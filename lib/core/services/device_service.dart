import '../config/api_config.dart';
import '../exceptions/api_exception.dart';
import 'api_service.dart';
import 'device_identity_service.dart';

class DeviceService {
  DeviceService._();

  static final DeviceService instance = DeviceService._();

  final ApiService _apiService = ApiService.instance;

  final DeviceIdentityService _deviceIdentityService =
      DeviceIdentityService.instance;

  Future<Map<String, dynamic>> registerCurrentDevice() async {
    final DeviceIdentity identity = await _deviceIdentityService
        .getDeviceIdentity();

    if (!identity.isPhysicalDevice) {
      throw const ApiException(
        message:
            'Attendance device registration requires a physical mobile device.',
      );
    }

    return _apiService.post(
      endpoint: ApiConfig.deviceRegisterRequestEndpoint,
      requiresAuth: true,
      body: identity.toJson(),
    );
  }

  Future<List<Map<String, dynamic>>> getMyDevices() async {
    final Map<String, dynamic> response = await _apiService.get(
      endpoint: ApiConfig.myDevicesEndpoint,
      requiresAuth: true,
    );

    return _extractList(
      response,
      possibleKeys: const <String>['devices', 'data', 'items'],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingDevices() async {
    final Map<String, dynamic> response = await _apiService.get(
      endpoint: ApiConfig.pendingDevicesEndpoint,
      requiresAuth: true,
    );

    return _extractList(
      response,
      possibleKeys: const <String>[
        'devices',
        'pending_devices',
        'data',
        'items',
      ],
    );
  }

  Future<Map<String, dynamic>> approveDevice({
    required String deviceId,
    String? reason,
  }) async {
    final String normalizedDeviceId = deviceId.trim();

    if (normalizedDeviceId.isEmpty) {
      throw const ApiException(message: 'Device ID cannot be empty.');
    }

    return _apiService.put(
      endpoint: ApiConfig.approveDeviceEndpoint(normalizedDeviceId),
      requiresAuth: true,
      body: <String, dynamic>{
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  Future<Map<String, dynamic>> revokeDevice({
    required String deviceId,
    String? reason,
  }) async {
    final String normalizedDeviceId = deviceId.trim();

    if (normalizedDeviceId.isEmpty) {
      throw const ApiException(message: 'Device ID cannot be empty.');
    }

    return _apiService.put(
      endpoint: ApiConfig.revokeDeviceEndpoint(normalizedDeviceId),
      requiresAuth: true,
      body: <String, dynamic>{
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  List<Map<String, dynamic>> _extractList(
    Map<String, dynamic> response, {
    required List<String> possibleKeys,
  }) {
    dynamic rawList;

    for (final String key in possibleKeys) {
      final dynamic value = response[key];

      if (value is List) {
        rawList = value;
        break;
      }
    }

    if (rawList == null && response['data'] is Map) {
      final Map<dynamic, dynamic> data =
          response['data'] as Map<dynamic, dynamic>;

      for (final String key in possibleKeys) {
        final dynamic value = data[key];

        if (value is List) {
          rawList = value;
          break;
        }
      }
    }

    if (rawList is! List) {
      return <Map<String, dynamic>>[];
    }

    return rawList
        .whereType<Map>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
