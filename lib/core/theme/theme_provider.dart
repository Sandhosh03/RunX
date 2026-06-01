import 'package:flutter/material.dart';
import '../../services/settings_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    final settings = await SettingsService.getSettings();
    _themeMode = settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    
    final settings = await SettingsService.getSettings();
    await SettingsService.saveSettings(settings.copyWith(isDarkMode: isDark));
  }
}
