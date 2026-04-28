import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_vision/shared/providers/data_providers.dart';
import 'package:track_vision/shared/providers/providers.dart';
import 'package:track_vision/core/config/constants.dart';
import 'package:track_vision/core/services/websocket_service.dart';
import 'package:track_vision/features/user/alerts/screens/alert_details_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserAlerts extends ConsumerStatefulWidget {
  const UserAlerts({super.key});

  @override
  ConsumerState<UserAlerts> createState() => _UserAlertsState();
}

class _UserAlertsState extends ConsumerState<UserAlerts> {
  List<dynamic> _alerts = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize WebSocket asynchronously (non-blocking)
    Future.microtask(() => _initializeWebSocket());
  }

  void _initializeWebSocket() {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.user?.email;

    if (userId != null && !_isInitialized) {
      try {
        // Connect to WebSocket for real-time alerts
        webSocketService.connectToAlerts(userId: userId, isAdmin: false);

        // Listen to WebSocket stream
        webSocketService.alertsStream.listen(
          (newAlert) {
            if (mounted) {
              setState(() {
                _alerts.insert(0, newAlert);
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
        // Continue without WebSocket - app will still work with API polling
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
            // Title with WebSocket status indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Alerts",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // WebSocket connection indicator
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
                  if (alerts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No alerts available.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Combine API alerts with real-time WebSocket alerts
                  final combinedAlerts = [..._alerts, ...alerts];
                  // Remove duplicates by ID if available
                  final uniqueAlerts = <dynamic>[];
                  final seenIds = <int>{};
                  for (var alert in combinedAlerts) {
                    final id = alert['id'];
                    if (id == null || !seenIds.contains(id)) {
                      uniqueAlerts.add(alert);
                      if (id != null) seenIds.add(id);
                    }
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(alertsProvider);
                      setState(() {
                        _alerts.clear(); // Clear WebSocket alerts on refresh
                      });
                    },
                    child: ListView.builder(
                      itemCount: uniqueAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = uniqueAlerts[index];
                        return _buildAlertCard(alert);
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

  Widget _buildAlertCard(dynamic alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert Message
            Text(
              alert['message'] ?? alert['alertMessage'] ?? 'No message',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            // Alert Image (if available)
            if (alert['image'] != null || alert['alertImage'] != null)
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade300,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'http://localhost:8000${alert['image'] ?? alert['alertImage']}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  alert['sentAt'] != null || alert['timestamp'] != null
                      ? timeago.format(
                          DateTime.parse(alert['sentAt'] ?? alert['timestamp']),
                        )
                      : 'Unknown time',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                // View Detail Button
                TextButton(
                  onPressed: () {
                    // Navigate to alert details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlertDetailsScreen(alert: alert),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                  ),
                  child: const Text('View Detail'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
