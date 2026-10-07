import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/config/api_config.dart';
import '../../../core/services/secure_storage_service.dart';

class ScanAttendanceScreen extends StatefulWidget {
  const ScanAttendanceScreen({super.key});

  @override
  State<ScanAttendanceScreen> createState() => _ScanAttendanceScreenState();
}

class _ScanAttendanceScreenState extends State<ScanAttendanceScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isSubmitting = false;
  bool _attendanceRecorded = false;
  String? _errorMessage;
  String? _successMessage;
  String? _lastScannedToken;

  // Detected location state
  double? _detectedLatitude;
  double? _detectedLongitude;
  double? _detectedAccuracy;
  bool _isFetchingLocation = false;
  bool _simulateOutsideLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
      if (Platform.isWindows) return 'windows';
      if (Platform.isMacOS) return 'macos';
      if (Platform.isLinux) return 'linux';
    } catch (_) {}
    return 'mobile';
  }

  Future<Position?> _fetchCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Fallback default coordinates for campus testing
        _detectedLatitude = 11.0168;
        _detectedLongitude = 76.9558;
        _detectedAccuracy = 15.0;
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Fallback for web / testing
        _detectedLatitude = 11.0168;
        _detectedLongitude = 76.9558;
        _detectedAccuracy = 15.0;
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        setState(() {
          _detectedLatitude = position.latitude;
          _detectedLongitude = position.longitude;
          _detectedAccuracy = position.accuracy;
        });
      }
      return position;
    } catch (e) {
      if (mounted) {
        setState(() {
          _detectedLatitude = 11.0168;
          _detectedLongitude = 76.9558;
          _detectedAccuracy = 15.0;
        });
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  void _onQrDetected(BarcodeCapture capture) {
    if (_isSubmitting || _attendanceRecorded) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final Barcode barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        if (_lastScannedToken == rawValue.trim() && _errorMessage != null) {
          // Prevent repeated rapid submissions of the same failed token
          continue;
        }
        _lastScannedToken = rawValue.trim();
        _recordAttendanceWithToken(rawValue.trim());
        break;
      }
    }
  }

  Future<void> _recordAttendanceWithToken(String qrToken) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
      _attendanceRecorded = false;
    });

    try {
      // 1. Get employee JWT token
      final String? token =
          await SecureStorageService.instance.readAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Login session expired. Please sign in again.');
      }

      // 2. Ensure location is ready
      double lat = _detectedLatitude ?? 11.0168;
      double lon = _detectedLongitude ?? 76.9558;
      double accuracy = _detectedAccuracy ?? 15.0;

      // If user toggled simulated outside location for testing location mismatch alert
      if (_simulateOutsideLocation) {
        lat += 0.05; // ~5.5 km away from campus
        lon += 0.05;
      }

      final String platform = _getPlatform();
      final String deviceId =
          (await SecureStorageService.instance.readInstallationId()) ??
              'DEVICE-${platform.toUpperCase()}-001';

      final Map<String, dynamic> payload = <String, dynamic>{
        'qr_token': qrToken,
        'device_id': deviceId,
        'platform': platform,
        'latitude': lat,
        'longitude': lon,
        'location_accuracy_meters': accuracy,
        'is_mock_location': false,
      };

      // 3. Post to existing backend
      final http.Response response = await http
          .post(
            ApiConfig.uri(ApiConfig.attendanceScanEndpoint),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      Map<String, dynamic> responseData = <String, dynamic>{};
      try {
        responseData =
            jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      if (response.statusCode >= 400) {
        final String detail =
            responseData['detail']?.toString() ?? 'Failed to record attendance.';

        String userFriendlyMessage = detail;
        if (detail.toLowerCase().contains('outside') ||
            detail.toLowerCase().contains('campus location')) {
          userFriendlyMessage =
              'Attendance cannot be recorded because you are outside the authorized attendance location.';
        } else if (detail.toLowerCase().contains('expired')) {
          userFriendlyMessage = 'This attendance QR has expired.';
        } else if (detail.toLowerCase().contains('already')) {
          userFriendlyMessage =
              'Attendance has already been recorded for this session.';
        } else if (detail.toLowerCase().contains('invalid') &&
            detail.toLowerCase().contains('qr')) {
          userFriendlyMessage = 'Invalid attendance QR.';
        } else if (detail.toLowerCase().contains('device') &&
            detail.toLowerCase().contains('not approved')) {
          userFriendlyMessage =
              'Your device is not approved for attendance. Please register your device from the Employee Dashboard and wait for manager approval.';
        }

        if (!mounted) return;
        setState(() {
          _errorMessage = userFriendlyMessage;
          _attendanceRecorded = false;
        });

        _showErrorSnackbar(userFriendlyMessage);
        return;
      }

      if (!mounted) return;

      setState(() {
        _attendanceRecorded = true;
        _successMessage = 'Attendance recorded successfully.';
        _errorMessage = null;
      });

      _showSuccessSnackbar('Attendance recorded successfully.');
    } on http.ClientException {
      const String msg =
          'Unable to connect to the attendance server. Please try again.';
      if (mounted) {
        setState(() => _errorMessage = msg);
        _showErrorSnackbar(msg);
      }
    } catch (error) {
      String msg = error.toString().replaceFirst('Exception: ', '').trim();
      if (msg.isEmpty) {
        msg = 'Unable to connect to the attendance server. Please try again.';
      }
      if (mounted) {
        setState(() => _errorMessage = msg);
        _showErrorSnackbar(msg);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Color(0xFF0F172A),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ),
        title: const Text(
          'Scan Attendance QR',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
            height: 1,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle Flash',
            onPressed: () => _scannerController.toggleTorch(),
            icon: const Icon(Icons.flash_on_rounded, size: 20, color: Color(0xFF0F172A)),
          ),
          IconButton(
            tooltip: 'Switch Camera',
            onPressed: () => _scannerController.switchCamera(),
            icon: const Icon(Icons.cameraswitch_outlined, size: 20, color: Color(0xFF0F172A)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: 'Refresh Location',
                  onPressed: _isFetchingLocation ? null : _fetchCurrentLocation,
                  icon: _isFetchingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                        )
                      : const Icon(Icons.my_location_rounded, size: 18, color: Color(0xFF0F172A)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Camera QR Scanner Container
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(21),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              MobileScanner(
                                controller: _scannerController,
                                onDetect: _onQrDetected,
                                errorBuilder: (context, error) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.qr_code_scanner_rounded,
                                            size: 60,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Point camera at Manager QR',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (_isSubmitting)
                                Container(
                                  color: Colors.black45,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              if (_attendanceRecorded)
                                Container(
                                  color: Colors.green.withValues(alpha: 0.85),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 60,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Recorded!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Scan Attendance QR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Point your camera at the QR code displayed on the Manager panel to automatically record attendance.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Location info badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffEEF4FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xff2563EB).withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xff2563EB),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _detectedLatitude != null
                                    ? 'GPS: ${_detectedLatitude!.toStringAsFixed(4)}, ${_detectedLongitude!.toStringAsFixed(4)} (±${_detectedAccuracy?.toStringAsFixed(0) ?? "15"}m)'
                                    : 'Fetching GPS location...',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff081A63),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Test toggle for location mismatch simulation
                      Row(
                        children: [
                          Checkbox(
                            value: _simulateOutsideLocation,
                            onChanged: (bool? val) {
                              setState(() {
                                _simulateOutsideLocation = val ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Simulate Outside Campus Location (for testing Location Mismatch Alert)',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      if (_isSubmitting)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Verifying location & recording attendance...',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),

                      if (_attendanceRecorded)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _attendanceRecorded = false;
                                _errorMessage = null;
                                _successMessage = null;
                                _lastScannedToken = null;
                              });
                            },
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Scan Again'),
                          ),
                        ),
                    ],
                  ),
                ),

                // Error alert card
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFFFDEDE),
                          child: Icon(Icons.location_off, color: Colors.red),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Attendance Rejected',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Success alert card
                if (_attendanceRecorded) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFDFF7E5),
                          child: Icon(Icons.check_rounded, color: Colors.green),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Attendance Recorded',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _successMessage ?? 'Your attendance check-in was successful.',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
