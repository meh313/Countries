import 'quiz_category.dart';

/// Single question used in the quick quiz flows.
class QuickQuizQuestion {
  /// Creates a quiz question.
  const QuickQuizQuestion({
    required this.category,
    required this.countryCode,
    required this.countryName,
    required this.flagAssetOrUrl,
    required this.correctAnswer,
    required this.options,
  });

  /// Subject matter this question belongs to.
  final QuizCategory category;

  /// Stable country identifier used for internal tracking.
  final String countryCode;

  /// Country name shown to the user (capitals) or hidden (flags).
  final String countryName;

  /// Flag asset path rendered with the prompt.
  final String flagAssetOrUrl;

  /// Correct answer for the question.
  final String correctAnswer;

  /// Candidate answers shown to the user.
  final List<String> options;
}
