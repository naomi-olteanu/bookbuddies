import 'package:flutter/material.dart';

/// 🌿 Forest Reading — Light Mode Colors
class AppColors {
  // Core palette
  static const Color primary = Color(0xFF2F5D50);     // Forest Green
  static const Color secondary = Color(0xFFA3B18A);   // Sage
  static const Color background = Color(0xFFF5F3E7);  // Warm Beige
  static const Color card = Color(0xFFFFFFFF);        // White
  static const Color accent = Color(0xFF8B5E34);      // Brown (Wood)

  // Text
  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textMuted = Color(0xFF6B705C);
}

/// 🌙 Forest Reading — Dark Mode Colors
class AppDarkColors {
  static const Color primary = Color(0xFF3A7D6C);     // Muted Forest Green
  static const Color secondary = Color(0xFF7FA38D);   // Sage Green
  static const Color background = Color(0xFF1E2623);  // Dark Moss
  static const Color card = Color(0xFF27312D);        // Deep Olive
  static const Color accent = Color(0xFFB08968);      // Warm Brown

  static const Color textPrimary = Color(0xFFEAEAEA); // Soft White
  static const Color textMuted = Color(0xFFB7C1BC);   // Muted Gray-Green
}

class AppTheme {
  /// ☀️ LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.background,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.card,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      bodySmall: TextStyle(
        color: AppColors.textMuted,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
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

    iconTheme: const IconThemeData(
      color: AppColors.primary,
    ),
  );

  /// 🌙 DARK THEME
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppDarkColors.background,
    primaryColor: AppDarkColors.primary,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppDarkColors.primary,
      primary: AppDarkColors.primary,
      secondary: AppDarkColors.accent,
      surface: AppDarkColors.background,
      brightness: Brightness.dark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppDarkColors.card,
      foregroundColor: AppDarkColors.textPrimary,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppDarkColors.textPrimary,
        fontSize: 16,
      ),
      bodySmall: TextStyle(
        color: AppDarkColors.textMuted,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppDarkColors.card,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppDarkColors.accent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    iconTheme: const IconThemeData(
      color: AppDarkColors.secondary,
    ),
  );
}
