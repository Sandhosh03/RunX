import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/training_plan.dart';
import 'auth_service.dart';
import '../models/run_session.dart';
import 'supabase_service.dart';
import 'reminder_engine.dart';

export 'plan_recommendation_engine.dart';
export 'plan_progress_tracker.dart';

class TrainingPlanService {
  static String get _storageKey {
    final userId = AuthService.userId;
    return userId != null ? 'training_plan_$userId' : 'training_plan_guest';
  }

  static Future<TrainingPlan?> getActivePlan() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Try Local Cache
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      return TrainingPlan.fromJson(jsonDecode(jsonStr));
    }
    
    // 2. Try Cloud Fallback
    final userId = AuthService.userId;
    if (userId != null) {
      try {
        final response = await SupabaseService.client
            .from('training_plans')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        
        if (response != null && response['data'] != null) {
          final plan = TrainingPlan.fromJson(response['data']);
          // Cache locally
          await prefs.setString(_storageKey, jsonEncode(plan.toJson()));
          return plan;
        }
      } catch (e) {
        debugPrint('Cloud fetch failed: $e');
      }
    }
    
    return null;
  }

  static Future<void> savePlan(TrainingPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Local Persist
    await prefs.setString(_storageKey, jsonEncode(plan.toJson()));
    
    // 2. Cloud Sync
    await _syncToCloud(plan);
    
    // 3. Notification Hooks
    ReminderEngine.refreshAllReminders();
  }

  static Future<void> clearPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    
    // Clear from cloud too
    final userId = AuthService.userId;
    if (userId != null) {
      try {
        await SupabaseService.client
            .from('training_plans')
            .delete()
            .eq('user_id', userId);
      } catch (e) {
        debugPrint('Cloud clear failed: $e');
      }
    }
    
    ReminderEngine.refreshAllReminders();
  }

  static Future<void> markSessionComplete(String sessionId) async {
    final plan = await getActivePlan();
    if (plan == null) return;

    final newSchedule = plan.schedule.map((s) {
      if (s.id == sessionId) {
        return s.copyWith(isCompleted: true);
      }
      return s;
    }).toList();

    final newPlan = TrainingPlan(
      id: plan.id,
      name: plan.name,
      description: plan.description,
      type: plan.type,
      totalWeeks: plan.totalWeeks,
      schedule: newSchedule,
      startDate: plan.startDate,
    );

    await savePlan(newPlan);
  }

  static Future<void> checkAndCompleteTodaySession(RunSession run) async {
    final plan = await getActivePlan();
    if (plan == null) return;

    final todaySession = plan.getTodaySession();
    if (todaySession == null || todaySession.isCompleted || todaySession.type == SessionType.rest) {
      return;
    }

    bool meetsCriteria = false;
    
    if (todaySession.targetDistanceKm > 0) {
      if (run.distance >= todaySession.targetDistanceKm * 0.5) {
        meetsCriteria = true;
      }
    } else if (todaySession.targetDurationMinutes > 0) {
      if (run.duration >= (todaySession.targetDurationMinutes * 60) * 0.5) {
        meetsCriteria = true;
      }
    }

    if (meetsCriteria) {
      await markSessionComplete(todaySession.id);
    }
  }

  static Future<void> _syncToCloud(TrainingPlan plan) async {
    final userId = AuthService.userId;
    if (userId == null) return;
    
    try {
      await SupabaseService.client.from('training_plans').upsert({
        'user_id': userId,
        'plan_id': plan.id,
        'data': plan.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Cloud sync failed: $e. Note: Ensure training_plans table exists in Supabase.');
    }
  }
}
