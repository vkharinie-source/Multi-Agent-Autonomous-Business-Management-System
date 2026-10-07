import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyPerformanceScreen extends StatelessWidget {
  const MyPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const List<_PerformanceMetric> metrics = [
      _PerformanceMetric(
        title: 'Task Completion',
        subtitle: '23 of 25 Tasks Done',
        value: 0.92,
        displayValue: '92%',
        icon: Icons.task_alt_rounded,
        gradient: [Color(0xFF2563EB), Color(0xFF38BDF8)],
        badgeColor: Color(0xFFEFF6FF),
      ),
      _PerformanceMetric(
        title: 'Attendance',
        subtitle: '22 of 23 Days Present',
        value: 0.94,
        displayValue: '94%',
        icon: Icons.calendar_today_rounded,
        gradient: [Color(0xFF059669), Color(0xFF34D399)],
        badgeColor: Color(0xFFECFDF5),
      ),
      _PerformanceMetric(
        title: 'Work Quality',
        subtitle: 'High Precision & Detail',
        value: 0.88,
        displayValue: '88%',
        icon: Icons.star_rounded,
        gradient: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
        badgeColor: Color(0xFFF5F3FF),
      ),
      _PerformanceMetric(
        title: 'Team Collaboration',
        subtitle: 'Active Communication',
        value: 0.90,
        displayValue: '90%',
        icon: Icons.groups_rounded,
        gradient: [Color(0xFFD97706), Color(0xFFFBBF24)],
        badgeColor: Color(0xFFFFFBEB),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FC),
      body: SafeArea(
        child: Stack(
          children: [
            // Background ambient glow circles
            Positioned(
              top: -90,
              right: -70,
              child: _buildGlowCircle(
                size: 260,
                color: const Color(0xFF7B61FF).withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              bottom: -110,
              left: -80,
              child: _buildGlowCircle(
                size: 280,
                color: const Color(0xFFB66DFF).withValues(alpha: 0.08),
              ),
            ),

            Column(
              children: [
                // Top Custom Header
                _buildHeader(context),

                // Main Content List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    children: [
                      // Overall Performance Score Radial Hero Card
                      _buildOverallScoreHeroCard(),

                      const SizedBox(height: 22),

                      // Circular Charts Grid Header
                      const Row(
                        children: [
                          Icon(
                            Icons.donut_large_rounded,
                            color: Color(0xFF6C5CE7),
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Performance Breakdown',
                            style: TextStyle(
                              color: Color(0xFF201A3D),
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 2x2 Circular Progress Chart Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.88,
                            ),
                        itemCount: metrics.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildCircularMetricCard(metrics[index]);
                        },
                      ),

                      const SizedBox(height: 22),

                      // Manager Feedback Section Card
                      _buildManagerFeedbackCard(),

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Performance',
                style: GoogleFonts.inter(
                  color: const Color(0xFF201A3D),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Q3 Analytics & Evaluation',
                style: GoogleFonts.inter(color: const Color(0xFF756E8A), fontSize: 12),
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
                  Icons.verified_rounded,
                  color: Color(0xFF6C5CE7),
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'Top Performer',
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

  Widget _buildOverallScoreHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Score Gauge Ring
          SizedBox(
            width: 105,
            height: 105,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 105,
                  height: 105,
                  child: CircularProgressIndicator(
                    value: 0.90,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    color: const Color(0xFF55E6C1),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '90',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'out of 100',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Overall Rating',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Excellent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF55E6C1),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+5% higher than last month',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildCircularMetricCard(_PerformanceMetric metric) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEBE6F8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular Donut Progress Ring with Icon/Percentage inside
          SizedBox(
            width: 78,
            height: 78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(78, 78),
                  painter: _RadialChartPainter(
                    progress: metric.value,
                    gradientColors: metric.gradient,
                    trackColor: const Color(0xFFF0ECFA),
                    strokeWidth: 8,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(metric.icon, color: metric.gradient.first, size: 20),
                    const SizedBox(height: 2),
                    Text(
                      metric.displayValue,
                      style: TextStyle(
                        color: metric.gradient.first,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Title
          Text(
            metric.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF201A3D),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          // Subtitle detail
          Text(
            metric.subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8B849E),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEBE6F8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF9B6CFF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.format_quote_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manager Feedback',
                      style: TextStyle(
                        color: Color(0xFF201A3D),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Quarterly Evaluation',
                      style: TextStyle(color: Color(0xFF8B849E), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7FE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECE6F8)),
            ),
            child: const Text(
              '"Consistently completes assigned tasks with high accuracy and collaborates exceptionally well with the team."',
              style: TextStyle(
                color: Color(0xFF4C4366),
                fontSize: 13,
                height: 1.5,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
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

class _PerformanceMetric {
  const _PerformanceMetric({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.displayValue,
    required this.icon,
    required this.gradient,
    required this.badgeColor,
  });

  final String title;
  final String subtitle;
  final double value;
  final String displayValue;
  final IconData icon;
  final List<Color> gradient;
  final Color badgeColor;
}

/// Custom painter to draw smooth circular radial progress ring charts
class _RadialChartPainter extends CustomPainter {
  _RadialChartPainter({
    required this.progress,
    required this.gradientColors,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final List<Color> gradientColors;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width - strokeWidth) / 2;

    // Draw background track ring
    final Paint trackPaint =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw foreground progress ring gradient
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Gradient gradient = SweepGradient(
      colors: gradientColors,
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + (2 * math.pi * progress),
      transform: GradientRotation(-math.pi / 2),
    );

    final Paint progressPaint =
        Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

    final double sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gradientColors != gradientColors;
  }
}

