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
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: InkWell(
              key: const ValueKey('quiz-type-quick'),
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.go('/quiz/quick'),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flash_on_outlined),
                        SizedBox(width: 8),
                        Text(
                          'Quick Quiz (MCQ)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('15 questions about country capitals.'),
                    SizedBox(height: 6),
                    Text(
                        'Each question has 5 options with one correct answer.'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: InkWell(
              key: const ValueKey('quiz-type-quick-typing'),
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.go('/quiz/quick/typing'),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.keyboard_alt_outlined),
                        SizedBox(width: 8),
                        Text(
                          'Quick Quiz (Typing)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('15 questions about country capitals.'),
                    SizedBox(height: 6),
                    Text('Type the capital city instead of choosing options.'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
