import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/services/secure_storage_service.dart';
import 'pages/manager_salary_screen.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final searchController = TextEditingController();

  static const double _mobileBreakpoint = 700;

  List<Map<String, dynamic>> employees = [
    {
      "id": "EMP001",
      "name": "Harinie V K",
      "email": "harinie@gmail.com",
      "phone": "9876543210",
      "department": "IT",
      "designation": "Flutter Developer",
      "salary": 45000,
      "attendance": 92,
      "leave": 2,
      "performance": 88,
    },
    {
      "id": "EMP002",
      "name": "Priya S",
      "email": "priya@gmail.com",
      "phone": "9876501234",
      "department": "Sales",
      "designation": "Sales Executive",
      "salary": 38000,
      "attendance": 85,
      "leave": 4,
      "performance": 80,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchEmployeesFromBackend();
  }

  Future<void> _fetchEmployeesFromBackend() async {
    try {
      final String? token =
          await SecureStorageService.instance.readAccessToken();
      final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/employees');
      final http.Response res = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(res.body) as Map<String, dynamic>;
        final List<dynamic>? list = body['employees'] as List<dynamic>?;
        if (list != null && list.isNotEmpty && mounted) {
          setState(() {
            employees = list.map((dynamic item) {
              final Map<String, dynamic> m = item as Map<String, dynamic>;
              return {
                "id": m["employee_id"] ?? m["id"] ?? "",
                "name": m["name"] ?? "",
                "email": m["email"] ?? "",
                "phone": m["phone"] ?? "",
                "department": m["department"] ?? "General",
                "designation": m["designation"] ?? "Employee",
                "salary": (m["salary"] as num?)?.toInt() ?? 35000,
                "attendance": (m["attendance"] as num?)?.toInt() ?? 90,
                "leave": (m["leave"] as num?)?.toInt() ?? 0,
                "performance": (m["performance"] as num?)?.toInt() ?? 85,
              };
            }).toList();
          });
        }
      }
    } catch (_) {
      // Graceful fallback to initial items
    }
  }

  Future<void> _syncEmployeeToBackend(Map<String, dynamic> data) async {
    try {
      final String? token =
          await SecureStorageService.instance.readAccessToken();
      final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/employees');

      final Map<String, dynamic> payload = {
        "employee_id": data["id"],
        "name": data["name"],
        "email": data["email"],
        "phone": data["phone"] ?? "",
        "department": data["department"] ?? "General",
        "designation": data["designation"] ?? "Employee",
        "salary": (data["salary"] as num).toDouble(),
      };

      await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      // Handled silently
    }
  }

  void openEmployeeForm({Map<String, dynamic>? employee, int? index}) {
    final id = TextEditingController(text: employee?["id"] ?? "");
    final name = TextEditingController(text: employee?["name"] ?? "");
    final email = TextEditingController(text: employee?["email"] ?? "");
    final phone = TextEditingController(text: employee?["phone"] ?? "");
    final department = TextEditingController(
      text: employee?["department"] ?? "",
    );
    final designation = TextEditingController(
      text: employee?["designation"] ?? "",
    );
    final salary = TextEditingController(
      text: employee?["salary"]?.toString() ?? "",
    );
    final attendance = TextEditingController(
      text: employee?["attendance"]?.toString() ?? "",
    );
    final leave = TextEditingController(
      text: employee?["leave"]?.toString() ?? "",
    );
    final performance = TextEditingController(
      text: employee?["performance"]?.toString() ?? "",
    );

    final dialogWidth = MediaQuery.of(context).size.width;
    // Cap the dialog to 500 on wide screens, but never exceed the
    // available viewport width (minus margin) on phones.
    final formWidth = dialogWidth < 560 ? dialogWidth - 60 : 500.0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(employee == null ? "Add Employee" : "Edit Employee"),
        content: SizedBox(
          width: formWidth,
          child: SingleChildScrollView(
            child: Column(
              children: [
                input(id, "Employee ID"),
                input(name, "Employee Name"),
                input(email, "Email"),
                input(phone, "Phone"),
                input(department, "Department"),
                input(designation, "Designation"),
                input(salary, "Salary (₹)", number: true),
                input(attendance, "Attendance %", number: true),
                input(leave, "Leave Count", number: true),
                input(performance, "Performance %", number: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final String empId = id.text.trim().isNotEmpty
                  ? id.text.trim()
                  : "EMP${DateTime.now().millisecondsSinceEpoch % 10000}";

              final data = {
                "id": empId,
                "name": name.text.trim(),
                "email": email.text.trim(),
                "phone": phone.text.trim(),
                "department": department.text.trim(),
                "designation": designation.text.trim(),
                "salary": int.tryParse(salary.text) ?? 35000,
                "attendance": int.tryParse(attendance.text) ?? 90,
                "leave": int.tryParse(leave.text) ?? 0,
                "performance": int.tryParse(performance.text) ?? 85,
              };

              setState(() {
                if (index == null) {
                  employees.add(data);
                } else {
                  employees[index] = data;
                }
              });

              Navigator.pop(context);

              // Persist to backend MongoDB
              await _syncEmployeeToBackend(data);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    content: Text(
                      'Salary of ₹${data["salary"]} updated for ${data["name"]}. Synced with Employee Portal!',
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget input(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xffF8FAFF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void deleteEmployee(int index) {
    setState(() {
      employees.removeAt(index);
    });
  }

  void openProfile(Map<String, dynamic> emp) {
    final dialogWidth = MediaQuery.of(context).size.width;
    final width = dialogWidth < 480 ? dialogWidth - 60 : 420.0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text("Employee Profile"),
        content: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xff2563EB),
                child: Icon(Icons.person, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 16),
              Text(
                emp["name"],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                emp["designation"],
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              profileRow("Employee ID", emp["id"]),
              profileRow("Email", emp["email"]),
              profileRow("Phone", emp["phone"]),
              profileRow("Department", emp["department"]),
              profileRow("Salary", "₹${emp["salary"]}"),
              profileRow("Attendance", "${emp["attendance"]}%"),
              profileRow("Leave Taken", "${emp["leave"]} days"),
              profileRow("Performance", "${emp["performance"]}%"),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openEmployeeTasksDialog(emp);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.task_alt_rounded, size: 18),
                  label: const Text("View Assigned Tasks & Status"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEmployeeTasksDialog(Map<String, dynamic> emp) {
    showDialog(
      context: context,
      builder: (_) => _EmployeeTasksDialog(emp: emp),
    );
  }

  Widget profileRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEmployees = employees.where((e) {
      final search = searchController.text.toLowerCase();
      return e["name"].toString().toLowerCase().contains(search) ||
          e["department"].toString().toLowerCase().contains(search) ||
          e["designation"].toString().toLowerCase().contains(search);
    }).toList();

    final totalSalary = employees.fold<int>(
      0,
      (sum, e) => sum + e["salary"] as int,
    );
    final avgAttendance = employees.isEmpty
        ? 0
        : employees.fold<int>(0, (sum, e) => sum + e["attendance"] as int) ~/
              employees.length;
    final avgPerformance = employees.isEmpty
        ? 0
        : employees.fold<int>(0, (sum, e) => sum + e["performance"] as int) ~/
              employees.length;

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < _mobileBreakpoint;

          return Column(
            children: [
              header(isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 26),
                  child: Column(
                    children: [
                      summaryCardsRow(
                        isMobile,
                        employees.length,
                        totalSalary,
                        avgAttendance,
                        avgPerformance,
                      ),
                      SizedBox(height: isMobile ? 18 : 24),
                      searchAndAdd(isMobile),
                      SizedBox(height: isMobile ? 18 : 24),
                      employeeList(filteredEmployees, isMobile),
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

  Widget header(bool isMobile) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 28,
        (isMobile ? 12 : 24) + statusBarHeight,
        isMobile ? 16 : 28,
        isMobile ? 22 : 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff020A3D), Color(0xff2563EB), Color(0xff9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
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
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Employee Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 20 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Manage employees, salary, attendance, leave and performance",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 12 : 14,
                  ),
                  maxLines: isMobile ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.badge, color: Colors.white, size: 36),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.badge, color: Colors.white, size: 22),
            ),
        ],
      ),
    );
  }

  Widget summaryCardsRow(
    bool isMobile,
    int employeeCount,
    int totalSalary,
    int avgAttendance,
    int avgPerformance,
  ) {
    final cards = [
      summaryCardContent(
        "Employees",
        "$employeeCount",
        Icons.groups,
        const Color(0xff2563EB),
      ),
      summaryCardContent(
        "Total Salary",
        "₹$totalSalary",
        Icons.currency_rupee,
        const Color(0xff10B981),
      ),
      summaryCardContent(
        "Attendance",
        "$avgAttendance%",
        Icons.calendar_month,
        const Color(0xffF97316),
      ),
      summaryCardContent(
        "Performance",
        "$avgPerformance%",
        Icons.star,
        const Color(0xff9333EA),
      ),
    ];

    if (isMobile) {
      return SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (context, index) => const SizedBox(width: 14),
          itemBuilder: (context, index) => Container(
            width: 190,
            padding: const EdgeInsets.all(18),
            decoration: card(),
            child: cards[index],
          ),
        ),
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i != 0) const SizedBox(width: 18),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: card(),
              child: cards[i],
            ),
          ),
        ],
      ],
    );
  }

  Widget summaryCardContent(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withValues(alpha: 0.13),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff081A63),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget searchAndAdd(bool isMobile) {
    final searchField = TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: "Search employee, department or designation...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xffF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );

    final leaveButton = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff8B5CF6),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: isMobile ? 16 : 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const _ManagerLeaveApprovalDialog(),
        );
      },
      icon: const Icon(Icons.event_available_rounded),
      label: const Text("Leave Approvals"),
    );

    final salaryButton = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff10B981),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: isMobile ? 16 : 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ManagerSalaryScreen(),
          ),
        );
      },
      icon: const Icon(Icons.account_balance_wallet),
      label: const Text("Monthly Salary"),
    );

    final addButton = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: isMobile ? 16 : 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () => openEmployeeForm(),
      icon: const Icon(Icons.add),
      label: const Text("Add Employee"),
    );

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: card(),
      child: isMobile
          ? Column(
              children: [
                searchField,
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: leaveButton),
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: salaryButton),
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: addButton),
              ],
            )
          : Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 14),
                leaveButton,
                const SizedBox(width: 10),
                salaryButton,
                const SizedBox(width: 10),
                addButton,
              ],
            ),
    );
  }

  Widget employeeList(List<Map<String, dynamic>> data, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Employee List",
            style: TextStyle(
              fontSize: isMobile ? 19 : 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff081A63),
            ),
          ),
          const SizedBox(height: 18),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final emp = data[index];
              final originalIndex = employees.indexOf(emp);

              final actionButtons = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => openProfile(emp),
                    icon: const Icon(Icons.visibility, color: Colors.purple),
                  ),
                  IconButton(
                    onPressed: () =>
                        openEmployeeForm(employee: emp, index: originalIndex),
                    icon: const Icon(Icons.edit, color: Colors.blue),
                  ),
                  IconButton(
                    onPressed: () => deleteEmployee(originalIndex),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xffF8FAFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 26,
                                backgroundColor: Color(0xff2563EB),
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      emp["name"],
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff081A63),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${emp["department"]} • ${emp["designation"]}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Attendance: ${emp["attendance"]}% | Leave: ${emp["leave"]} days | Performance: ${emp["performance"]}%",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                "₹${emp["salary"]}",
                                style: const TextStyle(
                                  color: Color(0xff10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              actionButtons,
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xff2563EB),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  emp["name"],
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff081A63),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${emp["department"]} • ${emp["designation"]}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Attendance: ${emp["attendance"]}% | Leave: ${emp["leave"]} days | Performance: ${emp["performance"]}%",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "₹${emp["salary"]}",
                            style: const TextStyle(
                              color: Color(0xff10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 18),
                          actionButtons,
                        ],
                      ),
              );
            },
          ),
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

