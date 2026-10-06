import 'package:flutter/material.dart';

class ReportsDashboard extends StatefulWidget {
  const ReportsDashboard({super.key});

  @override
  State<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends State<ReportsDashboard> {
  String selectedPeriod = "This Month";

  final List<String> periods = [
    "Today",
    "This Week",
    "This Month",
    "This Year",
  ];

  final List<Map<String, dynamic>> reportModules = [
    {
      "title": "Employee Report",
      "subtitle": "Employee details, departments and performance",
      "icon": Icons.groups,
      "color": const Color(0xff2563EB),
    },
    {
      "title": "Attendance Report",
      "subtitle": "Present, absent, late and attendance percentage",
      "icon": Icons.fact_check,
      "color": const Color(0xff16A34A),
    },
    {
      "title": "Inventory Report",
      "subtitle": "Products, categories, suppliers and stock levels",
      "icon": Icons.inventory_2,
      "color": const Color(0xffF59E0B),
    },
    {
      "title": "Sales Report",
      "subtitle": "Sales, orders, customers and product performance",
      "icon": Icons.trending_up,
      "color": const Color(0xff8B5CF6),
    },
    {
      "title": "Finance Report",
      "subtitle": "Revenue, expenses, profit and financial summary",
      "icon": Icons.account_balance_wallet,
      "color": const Color(0xff0891B2),
    },
    {
      "title": "Payroll Report",
      "subtitle": "Salary, bonus, deductions and payment summary",
      "icon": Icons.payments,
      "color": const Color(0xffDB2777),
    },
    {
      "title": "Leave Report",
      "subtitle": "Leave requests, approvals and employee leave balance",
      "icon": Icons.event_available,
      "color": const Color(0xffEA580C),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 750;
          final bool isTablet =
              constraints.maxWidth >= 750 && constraints.maxWidth < 1100;

          return Column(
            children: [
              _header(context, isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 14 : 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _filterAndExportSection(isMobile),
                      SizedBox(height: isMobile ? 16 : 24),
                      _summarySection(isMobile: isMobile, isTablet: isTablet),
                      SizedBox(height: isMobile ? 18 : 26),
                      _analyticsSection(isMobile: isMobile, isTablet: isTablet),
                      SizedBox(height: isMobile ? 18 : 26),
                      _sectionTitle(
                        title: "Business Reports",
                        subtitle:
                            "Access detailed reports from every business module",
                        isMobile: isMobile,
                      ),
                      SizedBox(height: isMobile ? 14 : 18),
                      _reportModuleSection(
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
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
                Icons.assessment,
                color: Colors.white,
                size: isMobile ? 24 : 32,
              ),
            ),
            SizedBox(width: isMobile ? 10 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reports Dashboard",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 20 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMobile
                        ? "Business reports and analytics"
                        : "Analyze employees, attendance, inventory, sales and finance",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Color(0xff4ADE80), size: 9),
                    SizedBox(width: 6),
                    Text(
                      "Live Reports",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filterAndExportSection(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 850;

        if (isCompact) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _periodDropdown(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _exportButton(
                        title: "Export PDF",
                        icon: Icons.picture_as_pdf,
                        color: const Color(0xffEF4444),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _exportButton(
                        title: "Export Excel",
                        icon: Icons.table_chart,
                        color: const Color(0xff16A34A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _exportButton(
                        title: "Print",
                        icon: Icons.print,
                        color: const Color(0xff2563EB),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _exportButton(
                        title: "Share",
                        icon: Icons.share,
                        color: const Color(0xff8B5CF6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(width: 220, child: _periodDropdown()),
                const SizedBox(width: 16),
                _exportButton(
                  title: "Export PDF",
                  icon: Icons.picture_as_pdf,
                  color: const Color(0xffEF4444),
                ),
                const SizedBox(width: 10),
                _exportButton(
                  title: "Export Excel",
                  icon: Icons.table_chart,
                  color: const Color(0xff16A34A),
                ),
                const SizedBox(width: 10),
                _exportButton(
                  title: "Print",
                  icon: Icons.print,
                  color: const Color(0xff2563EB),
                ),
                const SizedBox(width: 10),
                _exportButton(
                  title: "Share",
                  icon: Icons.share,
                  color: const Color(0xff8B5CF6),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _periodDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedPeriod,
      decoration: InputDecoration(
        labelText: "Report Period",
        prefixIcon: const Icon(Icons.calendar_month),
        filled: true,
        fillColor: const Color(0xffF8FAFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  Widget _exportButton({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return OutlinedButton.icon(
      onPressed: () => _showMessage("$title report generated successfully"),
      icon: Icon(icon, size: 18),
      label: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
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
          title: "Employees",
          value: "48",
          change: "+4 this month",
          icon: Icons.groups,
          color: const Color(0xff2563EB),
          isMobile: isMobile,
        ),
        _summaryCard(
          title: "Attendance",
          value: "91%",
          change: "+6% improvement",
          icon: Icons.fact_check,
          color: const Color(0xff16A34A),
          isMobile: isMobile,
        ),
        _summaryCard(
          title: "Revenue",
          value: "₹3.2L",
          change: "+12% growth",
          icon: Icons.currency_rupee,
          color: const Color(0xff8B5CF6),
          isMobile: isMobile,
        ),
        _summaryCard(
          title: "Inventory",
          value: "286",
          change: "5 low stock",
          icon: Icons.inventory_2,
          color: const Color(0xffF59E0B),
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
                const SizedBox(height: 3),
                Text(
                  change,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                      const SizedBox(height: 3),
                      Text(
                        change,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
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
          _chartCard(
            title: "Weekly Attendance",
            subtitle: "Employee attendance percentage",
            painter: AttendanceReportChartPainter(),
            isMobile: isMobile,
          ),
          const SizedBox(height: 16),
          _chartCard(
            title: "Monthly Revenue",
            subtitle: "Business revenue growth",
            painter: RevenueReportChartPainter(),
            isMobile: isMobile,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _chartCard(
            title: "Weekly Attendance",
            subtitle: "Employee attendance percentage",
            painter: AttendanceReportChartPainter(),
            isMobile: false,
          ),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: _chartCard(
            title: "Monthly Revenue",
            subtitle: "Business revenue growth",
            painter: RevenueReportChartPainter(),
            isMobile: false,
          ),
        ),
      ],
    );
  }

  Widget _chartCard({
    required String title,
    required String subtitle,
    required CustomPainter painter,
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      height: isMobile ? 320 : 390,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xff081A63),
              fontSize: isMobile ? 19 : 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CustomPaint(
              painter: painter,
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xff081A63),
            fontSize: isMobile ? 21 : 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey, fontSize: isMobile ? 12 : 14),
        ),
      ],
    );
  }

  Widget _reportModuleSection({
    required bool isMobile,
    required bool isTablet,
  }) {
    final int columns = isMobile
        ? 1
        : isTablet
        ? 2
        : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reportModules.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: isMobile ? 12 : 18,
        mainAxisSpacing: isMobile ? 12 : 18,
        childAspectRatio: isMobile ? 2.7 : 2.2,
      ),
      itemBuilder: (context, index) {
        final report = reportModules[index];

        return _reportCard(
          title: report["title"] as String,
          subtitle: report["subtitle"] as String,
          icon: report["icon"] as IconData,
          color: report["color"] as Color,
          isMobile: isMobile,
        );
      },
    );
  }

  Widget _reportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isMobile,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showReportDetails(title),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              CircleAvatar(
                radius: isMobile ? 25 : 30,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: isMobile ? 24 : 29),
              ),
              SizedBox(width: isMobile ? 13 : 16),
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
                        color: const Color(0xff081A63),
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isMobile ? 11 : 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomSection({required bool isMobile, required bool isTablet}) {
    if (isMobile || isTablet) {
      return Column(
        children: [
          _aiInsightCard(isMobile),
          const SizedBox(height: 16),
          _recentReportsCard(isMobile),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _aiInsightCard(false)),
        const SizedBox(width: 22),
        Expanded(child: _recentReportsCard(false)),
      ],
    );
  }

  Widget _aiInsightCard(bool isMobile) {
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
                "AI Report Insights",
                style: TextStyle(
                  color: const Color(0xff081A63),
                  fontSize: isMobile ? 19 : 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _insightItem(
            Icons.trending_up,
            "Sales increased by 12% compared with last month.",
            const Color(0xff16A34A),
          ),
          _insightItem(
            Icons.warning_rounded,
            "Five products require immediate stock replenishment.",
            const Color(0xffF59E0B),
          ),
          _insightItem(
            Icons.groups,
            "Employee attendance improved by 6%.",
            const Color(0xff2563EB),
          ),
          _insightItem(
            Icons.payments,
            "Operating expenses increased by 4%.",
            const Color(0xffEF4444),
          ),
        ],
      ),
    );
  }

  Widget _insightItem(IconData icon, String text, Color color) {
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

  Widget _recentReportsCard(bool isMobile) {
    final recentReports = [
      {"name": "June Attendance Report", "date": "12 Jul 2026", "type": "PDF"},
      {"name": "Monthly Sales Report", "date": "10 Jul 2026", "type": "Excel"},
      {"name": "Inventory Stock Report", "date": "08 Jul 2026", "type": "PDF"},
      {
        "name": "Employee Performance Report",
        "date": "05 Jul 2026",
        "type": "PDF",
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recently Generated Reports",
            style: TextStyle(
              color: const Color(0xff081A63),
              fontSize: isMobile ? 19 : 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 17),
          ...recentReports.map((report) {
            return Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xffF8FAFF),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xffE8EAF2)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xffEEF4FF),
                    child: Icon(Icons.description, color: Color(0xff2563EB)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report["name"]!,
                          style: const TextStyle(
                            color: Color(0xff081A63),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          report["date"]!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
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
                      color: const Color(0xff2563EB).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      report["type"]!,
                      style: const TextStyle(
                        color: Color(0xff2563EB),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showReportDetails(String title) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(title),
          content: Text(
            "$title contains detailed business data, summaries, filters, charts and export options.\n\n"
            "The report currently displays sample data. Backend and database integration can be added later.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Close"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showMessage("$title generated successfully");
              },
              icon: const Icon(Icons.download),
              label: const Text("Generate"),
            ),
          ],
        );
      },
    );
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

class AttendanceReportChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final values = [82.0, 88.0, 85.0, 91.0, 89.0, 93.0, 91.0];
    final labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    _drawBarChart(
      canvas: canvas,
      size: size,
      values: values,
      labels: labels,
      maximum: 100,
      startColor: const Color(0xff2563EB),
      endColor: const Color(0xff8B5CF6),
    );
  }

  @override
  bool shouldRepaint(covariant AttendanceReportChartPainter oldDelegate) {
    return false;
  }
}

class RevenueReportChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final values = [120.0, 175.0, 150.0, 230.0, 210.0, 290.0];
    final labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];

    _drawBarChart(
      canvas: canvas,
      size: size,
      values: values,
      labels: labels,
      maximum: 320,
      startColor: const Color(0xff16A34A),
      endColor: const Color(0xff0891B2),
    );
  }

  @override
  bool shouldRepaint(covariant RevenueReportChartPainter oldDelegate) {
    return false;
  }
}

void _drawBarChart({
  required Canvas canvas,
  required Size size,
  required List<double> values,
  required List<String> labels,
  required double maximum,
  required Color startColor,
  required Color endColor,
}) {
  final chartHeight = size.height - 30;
  final gap = size.width / values.length;
  final barWidth = gap * 0.45;

  final gridPaint = Paint()
    ..color = Colors.grey.withValues(alpha: 0.16)
    ..strokeWidth = 1;

  for (int i = 1; i <= 4; i++) {
    final y = chartHeight * i / 5;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
  }

  final textPainter = TextPainter(textDirection: TextDirection.ltr);

  for (int i = 0; i < values.length; i++) {
    final x = i * gap + gap * 0.28;
    final barHeight = values[i] / maximum * chartHeight;
    final y = chartHeight - barHeight;

    final bar = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, barWidth, barHeight),
      const Radius.circular(13),
    );

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [startColor, endColor],
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
