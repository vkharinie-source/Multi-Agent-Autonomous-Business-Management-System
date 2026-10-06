import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // ────────────────────────────────────────────────────────────────
  // CUSTOM BASE URL
  // ────────────────────────────────────────────────────────────────
  // Usage:
  //   - Emulator (default): http://10.0.2.2:8000
  //   - Physical Device: flutter run --dart-define=API_BASE_URL=http://10.47.131.48:8000
  //   - Web: http://127.0.0.1:8000
  //   - iOS: http://127.0.0.1:8000
  // ────────────────────────────────────────────────────────────────
  static const String _customBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    final String customUrl = _customBaseUrl.trim();

    // If custom base URL is provided via --dart-define, use it
    if (customUrl.isNotEmpty) {
      return _removeTrailingSlash(customUrl);
    }

    // Platform-specific defaults
    if (kIsWeb) {
      // Flutter Web
      return 'http://127.0.0.1:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android Emulator: 10.0.2.2 is the host machine's loopback address
      // For physical device: Use --dart-define=API_BASE_URL=http://<device-ip>:8000
      return 'http://10.0.2.2:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS Simulator and Physical Device
      return 'http://127.0.0.1:8000';
    }

    // Windows, Linux, macOS and other platforms
    return 'http://127.0.0.1:8000';
  }

  // ────────────────────────────────────────────────────────────────
  // AUTHENTICATION ENDPOINTS
  // ────────────────────────────────────────────────────────────────
  static const String registerEndpoint = '/api/auth/register';

  static const String verifyOtpEndpoint = '/api/auth/verify-otp';

  static const String resendOtpEndpoint = '/api/auth/resend-otp';

  static const String loginEndpoint = '/api/auth/login';

  static const String currentUserEndpoint = '/api/auth/me';

  static const String changePasswordEndpoint = '/api/auth/change-password';

  static const String forgotPasswordEndpoint = '/api/auth/forgot-password';

  static const String verifyResetOtpEndpoint = '/api/auth/verify-reset-otp';

  static const String resetPasswordEndpoint = '/api/auth/reset-password';

  // ────────────────────────────────────────────────────────────────
  // ATTENDANCE ENDPOINTS
  // ────────────────────────────────────────────────────────────────
  static const String campusesEndpoint = '/api/attendance/campuses';

  static const String attendanceSessionsEndpoint = '/api/attendance/sessions';

  static const String activeAttendanceSessionsEndpoint =
      '/api/attendance/sessions/active';

  static const String attendanceScanEndpoint = '/api/attendance/scan';

  static const String todayAttendanceEndpoint = '/api/attendance/today';

  static const String myAttendanceEndpoint = '/api/attendance/me';

  static const String attendanceAuditLogsEndpoint =
      '/api/attendance/audit-logs';

  // ────────────────────────────────────────────────────────────────
  // DEVICE ENDPOINTS
  // ────────────────────────────────────────────────────────────────
  static const String deviceRegisterRequestEndpoint =
      '/api/devices/register-request';

  static const String myDevicesEndpoint = '/api/devices/me';

  static const String pendingDevicesEndpoint = '/api/devices/pending';

  // ────────────────────────────────────────────────────────────────
  // DYNAMIC ENDPOINTS
  // ────────────────────────────────────────────────────────────────
  static String attendanceSessionQrEndpoint(String sessionId) {
    return '/api/attendance/sessions/$sessionId/qr';
  }

  static String closeAttendanceSessionEndpoint(String sessionId) {
    return '/api/attendance/sessions/$sessionId/close';
  }

  static String approveDeviceEndpoint(String deviceId) {
    return '/api/devices/$deviceId/approve';
  }

  static String revokeDeviceEndpoint(String deviceId) {
    return '/api/devices/$deviceId/revoke';
  }

  // ────────────────────────────────────────────────────────────────
  // URI BUILDER
  // ────────────────────────────────────────────────────────────────
  static Uri uri(String endpoint) {
    final String normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';

    return Uri.parse('$baseUrl$normalizedEndpoint');
  }

  // ────────────────────────────────────────────────────────────────
  // WEBSOCKET BASE URL
  // ────────────────────────────────────────────────────────────────
  static String get websocketBaseUrl {
    if (baseUrl.startsWith('https://')) {
      return baseUrl.replaceFirst('https://', 'wss://');
    }

    return baseUrl.replaceFirst('http://', 'ws://');
  }

  // ────────────────────────────────────────────────────────────────
  // HELPER: REMOVE TRAILING SLASH
  // ────────────────────────────────────────────────────────────────
  static String _removeTrailingSlash(String value) {
    String result = value;

    while (result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }

    return result;
  }
}
