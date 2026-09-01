import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/country.dart';
import '../providers/favorites_provider.dart';
import 'country_flag.dart';

/// Compact visual representation of a country in the list.
class CountryListTile extends ConsumerWidget {
  /// Creates the list tile widget.
  const CountryListTile({
    required this.country,
    required this.onTap,
    super.key,
  });

  /// Country content shown by the row.
  final Country country;

  /// Callback fired when the row is selected.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select((codes) => codes.contains(country.code)),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CountryFlag(
          imageUrl: country.flagAssetOrUrl,
          heroTag: 'flag-${country.code}',
        ),
        title: Text(
          country.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          country.region == null
              ? country.capital
              : '${country.capital} · ${country.region}',
        ),
        trailing: IconButton(
          key: ValueKey('favorite-toggle-${country.code}'),
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? colorScheme.secondary : null,
          ),
          onPressed: () {
            ref.read(favoritesProvider.notifier).toggle(country.code);
          },
        ),
      ),
    );
  }
}
