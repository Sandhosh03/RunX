import 'run_point.dart';

class RunSession {
  final double distance;
  final double calories;
  final int duration;
  final String date;
  final List<RunPoint>? route;
  final double? averagePace;
  final double elevationGain;
  final double elevationLoss;

  RunSession({
    required this.distance,
    required this.calories,
    required this.duration,
    required this.date,
    this.route,
    this.averagePace,
    this.elevationGain = 0.0,
    this.elevationLoss = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'calories': calories,
      'duration': duration,
      'date': date,
      'route': route?.map((p) => p.toJson()).toList(),
      'averagePace': averagePace,
      'elevationGain': elevationGain,
      'elevationLoss': elevationLoss,
    };
  }

  factory RunSession.fromJson(Map<String, dynamic> json) {
    // Migration helper for old Map based points
    List<RunPoint>? parsedRoute;
    if (json['route'] != null) {
      parsedRoute = (json['route'] as List)
          .map((p) => RunPoint.fromJson(Map<String, dynamic>.from(p)))
          .toList();
    } else if (json['routePoints'] != null) {
      // Old format fallback
      parsedRoute = (json['routePoints'] as List).map((p) {
        final map = Map<String, dynamic>.from(p);
        return RunPoint(
          latitude: map['lat'] ?? 0.0,
          longitude: map['lng'] ?? 0.0,
          timestamp: DateTime.now(), // Estimate
        );
      }).toList();
    }

    return RunSession(
      distance: (json['distance'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
      date: json['date'] as String,
      route: parsedRoute,
      averagePace: (json['averagePace'] as num?)?.toDouble(),
      elevationGain: (json['elevationGain'] as num?)?.toDouble() ?? 0.0,
      elevationLoss: (json['elevationLoss'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
