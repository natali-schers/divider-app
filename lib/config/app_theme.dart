import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Marca
  static const primary = Color(0xFFFF4335);
  static const secondary = Color.fromARGB(255, 255, 223, 221);

  // Semânticas
  static const error = Color(0xFFB00020);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF9A825);

  // Texto
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6E6E6E);

  // Superfícies
  static const background = Color(0xFFFAFAFA);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: colorScheme.surface,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
