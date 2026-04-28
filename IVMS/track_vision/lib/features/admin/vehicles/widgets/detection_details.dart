import 'package:flutter/material.dart';
import 'package:track_vision/shared/models/detection_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class DetectionDetailPage extends StatelessWidget {
  final Detection detection;
  const DetectionDetailPage(this.detection, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car image
            if (detection.image != null)
              Container(
                height: 180,
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
                height: 180,
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

            // Detection Details
            _buildInfoCard('Plate Number', detection.plateNumber ?? 'Unknown'),
            _buildInfoCard('Vehicle Model', detection.vehicleModel ?? 'N/A'),
            _buildInfoCard('Vehicle Color', detection.vehicleColor ?? 'N/A'),
            _buildInfoCard('Status', detection.status ?? 'Detected'),
            _buildInfoCard('Location', detection.location ?? 'N/A'),
            _buildInfoCard('Owner Name', detection.ownerName ?? 'N/A'),
            _buildInfoCard('Owner Email', detection.ownerEmail ?? 'N/A'),
            if (detection.latitude != null && detection.longitude != null)
              _buildInfoCard(
                'Coordinates',
                '${detection.latitude}, ${detection.longitude}',
              ),

            const SizedBox(height: 20),

            // Timestamps
            const Text(
              "Detection Time:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInfoCard('Detected At', detection.detectedAt.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
