import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/countries/presentation/screens/countries_list_screen.dart';
import '../../features/countries/presentation/screens/country_details_screen.dart';
import '../../features/navigation/presentation/screens/app_shell_screen.dart';
import '../../features/quiz/domain/entities/quiz_category.dart';
import '../../features/quiz/presentation/screens/quick_quiz_result_screen.dart';
import '../../features/quiz/presentation/screens/quick_quiz_screen.dart';
import '../../features/quiz/presentation/screens/quick_quiz_typing_screen.dart';
import '../../features/quiz/presentation/screens/quiz_landing_screen.dart';
import '../../features/quiz/presentation/screens/quiz_types_screen.dart';

/// Provides the application router.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShellScreen(
            currentLocation: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const CountriesListScreen(),
          ),
          GoRoute(
            path: '/quiz',
            builder: (context, state) => const QuizLandingScreen(),
          ),
          GoRoute(
            path: '/quiz/types',
            builder: (context, state) => const QuizTypesScreen(),
          ),
          GoRoute(
            path: '/quiz/quick',
            builder: (context, state) => QuickQuizScreen(
              category: QuizCategory.fromId(
                state.uri.queryParameters['category'],
              ),
            ),
          ),
          GoRoute(
            path: '/quiz/quick/typing',
            builder: (context, state) => QuickQuizTypingScreen(
              category: QuizCategory.fromId(
                state.uri.queryParameters['category'],
              ),
            ),
          ),
          GoRoute(
            path: '/quiz/quick/result',
            builder: (context, state) => const QuickQuizResultScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/country/:code',
        builder: (context, state) {
          final code = state.pathParameters['code']!;
          return CountryDetailsScreen(countryCode: code);
        },
      ),
    ],
  );
});
