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
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : 20,
            isMobile ? 14 : 18,
            isMobile ? 14 : 24,
            isMobile ? 18 : 22,
          ),
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
    final List<double> values = [78, 88, 82, 96, 90, 84, 92];
    final List<String> labels = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    ];

    const double leftPadding = 32.0;
    const double rightPadding = 18.0;
    const double topPadding = 26.0;
    const double bottomPadding = 28.0;

    final double plotWidth = size.width - leftPadding - rightPadding;
    final double plotHeight = size.height - topPadding - bottomPadding;
    final double chartBottom = topPadding + plotHeight;

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 1. Draw horizontal reference gridlines & Y-axis labels
    final List<int> yTicks = [100, 75, 50, 25, 0];
    final Paint gridLinePaint = Paint()
      ..color = const Color(0xffE2E8F0).withValues(alpha: 0.8)
      ..strokeWidth = 1.0;

    for (final int tick in yTicks) {
      final double y = topPadding + (1.0 - (tick / 100.0)) * plotHeight;

      // Draw subtle horizontal dashed-style grid line
      const double dashWidth = 4.0;
      const double dashSpace = 4.0;
      double startX = leftPadding;
      while (startX < size.width - rightPadding) {
        canvas.drawLine(
          Offset(startX, y),
          Offset(
            (startX + dashWidth).clamp(leftPadding, size.width - rightPadding),
            y,
          ),
          gridLinePaint,
        );
        startX += dashWidth + dashSpace;
      }

      // Draw Y-axis percentage text
      textPainter.text = TextSpan(
        text: "$tick%",
        style: const TextStyle(
          color: Color(0xff94A3B8),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    // 2. Compute smooth plot points
    final List<Offset> points = [];
    final double stepX = plotWidth / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final double px = leftPadding + i * stepX;
      final double py = topPadding + (1.0 - (values[i] / 100.0)) * plotHeight;
      points.add(Offset(px, py));
    }

    // 3. Build smooth Cubic Spline Curve Path
    final Path curvePath = Path();
    curvePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final Offset p0 = points[i];
      final Offset p1 = points[i + 1];

      final double controlDx = (p1.dx - p0.dx) * 0.45;
      final Offset cp1 = Offset(p0.dx + controlDx, p0.dy);
      final Offset cp2 = Offset(p1.dx - controlDx, p1.dy);

      curvePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    // 4. Draw vibrant gradient Area Fill under the curve
    final Path areaPath = Path.from(curvePath);
    areaPath.lineTo(points.last.dx, chartBottom);
    areaPath.lineTo(points.first.dx, chartBottom);
    areaPath.close();

    final Paint areaPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xff2563EB).withValues(alpha: 0.32),
          const Color(0xff7C3AED).withValues(alpha: 0.10),
          const Color(0xff7C3AED).withValues(alpha: 0.00),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
        Rect.fromLTWH(leftPadding, topPadding, plotWidth, plotHeight),
      );

    canvas.drawPath(areaPath, areaPaint);

    // 5. Draw soft glowing shadow under the curve
    final Paint glowPaint = Paint()
      ..color = const Color(0xff6366F1).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(curvePath, glowPaint);

    // 6. Draw the primary Spline Line Stroke with linear gradient
    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [
          Color(0xff2563EB),
          Color(0xff6366F1),
          Color(0xff9333EA),
        ],
      ).createShader(
        Rect.fromLTWH(leftPadding, topPadding, plotWidth, plotHeight),
      );

    canvas.drawPath(curvePath, strokePaint);

    // Find peak point index
    int maxIndex = 0;
    double maxVal = values[0];
    for (int i = 1; i < values.length; i++) {
      if (values[i] > maxVal) {
        maxVal = values[i];
        maxIndex = i;
      }
    }

    // 7. Draw data nodes, subtle drop guides & X-axis labels
    for (int i = 0; i < points.length; i++) {
      final Offset pt = points[i];
      final bool isPeak = i == maxIndex;

      // Vertical guide line from node to bottom
      final Paint dropPaint = Paint()
        ..color = isPeak
            ? const Color(0xff6366F1).withValues(alpha: 0.45)
            : const Color(0xffE2E8F0).withValues(alpha: 0.6)
        ..strokeWidth = isPeak ? 1.4 : 1.0;

      canvas.drawLine(Offset(pt.dx, pt.dy + 7), Offset(pt.dx, chartBottom), dropPaint);

      // Node Halo Outer
      canvas.drawCircle(
        pt,
        isPeak ? 8.5 : 6.5,
        Paint()
          ..color = isPeak
              ? const Color(0xff6366F1).withValues(alpha: 0.25)
              : const Color(0xff2563EB).withValues(alpha: 0.15),
      );

      // Node White border ring
      canvas.drawCircle(
        pt,
        isPeak ? 5.2 : 4.2,
        Paint()..color = Colors.white,
      );

      // Node Center Dot
      canvas.drawCircle(
        pt,
        isPeak ? 3.4 : 2.6,
        Paint()
          ..color = isPeak ? const Color(0xff9333EA) : const Color(0xff2563EB),
      );

      // Draw Peak Tooltip Badge above the highest point
      if (isPeak) {
        const double badgeW = 38.0;
        const double badgeH = 20.0;
        final double badgeX = pt.dx - badgeW / 2;
        final double badgeY = pt.dy - badgeH - 8;

        // Badge pill background
        final RRect badgeRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(badgeX, badgeY, badgeW, badgeH),
          const Radius.circular(10),
        );
        canvas.drawRRect(
          badgeRRect,
          Paint()..color = const Color(0xff0F172A),
        );

        // Badge downward pointer triangle
        final Path pointerPath = Path()
          ..moveTo(pt.dx - 3.5, badgeY + badgeH)
          ..lineTo(pt.dx + 3.5, badgeY + badgeH)
          ..lineTo(pt.dx, badgeY + badgeH + 3.5)
          ..close();
        canvas.drawPath(pointerPath, Paint()..color = const Color(0xff0F172A));

        // Badge Text
        textPainter.text = TextSpan(
          text: "${values[i].toInt()}%",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            badgeX + (badgeW - textPainter.width) / 2,
            badgeY + (badgeH - textPainter.height) / 2,
          ),
        );
      }

      // X-Axis Day Labels
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: isPeak ? const Color(0xff2563EB) : const Color(0xff64748B),
          fontSize: size.width < 400 ? 9.5 : 10.5,
          fontWeight: isPeak ? FontWeight.w700 : FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pt.dx - textPainter.width / 2, size.height - 18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ModernAttendanceChartPainter oldDelegate) {
    return false;
  }
}
