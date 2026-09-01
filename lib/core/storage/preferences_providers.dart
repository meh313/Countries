import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the [SharedPreferences] instance loaded during app bootstrap.
///
/// Overridden in `main.dart` once the instance is available; stays `null`
/// in tests so state simply lives in memory.
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);
