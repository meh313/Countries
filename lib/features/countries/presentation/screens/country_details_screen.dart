import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/country.dart';
import '../providers/countries_providers.dart';
import '../providers/favorites_provider.dart';
import '../widgets/country_flag.dart';
import '../widgets/country_map.dart';

/// Detail screen for a selected country.
class CountryDetailsScreen extends ConsumerWidget {
  /// Creates the detail screen.
  const CountryDetailsScreen({
    required this.countryCode,
    super.key,
  });

  /// Country identifier from the route.
  final String countryCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countryValue = ref.watch(countryByCodeProvider(countryCode));
    final isFavorite = ref.watch(
      favoritesProvider.select((codes) => codes.contains(countryCode)),
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            key: ValueKey('details-favorite-toggle-$countryCode'),
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? Theme.of(context).colorScheme.secondary
                  : null,
            ),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggle(countryCode);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: countryValue.when(
        data: (country) {
          if (country == null) {
            return const Center(
              child: Text('Country not found.'),
            );
          }

          return _CountryDetailsBody(country: country);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return Center(
            child: Text('Failed to load country: $error'),
          );
        },
      ),
    );
  }
}

class _CountryDetailsBody extends StatelessWidget {
  const _CountryDetailsBody({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CountryFlag(
                    imageUrl: country.flagAssetOrUrl,
                    heroTag: 'flag-${country.code}',
                    width: 104,
                    height: 76,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          country.name,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Capital: ${country.capital}',
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (country.region != null)
                _InfoChip(
                  icon: Icons.public,
                  label: country.region!,
                  color: colorScheme.primary,
                ),
              _InfoChip(
                icon: Icons.tag,
                label: country.code,
                color: colorScheme.secondary,
              ),
              _InfoChip(
                icon: Icons.place_outlined,
                label: '${country.latitude.toStringAsFixed(4)}, '
                    '${country.longitude.toStringAsFixed(4)}',
                color: colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Map',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          CountryMap(country: country),
          const SizedBox(height: 12),
          Text(
            'Country-level zoom with capital marker at '
            '${country.latitude.toStringAsFixed(4)}, '
            '${country.longitude.toStringAsFixed(4)}.',
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
