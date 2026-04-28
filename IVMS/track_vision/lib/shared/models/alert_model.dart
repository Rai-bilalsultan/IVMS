class Alert {
  final int id;
  final int detectionId;
  final String alertType; // vehicle_detected
  final String alertMessage;
  final String? alertImage;
  final DateTime sentAt;
  final bool isRead;

  Alert({
    required this.id,
    required this.detectionId,
    required this.alertType,
    required this.alertMessage,
    this.alertImage,
    required this.sentAt,
    required this.isRead,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] ?? 0,
      detectionId: json['detection'] ?? json['detectionId'] ?? 0,
      alertType: json['alertType'] ?? 'vehicle_detected',
      alertMessage: json['alertMessage'] ?? '',
      alertImage: json['alertImage'],
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'detection': detectionId,
      'alertType': alertType,
      'alertMessage': alertMessage,
      'alertImage': alertImage,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
