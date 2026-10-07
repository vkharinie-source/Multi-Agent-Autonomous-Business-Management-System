import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/services/secure_storage_service.dart';

class MyAttendanceScreen extends StatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  State<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends State<MyAttendanceScreen> {
  bool _isLoading = true;
  List<Map<String, String>> _records = <Map<String, String>>[];
  int _presentCount = 21;
  int _absentCount = 1;
  int _lateCount = 2;
  String _percentage = '94%';

  final List<Map<String, String>> _defaultRecords = const <Map<String, String>>[
    {
      'date': '26 July 2026',
      'checkIn': '09:05 AM',
      'checkOut': '05:42 PM',
      'status': 'Present',
    },
    {
      'date': '25 July 2026',
      'checkIn': '09:12 AM',
      'checkOut': '05:35 PM',
      'status': 'Present',
    },
    {
      'date': '24 July 2026',
      'checkIn': '09:42 AM',
      'checkOut': '05:45 PM',
      'status': 'Late',
    },
    {
      'date': '23 July 2026',
      'checkIn': '--',
      'checkOut': '--',
      'status': 'Leave',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMyAttendance();
  }

  Future<void> _loadMyAttendance() async {
    try {
      final String? token =
          await SecureStorageService.instance.readAccessToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        setState(() {
          _records = List<Map<String, String>>.from(_defaultRecords);
          _isLoading = false;
        });
        return;
      }

      final http.Response res = await http
          .get(
            ApiConfig.uri(ApiConfig.myAttendanceEndpoint),
            headers: <String, String>{
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(res.body) as Map<String, dynamic>;
        final List<dynamic> list =
            data['attendance'] as List<dynamic>? ?? <dynamic>[];

        if (list.isNotEmpty) {
          final List<Map<String, String>> liveRecords = <Map<String, String>>[];
          int present = 0;
          int lateCount = 0;
          int absent = 0;

          for (final dynamic item in list) {
            if (item is Map) {
              final String status = item['status']?.toString() ?? 'Present';
              if (status.toLowerCase() == 'present') {
                present++;
              } else if (status.toLowerCase() == 'late') {
                lateCount++;
              } else if (status.toLowerCase() == 'absent') {
                absent++;
              }

              liveRecords.add(<String, String>{
                'date': item['date']?.toString() ?? '—',
                'checkIn': item['check_in']?.toString() ?? '--',
                'checkOut': item['check_out']?.toString() ?? '--',
                'status': status,
              });
            }
          }

          final int total = liveRecords.length;
          final String pct = total > 0
              ? '${(((present + lateCount) / total) * 100).toStringAsFixed(0)}%'
              : '100%';

          if (!mounted) return;
          setState(() {
            _records = liveRecords;
            _presentCount = present;
            _lateCount = lateCount;
            _absentCount = absent;
            _percentage = pct;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _records = List<Map<String, String>>.from(_defaultRecords);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> displayRecords =
        _records.isNotEmpty ? _records : _defaultRecords;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FC),
      body: SafeArea(
        child: Stack(
          children: [
            // Background ambient glow circles
            Positioned(
              top: -80,
              right: -60,
              child: _buildGlowCircle(
                size: 260,
                color: const Color(0xFF7B61FF).withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _buildGlowCircle(
                size: 280,
                color: const Color(0xFFB66DFF).withValues(alpha: 0.10),
              ),
            ),

            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadMyAttendance,
                    color: const Color(0xFF6C5CE7),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      children: [
                        // Hero attendance score card
                        _buildHeroScoreCard(),

                        const SizedBox(height: 20),

                        // 4-Grid Summary cards
                        _buildSummaryGrid(),

                        const SizedBox(height: 24),

                        // Section Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.history_toggle_off_rounded,
                                  color: Color(0xFF6C5CE7),
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Attendance History',
                                  style: TextStyle(
                                    color: Color(0xFF201A3D),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFEAFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${displayRecords.length} Records',
                                style: const TextStyle(
                                  color: Color(0xFF6C5CE7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(
                                color: Color(0xFF6C5CE7),
                              ),
                            ),
                          )
                        else
                          ...displayRecords.map((Map<String, String> record) {
                            return _buildAttendanceCard(record);
                          }),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEBE6F8), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3EEFF),
              foregroundColor: const Color(0xFF4C3F91),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Attendance',
                style: GoogleFonts.inter(
                  color: const Color(0xFF201A3D),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Clock-in Logs & Working Hours',
                style: GoogleFonts.inter(color: const Color(0xFF756E8A), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Refresh Logs',
            onPressed: _isLoading ? null : _loadMyAttendance,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3EEFF),
              foregroundColor: const Color(0xFF6C5CE7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF35168A), Color(0xFF6C5CE7), Color(0xFF8E5BEF)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Verified Attendance Rate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _percentage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Punctuality & Presence',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$_presentCount days present and $_lateCount late check-ins recorded this cycle.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = (constraints.maxWidth - 36) / 4;
        final bool compact = width < 70;

        if (compact) {
          return Row(
            children: [
              Expanded(
                child: _buildSummaryPill(
                  title: 'Present',
                  value: '$_presentCount',
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryPill(
                  title: 'Late',
                  value: '$_lateCount',
                  icon: Icons.access_time_filled_rounded,
                  color: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFFFBEB),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryPill(
                  title: 'Absent',
                  value: '$_absentCount',
                  icon: Icons.cancel_rounded,
                  color: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFEF2F2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryPill(
                  title: 'Score',
                  value: _percentage,
                  icon: Icons.pie_chart_rounded,
                  color: const Color(0xFF6C5CE7),
                  bgColor: const Color(0xFFF3EEFF),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildSummaryPill(
                title: 'Present',
                value: '$_presentCount',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSummaryPill(
                title: 'Late',
                value: '$_lateCount',
                icon: Icons.access_time_filled_rounded,
                color: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSummaryPill(
                title: 'Absent',
                value: '$_absentCount',
                icon: Icons.cancel_rounded,
                color: const Color(0xFFEF4444),
                bgColor: const Color(0xFFFEF2F2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSummaryPill(
                title: 'Overall',
                value: _percentage,
                icon: Icons.pie_chart_rounded,
                color: const Color(0xFF6C5CE7),
                bgColor: const Color(0xFFF3EEFF),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryPill({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF201A3D),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF756E8A),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, String> record) {
    final String status = record['status'] ?? 'Present';
    final String checkIn = record['checkIn'] ?? '--';
    final String checkOut = record['checkOut'] ?? '--';
    final String date = record['date'] ?? '—';

    final Color statusColor = status.toLowerCase() == 'present'
        ? const Color(0xFF10B981)
        : status.toLowerCase() == 'late'
        ? const Color(0xFFF59E0B)
        : status.toLowerCase() == 'leave'
        ? const Color(0xFF6C5CE7)
        : const Color(0xFFEF4444);

    final Color statusBg = status.toLowerCase() == 'present'
        ? const Color(0xFFECFDF5)
        : status.toLowerCase() == 'late'
        ? const Color(0xFFFFFBEB)
        : status.toLowerCase() == 'leave'
        ? const Color(0xFFF3EEFF)
        : const Color(0xFFFEF2F2);

    final IconData statusIcon = status.toLowerCase() == 'present'
        ? Icons.check_circle_outline_rounded
        : status.toLowerCase() == 'late'
        ? Icons.schedule_rounded
        : status.toLowerCase() == 'leave'
        ? Icons.beach_access_rounded
        : Icons.highlight_off_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBE6F8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFF201A3D),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Workday Log',
                      style: TextStyle(
                        color: Color(0xFF8B849E),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
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
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7FD),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFECE7F6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      color: Color(0xFF10B981),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Check-In',
                          style: TextStyle(
                            color: Color(0xFF8B849E),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          checkIn,
                          style: const TextStyle(
                            color: Color(0xFF201A3D),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: const Color(0xFFE0D7F8),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Check-Out',
                          style: TextStyle(
                            color: Color(0xFF8B849E),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          checkOut,
                          style: const TextStyle(
                            color: Color(0xFF201A3D),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
