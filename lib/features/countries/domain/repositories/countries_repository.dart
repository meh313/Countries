import '../entities/country.dart';

/// Contract for reading countries data regardless of its backing source.
abstract class CountriesRepository {
  /// Returns the full list of available countries.
  Future<List<Country>> getAllCountries();

  /// Returns a single country by code, or `null` if no match exists.
  Future<Country?> getCountryByCode(String code);
}
