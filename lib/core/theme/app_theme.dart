import 'package:flutter/material.dart';

/// Application-wide visual theme configuration.
abstract final class AppTheme {
  /// Builds the light theme used across the app.
  static ThemeData light() {
    const baseColor = Color(0xFF0F4C5C);
    const accentColor = Color(0xFFE36414);
    const surfaceTint = Color(0xFFF7F4EA);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: baseColor,
      primary: baseColor,
      secondary: accentColor,
      surface: Colors.white,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceTint,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceTint,
        foregroundColor: baseColor,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
