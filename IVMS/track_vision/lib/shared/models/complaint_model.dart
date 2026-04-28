class Complaint {
  final int id;
  final String ownerName;
  final String ownerEmail;
  final String? ownerPhone;
  final String ownerCnic;

  // Vehicle Info
  final String vehicleMake;
  final String vehicleModel;
  final String? vehicleVariant;
  final String vehicleColor;
  final String plateNumber;
  final String? chassisNumber;
  final String? vehiclePicture;

  // Complaint Info
  final String complaintDescription;
  final String status; // investigating, resolved, closed
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.ownerName,
    required this.ownerEmail,
    this.ownerPhone,
    required this.ownerCnic,
    required this.vehicleMake,
    required this.vehicleModel,
    this.vehicleVariant,
    required this.vehicleColor,
    required this.plateNumber,
    this.chassisNumber,
    this.vehiclePicture,
    required this.complaintDescription,
    required this.status,
    required this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] ?? 0,
      ownerName: json['ownerName'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      ownerPhone: json['ownerPhone'],
      ownerCnic: json['ownerCnic'] ?? '',
      vehicleMake: json['vehicleMake'] ?? '',
      vehicleModel: json['vehicleModel'] ?? '',
      vehicleVariant: json['vehicleVariant'],
      vehicleColor: json['vehicleColor'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      chassisNumber: json['chassisNumber'],
      vehiclePicture: json['vehiclePicture'],
      complaintDescription: json['complaintDescription'] ?? '',
      status: json['status'] ?? 'investigating',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'ownerPhone': ownerPhone,
      'ownerCnic': ownerCnic,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleVariant': vehicleVariant,
      'vehicleColor': vehicleColor,
      'plateNumber': plateNumber,
      'chassisNumber': chassisNumber,
      'vehiclePicture': vehiclePicture,
      'complaintDescription': complaintDescription,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
