import 'package:flutter/material.dart';

class MyLeaveScreen extends StatelessWidget {
  const MyLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> leaves = [
      {
        'type': 'Sick Leave',
        'date': '23 July 2026',
        'days': '1 Day',
        'status': 'Approved',
        'reason': 'Medical checkup',
      },
      {
        'type': 'Casual Leave',
        'date': '15 July 2026',
        'days': '2 Days',
        'status': 'Pending',
        'reason': 'Family function',
      },
      {
        'type': 'Personal Leave',
        'date': '04 July 2026',
        'days': '1 Day',
        'status': 'Rejected',
        'reason': 'Personal work',
      },
    ];

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
                // Top Custom Header Navigation Bar
                _buildHeader(context),

                // Main Scrollable List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    children: [
                      // Hero Available Leave Balance Card
                      _buildLeaveBalanceHeroCard(),

                      const SizedBox(height: 22),

                      // Leave Requests Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.event_note_rounded,
                                color: Color(0xFF6C5CE7),
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Leave Requests',
                                style: TextStyle(
                                  color: Color(0xFF201A3D),
                                  fontSize: 19,
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
                            child: const Text(
                              '3 Submissions',
                              style: TextStyle(
                                color: Color(0xFF6C5CE7),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Leave Request Cards
                      ...leaves.map((Map<String, String> leave) {
                        return _buildLeaveRequestCard(context, leave);
                      }),

                      const SizedBox(height: 24),
                    ],
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
            onPressed: () {
              Navigator.of(context).maybePop();
            },
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Leave',
                style: TextStyle(
                  color: Color(0xFF201A3D),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Time Off & Balance Management',
                style: TextStyle(color: Color(0xFF756E8A), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_available_rounded,
                  color: Color(0xFF6C5CE7),
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  '2026 Quota',
                  style: TextStyle(
                    color: Color(0xFF6C5CE7),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveBalanceHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF35168A), Color(0xFF6C5CE7), Color(0xFF8E5BEF)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative circle
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flight_takeoff_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Available Leave Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
                      color: const Color(0xFF55E6C1).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '8 Remaining',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '8',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Days',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildQuotaStat(
                    title: 'Total Quota',
                    value: '20 Days',
                    icon: Icons.calendar_month_rounded,
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.2),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  _buildQuotaStat(
                    title: 'Used Leave',
                    value: '12 Days',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaStat({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF55E6C1), size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeaveRequestCard(
    BuildContext context,
    Map<String, String> leave,
  ) {
    final String status = leave['status']!;

    final Color statusColor = status == 'Approved'
        ? const Color(0xFF10B981)
        : status == 'Pending'
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    final Color statusBg = status == 'Approved'
        ? const Color(0xFFECFDF5)
        : status == 'Pending'
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFFEF2F2);

    final IconData statusIcon = status == 'Approved'
        ? Icons.check_circle_rounded
        : status == 'Pending'
        ? Icons.hourglass_top_rounded
        : Icons.cancel_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEBE6F8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leave['type']!,
                  style: const TextStyle(
                    color: Color(0xFF201A3D),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${leave['date']} • ${leave['days']}',
                  style: const TextStyle(
                    color: Color(0xFF8B849E),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
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

