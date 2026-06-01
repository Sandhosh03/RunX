class UserProfile {
  final String name;
  final int age;
  final String gender;
  final double weight;
  final double height; // in cm
  final String goal;
  final String fitnessLevel;
  final int xp;
  final int level;

  UserProfile({
    required this.name,
    required this.age,
    this.gender = 'Other',
    required this.weight,
    this.height = 175.0,
    required this.goal,
    this.fitnessLevel = 'Beginner',
    this.xp = 0,
    this.level = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'goal': goal,
      'fitnessLevel': fitnessLevel,
      'xp': xp,
      'level': level,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? 'Other',
      weight: (json['weight'] ?? 0.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
      goal: json['goal'] ?? '',
      fitnessLevel: json['fitnessLevel'] ?? 'Beginner',
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? goal,
    String? fitnessLevel,
    int? xp,
    int? level,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      xp: xp ?? this.xp,
      level: level ?? this.level,
    );
  }

  bool get isComplete {
    // Basic heuristic: if they have a name and non-zero age/weight/height
    // and they've interacted with setup.
    return name.isNotEmpty && age > 0 && weight > 0 && height > 0;
  }
}
