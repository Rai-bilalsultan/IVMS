import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/shared/models/detection_model.dart';
import 'package:track_vision/shared/providers/data_providers.dart';
import 'package:track_vision/features/admin/vehicles/widgets/detection_details.dart';
import 'package:track_vision/core/config/constants.dart';
import 'package:intl/intl.dart';

class VehicleDetectionTable extends ConsumerStatefulWidget {
  final int limit;

  const VehicleDetectionTable({super.key, this.limit = 10});

  @override
  ConsumerState<VehicleDetectionTable> createState() =>
      _VehicleDetectionTableState();
}

class _VehicleDetectionTableState extends ConsumerState<VehicleDetectionTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = false;
  List<Detection> _sortedDetections = [];

  void _sort<T>(
    Comparable<T> Function(Detection d) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortedDetections.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final detectionsAsync = ref.watch(detectionsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: detectionsAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(50.0),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load detections',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  style: const TextStyle(color: Colors.red),
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
        ),
        data: (detections) {
          if (detections.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No vehicle detections yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Initialize sorted list if empty
          if (_sortedDetections.isEmpty) {
            _sortedDetections = detections.take(widget.limit).toList()
              ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
          }

          return Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Vehicle Detections',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      'Total: ${detections.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Data Table
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  headingRowColor: MaterialStateProperty.all(
                    AppColors.primaryBlue.withOpacity(0.1),
                  ),
                  columns: [
                    DataColumn(
                      label: const Text(
                        'ID',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onSort: (columnIndex, ascending) {
                        _sort<num>((d) => d.id, columnIndex, ascending);
                      },
                    ),
                    DataColumn(
                      label: const Text(
                        'Device ID',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onSort: (columnIndex, ascending) {
                        _sort<String>(
                          (d) => d.deviceId ?? '',
                          columnIndex,
                          ascending,
                        );
                      },
                    ),
                    DataColumn(
                      label: const Text(
                        'Location',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onSort: (columnIndex, ascending) {
                        _sort<String>(
                          (d) => d.locationText ?? '',
                          columnIndex,
                          ascending,
                        );
                      },
                    ),
                    DataColumn(
                      label: const Text(
                        'Detected At',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onSort: (columnIndex, ascending) {
                        _sort<DateTime>(
                          (d) => d.detectedAt,
                          columnIndex,
                          ascending,
                        );
                      },
                    ),
                    const DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'Actions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: _sortedDetections.map((detection) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            '#${detection.id}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              detection.deviceId ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                detection.locationText ?? 'Unknown',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatDateTime(detection.detectedAt),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue, width: 1),
                            ),
                            child: const Text(
                              'DETECTED',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(
                              Icons.visibility,
                              color: AppColors.primaryBlue,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetectionDetailPage(detection),
                                ),
                              );
                            },
                            tooltip: 'View Details',
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // Footer
              if (detections.length > widget.limit)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextButton.icon(
                    onPressed: () {
                      // Navigate to full vehicles screen
                      Navigator.pushNamed(context, '/admin-vehicles/');
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('View All Detections'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
