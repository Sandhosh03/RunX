import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/xp_data.dart';
import '../models/run_session.dart';
import 'streak_service.dart';
import 'run_storage_service.dart';
import 'profile_service.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class XpService {
  static String get _userTotalXpKey {
    final userId = AuthService.userId;
    return userId != null ? 'total_xp_points_$userId' : 'total_xp_points_guest';
  }

  static final SupabaseClient _client = SupabaseService.client;

  static Future<int> getTotalXp() async {
    final userId = AuthService.userId;

    // 1. Try Cloud First
    if (userId != null) {
      try {
        final response = await _client
            .from('xp_progress')
            .select('total_xp')
            .eq('user_id', userId)
            .single();
        
        final cloudXp = response['total_xp'] as int;
        
        // Update local cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_userTotalXpKey, cloudXp);
        
        return cloudXp;
      } catch (e) {
        // Fallback
      }
    }

    // 2. Local Fallback
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userTotalXpKey) ?? 0;
  }

  static Future<XpData> getXpData() async {
    final totalXp = await getTotalXp();
    return XpData.calculate(totalXp);
  }

  static Future<Map<String, dynamic>> addRunXp(RunSession session) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Base XP from distance: 100 XP per KM
    double distanceXp = session.distance * 100;
    
    // 2. Base XP from calories: 1 XP per 2 calories
    double calorieXp = session.calories * 0.5;
    
    // 3. Streak Bonus
    final runs = await RunStorageService.getRuns();
    final streakData = StreakService.calculateStreak(runs);
    double streakMultiplier = 1.0 + (streakData.currentStreak * 0.05); // 5% bonus per streak day
    
    // Max multiplier cap at 2.0 (100% bonus)
    if (streakMultiplier > 2.0) streakMultiplier = 2.0;
    
    int baseXp = (distanceXp + calorieXp).round();
    int earnedXp = (baseXp * streakMultiplier).round();
    
    int currentTotalXp = await getTotalXp();
    XpData oldData = XpData.calculate(currentTotalXp);
    
    int newTotalXp = currentTotalXp + earnedXp;

    // Save Locally
    await prefs.setInt(_userTotalXpKey, newTotalXp);
    
    // Save to Cloud
    final userId = AuthService.userId;
    if (userId != null) {
      try {
        await _client.from('xp_progress').upsert({
          'user_id': userId,
          'total_xp': newTotalXp,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Handle cloud save error
      }
    }
    
    XpData newData = XpData.calculate(newTotalXp);
    bool leveledUp = newData.level > oldData.level;
    
    // Sync with UserProfile for compatibility
    final profile = await ProfileService.getProfile();
    if (profile != null) {
      final updatedProfile = profile.copyWith(
        xp: newData.currentXp,
        level: newData.level,
      );
      await ProfileService.saveProfile(updatedProfile);
    }
    
    return {
      'earnedXp': earnedXp,
      'leveledUp': leveledUp,
      'newLevel': newData.level,
      'xpData': newData,
    };
  }
}


