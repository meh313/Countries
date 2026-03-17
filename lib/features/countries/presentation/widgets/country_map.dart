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
    final center = LatLng(country.latitude, country.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 280,
        child: FlutterMap(
          key: ValueKey('country-map-${country.code}'),
          options: MapOptions(
            initialCenter: center,
            initialZoom: 4.8,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.countries_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 80,
                  height: 80,
                  child: Container(
                    key: ValueKey('country-map-marker-${country.code}'),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ),
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
