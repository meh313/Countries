import 'dart:math';

import '../../../countries/domain/entities/country.dart';
import '../../../countries/domain/usecases/get_all_countries.dart';
import '../entities/quick_quiz_question.dart';
import '../entities/quiz_category.dart';

/// Generates quick quiz questions from the countries catalog.
class GenerateQuickQuizQuestions {
  /// Creates the question generator use case.
  GenerateQuickQuizQuestions(
    this._getAllCountries, {
    Random? random,
  }) : _random = random ?? Random();

  final GetAllCountries _getAllCountries;
  final Random _random;

  /// Builds an ordered list of quick-quiz questions for [category].
  Future<List<QuickQuizQuestion>> call({
    int questionCount = 15,
    int optionsPerQuestion = 5,
    QuizCategory category = QuizCategory.capitals,
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
            category: category,
          ),
        )
        .toList(growable: false);
  }

  String _answerOf(Country country, QuizCategory category) {
    return switch (category) {
      QuizCategory.capitals => country.capital,
      QuizCategory.flags => country.name,
    };
  }

  QuickQuizQuestion _toQuestion({
    required Country country,
    required List<Country> allCountries,
    required int requiredDistractors,
    required QuizCategory category,
  }) {
    final correctAnswer = _answerOf(country, category);

    final regionDistractors = _buildAnswerPool(
      category: category,
      countries: allCountries.where((candidate) {
        return candidate.code != country.code &&
            candidate.region == country.region &&
            _answerOf(candidate, category) != correctAnswer;
      }),
    )..shuffle(_random);

    final selectedDistractors = <String>[
      ...regionDistractors.take(requiredDistractors),
    ];

    if (selectedDistractors.length < requiredDistractors) {
      final globalDistractors = _buildAnswerPool(
        category: category,
        countries: allCountries.where((candidate) {
          final answer = _answerOf(candidate, category);
          return candidate.code != country.code &&
              answer != correctAnswer &&
              !selectedDistractors.contains(answer);
        }),
      )..shuffle(_random);

      selectedDistractors.addAll(
        globalDistractors
            .take(requiredDistractors - selectedDistractors.length),
      );
    }

    if (selectedDistractors.length < requiredDistractors) {
      throw StateError(
        'Not enough distractor answers to build question for ${country.code}.',
      );
    }

    final options = <String>[correctAnswer, ...selectedDistractors]
      ..shuffle(_random);

    return QuickQuizQuestion(
      category: category,
      countryCode: country.code,
      countryName: country.name,
      flagAssetOrUrl: country.flagAssetOrUrl,
      correctAnswer: correctAnswer,
      options: options,
    );
  }

  List<String> _buildAnswerPool({
    required QuizCategory category,
    required Iterable<Country> countries,
  }) {
    final unique = <String>{};

    for (final country in countries) {
      unique.add(_answerOf(country, category));
    }

    return unique.toList(growable: false);
  }
}
