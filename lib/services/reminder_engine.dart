import 'notification_service.dart';
import 'settings_service.dart';
import 'training_plan_service.dart';
import 'run_storage_service.dart';
import 'streak_service.dart';
import 'challenge_service.dart';
import '../models/app_settings.dart';
import '../models/training_plan.dart';

class ReminderEngine {
  static const int workoutIdBase = 1000;
  static const int streakIdBase = 2000;
  static const int coachIdBase = 3000;
  static const int challengeIdBase = 4000;

  static Future<void> refreshAllReminders() async {
    final settings = await SettingsService.getSettings();
    if (!settings.notificationsEnabled) {
      await NotificationService.cancelAll();
      return;
    }

    await NotificationService.cancelAll();

    if (settings.workoutReminders) {
      await scheduleWorkoutReminders(settings);
    }

    await scheduleStreakProtection(settings);
    
    if (settings.coachNotifications) {
      await scheduleCoachAlerts(settings);
    }
    
    if (settings.challengeNotifications) {
      await scheduleChallengeReminders(settings);
    }
  }

  static Future<void> scheduleWorkoutReminders(AppSettings settings) async {
    final plan = await TrainingPlanService.getActivePlan();
    if (plan == null) return;

    final timeParts = settings.reminderTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final targetDate = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      final session = _getSessionForDate(plan, targetDate);
      
      if (session != null && !session.isCompleted) {
        if (session.type == SessionType.rest) {
          await NotificationService.scheduleNotification(
            id: workoutIdBase + i,
            title: "RECOVERY DAY",
            body: "Today is a rest day. Focus on mobility and hydration.",
            scheduledDate: DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute),
          );
        } else {
          String workoutType = session.type.toString().split('.').last.toUpperCase();
          await NotificationService.scheduleNotification(
            id: workoutIdBase + i,
            title: "WORKOUT PENDING: $workoutType",
            body: "Your ${session.title} is waiting. Goal: ${session.targetDistanceKm > 0 ? '${session.targetDistanceKm}km' : '${session.targetDurationMinutes}min'}.",
            scheduledDate: DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute),
          );
        }
      }
    }
  }

  static Future<void> scheduleStreakProtection(AppSettings settings) async {
    final runs = await RunStorageService.getRuns();
    final streak = StreakService.calculateStreak(runs);
    
    if (streak.currentStreak > 0) {
      final now = DateTime.now();
      final todayStr = "${now.day}/${now.month}/${now.year}";
      bool hasRunToday = runs.any((r) => r.date == todayStr);

      if (!hasRunToday) {
        final reminderTime = DateTime(now.year, now.month, now.day, 19, 0);
        if (reminderTime.isAfter(now)) {
          await NotificationService.scheduleNotification(
            id: streakIdBase,
            title: "STREAK AT RISK",
            body: "Your ${streak.currentStreak}-day streak is at risk! Don't let it break.",
            scheduledDate: reminderTime,
          );
        }
      }
    }
  }

  static Future<void> scheduleCoachAlerts(AppSettings settings) async {
    final runs = await RunStorageService.getRuns();
    
    if (runs.isNotEmpty) {
      final recentRuns = runs.take(3).toList();
      double recentMileage = recentRuns.fold(0, (sum, r) => sum + r.distance);
      
      if (recentMileage > 30) {
        await NotificationService.scheduleNotification(
          id: coachIdBase,
          title: "COACH WARNING",
          body: "High volume detected. I recommend an extra recovery day to prevent injury.",
          scheduledDate: DateTime.now().add(const Duration(hours: 2)),
        );
      }
    }
  }

  static Future<void> scheduleChallengeReminders(AppSettings settings) async {
    final runs = await RunStorageService.getRuns();
    final challenges = ChallengeService.generateChallenges(runs);
    
    for (var challenge in challenges) {
      if (!challenge.isCompleted && challenge.completionPercentage > 0.8) {
        await NotificationService.scheduleNotification(
          id: challengeIdBase + challenges.indexOf(challenge),
          title: "CHALLENGE NEARLY COMPLETE",
          body: "You're 80% through the ${challenge.title}. Push through to earn your reward!",
          scheduledDate: DateTime.now().add(const Duration(hours: 4)),
        );
      }
    }
  }

  static TrainingSession? _getSessionForDate(TrainingPlan plan, DateTime date) {
    final diff = date.difference(plan.startDate).inDays;
    if (diff < 0) return null;
    
    final currentWeek = (diff ~/ 7) + 1;
    final currentDay = (diff % 7) + 1;
    
    try {
      return plan.schedule.firstWhere((s) => s.week == currentWeek && s.day == currentDay);
    } catch (e) {
      return null;
    }
  }
}
