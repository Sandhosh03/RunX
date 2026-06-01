class GoalData {
  final double dailyDistanceGoal;

  final double dailyCaloriesGoal;

  GoalData({
    required this.dailyDistanceGoal,
    required this.dailyCaloriesGoal,
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyDistanceGoal':
          dailyDistanceGoal,
      'dailyCaloriesGoal':
          dailyCaloriesGoal,
    };
  }

  factory GoalData.fromJson(
    Map<String, dynamic> json,
  ) {
    return GoalData(
      dailyDistanceGoal:
          json['dailyDistanceGoal']
              .toDouble(),

      dailyCaloriesGoal:
          json['dailyCaloriesGoal']
              .toDouble(),
    );
  }
}
