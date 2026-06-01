import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Placeholders for environment variables
  static const String _supabaseUrl = 'https://dcjmookjdwsdfvrmymka.supabase.co';
  static const String _supabaseAnonKey = 'sb_publishable_tTKz9cYk8_j_bVpOpX0pxg_qgGT3Yza';

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );
    } catch (e) {
      // If placeholders are not replaced, Supabase initialization will fail.
      // We catch the error to ensure the app still runs in offline-first mode.
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Foundation for future Auth features
  static bool get hasActiveSession => Supabase.instance.client.auth.currentSession != null;
  static User? get currentUser => Supabase.instance.client.auth.currentUser;
}
