import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../exceptions/api_exception.dart';
import 'secure_storage_service.dart';

class DeviceIdentity {
  const DeviceIdentity({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.isPhysicalDevice,
  });

  final String deviceId;
  final String deviceName;
  final String platform;
  final bool isPhysicalDevice;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'device_id': deviceId,
      'device_name': deviceName,
      'platform': platform,
    };
  }
}

class DeviceIdentityService {
  DeviceIdentityService._();

  static final DeviceIdentityService instance = DeviceIdentityService._();

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  final SecureStorageService _secureStorageService =
      SecureStorageService.instance;

  final Uuid _uuid = Uuid();

  Future<DeviceIdentity> getDeviceIdentity() async {
    if (kIsWeb) {
      throw const ApiException(
        message:
            'Device registration is available only in the Android or iOS mobile application.',
      );
    }

    final String installationId = await _getOrCreateInstallationId();

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _getAndroidDeviceIdentity(installationId);

      case TargetPlatform.iOS:
        return _getIosDeviceIdentity(installationId);

      default:
        throw const ApiException(
          message: 'Device registration is not supported on this platform.',
        );
    }
  }

  Future<DeviceIdentity> _getAndroidDeviceIdentity(
    String installationId,
  ) async {
    try {
      final AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;

      final String manufacturer = _cleanText(androidInfo.manufacturer);

      final String model = _cleanText(androidInfo.model);

      final String deviceName = _createDeviceName(
        firstPart: manufacturer,
        secondPart: model,
        fallback: 'Android Device',
      );

      return DeviceIdentity(
        deviceId: installationId,
        deviceName: deviceName,
        platform: 'android',
        isPhysicalDevice: androidInfo.isPhysicalDevice,
      );
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }

      throw ApiException(
        message: 'Unable to read Android device information: $error',
      );
    }
  }

  Future<DeviceIdentity> _getIosDeviceIdentity(String installationId) async {
    try {
      final IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;

      final String assignedName = _cleanText(iosInfo.name);

      final String model = _cleanText(iosInfo.model);

      final String deviceName = assignedName.isNotEmpty
          ? assignedName
          : _createDeviceName(
              firstPart: 'Apple',
              secondPart: model,
              fallback: 'iOS Device',
            );

      return DeviceIdentity(
        deviceId: installationId,
        deviceName: deviceName,
        platform: 'ios',
        isPhysicalDevice: iosInfo.isPhysicalDevice,
      );
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }

      throw ApiException(
        message: 'Unable to read iOS device information: $error',
      );
    }
  }

  Future<String> _getOrCreateInstallationId() async {
    final String? savedInstallationId = await _secureStorageService
        .readInstallationId();

    if (savedInstallationId != null && savedInstallationId.trim().isNotEmpty) {
      return savedInstallationId.trim();
    }

    final String newInstallationId = _uuid.v4();

    await _secureStorageService.saveInstallationId(newInstallationId);

    return newInstallationId;
  }

  String _cleanText(String value) {
    final String cleanedValue = value.trim().replaceAll(RegExp(r'\s+'), ' ');

    final String lowercaseValue = cleanedValue.toLowerCase();

    if (lowercaseValue == 'unknown' || lowercaseValue == 'null') {
      return '';
    }

    return cleanedValue;
  }

  String _createDeviceName({
    required String firstPart,
    required String secondPart,
    required String fallback,
  }) {
    final List<String> parts = <String>[firstPart, secondPart].where((
      String value,
    ) {
      return value.trim().isNotEmpty;
    }).toList();

    if (parts.isEmpty) {
      return fallback;
    }

    return parts.join(' ');
  }
}
