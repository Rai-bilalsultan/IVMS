import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/shared/providers/data_providers.dart';
import 'package:track_vision/features/common/screens/detection_details_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class DetectionsPage extends ConsumerStatefulWidget {
  const DetectionsPage({super.key});

  @override
  ConsumerState<DetectionsPage> createState() => _DetectionsPageState();
}

class _DetectionsPageState extends ConsumerState<DetectionsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final detectionsAsync = ref.watch(detectionsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('Detections'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by plate, model, or location...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Detections Grid
            Expanded(
              child: detectionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      ),
                      const SizedBox(height: 10),
                      Text('Error: $err'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(detectionsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (detections) {
                  // Filter detections
                  var filtered = detections.where((d) {
                    final matchesSearch =
                        _searchQuery.isEmpty ||
                        (d.plateNumber?.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ??
                            false) ||
                        (d.vehicleModel?.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ??
                            false) ||
                        (d.location?.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ??
                            false);
                    return matchesSearch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No detections found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(detectionsProvider);
                    },
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final detection = filtered[index];
                        return Card(
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetectionDetailsPage(
                                    detection: detection,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: detection.image != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  detection.image!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        color: detection.image == null
                                            ? Colors.grey.shade300
                                            : null,
                                      ),
                                      child: detection.image == null
                                          ? const Icon(
                                              Icons.directions_car,
                                              size: 40,
                                              color: Colors.grey,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Info
                                  Text(
                                    'Plate: ${detection.plateNumber ?? "Unknown"}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Model: ${detection.vehicleModel ?? "N/A"}',
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Color: ${detection.vehicleColor ?? "N/A"}',
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Status: ${detection.status ?? "Detected"}',
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Location: ${detection.location ?? "N/A"}',
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Owner: ${detection.ownerName ?? "N/A"}',
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    timeago.format(detection.detectedAt),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
