import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/quick_quiz_providers.dart';

/// Displays the final score of the quick quiz.
class QuickQuizResultScreen extends ConsumerWidget {
  /// Creates the quick-quiz result screen.
  const QuickQuizResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(quickQuizSessionProvider);
    final session = sessionState.session;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quick Quiz Result'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No quiz result found.'),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => context.go('/quiz/types'),
                  child: const Text('Back to Quiz Types'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Quiz Result'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You scored ${session.score}/${session.questions.length}',
                key: const ValueKey('quick-quiz-result-score'),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const ValueKey('quick-quiz-restart-button'),
                  onPressed: () => context.go('/quiz/quick'),
                  child: const Text('Restart Quick Quiz'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/quiz/types'),
                  child: const Text('Choose Another Quiz Type'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
