import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'profile_service.dart';
import 'run_storage_service.dart';
import 'onboarding_service.dart';

class AuthService {
  static final SupabaseClient _client = SupabaseService.client;

  static Future<bool> isLoggedIn() async {
    return _client.auth.currentSession != null;
  }

  static Future<void> login(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signup(String name, String email, String password) async {
    final AuthResponse res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );

    if (res.user != null) {
      // Initialize cloud profile foundation
      await _initializeCloudProfile(res.user!.id, name);
    }
  }

  static Future<void> _initializeCloudProfile(String userId, String name) async {
    try {
      await _client.from('profiles').upsert({
        'id': userId,
        'full_name': name,
        'level': 1,
        'xp': 0,
        'total_distance': 0.0,
        'total_calories': 0.0,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Fail silently for now
    }
  }

  static Future<void> logout() async {
    final userId = _client.auth.currentUser?.id;
    await _client.auth.signOut();
    
    // Clear profile cache immediately
    ProfileService.clearCache();
    // Also clear runs cache
    RunStorageService.clearCache();

    // Reset onboarding for security/determinism
    await OnboardingService.resetOnboarding();
    
    if (userId != null) {
      // CRITICAL: Clear ONLY user-specific local caches on logout
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('run_history_$userId');
      await prefs.remove('total_xp_points_$userId');
      await prefs.remove('user_profile_$userId');
      await prefs.remove('goal_data_$userId');
      await prefs.remove('app_settings_$userId');
      await prefs.remove('training_plan_$userId');
    }
  }
  
  static Future<String?> getUserName() async {
    final user = _client.auth.currentUser;
    return user?.userMetadata?['full_name'] as String?;
  }

  static String? get userEmail => _client.auth.currentUser?.email;

  static String? get userId => _client.auth.currentUser?.id;

  static bool get isAuthenticated => _client.auth.currentSession != null;
}
