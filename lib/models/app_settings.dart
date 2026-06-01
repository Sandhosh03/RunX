class AppSettings {
  final bool isMetric; // true for KM, false for Miles
  final bool autoFollowMap;
  final bool isDarkMode;

  // Notification Preferences
  final bool notificationsEnabled;
  final bool workoutReminders;
  final bool coachNotifications;
  final bool challengeNotifications;
  final bool communityNotifications;
  final String reminderTime; // "HH:mm" format
  final String quietHoursStart; // "HH:mm"
  final String quietHoursEnd; // "HH:mm"

  AppSettings({
    this.isMetric = true,
    this.autoFollowMap = true,
    this.notificationsEnabled = true,
    this.isDarkMode = true,
    this.workoutReminders = true,
    this.coachNotifications = true,
    this.challengeNotifications = true,
    this.communityNotifications = true,
    this.reminderTime = "08:00",
    this.quietHoursStart = "22:00",
    this.quietHoursEnd = "07:00",
  });

  Map<String, dynamic> toJson() {
    return {
      'isMetric': isMetric,
      'autoFollowMap': autoFollowMap,
      'notificationsEnabled': notificationsEnabled,
      'isDarkMode': isDarkMode,
      'workoutReminders': workoutReminders,
      'coachNotifications': coachNotifications,
      'challengeNotifications': challengeNotifications,
      'communityNotifications': communityNotifications,
      'reminderTime': reminderTime,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isMetric: json['isMetric'] ?? true,
      autoFollowMap: json['autoFollowMap'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      isDarkMode: json['isDarkMode'] ?? true,
      workoutReminders: json['workoutReminders'] ?? true,
      coachNotifications: json['coachNotifications'] ?? true,
      challengeNotifications: json['challengeNotifications'] ?? true,
      communityNotifications: json['communityNotifications'] ?? true,
      reminderTime: json['reminderTime'] ?? "08:00",
      quietHoursStart: json['quietHoursStart'] ?? "22:00",
      quietHoursEnd: json['quietHoursEnd'] ?? "07:00",
    );
  }

  AppSettings copyWith({
    bool? isMetric,
    bool? autoFollowMap,
    bool? notificationsEnabled,
    bool? isDarkMode,
    bool? workoutReminders,
    bool? coachNotifications,
    bool? challengeNotifications,
    bool? communityNotifications,
    String? reminderTime,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return AppSettings(
      isMetric: isMetric ?? this.isMetric,
      autoFollowMap: autoFollowMap ?? this.autoFollowMap,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      workoutReminders: workoutReminders ?? this.workoutReminders,
      coachNotifications: coachNotifications ?? this.coachNotifications,
      challengeNotifications: challengeNotifications ?? this.challengeNotifications,
      communityNotifications: communityNotifications ?? this.communityNotifications,
      reminderTime: reminderTime ?? this.reminderTime,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}
