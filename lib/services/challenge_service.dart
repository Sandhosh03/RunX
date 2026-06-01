import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/challenge.dart';
import '../models/run_session.dart';
import '../models/streak_data.dart';
import 'streak_service.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class ChallengeService {
  static final SupabaseClient _client = SupabaseService.client;

  static List<Challenge> generateChallenges(List<RunSession> runs) {
    double totalDistance = 0;
    double totalCalories = 0;
    int runCount = runs.length;
    StreakData streak = StreakService.calculateStreak(runs);

    for (var run in runs) {
      totalDistance += run.distance;
      totalCalories += run.calories;
    }

    return [
      Challenge(
        id: 'dist_may_2026',
        title: 'May Distance Master',
        description: 'Run 50km this month to earn the Master Badge.',
        target: 50.0,
        currentProgress: totalDistance,
        category: ChallengeCategory.distance,
        reward: 'Master Badge',
        icon: '👟',
      ),
      Challenge(
        id: 'cal_may_2026',
        title: 'Calorie Crusher',
        description: 'Burn 5000 calories through running.',
        target: 5000.0,
        currentProgress: totalCalories,
        category: ChallengeCategory.calories,
        reward: 'Flame Icon',
        icon: '🔥',
      ),
      Challenge(
        id: 'streak_may_2026',
        title: 'Consistency King',
        description: 'Maintain a 7-day run streak.',
        target: 7.0,
        currentProgress: streak.currentStreak.toDouble(),
        category: ChallengeCategory.streak,
        reward: 'King Crown',
        icon: '👑',
      ),
      Challenge(
        id: 'count_may_2026',
        title: 'Frequent Flyer',
        description: 'Complete 10 runs in May.',
        target: 10.0,
        currentProgress: runCount.toDouble(),
        category: ChallengeCategory.runCount,
        reward: 'Flyer Badge',
        icon: '✈️',
      ),
    ];
  }

  static Future<void> syncChallengeProgress(List<Challenge> challenges) async {
    final userId = AuthService.userId;
    if (userId == null) return;

    for (var challenge in challenges) {
      try {
        await _client.from('challenges_progress').upsert({
          'user_id': userId,
          'challenge_id': challenge.id,
          'progress': challenge.currentProgress,
          'is_completed': challenge.isCompleted,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Handle error
      }
    }
  }
}
