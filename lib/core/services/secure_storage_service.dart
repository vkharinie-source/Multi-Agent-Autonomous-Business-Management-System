import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userRoleKey = 'user_role';
  static const String _employeeIdKey = 'employee_id';
  static const String _installationIdKey = 'installation_id';

  Future<void> saveAccessToken(String token) async {
    final String value = token.trim();

    if (value.isEmpty) {
      throw ArgumentError('Access token cannot be empty.');
    }

    await _storage.write(key: _accessTokenKey, value: value);
  }

  Future<String?> readAccessToken() async {
    final String? accessToken = await _storage.read(key: _accessTokenKey);

    if (accessToken != null && accessToken.trim().isNotEmpty) {
      return accessToken.trim();
    }

    // Support old token keys used by previous code.
    final String? authToken = await _storage.read(key: 'auth_token');

    if (authToken != null && authToken.trim().isNotEmpty) {
      return authToken.trim();
    }

    final String? oldToken = await _storage.read(key: 'token');

    if (oldToken != null && oldToken.trim().isNotEmpty) {
      return oldToken.trim();
    }

    return null;
  }

  Future<void> saveRefreshToken(String token) async {
    final String value = token.trim();

    if (value.isEmpty) {
      throw ArgumentError('Refresh token cannot be empty.');
    }

    await _storage.write(key: _refreshTokenKey, value: value);
  }

  Future<String?> readRefreshToken() async {
    final String? token = await _storage.read(key: _refreshTokenKey);

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    return token.trim();
  }

  Future<void> saveUserRole(String role) async {
    final String value = role.trim().toLowerCase();

    if (value.isEmpty) {
      throw ArgumentError('User role cannot be empty.');
    }

    await _storage.write(key: _userRoleKey, value: value);
  }

  Future<String?> readUserRole() async {
    final String? role = await _storage.read(key: _userRoleKey);

    if (role == null || role.trim().isEmpty) {
      return null;
    }

    return role.trim().toLowerCase();
  }

  Future<void> saveEmployeeId(String employeeId) async {
    final String value = employeeId.trim();

    if (value.isEmpty) {
      throw ArgumentError('Employee ID cannot be empty.');
    }

    await _storage.write(key: _employeeIdKey, value: value);
  }

  Future<String?> readEmployeeId() async {
    final String? employeeId = await _storage.read(key: _employeeIdKey);

    if (employeeId == null || employeeId.trim().isEmpty) {
      return null;
    }

    return employeeId.trim();
  }

  Future<void> saveInstallationId(String installationId) async {
    final String value = installationId.trim();

    if (value.isEmpty) {
      throw ArgumentError('Installation ID cannot be empty.');
    }

    await _storage.write(key: _installationIdKey, value: value);
  }

  Future<String?> readInstallationId() async {
    final String? installationId = await _storage.read(key: _installationIdKey);

    if (installationId == null || installationId.trim().isEmpty) {
      return null;
    }

    return installationId.trim();
  }

  Future<bool> hasAccessToken() async {
    final String? token = await readAccessToken();

    return token != null && token.isNotEmpty;
  }

  Future<void> clearAuthenticationData() async {
    await _storage.delete(key: _accessTokenKey);

    await _storage.delete(key: _refreshTokenKey);

    await _storage.delete(key: _userRoleKey);

    await _storage.delete(key: _employeeIdKey);

    // Remove keys used by older versions.
    await _storage.delete(key: 'auth_token');

    await _storage.delete(key: 'token');

    // Installation ID is intentionally retained.
    // Logout should not create a new device identity.
  }

  Future<void> clearInstallationId() async {
    await _storage.delete(key: _installationIdKey);
  }

  Future<void> clearAllData() async {
    await _storage.deleteAll();
  }
}
