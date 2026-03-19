import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/country.dart';
import '../../domain/repositories/countries_repository.dart';
import '../dtos/country_dto.dart';

/// Reads country data from a bundled JSON asset.
class AssetCountriesRepository implements CountriesRepository {
  /// Creates the repository.
  const AssetCountriesRepository({
    required AssetBundle assetBundle,
    this.assetPath = 'assets/data/countries.json',
  }) : _assetBundle = assetBundle;

  final AssetBundle _assetBundle;
  /// Location of the bundled countries JSON file.
  final String assetPath;

  /// Parses the JSON asset into country entities.
  @override
  Future<List<Country>> getAllCountries() async {
    final jsonString = await _assetBundle.loadString(assetPath);
    final decoded = jsonDecode(jsonString) as List<dynamic>;

    return decoded
        .map((dynamic item) => CountryDto.fromJson(item as Map<String, dynamic>))
        .map((dto) => dto.toDomain())
        .toList(growable: false);
  }

  /// Finds a single country by code from the in-memory asset data.
  @override
  Future<Country?> getCountryByCode(String code) async {
    final countries = await getAllCountries();

    for (final country in countries) {
      if (country.code == code) {
        return country;
      }
    }

    return null;
  }
}
