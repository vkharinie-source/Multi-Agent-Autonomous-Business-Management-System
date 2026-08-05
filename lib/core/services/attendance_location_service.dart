import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../exceptions/api_exception.dart';

class AttendanceLocation {
  const AttendanceLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.capturedAt,
    required this.isMocked,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime capturedAt;
  final bool isMocked;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'captured_at': capturedAt.toUtc().toIso8601String(),
      'is_mocked': isMocked,
    };
  }
}

class AttendanceLocationService {
  AttendanceLocationService._();

  static final AttendanceLocationService instance =
      AttendanceLocationService._();

  static const double maximumAllowedAccuracy = 60;

  Future<AttendanceLocation> getVerifiedLocation() async {
    if (kIsWeb) {
      throw const ApiException(
        message:
            'Secure attendance location verification is available only in the mobile application.',
      );
    }

    final bool supportedPlatform =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    if (!supportedPlatform) {
      throw const ApiException(
        message:
            'Attendance location verification is supported only on Android and iOS.',
      );
    }

    await _checkLocationService();
    await _checkLocationPermission();
    await _checkPreciseLocation();

    final Position position = await _getCurrentPosition();

    if (position.isMocked) {
      throw const ApiException(
        message:
            'Mock location was detected. Disable fake GPS or developer mock-location apps before marking attendance.',
      );
    }

    if (position.accuracy <= 0) {
      throw const ApiException(
        message:
            'The device returned an invalid GPS accuracy. Move to an open area and try again.',
      );
    }

    if (position.accuracy > maximumAllowedAccuracy) {
      throw ApiException(
        message:
            'GPS accuracy is too low (${position.accuracy.toStringAsFixed(0)} meters). Move closer to an open area and try again.',
      );
    }

    return AttendanceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      capturedAt: position.timestamp,
      isMocked: position.isMocked,
    );
  }

  Future<void> _checkLocationService() async {
    final bool enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      throw const ApiException(
        message: 'Location service is turned off. Enable GPS and try again.',
      );
    }
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const ApiException(
        message:
            'Location permission was denied. Attendance cannot be marked without location access.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const ApiException(
        message:
            'Location permission is permanently denied. Open app settings and allow location permission.',
      );
    }

    if (permission == LocationPermission.unableToDetermine) {
      throw const ApiException(
        message:
            'Unable to determine location permission. Check the device settings and try again.',
      );
    }
  }

  Future<void> _checkPreciseLocation() async {
    try {
      final LocationAccuracyStatus accuracyStatus =
          await Geolocator.getLocationAccuracy();

      if (accuracyStatus == LocationAccuracyStatus.reduced) {
        throw const ApiException(
          message:
              'Precise location is disabled. Enable precise location for secure attendance.',
        );
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      // Some older devices may not report this setting.
      // GPS accuracy is checked again after getting the position.
    }
  }

  Future<Position> _getCurrentPosition() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
      timeLimit: Duration(seconds: 20),
    );

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } on TimeoutException {
      throw const ApiException(
        message:
            'GPS location request timed out. Move to an open area and try again.',
      );
    } on LocationServiceDisabledException {
      throw const ApiException(
        message: 'Location service is disabled. Enable GPS and try again.',
      );
    } on PermissionDeniedException {
      throw const ApiException(
        message: 'Location permission is required to mark attendance.',
      );
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }

      throw ApiException(
        message: 'Unable to obtain the current location: $error',
      );
    }
  }

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  Future<bool> openApplicationSettings() {
    return Geolocator.openAppSettings();
  }
}
