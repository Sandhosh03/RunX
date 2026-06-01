import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/run_session.dart';
import '../models/run_point.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

import 'feed_service.dart';
import 'training_plan_service.dart';
import 'reminder_engine.dart';

class RunStorageService {
  static String get _userStorageKey {
    final userId = AuthService.userId;
    return userId != null ? 'run_history_$userId' : 'run_history_guest';
  }

  static final SupabaseClient _client = SupabaseService.client;

  static List<RunSession> _parseRuns(List<String> storedRuns) {
    return storedRuns.map((run) {
      return RunSession.fromJson(jsonDecode(run));
    }).toList().reversed.toList();
  }

  static Future<void> saveRun(RunSession session) async {
    // 1. Save Locally
    final prefs = await SharedPreferences.getInstance();
    final existingRuns = prefs.getStringList(_userStorageKey) ?? [];
    existingRuns.add(jsonEncode(session.toJson()));
    await prefs.setStringList(_userStorageKey, existingRuns);

    // 2. Training Plan Integration
    await TrainingPlanService.checkAndCompleteTodaySession(session);
    
    // 3. Notification Refresh
    ReminderEngine.refreshAllReminders();

    // 4. Save to Cloud
    final userId = AuthService.userId;
    if (userId != null) {
      try {
        await _client.from('runs').insert({
          'user_id': userId,
          'distance': session.distance,
          'calories': session.calories,
          'duration': session.duration,
          'average_pace': session.averagePace,
          'route_points': session.route?.map((p) => p.toJson()).toList(),
          'elevation_gain': session.elevationGain,
          'elevation_loss': session.elevationLoss,
          'date': session.date,
        });
        // 3. Post to Activity Feed
        await FeedService.postActivity(
          type: 'run',
          data: {
            'distance': session.distance.toStringAsFixed(2),
            'duration': (session.duration / 60).toStringAsFixed(1),
            'calories': session.calories.toStringAsFixed(0),
          },
        );
      } catch (e) {
        // Log or handle error
      }
    }
    
    // Invalidate cache so next getRuns() fetches the updated list
    _cachedRuns = null;
  }

  static List<RunSession>? _cachedRuns;

  static void clearCache() {
    _cachedRuns = null;
  }

  static Future<List<RunSession>> getRuns({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedRuns != null) {
      return _cachedRuns!;
    }

    final userId = AuthService.userId;
    final prefs = await SharedPreferences.getInstance();

    // 1. Local Fallback First (For instant UX)
    final storedRuns = prefs.getStringList(_userStorageKey) ?? [];
    if (storedRuns.isNotEmpty && !forceRefresh) {
      // Use compute for heavy parsing if the list is potentially large
      if (storedRuns.length > 5) {
        _cachedRuns = await compute(_parseRuns, storedRuns);
      } else {
        _cachedRuns = _parseRuns(storedRuns);
      }
      
      // Trigger background sync
      _syncFromCloud(userId, prefs);
      return _cachedRuns!;
    }

    // 2. If no local or forced refresh, await cloud
    if (userId != null) {
      await _syncFromCloud(userId, prefs);
      return _cachedRuns ?? [];
    }

    return [];
  }

  static Future<void> _syncFromCloud(String? userId, SharedPreferences prefs) async {
    if (userId == null) return;
    try {
      final List<dynamic> response = await _client
          .from('runs')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);
      
      final cloudRuns = response.map((run) => RunSession(
        distance: (run['distance'] as num).toDouble(),
        calories: (run['calories'] as num).toDouble(),
        duration: (run['duration'] as num).toInt(),
        date: run['date'] as String,
        averagePace: (run['average_pace'] as num?)?.toDouble(),
        route: (run['route_points'] as List?)?.map((p) => RunPoint.fromJson(Map<String, dynamic>.from(p as Map))).toList(),
        elevationGain: (run['elevation_gain'] as num?)?.toDouble() ?? 0.0,
        elevationLoss: (run['elevation_loss'] as num?)?.toDouble() ?? 0.0,
      )).toList();
      
      // Update local cache
      _cachedRuns = cloudRuns;
      final List<String> encodedRuns = cloudRuns.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_userStorageKey, encodedRuns.reversed.toList());
    } catch (e) {
      // Keep existing cache on error
    }
  }
}