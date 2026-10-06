import '../config/api_config.dart';
import '../exceptions/api_exception.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final ApiService _apiService = ApiService.instance;

  final SecureStorageService _secureStorageService =
      SecureStorageService.instance;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String employeeId,
    required String department,
    required String designation,
    required String phone,
    required String password,
  }) async {
    return _apiService.post(
      endpoint: ApiConfig.registerEndpoint,
      requiresAuth: false,
      body: <String, dynamic>{
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'employee_id': employeeId.trim(),
        'department': department.trim(),
        'designation': designation.trim(),
        'phone': phone.trim(),
        'password': password,
        'role': 'Employee',
      },
    );
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return _apiService.post(
      endpoint: ApiConfig.verifyOtpEndpoint,
      body: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    return _apiService.post(
      endpoint: ApiConfig.resendOtpEndpoint,
      body: <String, dynamic>{'email': email.trim().toLowerCase()},
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> response = await _apiService.post(
      endpoint: ApiConfig.loginEndpoint,
      body: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final String accessToken =
        response['access_token']?.toString().trim() ?? '';

    if (accessToken.isEmpty) {
      throw const ApiException(
        message: 'Login succeeded but access token was not returned.',
      );
    }

    await _secureStorageService.saveAccessToken(accessToken);

    final dynamic rawUser = response['user'];

    if (rawUser is Map) {
      final Map<String, dynamic> user = Map<String, dynamic>.from(rawUser);

      final String role = user['role']?.toString().trim().toLowerCase() ?? '';

      final String employeeId = user['employee_id']?.toString().trim() ?? '';

      if (role.isNotEmpty) {
        await _secureStorageService.saveUserRole(role);
      }

      if (employeeId.isNotEmpty) {
        await _secureStorageService.saveEmployeeId(employeeId);
      }
    }

    return response;
  }

  Future<Map<String, dynamic>> getCurrentUser({
    required String accessToken,
  }) async {
    return _apiService.get(
      endpoint: ApiConfig.currentUserEndpoint,
      accessToken: accessToken,
      requiresAuth: true,
    );
  }

  Future<Map<String, dynamic>> getProfile({
    required String accessToken,
  }) async {
    return _apiService.get(
      endpoint: ApiConfig.profileEndpoint,
      accessToken: accessToken,
      requiresAuth: true,
    );
  }

  Future<Map<String, dynamic>> updateProfile({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    return _apiService.put(
      endpoint: ApiConfig.profileEndpoint,
      accessToken: accessToken,
      requiresAuth: true,
      body: data,
    );
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String accessToken,
  }) async {
    return _apiService.put(
      endpoint: ApiConfig.changePasswordEndpoint,
      accessToken: accessToken,
      requiresAuth: true,
      body: <String, dynamic>{
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    return _apiService.post(
      endpoint: ApiConfig.forgotPasswordEndpoint,
      body: <String, dynamic>{'email': email.trim().toLowerCase()},
    );
  }

  Future<Map<String, dynamic>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    return _apiService.post(
      endpoint: ApiConfig.verifyResetOtpEndpoint,
      body: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    return _apiService.post(
      endpoint: ApiConfig.resetPasswordEndpoint,
      body: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'reset_token': resetToken.trim(),
        'new_password': newPassword,
      },
    );
  }

  Future<void> logout() async {
    await _secureStorageService.clearAuthenticationData();
  }
}
