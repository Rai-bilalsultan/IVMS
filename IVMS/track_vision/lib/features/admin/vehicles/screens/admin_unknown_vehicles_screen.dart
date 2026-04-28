import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:track_vision/core/config/constants.dart';
import 'package:track_vision/core/services/api_service.dart';
import 'package:track_vision/shared/providers/data_providers.dart';
import 'package:track_vision/shared/models/unknown_vehicle_model.dart';

class AdminUnknownVehiclesScreen extends ConsumerStatefulWidget {
  const AdminUnknownVehiclesScreen({super.key});

  @override
  ConsumerState<AdminUnknownVehiclesScreen> createState() =>
      _AdminUnknownVehiclesScreenState();
}

class _AdminUnknownVehiclesScreenState
    extends ConsumerState<AdminUnknownVehiclesScreen> {
  String _searchQuery = '';

  String _buildImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    final base = AuthServices.baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (path.startsWith('/')) {
      return '$base$path';
    }
    return '$base/$path';
  }

  @override
  Widget build(BuildContext context) {
    final unknownVehiclesAsync = ref.watch(unknownVehiclesProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unknown Vehicles',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by color, location, or coordinates...',
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
            Expanded(
              child: unknownVehiclesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Unable to load unknown vehicles',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(error.toString()),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(unknownVehiclesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (vehicles) {
                  final filtered = vehicles.where((vehicle) {
                    final query = _searchQuery.toLowerCase();
                    final colorMatch =
                        vehicle.vehicleColor?.toLowerCase().contains(query) ??
                        false;
                    final locationMatch =
                        vehicle.location?.toLowerCase().contains(query) ??
                        false;
                    final coordinatesMatch =
                        '${vehicle.latitude ?? ''}, ${vehicle.longitude ?? ''}'
                            .toLowerCase()
                            .contains(query);
                    return _searchQuery.isEmpty ||
                        colorMatch ||
                        locationMatch ||
                        coordinatesMatch;
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
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final unknown = filtered[index];
                        final imageUrl = _buildImageUrl(unknown.image);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.accentBlue,
                              child: Text(
                                unknown.vehicleColor
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              unknown.vehicleColor != null
                                  ? '${unknown.vehicleColor} vehicle'
                                  : 'Unknown vehicle',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(timeago.format(unknown.detectedAt)),
                                const SizedBox(height: 4),
                                Text(
                                  unknown.location ?? 'No location',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lat: ${unknown.latitude ?? '-'}, Lng: ${unknown.longitude ?? '-'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.directions_car,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.directions_car, size: 30),
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
