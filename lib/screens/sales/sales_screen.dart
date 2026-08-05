import 'package:flutter/material.dart';

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
      height: isMobile ? 320 : 420,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sales Performance",
            style: TextStyle(
              color: const Color(0xff081A63),
              fontSize: isMobile ? 19 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Weekly revenue and sales trend",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
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

    final double chartHeight = size.height - 30;
    final double gap = size.width / values.length;
    final double barWidth = gap * 0.45;

    final Paint gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.16)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final double y = chartHeight * i / 5;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < values.length; i++) {
      final double x = i * gap + gap * 0.28;
      final double barHeight = values[i] / maximum * chartHeight;
      final double y = chartHeight - barHeight;

      final RRect bar = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(13),
      );

      final Paint paint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xff2563EB), Color(0xff9333EA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

      canvas.drawRRect(bar, paint);

      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: size.width < 400 ? 9 : 11,
        ),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, size.height - 17),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SalesChartPainter oldDelegate) {
    return false;
  }
}
