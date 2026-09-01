import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Lets the user choose the quiz mode to start.
class QuizTypesScreen extends StatelessWidget {
  /// Creates the quiz types screen.
  const QuizTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Quiz Type'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _QuizTypeCard(
            cardKey: const ValueKey('quiz-type-quick'),
            icon: Icons.flash_on_outlined,
            title: 'Capitals Quiz (MCQ)',
            lines: const [
              '15 questions about country capitals.',
              'Each question has 5 options with one correct answer.',
            ],
            onTap: () => context.go('/quiz/quick?category=capitals'),
          ),
          const SizedBox(height: 12),
          _QuizTypeCard(
            cardKey: const ValueKey('quiz-type-quick-typing'),
            icon: Icons.keyboard_alt_outlined,
            title: 'Capitals Quiz (Typing)',
            lines: const [
              '15 questions about country capitals.',
              'Type the capital city instead of choosing options.',
            ],
            onTap: () => context.go('/quiz/quick/typing?category=capitals'),
          ),
          const SizedBox(height: 12),
          _QuizTypeCard(
            cardKey: const ValueKey('quiz-type-flags'),
            icon: Icons.flag_outlined,
            title: 'Flags Quiz (MCQ)',
            lines: const [
              '15 flags to recognize from around the world.',
              'Pick the country each flag belongs to.',
            ],
            onTap: () => context.go('/quiz/quick?category=flags'),
          ),
          const SizedBox(height: 12),
          _QuizTypeCard(
            cardKey: const ValueKey('quiz-type-flags-typing'),
            icon: Icons.flag_circle_outlined,
            title: 'Flags Quiz (Typing)',
            lines: const [
              '15 flags to recognize from around the world.',
              'Type the country name for each flag.',
            ],
            onTap: () => context.go('/quiz/quick/typing?category=flags'),
          ),
        ],
      ),
    );
  }
}

class _QuizTypeCard extends StatelessWidget {
  const _QuizTypeCard({
    required this.cardKey,
    required this.icon,
    required this.title,
    required this.lines,
    required this.onTap,
  });

  final Key cardKey;
  final IconData icon;
  final String title;
  final List<String> lines;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        key: cardKey,
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),
              for (final line in lines) ...[
                Text(line),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
