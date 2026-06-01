enum ChallengeCategory { distance, calories, streak, runCount }

class Challenge {
  final String id;
  final String title;
  final String description;
  final double target;
  final double currentProgress;
  final ChallengeCategory category;
  final String reward;
  final String icon;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.currentProgress,
    required this.category,
    required this.reward,
    required this.icon,
  });

  double get completionPercentage => (currentProgress / target).clamp(0.0, 1.0);
  bool get isCompleted => currentProgress >= target;
}
