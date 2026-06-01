import 'package:flutter/material.dart';
import '../models/run_session.dart';
import '../models/streak_data.dart';
import '../models/goal_data.dart';
import '../models/user_profile.dart';
import '../models/coach_data.dart';
import '../models/training_plan.dart';
import 'training_plan_service.dart';

class InsightEngine {
  static CoachInsight generateDailyInsight({
    required List<RunSession> runs,
    required StreakData? streak,
    required UserProfile? profile,
    TrainingPlan? activePlan,
  }) {
    if (activePlan != null) {
      final stats = PlanProgressTracker.calculateStats(activePlan);
      final double adherence = stats['adherence'];
      final int missed = stats['missed'];
      
      if (missed >= 3) {
        return const CoachInsight(
          title: "PLAN RECOVERY",
          message: "You've missed several sessions. Don't worry about the past—let's reset and focus on tomorrow's goal.",
          type: CoachInsightType.recovery,
          icon: Icons.health_and_safety_rounded,
        );
      }

      if (adherence > 95 && stats['completed'] > 5) {
        return const CoachInsight(
          title: "ELITE ADHERENCE",
          message: "Your discipline is exceptional. You're following the plan perfectly. Keep this momentum!",
          type: CoachInsightType.performance,
          icon: Icons.verified_rounded,
        );
      }
      
      final todaySession = activePlan.getTodaySession();
      if (todaySession != null && !todaySession.isCompleted) {
        String sessionTypeName = todaySession.type.toString().split('.').last.toUpperCase();
        return CoachInsight(
          title: "TODAY'S MISSION",
          message: "A $sessionTypeName session is waiting: ${todaySession.title}. It's key for your ${activePlan.type.toString().split('.').last} goal.",
          type: CoachInsightType.training,
          icon: Icons.track_changes_rounded,
        );
      }
    }

    if (runs.isEmpty) {
      return const CoachInsight(
        title: "THE FIRST STEP",
        message: "Your journey to elite performance starts with a single step. Let's record your first run today.",
        type: CoachInsightType.motivation,
        icon: Icons.directions_run_rounded,
      );
    }

    final latestRun = runs.first;
    
    // Recovery Logic
    if (latestRun.distance > 15) {
      return const CoachInsight(
        title: "RECOVERY PRIORITY",
        message: "Your last run was intense. Focus on mobility work and hydration today to prevent overtraining.",
        type: CoachInsightType.recovery,
        icon: Icons.self_improvement_rounded,
      );
    }

    // Consistency Logic
    if (streak != null && streak.currentStreak > 3) {
      return CoachInsight(
        title: "MOMENTUM BUILT",
        message: "You're on a ${streak.currentStreak} day streak. Your aerobic base is strengthening significantly.",
        type: CoachInsightType.performance,
        icon: Icons.bolt_rounded,
      );
    }

    // Default Advice
    return const CoachInsight(
      title: "TRAINING TIP",
      message: "Varying your running surfaces can reduce injury risk. Try a trail or track session this week.",
      type: CoachInsightType.training,
      icon: Icons.lightbulb_outline_rounded,
    );
  }

  static CoachPerformanceAnalysis analyzeWeeklyPerformance(List<RunSession> runs, {TrainingPlan? activePlan}) {
    double mileage = 0;
    double totalPace = 0;
    int paceCount = 0;
    
    // Last 7 days logic...
    int runsThisWeek = 0;
    for (var run in runs) {
      if (runsThisWeek < 5) { // Limit to recent
        mileage += run.distance;
        if (run.averagePace != null) {
          totalPace += run.averagePace!;
          paceCount++;
        }
        runsThisWeek++;
      }
    }

    double avgPace = paceCount > 0 ? totalPace / paceCount : 0;
    
    String summary = mileage > 20 
      ? "High volume week. You're building serious endurance."
      : "Building consistency. Keep increasing your volume gradually.";
      
    if (activePlan != null) {
      final stats = PlanProgressTracker.calculateStats(activePlan);
      if (stats['adherence'] >= 90) {
        summary = "Outstanding plan adherence (${stats['adherence'].toStringAsFixed(0)}%). You are perfectly on track for your goal.";
      } else if (stats['adherence'] < 60) {
        summary = "We've slipped on the plan recently. Let's aim for 3 sessions this week to rebuild consistency.";
      }
    }

    return CoachPerformanceAnalysis(
      weeklyMileage: mileage,
      averagePace: avgPace,
      runCount: runsThisWeek,
      summary: summary,
      consistencyScore: (runsThisWeek / 5).clamp(0.0, 1.0),
    );
  }
}

class RecommendationEngine {
  static List<CoachRecommendation> getRecommendations({
    required List<RunSession> runs,
    required GoalData? goals,
    TrainingPlan? activePlan,
  }) {
    final List<CoachRecommendation> recs = [];

    if (activePlan == null) {
      recs.add(const CoachRecommendation(
        title: "Start a Training Plan",
        description: "Get a personalized schedule to reach your goals faster.",
        actionLabel: "GET PLAN",
      ));
    } else {
      final stats = PlanProgressTracker.calculateStats(activePlan);
      if (stats['adherence'] < 50 && stats['expected'] > 5) {
        recs.add(const CoachRecommendation(
          title: "Adjust Plan Intensity",
          description: "You've been struggling to keep up. Should we dial down the intensity?",
          actionLabel: "RECALCULATE",
        ));
      }
      
      if (stats['completion'] > 90) {
        recs.add(const CoachRecommendation(
          title: "Plan Near Completion",
          description: "You've almost finished your plan. Start thinking about your next milestone!",
          actionLabel: "BROWSE",
        ));
      }
    }

    if (goals != null && goals.dailyDistanceGoal < 5) {
      recs.add(const CoachRecommendation(
        title: "Level Up Goal",
        description: "You're consistently hitting targets. Try a 7km daily goal.",
        actionLabel: "ADJUST GOAL",
      ));
    }

    recs.add(const CoachRecommendation(
      title: "Injury Prevention",
      description: "Perform 10 mins of dynamic stretching before your next run.",
      actionLabel: "SEE EXERCISES",
    ));

    return recs;
  }
}
