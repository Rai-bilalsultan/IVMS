import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:track_vision/core/config/constants.dart';
import 'package:track_vision/shared/providers/data_providers.dart';

class OverviewCards extends ConsumerStatefulWidget {
  const OverviewCards({super.key});

  @override
  ConsumerState<OverviewCards> createState() => _OverviewCardsState();
}

class _OverviewCardsState extends ConsumerState<OverviewCards> {
  @override
  Widget build(BuildContext context) {
    final complaintsAsync = ref.watch(complaintsProvider);
    final unreadCountAsync = ref.watch(unreadAlertsCountProvider);

    return complaintsAsync.when(
      loading: () => Container(
        height: 120,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, st) => Container(
        height: 120,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('Error: $err')),
      ),
      data: (complaints) {
        final totalComplaints = complaints.length;
        final investigating = complaints
            .where((c) => c.status == 'investigating')
            .length;
        final resolved = complaints.where((c) => c.status == 'resolved').length;

        final cardsList = [
          CardInfo(
            icon: Icons.description_outlined,
            title: "Total Reports",
            count: totalComplaints,
          ),
          CardInfo(
            icon: Icons.search_outlined,
            title: "Pending",
            count: investigating,
          ),
          CardInfo(
            icon: Icons.check_circle_outline,
            title: "Resolved",
            count: resolved,
          ),
          CardInfo(
            icon: Icons.notifications_active_outlined,
            title: "Unread Alerts",
            count: unreadCountAsync.maybeWhen(
              data: (count) => count,
              orElse: () => 0,
            ),
          ),
        ];

        return Container(
          height: 120,
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: cardsList.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            cacheExtent: 300,
            itemBuilder: (context, index) {
              final card = cardsList[index];
              return RepaintBoundary(
                child: Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Icon(card.icon, color: Colors.white, size: 35),
                      ),
                      const SizedBox(width: 15),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              card.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              card.count.toString(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// cards info class
class CardInfo {
  final IconData icon;
  final String title;
  final int count;

  CardInfo({required this.icon, required this.title, required this.count});
}
