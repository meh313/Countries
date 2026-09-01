import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/quiz_category.dart';
import '../providers/quick_quiz_providers.dart';
import '../widgets/quiz_prompt_card.dart';
import 'quick_quiz_screen.dart';

/// Runs the 15-question quiz using typed answers.
class QuickQuizTypingScreen extends ConsumerStatefulWidget {
  /// Creates the typing quiz screen.
  const QuickQuizTypingScreen({
    this.category = QuizCategory.capitals,
    super.key,
  });

  /// Subject matter of this quiz run.
  final QuizCategory category;

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
      () => ref.read(quickQuizSessionProvider.notifier).start(
            category: widget.category,
            answerMode: QuizAnswerMode.typing,
          ),
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
        title: Text('${widget.category.label} Quiz (Typing)'),
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
    final correctAnswer = question.correctAnswer;
    final inputLabel = question.category == QuizCategory.flags
        ? 'Type the country name'
        : 'Type the capital';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuizProgressHeader(session: session),
          const SizedBox(height: 12),
          QuizPromptCard(
            question: question,
            heroTagPrefix: 'typing-quiz',
            questionIndex: session.currentQuestionIndex,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('quick-quiz-typing-input'),
            controller: controller,
            enabled: !isAnswered,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: inputLabel,
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
            QuizFeedbackText(
              feedbackKey: const ValueKey('quick-quiz-typing-feedback-text'),
              isCorrect: selectedAnswer == correctAnswer,
              correctAnswer: correctAnswer,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const ValueKey('quick-quiz-typing-view-map-button'),
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
