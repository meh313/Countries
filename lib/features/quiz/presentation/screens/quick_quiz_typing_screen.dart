import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../countries/presentation/widgets/country_flag.dart';
import '../providers/quick_quiz_providers.dart';

/// Runs the 15-question capitals quiz using typed answers.
class QuickQuizTypingScreen extends ConsumerStatefulWidget {
  /// Creates the typing quiz screen.
  const QuickQuizTypingScreen({super.key});

  @override
  ConsumerState<QuickQuizTypingScreen> createState() =>
      _QuickQuizTypingScreenState();
}

class _QuickQuizTypingScreenState extends ConsumerState<QuickQuizTypingScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _answerController.addListener(_handleInputChange);
    Future<void>.microtask(
      () => ref.read(quickQuizSessionProvider.notifier).start(),
    );
  }

  @override
  void dispose() {
    _answerController.removeListener(_handleInputChange);
    _answerController.dispose();
    super.dispose();
  }

  void _handleInputChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(quickQuizSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Quiz (Typing)'),
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
          _TypingReadyQuizBody(
            state: sessionState,
            controller: _answerController,
            canSubmit:
                !sessionState.session!.isCurrentQuestionAnswered &&
                _answerController.text.trim().isNotEmpty,
          ),
      },
    );
  }
}

class _TypingReadyQuizBody extends ConsumerWidget {
  const _TypingReadyQuizBody({
    required this.state,
    required this.controller,
    required this.canSubmit,
  });

  final QuickQuizSessionState state;
  final TextEditingController controller;
  final bool canSubmit;

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
                        'typing-quiz-flag-${question.countryCode}-${session.currentQuestionIndex}',
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
          TextField(
            key: const ValueKey('quick-quiz-typing-input'),
            controller: controller,
            enabled: !isAnswered,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Type the capital',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              if (!canSubmit) {
                return;
              }
              ref
                  .read(quickQuizSessionProvider.notifier)
                  .submitTypedAnswer(controller.text);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const ValueKey('quick-quiz-typing-submit-button'),
              onPressed: canSubmit
                  ? () {
                      ref
                          .read(quickQuizSessionProvider.notifier)
                          .submitTypedAnswer(controller.text);
                    }
                  : null,
              child: const Text('Submit Answer'),
            ),
          ),
          const SizedBox(height: 12),
          if (isAnswered) ...[
            Text(
              selectedAnswer == correctCapital
                  ? 'Correct answer.'
                  : 'Wrong answer. Correct: $correctCapital',
              key: const ValueKey('quick-quiz-typing-feedback-text'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const ValueKey('quick-quiz-typing-view-map-button'),
                onPressed: () => context.push('/country/${question.countryCode}'),
                icon: const Icon(Icons.map_outlined),
                label: const Text('View on map'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const ValueKey('quick-quiz-typing-next-button'),
                onPressed: () {
                  final completed = ref
                      .read(quickQuizSessionProvider.notifier)
                      .nextQuestion();

                  if (completed) {
                    context.go('/quiz/quick/result');
                    return;
                  }

                  controller.clear();
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
