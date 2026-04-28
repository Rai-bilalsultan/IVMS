import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/shared/providers/data_providers.dart';
import 'package:track_vision/core/services/websocket_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:track_vision/core/config/constants.dart';

class AdminAlerts extends ConsumerStatefulWidget {
  const AdminAlerts({super.key});

  @override
  ConsumerState<AdminAlerts> createState() => _AdminAlertsState();
}

class _AdminAlertsState extends ConsumerState<AdminAlerts> {
  String _filterType = 'all';
  List<dynamic> _webSocketAlerts = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize WebSocket asynchronously (non-blocking)
    Future.microtask(() => _initializeWebSocket());
  }

  void _initializeWebSocket() {
    if (!_isInitialized) {
      try {
        // Connect to admin WebSocket channel
        webSocketService.connectToAlerts(isAdmin: true);

        // Listen to WebSocket stream for real-time alerts
        webSocketService.alertsStream.listen(
          (newAlert) {
            if (mounted) {
              setState(() {
                _webSocketAlerts.insert(0, newAlert);
              });
            }
          },
          onError: (error) {
            debugPrint('WebSocket stream error: $error');
          },
        );

        _isInitialized = true;
      } catch (e) {
        debugPrint('Failed to initialize WebSocket: $e');
        // Continue without WebSocket - app will still work with polling
      }
    }
  }

  @override
  void dispose() {
    // Don't disconnect WebSocket here as it may be used by other screens
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "System Alerts",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // WebSocket status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: webSocketService.isConnected
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: webSocketService.isConnected
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            webSocketService.isConnected ? 'Live' : 'Offline',
                            style: TextStyle(
                              fontSize: 10,
                              color: webSocketService.isConnected
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Mark all as read button
                    TextButton.icon(
                      onPressed: () async {
                        // TODO: Implement mark all as read API endpoint
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Marked all as read')),
                        );
                        ref.invalidate(alertsProvider);
                      },
                      icon: const Icon(Icons.done_all),
                      label: const Text('Mark all read'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter Bar
            Row(
              children: [
                const Text('Filter: '),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _filterType,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Alerts')),
                    DropdownMenuItem(value: 'unread', child: Text('Unread')),
                    DropdownMenuItem(
                      value: 'critical',
                      child: Text('Critical'),
                    ),
                    DropdownMenuItem(value: 'warning', child: Text('Warning')),
                    DropdownMenuItem(value: 'info', child: Text('Info')),
                  ],
                  onChanged: (value) => setState(() => _filterType = value!),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Alerts List
            Expanded(
              child: alertsAsync.when(
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
                        onPressed: () => ref.invalidate(alertsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (alerts) {
                  // Filter alerts
                  var filtered = alerts.where((alert) {
                    if (_filterType == 'all') return true;
                    if (_filterType == 'unread') return !alert.isRead;
                    return alert.alertType == _filterType;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No alerts found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(alertsProvider);
                      setState(() {
                        _webSocketAlerts.clear();
                      });
                    },
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final alert = filtered[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: alert.isRead ? 1 : 3,
                          color: alert.isRead
                              ? Colors.white
                              : Colors.blue.shade50,
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getAlertColor(alert.alertType),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getAlertIcon(alert.alertType),
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    alert.alertMessage,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: alert.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (!alert.isRead)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(timeago.format(alert.sentAt)),
                                Text(
                                  'Detection ID: ${alert.detectionId}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(
                                alert.alertType,
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: _getAlertColor(
                                alert.alertType,
                              ).withOpacity(0.3),
                            ),
                            onTap: () {
                              // TODO: Mark as read and show details
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(alert.alertType.toUpperCase()),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(alert.alertMessage),
                                      const SizedBox(height: 10),
                                      Text('Sent At: ${alert.sentAt}'),
                                      Text(
                                        'Detection ID: ${alert.detectionId}',
                                      ),
                                      Text(
                                        'Read: ${alert.isRead ? "Yes" : "No"}',
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
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

  Color _getAlertColor(String type) {
    switch (type) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}
