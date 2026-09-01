import 'package:flutter/material.dart';

import '../../../countries/presentation/widgets/country_flag.dart';
import '../../domain/entities/quick_quiz_question.dart';
import '../../domain/entities/quiz_category.dart';

/// Prompt card adapting its layout to the quiz category.
///
/// Capitals questions show the flag next to the country name and ask for the
/// capital; flags questions show a large flag alone and ask for the country.
class QuizPromptCard extends StatelessWidget {
  /// Creates the prompt card.
  const QuizPromptCard({
    required this.question,
    required this.heroTagPrefix,
    required this.questionIndex,
    super.key,
  });

  /// Question rendered by the card.
  final QuickQuizQuestion question;

  /// Prefix ensuring hero tags stay unique per quiz flow.
  final String heroTagPrefix;

  /// Zero-based question index used in the hero tag.
  final int questionIndex;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final heroTag =
        '$heroTagPrefix-flag-${question.countryCode}-$questionIndex';

    if (question.category == QuizCategory.flags) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CountryFlag(
                imageUrl: question.flagAssetOrUrl,
                heroTag: heroTag,
                width: 168,
                height: 112,
              ),
              const SizedBox(height: 12),
              Text(
                'Which country does this flag belong to?',
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CountryFlag(
              imageUrl: question.flagAssetOrUrl,
              heroTag: heroTag,
              width: 80,
              height: 56,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.countryName,
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'What is the capital?',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
