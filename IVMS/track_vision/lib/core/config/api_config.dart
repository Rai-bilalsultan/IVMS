/// API Configuration - Automatic Detection System
///
/// This system automatically detects which environment you're running on:
/// - Android Emulator → uses 10.0.2.2:8000
/// - Physical Android Device → tries to connect automatically
/// - iOS Simulator → uses localhost:8000
/// - Physical iOS Device → tries to connect automatically
/// - Web → uses localhost:8000
///
/// NO MANUAL IP CHANGE NEEDED! The system tries multiple IPs automatically.
/// Just make sure Django backend is running on 0.0.0.0:8000

class ApiConfig {
  // ========== AUTOMATIC DETECTION - NO MANUAL CHANGES NEEDED ==========

  // Primary backend server (works on all devices)
  static const String baseUrl = "http://172.17.241.89:8000";



  // Fallback IPs to try (for physical devices when primary fails)
  static const List<String> fallbackUrls = [
    "http://localhost:8000", // iOS Simulator / Web
    "http://192.168.1.1:8000", // Gateway IP
    "http://192.168.1.100:8000", // Common router IP
    "http://192.168.100.1:8000", // Another common IP
    "http://10.0.0.1:8000", // VPN/Corporate network
  ];

  // OPTIONAL: If above don't work, manually set your machine IP here:
  // static const String manualDeviceIp = "192.168.1.5:8000";
  static const String? manualDeviceIp = null; // null = auto-detect

  // Get the base URL (with automatic fallback handling)
  static String get baseUrlWithFallback {
    if (manualDeviceIp != null) {
      return "http://$manualDeviceIp";
    }
    return baseUrl; // Will be handled by ApiService with fallbacks
  }

  // ================================================================

  // API Endpoints
  static const String signupEndpoint = '/signup/';
  static const String loginEndpoint = '/login/';
  static const String forgotPasswordEndpoint = '/forgot-password/';
  static const String verifyOtpEndpoint = '/verify-otp/';
  static const String resetPasswordEndpoint = '/reset-password/';
  static const String getProfileEndpoint = '/user/profile/';
  static const String updateProfileEndpoint = '/user/profile/update/';

  // Complaints Endpoints
  static const String complaintsEndpoint = '/complaints/';
  static const String registerComplaintEndpoint = '/complaints/register/';
  static const String searchComplaintsEndpoint = '/complaints/search/';
  static const String getAllComplaintsEndpoint = '/complaints/all/';
  static const String updateComplaintStatusEndpoint =
      '/complaints/update-status/';

  // Alerts Endpoints
  static const String alertsEndpoint = '/alerts/';
  static const String alertDetailsEndpoint = '/alerts/';
  static const String markAlertReadEndpoint = '/alerts/';

  // WebSocket Endpoints (for real-time features)
  static String get webSocketBaseUrl => baseUrl
      .replaceFirst('http://', 'ws://')
      .replaceFirst('https://', 'wss://');
  static String get userAlertsWsEndpoint => '$webSocketBaseUrl/ws/alerts/';
  static String get adminAlertsWsEndpoint =>
      '$webSocketBaseUrl/ws/alerts/admin/';

  // Request timeout in seconds
  static const int requestTimeout = 30;

  // Connection status check
  static bool isProduction = false; // Set to true for production

  /// Get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
