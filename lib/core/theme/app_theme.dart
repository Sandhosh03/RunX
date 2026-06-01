import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ),
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      outline: AppColors.outline,
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 32),
      headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 24),
      bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 1.2),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
      ),
    ),
    
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.outline, width: 1),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.outline,
      thickness: 1,
      space: 32,
    ),
  );

  static ThemeData get lightTheme => darkTheme.copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: darkTheme.appBarTheme.copyWith(
      titleTextStyle: darkTheme.appBarTheme.titleTextStyle?.copyWith(color: Colors.black),
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Color(0xFF424242),
      surface: Colors.white,
      onSurface: Colors.black,
      outline: Color(0xFFE0E0E0),
    ),
  );
}
