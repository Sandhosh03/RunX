enum PlanType { beginner, fiveK, tenK, halfMarathon, weightLoss, endurance }
enum SessionType { easy, tempo, interval, long, recovery, rest }

class TrainingSession {
  final String id;
  final int week;
  final int day;
  final String title;
  final String description;
  final SessionType type;
  final int targetDurationMinutes;
  final double targetDistanceKm;
  final bool isCompleted;

  TrainingSession({
    required this.id,
    required this.week,
    required this.day,
    required this.title,
    required this.description,
    required this.type,
    required this.targetDurationMinutes,
    this.targetDistanceKm = 0.0,
    this.isCompleted = false,
  });

  TrainingSession copyWith({bool? isCompleted}) {
    return TrainingSession(
      id: id,
      week: week,
      day: day,
      title: title,
      description: description,
      type: type,
      targetDurationMinutes: targetDurationMinutes,
      targetDistanceKm: targetDistanceKm,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week': week,
      'day': day,
      'title': title,
      'description': description,
      'type': type.toString(),
      'targetDurationMinutes': targetDurationMinutes,
      'targetDistanceKm': targetDistanceKm,
      'isCompleted': isCompleted,
    };
  }

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'],
      week: json['week'],
      day: json['day'],
      title: json['title'],
      description: json['description'],
      type: SessionType.values.firstWhere((e) => e.toString() == json['type'], orElse: () => SessionType.easy),
      targetDurationMinutes: json['targetDurationMinutes'],
      targetDistanceKm: json['targetDistanceKm'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class TrainingPlan {
  final String id;
  final String name;
  final String description;
  final PlanType type;
  final int totalWeeks;
  final List<TrainingSession> schedule;
  final DateTime startDate;

  TrainingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.totalWeeks,
    required this.schedule,
    required this.startDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'totalWeeks': totalWeeks,
      'schedule': schedule.map((s) => s.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
    };
  }

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: PlanType.values.firstWhere((e) => e.toString() == json['type'], orElse: () => PlanType.beginner),
      totalWeeks: json['totalWeeks'],
      schedule: (json['schedule'] as List).map((s) => TrainingSession.fromJson(s)).toList(),
      startDate: DateTime.parse(json['startDate']),
    );
  }
  
  TrainingSession? getTodaySession() {
    final now = DateTime.now();
    final diff = now.difference(startDate).inDays;
    if (diff < 0) return null;
    
    final currentWeek = (diff ~/ 7) + 1;
    final currentDay = (diff % 7) + 1;
    
    try {
      return schedule.firstWhere((s) => s.week == currentWeek && s.day == currentDay);
    } catch (e) {
      return null;
    }
  }

  int get completedSessions => schedule.where((s) => s.isCompleted).length;
  double get progressPercentage => schedule.isEmpty ? 0 : completedSessions / schedule.length;
  
  int get currentWeek {
    final diff = DateTime.now().difference(startDate).inDays;
    if (diff < 0) return 1;
    return (diff ~/ 7) + 1;
  }
}
