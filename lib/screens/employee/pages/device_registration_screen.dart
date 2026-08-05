import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/exceptions/api_exception.dart';
import '../../../core/services/device_service.dart';

class DeviceRegistrationScreen extends StatefulWidget {
  const DeviceRegistrationScreen({super.key});

  @override
  State<DeviceRegistrationScreen> createState() {
    return _DeviceRegistrationScreenState();
  }
}

class _DeviceRegistrationScreenState extends State<DeviceRegistrationScreen> {
  final DeviceService _deviceService = DeviceService.instance;

  bool _isLoading = true;
  bool _isRegistering = false;

  String? _errorMessage;

  List<Map<String, dynamic>> _devices = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final List<Map<String, dynamic>> devices = await _deviceService
          .getMyDevices();

      if (!mounted) {
        return;
      }

      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanError(error);
      });
    }
  }

  Future<void> _registerCurrentDevice() async {
    if (_isRegistering) {
      return;
    }

    if (kIsWeb) {
      _showMessage(
        message:
            'Secure device registration is available only in the Android or iOS mobile app.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      final Map<String, dynamic> response = await _deviceService
          .registerCurrentDevice();

      if (!mounted) {
        return;
      }

      _showMessage(
        message:
            response['message']?.toString() ??
            'Device registration request submitted successfully.',
        isError: false,
      );

      await _loadDevices();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(message: error.message, isError: true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(message: _cleanError(error), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  String _cleanError(Object error) {
    String message = error.toString().trim();

    message = message
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiException: ', '')
        .trim();

    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    return message;
  }

  void _showMessage({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
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
        backgroundColor: isError
            ? const Color(0xFFE74C3C)
            : const Color(0xFF21A366),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  String _deviceName(Map<String, dynamic> device) {
    return device['device_name']?.toString().trim() ??
        device['name']?.toString().trim() ??
        'Unknown device';
  }

  String _platform(Map<String, dynamic> device) {
    final String platform =
        device['platform']?.toString().trim().toLowerCase() ?? 'unknown';

    switch (platform) {
      case 'android':
        return 'Android';

      case 'ios':
        return 'iOS';

      default:
        return 'Unknown platform';
    }
  }

  String _status(Map<String, dynamic> device) {
    return device['status']?.toString().trim().toLowerCase() ?? 'pending';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF21A366);

      case 'rejected':
      case 'revoked':
        return const Color(0xFFE74C3C);

      case 'pending':
      default:
        return const Color(0xFFF39C12);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.verified_rounded;

      case 'rejected':
      case 'revoked':
        return Icons.block_rounded;

      case 'pending':
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';

      case 'rejected':
        return 'Rejected';

      case 'revoked':
        return 'Revoked';

      case 'pending':
      default:
        return 'Pending approval';
    }
  }

  bool get _hasApprovedDevice {
    return _devices.any((Map<String, dynamic> device) {
      return _status(device) == 'approved';
    });
  }

  bool get _hasPendingDevice {
    return _devices.any((Map<String, dynamic> device) {
      return _status(device) == 'pending';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text(
          'Attendance Device',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadDevices,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDevices,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildRegistrationCard(),
            const SizedBox(height: 24),
            const Text(
              'Registered Devices',
              style: TextStyle(
                color: Color(0xFF201A3D),
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              _buildErrorCard()
            else if (_devices.isEmpty)
              _buildEmptyCard()
            else
              ..._devices.map((Map<String, dynamic> device) {
                return _buildDeviceCard(device);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF07134F), Color(0xFF1749E5), Color(0xFF7556F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.phonelink_lock_rounded, color: Colors.white, size: 48),
          SizedBox(height: 18),
          Text(
            'Secure Attendance Device',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Only an approved physical mobile device can scan the company attendance QR.',
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard() {
    String title;
    String description;
    Color statusColor;
    IconData statusIcon;

    if (_hasApprovedDevice) {
      title = 'Device approved';
      description =
          'Your registered device is approved and ready for secure attendance scanning.';
      statusColor = const Color(0xFF21A366);
      statusIcon = Icons.verified_user_rounded;
    } else if (_hasPendingDevice) {
      title = 'Approval pending';
      description =
          'Your request has been submitted. Wait for an Admin or Manager to approve the device.';
      statusColor = const Color(0xFFF39C12);
      statusIcon = Icons.hourglass_top_rounded;
    } else {
      title = 'Register this device';
      description =
          'Submit this physical mobile device for Admin or Manager approval.';
      statusColor = const Color(0xFF1749E5);
      statusIcon = Icons.add_moderator_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: statusColor.withValues(alpha: 0.12),
                child: Icon(statusIcon, color: statusColor, size: 29),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF201A3D),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF6F6981),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_hasApprovedDevice && !_hasPendingDevice) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isRegistering ? null : _registerCurrentDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1749E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: _isRegistering
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.phonelink_setup_rounded),
                label: Text(
                  _isRegistering ? 'Registering...' : 'Register This Device',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
          if (kIsWeb) ...[
            const SizedBox(height: 14),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 19,
                  color: Color(0xFFF39C12),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Device registration cannot be completed in Chrome. Run the app on a physical Android or iOS phone.',
                    style: TextStyle(
                      color: Color(0xFF7B5A12),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final String status = _status(device);
    final Color statusColor = _statusColor(status);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E8F2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: const Color(0xFFE8EEFF),
            child: Icon(
              _platform(device) == 'iOS'
                  ? Icons.phone_iphone_rounded
                  : Icons.phone_android_rounded,
              color: const Color(0xFF1749E5),
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _deviceName(device),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF201A3D),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _platform(device),
                  style: const TextStyle(color: Color(0xFF6F6981)),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(status), color: statusColor, size: 17),
                      const SizedBox(width: 6),
                      Text(
                        _statusLabel(status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE74C3C)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFE74C3C),
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'Unable to load registered devices.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _loadDevices,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E8F2)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.phonelink_erase_rounded,
            color: Color(0xFF9A95A8),
            size: 54,
          ),
          SizedBox(height: 14),
          Text(
            'No registered devices',
            style: TextStyle(
              color: Color(0xFF201A3D),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Register your physical mobile device to use secure QR attendance.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6F6981), height: 1.4),
          ),
        ],
      ),
    );
  }
}
