import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/run_session.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/run_stat_tile.dart';
import '../../widgets/replay_controls.dart';

class RunDetailScreen extends StatefulWidget {
  final RunSession session;

  const RunDetailScreen({super.key, required this.session});

  @override
  State<RunDetailScreen> createState() => _RunDetailScreenState();
}

class _RunDetailScreenState extends State<RunDetailScreen> {
  final MapController mapController = MapController();
  List<LatLng> points = [];
  List<LatLng> replayPoints = [];
  bool isReplaying = false;
  int currentReplayIndex = 0;
  Timer? replayTimer;
  double replaySpeed = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.session.route != null) {
      points = widget.session.route!
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
    }
  }

  @override
  void dispose() {
    replayTimer?.cancel();
    super.dispose();
  }

  void toggleReplay() {
    if (points.isEmpty) return;

    if (isReplaying) {
      _stopReplay();
    } else {
      _startReplay();
    }
  }

  void toggleSpeed() {
    setState(() {
      if (replaySpeed == 1.0) {
        replaySpeed = 2.0;
      } else if (replaySpeed == 2.0) {
        replaySpeed = 4.0;
      } else {
        replaySpeed = 1.0;
      }
    });

    if (isReplaying) {
      _stopReplay();
      _startReplay();
    }
  }

  void _startReplay() {
    setState(() {
      isReplaying = true;
      if (currentReplayIndex >= points.length - 1) {
        currentReplayIndex = 0;
        replayPoints = [];
      }
    });

    replayTimer?.cancel();
    int interval = (100 ~/ replaySpeed).clamp(10, 100);
    replayTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (currentReplayIndex < points.length) {
        setState(() {
          replayPoints.add(points[currentReplayIndex]);
          mapController.move(points[currentReplayIndex], 17);
          currentReplayIndex++;
        });
      } else {
        _stopReplay();
      }
    });
  }

  void _stopReplay() {
    replayTimer?.cancel();
    setState(() {
      isReplaying = false;
    });
  }

  void restartReplay() {
    _stopReplay();
    setState(() {
      currentReplayIndex = 0;
      replayPoints = [];
    });
    _startReplay();
  }

  double get replayProgress {
    if (points.isEmpty) return 0.0;
    return (currentReplayIndex / points.length).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Run Insight',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: points.isNotEmpty ? points.first : const LatLng(0, 0),
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                          userAgentPackageName:
                              'com.runx.app',
                        ),
                        PolylineLayer(
                          polylines: [
                            // Shadow polyline
                            Polyline(
                              points: points,
                              strokeWidth: 6,
                              color: Colors.black26,
                            ),
                            // Progressive polyline
                            Polyline(
                              points: isReplaying || replayPoints.isNotEmpty ? replayPoints : points,
                              strokeWidth: 5,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        if (replayPoints.isNotEmpty)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: replayPoints.last,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.directions_run_rounded,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.session.date,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Text(
                                  'Morning Run Performance',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.share_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.5,
                          children: [
                            RunStatTile(
                              label: 'DISTANCE',
                              value: '${widget.session.distance.toStringAsFixed(2)} KM',
                              icon: Icons.map_outlined,
                            ),
                            RunStatTile(
                              label: 'DURATION',
                              value: formatDuration(widget.session.duration),
                              icon: Icons.timer_outlined,
                              iconColor: Colors.orangeAccent,
                            ),
                            RunStatTile(
                              label: 'CALORIES',
                              value: '${widget.session.calories.toStringAsFixed(0)} KCAL',
                              icon: Icons.local_fire_department_outlined,
                              iconColor: Colors.redAccent,
                            ),
                            RunStatTile(
                              label: 'AVG PACE',
                              value: '${widget.session.averagePace?.toStringAsFixed(2) ?? "N/A"} /KM',
                              icon: Icons.speed_rounded,
                              iconColor: Colors.blueAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Insights',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.auto_awesome, color: AppColors.primary),
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Text(
                                  'Your pace was remarkably consistent throughout the run. Great job!',
                                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Space for controls
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (points.isNotEmpty)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: ReplayControls(
                  isReplaying: isReplaying,
                  onPlayPause: toggleReplay,
                  onRestart: restartReplay,
                  progress: replayProgress,
                  speed: replaySpeed,
                  onSpeedChange: toggleSpeed,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String formatDuration(int seconds) {
    final hours = (seconds ~/ 3600);
    final mins = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$mins:$secs' : '$mins:$secs';
  }
}
