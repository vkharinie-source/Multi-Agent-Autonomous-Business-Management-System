import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/config/api_config.dart';
import '../../core/services/secure_storage_service.dart';

// ---------------------------------------------------------------------------
// Manager QR Attendance Screen
// Connects to existing backend endpoints:
//   POST /api/attendance/sessions          — create session
//   GET  /api/attendance/campuses          — list campuses
//   GET  /api/attendance/sessions/{id}/qr  — rotating QR token
//   GET  /api/attendance/sessions/{id}/events — scanned employees (polling)
// ---------------------------------------------------------------------------

class QRAttendanceScreen extends StatefulWidget {
  const QRAttendanceScreen({super.key});

  @override
  State<QRAttendanceScreen> createState() => _QRAttendanceScreenState();
}

class _QRAttendanceScreenState extends State<QRAttendanceScreen> {
  static const double _mobileBreakpoint = 950;

  // --- campus & session state ---
  List<Map<String, dynamic>> _campuses = <Map<String, dynamic>>[];
  String? _selectedCampusId;
  String _attendanceType = 'check_in';
  int _durationMinutes = 20;

  // --- countdown timer ---
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;

  // --- active session state ---
  Map<String, dynamic>? _session;
  String? _qrToken;
  String? _closesAt;

  // --- scanned employees list (live) ---
  List<Map<String, dynamic>> _events = <Map<String, dynamic>>[];

  // --- loading / error ---
  bool _loadingCampuses = true;
  bool _creatingSession = false;
  String? _error;

