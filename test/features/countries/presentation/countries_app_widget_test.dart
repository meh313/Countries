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
  final countries = <Country>[
    const Country(
      code: 'MA',
      name: 'Morocco',
      capital: 'Rabat',
      flagAssetOrUrl: 'assets/flags/ma.png',
      latitude: 34.0209,
      longitude: -6.8416,
      region: 'Africa',
    ),
    const Country(
      code: 'FR',
      name: 'France',
      capital: 'Paris',
      flagAssetOrUrl: 'assets/flags/fr.png',
      latitude: 48.8566,
      longitude: 2.3522,
      region: 'Europe',
    ),
    ...List<Country>.generate(24, (index) {
      final id = index + 1;
      final region = switch (id % 4) {
        0 => 'Europe',
        1 => 'Africa',
        2 => 'Asia',
        _ => 'Americas',
      };

      return Country(
        code: 'C$id',
        name: 'Zed Country $id',
        capital: 'Capital $id',
        flagAssetOrUrl: 'assets/flags/c$id.png',
        latitude: 10 + id.toDouble(),
        longitude: 20 + id.toDouble(),
        region: region,
      );
    }),
  ];

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        countriesRepositoryProvider.overrideWithValue(
          FakeCountriesRepository(countries),
        ),
      ],
      child: const CountriesApp(),
    );
  }

  testWidgets('renders the seeded countries list', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Countries'), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-start-button')), findsOneWidget);
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

  testWidgets('opens the details screen when a country is tapped',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Morocco'));
    await tester.pumpAndSettle();

    expect(find.text('Capital: Rabat'), findsOneWidget);
    expect(find.byType(CountryMap), findsOneWidget);
    expect(find.byKey(const ValueKey('country-map-marker-MA')), findsOneWidget);
    expect(find.textContaining('34.0209'), findsOneWidget);
  });

  testWidgets('opens quiz types from start button and launches quick quiz', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('bottom-start-button')));
    await tester.pumpAndSettle();

    expect(find.text('Choose Quiz Type'), findsOneWidget);
    expect(find.text('Quick Quiz (MCQ)'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quiz-type-quick')));
    await tester.pumpAndSettle();

    expect(find.text('Quick Quiz (MCQ)'), findsWidgets);
    expect(find.textContaining('Question 1/15'), findsOneWidget);
    expect(find.byKey(const ValueKey('quick-quiz-option-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-start-button')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('quick-quiz-option-0')));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('quick-quiz-feedback-text')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('quick-quiz-view-map-button')),
      findsOneWidget,
    );
    expect(
        find.byKey(const ValueKey('quick-quiz-next-button')), findsOneWidget);
  });

  testWidgets('opens country map from quick quiz answer feedback',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final router = container.read(appRouterProvider);
    router.go('/quiz/quick');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('quick-quiz-option-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-quiz-view-map-button')));
    await tester.pumpAndSettle();

    expect(find.byType(CountryMap), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Quick Quiz (MCQ)'), findsWidgets);
    expect(
        find.byKey(const ValueKey('quick-quiz-next-button')), findsOneWidget);
  });

  testWidgets('completes the 15-question quick quiz and shows final result', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final router = container.read(appRouterProvider);
    router.go('/quiz/quick');
    await tester.pumpAndSettle();

    for (var i = 0; i < 15; i += 1) {
      await tester.tap(find.byKey(const ValueKey('quick-quiz-option-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('quick-quiz-next-button')));
      await tester.pumpAndSettle();
    }

    expect(
        find.byKey(const ValueKey('quick-quiz-result-score')), findsOneWidget);
    expect(find.byKey(const ValueKey('quick-quiz-restart-button')),
        findsOneWidget);
  });
}
