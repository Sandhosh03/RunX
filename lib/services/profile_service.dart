import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class ProfileService {
  static String get _userProfileKey {
    final userId = AuthService.userId;
    return userId != null ? 'user_profile_$userId' : 'user_profile_guest';
  }

  static final SupabaseClient _client = SupabaseService.client;
  static UserProfile? _cachedProfile;

  static Future<void> saveProfile(UserProfile profile) async {
    _cachedProfile = profile;
    // 1. Save Locally
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(profile.toJson());
    await prefs.setString(_userProfileKey, jsonString);

    // 2. Save to Cloud (if authenticated)
    final userId = AuthService.userId;
    if (userId != null) {
      try {
        await _client.from('profiles').upsert({
          'id': userId,
          'full_name': profile.name,
          'age': profile.age,
          'gender': profile.gender,
          'weight': profile.weight,
          'height': profile.height,
          'goal': profile.goal,
          'fitness_level': profile.fitnessLevel,
          'level': profile.level,
          'xp': profile.xp,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Handle cloud save error (e.g., offline)
      }
    }
  }

  static void clearCache() {
    _cachedProfile = null;
  }

  static Future<UserProfile?> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedProfile != null) {
      return _cachedProfile;
    }

    final userId = AuthService.userId;

    // 1. Local Fallback First (For instant UX)
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userProfileKey);
    
    if (jsonString != null && !forceRefresh) {
       _cachedProfile = UserProfile.fromJson(jsonDecode(jsonString));
       // Trigger background sync
       _syncFromCloud(userId, prefs);
       return _cachedProfile;
    }

    // 2. If no local or forced refresh, await cloud
    if (userId != null) {
       await _syncFromCloud(userId, prefs);
       return _cachedProfile;
    }
    
    return null;
  }

  static Future<void> _syncFromCloud(String? userId, SharedPreferences prefs) async {
    if (userId == null) return;
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      final cloudProfile = UserProfile(
        name: response['full_name'] ?? '',
        age: response['age'] ?? 0,
        gender: response['gender'] ?? 'Other',
        weight: (response['weight'] as num?)?.toDouble() ?? 0.0,
        height: (response['height'] as num?)?.toDouble() ?? 0.0,
        goal: response['goal'] ?? '',
        fitnessLevel: response['fitness_level'] ?? 'Beginner',
        level: response['level'] ?? 1,
        xp: response['xp'] ?? 0,
      );
      
      _cachedProfile = cloudProfile;
      await prefs.setString(_userProfileKey, jsonEncode(cloudProfile.toJson()));
    } catch (e) {
      // Keep existing cache on error
    }
  }
}

