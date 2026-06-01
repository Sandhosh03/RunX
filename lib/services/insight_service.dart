import 'package:flutter/material.dart';
import '../models/fitness_insight.dart';
import '../models/run_session.dart';
import '../models/streak_data.dart';
import '../models/goal_data.dart';
import '../models/xp_data.dart';

class InsightService {
  static List<FitnessInsight> generateInsights({
    required List<RunSession> runs,
    required StreakData? streakData,
    required GoalData? goalData,
    required XpData? xpData,
    required double todayDistance,
    required double todayCalories,
  }) {
    final List<FitnessInsight> insights = [];

    // 1. Goal Progress Insight
    if (goalData != null && todayDistance > 0) {
      double progress = (todayDistance / goalData.dailyDistanceGoal);
      if (progress >= 1.0) {
        insights.add(FitnessInsight(
          title: 'Goal Achieved!',
          message: "You've smashed today's distance goal. Exceptional work!",
          type: InsightType.goal,
          icon: Icons.stars_rounded,
          color: Colors.white,
        ));
      } else if (progress >= 0.7) {
        insights.add(FitnessInsight(
          title: 'Almost There',
          message: "You're ${(progress * 100).toInt()}% toward today's distance goal. Finish strong!",
          type: InsightType.goal,
          icon: Icons.flag_circle_rounded,
          color: Colors.white,
        ));
      }
    }

    // 2. Streak Insight
    if (streakData != null && streakData.currentStreak > 1) {
      insights.add(FitnessInsight(
        title: 'Consistency King',
        message: "Amazing consistency! You're on a ${streakData.currentStreak}-day streak.",
        type: InsightType.motivational,
        icon: Icons.local_fire_department_rounded,
        color: Colors.white,
      ));
    }

    // 3. XP Progression Insight
    if (xpData != null) {
      int remaining = xpData.xpNeededForNextLevel - xpData.currentXp;
      if (remaining < 200) {
        insights.add(FitnessInsight(
          title: 'Level Up Near',
          message: "You're only $remaining XP away from Level ${xpData.level + 1}!",
          type: InsightType.progression,
          icon: Icons.auto_awesome_rounded,
          color: Colors.white,
        ));
      }
    }

    // 4. Performance / Pace Insight
    if (runs.length >= 2) {
      final latest = runs[0];
      final previous = runs[1];
      if (latest.averagePace != null && previous.averagePace != null) {
        if (latest.averagePace! < previous.averagePace!) {
          insights.add(FitnessInsight(
            title: 'Speed Boost',
            message: "Your average pace improved compared to your last run. Getting faster!",
            type: InsightType.performance,
            icon: Icons.speed_rounded,
            color: Colors.cyanAccent,
          ));
        }
      }
    }

    // 5. Recovery Insight
    if (runs.isNotEmpty) {
      final latest = runs[0];
      if (latest.distance > 10) {
        insights.add(FitnessInsight(
          title: 'Recovery Time',
          message: "That was a long run! Ensure you prioritize recovery today.",
          type: InsightType.recovery,
          icon: Icons.self_improvement_rounded,
          color: Colors.lightBlueAccent,
        ));
      }
    }

    // 6. Workout Readiness & Streak Protection (Retention Hooks)
    if (streakData != null && streakData.currentStreak > 0 && todayDistance == 0) {
      insights.add(FitnessInsight(
        title: 'Streak at Risk',
        message: "Your ${streakData.currentStreak}-day streak is on the line. Run at least 1km to protect it!",
        type: InsightType.motivational,
        icon: Icons.shield_outlined,
        color: Colors.redAccent,
      ));
    } else if (todayDistance == 0) {
      insights.add(FitnessInsight(
        title: 'Daily Challenge',
        message: "Can you beat your average pace today? Accept the challenge!",
        type: InsightType.performance,
        icon: Icons.fitness_center_rounded,
        color: Colors.amberAccent,
      ));
    } else {
       insights.add(FitnessInsight(
        title: 'Workout Readiness',
        message: "Your metrics look optimal. You are primed for a high-intensity session.",
        type: InsightType.recovery,
        icon: Icons.battery_charging_full_rounded,
        color: Colors.white,
      ));
    }

    // Default motivational if list is short
    if (insights.length < 2) {
      insights.add(FitnessInsight(
        title: 'Ready to Run?',
        message: "Every mile is a victory. Lace up and hit the road today!",
        type: InsightType.motivational,
        icon: Icons.directions_run_rounded,
        color: Colors.white,
      ));
    }

    return insights;
  }

  static Map<String, dynamic> calculateWeeklySummary(List<RunSession> runs) {
    double totalDistance = 0;
    double totalCalories = 0;
    int totalDuration = 0;
    
    // Simplification: just last 7 runs for summary
    final weeklyRuns = runs.take(7).toList();
    
    for (var run in weeklyRuns) {
      totalDistance += run.distance;
      totalCalories += run.calories;
      totalDuration += run.duration;
    }

    return {
      'distance': totalDistance,
      'calories': totalCalories,
      'count': weeklyRuns.length,
      'duration': totalDuration,
    };
  }
}
