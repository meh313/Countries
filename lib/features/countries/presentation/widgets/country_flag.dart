import 'package:flutter/material.dart';

/// Renders a country flag from a network URL.
class CountryFlag extends StatelessWidget {
  /// Creates the flag widget.
  const CountryFlag({
    required this.imageUrl,
    required this.heroTag,
    super.key,
    this.width = 56,
    this.height = 40,
  });

  /// Image URL for the flag asset.
  final String imageUrl;

  /// Shared hero tag between list and details screens.
  final String heroTag;

  /// Desired width.
  final double width;

  /// Desired height.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: const Icon(Icons.flag_outlined),
            );
          },
        ),
      ),
    );
  }
}
