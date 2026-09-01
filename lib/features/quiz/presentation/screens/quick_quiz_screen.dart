import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/quick_quiz_session.dart';
import '../../domain/entities/quiz_category.dart';
import '../providers/quick_quiz_providers.dart';
import '../widgets/quiz_prompt_card.dart';

/// Runs the interactive 15-question multiple-choice quiz.
class QuickQuizScreen extends ConsumerStatefulWidget {
  /// Creates the quick quiz screen.
  const QuickQuizScreen({
    this.category = QuizCategory.capitals,
    super.key,
  });

  /// Subject matter of this quiz run.
  final QuizCategory category;

  @override
  ConsumerState<QuickQuizScreen> createState() => _QuickQuizScreenState();
}

class _QuickQuizScreenState extends ConsumerState<QuickQuizScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(quickQuizSessionProvider.notifier).start(
            category: widget.category,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(quickQuizSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.label} Quiz'),
      ),
      body: switch (sessionState.status) {
        QuickQuizSessionStatus.initial ||
        QuickQuizSessionStatus.loading =>
          const Center(
            child: CircularProgressIndicator(),
          ),
        QuickQuizSessionStatus.error => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                sessionState.errorMessage ?? 'Failed to start the quiz.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        QuickQuizSessionStatus.ready ||
        QuickQuizSessionStatus.completed =>
          _ReadyQuizBody(
            state: sessionState,
          ),
      },
    );
  }
}

/// Renders the current question and answer controls.
class _ReadyQuizBody extends ConsumerWidget {
  /// Creates the ready-state body.
  const _ReadyQuizBody({required this.state});

  /// Current quick-quiz state.
  final QuickQuizSessionState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = state.session!;
    final question = session.currentQuestion;
    final selectedAnswer = session.selectedAnswer;
    final isAnswered = session.isCurrentQuestionAnswered;
    final correctAnswer = question.correctAnswer;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuizProgressHeader(session: session),
          const SizedBox(height: 12),
          QuizPromptCard(
            question: question,
            heroTagPrefix: 'quiz',
            questionIndex: session.currentQuestionIndex,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: question.options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isCorrectOption = option == correctAnswer;
                final isSelectedOption = option == selectedAnswer;
                final buttonStyle = _optionButtonStyle(
                  context: context,
                  isAnswered: isAnswered,
                  isCorrectOption: isCorrectOption,
                  isSelectedWrongOption: isSelectedOption && !isCorrectOption,
                );

                return FilledButton.tonal(
                  key: ValueKey('quick-quiz-option-$index'),
                  onPressed: isAnswered
                      ? null
                      : () {
                          ref
                              .read(quickQuizSessionProvider.notifier)
                              .selectAnswer(option);
                        },
                  style: buttonStyle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(option),
                          ),
                        ),
                        if (isAnswered && isCorrectOption)
                          const Icon(Icons.check_circle_outline, size: 20),
                        if (isAnswered &&
                            isSelectedOption &&
                            !isCorrectOption)
                          const Icon(Icons.cancel_outlined, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (isAnswered) ...[
            QuizFeedbackText(
              feedbackKey: const ValueKey('quick-quiz-feedback-text'),
              isCorrect: selectedAnswer == correctAnswer,
              correctAnswer: correctAnswer,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const ValueKey('quick-quiz-view-map-button'),
                onPressed: () =>
                    context.push('/country/${question.countryCode}'),
                icon: const Icon(Icons.map_outlined),
                label: const Text('View on map'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const ValueKey('quick-quiz-next-button'),
                onPressed: () {
                  final completed = ref
                      .read(quickQuizSessionProvider.notifier)
                      .nextQuestion();

                  if (completed) {
                    context.go('/quiz/quick/result');
                  }
                },
                child: Text(session.isLastQuestion ? 'Finish' : 'Next'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

ButtonStyle _optionButtonStyle({
  required BuildContext context,
  required bool isAnswered,
  required bool isCorrectOption,
  required bool isSelectedWrongOption,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  if (!isAnswered) {
    return FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      alignment: Alignment.centerLeft,
    );
  }

  if (isCorrectOption) {
    return FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      alignment: Alignment.centerLeft,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      disabledBackgroundColor: colorScheme.primaryContainer,
      disabledForegroundColor: colorScheme.onPrimaryContainer,
    );
  }

  if (isSelectedWrongOption) {
    return FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      alignment: Alignment.centerLeft,
      backgroundColor: colorScheme.errorContainer,
      foregroundColor: colorScheme.onErrorContainer,
      disabledBackgroundColor: colorScheme.errorContainer,
      disabledForegroundColor: colorScheme.onErrorContainer,
    );
  }

  return FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(48),
    alignment: Alignment.centerLeft,
  );
}

/// Shared progress header showing question position and completion bar.
class QuizProgressHeader extends StatelessWidget {
  /// Creates the progress header.
  const QuizProgressHeader({required this.session, super.key});

  /// Active quiz session.
  final QuickQuizSession session;

  @override
  Widget build(BuildContext context) {
    final index = session.currentQuestionIndex;
    final total = session.questions.length;
    final score = session.score;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${index + 1}/$total',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Score: $score',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (index + 1) / total,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

/// Shared answered-state feedback line.
class QuizFeedbackText extends StatelessWidget {
  /// Creates the feedback text widget.
  const QuizFeedbackText({
    required this.feedbackKey,
    required this.isCorrect,
    required this.correctAnswer,
    super.key,
  });

  /// Widget key used by tests.
  final Key feedbackKey;

  /// Whether the selected answer was correct.
  final bool isCorrect;

  /// Correct answer to reveal on mistakes.
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: isCorrect ? colorScheme.primary : colorScheme.error,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isCorrect
                ? 'Correct answer.'
                : 'Wrong answer. Correct: $correctAnswer',
            key: feedbackKey,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
