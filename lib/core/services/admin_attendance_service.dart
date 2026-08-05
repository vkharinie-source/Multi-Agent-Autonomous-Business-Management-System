import '../exceptions/api_exception.dart';
import 'api_service.dart';

class AdminAttendanceService {
  AdminAttendanceService._();

  static final AdminAttendanceService instance = AdminAttendanceService._();

  final ApiService _apiService = ApiService.instance;

  Future<Map<String, dynamic>> getTodayAttendance() async {
    return _apiService.get(
      endpoint: '/api/attendance/today',
      requiresAuth: true,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingDevices() async {
    final Map<String, dynamic> response = await _apiService.get(
      endpoint: '/api/devices/pending',
      requiresAuth: true,
    );

    final dynamic rawDevices =
        response['devices'] ?? response['pending_devices'] ?? response['data'];

    if (rawDevices is! List) {
      return <Map<String, dynamic>>[];
    }

    return rawDevices
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> device) => Map<String, dynamic>.from(device),
        )
        .toList();
  }

  Future<Map<String, dynamic>> approveDevice({
    required String deviceId,
    String reason = 'Approved attendance device',
  }) async {
    final String normalizedDeviceId = deviceId.trim();

    if (normalizedDeviceId.isEmpty) {
      throw const ApiException(message: 'Device ID is missing.');
    }

    return _apiService.put(
      endpoint: '/api/devices/$normalizedDeviceId/approve',
      requiresAuth: true,
      body: <String, dynamic>{'reason': reason.trim()},
    );
  }

  Future<Map<String, dynamic>> revokeDevice({
    required String deviceId,
    String reason = 'Device access revoked',
  }) async {
    final String normalizedDeviceId = deviceId.trim();

    if (normalizedDeviceId.isEmpty) {
      throw const ApiException(message: 'Device ID is missing.');
    }

    return _apiService.put(
      endpoint: '/api/devices/$normalizedDeviceId/revoke',
      requiresAuth: true,
      body: <String, dynamic>{'reason': reason.trim()},
    );
  }
}
