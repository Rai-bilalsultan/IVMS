import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/shared/providers/data_providers.dart';
import 'package:timeago/timeago.dart' as timeago;

class UnknownVehiclesPage extends ConsumerStatefulWidget {
  const UnknownVehiclesPage({super.key});

  @override
  ConsumerState<UnknownVehiclesPage> createState() =>
      _UnknownVehiclesPageState();
}

class _UnknownVehiclesPageState extends ConsumerState<UnknownVehiclesPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(unknownVehiclesProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('Unknown Vehicles'),
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
                hintText: 'Search by color or location...',
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

            // Vehicles Grid
            Expanded(
              child: vehiclesAsync.when(
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
                        onPressed: () =>
                            ref.invalidate(unknownVehiclesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (vehicles) {
                  // Filter vehicles
                  var filtered = vehicles.where((v) {
                    final matchesSearch =
                        _searchQuery.isEmpty ||
                        (v.vehicleColor?.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ??
                            false) ||
                        (v.location?.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ??
                            false);
                    return matchesSearch;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No unknown vehicles found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(unknownVehiclesProvider);
                    },
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final vehicle = filtered[index];
                        return Card(
                          elevation: 2,
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
                                      image: vehicle.image != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                vehicle.image!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: vehicle.image == null
                                          ? Colors.grey.shade300
                                          : null,
                                    ),
                                    child: vehicle.image == null
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
                                  'Color: ${vehicle.vehicleColor ?? "Unknown"}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Location: ${vehicle.location ?? "N/A"}',
                                  style: const TextStyle(fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  timeago.format(vehicle.detectedAt),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
