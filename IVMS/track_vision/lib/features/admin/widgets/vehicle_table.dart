import 'package:flutter/material.dart';
import 'package:track_vision/core/config/constants.dart';

class VehicleTable extends StatelessWidget {
  final List<Map<String, dynamic>> vehicles;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const VehicleTable({
    super.key,
    required this.vehicles,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Vehicles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: isLoading ? null : onRefresh,
                  ),
              ],
            ),
          ),

          // Table Content
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (vehicles.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No vehicles detected yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Plate Number',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Vehicle Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Detected At',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                rows: vehicles.map((vehicle) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            vehicle['plateNumber'] ?? 'N/A',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Icon(
                              _getVehicleIcon(vehicle['vehicleType']),
                              size: 18,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(vehicle['vehicleType'] ?? 'Unknown'),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          _formatDateTime(vehicle['detectedAt']),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              vehicle['location'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      DataCell(_buildStatusChip(vehicle['status'])),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(String? vehicleType) {
    if (vehicleType == null) return Icons.directions_car;

    switch (vehicleType.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'truck':
        return Icons.local_shipping;
      case 'bus':
        return Icons.directions_bus;
      case 'motorcycle':
      case 'bike':
        return Icons.two_wheeler;
      case 'van':
        return Icons.airport_shuttle;
      default:
        return Icons.directions_car;
    }
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';

    try {
      final dt = dateTime is String
          ? DateTime.parse(dateTime)
          : dateTime as DateTime;
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours} hr ago';
      } else {
        return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return dateTime.toString();
    }
  }

  Widget _buildStatusChip(String? status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status?.toLowerCase()) {
      case 'detected':
      case 'new':
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        displayText = 'Detected';
        break;
      case 'alert':
      case 'warning':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        displayText = 'Alert';
        break;
      case 'stolen':
      case 'suspicious':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        displayText = status!;
        break;
      case 'cleared':
      case 'verified':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        displayText = status!;
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        displayText = status ?? 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
