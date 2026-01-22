import 'package:flutter/material.dart';

/// 🌿 Forest Reading — Light Mode Colors
class AppColors {
  // Core palette
  static const Color primary = Color(0xFF386641);     // Deep Fern Green (Solid, readable)
  static const Color secondary = Color(0xFFA3B18A);   // Sage
  
  // Backgrounds
  static const Color background = Color(0xFFEBE9E1);  // "Old Paper" / Warm Sand
  static const Color card = Color(0xFFFDFBF7);        // "Rice Paper" (Not harsh white)
  
  // Accent
  static const Color accent = Color(0xFFBC6C25);      // Earthy Bronze / Tiger Lily

  // Text
  static const Color textPrimary = Color(0xFF1F2421); // Charcoal Green (Softer than black)
  static const Color textMuted = Color(0xFF606C5D);   // Muted Moss
}

/// 🌙 Forest Reading — Dark Mode Colors
class AppDarkColors {
  // Brighter primary for contrast
  static const Color primary = Color(0xFF81B29A);     // Soft Eucalyptus
  static const Color secondary = Color(0xFF588157);   // Muted Green
  
  // Deep Slate Backgrounds
  static const Color background = Color(0xFF262B2B);  // Deep Twilight Slate
  static const Color card = Color(0xFF353E3C);        // Elevated Slate Green
  
  // Golden/Amber accent
  static const Color accent = Color(0xFFDDA15E);      // Muted Gold / Buff

  static const Color textPrimary = Color(0xFFEAE0D5); // Almond / Bone White
  static const Color textMuted = Color(0xFFAAB3AB);   // Silver Sage
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
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.primary),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: AppColors.textPrimary, fontSize: 16),
      bodySmall: TextStyle(color: AppColors.textMuted),
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColors.primary.withOpacity(0.05), width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    iconTheme: const IconThemeData(color: AppColors.primary),
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
      surface: AppDarkColors.card,
      onSurface: AppDarkColors.textPrimary,
      brightness: Brightness.dark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppDarkColors.background,
      foregroundColor: AppDarkColors.textPrimary,
      elevation: 0,
      iconTheme: IconThemeData(color: AppDarkColors.primary),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppDarkColors.primary, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: AppDarkColors.textPrimary, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: AppDarkColors.textPrimary, fontSize: 16),
      bodySmall: TextStyle(color: AppDarkColors.textMuted),
    ),

    cardTheme: const CardThemeData(
      color: AppDarkColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppDarkColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppDarkColors.primary.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppDarkColors.primary.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppDarkColors.primary, width: 1.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppDarkColors.primary,
        foregroundColor: AppDarkColors.background,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    iconTheme: const IconThemeData(color: AppDarkColors.primary),
  );
}