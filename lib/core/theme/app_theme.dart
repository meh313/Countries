import 'package:flutter/material.dart';

/// Application-wide visual theme configuration.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF0F4C5C);
  static const Color _accent = Color(0xFFE36414);

  /// Builds the light theme used across the app.
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      primary: _seed,
      secondary: _accent,
      surface: Colors.white,
    );

    return _base(colorScheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFFF7F4EA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F4EA),
        foregroundColor: _seed,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _seed,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: _inputTheme(fillColor: Colors.white),
    );
  }

  /// Builds the dark theme used across the app.
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
      secondary: _accent,
    );

    return _base(colorScheme).copyWith(
      scaffoldBackgroundColor: const Color(0xFF0E1518),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0E1518),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1A2529),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: _inputTheme(fillColor: const Color(0xFF1A2529)),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: Color(0xFF141D21),
      ),
    );
  }

  static ThemeData _base(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      splashFactory: InkSparkle.splashFactory,
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static InputDecorationTheme _inputTheme({required Color fillColor}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
