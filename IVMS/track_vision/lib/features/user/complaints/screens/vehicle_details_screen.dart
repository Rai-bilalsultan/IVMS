import 'package:flutter/material.dart';
import 'package:track_vision/core/config/constants.dart';
import 'package:track_vision/core/services/api_service.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final int complaintId;

  const VehicleDetailsScreen({super.key, required this.complaintId});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _complaint;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchComplaintDetails();
  }

  Future<void> _fetchComplaintDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final complaint = await AuthServices.getComplaintById(widget.complaintId);

      setState(() {
        _complaint = complaint;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch vehicle details: $e';
        _isLoading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Vehicle Details'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(_error!),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _fetchComplaintDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _complaint == null
          ? const Center(child: Text('No vehicle found.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          _complaint!['status'] ?? 'pending',
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (_complaint!['status'] ?? 'PENDING')
                            .toString()
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(
                            _complaint!['status'] ?? 'pending',
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Vehicle Information Card
                  _buildCard(
                    title: 'Vehicle Information',
                    children: [
                      _buildInfoRow(
                        'Make',
                        _complaint!['vehicleMake'] ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Model',
                        _complaint!['vehicleModel'] ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Variant',
                        _complaint!['vehicleVariant'] ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Color',
                        _complaint!['vehicleColor'] ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Plate No',
                        _complaint!['plateNumber'] ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Chassis No',
                        _complaint!['chassisNumber'] ?? 'N/A',
                      ),

                      // Vehicle Image
                      if (_complaint!['vehiclePicture'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade300,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                'http://localhost:8000${_complaint!['vehiclePicture']}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Owner Details Card
                  _buildCard(
                    title: 'Owner Details',
                    children: [
                      _buildInfoRow('Name', _complaint!['ownerName'] ?? 'N/A'),
                      _buildInfoRow(
                        'Email',
                        _complaint!['ownerEmail'] ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Phone',
                        _complaint!['ownerPhone'] ?? 'N/A',
                      ),
                      _buildInfoRow('CNIC', _complaint!['ownerCnic'] ?? 'N/A'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Complaint Details Card
                  _buildCard(
                    title: 'Complaint Details',
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _complaint!['complaintDescription'] ??
                              'No description provided',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildInfoRow(
                        'Submitted At',
                        _complaint!['submittedAt'] ??
                            _complaint!['createdAt'] ??
                            'N/A',
                      ),
                      _buildInfoRow(
                        'Complaint ID',
                        _complaint!['id']?.toString() ?? 'N/A',
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
