import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/asset_countries_repository.dart';
import '../../domain/entities/country.dart';
import '../../domain/repositories/countries_repository.dart';
import '../../domain/usecases/get_all_countries.dart';
import '../../domain/usecases/get_country_by_code.dart';

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
  countries.sort((left, right) => left.name.compareTo(right.name));
  return countries;
});

/// Stores the user-entered country name filter.
final countrySearchQueryProvider = StateProvider<String>((ref) => '');

/// Filters the loaded countries according to the current search query.
final filteredCountriesProvider = Provider<AsyncValue<List<Country>>>((ref) {
  final countriesValue = ref.watch(countriesProvider);
  final query = ref.watch(countrySearchQueryProvider).trim().toLowerCase();

  return countriesValue.whenData((countries) {
    if (query.isEmpty) {
      return countries;
    }

    return countries
        .where((country) => country.name.toLowerCase().contains(query))
        .toList(growable: false);
  });
});

/// Loads a single country by code.
final countryByCodeProvider =
    FutureProvider.family<Country?, String>((ref, code) async {
  final getCountryByCode = ref.watch(getCountryByCodeProvider);
  return getCountryByCode(code);
});
