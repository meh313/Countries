import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/countries/presentation/screens/countries_list_screen.dart';
import '../../features/countries/presentation/screens/country_details_screen.dart';
import '../../features/quiz/presentation/screens/quiz_placeholder_screen.dart';

/// Provides the application router.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const CountriesListScreen(),
      ),
      GoRoute(
        path: '/country/:code',
        builder: (context, state) {
          final code = state.pathParameters['code']!;
          return CountryDetailsScreen(countryCode: code);
        },
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizPlaceholderScreen(),
      ),
    ],
  );
});
