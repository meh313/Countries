import 'quick_quiz_question.dart';

/// Immutable quick-quiz runtime state.
class QuickQuizSession {
  /// Creates a quick-quiz session.
  const QuickQuizSession({
    required this.questions,
    required this.currentQuestionIndex,
    required this.answersByQuestionIndex,
  });

  /// Builds the initial state for a question set.
  factory QuickQuizSession.initial(List<QuickQuizQuestion> questions) {
    return QuickQuizSession(
      questions: questions,
      currentQuestionIndex: 0,
      answersByQuestionIndex: const <int, String>{},
    );
  }

  /// Ordered list of generated questions.
  final List<QuickQuizQuestion> questions;

  /// Zero-based index for the currently visible question.
  final int currentQuestionIndex;

  /// Selected answer by question index.
  final Map<int, String> answersByQuestionIndex;

  /// Returns the current question.
  QuickQuizQuestion get currentQuestion => questions[currentQuestionIndex];

  /// Returns the selected answer for the current question if available.
  String? get selectedAnswer => answersByQuestionIndex[currentQuestionIndex];

  /// Whether the current question already has a selected answer.
  bool get isCurrentQuestionAnswered => selectedAnswer != null;

  /// Whether the current question is the last one.
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  /// Correct answer count across all answered questions.
  int get score {
    var total = 0;

    answersByQuestionIndex.forEach((index, selectedCapital) {
      if (questions[index].correctCapital == selectedCapital) {
        total += 1;
      }
    });

    return total;
  }

  /// Returns a copy with updated selected answer for the active question.
  QuickQuizSession answerCurrentQuestion(String selectedCapital) {
    return QuickQuizSession(
      questions: questions,
      currentQuestionIndex: currentQuestionIndex,
      answersByQuestionIndex: {
        ...answersByQuestionIndex,
        currentQuestionIndex: selectedCapital,
      },
    );
  }

  /// Returns a copy moved to the next question.
  QuickQuizSession moveToNextQuestion() {
    return QuickQuizSession(
      questions: questions,
      currentQuestionIndex: currentQuestionIndex + 1,
      answersByQuestionIndex: answersByQuestionIndex,
    );
  }
}
