import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../countries/presentation/providers/countries_providers.dart';
import '../../domain/entities/quick_quiz_session.dart';
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

  /// Error details when status is error.
  final String? errorMessage;
}

/// Handles quick-quiz session lifecycle and user actions.
class QuickQuizSessionController extends StateNotifier<QuickQuizSessionState> {
  /// Creates the session controller.
  QuickQuizSessionController(this._generateQuestions)
      : super(QuickQuizSessionState.initial());

  final GenerateQuickQuizQuestions _generateQuestions;

  /// Loads a new 15-question quiz session.
  Future<void> start() async {
    state = const QuickQuizSessionState(status: QuickQuizSessionStatus.loading);

    try {
      final questions = await _generateQuestions(
        questionCount: 15,
        optionsPerQuestion: 5,
      );

      state = QuickQuizSessionState(
        status: QuickQuizSessionStatus.ready,
        session: QuickQuizSession.initial(questions),
      );
    } on Object catch (error) {
      state = QuickQuizSessionState(
        status: QuickQuizSessionStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  /// Stores the answer for the current question and locks input.
  void selectAnswer(String selectedCapital) {
    if (state.status != QuickQuizSessionStatus.ready || state.session == null) {
      return;
    }

    final session = state.session!;
    if (session.isCurrentQuestionAnswered) {
      return;
    }

    state = QuickQuizSessionState(
      status: QuickQuizSessionStatus.ready,
      session: session.answerCurrentQuestion(selectedCapital),
    );
  }

  /// Stores a typed answer and validates it against the current capital.
  void submitTypedAnswer(String typedCapital) {
    if (state.status != QuickQuizSessionStatus.ready || state.session == null) {
      return;
    }

    final session = state.session!;
    if (session.isCurrentQuestionAnswered) {
      return;
    }

    final normalizedTyped = _normalizeAnswer(typedCapital);
    final correctCapital = session.currentQuestion.correctCapital;
    final normalizedCorrect = _normalizeAnswer(correctCapital);
    final storedAnswer =
        normalizedTyped == normalizedCorrect ? correctCapital : typedCapital;

    state = QuickQuizSessionState(
      status: QuickQuizSessionStatus.ready,
      session: session.answerCurrentQuestion(storedAnswer),
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
      );
      return true;
    }

    state = QuickQuizSessionState(
      status: QuickQuizSessionStatus.ready,
      session: session.moveToNextQuestion(),
    );
    return false;
  }

  /// Recreates a new session.
  Future<void> restart() async {
    await start();
  }

  String _normalizeAnswer(String value) {
    return value.trim().toLowerCase();
  }
}

/// Exposes quick-quiz session state and actions.
final quickQuizSessionProvider =
    StateNotifierProvider<QuickQuizSessionController, QuickQuizSessionState>((
  ref,
) {
  final generator = ref.watch(generateQuickQuizQuestionsProvider);
  return QuickQuizSessionController(generator);
});
