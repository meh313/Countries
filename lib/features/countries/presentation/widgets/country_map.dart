import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/country.dart';

/// Displays an interactive map centered on the selected country.
class CountryMap extends StatelessWidget {
  /// Creates the map widget.
  const CountryMap({
    required this.country,
    super.key,
  });

  /// Country used to configure the map focus and marker.
  final Country country;

  @override
  Widget build(BuildContext context) {
    final capitalPoint = LatLng(country.latitude, country.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 280,
        child: FlutterMap(
          key: ValueKey('country-map-${country.code}'),
          options: MapOptions(
            initialCenter: capitalPoint,
            // Keep a stable country-level zoom instead of a city-level focus.
            initialZoom: 3.2,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.countries_app',
            ),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors'),
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: capitalPoint,
                  width: 28,
                  height: 28,
                  child: Icon(
                    key: ValueKey('country-map-marker-${country.code}'),
                    Icons.location_on,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                    shadows: const [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
