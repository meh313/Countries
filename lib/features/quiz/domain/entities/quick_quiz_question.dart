/// Single question used in the quick capitals quiz flow.
class QuickQuizQuestion {
  /// Creates a quiz question.
  const QuickQuizQuestion({
    required this.countryCode,
    required this.countryName,
    required this.flagAssetOrUrl,
    required this.correctCapital,
    required this.options,
  });

  /// Stable country identifier used for internal tracking.
  final String countryCode;

  /// Country name shown to the user.
  final String countryName;

  /// Flag asset path rendered with the prompt.
  final String flagAssetOrUrl;

  /// Correct answer for the question.
  final String correctCapital;

  /// Candidate answers shown to the user.
  final List<String> options;
}
