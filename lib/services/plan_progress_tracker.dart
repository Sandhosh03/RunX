import '../models/training_plan.dart';

class PlanProgressTracker {
  static Map<String, dynamic> calculateStats(TrainingPlan plan) {
    final now = DateTime.now();
    final diff = now.difference(plan.startDate).inDays;
    
    int expectedCompleted = 0;
    int actuallyCompleted = 0;
    int missed = 0;
    int totalWorkoutSessions = plan.schedule.where((s) => s.type != SessionType.rest).length;

    // 1. Calculate Adherence & Completion
    for (var s in plan.schedule) {
      bool isPastOrToday = (s.week - 1) * 7 + (s.day - 1) <= diff;
      
      if (s.type != SessionType.rest) {
        if (isPastOrToday) {
          expectedCompleted++;
          if (s.isCompleted) {
            actuallyCompleted++;
          } else {
            // If it's strictly in the past, it's missed
            if ((s.week - 1) * 7 + (s.day - 1) < diff) {
              missed++;
            }
          }
        }
      }
    }

    double adherence = expectedCompleted == 0 ? 100.0 : (actuallyCompleted / expectedCompleted) * 100;
    double completionPercentage = totalWorkoutSessions == 0 ? 0.0 : (plan.completedSessions / totalWorkoutSessions) * 100;

    // 2. Calculate Consistency Score
    // Defined as: % of elapsed weeks where >= 75% of scheduled workouts were completed
    int consistentWeeks = 0;
    int elapsedWeeks = diff < 0 ? 0 : (diff ~/ 7) + 1;
    if (elapsedWeeks > plan.totalWeeks) elapsedWeeks = plan.totalWeeks;

    for (int w = 1; w <= elapsedWeeks; w++) {
      var weekSessions = plan.schedule.where((s) => s.week == w && s.type != SessionType.rest);
      if (weekSessions.isEmpty) {
        consistentWeeks++;
        continue;
      }
      
      int completedInWeek = weekSessions.where((s) => s.isCompleted).length;
      if (completedInWeek / weekSessions.length >= 0.75) {
        consistentWeeks++;
      }
    }

    double consistencyScore = elapsedWeeks == 0 ? 100.0 : (consistentWeeks / elapsedWeeks) * 100;

    return {
      'adherence': adherence,
      'consistency': consistencyScore,
      'completion': completionPercentage,
      'missed': missed,
      'expected': expectedCompleted,
      'completed': actuallyCompleted,
      'totalWorkouts': totalWorkoutSessions,
    };
  }

  // Legacy support for older code if any
  static Map<String, dynamic> calculateAdherence(TrainingPlan plan) {
    final stats = calculateStats(plan);
    return {
      'score': stats['adherence'],
      'missed': stats['missed'],
      'expected': stats['expected'],
      'completed': stats['completed'],
    };
  }
}
