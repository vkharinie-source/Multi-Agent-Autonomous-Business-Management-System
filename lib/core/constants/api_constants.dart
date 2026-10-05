class ApiConstants {
  ApiConstants._();

  static const String serverUrl =
      'https://multi-agent-autonomous-business.onrender.com';

  static String get authBaseUrl {
    return '$serverUrl/api/auth';
  }

  // Authentication
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

  static String get forgotPasswordUrl {
    return '$authBaseUrl/forgot-password';
  }

  static String get verifyResetOtpUrl {
    return '$authBaseUrl/verify-reset-otp';
  }

  static String get resetPasswordUrl {
    return '$authBaseUrl/reset-password';
  }
}
