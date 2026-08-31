import 'package:flutter/material.dart';

/// Renders a country flag from a local bundled asset.
class CountryFlag extends StatelessWidget {
  /// Creates the flag widget.
  const CountryFlag({
    required this.imageUrl,
    required this.heroTag,
    super.key,
    this.width = 56,
    this.height = 40,
  });

  /// Asset path for the flag image.
  final String imageUrl;

  /// Shared hero tag between list and details screens.
  final String heroTag;

  /// Desired width.
  final double width;

  /// Desired height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.flag_outlined),
    );

    final image = Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );

    return Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: image,
      ),
    );
  }
}
