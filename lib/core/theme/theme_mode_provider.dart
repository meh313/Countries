import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/preferences_providers.dart';

const String _themeModeKey = 'settings.themeMode';

/// Persists and exposes the user-selected theme mode.
class ThemeModeController extends StateNotifier<ThemeMode> {
  /// Creates the controller, restoring any previously saved mode.
  ThemeModeController(this._ref) : super(ThemeMode.system) {
    final stored = _ref.read(sharedPreferencesProvider)?.getString(
          _themeModeKey,
        );
    state = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  final Ref _ref;

  /// Cycles between light and dark mode.
  void toggle(Brightness currentBrightness) {
    final next = currentBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    state = next;
    _ref.read(sharedPreferencesProvider)?.setString(
          _themeModeKey,
          next == ThemeMode.dark ? 'dark' : 'light',
        );
  }
}

/// Exposes the active [ThemeMode] with persistence.
final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(ref);
});
