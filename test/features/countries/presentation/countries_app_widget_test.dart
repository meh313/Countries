import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:countries_app/app.dart';
import 'package:countries_app/core/routing/app_router.dart';
import 'package:countries_app/features/countries/domain/entities/country.dart';
import 'package:countries_app/features/countries/domain/repositories/countries_repository.dart';
import 'package:countries_app/features/countries/presentation/providers/countries_providers.dart';
import 'package:countries_app/features/countries/presentation/widgets/country_map.dart';

class FakeCountriesRepository implements CountriesRepository {
  const FakeCountriesRepository(this._countries);

  final List<Country> _countries;

  @override
  Future<List<Country>> getAllCountries() async => _countries;

  @override
  Future<Country?> getCountryByCode(String code) async {
    for (final country in _countries) {
      if (country.code == code) {
        return country;
      }
    }

    return null;
  }
}

void main() {
  const countries = <Country>[
    Country(
      code: 'MA',
      name: 'Morocco',
      capital: 'Rabat',
      flagAssetOrUrl: 'https://flagcdn.com/w320/ma.png',
      latitude: 34.0209,
      longitude: -6.8416,
      region: 'Africa',
    ),
    Country(
      code: 'FR',
      name: 'France',
      capital: 'Paris',
      flagAssetOrUrl: 'https://flagcdn.com/w320/fr.png',
      latitude: 48.8566,
      longitude: 2.3522,
      region: 'Europe',
    ),
  ];

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        countriesRepositoryProvider.overrideWithValue(
          const FakeCountriesRepository(countries),
        ),
      ],
      child: const CountriesApp(),
    );
  }

  testWidgets('renders the seeded countries list', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Countries'), findsOneWidget);
    expect(find.text('Morocco'), findsOneWidget);
    expect(find.text('France'), findsOneWidget);
    expect(find.text('Capital: Rabat'), findsOneWidget);
  });

  testWidgets('filters the list by search query', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('countries-search-field')),
      'mor',
    );
    await tester.pumpAndSettle();

    expect(find.text('Morocco'), findsOneWidget);
    expect(find.text('France'), findsNothing);
  });

  testWidgets('opens the details screen when a country is tapped', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Morocco'));
    await tester.pumpAndSettle();

    expect(find.text('Capital: Rabat'), findsOneWidget);
    expect(find.byType(CountryMap), findsOneWidget);
    expect(find.byKey(const ValueKey('country-map-marker-MA')), findsOneWidget);
    expect(find.textContaining('34.0209'), findsOneWidget);
  });

  testWidgets('registers the quiz placeholder route', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final router = container.read(appRouterProvider);

    router.go('/quiz');
    await tester.pumpAndSettle();

    expect(find.text('Quiz Mode'), findsOneWidget);
    expect(find.textContaining('Capitals quiz'), findsOneWidget);
  });
}
