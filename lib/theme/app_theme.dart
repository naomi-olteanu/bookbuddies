import 'package:flutter/material.dart';

class AppColors {
  // 🎨 Palette 1 – Warm Library
  static const Color primary = Color(0xFF4B3F72);     // Deep Indigo
  static const Color secondary = Color(0xFFCDB4DB);   // Soft Lavender
  static const Color background = Color(0xFFF6F7FB);  // Light Gray
  static const Color card = Color(0xFFFFFFFF);        // White
  static const Color accent = Color(0xFFE07A5F);      // Warm Coral

  static const Color textPrimary = Color(0xFF1F2937); // Dark Gray
  static const Color textMuted = Color(0xFF6B7280);   // Muted Gray
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      background: AppColors.background,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.card,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textMuted),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
