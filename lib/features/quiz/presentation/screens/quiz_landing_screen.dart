import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Quiz tab landing page.
class QuizLandingScreen extends StatelessWidget {
  /// Creates the quiz landing screen.
  const QuizLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.quiz_rounded,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Ready for capitals challenges?',
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Tap Start in the bottom bar to choose a quiz type and begin.',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                key: const ValueKey('quiz-landing-open-types'),
                onPressed: () => context.go('/quiz/types'),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Choose Quiz Type'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
