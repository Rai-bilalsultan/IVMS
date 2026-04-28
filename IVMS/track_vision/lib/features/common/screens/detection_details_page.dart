import 'package:flutter/material.dart';
import 'package:track_vision/shared/models/detection_model.dart';

class DetectionDetailsPage extends StatelessWidget {
  final Detection detection;

  const DetectionDetailsPage({super.key, required this.detection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car image
            if (detection.image != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(detection.image!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade300,
                ),
                child: const Icon(
                  Icons.directions_car,
                  size: 80,
                  color: Colors.grey,
                ),
              ),

            const SizedBox(height: 20),

            // Details
            _buildDetailRow('Plate', detection.plateNumber ?? 'Unknown'),
            _buildDetailRow('Model', detection.vehicleModel ?? 'N/A'),
            _buildDetailRow('Color', detection.vehicleColor ?? 'N/A'),
            _buildDetailRow('Status', detection.status ?? 'Detected'),
            _buildDetailRow('Location', detection.location ?? 'N/A'),
            _buildDetailRow('Owner', detection.ownerName ?? 'N/A'),
            _buildDetailRow('Date', detection.detectedAt.toString()),

            const SizedBox(height: 20),

            // Map placeholder (would need google_maps_flutter package)
            if (detection.latitude != null && detection.longitude != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade300,
                ),
                child: Center(
                  child: Text(
                    'Map View\n(Latitude: ${detection.latitude}, Longitude: ${detection.longitude})',
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Routes (if available)
            if (detection.routes != null && detection.routes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Predicted Routes:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...detection.routes!.map(
                    (route) =>
                        Text('- Route ${detection.routes!.indexOf(route) + 1}'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
