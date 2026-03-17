import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/countries_providers.dart';
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

    return Scaffold(
      appBar: AppBar(),
      body: countryValue.when(
        data: (country) {
          if (country == null) {
            return const Center(
              child: Text('Country not found.'),
            );
          }

          final textTheme = Theme.of(context).textTheme;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CountryFlag(
                      imageUrl: country.flagAssetOrUrl,
                      heroTag: 'flag-${country.code}',
                      width: 96,
                      height: 72,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            country.name,
                            style: textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Capital: ${country.capital}',
                            style: textTheme.titleMedium,
                          ),
                          if (country.region != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Region: ${country.region}',
                              style: textTheme.bodyLarge,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Map',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                CountryMap(country: country),
                const SizedBox(height: 12),
                Text(
                  'Focused on ${country.capital} at '
                  '${country.latitude.toStringAsFixed(4)}, '
                  '${country.longitude.toStringAsFixed(4)}.',
                ),
              ],
            ),
          );
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
