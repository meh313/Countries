import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_mode_provider.dart';
import '../providers/countries_providers.dart';
import '../widgets/country_list_tile.dart';

/// Home screen that lists countries with search, region, and favorite
/// filters.
class CountriesListScreen extends ConsumerStatefulWidget {
  /// Creates the countries list screen.
  const CountriesListScreen({super.key});

  @override
  ConsumerState<CountriesListScreen> createState() =>
      _CountriesListScreenState();
}

class _CountriesListScreenState extends ConsumerState<CountriesListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(countrySearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCountries = ref.watch(filteredCountriesProvider);
    final regions = ref.watch(regionsProvider);
    final selectedRegion = ref.watch(regionFilterProvider);
    final favoritesOnly = ref.watch(favoritesOnlyProvider);
    final query = ref.watch(countrySearchQueryProvider);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries'),
        actions: [
          IconButton(
            key: const ValueKey('theme-toggle-button'),
            tooltip: brightness == Brightness.dark
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            icon: Icon(
              brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () =>
                ref.read(themeModeProvider.notifier).toggle(brightness),
          ),
          IconButton(
            key: const ValueKey('favorites-filter-button'),
            tooltip:
                favoritesOnly ? 'Show all countries' : 'Show favorites only',
            icon: Icon(
              favoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: favoritesOnly
                  ? Theme.of(context).colorScheme.secondary
                  : null,
            ),
            onPressed: () {
              ref.read(favoritesOnlyProvider.notifier).state = !favoritesOnly;
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              key: const ValueKey('countries-search-field'),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by country or capital',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        key: const ValueKey('countries-search-clear'),
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(countrySearchQueryProvider.notifier)
                              .state = '';
                        },
                      ),
              ),
              onChanged: (value) {
                ref.read(countrySearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          if (regions.isNotEmpty)
            SizedBox(
              height: 56,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                scrollDirection: Axis.horizontal,
                itemCount: regions.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return FilterChip(
                      key: const ValueKey('region-chip-all'),
                      label: const Text('All'),
                      selected: selectedRegion == null,
                      showCheckmark: false,
                      onSelected: (_) {
                        ref.read(regionFilterProvider.notifier).state = null;
                      },
                    );
                  }

                  final region = regions[index - 1];
                  final isSelected = selectedRegion == region;

                  return FilterChip(
                    key: ValueKey('region-chip-$region'),
                    label: Text(region),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (_) {
                      ref.read(regionFilterProvider.notifier).state =
                          isSelected ? null : region;
                    },
                  );
                },
              ),
            ),
          Expanded(
            child: filteredCountries.when(
              data: (countries) {
                if (countries.isEmpty) {
                  return _EmptyState(favoritesOnly: favoritesOnly);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: countries.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 4),
                        child: Text(
                          '${countries.length} '
                          '${countries.length == 1 ? 'country' : 'countries'}',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                        ),
                      );
                    }

                    final country = countries[index - 1];

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
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.favoritesOnly});

  final bool favoritesOnly;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            favoritesOnly ? Icons.favorite_border : Icons.public_off_outlined,
            size: 56,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 12),
          Text(
            favoritesOnly
                ? 'No favorites yet. Tap the heart on a country to save it.'
                : 'No countries match your filters.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
