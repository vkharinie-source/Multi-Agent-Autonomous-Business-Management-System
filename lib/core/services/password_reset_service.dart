import 'dart:convert';

import 'package:http/http.dart' as http;

class PasswordResetService {
  PasswordResetService._();

  static const String _baseUrl = 'http://10.0.2.2:8000/api/auth';

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final uri = Uri.parse('$_baseUrl/forgot-password');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim().toLowerCase()}),
      );

      return _handleResponse(response);
    } catch (error) {
      throw Exception(
        'Unable to connect to the server. Please check whether the backend is running.',
      );
    }
  }

  static Future<Map<String, dynamic>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final uri = Uri.parse('$_baseUrl/verify-reset-otp');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
        }),
      );

      return _handleResponse(response);
    } catch (error) {
      throw Exception(
        'Unable to connect to the server. Please check whether the backend is running.',
      );
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse('$_baseUrl/reset-password');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      return _handleResponse(response);
    } catch (error) {
      throw Exception(
        'Unable to connect to the server. Please check whether the backend is running.',
      );
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        data = {'detail': 'Invalid response received from server.'};
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final detail = data['detail'];

    if (detail is String && detail.isNotEmpty) {
      throw Exception(detail);
    }

    if (detail is List) {
      final messages = detail
          .map((item) {
            if (item is Map<String, dynamic>) {
              return item['msg']?.toString();
            }

            return item.toString();
          })
          .whereType<String>()
          .where((message) => message.isNotEmpty)
          .toList();

      if (messages.isNotEmpty) {
        throw Exception(messages.join('\n'));
      }
    }

    throw Exception('Request failed with status code ${response.statusCode}.');
  }
}
