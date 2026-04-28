class UnknownVehicle {
  final int id;
  final String? vehicleColor;
  final DateTime detectedAt;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? image;

  UnknownVehicle({
    required this.id,
    this.vehicleColor,
    required this.detectedAt,
    this.location,
    this.latitude,
    this.longitude,
    this.image,
  });

  factory UnknownVehicle.fromJson(Map<String, dynamic> json) {
    return UnknownVehicle(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      vehicleColor: json['vehicleColor'] as String?,
      detectedAt: json['detectedAt'] != null
          ? DateTime.parse(json['detectedAt'] as String)
          : DateTime.now(),
      location: json['location'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleColor': vehicleColor,
      'detectedAt': detectedAt.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'image': image,
    };
  }
}
