import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/core/config/constants.dart';
import 'package:track_vision/core/services/api_service.dart' show AuthServices;

class AlertDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> alert;

  const AlertDetailsScreen({super.key, required this.alert});

  @override
  ConsumerState<AlertDetailsScreen> createState() => _AlertDetailsScreenState();
}

class _AlertDetailsScreenState extends ConsumerState<AlertDetailsScreen> {
  bool _isMarking = false;
  late bool _isRead;

  @override
  void initState() {
    super.initState();
    _isRead = widget.alert['isRead'] ?? false;
    // Mark as read when the screen opens if it's unread
    if (!_isRead) {
      _markAsRead();
    }
  }

  Future<void> _markAsRead() async {
    if (_isMarking || _isRead) return;

    setState(() {
      _isMarking = true;
    });

    try {
      final alertId = widget.alert['id'];
      await AuthServices.markAlertAsRead(alertId);

      if (mounted) {
        setState(() {
          _isRead = true;
          _isMarking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMarking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark alert as read: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getAlertTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'red alert':
      case 'critical':
        return Colors.red;
      case 'yellow alert':
      case 'warning':
        return Colors.orange;
      case 'info':
      case 'information':
        return Colors.blue;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _getAlertTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'red alert':
      case 'critical':
        return Icons.error;
      case 'yellow alert':
      case 'warning':
        return Icons.warning;
      case 'info':
      case 'information':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertType = widget.alert['alertType'] ?? 'info';
    final message = widget.alert['message'] ?? 'No message';
    final timestamp = widget.alert['timestamp'] ?? 'Unknown time';
    final vehicleNumber = widget.alert['vehicleNumber'];
    final location = widget.alert['location'];
    final cameraName = widget.alert['cameraName'];
    final severity = widget.alert['severity'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Details'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (!_isRead && !_isMarking)
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: _markAsRead,
              tooltip: 'Mark as read',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert Type Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getAlertTypeColor(alertType).withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: _getAlertTypeColor(alertType),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getAlertTypeColor(alertType),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getAlertTypeIcon(alertType),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alertType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getAlertTypeColor(alertType),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timestamp,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_isRead)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Read',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Message Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            if (vehicleNumber != null ||
                location != null ||
                cameraName != null ||
                severity != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          if (vehicleNumber != null)
                            _buildDetailRow(
                              icon: Icons.directions_car,
                              label: 'Vehicle Number',
                              value: vehicleNumber,
                            ),
                          if (vehicleNumber != null && location != null)
                            Divider(height: 1, color: Colors.grey[300]),
                          if (location != null)
                            _buildDetailRow(
                              icon: Icons.location_on,
                              label: 'Location',
                              value: location,
                            ),
                          if (location != null && cameraName != null)
                            Divider(height: 1, color: Colors.grey[300]),
                          if (cameraName != null)
                            _buildDetailRow(
                              icon: Icons.videocam,
                              label: 'Camera',
                              value: cameraName,
                            ),
                          if (cameraName != null && severity != null)
                            Divider(height: 1, color: Colors.grey[300]),
                          if (severity != null)
                            _buildDetailRow(
                              icon: Icons.priority_high,
                              label: 'Severity',
                              value: severity,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
