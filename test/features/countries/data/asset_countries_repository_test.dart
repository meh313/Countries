import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:countries_app/features/countries/data/dtos/country_dto.dart';
import 'package:countries_app/features/countries/data/repositories/asset_countries_repository.dart';

/// In-memory asset bundle used by repository tests.
class TestAssetBundle extends CachingAssetBundle {
  /// Creates the fake bundle.
  TestAssetBundle(this._payload);

  final String _payload;

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError('Binary loading is not needed for this test.');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return _payload;
  }
}

void main() {
  group('CountryDto', () {
    test('maps JSON into a domain entity with capitals preserved', () {
      final dto = CountryDto.fromJson(<String, dynamic>{
        'code': 'MA',
        'name': 'Morocco',
        'capital': 'Rabat',
        'flagAssetOrUrl': 'https://flagcdn.com/w320/ma.png',
        'latitude': 34.0209,
        'longitude': -6.8416,
        'region': 'Africa',
      });

      final country = dto.toDomain();

      expect(country.code, 'MA');
      expect(country.capital, 'Rabat');
      expect(country.region, 'Africa');
    });
  });

  group('AssetCountriesRepository', () {
    const payload = '''
[
  {
    "code": "FR",
    "name": "France",
    "capital": "Paris",
    "flagAssetOrUrl": "https://flagcdn.com/w320/fr.png",
    "latitude": 48.8566,
    "longitude": 2.3522,
    "region": "Europe"
  },
  {
    "code": "JP",
    "name": "Japan",
    "capital": "Tokyo",
    "flagAssetOrUrl": "https://flagcdn.com/w320/jp.png",
    "latitude": 35.6762,
    "longitude": 139.6503,
    "region": "Asia"
  }
]
''';

    test('loads all countries from the asset bundle', () async {
      final repository = AssetCountriesRepository(
        assetBundle: TestAssetBundle(payload),
      );

      final countries = await repository.getAllCountries();

      expect(countries, hasLength(2));
      expect(countries.first.name, 'France');
      expect(countries.last.capital, 'Tokyo');
    });

    test('returns one country by code', () async {
      final repository = AssetCountriesRepository(
        assetBundle: TestAssetBundle(payload),
      );

      final country = await repository.getCountryByCode('JP');

      expect(country, isNotNull);
      expect(country!.name, 'Japan');
      expect(country.capital, 'Tokyo');
    });
  });
}
