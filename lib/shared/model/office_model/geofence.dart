class Geofence {
  final double lat;
  final double lng;
  final int radiusMeters;
  final String addressLabel;

  Geofence({
    required this.lat,
    required this.lng,
    required this.radiusMeters,
    required this.addressLabel,
  });

  factory Geofence.fromJson(Map<String, dynamic> json) {
    final center = json['center'] ?? {};
    return Geofence(
      lat: (center['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (center['lng'] as num?)?.toDouble() ?? 0.0,
      radiusMeters: json['radius_meters'] ?? 0,
      addressLabel: json['address_label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'center': {'lat': lat, 'lng': lng},
    'radius_meters': radiusMeters,
    'address_label': addressLabel,
  };
}
