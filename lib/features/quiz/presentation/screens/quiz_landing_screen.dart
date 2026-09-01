import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/quiz_category.dart';
import '../providers/quick_quiz_providers.dart';

/// Quiz tab landing page with best scores overview.
class QuizLandingScreen extends ConsumerWidget {
  /// Creates the quiz landing screen.
  const QuizLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final variants = <(String, QuizCategory, QuizAnswerMode)>[
      ('Capitals · MCQ', QuizCategory.capitals, QuizAnswerMode.multipleChoice),
      ('Capitals · Typing', QuizCategory.capitals, QuizAnswerMode.typing),
      ('Flags · MCQ', QuizCategory.flags, QuizAnswerMode.multipleChoice),
      ('Flags · Typing', QuizCategory.flags, QuizAnswerMode.typing),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
        children: [
          Icon(
            Icons.quiz_rounded,
            size: 72,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Ready for a geography challenge?',
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Test yourself on capitals and flags — multiple choice or typing.',
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              key: const ValueKey('quiz-landing-open-types'),
              onPressed: () => context.go('/quiz/types'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Choose Quiz Type'),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Best scores',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                for (final (label, category, mode) in variants)
                  ListTile(
                    leading: Icon(
                      category == QuizCategory.flags
                          ? Icons.flag_outlined
                          : Icons.location_city_outlined,
                      color: colorScheme.primary,
                    ),
                    title: Text(label),
                    trailing: Text(
                      '${ref.watch(bestScoreProvider((category, mode)))}/15',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
