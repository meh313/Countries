import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../countries/presentation/widgets/country_flag.dart';
import '../../domain/entities/quick_quiz_question.dart';
import '../../domain/entities/quiz_category.dart';
import '../providers/quick_quiz_providers.dart';

/// Displays the final score and per-question review of the quick quiz.
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
          title: const Text('Quiz Result'),
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

    final score = session.score;
    final total = session.questions.length;
    final bestScore = ref.watch(
      bestScoreProvider((sessionState.category, sessionState.answerMode)),
    );
    final restartPath = sessionState.answerMode == QuizAnswerMode.typing
        ? '/quiz/quick/typing?category=${sessionState.category.id}'
        : '/quiz/quick?category=${sessionState.category.id}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
        children: [
          _ScoreRing(score: score, total: total),
          const SizedBox(height: 12),
          Text(
            _scoreMessage(score, total),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Best in this mode: $bestScore/$total',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const ValueKey('quick-quiz-restart-button'),
              onPressed: () => context.go(restartPath),
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Play Again'),
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
          const SizedBox(height: 24),
          Text(
            'Review',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < session.questions.length; i += 1)
            _ReviewTile(
              index: i,
              question: session.questions[i],
              userAnswer: session.answersByQuestionIndex[i],
              isCorrect: session.isAnswerCorrect(i),
            ),
        ],
      ),
    );
  }

  String _scoreMessage(int score, int total) {
    final ratio = total == 0 ? 0.0 : score / total;
    if (ratio == 1.0) {
      return 'Perfect score — world-class geography!';
    }
    if (ratio >= 0.8) {
      return 'Excellent! You really know your way around the globe.';
    }
    if (ratio >= 0.5) {
      return 'Nice work — keep exploring to push it higher.';
    }
    return 'Good start — the map is waiting for you.';
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.total});

  final int score;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ratio = total == 0 ? 0.0 : score / total;

    return Center(
      child: SizedBox(
        width: 148,
        height: 148,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  backgroundColor:
                      colorScheme.primary.withValues(alpha: 0.12),
                );
              },
            ),
            Center(
              child: Text(
                '$score/$total',
                key: const ValueKey('quick-quiz-result-score'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.index,
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
  });

  final int index;
  final QuickQuizQuestion question;
  final String? userAnswer;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CountryFlag(
          imageUrl: question.flagAssetOrUrl,
          heroTag: 'result-flag-${question.countryCode}-$index',
          width: 48,
          height: 34,
        ),
        title: Text(question.countryName),
        subtitle: Text(
          isCorrect
              ? question.correctAnswer
              : '${userAnswer ?? '—'} → ${question.correctAnswer}',
        ),
        trailing: Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: isCorrect ? colorScheme.primary : colorScheme.error,
        ),
      ),
    );
  }
}
