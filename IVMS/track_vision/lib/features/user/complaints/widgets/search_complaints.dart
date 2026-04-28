import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/features/auth/providers/user_provider.dart';
import 'package:track_vision/shared/providers/data_providers.dart';
import 'package:track_vision/core/config/constants.dart';

class UserComplainsSearch extends ConsumerStatefulWidget {
  const UserComplainsSearch({super.key});

  @override
  ConsumerState<UserComplainsSearch> createState() =>
      _UserComplainsSearchState();
}

class _UserComplainsSearchState extends ConsumerState<UserComplainsSearch> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaintsAsync = ref.watch(complaintsProvider);
    final searchQuery = ref.watch(complaintSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.textLightMode.withOpacity(0.5),
      appBar: AppBar(
        title: const Text('Search Complaints'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title text
            const Text(
              "Search Complaints",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by Plate, CNIC, Email...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                ref.read(complaintSearchQueryProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 20),
            // Complaints List
            Expanded(
              child: complaintsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, st) => Center(
                  child: Text('Error: $err'),
                ),
                data: (allComplaints) {
                  // Filter based on search query
                  final filtered = allComplaints.where((complaint) {
                    final query = searchQuery.toLowerCase();
                    return complaint.plateNumber.toLowerCase().contains(query) ||
                        complaint.ownerCnic.toLowerCase().contains(query) ||
                        complaint.ownerEmail.toLowerCase().contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        "No complaints found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final complaint = filtered[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  complaint.plateNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: complaint.status == 'resolved'
                                        ? Colors.green.shade100
                                        : complaint.status == 'investigating'
                                            ? Colors.orange.shade100
                                            : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    complaint.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: complaint.status == 'resolved'
                                          ? Colors.green
                                          : complaint.status == 'investigating'
                                              ? Colors.orange
                                              : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${complaint.vehicleMake} ${complaint.vehicleModel}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Owner: ${complaint.ownerName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'CNIC: ${complaint.ownerCnic}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

