import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import 'package:track_vision/shared/providers/data_providers.dart';
import 'package:track_vision/shared/models/detection_model.dart';
import 'package:track_vision/core/config/constants.dart';

class VehicleMapPreview extends ConsumerStatefulWidget {
  final int limit;
  final double height;

  const VehicleMapPreview({super.key, this.limit = 20, this.height = 400});

  @override
  ConsumerState<VehicleMapPreview> createState() => _VehicleMapPreviewState();
}

class _VehicleMapPreviewState extends ConsumerState<VehicleMapPreview> {
  final MapController _mapController = MapController();
  Detection? _selectedDetection;

  List<Marker> _buildMarkers(List<Detection> detections) {
    return detections
        .take(widget.limit)
        .where((d) {
          return d.latitude != null && d.longitude != null;
        })
        .map((detection) {
          final isSelected = _selectedDetection?.id == detection.id;

          return Marker(
            point: LatLng(detection.latitude!, detection.longitude!),
            width: isSelected ? 50 : 40,
            height: isSelected ? 50 : 40,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDetection = detection;
                });
                _mapController.move(
                  LatLng(detection.latitude!, detection.longitude!),
                  14,
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow/Glow effect for selected marker
                  if (isSelected)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ),
                  // Marker icon
                  Icon(
                    Icons.location_pin,
                    size: isSelected ? 50 : 40,
                    color: isSelected ? Colors.red : AppColors.accentBlue,
                  ),
                  // Detection ID badge
                  if (isSelected)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red, width: 1),
                        ),
                        child: Text(
                          '#${detection.id}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final detectionsAsync = ref.watch(detectionsProvider);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: detectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load map data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(detectionsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (detections) {
          // Filter detections with valid coordinates
          final detectionsWithCoords = detections.where((d) {
            return d.latitude != null && d.longitude != null;
          }).toList();

          if (detectionsWithCoords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No detection locations available',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          // Calculate center point (average of all coordinates)
          final avgLat =
              detectionsWithCoords
                  .map((d) => d.latitude!)
                  .reduce((a, b) => a + b) /
              detectionsWithCoords.length;
          final avgLng =
              detectionsWithCoords
                  .map((d) => d.longitude!)
                  .reduce((a, b) => a + b) /
              detectionsWithCoords.length;

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(avgLat, avgLng),
                    initialZoom: 10,
                    minZoom: 5,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.track_vision',
                    ),
                    MarkerLayer(markers: _buildMarkers(detectionsWithCoords)),
                  ],
                ),

                // Map Controls Overlay
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: [
                      // Zoom In
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(
                            _mapController.camera.center,
                            currentZoom + 1,
                          );
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.add, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      // Zoom Out
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(
                            _mapController.camera.center,
                            currentZoom - 1,
                          );
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.remove, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      // Reset View
                      FloatingActionButton.small(
                        heroTag: 'reset_view',
                        onPressed: () {
                          _mapController.move(LatLng(avgLat, avgLng), 10);
                          setState(() {
                            _selectedDetection = null;
                          });
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Detection Info Card (when selected)
                if (_selectedDetection != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Detection #${_selectedDetection!.id}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDetection = null;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_selectedDetection!.deviceId != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.devices,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Device: ${_selectedDetection!.deviceId}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 4),
                            if (_selectedDetection!.locationText != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedDetection!.locationText!,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Legend
                Positioned(
                  top: 10,
                  left: 10,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_pin,
                                size: 20,
                                color: AppColors.accentBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${detectionsWithCoords.length} Detections',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
