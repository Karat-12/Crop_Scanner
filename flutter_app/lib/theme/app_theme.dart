import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4CAF50); // Green
  static const Color secondary = Color(0xFF8BC34A);
  static const Color background = Color(0xFF121212); // Dark background
  static const Color cardBackground = Color(0xFF1E1E1E); // Darker cards
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color accent = Color(0xFF69F0AE); // Light green accent
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      cardColor: AppColors.cardBackground,
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        labelLarge: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ), // for buttons
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: AppColors.accent,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
