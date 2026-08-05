import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _customBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    final String customUrl = _customBaseUrl.trim();

    if (customUrl.isNotEmpty) {
      return _removeTrailingSlash(customUrl);
    }

    // Flutter Web
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    // Android Emulator only
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    // Windows and other local platforms
    return 'http://127.0.0.1:8000';
  }

  // Authentication endpoints
  static const String registerEndpoint = '/api/auth/register';

  static const String verifyOtpEndpoint = '/api/auth/verify-otp';

  static const String resendOtpEndpoint = '/api/auth/resend-otp';

  static const String loginEndpoint = '/api/auth/login';

  static const String currentUserEndpoint = '/api/auth/me';

  static const String changePasswordEndpoint = '/api/auth/change-password';

  static const String forgotPasswordEndpoint = '/api/auth/forgot-password';

  static const String verifyResetOtpEndpoint = '/api/auth/verify-reset-otp';

  static const String resetPasswordEndpoint = '/api/auth/reset-password';

  // Attendance endpoints
  static const String campusesEndpoint = '/api/attendance/campuses';

  static const String attendanceSessionsEndpoint = '/api/attendance/sessions';

  static const String activeAttendanceSessionsEndpoint =
      '/api/attendance/sessions/active';

  static const String attendanceScanEndpoint = '/api/attendance/scan';

  static const String todayAttendanceEndpoint = '/api/attendance/today';

  static const String myAttendanceEndpoint = '/api/attendance/me';

  static const String attendanceAuditLogsEndpoint =
      '/api/attendance/audit-logs';

  // Device endpoints
  static const String deviceRegisterRequestEndpoint =
      '/api/devices/register-request';

  static const String myDevicesEndpoint = '/api/devices/me';

  static const String pendingDevicesEndpoint = '/api/devices/pending';

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

  static Uri uri(String endpoint) {
    final String normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';

    return Uri.parse('$baseUrl$normalizedEndpoint');
  }

  static String get websocketBaseUrl {
    if (baseUrl.startsWith('https://')) {
      return baseUrl.replaceFirst('https://', 'wss://');
    }

    return baseUrl.replaceFirst('http://', 'ws://');
  }

  static String _removeTrailingSlash(String value) {
    String result = value;

    while (result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }

    return result;
  }
}
