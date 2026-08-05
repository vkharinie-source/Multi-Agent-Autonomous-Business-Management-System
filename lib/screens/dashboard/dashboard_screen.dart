import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const double _mobileBreakpoint = 700;
  static const double _tabletBreakpoint = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < _mobileBreakpoint;
          final isTablet =
              !isMobile && constraints.maxWidth < _tabletBreakpoint;
          final stackedWide = isMobile || isTablet;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                welcomeSection(isMobile),
                SizedBox(height: isMobile ? 18 : 24),
                overviewCards(isMobile),
                SizedBox(height: isMobile ? 18 : 24),
                aiRecommendationCards(isMobile),
                SizedBox(height: isMobile ? 18 : 24),
                stackedWide
                    ? Column(
                        children: [
                          weeklyChart(isMobile),
                          const SizedBox(height: 22),
                          businessHealth(isMobile),
                        ],
                      )
                    : IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: weeklyChart(isMobile)),
                            const SizedBox(width: 22),
                            Expanded(child: businessHealth(isMobile)),
                          ],
                        ),
                      ),
                SizedBox(height: isMobile ? 18 : 24),
                stackedWide
                    ? Column(
                        children: [
                          notifications(),
                          const SizedBox(height: 22),
                          recentActivities(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: notifications()),
                          const SizedBox(width: 22),
                          Expanded(child: recentActivities()),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget welcomeSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff020A3D), Color(0xff2563EB), Color(0xff9333EA)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isMobile ? 26 : 34,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: const Color(0xff2563EB),
              size: isMobile ? 26 : 36,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, Harinie ðŸ‘‹",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 20 : 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Here is your AI-powered business overview for today.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 13 : 16,
                  ),
                  maxLines: isMobile ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const Spacer(),
            const Icon(Icons.auto_awesome, color: Colors.white, size: 44),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Metric cards
  //
  // IMPORTANT: metricCardContent() returns PLAIN content (no Expanded
  // baked in). Expanded is only valid as a direct child of a Row/Column,
  // so it must be added by whoever places the card into a Flex â€” never
  // by the card itself. This is what previously crashed on mobile widths
  // (Expanded ended up inside a SizedBox, which isn't a Flex).
  // ---------------------------------------------------------------------

  Widget overviewCards(bool isMobile) {
    final rowOne = [
      _MetricData(
        "Today's Sales",
        "â‚¹24,850",
        "+18%",
        Icons.trending_up,
        Colors.green,
      ),
      _MetricData(
        "Revenue",
        "â‚¹3.2L",
        "+12%",
        Icons.currency_rupee,
        Colors.blue,
      ),
      _MetricData(
        "Expenses",
        "â‚¹86,000",
        "-4%",
        Icons.money_off,
        Colors.orange,
      ),
      _MetricData("Profit", "â‚¹1.4L", "+9%", Icons.savings, Colors.purple),
    ];

    final rowTwo = [
      _MetricData("Customers", "2,340", "+52", Icons.people, Colors.teal),
      _MetricData("Employees", "48", "+3", Icons.badge, Colors.indigo),
      _MetricData(
        "Inventory",
        "320 Items",
        "5 Low",
        Icons.inventory_2,
        Colors.deepOrange,
      ),
      _MetricData("Pending Tasks", "12", "Today", Icons.task_alt, Colors.red),
    ];

    if (isMobile) {
      return Column(
        children: [
          _metricScrollRow(rowOne),
          const SizedBox(height: 14),
          _metricScrollRow(rowTwo),
        ],
      );
    }

    return Column(
      children: [
        _metricDesktopRow(rowOne),
        const SizedBox(height: 18),
        _metricDesktopRow(rowTwo),
      ],
    );
  }

  // Desktop / tablet: cards share the row equally.
  Widget _metricDesktopRow(List<_MetricData> items) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(width: 18),
          Expanded(
            child: metricCardContent(
              items[i].title,
              items[i].value,
              items[i].change,
              items[i].icon,
              items[i].color,
            ),
          ),
        ],
      ],
    );
  }

  // Mobile: cards scroll horizontally with a fixed width each.
  Widget _metricScrollRow(List<_MetricData> items) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 14);
        },
        itemBuilder: (context, index) {
          final it = items[index];
          return SizedBox(
            width: 200,
            child: metricCardContent(
              it.title,
              it.value,
              it.change,
              it.icon,
              it.color,
            ),
          );
        },
      ),
    );
  }

  Widget metricCardContent(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: card(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff081A63),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  change,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // AI recommendation cards
  //
  // Same fix as above: no Expanded baked into aiCardContent(). On mobile
  // these stack in a Column that lives inside a SingleChildScrollView,
  // which gives it unbounded height â€” an Expanded there used to crash
  // with "RenderFlex children have non-zero flex but incoming height
  // constraints are unbounded."
  // ---------------------------------------------------------------------

  Widget aiRecommendationCards(bool isMobile) {
    final items = [
      _AiData(
        "Sales Agent",
        "Sales may increase by 18% this week. Continue current offer campaign.",
        Icons.trending_up,
        Colors.green,
      ),
      _AiData(
        "Inventory Agent",
        "Laptop stock is low. Suggested reorder quantity: 20 units.",
        Icons.inventory,
        Colors.orange,
      ),
      _AiData(
        "Finance Agent",
        "Expenses are 4% lower this week. Cash flow looks stable.",
        Icons.account_balance_wallet,
        Colors.blue,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i != 0) const SizedBox(height: 14),
            aiCardContent(
              items[i].title,
              items[i].text,
              items[i].icon,
              items[i].color,
            ),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i != 0) const SizedBox(width: 18),
          Expanded(
            child: aiCardContent(
              items[i].title,
              items[i].text,
              items[i].icon,
              items[i].color,
            ),
          ),
        ],
      ],
    );
  }

  Widget aiCardContent(String title, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.12), Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(color: Colors.grey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget weeklyChart(bool isMobile) {
    return Container(
      height: isMobile ? 300 : 360,
      padding: EdgeInsets.all(isMobile ? 18 : 26),
      decoration: card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Charts",
            style: TextStyle(
              fontSize: isMobile ? 19 : 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff081A63),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Sales and revenue performance",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: CustomPaint(
              painter: DashboardChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget businessHealth(bool isMobile) {
    return Container(
      height: isMobile ? null : 360,
      padding: EdgeInsets.all(isMobile ? 18 : 26),
      decoration: card(),
      child: Column(
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Business Health Score",
            style: TextStyle(
              fontSize: isMobile ? 19 : 23,
              fontWeight: FontWeight.bold,
              color: const Color(0xff081A63),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: isMobile ? 140 : 170,
                  height: isMobile ? 140 : 170,
                  child: CircularProgressIndicator(
                    value: 0.86,
                    strokeWidth: 16,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xff10B981),
                  ),
                ),
                Text(
                  "86%",
                  style: TextStyle(
                    fontSize: isMobile ? 30 : 38,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff081A63),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          statusRow("Active AI Agents", "5", Colors.green),
          statusRow("Pending Tasks", "12", Colors.orange),
          statusRow("Low Stock Items", "5", Colors.red),
        ],
      ),
    );
  }

  Widget statusRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(radius: 7, backgroundColor: color),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget notifications() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Notifications",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xff081A63),
            ),
          ),
          const SizedBox(height: 18),
          item(Icons.warning, "Low stock alert for Laptop", Colors.orange),
          item(Icons.task, "12 tasks pending today", Colors.blue),
          item(
            Icons.payments,
            "Monthly finance report generated",
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget recentActivities() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activities",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xff081A63),
            ),
          ),
          const SizedBox(height: 18),
          item(Icons.person_add, "New employee added", Colors.purple),
          item(Icons.shopping_cart, "New sale order created", Colors.green),
          item(Icons.inventory_2, "Inventory updated", Colors.orange),
        ],
      ),
    );
  }

  Widget item(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  BoxDecoration card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}

// Simple data holders for the metric / AI cards â€” keeps overviewCards()
// and aiRecommendationCards() free of duplicated literals between the
// mobile and desktop layouts.
class _MetricData {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  const _MetricData(this.title, this.value, this.change, this.icon, this.color);
}

class _AiData {
  final String title;
  final String text;
  final IconData icon;
  final Color color;

  const _AiData(this.title, this.text, this.icon, this.color);
}

class DashboardChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final values = [80.0, 130.0, 100.0, 180.0, 160.0, 230.0, 210.0];
    final labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const maxValue = 250.0;
    final chartHeight = size.height - 35;
    final gap = size.width / (values.length - 1);

    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.18)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = chartHeight * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    final fill = Path();

    for (int i = 0; i < values.length; i++) {
      final x = i * gap;
      final y = chartHeight - (values[i] / maxValue * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, chartHeight);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }

    fill.lineTo(size.width, chartHeight);
    fill.close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xff2563EB).withValues(alpha: 0.25),
            const Color(0xff9333EA).withValues(alpha: 0.03),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xff2563EB), Color(0xff9333EA)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight))
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < labels.length; i++) {
      final x = i * gap;
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 14, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
