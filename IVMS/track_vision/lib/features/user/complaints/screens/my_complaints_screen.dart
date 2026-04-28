import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:track_vision/core/services/api_service.dart';
import 'package:track_vision/shared/providers/auth_notifier.dart';
import 'package:track_vision/shared/models/complaint_model.dart';
import 'package:track_vision/features/user/complaints/widgets/complaint_card.dart';
import 'package:track_vision/features/user/complaints/widgets/complaint_detail_modal.dart';

class MyComplaintsScreen extends ConsumerStatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  ConsumerState<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends ConsumerState<MyComplaintsScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<Complaint> _complaints = [];
  String? _error;

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
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
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

      // Call paginated API
      final response = await AuthServices.getComplaintsPaginated(
        page: _currentPage,
        limit: _limit,
        email: email,
      );

      if (!mounted) return;

      if (response['success']) {
        setState(() {
          _complaints = response['complaints'] as List<Complaint>;
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
      final authState = ref.read(authNotifierProvider);
      final email = authState.user?.email;

      if (email == null) return;

      final response = await AuthServices.getComplaintsPaginated(
        page: _currentPage + 1,
        limit: _limit,
        email: email,
      );

      if (!mounted) return;

      if (response['success']) {
        setState(() {
          _complaints.addAll(response['complaints'] as List<Complaint>);
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

  void _viewComplaintDetails(Complaint complaint) {
    showDialog(
      context: context,
      builder: (context) => ComplaintDetailModal(complaint: complaint.toJson()),
    );
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
            // Title and Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Complaints",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_total > 0)
                  Text(
                    'Total: $_total',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Content
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
                  : _complaints.isEmpty
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
                            'No complaints posted yet.',
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
                            _complaints.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _complaints.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final complaint = _complaints[index];
                          return ComplaintCard(
                            complaint: complaint.toJson(),
                            onView: (c) => _viewComplaintDetails(complaint),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
