import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_settings.dart';
import 'supabase_service.dart';
import 'auth_service.dart';
import 'reminder_engine.dart';

class SettingsService {
  static String get _userSettingsKey {
    final userId = AuthService.userId;
    return userId != null ? 'app_settings_$userId' : 'app_settings_guest';
  }

  static final SupabaseClient _client = SupabaseService.client;

  static Future<void> saveSettings(AppSettings settings) async {
    // 1. Save Locally
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await prefs.setString(_userSettingsKey, jsonString);

    // 2. Refresh Reminders
    ReminderEngine.refreshAllReminders();

    // 3. Save to Cloud
    final userId = AuthService.userId;
    if (userId != null) {
      try {
        await _client.from('user_settings').upsert({
          'user_id': userId,
          'is_metric': settings.isMetric,
          'auto_follow_map': settings.autoFollowMap,
          'notifications_enabled': settings.notificationsEnabled,
          'is_dark_mode': settings.isDarkMode,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Handle error
      }
    }
  }

  static Future<AppSettings> getSettings() async {
    final userId = AuthService.userId;

    // 1. Local Fallback First (For instant UX)
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userSettingsKey);

    AppSettings localSettings = AppSettings();

    if (jsonString != null) {
      localSettings = AppSettings.fromJson(jsonDecode(jsonString));
    }

    // 2. Trigger background sync
    if (userId != null) {
      _syncFromCloud(userId, prefs);
    }

    return localSettings;
  }

  static Future<void> _syncFromCloud(String userId, SharedPreferences prefs) async {
    try {
      final response = await _client
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .single();
      
      final cloudSettings = AppSettings(
        isMetric: response['is_metric'] ?? true,
        autoFollowMap: response['auto_follow_map'] ?? true,
        notificationsEnabled: response['notifications_enabled'] ?? true,
        isDarkMode: response['is_dark_mode'] ?? true,
      );
      
      // Update local cache
      await prefs.setString(_userSettingsKey, jsonEncode(cloudSettings.toJson()));
    } catch (e) {
      // Keep local on error
    }
  }
}
