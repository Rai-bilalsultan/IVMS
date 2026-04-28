import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/core/services/api_service.dart';
import 'package:track_vision/shared/providers/auth_notifier.dart';
import 'package:track_vision/core/config/constants.dart';

class DetailedComplaintsScreen extends ConsumerStatefulWidget {
  const DetailedComplaintsScreen({super.key});

  @override
  ConsumerState<DetailedComplaintsScreen> createState() =>
      _DetailedComplaintsScreenState();
}

class _DetailedComplaintsScreenState
    extends ConsumerState<DetailedComplaintsScreen> {
  bool _isLoading = true;
  List<dynamic> _complaints = [];
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authState = ref.read(authNotifierProvider);
      final email = authState.user?.email;

      if (email == null) {
        if (!mounted) return;
        setState(() {
          _error = 'User email not found';
          _isLoading = false;
        });
        return;
      }

      final response = await AuthServices.getComplaintsPaginated(
        page: _currentPage,
        limit: _limit,
        email: email,
      );

      if (!mounted) return;

      if (response['success']) {
        setState(() {
          _complaints = response['complaints'];
          _totalPages = response['totalPages'];
          _currentPage = response['page'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load complaints';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load complaints: $e';
        _isLoading = false;
      });
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
      _fetchComplaints();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _fetchComplaints();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                'My Complaints',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 40),

              // Content
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_error != null)
                Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 20),
                    Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                )
              else if (_complaints.isEmpty)
                Text(
                  'No complaints posted yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = _complaints[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: ListTile(
                          title: Text(
                            'Complaint #${complaint['id']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Plate: ${complaint['plateNumber'] ?? 'N/A'}',
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(complaint['status']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              complaint['status']?.toUpperCase() ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 30),

              // Pagination Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '$_currentPage of $_totalPages',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _currentPage < _totalPages
                        ? _goToNextPage
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Next', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'investigating':
      case 'under investigation':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
