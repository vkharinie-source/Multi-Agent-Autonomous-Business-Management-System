import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  static String get serverUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    return 'http://10.0.2.2:8000';
  }

  static String get authBaseUrl {
    return '$serverUrl/api/auth';
  }

  static String get registerUrl {
    return '$authBaseUrl/register';
  }

  static String get verifyOtpUrl {
    return '$authBaseUrl/verify-otp';
  }

  static String get resendOtpUrl {
    return '$authBaseUrl/resend-otp';
  }

  static String get loginUrl {
    return '$authBaseUrl/login';
  }

  static String get profileUrl {
    return '$authBaseUrl/me';
  }

  static String get changePasswordUrl {
    return '$authBaseUrl/change-password';
  }
}
