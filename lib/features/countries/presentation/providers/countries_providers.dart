import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/asset_countries_repository.dart';
import '../../domain/entities/country.dart';
import '../../domain/repositories/countries_repository.dart';
import '../../domain/usecases/get_all_countries.dart';
import '../../domain/usecases/get_country_by_code.dart';
import 'favorites_provider.dart';

/// Provides the countries repository implementation.
final countriesRepositoryProvider = Provider<CountriesRepository>((ref) {
  return AssetCountriesRepository(assetBundle: rootBundle);
});

/// Provides the use case for reading all countries.
final getAllCountriesProvider = Provider<GetAllCountries>((ref) {
  final repository = ref.watch(countriesRepositoryProvider);
  return GetAllCountries(repository);
});

/// Provides the use case for reading a single country.
final getCountryByCodeProvider = Provider<GetCountryByCode>((ref) {
  final repository = ref.watch(countriesRepositoryProvider);
  return GetCountryByCode(repository);
});

/// Loads the full countries catalog.
final countriesProvider = FutureProvider<List<Country>>((ref) async {
  final getAllCountries = ref.watch(getAllCountriesProvider);
  final countries = List<Country>.of(await getAllCountries());
  countries.sort(
    (left, right) => _sortKey(left.name).compareTo(_sortKey(right.name)),
  );
  return countries;
});

const _accented = 'àáâãäåçèéêëìíîïñòóôõöùúûü';
const _unaccented = 'aaaaaaceeeeiiiinooooouuuu';

String _sortKey(String name) {
  final lower = name.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final index = _accented.indexOf(char);
    buffer.write(index >= 0 ? _unaccented[index] : char);
  }
  return buffer.toString();
}

/// Stores the user-entered country name filter.
final countrySearchQueryProvider = StateProvider<String>((ref) => '');

/// Stores the active region filter, or `null` for all regions.
final regionFilterProvider = StateProvider<String?>((ref) => null);

/// Whether the list is restricted to favorite countries only.
final favoritesOnlyProvider = StateProvider<bool>((ref) => false);

/// Distinct region labels available in the catalog, sorted alphabetically.
final regionsProvider = Provider<List<String>>((ref) {
  final countriesValue = ref.watch(countriesProvider);

  return countriesValue.maybeWhen(
    data: (countries) {
      final regions = <String>{
        for (final country in countries)
          if (country.region != null) country.region!,
      }.toList()
        ..sort();
      return regions;
    },
    orElse: () => const <String>[],
  );
});

/// Filters the loaded countries by search query, region, and favorites.
final filteredCountriesProvider = Provider<AsyncValue<List<Country>>>((ref) {
  final countriesValue = ref.watch(countriesProvider);
  final query = ref.watch(countrySearchQueryProvider).trim().toLowerCase();
  final region = ref.watch(regionFilterProvider);
  final favoritesOnly = ref.watch(favoritesOnlyProvider);
  final favorites = ref.watch(favoritesProvider);

  return countriesValue.whenData((countries) {
    return countries.where((country) {
      if (region != null && country.region != region) {
        return false;
      }
      if (favoritesOnly && !favorites.contains(country.code)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return country.name.toLowerCase().contains(query) ||
          country.capital.toLowerCase().contains(query);
    }).toList(growable: false);
  });
});

/// Loads a single country by code.
final countryByCodeProvider =
    FutureProvider.family<Country?, String>((ref, code) async {
  final getCountryByCode = ref.watch(getCountryByCodeProvider);
  return getCountryByCode(code);
});
