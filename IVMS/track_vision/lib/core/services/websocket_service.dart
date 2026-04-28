import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class WebSocketService {
  static const String baseUrl = "ws://10.0.2.2:8000";

  WebSocketChannel? _channel;
  final _alertsController = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnected = false;
  String? _userId;
  bool _isAdmin = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;

  // Getters
  Stream<Map<String, dynamic>> get alertsStream => _alertsController.stream;
  bool get isConnected => _isConnected;

  /// Connect to WebSocket for alerts
  /// [userId] - Email or user ID for user-specific alerts
  /// [isAdmin] - Set to true for admin alerts channel
  void connectToAlerts({String? userId, bool isAdmin = false}) {
    if (_isConnected) {
      debugPrint('WebSocket already connected');
      return;
    }

    // Prevent too many reconnection attempts
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max WebSocket reconnection attempts reached. Skipping.');
      return;
    }

    _userId = userId;
    _isAdmin = isAdmin;

    try {
      // Construct WebSocket URL based on role
      String wsUrl;
      if (isAdmin) {
        wsUrl = '$baseUrl/ws/alerts/admin/';
      } else if (userId != null) {
        wsUrl = '$baseUrl/ws/alerts/$userId/';
      } else {
        debugPrint('Error: userId required for user alerts');
        return;
      }

      debugPrint(
        'Connecting to WebSocket: $wsUrl (attempt ${_reconnectAttempts + 1})',
      );

      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        // Add timeout to prevent hanging
      );
      _isConnected = true;
      _reconnectAttempts = 0; // Reset on successful connection

      // Listen to messages
      _channel!.stream
          .timeout(
            const Duration(seconds: 10),
            onTimeout: (sink) {
              debugPrint('WebSocket connection timeout');
              sink.close();
            },
          )
          .listen(
            (message) {
              try {
                final data = jsonDecode(message);
                debugPrint('WebSocket message received: $data');
                _alertsController.add(data);
              } catch (e) {
                debugPrint('Error parsing WebSocket message: $e');
              }
            },
            onError: (error) {
              debugPrint('WebSocket error: $error');
              _isConnected = false;
              _reconnectAttempts++;
              // Don't auto-reconnect if backend is down
              if (_reconnectAttempts < _maxReconnectAttempts) {
                _reconnect();
              }
            },
            onDone: () {
              debugPrint('WebSocket connection closed');
              _isConnected = false;
            },
            cancelOnError: true,
          );

      debugPrint('WebSocket connected successfully');
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
      _isConnected = false;
      _reconnectAttempts++;
    }
  }

  /// Reconnect to WebSocket after disconnect
  void _reconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnection attempts reached. WebSocket disabled.');
      return;
    }

    if (_userId != null || _isAdmin) {
      debugPrint('Attempting to reconnect WebSocket in 5 seconds...');
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isConnected && _reconnectAttempts < _maxReconnectAttempts) {
          connectToAlerts(userId: _userId, isAdmin: _isAdmin);
        }
      });
    }
  }

  /// Send message through WebSocket
  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
      debugPrint('WebSocket message sent: $message');
    } else {
      debugPrint('Cannot send message: WebSocket not connected');
    }
  }

  /// Disconnect from WebSocket
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    _isConnected = false;
    debugPrint('WebSocket disconnected');
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _alertsController.close();
  }
}

// Singleton instance
final webSocketService = WebSocketService();
