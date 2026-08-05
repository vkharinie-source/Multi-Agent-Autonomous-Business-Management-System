class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  // Authentication endpoints
  static const String register = '/api/auth/register';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String resendOtp = '/api/auth/resend-otp';
  static const String login = '/api/auth/login';
  static const String currentUser = '/api/auth/me';
  static const String changePassword = '/api/auth/change-password';

  static Uri buildUri(String endpoint) {
    return Uri.parse('$baseUrl$endpoint');
  }
}
