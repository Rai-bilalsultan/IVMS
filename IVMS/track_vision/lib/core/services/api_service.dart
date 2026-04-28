import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:track_vision/core/config/api_config.dart';
import 'package:track_vision/shared/models/complaint_model.dart';
import 'package:track_vision/shared/models/detection_model.dart';
import 'package:track_vision/shared/models/alert_model.dart';
import 'package:track_vision/shared/models/route_model.dart';
import 'package:track_vision/shared/models/unknown_vehicle_model.dart';

// API Services with Automatic Fallback Detection
class AuthServices {
  // Automatic IP detection with fallbacks
  static String baseUrl = ApiConfig.baseUrl;
  static String? _token;
  static String? _userEmail;
  static bool _connectionTested = false;

  // Set token after login
  static void setToken(String token) {
    _token = token;
  }

  // Set user email (call this during login)
  static void setUserEmail(String email) {
    _userEmail = email;
  }

  // Get current user email
  static String? getUserEmail() {
    return _userEmail;
  }

  // Auto-detect working backend URL (cached for performance)
  static Future<String> _getWorkingUrl() async {
    // If already tested and working, reuse it
    if (_connectionTested) {
      return baseUrl;
    }

    // If manual IP is set, use it
    if (ApiConfig.manualDeviceIp != null) {
      baseUrl = "http://${ApiConfig.manualDeviceIp}";
      _connectionTested = true;
      return baseUrl;
    }

    // Try primary URL first
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200 || response.statusCode == 301) {
        _connectionTested = true;
        return baseUrl; // Primary URL works!
      }
    } catch (e) {
      print('Primary URL failed: $e');
    }

    // Try fallback URLs
    for (String fallbackUrl in ApiConfig.fallbackUrls) {
      try {
        final response = await http
            .get(Uri.parse('$fallbackUrl/'))
            .timeout(const Duration(seconds: 3));
        if (response.statusCode == 200 || response.statusCode == 301) {
          baseUrl = fallbackUrl;
          _connectionTested = true;
          print('✅ Connected to backend at: $baseUrl');
          return baseUrl; // Found working URL!
        }
      } catch (e) {
        print('Fallback URL $fallbackUrl failed, trying next...');
      }
    }

    // If nothing works, use primary (show error on next request)
    _connectionTested = true;
    print('❌ No backend found, using primary: $baseUrl');
    return baseUrl;
  }

  // Get request with auth header and auto-detection
  static Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final url = Uri.parse('${await _getWorkingUrl()}$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

      final res = await http
          .get(url, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      print('GET REQUEST to $endpoint');
      print('RESPONSE ${res.statusCode}: ${res.body}');

      try {
        final decoded = jsonDecode(res.body);
        if (res.statusCode >= 200 && res.statusCode < 300) {
          return {'success': true, 'data': decoded};
        } else {
          return {
            'success': false,
            'message': decoded['message'] ?? decoded.toString(),
          };
        }
      } catch (e) {
        return {'success': false, 'message': 'Parse error: $e'};
      }
    } catch (e) {
      print('GET Error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e. Make sure backend is running!',
      };
    }
  }

  static Future<Map<String, dynamic>> _post(String endpoint, Map body) async {
    try {
      final url = Uri.parse('${await _getWorkingUrl()}$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

      print('REQUEST to ${await _getWorkingUrl()}$endpoint: $body');

      final res = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      print('RESPONSE ${res.statusCode}: ${res.body}');

      try {
        final decoded = jsonDecode(res.body);
        if (res.statusCode >= 200 && res.statusCode < 300) {
          return {'success': true, 'data': decoded};
        } else {
          return {
            'success': false,
            'message': decoded['message'] ?? decoded.toString(),
          };
        }
      } catch (e) {
        return {'success': false, 'message': 'Response parse error: $e'};
      }
    } catch (e) {
      print('HTTP POST Error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e. Make sure backend is running!',
      };
    }
  }

  // ============= AUTH ENDPOINTS =============

  // LogIn
  static Future<Map<String, dynamic>> login(String email, String password) {
    return _post('/login/', {'email': email, 'password': password});
  }

  // SignUp for user
  static Future<Map<String, dynamic>> signupUser(Map<String, dynamic> payload) {
    return _post('/signup/', payload);
  }

  // SignUp for Admin
  static Future<Map<String, dynamic>> signupAdmin(
    Map<String, dynamic> payload,
  ) {
    return _post('/signup/', payload);
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) {
    return _post('/forgot-password/', {'email': email});
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) {
    return _post('/verify-otp/', {'email': email, 'otp': otp});
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String newPassword,
  ) {
    return _post('/reset-password/', {
      'email': email,
      'new_password': newPassword,
    });
  }

  // ============= COMPLAINT ENDPOINTS =============

  // Get all complaints
  static Future<List<Complaint>> getComplaints() async {
    try {
      final result = await _get('/complaints/');
      if (result['success']) {
        final data = result['data'];
        // Backend returns {complaints: [...]}
        if (data is Map && data['complaints'] != null) {
          final complaints = data['complaints'] as List;
          return complaints.map((item) => Complaint.fromJson(item)).toList();
        }
        // Fallback if it's already a list
        if (data is List) {
          return data.map((item) => Complaint.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print('Error fetching complaints: $e');
    }
    return [];
  }

  // Get user complaints
  static Future<List<dynamic>> getUserComplaints(String email) async {
    final result = await _get('/complaints/?email=$email');
    if (result['success']) {
      if (result['data'] is Map && result['data']['complaints'] != null) {
        return result['data']['complaints'] as List;
      }
      return result['data'] as List;
    }
    return [];
  }

  // Get all complaints (admin)
  static Future<List<dynamic>> getAllComplaints() async {
    final result = await _get('/complaints/all/');
    if (result['success']) {
      if (result['data'] is Map && result['data']['complaints'] != null) {
        return result['data']['complaints'] as List;
      }
      return result['data'] as List;
    }
    return [];
  }

  // Get single complaint
  static Future<Complaint?> getComplaint(int id) async {
    final result = await _get('/complaints/$id/');
    if (result['success']) {
      return Complaint.fromJson(result['data']);
    }
    return null;
  }

  // Get complaint by ID (returns dynamic for flexibility)
  static Future<Map<String, dynamic>?> getComplaintById(int id) async {
    final result = await _get('/complaints/$id/');
    if (result['success']) {
      return result['data'];
    }
    return null;
  }

  // Search complaints (Admin)
  static Future<List<dynamic>> searchComplaintForAdmin(String query) async {
    final result = await _get('/complaints/search/?q=$query&role=admin');
    if (result['success']) {
      if (result['data'] is Map && result['data']['data'] != null) {
        return result['data']['data'] as List;
      }
      return result['data'] as List;
    }
    return [];
  }

  // Search complaints (User)
  static Future<List<dynamic>> searchComplaintForUser(
    String query,
    String email,
  ) async {
    final result = await _get(
      '/complaints/search/?q=$query&role=user&email=$email',
    );
    if (result['success']) {
      if (result['data'] is Map && result['data']['data'] != null) {
        return result['data']['data'] as List;
      }
      return result['data'] as List;
    }
    return [];
  }

  // Mark alert as read
  static Future<Map<String, dynamic>> markAlertAsRead(int alertId) async {
    return _post('/alerts/$alertId/mark-read/', {});
  }

  // ============= PAGINATED COMPLAINT ENDPOINTS =============

  // Get complaints with pagination
  static Future<Map<String, dynamic>> getComplaintsPaginated({
    int page = 1,
    int limit = 10,
    String? email,
  }) async {
    String endpoint = '/complaints/?page=$page&limit=$limit';
    if (email != null && email.isNotEmpty) {
      endpoint += '&email=$email';
    }

    final result = await _get(endpoint);
    if (result['success']) {
      final data = result['data'];
      return {
        'success': true,
        'total': data['total'] ?? 0,
        'page': data['page'] ?? page,
        'limit': data['limit'] ?? limit,
        'totalPages': data['totalPages'] ?? 1,
        'complaints': (data['complaints'] as List)
            .map((item) => Complaint.fromJson(item))
            .toList(),
      };
    }
    return {
      'success': false,
      'message': result['message'] ?? 'Failed to fetch complaints',
      'complaints': <Complaint>[],
    };
  }

  // Search complaints with pagination
  static Future<Map<String, dynamic>> searchComplaintsPaginated({
    required String query,
    int page = 1,
    int limit = 10,
    String? role,
    String? email,
  }) async {
    String endpoint = '/complaints/search/?q=$query&page=$page&limit=$limit';
    if (role != null) {
      endpoint += '&role=$role';
    }
    if (email != null) {
      endpoint += '&email=$email';
    }

    final result = await _get(endpoint);
    if (result['success']) {
      final data = result['data'];
      return {
        'success': true,
        'total': data['total'] ?? 0,
        'page': data['page'] ?? page,
        'limit': data['limit'] ?? limit,
        'totalPages': data['totalPages'] ?? 1,
        'complaints': (data['complaints'] as List)
            .map((item) => Complaint.fromJson(item))
            .toList(),
      };
    }
    return {
      'success': false,
      'message': result['message'] ?? 'Failed to search complaints',
      'complaints': <Complaint>[],
    };
  }

  // Create complaint
  static Future<Map<String, dynamic>> createComplaint(Complaint complaint) {
    return _post('/complaints/register/', complaint.toJson());
  }

  // Update complaint
  static Future<Map<String, dynamic>> updateComplaint(
    int id,
    Map<String, dynamic> data,
  ) {
    return _post('/complaints/$id/', data);
  }

  // Update complaint status (admin)
  static Future<Map<String, dynamic>> updateComplaintStatus(
    int id,
    String status,
  ) async {
    final url = Uri.parse('$baseUrl/complaints/update-status/$id/');
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    final res = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    print(
      'PATCH REQUEST to /complaints/update-status/$id/: {"status": "$status"}',
    );
    print('RESPONSE ${res.statusCode}: ${res.body}');

    try {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {'success': true};
      } else {
        final decoded = jsonDecode(res.body);
        return {
          'success': false,
          'message': decoded['message'] ?? decoded.toString(),
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Parse error: $e'};
    }
  }

  // ============= DETECTION ENDPOINTS =============

  // Get detections for complaint
  static Future<List<Detection>> getDetections(int complaintId) async {
    final result = await _get('/complaints/$complaintId/detections/');
    if (result['success']) {
      final data = result['data'] as List;
      return data.map((item) => Detection.fromJson(item)).toList();
    }
    return [];
  }

  // Get unknown vehicles for admin users
  static Future<List<UnknownVehicle>> getUnknownVehicles(String role) async {
    final result = await _get('/unknown-vehicles/?role=$role');
    if (result['success']) {
      final data = result['data'];
      if (data is List) {
        return data
            .map(
              (item) => UnknownVehicle.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map(
              (item) => UnknownVehicle.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
    }
    return [];
  }

  // Create detection (when camera captures vehicle)
  static Future<Map<String, dynamic>> createDetection(Detection detection) {
    return _post('/detections/', detection.toJson());
  }

  // ============= ALERT ENDPOINTS =============

  // Get all alerts
  static Future<List<Alert>> getAlerts() async {
    try {
      final result = await _get('/alerts/');
      if (result['success']) {
        final data = result['data'];
        // Backend returns array directly
        if (data is List) {
          return data.map((item) => Alert.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print('Error fetching alerts: $e');
    }
    return [];
  }

  // Get unread alerts count
  static Future<int> getUnreadAlertsCount() async {
    try {
      // Backend doesn't have this endpoint, so calculate from alerts
      final alerts = await getAlerts();
      return alerts.where((alert) => !alert.isRead).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // ============= ROUTE PREDICTION ENDPOINTS =============

  // Get predicted routes for detection
  static Future<List<PredictionRoute>> getPredictedRoutes(
    int detectionId,
  ) async {
    final result = await _get('/detections/$detectionId/routes/');
    if (result['success']) {
      final data = result['data'] as List;
      return data.map((item) => PredictionRoute.fromJson(item)).toList();
    }
    return [];
  }

  // Fetch all detections (with role-based filtering)
  static Future<List<Detection>> fetchDetections() async {
    try {
      final userEmail = getUserEmail();
      final result = await _get('/detections/?role=admin&email=$userEmail');
      if (result['success']) {
        final data = result['data'];
        if (data is List) {
          return data.map((item) => Detection.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print('Error fetching detections: $e');
    }
    return [];
  }

  // Get single detection details
  static Future<Detection?> getDetectionDetails(int id) async {
    try {
      final result = await _get('/detections/$id/');
      if (result['success']) {
        final data = result['data'];
        if (data is Map<String, dynamic>) {
          return Detection.fromJson(data);
        }
      }
    } catch (e) {
      print('Error fetching detection details: $e');
    }
    return null;
  }

  // Fetch unknown vehicles (admin only)
  static Future<List<UnknownVehicle>> fetchUnknownVehicles() async {
    try {
      final result = await _get('/unknown-vehicles/?role=admin');
      if (result['success']) {
        final data = result['data'];
        if (data is List) {
          return data.map((item) => UnknownVehicle.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print('Error fetching unknown vehicles: $e');
    }
    return [];
  }

  // ============= PROFILE ENDPOINTS =============

  // Get user profile
  static Future<Map<String, dynamic>> getProfile(String email) async {
    final result = await _get('/user/profile/?email=$email');
    if (result['success']) {
      return result['data'];
    }
    throw Exception(result['message'] ?? 'Failed to get profile');
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String email,
    required String fullName,
    required String phoneNumber,
  }) async {
    final result = await _post('/user/profile/update/', {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    });
    if (result['success']) {
      return result['data'];
    }
    throw Exception(result['message'] ?? 'Failed to update profile');
  }

  // Camera Management APIs
  static Future<Map<String, dynamic>> getCameras() async {
    return _get('/cameras/');
  }

  static Future<Map<String, dynamic>> addCamera(
    Map<String, dynamic> cameraData,
  ) async {
    return _post('/cameras/', cameraData);
  }

  static Future<Map<String, dynamic>> updateCamera(
    int cameraId,
    Map<String, dynamic> cameraData,
  ) async {
    return _post('/cameras/$cameraId/', cameraData);
  }

  static Future<Map<String, dynamic>> deleteCamera(int cameraId) async {
    final url = Uri.parse('$baseUrl/cameras/$cameraId/');
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    final res = await http.delete(url, headers: headers);
    print('DELETE REQUEST to /cameras/$cameraId/');
    print('RESPONSE ${res.statusCode}: ${res.body}');

    try {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {'success': true, 'message': 'Camera deleted successfully'};
      } else {
        final decoded = jsonDecode(res.body);
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to delete camera',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Parse error: $e'};
    }
  }
}

// ApiService alias for easier access
class ApiService extends AuthServices {}
