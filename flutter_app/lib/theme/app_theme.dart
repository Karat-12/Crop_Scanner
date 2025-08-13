import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1ABC9C); // Vibrant teal
  static const Color secondary = Color(0xFF16A085); // Slightly darker teal
  static const Color background = Color(0xFF121212); // Dark background
  static const Color cardBackground = Color(0xFF1E1E2F); // Darker cards
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5); // Soft gray
  static const Color accent = Color(0xFFF1C40F); // Warm accent (lime/orange)
  static const Color healthy = Color(0xFF2ECC71); // Green for Healthy
  static const Color diseased = Color(0xFFE74C3C); // Red for Diseased
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
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
