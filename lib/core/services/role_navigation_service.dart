import 'package:flutter/material.dart';

import 'package:autonomous_business_ai/core/exceptions/api_exception.dart';
import 'package:autonomous_business_ai/core/services/auth_service.dart';
import 'package:autonomous_business_ai/core/services/secure_storage_service.dart';
import 'package:autonomous_business_ai/screens/employee/employee_dashboard.dart';
import 'package:autonomous_business_ai/screens/home/landing_page.dart';

class RoleNavigationService {
  RoleNavigationService._();

  static Future<void> openDashboard({
    required BuildContext context,
    required Map<String, dynamic> loginResponse,
  }) async {
    Map<String, dynamic>? user;

    final dynamic loginUser = loginResponse['user'];

    if (loginUser is Map) {
      user = Map<String, dynamic>.from(loginUser);
    }

    // Login response-ல் user details இல்லையெனில் backend-ல் இருந்து பெறும்.
    if (user == null) {
      final String? accessToken = await SecureStorageService.instance
          .readAccessToken();

      if (accessToken == null || accessToken.trim().isEmpty) {
        throw const ApiException(
          message: 'Login session was not found. Please sign in again.',
          statusCode: 401,
        );
      }

      final Map<String, dynamic> response = await AuthService.instance
          .getCurrentUser(accessToken: accessToken);

      final dynamic currentUser = response['user'];

      if (currentUser is Map) {
        user = Map<String, dynamic>.from(currentUser);
      } else if (response['role'] != null) {
        user = Map<String, dynamic>.from(response);
      }
    }

    if (user == null) {
      throw const ApiException(
        message: 'Unable to load the current user information.',
      );
    }

    final String role = user['role']?.toString().trim().toLowerCase() ?? '';

    Widget destination;

    switch (role) {
      case 'admin':
        destination = LandingPage();
        break;

      case 'manager':
        destination = LandingPage();
        break;

      case 'employee':
        destination = EmployeeDashboard();
        break;

      default:
        throw const ApiException(
          message: 'This account does not have a valid role.',
        );
    }

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return destination;
        },
      ),
      (Route<dynamic> route) => false,
    );
  }
}
