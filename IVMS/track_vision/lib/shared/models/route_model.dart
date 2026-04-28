class PredictionRoute {
  final int id;
  final int detectionId;
  final String routeName;
  final double probability;
  final List<Map<String, double>>? pathCoordinates;
  final DateTime createdAt;

  PredictionRoute({
    required this.id,
    required this.detectionId,
    required this.routeName,
    required this.probability,
    this.pathCoordinates,
    required this.createdAt,
  });

  factory PredictionRoute.fromJson(Map<String, dynamic> json) {
    List<Map<String, double>>? parseCoordinates(dynamic coords) {
      if (coords == null) return null;
      if (coords is List) {
        return List<Map<String, double>>.from(
          coords.map(
            (item) => {
              'latitude': double.tryParse(item['latitude'].toString()) ?? 0.0,
              'longitude': double.tryParse(item['longitude'].toString()) ?? 0.0,
            },
          ),
        );
      }
      return null;
    }

    return PredictionRoute(
      id: json['id'] ?? 0,
      detectionId: json['detection'] ?? json['detectionId'] ?? 0,
      routeName: json['routeName'] ?? '',
      probability: double.tryParse(json['probability'].toString()) ?? 0.0,
      pathCoordinates: parseCoordinates(json['pathCoordinates']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'detection': detectionId,
      'routeName': routeName,
      'probability': probability,
      'pathCoordinates': pathCoordinates,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
