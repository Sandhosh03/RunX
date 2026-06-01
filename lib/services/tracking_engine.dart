import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/run_point.dart';

enum GpsSignalStatus { excellent, good, fair, poor, none }

class TrackingEngine {
  // Configuration
  static const double minAccuracyThreshold = 20.0; // Discard > 20m
  static const double maxRealisticSpeed = 12.0; // ~43 km/h (Sprinting elite)
  static const int rollingAverageWindow = 5; // Points for pace smoothing

  // State
  final List<RunPoint> _route = [];
  double _totalDistance = 0.0; // meters
  double _elevationGain = 0.0;
  double _elevationLoss = 0.0;
  
  bool _isPaused = false;
  bool _isAutoPaused = false;
  
  GpsSignalStatus _signalStatus = GpsSignalStatus.none;
  StreamSubscription<Position>? _positionSubscription;
  
  // Callbacks
  final Function(List<RunPoint> route, double distance, double pace)? onUpdate;
  final Function(GpsSignalStatus status)? onSignalChange;
  final Function(bool isAutoPaused)? onAutoPauseChange;

  TrackingEngine({this.onUpdate, this.onSignalChange, this.onAutoPauseChange});

  List<RunPoint> get route => _route;
  double get distance => _totalDistance;
  double get elevationGain => _elevationGain;
  double get elevationLoss => _elevationLoss;
  GpsSignalStatus get signalStatus => _signalStatus;
  bool get isAutoPaused => _isAutoPaused;

  void start() {
    _isPaused = false;
    _isAutoPaused = false;
    
    final LocationSettings locationSettings;
    
    // Platform specific high-accuracy settings
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2,
      intervalDuration: const Duration(seconds: 1),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText: "RunX is tracking your elite performance.",
        notificationTitle: "RunX Active Tracking",
        enableWakeLock: true,
      ),
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_handlePosition);
  }

  void pause() {
    _isPaused = true;
  }

  void resume() {
    _isPaused = false;
    _isAutoPaused = false;
  }

  void stop() {
    _positionSubscription?.cancel();
  }

  void _handlePosition(Position pos) {
    _updateSignalStatus(pos.accuracy);

    if (_isPaused) return;

    // 1. Quality Filtering
    if (pos.accuracy > minAccuracyThreshold) return;

    final newPoint = RunPoint(
      latitude: pos.latitude,
      longitude: pos.longitude,
      timestamp: pos.timestamp,
      speed: pos.speed,
      accuracy: pos.accuracy,
      altitude: pos.altitude,
    );

    if (_route.isNotEmpty) {
      final lastPoint = _route.last;
      
      // 2. Jump & Speed Spike Filtering
      final double distanceBetween = Geolocator.distanceBetween(
        lastPoint.latitude, lastPoint.longitude,
        newPoint.latitude, newPoint.longitude
      );
      
      final double timeDiff = newPoint.timestamp.difference(lastPoint.timestamp).inSeconds.toDouble();
      
      if (timeDiff > 0) {
        final double calculatedSpeed = distanceBetween / timeDiff;
        if (calculatedSpeed > maxRealisticSpeed) return; // Ignore teleportation
      }

      // 3. Auto-Pause Logic
      if (pos.speed < 0.5 && !_isAutoPaused) {
        _isAutoPaused = true;
        onAutoPauseChange?.call(true);
        return;
      } else if (pos.speed >= 0.5 && _isAutoPaused) {
        _isAutoPaused = false;
        onAutoPauseChange?.call(false);
      }

      if (_isAutoPaused) return;

      // 4. Distance & Elevation
      _totalDistance += distanceBetween;
      
      final altDiff = newPoint.altitude - lastPoint.altitude;
      if (altDiff > 0.5) { // Threshold to avoid noise
        _elevationGain += altDiff;
      } else if (altDiff < -0.5) {
        _elevationLoss += altDiff.abs();
      }
    }

    // 5. Add point
    _route.add(newPoint);
    
    // Notify UI
    onUpdate?.call(_route, _totalDistance, _calculateStablePace());
  }

  void _updateSignalStatus(double accuracy) {
    GpsSignalStatus newStatus;
    if (accuracy <= 5) {
      newStatus = GpsSignalStatus.excellent;
    } else if (accuracy <= 10) {
      newStatus = GpsSignalStatus.good;
    } else if (accuracy <= 20) {
      newStatus = GpsSignalStatus.fair;
    } else {
      newStatus = GpsSignalStatus.poor;
    }

    if (newStatus != _signalStatus) {
      _signalStatus = newStatus;
      onSignalChange?.call(_signalStatus);
    }
  }

  double _calculateStablePace() {
    if (_route.length < 2) return 0.0;
    
    // Rolling average of speed for last X points
    int window = min(_route.length, rollingAverageWindow);
    double totalSpeed = 0.0;
    int count = 0;
    
    for (int i = _route.length - 1; i >= _route.length - window; i--) {
      if (_route[i].speed > 0) {
        totalSpeed += _route[i].speed;
        count++;
      }
    }
    
    double avgSpeed = count > 0 ? totalSpeed / count : 0.0;
    if (avgSpeed <= 0.2) return 0.0; // Stationary
    
    // Pace in min/km = (1 / speed in m/s) * (1000 / 60)
    return (1.0 / avgSpeed) * (1000.0 / 60.0);
  }
}
