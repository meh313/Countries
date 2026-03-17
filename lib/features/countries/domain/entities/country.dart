/// Canonical domain model shared by list, details, and future quiz flows.
class Country {
  /// Creates a country entity.
  const Country({
    required this.code,
    required this.name,
    required this.capital,
    required this.flagAssetOrUrl,
    required this.latitude,
    required this.longitude,
    this.region,
  });

  /// ISO-like code used as the stable identifier.
  final String code;

  /// Display name of the country.
  final String name;

  /// Capital city name used in both details and quiz features.
  final String capital;

  /// URL or local asset path for the flag.
  final String flagAssetOrUrl;

  /// Representative latitude for map focus.
  final double latitude;

  /// Representative longitude for map focus.
  final double longitude;

  /// Optional geographic region label.
  final String? region;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Country &&
        other.code == code &&
        other.name == name &&
        other.capital == capital &&
        other.flagAssetOrUrl == flagAssetOrUrl &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.region == region;
  }

  @override
  int get hashCode => Object.hash(
        code,
        name,
        capital,
        flagAssetOrUrl,
        latitude,
        longitude,
        region,
      );
}
