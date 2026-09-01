import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/preferences_providers.dart';
import '../../../countries/presentation/providers/countries_providers.dart';
import '../../domain/entities/quick_quiz_session.dart';
import '../../domain/entities/quiz_category.dart';
import '../../domain/usecases/generate_quick_quiz_questions.dart';

/// Exposes random source for quiz generation.
final quickQuizRandomProvider = Provider<Random>((ref) => Random());

/// Builds the quick-quiz questions generator use case.
final generateQuickQuizQuestionsProvider =
    Provider<GenerateQuickQuizQuestions>((
  ref,
) {
  final getAllCountries = ref.watch(getAllCountriesProvider);
  final random = ref.watch(quickQuizRandomProvider);

  return GenerateQuickQuizQuestions(
    getAllCountries,
    random: random,
  );
});

/// Loading status for the quick-quiz screen.
enum QuickQuizSessionStatus {
  /// Session has not been initialized yet.
  initial,

  /// Session data is currently loading.
  loading,

  /// Session is active and can receive user actions.
  ready,

  /// Session reached the result state.
  completed,

  /// Session failed to initialize.
  error,
}

/// Immutable state wrapper for quick-quiz presentation.
class QuickQuizSessionState {
  /// Creates a quick-quiz presentation state.
  const QuickQuizSessionState({
    required this.status,
    this.session,
    this.category = QuizCategory.capitals,
    this.answerMode = QuizAnswerMode.multipleChoice,
    this.errorMessage,
  });

  /// Returns the default idle state.
  factory QuickQuizSessionState.initial() {
    return const QuickQuizSessionState(status: QuickQuizSessionStatus.initial);
  }

  /// Current session status.
  final QuickQuizSessionStatus status;

  /// Active session when status is ready or completed.
  final QuickQuizSession? session;

  /// Subject matter of the active session.
  final QuizCategory category;

  /// Answer input mode of the active session.
  final QuizAnswerMode answerMode;

  /// Error details when status is error.
  final String? errorMessage;
}

/// Handles quick-quiz session lifecycle and user actions.
class QuickQuizSessionController extends StateNotifier<QuickQuizSessionState> {
  /// Creates the session controller.
  QuickQuizSessionController(this._generateQuestions, this._ref)
      : super(QuickQuizSessionState.initial());

  final GenerateQuickQuizQuestions _generateQuestions;
  final Ref _ref;

  /// Loads a new 15-question quiz session.
  Future<void> start({
    QuizCategory category = QuizCategory.capitals,
    QuizAnswerMode answerMode = QuizAnswerMode.multipleChoice,
  }) async {
    state = QuickQuizSessionState(
      status: QuickQuizSessionStatus.loading,
      category: category,
      answerMode: answerMode,
    );

    try {
      final questions = await _generateQuestions(
        questionCount: 15,
        optionsPerQuestion: 5,
        category: category,
      );

      state = QuickQuizSessionState(
        status: QuickQuizSessionStatus.ready,
        session: QuickQuizSession.initial(questions),
        category: category,
        answerMode: answerMode,
      );
    } on Object catch (error) {
      state = QuickQuizSessionState(
        status: QuickQuizSessionStatus.error,
        category: category,
        answerMode: answerMode,
        errorMessage: error.toString(),
      );
    }
  }

  /// Stores the answer for the current question and locks input.
  void selectAnswer(String selectedAnswer) {
    if (state.status != QuickQuizSessionStatus.ready || state.session == null) {
      return;
    }

    final session = state.session!;
    if (session.isCurrentQuestionAnswered) {
      return;
    }

    state = QuickQuizSessionState(
      status: QuickQuizSessionStatus.ready,
      session: session.answerCurrentQuestion(selectedAnswer),
      category: state.category,
      answerMode: state.answerMode,
    );
  }

  /// Stores a typed answer and validates it against the correct answer.
  void submitTypedAnswer(String typedAnswer) {
    if (state.status != QuickQuizSessionStatus.ready || state.session == null) {
      return;
    }

    final session = state.session!;
    if (session.isCurrentQuestionAnswered) {
      return;
    }

    final normalizedTyped = _normalizeAnswer(typedAnswer);
    final correctAnswer = session.currentQuestion.correctAnswer;
    final normalizedCorrect = _normalizeAnswer(correctAnswer);
    final storedAnswer =
        normalizedTyped == normalizedCorrect ? correctAnswer : typedAnswer;

    state = QuickQuizSessionState(
      status: QuickQuizSessionStatus.ready,
      session: session.answerCurrentQuestion(storedAnswer),
      category: state.category,
      answerMode: state.answerMode,
    );
  }

  /// Moves to next question or completes the quiz.
  bool nextQuestion() {
    if (state.status != QuickQuizSessionStatus.ready || state.session == null) {
      return false;
    }

    final session = state.session!;
    if (!session.isCurrentQuestionAnswered) {
      return false;
    }

    if (session.isLastQuestion) {
      state = QuickQuizSessionState(
        status: QuickQuizSessionStatus.completed,
        session: session,
        category: state.category,
        answerMode: state.answerMode,
      );
      _persistBestScore(session.score);
      return true;
    }

    state = QuickQuizSessionState(
      status: QuickQuizSessionStatus.ready,
      session: session.moveToNextQuestion(),
      category: state.category,
      answerMode: state.answerMode,
    );
    return false;
  }

  /// Recreates a new session with the same category and mode.
  Future<void> restart() async {
    await start(category: state.category, answerMode: state.answerMode);
  }

  void _persistBestScore(int score) {
    final preferences = _ref.read(sharedPreferencesProvider);
    if (preferences == null) {
      return;
    }

    final key = bestScoreKey(state.category, state.answerMode);
    final previous = preferences.getInt(key) ?? 0;
    if (score > previous) {
      preferences.setInt(key, score);
      _ref.invalidate(bestScoreProvider);
    }
  }

  static const _diacritics =
      'àáâãäåçèéêëìíîïñòóôõöùúûüýÿāăēĕėęěīĭįōŏőūŭůűșț';
  static const _plain = 'aaaaaaceeeeiiiinooooouuuuyyaaeeeeeiiioooouuuust';

  String _normalizeAnswer(String value) {
    final lower = value.trim().toLowerCase();
    final buffer = StringBuffer();

    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      final index = _diacritics.indexOf(char);
      buffer.write(index >= 0 ? _plain[index] : char);
    }

    return buffer.toString();
  }
}

/// Builds the preference key storing the best score for a quiz variant.
String bestScoreKey(QuizCategory category, QuizAnswerMode mode) {
  return 'quiz.best.${category.id}.${mode.id}';
}

/// Reads the persisted best score for a quiz variant.
final bestScoreProvider =
    Provider.family<int, (QuizCategory, QuizAnswerMode)>((ref, variant) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return preferences?.getInt(bestScoreKey(variant.$1, variant.$2)) ?? 0;
});

/// Exposes quick-quiz session state and actions.
final quickQuizSessionProvider =
    StateNotifierProvider<QuickQuizSessionController, QuickQuizSessionState>((
  ref,
) {
  final generator = ref.watch(generateQuickQuizQuestionsProvider);
  return QuickQuizSessionController(generator, ref);
});
