import 'package:flutter/material.dart';

enum CoachInsightType { performance, recovery, motivation, training, safety }

class CoachInsight {
  final String title;
  final String message;
  final CoachInsightType type;
  final IconData icon;

  const CoachInsight({
    required this.title,
    required this.message,
    required this.type,
    required this.icon,
  });
}

class CoachRecommendation {
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onAction;

  const CoachRecommendation({
    required this.title,
    required this.description,
    required this.actionLabel,
    this.onAction,
  });
}

class CoachPerformanceAnalysis {
  final double weeklyMileage;
  final double averagePace;
  final int runCount;
  final String summary;
  final double consistencyScore;

  const CoachPerformanceAnalysis({
    required this.weeklyMileage,
    required this.averagePace,
    required this.runCount,
    required this.summary,
    required this.consistencyScore,
  });
}
