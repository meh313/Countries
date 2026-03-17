import '../../domain/entities/country.dart';

/// Raw transport representation of a country entry loaded from JSON.
class CountryDto {
  /// Creates a DTO instance.
  const CountryDto({
    required this.code,
    required this.name,
    required this.capital,
    required this.flagAssetOrUrl,
    required this.latitude,
    required this.longitude,
    this.region,
  });

  /// Creates a DTO from JSON.
  factory CountryDto.fromJson(Map<String, dynamic> json) {
    return CountryDto(
      code: json['code'] as String,
      name: json['name'] as String,
      capital: json['capital'] as String,
      flagAssetOrUrl: json['flagAssetOrUrl'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      region: json['region'] as String?,
    );
  }

  /// Stable country code.
  final String code;

  /// Country display name.
  final String name;

  /// Capital city.
  final String capital;

  /// Flag asset path or URL.
  final String flagAssetOrUrl;

  /// Latitude for the map center.
  final double latitude;

  /// Longitude for the map center.
  final double longitude;

  /// Optional region label.
  final String? region;

  /// Converts the DTO into the domain entity.
  Country toDomain() {
    return Country(
      code: code,
      name: name,
      capital: capital,
      flagAssetOrUrl: flagAssetOrUrl,
      latitude: latitude,
      longitude: longitude,
      region: region,
    );
  }
}
