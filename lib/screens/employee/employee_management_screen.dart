import 'package:flutter/material.dart';

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
      "salary": 35000,
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
      "salary": 28000,
      "attendance": 85,
      "leave": 4,
      "performance": 80,
    },
  ];

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
                input(salary, "Salary", number: true),
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
            onPressed: () {
              final data = {
                "id": id.text,
                "name": name.text,
                "email": email.text,
                "phone": phone.text,
                "department": department.text,
                "designation": designation.text,
                "salary": int.tryParse(salary.text) ?? 0,
                "attendance": int.tryParse(attendance.text) ?? 0,
                "leave": int.tryParse(leave.text) ?? 0,
                "performance": int.tryParse(performance.text) ?? 0,
              };

              setState(() {
                if (index == null) {
                  employees.add(data);
                } else {
                  employees[index] = data;
                }
              });

              Navigator.pop(context);
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
            ],
          ),
        ),
      ),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 28,
        isMobile ? 20 : 30,
        isMobile ? 16 : 28,
        isMobile ? 24 : 34,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff020A3D), Color(0xff2563EB), Color(0xff9333EA)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: isMobile ? 6 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Employee Management",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 20 : 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
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
            const Spacer(),
            const Icon(Icons.badge, color: Colors.white, size: 42),
          ] else
            const Icon(Icons.badge, color: Colors.white, size: 30),
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
          separatorBuilder: (_, __) => const SizedBox(width: 14),
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

    final addButton = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 24,
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
                SizedBox(width: double.infinity, child: addButton),
              ],
            )
          : Row(
              children: [
                Expanded(child: searchField),
                const SizedBox(width: 16),
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
