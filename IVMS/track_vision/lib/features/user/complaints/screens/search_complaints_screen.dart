import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/core/config/constants.dart';
import 'package:track_vision/core/services/api_service.dart';
import 'package:track_vision/shared/models/complaint_model.dart';
import 'package:track_vision/shared/providers/providers.dart';
import 'package:track_vision/features/user/complaints/widgets/complaint_card.dart';
import 'package:track_vision/features/user/complaints/widgets/complaint_detail_modal.dart';

class SearchComplaintsScreen extends ConsumerStatefulWidget {
  const SearchComplaintsScreen({super.key});

  @override
  ConsumerState<SearchComplaintsScreen> createState() =>
      _SearchComplaintsScreenState();
}

class _SearchComplaintsScreenState
    extends ConsumerState<SearchComplaintsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<Complaint> _searchResults = [];
  String? _error;
  String? _successMessage;
  bool _hasSearched = false;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _limit = 10;
  int _total = 0;

  @override
  void initState() {
    super.initState();
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
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadMoreResults();
      }
    }
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      if (!mounted) return;

      setState(() {
        _error = 'Please enter Plate Number, CNIC, or Chassis Number.';
        _successMessage = null;
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      _hasSearched = true;
      _currentPage = 1;
    });

    try {
      final authState = ref.read(authNotifierProvider);
      final userRole = authState.user?.role ?? 'user';
      final userEmail = authState.user?.email;

      final response = await AuthServices.searchComplaintsPaginated(
        query: query,
        page: _currentPage,
        limit: _limit,
        role: userRole,
        email: userRole != 'admin' ? userEmail : null,
      );

      if (!mounted) return;

      if (response['success']) {
        setState(() {
          _searchResults = response['complaints'] as List<Complaint>;
          _total = response['total'];
          _totalPages = response['totalPages'];
          _currentPage = response['page'];
          _isLoading = false;
          if (_searchResults.isNotEmpty) {
            _successMessage = 'Found $_total result(s).';
          } else {
            _error = 'No matching complaints found.';
          }
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Search failed';
          _isLoading = false;
          _searchResults = [];
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Search failed: $e';
        _isLoading = false;
        _searchResults = [];
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoadingMore || !mounted) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final query = _searchController.text.trim();
      final authState = ref.read(authNotifierProvider);
      final userRole = authState.user?.role ?? 'user';
      final userEmail = authState.user?.email;

      final response = await AuthServices.searchComplaintsPaginated(
        query: query,
        page: _currentPage + 1,
        limit: _limit,
        role: userRole,
        email: userRole != 'admin' ? userEmail : null,
      );

      if (!mounted) return;

      if (response['success']) {
        setState(() {
          _searchResults.addAll(response['complaints'] as List<Complaint>);
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
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Search Complaints'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            const Text(
              'Search by Plate Number, CNIC, or Chassis Number',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),

            // Search Input
            Container(
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
                onSubmitted: (_) => _handleSearch(),
                decoration: InputDecoration(
                  hintText: 'Enter search query...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Search Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(
                  _isLoading ? 'Searching...' : 'Search',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Messages
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Results
            Expanded(
              child: _hasSearched && !_isLoading
                  ? _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No results found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                _searchResults.length +
                                (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _searchResults.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final complaint = _searchResults[index];
                              return ComplaintCard(
                                complaint: complaint.toJson(),
                                onView: (c) => _viewComplaintDetails(complaint),
                              );
                            },
                          )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Enter a search term to begin',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
