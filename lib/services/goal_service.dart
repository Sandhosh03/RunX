import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/goal_data.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class GoalService {
  static String get _userGoalKey {
    final userId = AuthService.userId;
    return userId != null ? 'goal_data_$userId' : 'goal_data_guest';
  }

  static final SupabaseClient _client = SupabaseService.client;

  static Future<void> saveGoals(GoalData goals) async {
    // 1. Save Locally
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(goals.toJson());
    await prefs.setString(_userGoalKey, jsonString);

    // 2. Save to Cloud
    final userId = AuthService.userId;
    if (userId != null) {
      try {
        await _client.from('goals').upsert({
          'user_id': userId,
          'daily_distance_goal': goals.dailyDistanceGoal,
          'daily_calories_goal': goals.dailyCaloriesGoal,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Handle error
      }
    }
  }

  static Future<GoalData> getGoals() async {
    final userId = AuthService.userId;

    // 1. Local Fallback First (For instant UX)
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userGoalKey);

    GoalData localGoals = GoalData(
      dailyDistanceGoal: 5,
      dailyCaloriesGoal: 500,
    );

    if (jsonString != null) {
      localGoals = GoalData.fromJson(jsonDecode(jsonString));
    }

    // 2. Trigger background sync
    if (userId != null) {
      _syncFromCloud(userId, prefs);
    }

    return localGoals;
  }

  static Future<void> _syncFromCloud(String userId, SharedPreferences prefs) async {
    try {
      final response = await _client
          .from('goals')
          .select()
          .eq('user_id', userId)
          .single();
      
      final cloudGoals = GoalData(
        dailyDistanceGoal: (response['daily_distance_goal'] as num).toDouble(),
        dailyCaloriesGoal: (response['daily_calories_goal'] as num).toDouble(),
      );
      
      // Update local cache
      await prefs.setString(_userGoalKey, jsonEncode(cloudGoals.toJson()));
    } catch (e) {
      // Keep local on error
    }
  }
}
