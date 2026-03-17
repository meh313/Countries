import 'package:flutter/material.dart';

import '../../domain/entities/country.dart';
import 'country_flag.dart';

/// Compact visual representation of a country in the list.
class CountryListTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CountryFlag(
          imageUrl: country.flagAssetOrUrl,
          heroTag: 'flag-${country.code}',
        ),
        title: Text(
          country.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text('Capital: ${country.capital}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
