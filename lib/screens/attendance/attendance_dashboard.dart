import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/exceptions/api_exception.dart';
import '../../core/services/admin_attendance_service.dart';
import 'attendance_analytics.dart';
import 'attendance_history.dart';
import 'late_arrival.dart';
import 'monthly_report.dart';
import 'qr_attendance.dart';

class AttendanceDashboard extends StatefulWidget {
  const AttendanceDashboard({super.key});

  @override
  State<AttendanceDashboard> createState() {
    return _AttendanceDashboardState();
  }
}

class _AttendanceDashboardState extends State<AttendanceDashboard> {
  static const double _mobileBreakpoint = 700;

  static const Duration _refreshInterval = Duration(seconds: 10);

  final AdminAttendanceService _attendanceService =
      AdminAttendanceService.instance;

  Timer? _refreshTimer;

  bool _isInitialLoading = true;
  bool _isRefreshing = false;

  String? _errorMessage;
  String? _processingDeviceId;

  DateTime? _lastUpdated;

  Map<String, dynamic> _todayResponse = <String, dynamic>{};

  List<Map<String, dynamic>> _pendingDevices = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();

    _loadDashboard(showLoader: true);

    _refreshTimer = Timer.periodic(_refreshInterval, (Timer timer) {
      _loadDashboard(showLoader: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboard({required bool showLoader}) async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;

    if (showLoader && mounted) {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final List<dynamic> results =
          await Future.wait<dynamic>(<Future<dynamic>>[
            _attendanceService.getTodayAttendance(),
            _attendanceService.getPendingDevices(),
          ]);

      final Map<String, dynamic> todayResponse = Map<String, dynamic>.from(
        results[0] as Map,
      );

      final List<Map<String, dynamic>> pendingDevices =
          List<Map<String, dynamic>>.from(results[1] as List);

      if (!mounted) {
        return;
      }

      setState(() {
        _todayResponse = todayResponse;
        _pendingDevices = pendingDevices;

        _isInitialLoading = false;
        _errorMessage = null;
        _lastUpdated = DateTime.now();
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitialLoading = false;
        _errorMessage = error.message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isInitialLoading = false;
        _errorMessage = _cleanError(error);
      });
    } finally {
      _isRefreshing = false;
    }
  }

  String _cleanError(Object error) {
    String message = error.toString().trim();

    message = message
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiException: ', '')
        .trim();

    if (message.isEmpty) {
      return 'Unable to load attendance information.';
    }

    return message;
  }

  Map<String, dynamic> get _summary {
    final dynamic rawSummary = _todayResponse['summary'];

    if (rawSummary is Map) {
      return Map<String, dynamic>.from(rawSummary);
    }

    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> get _attendanceRecords {
    final dynamic rawAttendance = _todayResponse['attendance'];

    if (rawAttendance is! List) {
      return <Map<String, dynamic>>[];
    }

    return rawAttendance.whereType<Map>().map((Map<dynamic, dynamic> item) {
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  int _readInteger(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String get _presentCount {
    return _readInteger(_summary['present']).toString();
  }

  String get _absentCount {
    return _readInteger(_summary['absent']).toString();
  }

  String get _lateCount {
    return _readInteger(_summary['late']).toString();
  }

  String get _attendanceRate {
    final dynamic rawRate = _summary['attendance_rate'];

    final double rate = rawRate is num
        ? rawRate.toDouble()
        : double.tryParse(rawRate?.toString() ?? '') ?? 0;

    final String formattedRate = rate == rate.roundToDouble()
        ? rate.toStringAsFixed(0)
        : rate.toStringAsFixed(1);

    return '$formattedRate%';
  }

  String _valueFrom(
    Map<String, dynamic> item,
    List<String> keys, {
    String fallback = '--',
  }) {
    for (final String key in keys) {
      final dynamic value = item[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  String _deviceId(Map<String, dynamic> device) {
    return _valueFrom(device, const <String>[
      'id',
      '_id',
      'device_id',
    ], fallback: '');
  }

  Future<void> _approveDevice(Map<String, dynamic> device) async {
    final String deviceId = _deviceId(device);

    if (deviceId.isEmpty) {
      _showMessage(
        message: 'Device ID was not returned by the backend.',
        isError: true,
      );
      return;
    }

    if (_processingDeviceId != null) {
      return;
    }

    setState(() {
      _processingDeviceId = deviceId;
    });

    try {
      final Map<String, dynamic> response = await _attendanceService
          .approveDevice(
            deviceId: deviceId,
            reason: 'Approved from attendance dashboard',
          );

      if (!mounted) {
        return;
      }

      _showMessage(
        message:
            response['message']?.toString() ?? 'Device approved successfully.',
        isError: false,
      );

      await _loadDashboard(showLoader: false);
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
          _processingDeviceId = null;
        });
      }
    }
  }

  Future<void> _revokeDevice(Map<String, dynamic> device) async {
    final String deviceId = _deviceId(device);

    if (deviceId.isEmpty) {
      _showMessage(
        message: 'Device ID was not returned by the backend.',
        isError: true,
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reject device request'),
          content: const Text(
            'Are you sure you want to reject this attendance device?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || _processingDeviceId != null) {
      return;
    }

    setState(() {
      _processingDeviceId = deviceId;
    });

    try {
      final Map<String, dynamic> response = await _attendanceService
          .revokeDevice(
            deviceId: deviceId,
            reason: 'Rejected from attendance dashboard',
          );

      if (!mounted) {
        return;
      }

      _showMessage(
        message: response['message']?.toString() ?? 'Device request rejected.',
        isError: false,
      );

      await _loadDashboard(showLoader: false);
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
          _processingDeviceId = null;
        });
      }
    }
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

  String get _lastUpdatedText {
    final DateTime? value = _lastUpdated;

    if (value == null) {
      return 'Waiting for update';
    }

    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    final String second = value.second.toString().padLeft(2, '0');

    return 'Last updated $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isMobile = constraints.maxWidth < _mobileBreakpoint;

          return Column(
            children: [
              _buildHeader(context, isMobile),
              Expanded(
                child: _isInitialLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () {
                          return _loadDashboard(showLoader: false);
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(isMobile ? 16 : 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_errorMessage != null) _buildErrorCard(),
                              _buildSummaryCards(isMobile),
                              SizedBox(height: isMobile ? 18 : 26),
                              _buildModuleCards(
                                context,
                                constraints.maxWidth,
                                isMobile,
                              ),
                              SizedBox(height: isMobile ? 18 : 26),
                              _buildPendingDevicesSection(isMobile),
                              SizedBox(height: isMobile ? 18 : 26),
                              _buildAttendanceTable(isMobile),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 14 : 24,
        (isMobile ? 12 : 24) + statusBarHeight,
        isMobile ? 14 : 24,
        isMobile ? 22 : 30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF020A3D), Color(0xFF2563EB), Color(0xFF9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Smart Attendance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 20 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Live attendance, secure QR and device approvals',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _lastUpdatedText,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 4, backgroundColor: Colors.greenAccent),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              _loadDashboard(showLoader: false);
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE74C3C)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE74C3C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? 'Unable to load attendance information.',
            ),
          ),
          IconButton(
            onPressed: () {
              _loadDashboard(showLoader: false);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(bool isMobile) {
    final List<_AttendanceSummaryItem> cards = <_AttendanceSummaryItem>[
      _AttendanceSummaryItem(
        title: 'Present Today',
        value: _presentCount,
        icon: Icons.check_circle_rounded,
        color: Colors.green,
      ),
      _AttendanceSummaryItem(
        title: 'Absent',
        value: _absentCount,
        icon: Icons.cancel_rounded,
        color: Colors.red,
      ),
      _AttendanceSummaryItem(
        title: 'Late Arrivals',
        value: _lateCount,
        icon: Icons.access_time_rounded,
        color: Colors.orange,
      ),
      _AttendanceSummaryItem(
        title: 'Attendance Rate',
        value: _attendanceRate,
        icon: Icons.analytics_rounded,
        color: Colors.purple,
      ),
    ];

    if (isMobile) {
      return SizedBox(
        height: 112,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(width: 14);
          },
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(width: 190, child: _buildSummaryCard(cards[index]));
          },
        ),
      );
    }

    return Row(
      children: [
        for (int index = 0; index < cards.length; index++) ...[
          if (index != 0) const SizedBox(width: 18),
          Expanded(child: _buildSummaryCard(cards[index])),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(_AttendanceSummaryItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: item.color.withValues(alpha: 0.13),
            child: Icon(item.icon, color: item.color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 7),
                Text(
                  item.value,
                  style: const TextStyle(
                    color: Color(0xFF081A63),
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCards(
    BuildContext context,
    double maxWidth,
    bool isMobile,
  ) {
    return Wrap(
      spacing: 18,
      runSpacing: 18,
      children: [
        _buildModuleCard(
          title: 'QR Attendance',
          subtitle: 'Create secure employee attendance sessions',
          icon: Icons.qr_code_scanner_rounded,
          color: Colors.blue,
          maxWidth: maxWidth,
          isMobile: isMobile,
          onTap: () {
            _openPage(context, const QRAttendanceScreen());
          },
        ),
        _buildModuleCard(
          title: 'Attendance Analytics',
          subtitle: 'View daily, weekly and monthly analytics',
          icon: Icons.bar_chart_rounded,
          color: Colors.green,
          maxWidth: maxWidth,
          isMobile: isMobile,
          onTap: () {
            _openPage(context, const AttendanceAnalyticsScreen());
          },
        ),
        _buildModuleCard(
          title: 'Monthly Report',
          subtitle: 'Generate employee attendance reports',
          icon: Icons.picture_as_pdf_rounded,
          color: Colors.red,
          maxWidth: maxWidth,
          isMobile: isMobile,
          onTap: () {
            _openPage(context, const MonthlyReportScreen());
          },
        ),
        _buildModuleCard(
          title: 'Late Arrival Detection',
          subtitle: 'Identify and track employees arriving late',
          icon: Icons.timer_rounded,
          color: const Color(0xFFF59E0B),
          maxWidth: maxWidth,
          isMobile: isMobile,
          onTap: () {
            _openPage(context, const LateArrivalScreen());
          },
        ),
        _buildModuleCard(
          title: 'Attendance History',
          subtitle: 'View employee attendance history',
          icon: Icons.history_rounded,
          color: Colors.teal,
          maxWidth: maxWidth,
          isMobile: isMobile,
          onTap: () {
            _openPage(context, const AttendanceHistoryScreen());
          },
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double maxWidth,
    required bool isMobile,
    required VoidCallback onTap,
  }) {
    final double cardWidth = isMobile
        ? maxWidth - 32
        : maxWidth < 1000
        ? (maxWidth - 44) / 2
        : 430;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: color.withValues(alpha: 0.13),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF081A63),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingDevicesSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE8EEFF),
                child: Icon(
                  Icons.phonelink_lock_rounded,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pending Device Approvals',
                  style: TextStyle(
                    color: const Color(0xFF081A63),
                    fontSize: isMobile ? 19 : 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _pendingDevices.length.toString(),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_pendingDevices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: Colors.green,
                      size: 44,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No pending device requests',
                      style: TextStyle(
                        color: Color(0xFF081A63),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._pendingDevices.map((Map<String, dynamic> device) {
              return _buildPendingDeviceCard(device, isMobile);
            }),
        ],
      ),
    );
  }

  Widget _buildPendingDeviceCard(Map<String, dynamic> device, bool isMobile) {
    final String id = _deviceId(device);

    final String employeeId = _valueFrom(device, const <String>[
      'employee_id',
    ], fallback: 'Employee ID unavailable');

    final String deviceName = _valueFrom(device, const <String>[
      'device_name',
      'name',
    ], fallback: 'Unknown device');

    final String platform = _valueFrom(device, const <String>[
      'platform',
    ], fallback: 'Unknown platform');

    final bool processing = _processingDeviceId == id;

    final Widget information = Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFE8EEFF),
          child: Icon(
            platform.toLowerCase() == 'ios'
                ? Icons.phone_iphone_rounded
                : Icons.phone_android_rounded,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deviceName,
                style: const TextStyle(
                  color: Color(0xFF081A63),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$employeeId • ${platform.toUpperCase()}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );

    final Widget actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: processing
              ? null
              : () {
                  _revokeDevice(device);
                },
          icon: const Icon(Icons.close_rounded),
          label: const Text('Reject'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        ),
        const SizedBox(width: 10),
        FilledButton.icon(
          onPressed: processing
              ? null
              : () {
                  _approveDevice(device);
                },
          icon: processing
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded),
          label: Text(processing ? 'Processing' : 'Approve'),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E7F3)),
      ),
      child: isMobile
          ? Column(
              children: [
                information,
                const SizedBox(height: 15),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            )
          : Row(
              children: [
                Expanded(child: information),
                const SizedBox(width: 18),
                actions,
              ],
            ),
    );
  }

  Widget _buildAttendanceTable(bool isMobile) {
    final List<Map<String, dynamic>> attendance = _attendanceRecords;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Today's Attendance",
                  style: TextStyle(
                    color: const Color(0xFF081A63),
                    fontSize: isMobile ? 19 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                _todayResponse['date']?.toString() ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (attendance.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      color: Colors.grey,
                      size: 52,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No attendance recorded today',
                      style: TextStyle(
                        color: Color(0xFF081A63),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attendance.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildAttendanceRow(attendance[index], isMobile);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(Map<String, dynamic> item, bool isMobile) {
    final String name = _valueFrom(item, const <String>[
      'employee_name',
      'name',
    ], fallback: 'Employee');

    final String employeeId = _valueFrom(item, const <String>[
      'employee_id',
      'employeeId',
    ], fallback: '—');

    final String department = _valueFrom(item, const <String>[
      'department',
    ], fallback: 'Not assigned');

    final String checkIn = _valueFrom(item, const <String>[
      'check_in',
      'checkIn',
    ]);

    final String checkOut = _valueFrom(item, const <String>[
      'check_out',
      'checkOut',
    ]);

    final bool locationVerified = item['location_verified'] as bool? ?? true;
    final dynamic rawDist = item['distance_from_company_meters'];
    final double? dist = rawDist is num
        ? rawDist.toDouble()
        : double.tryParse(rawDist?.toString() ?? '');
    final String distStr = dist != null
        ? (dist >= 1000 ? '${(dist / 1000).toStringAsFixed(1)} km' : '${dist.toStringAsFixed(0)} m')
        : '—';

    final String status = _valueFrom(item, const <String>[
      'status',
    ], fallback: 'Present');

    final Color statusColor = _statusColor(status);

    final Widget statusChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E7F3)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: statusColor.withValues(alpha: 0.12),
                      child: Icon(Icons.person_rounded, color: statusColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            employeeId,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    statusChip,
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Column(
                    children: [
                      _buildInformationRow('Department', department),
                      const SizedBox(height: 7),
                      _buildInformationRow('Check In', checkIn),
                      const SizedBox(height: 7),
                      _buildInformationRow('Check Out', checkOut),
                      const SizedBox(height: 7),
                      _buildInformationRow(
                        'Location',
                        locationVerified ? 'Valid ($distStr)' : 'Invalid ($distStr)',
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  child: Icon(Icons.person_rounded, color: statusColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        employeeId,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Text(department)),
                Expanded(child: Text(checkIn)),
                Expanded(child: Text(checkOut)),
                Expanded(
                  child: Text(
                    locationVerified ? 'Valid ($distStr)' : 'Invalid ($distStr)',
                    style: TextStyle(
                      color: locationVerified ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                statusChip,
              ],
            ),
    );
  }

  Widget _buildInformationRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'late':
        return Colors.orange;

      case 'absent':
        return Colors.red;

      case 'leave':
        return Colors.blue;

      case 'checked out':
        return Colors.teal;

      case 'present':
      default:
        return Colors.green;
    }
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}

class _AttendanceSummaryItem {
  const _AttendanceSummaryItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}