  // --- timers ---
  Timer? _qrRotationTimer;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadCampuses();
  }

  @override
  void dispose() {
    _qrRotationTimer?.cancel();
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Future<String?> _token() async =>
      SecureStorageService.instance.readAccessToken();

  Future<Map<String, dynamic>> _get(String endpoint) async {
    final String? token = await _token();
    final http.Response res = await http
        .get(
          ApiConfig.uri(endpoint),
          headers: <String, String>{
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 20));
    final Map<String, dynamic> body =
        jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception(body['detail'] ?? 'Request failed');
    }
    return body;
  }

  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final String? token = await _token();
    final http.Response res = await http
        .post(
          ApiConfig.uri(endpoint),
          headers: <String, String>{
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));
    final Map<String, dynamic> body =
        jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception(body['detail'] ?? 'Request failed');
    }
    return body;
  }

  // -------------------------------------------------------------------------
  // Data loading
  // -------------------------------------------------------------------------

  Future<void> _loadCampuses() async {
    try {
      final Map<String, dynamic> data =
          await _get(ApiConfig.campusesEndpoint);
      final List<dynamic> list =
          data['campuses'] as List<dynamic>? ?? <dynamic>[];
      if (!mounted) return;
      setState(() {
        _campuses = list
            .map((dynamic e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _selectedCampusId =
            _campuses.isNotEmpty ? _campuses[0]['campus_id'] as String? : null;
        _loadingCampuses = false;
      });

      // Check if there is already an active attendance session running
      try {
        final Map<String, dynamic> activeData =
            await _get(ApiConfig.activeAttendanceSessionsEndpoint);
        final List<dynamic> activeList =
            activeData['sessions'] as List<dynamic>? ?? <dynamic>[];
        if (activeList.isNotEmpty && mounted) {
          final Map<String, dynamic> session =
              Map<String, dynamic>.from(activeList[0] as Map);
          final String sessionId = session['session_id'] as String;
          final Map<String, dynamic> qrRes =
              await _get(ApiConfig.attendanceSessionQrEndpoint(sessionId));
          if (mounted) {
            setState(() {
              _session = session;
              _qrToken = qrRes['qr_token'] as String?;
              _closesAt = session['closes_at'] as String?;
              _events = <Map<String, dynamic>>[];
            });
            _startCountdown();
            _startQrRotation(sessionId);
            _startPolling(sessionId);
          }
        } else if (mounted && _campuses.isNotEmpty) {
          // Auto-create a 20-minute session when screen opens
          _autoCreateSession();
        }
      } catch (_) {
        // If active session lookup fails, auto-create a new one
        if (mounted && _campuses.isNotEmpty) {
          _autoCreateSession();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCampuses = false;
        _error = 'Could not load campuses: $e';
      });
    }
  }

  /// Auto-create a 20-minute QR session when the screen opens
  Future<void> _autoCreateSession() async {
    if (_selectedCampusId == null || _creatingSession) return;
    await _createSession();
  }

  Future<void> _createSession() async {
    if (_selectedCampusId == null) return;
    setState(() {
      _creatingSession = true;
      _error = null;
    });
    try {
      final Map<String, dynamic> result = await _post(
        ApiConfig.attendanceSessionsEndpoint,
        <String, dynamic>{
          'campus_id': _selectedCampusId,
          'attendance_type': _attendanceType,
          'duration_minutes': _durationMinutes,
        },
      );
      final Map<String, dynamic> session =
          Map<String, dynamic>.from(result['session'] as Map);
      final Map<String, dynamic> qr =
          Map<String, dynamic>.from(result['qr'] as Map);
      if (!mounted) return;
      setState(() {
        _session = session;
        _qrToken = qr['qr_token'] as String?;
        _closesAt = session['closes_at'] as String?;
        _events = <Map<String, dynamic>>[];
        _creatingSession = false;
      });
      _startCountdown();
      _startQrRotation(session['session_id'] as String);
      _startPolling(session['session_id'] as String);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _creatingSession = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _startQrRotation(String sessionId) {
    _qrRotationTimer?.cancel();
    // Rotate QR every 28 s (backend rotates every 30 s; 2 s early for safety)
    _qrRotationTimer =
        Timer.periodic(const Duration(seconds: 28), (_) async {
      try {
        final Map<String, dynamic> data = await _get(
          ApiConfig.attendanceSessionQrEndpoint(sessionId),
        );
        final Map<String, dynamic> qr =
            Map<String, dynamic>.from(data['qr'] as Map);
        final Map<String, dynamic> session =
            Map<String, dynamic>.from(data['session'] as Map);
        if (!mounted) return;
        // Check if session expired
        if (session['active'] != true) {
          _qrRotationTimer?.cancel();
          _pollTimer?.cancel();
          setState(() {
            _session = null;
            _qrToken = null;
          });
          return;
        }
        setState(() {
          _qrToken = qr['qr_token'] as String?;
        });
      } catch (_) {
        // Session might have expired — stop rotating
        _qrRotationTimer?.cancel();
      }
    });
  }

  void _startPolling(String sessionId) {
    _pollTimer?.cancel();
    // Poll every 5 seconds for new scan events
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final Map<String, dynamic> data = await _get(
          ApiConfig.attendanceSessionEventsEndpoint(sessionId),
        );
        final List<dynamic> events =
            data['events'] as List<dynamic>? ?? <dynamic>[];
        if (!mounted) return;
        setState(() {
          _events = events
              .map((dynamic e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      } catch (_) {
        // Silently ignore polling errors
      }
    });
  }

  /// Start the visible countdown timer from _closesAt
  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    if (_closesAt == null) return;
    try {
      final DateTime expiresAt = DateTime.parse(_closesAt!).toLocal();
      final Duration diff = expiresAt.difference(DateTime.now());
      if (!mounted) return;
      if (diff.isNegative) {
        // Session expired after 20 minutes — auto-close and immediately regenerate a new valid 20-minute QR
        _countdownTimer?.cancel();
        _handleSessionExpiration();
        return;
      }
      setState(() {
        _remainingTime = diff;
      });
    } catch (_) {}
  }

  String _formatCountdown() {
    final int mins = _remainingTime.inMinutes;
    final int secs = _remainingTime.inSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _handleSessionExpiration() async {
    _countdownTimer?.cancel();
    _qrRotationTimer?.cancel();
    _pollTimer?.cancel();
    await _closeSession();
    if (mounted && _selectedCampusId != null) {
      await _autoCreateSession();
    }
  }

  Future<void> _closeSession() async {
    final String? sessionId = _session?['session_id'] as String?;
    if (sessionId == null) return;
    try {
      await _post(
        ApiConfig.closeAttendanceSessionEndpoint(sessionId),
        <String, dynamic>{},
      );
    } catch (_) {}
    _qrRotationTimer?.cancel();
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _session = null;
      _qrToken = null;
      _events = <Map<String, dynamic>>[];
      _remainingTime = Duration.zero;
    });
  }

  // -------------------------------------------------------------------------
  // Formatting helpers
  // -------------------------------------------------------------------------

  String _formatTime(String? iso) {
    if (iso == null) return '—';
    try {
      final DateTime dt = DateTime.parse(iso).toLocal();
      final String m = dt.minute.toString().padLeft(2, '0');
      final String amPm = dt.hour < 12 ? 'AM' : 'PM';
      final int h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      return '$h12:$m $amPm';
    } catch (_) {
      return iso;
    }
  }

  String _formatClosesAt(String? iso) {
    if (iso == null) return '';
    return 'Valid until ${_formatTime(iso)}';
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isMobile = constraints.maxWidth < _mobileBreakpoint;
          return Column(
            children: <Widget>[
              _buildHeader(isMobile),
              Expanded(
                child: _loadingCampuses
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding:
                            EdgeInsets.all(isMobile ? 16 : 26),
                        child: Column(
                          children: <Widget>[
                            if (_error != null)
                              _buildErrorBanner(_error!),
                            isMobile
                                ? Column(
                                    children: <Widget>[
                                      _buildQrCard(isMobile),
                                      const SizedBox(height: 24),
                                      _buildInstructionCard(isMobile),
                                    ],
                                  )
                                : IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        _buildQrCard(isMobile),
                                        const SizedBox(width: 24),
                                        _buildInstructionCard(isMobile),
                                      ],
                                    ),
                                  ),
                            SizedBox(height: isMobile ? 18 : 26),
                            _buildScannedList(isMobile),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 28,
        isMobile ? 20 : 30,
        isMobile ? 16 : 28,
        isMobile ? 24 : 34,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xff020A3D),
            Color(0xff2563EB),
            Color(0xff9333EA),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: isMobile ? 6 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'QR Attendance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 22 : 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Generate QR code and mark employee attendance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 12 : 14,
                  ),
                  maxLines: isMobile ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isMobile) ...<Widget>[
            const Spacer(),
            const Icon(Icons.qr_code_scanner, color: Colors.white, size: 42),
          ] else
            const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String msg) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg, style: const TextStyle(color: Colors.red)),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => setState(() => _error = null),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(bool isMobile) {
    final bool sessionActive = _session != null;

    final Widget content = Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "Today's Attendance QR",
            style: TextStyle(
              fontSize: isMobile ? 19 : 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xff081A63),
            ),
          ),
          const SizedBox(height: 16),

          // --- campus & type selectors (only when no active session) ---
          if (!sessionActive) ...<Widget>[
            if (_campuses.isEmpty)
              const Text(
                'No campus configured. Ask Admin to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              )
            else ...<Widget>[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Campus / Location',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                initialValue: _selectedCampusId,
                items: _campuses.map((Map<String, dynamic> c) {
                  return DropdownMenuItem<String>(
                    value: c['campus_id'] as String,
                    child: Text(
                      c['name'] as String? ?? c['campus_id'] as String,
                    ),
                  );
                }).toList(),
                onChanged: (String? v) =>
                    setState(() => _selectedCampusId = v),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Attendance Type',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                initialValue: _attendanceType,
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'check_in',
                    child: Text('Check In'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'check_out',
                    child: Text('Check Out'),
                  ),
                ],
                onChanged: (String? v) =>
                    setState(() => _attendanceType = v ?? 'check_in'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                initialValue: _durationMinutes,
                items: const <DropdownMenuItem<int>>[
                  DropdownMenuItem<int>(value: 5, child: Text('5 minutes')),
                  DropdownMenuItem<int>(value: 10, child: Text('10 minutes')),
                  DropdownMenuItem<int>(value: 15, child: Text('15 minutes')),
                  DropdownMenuItem<int>(value: 20, child: Text('20 minutes (default)')),
                  DropdownMenuItem<int>(value: 30, child: Text('30 minutes')),
                  DropdownMenuItem<int>(value: 60, child: Text('1 hour')),
                ],
                onChanged: (int? v) =>
                    setState(() => _durationMinutes = v ?? 30),
              ),
            ],
            const SizedBox(height: 16),
          ],

          // --- QR image ---
          Container(
            height: isMobile ? 160 : 180,
            width: isMobile ? 160 : 180,
            decoration: BoxDecoration(
              color: sessionActive
                  ? Colors.white
                  : const Color(0xffEEF4FF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xff2563EB),
                width: 2,
              ),
            ),
            child: sessionActive && _qrToken != null
                ? QrImageView(
                    data: _qrToken!,
                    version: QrVersions.auto,
                    size: isMobile ? 140 : 155,
                    backgroundColor: Colors.white,
                  )
                : const Icon(
                    Icons.qr_code,
                    size: 80,
                    color: Color(0xff2563EB),
                  ),
          ),

          const SizedBox(height: 12),

          // --- countdown timer display ---
          if (sessionActive) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: _remainingTime.inMinutes < 5
                    ? Colors.red.withValues(alpha: 0.10)
                    : const Color(0xff10B981).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _remainingTime.inMinutes < 5
                      ? Colors.red.withValues(alpha: 0.30)
                      : const Color(0xff10B981).withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.timer,
                    size: 18,
                    color: _remainingTime.inMinutes < 5
                        ? Colors.red
                        : const Color(0xff10B981),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatCountdown(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: _remainingTime.inMinutes < 5
                          ? Colors.red
                          : const Color(0xff10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'remaining',
                    style: TextStyle(
                      fontSize: 11,
                      color: _remainingTime.inMinutes < 5
                          ? Colors.red
                          : const Color(0xff10B981),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
          ],

          // --- status text ---
          Text(
            sessionActive
                ? '🟢 QR Active • ${_formatClosesAt(_closesAt)} • Auto-rotates every 28s'
                : 'Auto-generates a 20-min QR on screen open',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: sessionActive ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          // --- action buttons ---
          if (sessionActive)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _closeSession,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Close Session'),
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563EB),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: (_creatingSession || _campuses.isEmpty)
                  ? null
                  : _createSession,
              icon: _creatingSession
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.qr_code_2),
              label: Text(_creatingSession ? 'Starting…' : 'Generate QR'),
            ),
        ],
      ),
    );

    return isMobile ? content : Expanded(child: content);
  }

  Widget _buildInstructionCard(bool isMobile) {
    final Widget content = Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'How QR Attendance Works',
            style: TextStyle(
              fontSize: isMobile ? 19 : 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xff081A63),
            ),
          ),
          const SizedBox(height: 16),
          _step(Icons.location_on, 'Admin configures campus location first.'),
          _step(Icons.qr_code_2, 'Manager generates a secure, time-limited QR.'),
          _step(Icons.phone_android, 'Employee opens Scan Attendance and scans.'),
          _step(Icons.location_searching, 'Backend validates location & QR.'),
          _step(Icons.check_circle, 'Attendance recorded — panel updates live.'),
          _step(Icons.block, 'Duplicate or out-of-zone scans are rejected.'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffEEF4FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: <Widget>[
                Icon(Icons.security, color: Color(0xff2563EB)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'QR rotates every 28 s. Employee location is validated server-side.',
                    style: TextStyle(
                      color: Color(0xff081A63),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return isMobile ? content : Expanded(child: content);
  }

  Widget _step(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor:
                const Color(0xff2563EB).withValues(alpha: 0.12),
            child: Icon(icon, color: const Color(0xff2563EB)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedList(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Scanned Employees',
                style: TextStyle(
                  fontSize: isMobile ? 19 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff081A63),
                ),
              ),
              const Spacer(),
              if (_session != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Live • ${_events.length} scanned',
                    style: const TextStyle(
                      color: Color(0xff2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (_events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _session == null
                      ? 'Generate a QR code to start recording attendance.'
                      : 'Waiting for employees to scan…',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _events.length,
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> ev = _events[index];
                final bool locationOk =
                    ev['location_verified'] as bool? ?? false;
                final String status =
                    ev['status'] as String? ?? (locationOk ? 'Present' : 'Location Mismatch');
                final dynamic rawDist = ev['distance_from_company_meters'];
                final double? dist = rawDist is num
                    ? rawDist.toDouble()
                    : double.tryParse(rawDist?.toString() ?? '');
                
                String distStr = '—';
                if (dist != null) {
                  if (dist >= 1000) {
                    distStr = '${(dist / 1000).toStringAsFixed(1)} km';
                  } else {
                    distStr = '${dist.toStringAsFixed(0)} m';
                  }
                }

                final Color statusColor =
                    locationOk ? Colors.green : Colors.red;
                final Color statusBg = locationOk
                    ? Colors.green.withValues(alpha: 0.10)
                    : Colors.red.withValues(alpha: 0.10);

                final String? empLat = ev['employee_latitude']?.toString();
                final String? empLon = ev['employee_longitude']?.toString();
                final String? authLat = ev['authorized_latitude']?.toString();
                final String? authLon = ev['authorized_longitude']?.toString();
                final String campusName = ev['campus_name'] as String? ?? 'Campus';

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: locationOk ? const Color(0xffF8FAFF) : const Color(0xffFFF5F5),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: locationOk ? Colors.grey.shade200 : Colors.red.shade200,
                    ),
                  ),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: statusBg,
                                  child: Icon(
                                    locationOk
                                        ? Icons.check
                                        : Icons.location_off,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    ev['employee_name'] as String? ?? '—',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _statusChip(
                                    status, statusColor, statusBg),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 54),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Employee ID: ${ev['employee_id'] ?? '—'}',
                                    style:
                                        const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    'Check-in Time: ${_formatTime(ev['recorded_at'] as String?)}',
                                    style:
                                        const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    'Location: ${locationOk ? "Valid" : "Invalid"}  •  Distance: $distStr',
                                    style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  if (!locationOk && empLat != null && authLat != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Expected: $campusName ($authLat, $authLon)',
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 11),
                                    ),
                                    Text(
                                      'Detected: ($empLat, $empLon)',
                                      style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 11),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: statusBg,
                                  child: Icon(
                                    locationOk ? Icons.check : Icons.location_off,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    ev['employee_id'] as String? ?? '—',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    ev['employee_name'] as String? ?? '—',
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _formatTime(ev['recorded_at'] as String?),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Location: ${locationOk ? "Valid" : "Invalid"}\n$distStr',
                                    style:
                                        TextStyle(color: statusColor, fontSize: 13),
                                  ),
                                ),
                                _statusChip(status, statusColor, statusBg),
                              ],
                            ),
                            if (!locationOk && empLat != null && authLat != null) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 56),
                                child: Text(
                                  'Expected Location: $campusName ($authLat, $authLon)  |  Detected: ($empLat, $empLon)  |  Distance: $distStr',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color fg, Color bg) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
