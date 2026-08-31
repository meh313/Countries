import 'dart:math';

import '../../../countries/domain/entities/country.dart';
import '../../../countries/domain/usecases/get_all_countries.dart';
import '../entities/quick_quiz_question.dart';

/// Generates quick capitals quiz questions from the countries catalog.
class GenerateQuickQuizQuestions {
  /// Creates the question generator use case.
  GenerateQuickQuizQuestions(
    this._getAllCountries, {
    Random? random,
  }) : _random = random ?? Random();

  final GetAllCountries _getAllCountries;
  final Random _random;

  /// Builds an ordered list of quick-quiz questions.
  Future<List<QuickQuizQuestion>> call({
    int questionCount = 15,
    int optionsPerQuestion = 5,
  }) async {
    final requiredDistractors = optionsPerQuestion - 1;
    if (requiredDistractors <= 0) {
      throw ArgumentError.value(
        optionsPerQuestion,
        'optionsPerQuestion',
        'Must be greater than 1.',
      );
    }

    final allCountries = await _getAllCountries();
    final eligibleCountries = allCountries
        .where((country) => country.capital.trim().isNotEmpty)
        .toList(growable: false);

    if (eligibleCountries.length < questionCount) {
      throw StateError(
        'Not enough countries to build $questionCount quiz questions.',
      );
    }

    final selectedCountries = List<Country>.of(eligibleCountries)
      ..shuffle(_random);

    return selectedCountries
        .take(questionCount)
        .map(
          (country) => _toQuestion(
            country: country,
            allCountries: eligibleCountries,
            requiredDistractors: requiredDistractors,
          ),
        )
        .toList(growable: false);
  }

  QuickQuizQuestion _toQuestion({
    required Country country,
    required List<Country> allCountries,
    required int requiredDistractors,
  }) {
    final correctCapital = country.capital;

    final regionDistractors = _buildCapitalPool(
      countries: allCountries.where((candidate) {
        return candidate.code != country.code &&
            candidate.region == country.region &&
            candidate.capital != correctCapital;
      }),
    )..shuffle(_random);

    final selectedDistractors = <String>[
      ...regionDistractors.take(requiredDistractors),
    ];

    if (selectedDistractors.length < requiredDistractors) {
      final globalDistractors = _buildCapitalPool(
        countries: allCountries.where((candidate) {
          return candidate.code != country.code &&
              candidate.capital != correctCapital &&
              !selectedDistractors.contains(candidate.capital);
        }),
      )..shuffle(_random);

      selectedDistractors.addAll(
        globalDistractors
            .take(requiredDistractors - selectedDistractors.length),
      );
    }

    if (selectedDistractors.length < requiredDistractors) {
      throw StateError(
        'Not enough distractor capitals to build question for ${country.code}.',
      );
    }

    final options = <String>[correctCapital, ...selectedDistractors]
      ..shuffle(_random);

    return QuickQuizQuestion(
      countryCode: country.code,
      countryName: country.name,
      flagAssetOrUrl: country.flagAssetOrUrl,
      correctCapital: correctCapital,
      options: options,
    );
  }

  List<String> _buildCapitalPool({
    required Iterable<Country> countries,
  }) {
    final unique = <String>{};

    for (final country in countries) {
      unique.add(country.capital);
    }

    return unique.toList(growable: false);
  }
}
