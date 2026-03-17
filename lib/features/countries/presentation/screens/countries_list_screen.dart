import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/countries_providers.dart';
import '../widgets/country_list_tile.dart';

/// Home screen that lists countries and supports text search.
class CountriesListScreen extends ConsumerStatefulWidget {
  /// Creates the countries list screen.
  const CountriesListScreen({super.key});

  @override
  ConsumerState<CountriesListScreen> createState() => _CountriesListScreenState();
}

class _CountriesListScreenState extends ConsumerState<CountriesListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCountries = ref.watch(filteredCountriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries'),
        actions: [
          IconButton(
            tooltip: 'Quiz mode',
            onPressed: () => context.push('/quiz'),
            icon: const Icon(Icons.quiz_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            TextField(
              key: const ValueKey('countries-search-field'),
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search countries',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                ref.read(countrySearchQueryProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredCountries.when(
                data: (countries) {
                  if (countries.isEmpty) {
                    return const Center(
                      child: Text('No countries match your search.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: countries.length,
                    itemBuilder: (context, index) {
                      final country = countries[index];

                      return CountryListTile(
                        country: country,
                        onTap: () => context.push('/country/${country.code}'),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) {
                  return Center(
                    child: Text('Failed to load countries: $error'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
