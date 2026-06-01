class RunPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double speed; // in m/s
  final double accuracy; // in meters
  final double altitude; // in meters

  RunPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed = 0.0,
    this.accuracy = 0.0,
    this.altitude = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
      'ts': timestamp.toIso8601String(),
      'spd': speed,
      'acc': accuracy,
      'alt': altitude,
    };
  }

  factory RunPoint.fromJson(Map<String, dynamic> json) {
    return RunPoint(
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
      timestamp: DateTime.parse(json['ts'] as String),
      speed: (json['spd'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['acc'] as num?)?.toDouble() ?? 0.0,
      altitude: (json['alt'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
