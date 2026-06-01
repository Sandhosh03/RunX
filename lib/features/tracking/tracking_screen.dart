import '../../models/run_session.dart';
import '../../services/run_storage_service.dart';
import '../../services/xp_service.dart';
import '../../services/settings_service.dart';
import '../../services/tracking_engine.dart';
import '../../widgets/premium/premium_card.dart';
import '../../core/theme/app_colors.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'post_run_summary_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController mapController = MapController();
  late TrackingEngine _engine;

  List<LatLng> routeLatLngs = [];
  GpsSignalStatus signalStatus = GpsSignalStatus.none;

  bool isTracking = false;
  bool isPaused = false;
  bool isAutoPaused = false;
  bool isPreparingRun = true;
  bool isReadyToRun = false;
  bool isCountingDown = false;
  bool isRunStopped = false;
  int countdownValue = 3;

  double totalDistance = 0; // meters
  double livePace = 0.0;
  double calories = 0;
  int elapsedSeconds = 0;

  Timer? runTimer;
  bool followUser = true;

  @override
  void initState() {
    super.initState();
    _initEngine();
    prepareRun();
  }

  void _initEngine() {
    _engine = TrackingEngine(
      onUpdate: (route, distance, pace) {
        if (mounted) {
          setState(() {
            routeLatLngs = route.map((p) => LatLng(p.latitude, p.longitude)).toList();
            totalDistance = distance;
            livePace = pace;
            // Calorie estimation: simple factor * distance in km
            calories = (totalDistance / 1000) * 65; 
            
            if (followUser && routeLatLngs.isNotEmpty) {
              mapController.move(routeLatLngs.last, 17);
            }
          });
        }
      },
      onSignalChange: (status) {
        if (mounted) {
          setState(() => signalStatus = status);
        }
      },
      onAutoPauseChange: (autoPaused) {
        if (mounted) {
          setState(() => isAutoPaused = autoPaused);
          if (autoPaused) {
            _stopTimer();
          } else if (isTracking && !isPaused) {
            _startTimer();
          }
        }
      },
    );
  }

  void prepareRun() async {
    final settings = await SettingsService.getSettings();
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        Navigator.pop(context);
        return;
      }
    }

    try {
      Position currentPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          routeLatLngs.add(LatLng(currentPos.latitude, currentPos.longitude));
          followUser = settings.autoFollowMap;
          isPreparingRun = false;
          isReadyToRun = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) mapController.move(routeLatLngs.last, 17);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          followUser = settings.autoFollowMap;
          isPreparingRun = false;
          isReadyToRun = true;
        });
      }
    }
  }

  void _startCountdown() {
    setState(() {
      isReadyToRun = false;
      isCountingDown = true;
      countdownValue = 3;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (countdownValue > 1) {
        setState(() => countdownValue--);
      } else {
        timer.cancel();
        setState(() => isCountingDown = false);
        startRun();
      }
    });
  }

  void startRun() {
    setState(() {
      isTracking = true;
      isPaused = false;
    });
    _startTimer();
    _engine.start();
  }

  void _startTimer() {
    runTimer?.cancel();
    runTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused && !isAutoPaused) {
        if (mounted) setState(() => elapsedSeconds++);
      }
    });
  }

  void _stopTimer() {
    runTimer?.cancel();
  }

  void togglePause() {
    if (isPaused) {
      _startTimer();
      _engine.resume();
    } else {
      _stopTimer();
      _engine.pause();
    }
    setState(() => isPaused = !isPaused);
  }

  void stopRun() async {
    _stopTimer();
    _engine.stop();

    final distanceKm = totalDistance / 1000;
    double averagePace = distanceKm > 0 ? (elapsedSeconds / 60) / distanceKm : 0;

    final session = RunSession(
      distance: distanceKm,
      calories: calories,
      duration: elapsedSeconds,
      date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      route: _engine.route,
      averagePace: averagePace,
      elevationGain: _engine.elevationGain,
      elevationLoss: _engine.elevationLoss,
    );

    await RunStorageService.saveRun(session);
    final xpResult = await XpService.addRunXp(session);

    setState(() => isRunStopped = true);

    if (!mounted) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PostRunSummaryScreen(
          session: session,
          earnedXp: xpResult['earnedXp'],
          leveledUp: xpResult['leveledUp'],
          newLevel: xpResult['newLevel'],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopTimer();
    _engine.stop();
    super.dispose();
  }

  String _formatPace(double pace) {
    if (pace <= 0 || pace > 60) return "--:--";
    int mins = pace.floor();
    int secs = ((pace - mins) * 60).round();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildGpsSignalIndicator() {
    Color color;
    String label;
    switch (signalStatus) {
      case GpsSignalStatus.excellent:
        color = Colors.greenAccent;
        label = "EXCELLENT";
        break;
      case GpsSignalStatus.good:
        color = Colors.white;
        label = "GOOD";
        break;
      case GpsSignalStatus.fair:
        color = Colors.orangeAccent;
        label = "FAIR";
        break;
      case GpsSignalStatus.poor:
        color = Colors.redAccent;
        label = "POOR";
        break;
      default:
        color = Colors.white24;
        label = "NO SIGNAL";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_tethering_rounded, color: color, size: 14),
          const SizedBox(width: 8),
          Text(
            "GPS: $label",
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: routeLatLngs.isNotEmpty ? routeLatLngs.last : const LatLng(0, 0),
              initialZoom: 17,
              maxZoom: 18,
              minZoom: 3,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.runx.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routeLatLngs,
                    strokeWidth: 5,
                    color: Colors.white,
                  ),
                ],
              ),
              if (routeLatLngs.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: routeLatLngs.last,
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          if (isPreparingRun)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.satellite_alt_rounded, color: AppColors.primary, size: 60),
                      SizedBox(height: 30),
                      CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                      SizedBox(height: 30),
                      Text('CALIBRATING TRACKING ENGINE...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(child: _buildGpsSignalIndicator()),
          ),

          if (isReadyToRun)
            Positioned(
              bottom: 60,
              left: 30,
              right: 30,
              child: GestureDetector(
                onTap: _startCountdown,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('START RUN', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ),
                ),
              ),
            ),

          if (isCountingDown)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
                child: Center(
                  child: Text(
                    countdownValue > 0 ? countdownValue.toString() : 'GO!',
                    style: const TextStyle(fontSize: 120, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
            ),

          if (isTracking || isPaused || isRunStopped) ...[
            Positioned(
              top: 110,
              left: 20,
              right: 20,
              child: PremiumCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  children: [
                    if (isAutoPaused)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Text(
                          'AUTO-PAUSED',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetric((totalDistance / 1000).toStringAsFixed(2), 'KM'),
                        _buildMetric(_formatPace(livePace), 'PACE'),
                        _buildMetric(formatTime(elapsedSeconds), 'TIME'),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(color: AppColors.outline),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetric(_engine.elevationGain.toStringAsFixed(0), 'ELEV GAIN', fontSize: 18),
                        _buildMetric(calories.toStringAsFixed(0), 'KCAL', fontSize: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isRunStopped) ...[
                    GestureDetector(
                      onTap: togglePause,
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                        child: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: AppColors.primary, size: 40),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onLongPress: stopRun,
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.stop_rounded, color: Colors.black, size: 45),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => setState(() => followUser = !followUser),
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                        child: Icon(Icons.my_location, color: followUser ? AppColors.primary : Colors.white70, size: 30),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label, {double fontSize = 26}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ],
    );
  }

  String formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return hours == '00' ? '$minutes:$secs' : '$hours:$minutes:$secs';
  }
}

