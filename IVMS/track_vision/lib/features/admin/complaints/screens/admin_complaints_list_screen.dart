import 'package:flutter/material.dart';
import 'package:track_vision/core/config/constants.dart';
import 'package:track_vision/core/services/api_service.dart';
import 'package:track_vision/shared/models/complaint_model.dart';
import 'package:track_vision/features/user/complaints/widgets/complaint_detail_modal.dart';

class AdminComplaintsListScreen extends StatefulWidget {
  const AdminComplaintsListScreen({super.key});

  @override
  State<AdminComplaintsListScreen> createState() =>
      _AdminComplaintsListScreenState();
}

class _AdminComplaintsListScreenState extends State<AdminComplaintsListScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<Complaint> _complaints = [];
  List<Complaint> _filteredComplaints = [];
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  // Pagination variables
  int _currentPage = 1;
  int _totalPages = 1;
  int _limit = 10;
  int _total = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoadingMore &&
          _currentPage < _totalPages &&
          _searchController.text.isEmpty) {
        _loadMoreComplaints();
      }
    }
  }

  Future<void> _fetchComplaints() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
    });

    try {
      // Call paginated API (admin sees all complaints)
      final response = await AuthServices.getComplaintsPaginated(
        page: _currentPage,
        limit: _limit,
      );

      if (!mounted) return;

      if (response['success']) {
        setState(() {
          _complaints = response['complaints'] as List<Complaint>;
          _filteredComplaints = _complaints;
          _total = response['total'];
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

  Future<void> _loadMoreComplaints() async {
    if (_isLoadingMore || !mounted) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await AuthServices.getComplaintsPaginated(
        page: _currentPage + 1,
        limit: _limit,
      );

      if (!mounted) return;

      if (response['success']) {
        setState(() {
          _complaints.addAll(response['complaints'] as List<Complaint>);
          _filteredComplaints = _complaints;
          _currentPage = response['page'];
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _filterComplaints(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredComplaints = _complaints;
      } else {
        _filteredComplaints = _complaints.where((complaint) {
          final id = complaint.id.toString().toLowerCase();
          final plateNumber = complaint.plateNumber.toLowerCase();
          final ownerName = complaint.ownerName.toLowerCase();
          final searchLower = query.toLowerCase();

          return id.contains(searchLower) ||
              plateNumber.contains(searchLower) ||
              ownerName.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthServices.updateComplaintStatus(id, status);
      await _fetchComplaints();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $status'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewComplaintDetails(Complaint complaint) {
    showDialog(
      context: context,
      builder: (context) => ComplaintDetailModal(complaint: complaint.toJson()),
    );
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Complaints Management",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_total > 0)
                  Text(
                    'Total: $_total | Showing: ${_filteredComplaints.length}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
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
              child: TextField(
                controller: _searchController,
                onChanged: _filterComplaints,
                decoration: const InputDecoration(
                  hintText: 'Search by ID, Plate Number, or Name',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Complaints List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 50,
                          ),
                          const SizedBox(height: 10),
                          Text(_error!),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _fetchComplaints,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _filteredComplaints.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No complaints found.'
                                : 'No matching complaints found.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchComplaints,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            _filteredComplaints.length +
                            (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredComplaints.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final complaint = _filteredComplaints[index];
                          return _buildComplaintCard(complaint);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    final status = complaint.status;
    final plateNumber = complaint.plateNumber;
    final ownerName = complaint.ownerName;
    final vehicleMake = complaint.vehicleMake;
    final vehicleModel = complaint.vehicleModel;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ID & Plate Number
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${complaint.id}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        plateNumber,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),

                // Status Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButton<String>(
                    value: status,
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('PENDING'),
                      ),
                      DropdownMenuItem(
                        value: 'investigating',
                        child: Text('INVESTIGATING'),
                      ),
                      DropdownMenuItem(
                        value: 'resolved',
                        child: Text('RESOLVED'),
                      ),
                      DropdownMenuItem(value: 'closed', child: Text('CLOSED')),
                    ],
                    onChanged: (newStatus) {
                      if (newStatus != null) {
                        _updateStatus(complaint.id, newStatus);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Vehicle & Owner Info
            Text(
              '$vehicleMake $vehicleModel',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Owner: $ownerName',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 12),

            // View Details Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _viewComplaintDetails(complaint),
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
    );
  }
}
