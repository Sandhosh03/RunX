import '../models/training_plan.dart';
import '../models/user_profile.dart';

class PlanRecommendationEngine {
  static TrainingPlan generateRecommendation(UserProfile profile, double avgWeeklyDistance) {
    PlanType type;
    String name;
    String desc;
    int weeks = 8;

    if (profile.goal.toLowerCase().contains('weight') || profile.goal.toLowerCase().contains('lose')) {
      type = PlanType.weightLoss;
      name = "Weight Loss Journey";
      desc = "Focus on fat burning through consistent, low-intensity aerobic efforts.";
      weeks = 8;
    } else if (profile.goal.toLowerCase().contains('endurance') || profile.goal.toLowerCase().contains('stamina')) {
      type = PlanType.endurance;
      name = "Endurance Builder";
      desc = "Build a massive aerobic base with high-volume, low-intensity training.";
      weeks = 10;
    } else if (profile.fitnessLevel == 'Beginner' || avgWeeklyDistance < 10) {
      type = PlanType.beginner;
      name = "Zero to Runner";
      desc = "Build a solid foundation safely with run-walk intervals.";
      weeks = 8;
    } else if (profile.fitnessLevel == 'Intermediate' && avgWeeklyDistance < 25) {
      type = PlanType.fiveK;
      name = "5K PR Crusher";
      desc = "Improve your top-end speed and aerobic threshold for a fast 5K.";
      weeks = 6;
    } else if (avgWeeklyDistance >= 25 && avgWeeklyDistance < 40) {
      type = PlanType.tenK;
      name = "10K Power";
      desc = "Extend your stamina with tempo runs and focused long efforts.";
      weeks = 10;
    } else {
      type = PlanType.halfMarathon;
      name = "Half Marathon Prep";
      desc = "High-volume training to prepare your body for 21.1km.";
      weeks = 12;
    }

    return TrainingPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: desc,
      type: type,
      totalWeeks: weeks,
      startDate: DateTime.now(),
      schedule: _generateSchedule(type, weeks),
    );
  }

  static List<TrainingSession> _generateSchedule(PlanType type, int weeks) {
    List<TrainingSession> schedule = [];
    
    for (int w = 1; w <= weeks; w++) {
      double factor = 1.0 + (w - 1) * 0.08; // 8% increase per week
      
      // Structure: 
      // D1: Easy/Base
      // D2: Rest/Active Recovery
      // D3: Specific Workout (Speed, Tempo, or Intervals)
      // D4: Rest
      // D5: Easy/Recovery
      // D6: Long Run
      // D7: Rest

      schedule.add(_createSession(w, 1, type, factor, SessionType.easy));
      schedule.add(_createSession(w, 2, type, factor, SessionType.rest));
      
      SessionType workoutType = _getWorkoutType(type);
      schedule.add(_createSession(w, 3, type, factor, workoutType));
      
      schedule.add(_createSession(w, 4, type, factor, SessionType.rest));
      schedule.add(_createSession(w, 5, type, factor, SessionType.recovery));
      schedule.add(_createSession(w, 6, type, factor, SessionType.long));
      schedule.add(_createSession(w, 7, type, factor, SessionType.rest));
    }
    
    return schedule;
  }

  static SessionType _getWorkoutType(PlanType planType) {
    switch (planType) {
      case PlanType.fiveK: return SessionType.interval;
      case PlanType.tenK: return SessionType.tempo;
      case PlanType.halfMarathon: return SessionType.tempo;
      case PlanType.weightLoss: return SessionType.easy;
      case PlanType.endurance: return SessionType.easy;
      case PlanType.beginner: return SessionType.easy;
    }
  }

  static TrainingSession _createSession(int week, int day, PlanType planType, double factor, SessionType sessionType) {
    String title = "";
    String desc = "";
    int duration = 0;
    double distance = 0.0;

    switch (sessionType) {
      case SessionType.rest:
        title = "Rest Day";
        desc = "Full recovery. Let your muscles repair.";
        duration = 0;
        distance = 0.0;
        break;
      case SessionType.easy:
        title = "Easy Base";
        desc = "Conversational pace. Effort level 4/10.";
        duration = _getBaseDuration(planType, factor);
        distance = _getBaseDistance(planType, factor);
        break;
      case SessionType.recovery:
        title = "Recovery Jog";
        desc = "Very light effort. Flush the legs.";
        duration = 20;
        distance = planType == PlanType.beginner ? 2.0 : 3.0;
        break;
      case SessionType.tempo:
        title = "Tempo Run";
        desc = "Comfortably hard pace. Effort level 7/10.";
        duration = (_getBaseDuration(planType, factor) * 1.2).round();
        distance = _getBaseDistance(planType, factor) * 1.1;
        break;
      case SessionType.interval:
        title = "Interval Training";
        desc = "Alternating fast bursts with recovery walks.";
        duration = (_getBaseDuration(planType, factor) * 0.8).round();
        distance = _getBaseDistance(planType, factor) * 0.9;
        break;
      case SessionType.long:
        title = "Long Run";
        desc = "Focus on endurance and time on feet.";
        duration = (_getBaseDuration(planType, factor) * 1.5).round();
        distance = _getBaseDistance(planType, factor) * 1.6;
        break;
    }

    return TrainingSession(
      id: 'w${week}d$day',
      week: week,
      day: day,
      title: title,
      description: desc,
      type: sessionType,
      targetDurationMinutes: duration,
      targetDistanceKm: double.parse(distance.toStringAsFixed(1)),
    );
  }

  static int _getBaseDuration(PlanType type, double factor) {
    int base = 30;
    switch (type) {
      case PlanType.beginner: base = 20; break;
      case PlanType.fiveK: base = 30; break;
      case PlanType.tenK: base = 40; break;
      case PlanType.halfMarathon: base = 50; break;
      case PlanType.weightLoss: base = 35; break;
      case PlanType.endurance: base = 45; break;
    }
    return (base * factor).round();
  }

  static double _getBaseDistance(PlanType type, double factor) {
    double base = 4.0;
    switch (type) {
      case PlanType.beginner: base = 2.5; break;
      case PlanType.fiveK: base = 4.0; break;
      case PlanType.tenK: base = 6.0; break;
      case PlanType.halfMarathon: base = 8.0; break;
      case PlanType.weightLoss: base = 4.0; break;
      case PlanType.endurance: base = 7.0; break;
    }
    return base * factor;
  }
}
