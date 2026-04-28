class Detection {
  final int id;
  final int? complaintId;
  final String? deviceId;
  final String? locationText;
  final double? latitude;
  final double? longitude;
  final String? detectedImage;
  final DateTime detectedAt;

  // New fields from backend
  final String? plateNumber;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? status;
  final String? ownerName;
  final String? ownerEmail;
  final String? location;
  final String? image;
  final List<dynamic>? routes;

  Detection({
    required this.id,
    this.complaintId,
    this.deviceId,
    this.locationText,
    this.latitude,
    this.longitude,
    this.detectedImage,
    required this.detectedAt,
    this.plateNumber,
    this.vehicleModel,
    this.vehicleColor,
    this.status,
    this.ownerName,
    this.ownerEmail,
    this.location,
    this.image,
    this.routes,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      id: json['id'] ?? 0,
      complaintId: json['complaint'] ?? json['complaintId'],
      deviceId: json['deviceId'],
      locationText: json['locationText'] ?? json['location'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      detectedImage: json['detectedImage'] ?? json['image'],
      detectedAt: json['detectedAt'] != null
          ? DateTime.parse(json['detectedAt'])
          : DateTime.now(),
      plateNumber: json['plateNumber'],
      vehicleModel: json['vehicleModel'],
      vehicleColor: json['vehicleColor'],
      status: json['status'],
      ownerName: json['ownerName'],
      ownerEmail: json['ownerEmail'],
      location: json['location'] ?? json['locationText'],
      image: json['image'] ?? json['detectedImage'],
      routes: json['routes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint': complaintId,
      'deviceId': deviceId,
      'locationText': locationText,
      'latitude': latitude,
      'longitude': longitude,
      'detectedImage': detectedImage,
      'detectedAt': detectedAt.toIso8601String(),
      'plateNumber': plateNumber,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'status': status,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'location': location,
      'image': image,
      'routes': routes,
    };
  }
}