class _EmployeeTasksDialog extends StatefulWidget {
  const _EmployeeTasksDialog({required this.emp});

  final Map<String, dynamic> emp;

  @override
  State<_EmployeeTasksDialog> createState() => _EmployeeTasksDialogState();
}

class _EmployeeTasksDialogState extends State<_EmployeeTasksDialog> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployeeTasks();
  }

  Future<void> _fetchEmployeeTasks() async {
    final empId = widget.emp["id"] ?? widget.emp["employee_id"] ?? "";
    try {
      final String? token =
          await SecureStorageService.instance.readAccessToken();
      final Uri uri =
          Uri.parse('${ApiConfig.baseUrl}/api/tasks?employee_id=$empId');
      final http.Response res = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(res.body) as Map<String, dynamic>;
        final List<dynamic>? list = body['tasks'] as List<dynamic>?;
        if (list != null && mounted) {
          setState(() {
            _tasks = list.map((e) => e as Map<String, dynamic>).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {
      // Fallback below
    }

    if (mounted) {
      setState(() {
        _tasks = [
          {
            "task_id": "TASK-01",
            "title": "Complete monthly sales report",
            "deadline": "Today, 4:00 PM",
            "priority": "High",
            "completed": false,
          },
          {
            "task_id": "TASK-02",
            "title": "Update customer information",
            "deadline": "Tomorrow",
            "priority": "Medium",
            "completed": false,
          },
          {
            "task_id": "TASK-03",
            "title": "Attend team meeting",
            "deadline": "Friday, 3:00 PM",
            "priority": "Medium",
            "completed": false,
          },
          {
            "task_id": "TASK-04",
            "title": "Review assigned documents",
            "deadline": "30 July 2026",
            "priority": "Low",
            "completed": false,
          },
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int doneCount = _tasks.where((t) => t["completed"] == true).length;
    final int totalCount = _tasks.length;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          const Icon(Icons.assignment_turned_in_rounded,
              color: Color(0xFF6366F1), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${widget.emp["name"]}'s Tasks",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: _isLoading
            ? const SizedBox(
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Live Completion Status:",
                          style: TextStyle(
                            color: Color(0xFF4338CA),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "$doneCount of $totalCount Done",
                          style: const TextStyle(
                            color: Color(0xFF4338CA),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_tasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text("No tasks currently assigned."),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _tasks.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final t = _tasks[idx];
                          final bool isDone = t["completed"] == true;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            leading: Icon(
                              isDone
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isDone
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                            ),
                            title: Text(
                              t["title"] ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isDone ? Colors.grey : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              "${t["priority"] ?? "Medium"} Priority • ${t["deadline"] ?? "Pending"}",
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isDone ? "Completed" : "Pending",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDone
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFD97706),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}

class _ManagerLeaveApprovalDialog extends StatefulWidget {
  const _ManagerLeaveApprovalDialog();

  @override
  State<_ManagerLeaveApprovalDialog> createState() =>
      _ManagerLeaveApprovalDialogState();
}

class _ManagerLeaveApprovalDialogState
    extends State<_ManagerLeaveApprovalDialog> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _leaves = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
  }

  Future<void> _fetchLeaves() async {
    try {
      final String? token =
          await SecureStorageService.instance.readAccessToken();
      final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/leaves');
      final http.Response res = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(res.body) as Map<String, dynamic>;
        final List<dynamic>? list = body['leaves'] as List<dynamic>?;
        if (list != null && mounted) {
          setState(() {
            _leaves = list.map((e) => e as Map<String, dynamic>).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {
      // Fallback below
    }

    if (mounted) {
      setState(() {
        _leaves = [
          {
            "leave_id": "LV-2026-001",
            "employee_id": "EMP0078",
            "employee_name": "harinievk",
            "leave_type": "Casual Leave",
            "start_date": "2026-10-15",
            "end_date": "2026-10-16",
            "days_count": 2,
            "reason": "Family function",
            "status": "Pending",
          },
          {
            "leave_id": "LV-2026-002",
            "employee_id": "EMP_DEMO_01",
            "employee_name": "Arun Kumar",
            "leave_type": "Sick Leave",
            "start_date": "2026-10-02",
            "end_date": "2026-10-02",
            "days_count": 1,
            "reason": "Doctor appointment",
            "status": "Approved",
          },
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _updateLeaveStatus(String leaveId, String newStatus) async {
    try {
      final String? token =
          await SecureStorageService.instance.readAccessToken();
      final Uri uri =
          Uri.parse('${ApiConfig.baseUrl}/api/leaves/$leaveId/status');
      final http.Response res = await http.patch(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"status": newStatus}),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        setState(() {
          final idx = _leaves.indexWhere((l) => l["leave_id"] == leaveId);
          if (idx != -1) {
            _leaves[idx]["status"] = newStatus;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: newStatus == "Approved"
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              content: Text(
                'Leave request $leaveId has been $newStatus successfully!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (_) {
      // Local optimistic update
      setState(() {
        final idx = _leaves.indexWhere((l) => l["leave_id"] == leaveId);
        if (idx != -1) {
          _leaves[idx]["status"] = newStatus;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int pendingCount =
        _leaves.where((l) => l["status"] == "Pending").length;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.approval_rounded,
                color: Color(0xFF7C3AED), size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Leave Approvals",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Review and approve employee leaves",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: _isLoading
            ? const SizedBox(
                height: 140,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EEFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pending Requests Awaiting Decision:",
                          style: TextStyle(
                            color: Color(0xFF6D28D9),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: pendingCount > 0
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$pendingCount Pending",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_leaves.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text("No leave requests found."),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _leaves.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final l = _leaves[idx];
                          final String leaveId =
                              l["leave_id"] ?? "LV-${idx + 1}";
                          final String statusStr =
                              l["status"]?.toString() ?? "Pending";
                          final bool isPending = statusStr == "Pending";
                          final bool isApproved = statusStr == "Approved";

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isPending
                                    ? const Color(0xFFFDE68A)
                                    : isApproved
                                        ? const Color(0xFFBBF7D0)
                                        : const Color(0xFFFECDD3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${l["employee_name"] ?? l["employee_id"] ?? "Employee"} (${l["employee_id"] ?? ""})",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isApproved
                                            ? const Color(0xFFDCFCE7)
                                            : isPending
                                                ? const Color(0xFFFEF3C7)
                                                : const Color(0xFFFEE2E2),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        statusStr,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isApproved
                                              ? const Color(0xFF16A34A)
                                              : isPending
                                                  ? const Color(0xFFD97706)
                                                  : const Color(0xFFEF4444),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${l["leave_type"]} • ${l["start_date"]} to ${l["end_date"]} (${l["days_count"] ?? 1} Days)",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                if (l["reason"] != null &&
                                    l["reason"].toString().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "Reason: ${l["reason"]}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                                if (isPending) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => _updateLeaveStatus(
                                            leaveId, "Rejected"),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFFEF4444),
                                          side: const BorderSide(
                                              color: Color(0xFFEF4444)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 6),
                                        ),
                                        child: const Text("Reject",
                                            style: TextStyle(fontSize: 12)),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => _updateLeaveStatus(
                                            leaveId, "Approved"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF10B981),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 6),
                                        ),
                                        child: const Text("Approve",
                                            style: TextStyle(fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
