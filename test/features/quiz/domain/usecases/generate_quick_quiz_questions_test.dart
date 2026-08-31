import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:countries_app/features/countries/domain/entities/country.dart';
import 'package:countries_app/features/countries/domain/repositories/countries_repository.dart';
import 'package:countries_app/features/countries/domain/usecases/get_all_countries.dart';
import 'package:countries_app/features/quiz/domain/usecases/generate_quick_quiz_questions.dart';

class _FakeCountriesRepository implements CountriesRepository {
  const _FakeCountriesRepository(this._countries);

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
  final countries = List<Country>.generate(30, (index) {
    final id = index + 1;
    final region = switch (id % 3) {
      0 => 'Europe',
      1 => 'Africa',
      _ => 'Asia',
    };

    return Country(
      code: 'C$id',
      name: 'Country $id',
      capital: 'Capital $id',
      flagAssetOrUrl: 'assets/flags/c$id.png',
      latitude: id.toDouble(),
      longitude: id.toDouble(),
      region: region,
    );
  });

  GenerateQuickQuizQuestions buildUseCase() {
    final repository = _FakeCountriesRepository(countries);
    return GenerateQuickQuizQuestions(
      GetAllCountries(repository),
      random: Random(9),
    );
  }

  test('returns 15 unique questions with 5 options each', () async {
    final useCase = buildUseCase();

    final questions = await useCase(questionCount: 15, optionsPerQuestion: 5);

    expect(questions, hasLength(15));
    expect(
      questions.map((question) => question.countryCode).toSet(),
      hasLength(15),
    );

    for (final question in questions) {
      expect(question.options, hasLength(5));
      expect(question.options.toSet(), hasLength(5));
      expect(question.options, contains(question.correctCapital));
    }
  });

  test('prefers region distractors when there are enough same-region capitals',
      () async {
    final useCase = buildUseCase();
    final questions = await useCase(questionCount: 15, optionsPerQuestion: 5);

    final capitalToCountry = {
      for (final country in countries) country.capital: country,
    };

    for (final question in questions) {
      final sourceCountry = countries.firstWhere(
        (country) => country.code == question.countryCode,
      );
      final availableInRegion = countries.where((country) {
        return country.code != sourceCountry.code &&
            country.region == sourceCountry.region &&
            country.capital != sourceCountry.capital;
      }).length;

      final distractors = question.options
          .where((capital) => capital != question.correctCapital)
          .toList(growable: false);

      if (availableInRegion >= 4) {
        final allFromRegion = distractors.every((capital) {
          return capitalToCountry[capital]!.region == sourceCountry.region;
        });
        expect(allFromRegion, isTrue);
      }
    }
  });
}
