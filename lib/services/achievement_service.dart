import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/achievement.dart';
import '../models/run_session.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

import 'feed_service.dart';

class AchievementService {
  static final SupabaseClient _client = SupabaseService.client;

  static List<Achievement> generateAchievements(
    List<RunSession> runs,
  ) {
    double totalDistance = 0;

    double totalCalories = 0;

    for (var run in runs) {
      totalDistance += run.distance;

      totalCalories += run.calories;
    }

    return [
      Achievement(
        title: 'First Run',
        description: 'Complete your first run',
        unlocked: runs.isNotEmpty,
        icon: '🏃',
      ),
      Achievement(
        title: '5 Runs',
        description: 'Complete 5 total runs',
        unlocked: runs.length >= 5,
        icon: '🔥',
      ),
      Achievement(
        title: '10 KM Club',
        description: 'Reach 10 KM total distance',
        unlocked: totalDistance >= 10,
        icon: '📍',
      ),
      Achievement(
        title: '100 KM Legend',
        description: 'Reach 100 KM total distance',
        unlocked: totalDistance >= 100,
        icon: '⚡',
      ),
      Achievement(
        title: '1000 Calories Burned',
        description: 'Burn 1000 calories',
        unlocked: totalCalories >= 1000,
        icon: '💪',
      ),
    ];
  }

  static Future<void> syncAchievements(List<Achievement> achievements) async {
    final userId = AuthService.userId;
    if (userId == null) return;

    final unlocked = achievements.where((a) => a.unlocked).toList();
    
    for (var achievement in unlocked) {
      try {
        await _client.from('achievements').upsert({
          'user_id': userId,
          'achievement_title': achievement.title,
          'unlocked_at': DateTime.now().toIso8601String(),
        });
        // Post to activity feed
        await FeedService.postActivity(
          type: 'achievement',
          data: {'title': achievement.title},
        );
      } catch (e) {
        // Handle error
      }
    }
  }
}