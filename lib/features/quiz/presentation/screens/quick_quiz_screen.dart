import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../countries/presentation/widgets/country_flag.dart';
import '../providers/quick_quiz_providers.dart';

/// Runs the interactive 15-question quick capitals quiz.
class QuickQuizScreen extends ConsumerStatefulWidget {
  /// Creates the quick quiz screen.
  const QuickQuizScreen({super.key});

  @override
  ConsumerState<QuickQuizScreen> createState() => _QuickQuizScreenState();
}

class _QuickQuizScreenState extends ConsumerState<QuickQuizScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(quickQuizSessionProvider.notifier).start(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(quickQuizSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Quiz (MCQ)'),
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
    final correctCapital = question.correctCapital;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${session.currentQuestionIndex + 1}/${session.questions.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CountryFlag(
                    imageUrl: question.flagAssetOrUrl,
                    heroTag:
                        'quiz-flag-${question.countryCode}-${session.currentQuestionIndex}',
                    width: 80,
                    height: 56,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.countryName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: question.options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isCorrectOption = option == correctCapital;
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
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(option),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isAnswered) ...[
            Text(
              selectedAnswer == correctCapital
                  ? 'Correct answer.'
                  : 'Wrong answer. Correct: $correctCapital',
              key: const ValueKey('quick-quiz-feedback-text'),
              style: Theme.of(context).textTheme.bodyLarge,
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
    );
  }

  if (isSelectedWrongOption) {
    return FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      alignment: Alignment.centerLeft,
      backgroundColor: colorScheme.errorContainer,
      foregroundColor: colorScheme.onErrorContainer,
    );
  }

  return FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(48),
    alignment: Alignment.centerLeft,
  );
}
