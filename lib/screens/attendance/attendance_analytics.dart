import 'package:flutter/material.dart';

class AttendanceAnalyticsScreen extends StatelessWidget {
  const AttendanceAnalyticsScreen({super.key});

  static const Color pageBackground = Color(0xffF5F7FC);
  static const Color darkBlue = Color(0xff0B1F51);
  static const Color primaryBlue = Color(0xff2563EB);
  static const Color purple = Color(0xff7C3AED);
  static const Color green = Color(0xff16A34A);
  static const Color orange = Color(0xffF59E0B);
  static const Color red = Color(0xffEF4444);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 700;
          final bool isTablet =
              constraints.maxWidth >= 700 && constraints.maxWidth < 1050;

          return Column(
            children: [
              _header(context, isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14 : 24,
                    vertical: isMobile ? 16 : 22,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _pageTitle(isMobile),
                          SizedBox(height: isMobile ? 14 : 18),

                          _summaryGrid(isMobile: isMobile, isTablet: isTablet),

                          SizedBox(height: isMobile ? 16 : 20),

                          _mainAnalyticsSection(
                            isMobile: isMobile,
                            isTablet: isTablet,
                          ),

                          SizedBox(height: isMobile ? 16 : 20),

                          _departmentSection(
                            isMobile: isMobile,
                            isTablet: isTablet,
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
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

  Widget _header(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 6 : 20,
        isMobile ? 12 : 18,
        isMobile ? 12 : 24,
        isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff071442), Color(0xff1D4ED8), Color(0xff7C3AED)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isMobile ? 22 : 28),
          bottomRight: Radius.circular(isMobile ? 22 : 28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: EdgeInsets.all(isMobile ? 9 : 11),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.insights_rounded,
                    color: Colors.white,
                    size: isMobile ? 24 : 29,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Attendance Analytics",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 20 : 27,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isMobile
                            ? "Smart attendance insights"
                            : "Track employee presence, punctuality and department performance",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isMobile ? 11 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMobile)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 4,
                          backgroundColor: Color(0xff4ADE80),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Live data",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageTitle(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Attendance Overview",
                style: TextStyle(
                  color: darkBlue,
                  fontSize: isMobile ? 21 : 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Monitor workforce attendance and punctuality",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isMobile ? 11 : 13,
                ),
              ),
            ],
          ),
        ),
        if (!isMobile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffE5EAF2)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: primaryBlue,
                  size: 19,
                ),
                SizedBox(width: 8),
                Text(
                  "This Week",
                  style: TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 5),
                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              ],
            ),
          ),
      ],
    );
  }

  Widget _summaryGrid({required bool isMobile, required bool isTablet}) {
    final int columns = isMobile || isTablet ? 2 : 4;

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 10 : 14,
      mainAxisSpacing: isMobile ? 10 : 14,
      childAspectRatio: isMobile ? 1.28 : 2.25,
      children: [
        _summaryCard(
          title: "Present Rate",
          value: "82%",
          change: "+6.4%",
          caption: "Compared to last week",
          icon: Icons.check_circle_rounded,
          color: green,
          isMobile: isMobile,
        ),
        _summaryCard(
          title: "Absent Rate",
          value: "8%",
          change: "-2.1%",
          caption: "Compared to last week",
          icon: Icons.cancel_rounded,
          color: red,
          isMobile: isMobile,
        ),
        _summaryCard(
          title: "Late Arrivals",
          value: "10%",
          change: "+1.2%",
          caption: "Requires attention",
          icon: Icons.schedule_rounded,
          color: orange,
          isMobile: isMobile,
        ),
        _summaryCard(
          title: "Average Check-in",
          value: "09:08",
          change: "AM",
          caption: "Office time: 09:00 AM",
          icon: Icons.timer_rounded,
          color: purple,
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String change,
    required String caption,
    required IconData icon,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 17),
      decoration: _cardDecoration(),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconBox(icon, color, 20),
                    const Spacer(),
                    _changeBadge(change, color),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                _iconBox(icon, color, 25),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: darkBlue,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          _changeBadge(change, color),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _mainAnalyticsSection({
    required bool isMobile,
    required bool isTablet,
  }) {
    if (isMobile) {
      return Column(
        children: [
          _trendCard(true),
          const SizedBox(height: 15),
          _insightCard(true),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: isTablet ? 6 : 7, child: _trendCard(false)),
        const SizedBox(width: 16),
        Expanded(flex: isTablet ? 4 : 3, child: _insightCard(false)),
      ],
    );
  }

  Widget _trendCard(bool isMobile) {
    return Container(
      width: double.infinity,
      height: isMobile ? 320 : 370,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.auto_graph_rounded, primaryBlue, 22),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weekly Attendance",
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: isMobile ? 18 : 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Daily employee presence trend",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "+6.4%",
                  style: TextStyle(
                    color: green,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: ModernAttendanceChartPainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightCard(bool isMobile) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 0 : 370),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffEEF4FF), Color(0xffF6F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffD9DDFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [primaryBlue, purple]),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  "AI Insights",
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: isMobile ? 18 : 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _insightTile(
            icon: Icons.trending_up_rounded,
            title: "Attendance improved",
            description: "Overall attendance increased by 6.4%.",
            color: green,
          ),
          _insightTile(
            icon: Icons.warning_amber_rounded,
            title: "Sales needs attention",
            description: "Highest late-arrival rate this week.",
            color: orange,
          ),
          _insightTile(
            icon: Icons.workspace_premium_rounded,
            title: "Best department",
            description: "IT maintains 94% attendance.",
            color: primaryBlue,
          ),
          _insightTile(
            icon: Icons.notifications_active_rounded,
            title: "Smart reminder",
            description: "Send alerts before 9:00 AM.",
            color: purple,
          ),
        ],
      ),
    );
  }

  Widget _insightTile({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 9,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _departmentSection({required bool isMobile, required bool isTablet}) {
    final List<Map<String, dynamic>> departments = [
      {
        "name": "Information Technology",
        "short": "IT",
        "value": 94,
        "employees": 18,
        "icon": Icons.computer_rounded,
        "color": primaryBlue,
      },
      {
        "name": "Finance",
        "short": "Finance",
        "value": 91,
        "employees": 10,
        "icon": Icons.account_balance_wallet_rounded,
        "color": purple,
      },
      {
        "name": "Sales",
        "short": "Sales",
        "value": 88,
        "employees": 14,
        "icon": Icons.trending_up_rounded,
        "color": green,
      },
      {
        "name": "Human Resources",
        "short": "HR",
        "value": 86,
        "employees": 6,
        "icon": Icons.groups_rounded,
        "color": orange,
      },
    ];

    final int columns = isMobile
        ? 1
        : isTablet
        ? 2
        : 4;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Department Performance",
            style: TextStyle(
              color: darkBlue,
              fontSize: isMobile ? 19 : 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Attendance performance across departments",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: departments.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 2.7 : 1.75,
            ),
            itemBuilder: (context, index) {
              final item = departments[index];
              final Color color = item["color"] as Color;
              final int value = item["value"] as int;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.055),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: color.withValues(alpha: 0.14)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _iconBox(item["icon"] as IconData, color, 21),
                        const Spacer(),
                        Text(
                          "$value%",
                          style: TextStyle(
                            color: color,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      isMobile
                          ? item["name"].toString()
                          : item["short"].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${item["employees"]} employees",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 9),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: value / 100,
                        minHeight: 8,
                        backgroundColor: color.withValues(alpha: 0.12),
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color, double size) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }

  Widget _changeBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xffE8ECF4)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xff0F172A).withValues(alpha: 0.055),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }
}

class ModernAttendanceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final List<double> values = [72, 84, 77, 92, 87, 80, 89];

    final List<String> labels = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    ];

    final double chartHeight = size.height - 27;
    final double gap = size.width / values.length;
    final double barWidth = gap * 0.34;

    final Paint gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.13)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final double y = chartHeight * i / 5;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final List<Offset> points = [];

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < values.length; i++) {
      final double x = i * gap + (gap - barWidth) / 2;

      final double barHeight = values[i] / 100 * chartHeight;

      final double y = chartHeight - barHeight;

      final RRect backgroundRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, barWidth, chartHeight),
        const Radius.circular(12),
      );

      canvas.drawRRect(
        backgroundRect,
        Paint()..color = const Color(0xffEEF2FF),
      );

      final RRect barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(12),
      );

      final Paint barPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xff2563EB), Color(0xff7C3AED)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

      canvas.drawRRect(barRect, barPaint);

      points.add(Offset(x + barWidth / 2, y));

      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: size.width < 400 ? 9 : 10,
        ),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, size.height - 16),
      );
    }

    final Path linePath = Path();

    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xff10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round,
    );

    for (final Offset point in points) {
      canvas.drawCircle(point, 5, Paint()..color = Colors.white);

      canvas.drawCircle(
        point,
        5,
        Paint()
          ..color = const Color(0xff10B981)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ModernAttendanceChartPainter oldDelegate) {
    return false;
  }
}
