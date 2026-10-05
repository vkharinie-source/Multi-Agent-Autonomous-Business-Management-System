class ApiConfig {
  ApiConfig._();

  static const String baseUrl =
      'https://multi-agent-autonomous-business.onrender.com';

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
}
