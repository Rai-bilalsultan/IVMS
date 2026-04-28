import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/features/admin/vehicles/widgets/detection_details.dart';
import 'package:track_vision/features/common/screens/detections_page.dart';
import 'package:track_vision/shared/providers/data_providers.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:track_vision/core/config/constants.dart';

class DetectionSection extends ConsumerStatefulWidget {
  const DetectionSection({super.key});

  @override
  ConsumerState<DetectionSection> createState() => _DetectionSectionState();
}

class _DetectionSectionState extends ConsumerState<DetectionSection> {
  @override
  Widget build(BuildContext context) {
    final detectionsAsync = ref.watch(detectionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Latest Detections",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.only(top: 10),
          child: detectionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Error: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(detectionsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (detections) {
              if (detections.isEmpty) {
                return const Center(
                  child: Text(
                    'No detections yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              // Show latest 5 detections
              final latest = detections.take(5).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(detectionsProvider);
                },
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: latest.length,
                  cacheExtent: 100,
                  itemBuilder: (context, index) {
                    final detection = latest[index];
                    return RepaintBoundary(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetectionDetailPage(detection),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: const Icon(
                              Icons.directions_car_outlined,
                              size: 35,
                              color: AppColors.textLightMode,
                            ),
                          ),
                          title: Row(
                            children: [
                              const Text(
                                "Detection: ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('#${detection.id}'),
                            ],
                          ),
                          subtitle: Text(
                            timeago.format(detection.detectedAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DetectionsPage()),
              );
            },
            child: const Text('View All Detections'),
          ),
        ),
      ],
    );
  }
}
