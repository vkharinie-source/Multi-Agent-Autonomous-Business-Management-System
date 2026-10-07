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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  /// Summary Cards
                  Row(
                    children: [
                      summaryCard(
                        "Present Days",
                        "24",
                        Icons.check_circle,
                        Colors.green,
                      ),
                      const SizedBox(width: 18),
                      summaryCard("Absent", "2", Icons.cancel, Colors.red),
                      const SizedBox(width: 18),
                      summaryCard(
                        "Late",
                        "4",
                        Icons.access_time,
                        Colors.orange,
                      ),
                      const SizedBox(width: 18),
                      summaryCard(
                        "Attendance %",
                        "92%",
                        Icons.analytics,
                        Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// Month Selection
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: card(),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Color(0xff2563EB),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "July 2026",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _exportPdf(context),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("Export PDF"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _exportExcel(context),
                          icon: const Icon(Icons.table_chart),
                          label: const Text("Export Excel"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Department Attendance
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Department Attendance",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff081A63),
                          ),
                        ),

                        const SizedBox(height: 25),

                        progress("IT", 0.95, Colors.blue),
                        progress("Sales", 0.88, Colors.green),
                        progress("Finance", 0.91, Colors.purple),
                        progress("HR", 0.86, Colors.orange),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Employee Report
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Employee Monthly Report",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        reportRow("EMP001", "Harinie", "IT", "24", "2", "92%"),

                        reportRow("EMP002", "Priya", "Sales", "22", "4", "88%"),

                        reportRow(
                          "EMP003",
                          "Arun",
                          "Finance",
                          "23",
                          "3",
                          "91%",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// AI Insight
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: card(),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Insights",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 18),

                        ListTile(
                          leading: Icon(Icons.smart_toy, color: Colors.blue),
                          title: Text(
                            "Attendance improved by 6% compared to last month.",
                          ),
                        ),

                        ListTile(
                          leading: Icon(Icons.trending_up, color: Colors.green),
                          title: Text(
                            "IT department has the highest attendance.",
                          ),
                        ),

                        ListTile(
                          leading: Icon(Icons.warning, color: Colors.orange),
                          title: Text(
                            "Sales team shows frequent late arrivals.",
                          ),
                        ),
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Monthly attendance summary and AI insights",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
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

  Widget summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: card(),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget progress(String title, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 12,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
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
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(name),
      subtitle: Text("$id • $dept"),
      trailing: Text(
        percent,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
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
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
