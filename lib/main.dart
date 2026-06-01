import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/splash_screen.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';
import 'services/reminder_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Services
  await NotificationService.init();
  final supabaseInit = SupabaseService.initialize();
  
  // Refresh reminders on start
  ReminderEngine.refreshAllReminders();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: RunXApp(supabaseInit: supabaseInit),
    ),
  );
}

class RunXApp extends StatelessWidget {
  final Future<void> supabaseInit;
  const RunXApp({super.key, required this.supabaseInit});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'RunX',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: SplashScreen(supabaseInit: supabaseInit),
        );
      },
    );
  }
}