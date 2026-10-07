import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  String selectedPeriod = "This Month";

  final List<String> periods = [
    "Today",
    "This Week",
    "This Month",
    "This Year",
  ];

  final List<Map<String, dynamic>> recentOrders = [
    {
      "id": "ORD-1001",
      "customer": "Priya S",
      "product": "Laptop",
      "amount": "₹58,000",
      "status": "Completed",
    },
    {
      "id": "ORD-1002",
      "customer": "Arun K",
      "product": "Wireless Mouse",
      "amount": "₹1,250",
      "status": "Pending",
    },
    {
      "id": "ORD-1003",
      "customer": "Rahul M",
      "product": "Keyboard",
      "amount": "₹2,800",
      "status": "Completed",
    },
    {
      "id": "ORD-1004",
      "customer": "Divya R",
      "product": "Monitor",
      "amount": "₹14,500",
      "status": "Cancelled",
    },
  ];

  final List<Map<String, dynamic>> topProducts = [
    {
      "name": "Laptop",
      "sales": "86 Units",
      "revenue": "₹8.2L",
      "icon": Icons.laptop,
      "color": const Color(0xff2563EB),
    },
    {
      "name": "Monitor",
      "sales": "64 Units",
      "revenue": "₹4.6L",
      "icon": Icons.desktop_windows,
      "color": const Color(0xff8B5CF6),
    },
    {
      "name": "Keyboard",
      "sales": "124 Units",
      "revenue": "₹2.1L",
      "icon": Icons.keyboard,
      "color": const Color(0xff16A34A),
    },
    {
      "name": "Mouse",
      "sales": "142 Units",
      "revenue": "₹1.7L",
      "icon": Icons.mouse,
      "color": const Color(0xffF59E0B),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 700;
          final bool isTablet =
              constraints.maxWidth >= 700 && constraints.maxWidth < 1100;

          return Column(
            children: [
              _header(context, isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 14 : 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _filterSection(isMobile),
                      SizedBox(height: isMobile ? 16 : 24),

                      _summarySection(isMobile: isMobile, isTablet: isTablet),

                      SizedBox(height: isMobile ? 18 : 26),

                      _analyticsSection(isMobile: isMobile, isTablet: isTablet),

                      SizedBox(height: isMobile ? 18 : 26),

                      _bottomSection(isMobile: isMobile, isTablet: isTablet),

                      const SizedBox(height: 20),
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

  Widget _header(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 8 : 22,
        isMobile ? 16 : 28,
        isMobile ? 16 : 28,
        isMobile ? 20 : 32,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff020A3D), Color(0xff2563EB), Color(0xff9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isMobile ? 24 : 32),
          bottomRight: Radius.circular(isMobile ? 24 : 32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            SizedBox(width: isMobile ? 2 : 12),
            Container(
              padding: EdgeInsets.all(isMobile ? 9 : 13),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                Icons.trending_up,
                color: Colors.white,
                size: isMobile ? 25 : 34,
              ),
            ),
            SizedBox(width: isMobile ? 11 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sales Management",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 21 : 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isMobile
                        ? "Track sales, orders and revenue"
                        : "Monitor sales performance, orders, revenue and customer activity",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isMobile ? 12 : 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterSection(bool isMobile) {
    if (isMobile) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            _periodDropdown(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showMessage("Add Sale screen will be added next.");
                },
                icon: const Icon(Icons.add),
                label: const Text("Add New Sale"),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          SizedBox(width: 220, child: _periodDropdown()),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              _showMessage("Add Sale screen will be added next.");
            },
            icon: const Icon(Icons.add),
            label: const Text("Add New Sale"),
          ),
        ],
      ),
    );
  }

  Widget _periodDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedPeriod,
      decoration: InputDecoration(
        labelText: "Sales Period",
        prefixIcon: const Icon(Icons.calendar_month),
        filled: true,
        fillColor: const Color(0xffF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: periods.map((period) {
        return DropdownMenuItem(value: period, child: Text(period));
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          selectedPeriod = value;
        });
      },
    );
  }

  Widget _summarySection({required bool isMobile, required bool isTablet}) {
    final int columns = isMobile || isTablet ? 2 : 4;

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 10 : 18,
      mainAxisSpacing: isMobile ? 10 : 18,
      childAspectRatio: isMobile ? 1.28 : 1.75,
      children: [
        _summaryCard(
          title: "Today's Sales",
          value: "₹24,850",
          change: "+18%",
          icon: Icons.point_of_sale,
          color: const Color(0xff2563EB),
          isMobile: isMobile,
        ),
        _summaryCard(
          title: "Revenue",
          value: "₹3.2L",
          change: "+12%",
          icon: Icons.currency_rupee,
          color: const Color(0xff8B5CF6),
          isMobile: isMobile,
        ),
        _summaryCard(
          title: "Orders",
          value: "156",
          change: "+25",
          icon: Icons.shopping_cart,
          color: const Color(0xffF59E0B),
          isMobile: isMobile,
        ),
        _summaryCard(
          title: "Customers",
          value: "2,340",
          change: "+52",
          icon: Icons.groups,
          color: const Color(0xff16A34A),
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      decoration: _cardDecoration(),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, color: color, size: 21),
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff081A63),
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  change,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 29,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xff081A63),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        change,
                        style: TextStyle(
                          color: color,
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

  Widget _analyticsSection({required bool isMobile, required bool isTablet}) {
    if (isMobile || isTablet) {
      return Column(
        children: [
          _salesChartCard(isMobile),
          const SizedBox(height: 16),
          _aiSalesInsightCard(isMobile),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _salesChartCard(false)),
        const SizedBox(width: 22),
        Expanded(child: _aiSalesInsightCard(false)),
      ],
    );
  }

  Widget _salesChartCard(bool isMobile) {
    return Container(
      width: double.infinity,
      height: isMobile ? 330 : 420,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sales Performance",
                      style: GoogleFonts.inter(
                        color: const Color(0xff081A63),
                        fontSize: isMobile ? 19 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Weekly revenue and sales trend",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF059669),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "+18.4%",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF059669),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: SalesChartPainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiSalesInsightCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffEEF4FF), Color(0xffF5F3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffC7D2FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xff2563EB),
                child: Icon(Icons.smart_toy, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                "AI Sales Insights",
                style: TextStyle(
                  color: const Color(0xff081A63),
                  fontSize: isMobile ? 19 : 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _insight(
            Icons.trending_up,
            "Sales may increase by 18% next week.",
            const Color(0xff16A34A),
          ),
          _insight(
            Icons.inventory_2,
            "Laptop stock may run out within 5 days.",
            const Color(0xffF59E0B),
          ),
          _insight(
            Icons.local_offer,
            "Festival discount may improve order volume.",
            const Color(0xff8B5CF6),
          ),
          _insight(
            Icons.groups,
            "Returning customers increased by 9%.",
            const Color(0xff2563EB),
          ),
        ],
      ),
    );
  }

  Widget _insight(IconData icon, String text, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xff081A63),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomSection({required bool isMobile, required bool isTablet}) {
    if (isMobile || isTablet) {
      return Column(
        children: [
          _topProductsCard(isMobile),
          const SizedBox(height: 16),
          _recentOrdersCard(isMobile),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _topProductsCard(false)),
        const SizedBox(width: 22),
        Expanded(flex: 2, child: _recentOrdersCard(false)),
      ],
    );
  }

  Widget _topProductsCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Top Selling Products",
            style: TextStyle(
              color: const Color(0xff081A63),
              fontSize: isMobile ? 19 : 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 17),
          ...topProducts.map((product) {
            final color = product["color"] as Color;

            return Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(product["icon"] as IconData, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product["name"].toString(),
                          style: const TextStyle(
                            color: Color(0xff081A63),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          product["sales"].toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    product["revenue"].toString(),
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _recentOrdersCard(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Orders",
            style: TextStyle(
              color: const Color(0xff081A63),
              fontSize: isMobile ? 19 : 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 17),
          if (!isMobile) _desktopOrderHeader(),
          if (!isMobile) const SizedBox(height: 8),
          ...recentOrders.map((order) {
            return isMobile ? _mobileOrderCard(order) : _desktopOrderRow(order);
          }),
        ],
      ),
    );
  }

  Widget _desktopOrderHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffEEF4FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Expanded(child: Text("Order ID")),
          Expanded(child: Text("Customer")),
          Expanded(child: Text("Product")),
          Expanded(child: Text("Amount")),
          Expanded(child: Text("Status")),
        ],
      ),
    );
  }

  Widget _desktopOrderRow(Map<String, dynamic> order) {
    final Color statusColor = _statusColor(order["status"].toString());

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xffFAFBFF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xffE8EAF2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              order["id"].toString(),
              style: const TextStyle(
                color: Color(0xff081A63),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(order["customer"].toString())),
          Expanded(child: Text(order["product"].toString())),
          Expanded(child: Text(order["amount"].toString())),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusBadge(order["status"].toString(), statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileOrderCard(Map<String, dynamic> order) {
    final Color statusColor = _statusColor(order["status"].toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffFAFBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE8EAF2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order["id"].toString(),
                  style: const TextStyle(
                    color: Color(0xff081A63),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _statusBadge(order["status"].toString(), statusColor),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow("Customer", order["customer"].toString()),
          _detailRow("Product", order["product"].toString()),
          _detailRow("Amount", order["amount"].toString()),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xff081A63),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == "Completed") {
      return const Color(0xff16A34A);
    }

    if (status == "Pending") {
      return const Color(0xffF59E0B);
    }

    return const Color(0xffEF4444);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 22,
          offset: const Offset(0, 9),
        ),
      ],
    );
  }
}

class SalesChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final List<double> values = [120, 180, 145, 240, 210, 290, 260];
    final List<String> labels = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    ];

    const double maximum = 320;
    const double leftPadding = 34.0;
    const double rightPadding = 16.0;
    const double bottomPadding = 26.0;
    const double topPadding = 24.0;

    final double chartWidth = size.width - leftPadding - rightPadding;
    final double chartHeight = size.height - bottomPadding - topPadding;
    final double chartBottom = size.height - bottomPadding;

    // 1. Draw horizontal grid lines & Y-axis labels
    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.8)
      ..strokeWidth = 1;

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final List<int> yTicks = [300, 200, 100, 0];
    for (final int tick in yTicks) {
      final double normalized = tick / maximum;
      final double y = chartBottom - (normalized * chartHeight);

      // Grid line
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      // Y-axis label text
      textPainter.text = TextSpan(
        text: tick == 0 ? "0" : "${tick}k",
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    // 2. Compute points for each day
    final double step = chartWidth / (values.length - 1);
    final List<Offset> points = <Offset>[];

    int peakIndex = 0;
    double peakValue = values[0];

    for (int i = 0; i < values.length; i++) {
      final double x = leftPadding + (i * step);
      final double normalized = values[i] / maximum;
      final double y = chartBottom - (normalized * chartHeight);
      points.add(Offset(x, y));

      if (values[i] > peakValue) {
        peakValue = values[i];
        peakIndex = i;
      }
    }

    if (points.isEmpty) return;

    // 3. Build Smooth Spline (Cubic Bezier) Path
    final Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final Offset p0 = points[i];
      final Offset p1 = points[i + 1];

      final double cx1 = p0.dx + (p1.dx - p0.dx) / 2;
      final double cy1 = p0.dy;
      final double cx2 = p0.dx + (p1.dx - p0.dx) / 2;
      final double cy2 = p1.dy;

      path.cubicTo(cx1, cy1, cx2, cy2, p1.dx, p1.dy);
    }

    // 4. Draw Smooth Gradient Fill
    final Path fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, chartBottom);
    fillPath.lineTo(points.first.dx, chartBottom);
    fillPath.close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2563EB).withValues(alpha: 0.35),
          const Color(0xFF7C3AED).withValues(alpha: 0.16),
          const Color(0xFF3B82F6).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTRB(leftPadding, topPadding, size.width - rightPadding, chartBottom));

    canvas.drawPath(fillPath, fillPaint);

    // 5. Draw Glowing Shadow & Spline Line
    final Paint shadowPaint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawPath(path, shadowPaint);

    final Paint strokePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFF9333EA)],
      ).createShader(Rect.fromLTRB(leftPadding, 0, size.width - rightPadding, chartBottom))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // 6. Draw Points, Day Labels, and Peak Tooltip
    for (int i = 0; i < points.length; i++) {
      final Offset pt = points[i];
      final bool isPeak = (i == peakIndex);

      // Outer glowing aura
      canvas.drawCircle(
        pt,
        isPeak ? 7.5 : 5.0,
        Paint()
          ..color = (isPeak ? const Color(0xFF7C3AED) : const Color(0xFF2563EB))
              .withValues(alpha: isPeak ? 0.35 : 0.2),
      );

      // Outer border circle
      canvas.drawCircle(
        pt,
        isPeak ? 5.5 : 4.0,
        Paint()
          ..color = isPeak ? const Color(0xFF7C3AED) : const Color(0xFF2563EB)
          ..style = PaintingStyle.fill,
      );

      // Inner white core
      canvas.drawCircle(
        pt,
        isPeak ? 2.5 : 2.0,
        Paint()..color = Colors.white,
      );

      // X-axis Day labels
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: isPeak ? const Color(0xFF081A63) : const Color(0xFF64748B),
          fontSize: 11,
          fontWeight: isPeak ? FontWeight.bold : FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pt.dx - (textPainter.width / 2), chartBottom + 7),
      );

      // Peak Day Tooltip Badge
      if (isPeak) {
        final String badgeStr = "₹${(values[i]).toInt()}k";
        textPainter.text = TextSpan(
          text: badgeStr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();

        final double badgeW = textPainter.width + 14;
        final double badgeH = textPainter.height + 6;
        final double badgeX = pt.dx - (badgeW / 2);
        final double badgeY = pt.dy - badgeH - 8;

        final RRect badgeRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(badgeX, badgeY, badgeW, badgeH),
          const Radius.circular(8),
        );

        // Tooltip shadow
        canvas.drawRRect(
          badgeRRect,
          Paint()
            ..color = const Color(0xFF081A63).withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );

        // Tooltip background
        canvas.drawRRect(
          badgeRRect,
          Paint()..color = const Color(0xFF081A63),
        );

        // Tooltip text
        textPainter.paint(
          canvas,
          Offset(badgeX + 7, badgeY + 3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SalesChartPainter oldDelegate) {
    return false;
  }
}
