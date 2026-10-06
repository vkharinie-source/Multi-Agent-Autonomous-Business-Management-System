import 'package:flutter/material.dart';
import '../attendance/attendance_dashboard.dart';
import '../chatbot/chatbot_screen.dart';
import '../employee/employee_management_screen.dart';
import '../finance/finance_screen.dart';
import '../inventory/inventory_screen.dart';
import '../marketing/marketing_screen.dart';
import '../reports/reports_screen.dart';
import '../sales/sales_screen.dart';
import '../settings/settings_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const double _mobileBreakpoint = 850;
  static const double _tabletBreakpoint = 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < _mobileBreakpoint;
        final isTablet = !isMobile && constraints.maxWidth < _tabletBreakpoint;
        final stackedWide = isMobile || isTablet;

        return Scaffold(
          backgroundColor: const Color(0xffF3F6FF),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xff2563EB),
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.smart_toy_rounded),
            label: const Text(
              "AI Agent",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatbotScreen()),
              );
            },
          ),
          // On mobile the sidebar becomes a slide-out drawer instead of a
          // fixed 265px column, and an AppBar provides the menu button.
          appBar: isMobile
              ? AppBar(
                  backgroundColor: const Color(0xff020A3D),
                  title: const Text(
                    "Business Dashboard",
                    style: TextStyle(color: Colors.white),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                )
              : null,
          drawer: isMobile
              ? Drawer(child: _sidebar(context, isMobile: true))
              : null,
          body: Row(
            children: [
              if (!isMobile) _sidebar(context, isMobile: false),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(isMobile, isTablet),
                      SizedBox(height: isMobile ? 16 : 24),

                      _statCardsRow(isMobile, constraints.maxWidth - (isMobile ? 32 : 320)),

                      SizedBox(height: isMobile ? 16 : 24),

                      stackedWide
                          ? Column(
                              children: [
                                _salesCard(isMobile),
                                const SizedBox(height: 22),
                                _rightColumn(),
                              ],
                            )
                          : IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _salesCard(isMobile),
                                  ),
                                  const SizedBox(width: 22),
                                  Expanded(child: _rightColumn()),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sidebar(BuildContext context, {required bool isMobile}) {
    return Container(
      width: isMobile ? null : 265,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff020A3D), Color(0xff123BD8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) ...[
            const Icon(Icons.auto_graph, color: Colors.white, size: 48),
            const SizedBox(height: 18),
            const Text(
              "Autonomous\nBusiness AI",
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 35),
          ] else
            const SizedBox(height: 8),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _menu(Icons.dashboard, "Dashboard", true),

                  GestureDetector(
                    onTap: () {
                      if (isMobile) Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const EmployeeManagementScreen(),
                        ),
                      );
                    },
                    child: _menu(Icons.badge, "Employees", false),
                  ),

                  GestureDetector(
                    onTap: () {
                      if (isMobile) Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AttendanceDashboard(),
                        ),
                      );
                    },
                    child: _menu(Icons.fact_check, "Attendance", false),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SalesDashboard(),
                        ),
                      );
                    },
                    child: _menu(Icons.trending_up, "Sales", false),
                  ),

                  GestureDetector(
                    onTap: () {
                      if (isMobile) {
                        Navigator.pop(context);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const FinanceDashboard();
                          },
                        ),
                      );
                    },
                    child: _menu(Icons.wallet, "Finance", false),
                  ),

                  GestureDetector(
                    onTap: () {
                      if (isMobile) Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InventoryScreen(),
                        ),
                      );
                    },
                    child: _menu(Icons.inventory_2, "Inventory", false),
                  ),

                  GestureDetector(
                    onTap: () {
                      if (isMobile) {
                        Navigator.pop(context);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const MarketingDashboard();
                          },
                        ),
                      );
                    },
                    child: _menu(Icons.campaign, "Marketing", false),
                  ),

                  GestureDetector(
                    onTap: () {
                      if (isMobile) {
                        Navigator.pop(context);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const ChatbotScreen();
                          },
                        ),
                      );
                    },
                    child: _menu(Icons.smart_toy, "AI Agents", false),
                  ),

                  GestureDetector(
                    onTap: () {
                      if (isMobile) {
                        Navigator.pop(context);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const ReportsDashboard();
                          },
                        ),
                      );
                    },
                    child: _menu(Icons.bar_chart, "Reports", false),
                  ),

                  GestureDetector(
                    onTap: () {
                      if (isMobile) {
                        Navigator.pop(context);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const SettingsScreen();
                          },
                        ),
                      );
                    },
                    child: _menu(Icons.settings_rounded, "Settings", false),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xff2563EB)),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Harinie",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Administrator",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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

  static Widget _header(bool isMobile, bool isTablet) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome Back 👋",
          style: TextStyle(color: Colors.grey, fontSize: isMobile ? 15 : 18),
        ),
        const SizedBox(height: 6),
        Text(
          "Business Dashboard",
          style: TextStyle(
            fontSize: isMobile ? 24 : (isTablet ? 30 : 36),
            fontWeight: FontWeight.w900,
            color: const Color(0xff081A63),
          ),
        ),
      ],
    );

    final searchBox = Container(
      width: isMobile || isTablet ? double.infinity : 320,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search anything...",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 14),
        ),
      ),
    );

    if (isMobile || isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 16), searchBox],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: title),
        const SizedBox(width: 16),
        searchBox,
      ],
    );
  }

  // Four stat cards: responsive grid / row to prevent pixel overflow
  static Widget _statCardsRow(bool isMobile, double availableWidth) {
    final cardsData = [
      ("Sales", "₹24,850", "+18%", Icons.trending_up, const Color(0xff2563EB)),
      ("Revenue", "₹3.2L", "+12%", Icons.currency_rupee, const Color(0xff8B5CF6)),
      ("Orders", "156", "+25", Icons.shopping_cart, const Color(0xffF97316)),
      ("Customers", "2,340", "+52", Icons.people, const Color(0xff10B981)),
    ];

    if (isMobile) {
      return SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cardsData.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final c = cardsData[index];
            return SizedBox(
              width: 190,
              child: _statCard(c.$1, c.$2, c.$3, c.$4, c.$5),
            );
          },
        ),
      );
    }

    if (availableWidth < 900) {
      // 2x2 Grid for medium / tablet widths
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _statCard(cardsData[0].$1, cardsData[0].$2, cardsData[0].$3, cardsData[0].$4, cardsData[0].$5)),
              const SizedBox(width: 14),
              Expanded(child: _statCard(cardsData[1].$1, cardsData[1].$2, cardsData[1].$3, cardsData[1].$4, cardsData[1].$5)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _statCard(cardsData[2].$1, cardsData[2].$2, cardsData[2].$3, cardsData[2].$4, cardsData[2].$5)),
              const SizedBox(width: 14),
              Expanded(child: _statCard(cardsData[3].$1, cardsData[3].$2, cardsData[3].$3, cardsData[3].$4, cardsData[3].$5)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cardsData.length; i++) ...[
          if (i != 0) const SizedBox(width: 16),
          Expanded(
            child: _statCard(
              cardsData[i].$1,
              cardsData[i].$2,
              cardsData[i].$3,
              cardsData[i].$4,
              cardsData[i].$5,
            ),
          ),
        ],
      ],
    );
  }

  static Widget _statCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: _card(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff081A63),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  change,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _salesCard(bool isMobile) {
    return Container(
      height: isMobile ? 380 : 430,
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sales Analytics",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff081A63),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Revenue Growth & Prediction",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffEEF4FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "This Week",
                        style: TextStyle(
                          color: Color(0xff2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sales Analytics",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff081A63),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Revenue Growth & Prediction",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffEEF4FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "This Week",
                        style: TextStyle(
                          color: Color(0xff2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

          SizedBox(height: isMobile ? 16 : 22),

          Row(
            children: [
              _mini("Revenue", "₹3.2L", "+12%", const Color(0xff2563EB)),
              const SizedBox(width: 14),
              _mini("Profit", "₹86K", "+8%", const Color(0xff10B981)),
              const SizedBox(width: 14),
              _mini("Growth", "64%", "+5%", const Color(0xff8B5CF6)),
            ],
          ),

          SizedBox(height: isMobile ? 18 : 25),

          Expanded(
            child: CustomPaint(
              painter: PremiumChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _mini(String title, String value, String change, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
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
    );
  }

  static Widget _rightColumn() {
    return Column(
      children: [
        Container(
          height: 205,
          padding: const EdgeInsets.all(24),
          decoration: _card(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Insights",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff081A63),
                  ),
                ),
                const SizedBox(height: 18),
                _insight(
                  Icons.trending_up,
                  "Sales may increase by 18% this week.",
                ),
                _insight(
                  Icons.inventory_2,
                  "5 products are running low in stock.",
                ),
                _insight(
                  Icons.campaign,
                  "Marketing Agent suggests festival offers.",
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 22),

        Container(
          height: 205,
          padding: const EdgeInsets.all(24),
          decoration: _card(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Agent Status",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff081A63),
                  ),
                ),
                const SizedBox(height: 18),
                _agent("Sales Agent", "Active", Colors.green),
                _agent("Finance Agent", "Active", Colors.green),
                _agent("Inventory Agent", "Warning", Colors.orange),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _menu(IconData icon, String title, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: active
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 14),
          Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontSize: 16,
              fontWeight: active ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _insight(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xff2563EB).withValues(alpha: 0.12),
            child: Icon(icon, color: const Color(0xff2563EB), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _agent(String name, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            status == "Warning" ? Icons.warning_rounded : Icons.check_circle,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
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

class PremiumChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.18)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final values = [80.0, 150.0, 120.0, 220.0, 180.0, 280.0, 240.0];

    final labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    const maxValue = 300.0;
    final chartHeight = size.height - 32;
    final gap = size.width / (values.length - 1);

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
            const Color(0xff9333EA).withValues(alpha: 0.04),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xff2563EB), Color(0xff9333EA)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight))
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final pointFill = Paint()..color = Colors.white;

    final pointBorder = Paint()
      ..color = const Color(0xff2563EB)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < values.length; i++) {
      final x = i * gap;
      final y = chartHeight - (values[i] / maxValue * chartHeight);

      canvas.drawCircle(Offset(x, y), 7, pointFill);
      canvas.drawCircle(Offset(x, y), 7, pointBorder);

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
