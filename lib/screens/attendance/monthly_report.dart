import 'package:flutter/material.dart';
import '../../core/services/export_service.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  void _exportPdf(BuildContext context) {
    ExportService.generateAndDownloadPdf(
      context: context,
      title: 'Monthly Attendance Report - July 2026',
      subtitle: 'Employee presence, leave and punctuality statistics',
      headers: ['Emp ID', 'Name', 'Department', 'Working Days', 'Leaves', 'Attendance %'],
      rows: [
        ['EMP001', 'Harinie', 'IT', '24 Days', '2 Days', '92%'],
        ['EMP002', 'Priya', 'Sales', '22 Days', '4 Days', '88%'],
        ['EMP003', 'Arun', 'Finance', '23 Days', '3 Days', '91%'],
        ['EMP004', 'Karthik', 'HR', '25 Days', '1 Day', '96%'],
        ['EMP005', 'Divya', 'Operations', '24 Days', '2 Days', '92%'],
      ],
      summaryStats: {
        'Avg Attendance': '92%',
        'Present Days': '24',
        'Absent Days': '2',
        'Late Count': '4',
      },
    );
  }

  void _exportExcel(BuildContext context) {
    ExportService.generateAndDownloadExcel(
      context: context,
      title: 'Monthly_Attendance_Report_July_2026',
      headers: ['Emp ID', 'Name', 'Department', 'Working Days', 'Leaves', 'Attendance %'],
      rows: [
        ['EMP001', 'Harinie', 'IT', '24 Days', '2 Days', '92%'],
        ['EMP002', 'Priya', 'Sales', '22 Days', '4 Days', '88%'],
        ['EMP003', 'Arun', 'Finance', '23 Days', '3 Days', '91%'],
        ['EMP004', 'Karthik', 'HR', '25 Days', '1 Day', '96%'],
        ['EMP005', 'Divya', 'Operations', '24 Days', '2 Days', '92%'],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),
      body: Column(
        children: [
          _header(context),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Summary Cards in Responsive 2x2 Grid
                  _buildSummaryGrid(),

                  const SizedBox(height: 20),

                  /// Month Selection & Export Buttons
                  _buildMonthAndExportBar(context),

                  const SizedBox(height: 20),

                  /// Department Attendance - Attractive Round Circular Gauges
                  _buildDepartmentRoundSection(),

                  const SizedBox(height: 20),

                  /// Employee Report
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Employee Monthly Report",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff081A63),
                          ),
                        ),
                        const SizedBox(height: 16),
                        reportRow("EMP001", "Harinie", "IT", "24", "2", "92%"),
                        const Divider(height: 20, thickness: 0.7),
                        reportRow("EMP002", "Priya", "Sales", "22", "4", "88%"),
                        const Divider(height: 20, thickness: 0.7),
                        reportRow("EMP003", "Arun", "Finance", "23", "3", "91%"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// AI Insight
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xff6366F1).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.auto_awesome, color: Color(0xff6366F1), size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "AI Insights",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff081A63),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _aiInsightTile(
                          icon: Icons.smart_toy_outlined,
                          color: Colors.blue,
                          text: "Attendance improved by 6% compared to last month.",
                        ),
                        _aiInsightTile(
                          icon: Icons.trending_up,
                          color: Colors.green,
                          text: "IT department has the highest attendance at 95%.",
                        ),
                        _aiInsightTile(
                          icon: Icons.warning_amber_rounded,
                          color: Colors.orange,
                          text: "Sales team shows frequent late arrivals.",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff020A3D), Color(0xff2563EB), Color(0xff9333EA)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Monthly Attendance Report",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Monthly attendance summary and AI insights",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2x2 Responsive Summary Grid (No Horizontal Overflow on Mobile)
  Widget _buildSummaryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            _summaryCardItem("Present Days", "24", Icons.check_circle_rounded, Colors.green),
            _summaryCardItem("Absent Days", "2", Icons.cancel_rounded, Colors.red),
            _summaryCardItem("Late Arrivals", "4", Icons.access_time_filled_rounded, Colors.orange),
            _summaryCardItem("Attendance %", "92%", Icons.analytics_rounded, Colors.blue),
          ],
        );
      },
    );
  }

  Widget _summaryCardItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: card(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Month Bar + Export Actions (Fully Responsive on Mobile)
  Widget _buildMonthAndExportBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xff2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xff2563EB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selected Period",
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "July 2026",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff081A63),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportPdf(context),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                  label: const Text(
                    "Export PDF",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportExcel(context),
                  icon: const Icon(Icons.table_chart_rounded, size: 16),
                  label: const Text(
                    "Export Excel",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0EA5E9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Attractive Round Circular Gauge Section for Departments
  Widget _buildDepartmentRoundSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Department Attendance",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff081A63),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Real-time",
                  style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              _departmentCircularCard(
                title: "IT",
                percent: 0.95,
                color: const Color(0xff3B82F6),
                countText: "24/25 Present",
              ),
              _departmentCircularCard(
                title: "Sales",
                percent: 0.88,
                color: const Color(0xff10B981),
                countText: "22/25 Present",
              ),
              _departmentCircularCard(
                title: "Finance",
                percent: 0.91,
                color: const Color(0xff8B5CF6),
                countText: "23/25 Present",
              ),
              _departmentCircularCard(
                title: "HR",
                percent: 0.86,
                color: const Color(0xffF59E0B),
                countText: "21/25 Present",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _departmentCircularCard({
    required String title,
    required double percent,
    required Color color,
    required String countText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 5.5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                "${(percent * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xff0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            countText,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget reportRow(
    String id,
    String name,
    String dept,
    String present,
    String absent,
    String percent,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xff2563EB).withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: Color(0xff2563EB), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                "$id • $dept",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Text(
          percent,
          style: const TextStyle(
            color: Color(0xff10B981),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _aiInsightTile({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
