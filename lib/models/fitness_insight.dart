import 'package:flutter/material.dart';

enum InsightType {
  performance,
  motivational,
  goal,
  recovery,
  progression,
}

class FitnessInsight {
  final String title;
  final String message;
  final InsightType type;
  final IconData icon;
  final Color color;

  FitnessInsight({
    required this.title,
    required this.message,
    required this.type,
    required this.icon,
    required this.color,
  });
}
