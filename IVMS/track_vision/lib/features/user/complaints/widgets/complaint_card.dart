import 'package:flutter/material.dart';
import 'package:track_vision/core/config/constants.dart';

class ComplaintCard extends StatelessWidget {
  final dynamic complaint;
  final Function(dynamic) onView;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onView,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'investigating':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'investigating':
        return Icons.search;
      case 'resolved':
        return Icons.check_circle;
      case 'closed':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = complaint['status'] ?? 'pending';
    final plateNumber = complaint['plateNumber'] ?? 'N/A';
    final vehicleMake = complaint['vehicleMake'] ?? '';
    final vehicleModel = complaint['vehicleModel'] ?? '';
    final submittedAt =
        complaint['submittedAt'] ?? complaint['createdAt'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => onView(complaint),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Plate Number
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
                      plateNumber,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          size: 16,
                          color: _getStatusColor(status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Vehicle Info
              Text(
                '$vehicleMake $vehicleModel',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Complaint ID & Date
              Row(
                children: [
                  Icon(Icons.tag, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${complaint['id'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    submittedAt.isNotEmpty
                        ? submittedAt.substring(0, 10)
                        : 'N/A',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // View Details Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => onView(complaint),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
