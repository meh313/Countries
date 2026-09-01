/// Subject matter of a quiz session.
enum QuizCategory {
  /// Guess the capital city of a given country.
  capitals,

  /// Guess the country a flag belongs to.
  flags;

  /// Stable identifier used in routes and persistence keys.
  String get id => name;

  /// Human-readable label.
  String get label => switch (this) {
        QuizCategory.capitals => 'Capitals',
        QuizCategory.flags => 'Flags',
      };

  /// Parses [value] into a category, defaulting to [QuizCategory.capitals].
  static QuizCategory fromId(String? value) {
    return QuizCategory.values.firstWhere(
      (category) => category.id == value,
      orElse: () => QuizCategory.capitals,
    );
  }
}

/// How the user provides answers during a quiz session.
enum QuizAnswerMode {
  /// Pick one option out of several.
  multipleChoice,

  /// Type the answer into a text field.
  typing;

  /// Stable identifier used in routes and persistence keys.
  String get id => switch (this) {
        QuizAnswerMode.multipleChoice => 'mcq',
        QuizAnswerMode.typing => 'typing',
      };

  /// Human-readable label.
  String get label => switch (this) {
        QuizAnswerMode.multipleChoice => 'Multiple choice',
        QuizAnswerMode.typing => 'Typing',
      };
}
