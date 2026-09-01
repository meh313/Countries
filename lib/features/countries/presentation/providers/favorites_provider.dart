import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/preferences_providers.dart';

const String _favoritesKey = 'countries.favorites';

/// Persists and exposes the set of favorite country codes.
class FavoritesController extends StateNotifier<Set<String>> {
  /// Creates the controller, restoring persisted favorites when available.
  FavoritesController(this._ref) : super(const <String>{}) {
    final stored =
        _ref.read(sharedPreferencesProvider)?.getStringList(_favoritesKey);
    if (stored != null) {
      state = stored.toSet();
    }
  }

  final Ref _ref;

  /// Adds or removes [countryCode] from the favorites set.
  void toggle(String countryCode) {
    final next = Set<String>.of(state);
    if (!next.remove(countryCode)) {
      next.add(countryCode);
    }
    state = next;
    _ref.read(sharedPreferencesProvider)?.setStringList(
          _favoritesKey,
          next.toList()..sort(),
        );
  }

  /// Whether [countryCode] is currently a favorite.
  bool isFavorite(String countryCode) => state.contains(countryCode);
}

/// Exposes the favorite country codes with persistence.
final favoritesProvider =
    StateNotifierProvider<FavoritesController, Set<String>>((ref) {
  return FavoritesController(ref);
});
