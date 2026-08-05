import 'package:flutter/material.dart';

class LateArrivalScreen extends StatefulWidget {
  const LateArrivalScreen({super.key});

  @override
  State<LateArrivalScreen> createState() => _LateArrivalScreenState();
}

class _LateArrivalScreenState extends State<LateArrivalScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedDepartment = "All";
  String selectedStatus = "All";

  final List<Map<String, dynamic>> lateEmployees = [
    {
      "id": "EMP001",
      "name": "Harinie V K",
      "department": "IT",
      "date": "14 Jul 2026",
      "checkIn": "09:18 AM",
      "lateMinutes": 18,
      "status": "Late",
    },
    {
      "id": "EMP002",
      "name": "Priya S",
      "department": "Sales",
      "date": "14 Jul 2026",
      "checkIn": "09:42 AM",
      "lateMinutes": 42,
      "status": "Very Late",
    },
    {
      "id": "EMP003",
      "name": "Rahul M",
      "department": "Finance",
      "date": "14 Jul 2026",
      "checkIn": "09:11 AM",
      "lateMinutes": 11,
      "status": "Late",
    },
    {
      "id": "EMP004",
      "name": "Arun K",
      "department": "HR",
      "date": "14 Jul 2026",
      "checkIn": "09:55 AM",
      "lateMinutes": 55,
      "status": "Very Late",
    },
    {
      "id": "EMP005",
      "name": "Divya R",
      "department": "IT",
      "date": "13 Jul 2026",
      "checkIn": "09:08 AM",
      "lateMinutes": 8,
      "status": "Late",
    },
  ];

  List<Map<String, dynamic>> get filteredEmployees {
    final query = searchController.text.trim().toLowerCase();

    return lateEmployees.where((employee) {
      final matchesSearch =
          employee["name"].toString().toLowerCase().contains(query) ||
          employee["id"].toString().toLowerCase().contains(query) ||
          employee["department"].toString().toLowerCase().contains(query);

      final matchesDepartment =
          selectedDepartment == "All" ||
          employee["department"] == selectedDepartment;

      final matchesStatus =
          selectedStatus == "All" || employee["status"] == selectedStatus;

      return matchesSearch && matchesDepartment && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          final isTablet =
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
                      _summarySection(isMobile: isMobile, isTablet: isTablet),
                      SizedBox(height: isMobile ? 16 : 24),
                      _filterSection(isMobile),
                      SizedBox(height: isMobile ? 16 : 24),
                      _mainSection(isMobile: isMobile, isTablet: isTablet),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Late Arrival Detection",
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
                        ? "Track employees arriving after office time"
                        : "Detect late check-ins, calculate delay and review attendance patterns",
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
            if (!isMobile)
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.timer, color: Colors.white, size: 36),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summarySection({required bool isMobile, required bool isTablet}) {
    final veryLate = lateEmployees
        .where((e) => e["status"] == "Very Late")
        .length;

    final averageLate = lateEmployees.isEmpty
        ? 0
        : lateEmployees
                  .map((e) => e["lateMinutes"] as int)
                  .reduce((a, b) => a + b) ~/
              lateEmployees.length;

    final columnCount = isMobile || isTablet ? 2 : 4;

    return GridView.count(
      crossAxisCount: columnCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 10 : 18,
      mainAxisSpacing: isMobile ? 10 : 18,
      childAspectRatio: isMobile ? 1.25 : 1.8,
      children: [
        _summaryCard(
          title: "Late Today",
          value: "${lateEmployees.length}",
          icon: Icons.access_time_filled,
          color: const Color(0xffF59E0B),
          isMobile: isMobile,
        ),
        _summaryCard(
          title: "Very Late",
          value: "$veryLate",
          icon: Icons.warning_rounded,
          color: const Color(0xffEF4444),
          isMobile: isMobile,
        ),
        _summaryCard(
          title: "Average Delay",
          value: "$averageLate min",
          icon: Icons.timer_outlined,
          color: const Color(0xff8B5CF6),
          isMobile: isMobile,
        ),
        _summaryCard(
          title: "Office Time",
          value: "09:00",
          icon: Icons.business_center,
          color: const Color(0xff2563EB),
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      decoration: _card(),
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
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xff081A63),
                          fontSize: 24,
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

  Widget _filterSection(bool isMobile) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _card(),
        child: Column(
          children: [
            _searchField(),
            const SizedBox(height: 12),
            _departmentDropdown(),
            const SizedBox(height: 12),
            _statusDropdown(),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: _resetButton()),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _card(),
      child: Row(
        children: [
          Expanded(flex: 2, child: _searchField()),
          const SizedBox(width: 16),
          Expanded(child: _departmentDropdown()),
          const SizedBox(width: 16),
          Expanded(child: _statusDropdown()),
          const SizedBox(width: 16),
          _resetButton(),
        ],
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: "Search employee, ID or department...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xffF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _departmentDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedDepartment,
      decoration: InputDecoration(
        labelText: "Department",
        filled: true,
        fillColor: const Color(0xffF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: "All", child: Text("All Departments")),
        DropdownMenuItem(value: "IT", child: Text("IT")),
        DropdownMenuItem(value: "Sales", child: Text("Sales")),
        DropdownMenuItem(value: "Finance", child: Text("Finance")),
        DropdownMenuItem(value: "HR", child: Text("HR")),
      ],
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          selectedDepartment = value;
        });
      },
    );
  }

  Widget _statusDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedStatus,
      decoration: InputDecoration(
        labelText: "Late Status",
        filled: true,
        fillColor: const Color(0xffF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: "All", child: Text("All Status")),
        DropdownMenuItem(value: "Late", child: Text("Late")),
        DropdownMenuItem(value: "Very Late", child: Text("Very Late")),
      ],
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          selectedStatus = value;
        });
      },
    );
  }

  Widget _resetButton() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          searchController.clear();
          selectedDepartment = "All";
          selectedStatus = "All";
        });
      },
      icon: const Icon(Icons.refresh),
      label: const Text("Reset"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _mainSection({required bool isMobile, required bool isTablet}) {
    if (isMobile || isTablet) {
      return Column(
        children: [
          _lateEmployeeSection(isMobile),
          const SizedBox(height: 16),
          _aiInsightCard(isMobile),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _lateEmployeeSection(false)),
        const SizedBox(width: 22),
        Expanded(child: _aiInsightCard(false)),
      ],
    );
  }

  Widget _lateEmployeeSection(bool isMobile) {
    final data = filteredEmployees;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Late Employee Records",
                  style: TextStyle(
                    color: const Color(0xff081A63),
                    fontSize: isMobile ? 19 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${data.length} Records",
                  style: const TextStyle(
                    color: Color(0xffF59E0B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (!isMobile) _desktopHeader(),
          if (!isMobile) const SizedBox(height: 8),
          if (data.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "No late arrival records found",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final employee = data[index];

                return isMobile
                    ? _mobileEmployeeCard(employee)
                    : _desktopEmployeeRow(employee);
              },
            ),
        ],
      ),
    );
  }

  Widget _desktopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xffFFF7ED),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text("Employee")),
          Expanded(child: Text("Department")),
          Expanded(child: Text("Date")),
          Expanded(child: Text("Check-in")),
          Expanded(child: Text("Delay")),
          Expanded(child: Text("Status")),
          SizedBox(width: 90, child: Text("Action")),
        ],
      ),
    );
  }

  Widget _desktopEmployeeRow(Map<String, dynamic> employee) {
    final color = _statusColor(employee["status"].toString());

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xffFAFBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE8EAF2)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Text(
                    employee["name"].toString()[0],
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee["name"].toString(),
                        style: const TextStyle(
                          color: Color(0xff081A63),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        employee["id"].toString(),
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
          ),
          Expanded(child: Text(employee["department"].toString())),
          Expanded(child: Text(employee["date"].toString())),
          Expanded(child: Text(employee["checkIn"].toString())),
          Expanded(
            child: Text(
              "${employee["lateMinutes"]} min",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusBadge(employee["status"].toString(), color),
            ),
          ),
          SizedBox(
            width: 90,
            child: OutlinedButton(
              onPressed: () => _showActionDialog(employee),
              child: const Text("View"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileEmployeeCard(Map<String, dynamic> employee) {
    final color = _statusColor(employee["status"].toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffFAFBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE8EAF2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Text(
                  employee["name"].toString()[0],
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee["name"].toString(),
                      style: const TextStyle(
                        color: Color(0xff081A63),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${employee["id"]} • ${employee["department"]}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _statusBadge(employee["status"].toString(), color),
            ],
          ),
          const SizedBox(height: 14),
          _detailRow("Date", employee["date"].toString()),
          _detailRow("Check-in", employee["checkIn"].toString()),
          _detailRow("Late by", "${employee["lateMinutes"]} minutes"),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showActionDialog(employee),
              icon: const Icon(Icons.visibility),
              label: const Text("View Details"),
            ),
          ),
        ],
      ),
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
              Expanded(
                child: Text(
                  "AI Late Arrival Insights",
                  style: TextStyle(
                    color: const Color(0xff081A63),
                    fontSize: isMobile ? 19 : 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _insight(
            Icons.warning_rounded,
            "Sales department has the highest average delay.",
            const Color(0xffF59E0B),
          ),
          _insight(
            Icons.schedule,
            "Two employees arrived more than 40 minutes late.",
            const Color(0xffEF4444),
          ),
          _insight(
            Icons.notifications_active,
            "Send an automatic reminder at 8:45 AM.",
            const Color(0xff2563EB),
          ),
          _insight(
            Icons.trending_down,
            "Late arrivals decreased compared with last week.",
            const Color(0xff16A34A),
          ),
        ],
      ),
    );
  }

  Widget _insight(IconData icon, String text, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xff081A63),
                fontWeight: FontWeight.w600,
                height: 1.35,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(employee["name"].toString()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogRow("Employee ID", employee["id"].toString()),
              _dialogRow("Department", employee["department"].toString()),
              _dialogRow("Date", employee["date"].toString()),
              _dialogRow("Check-in", employee["checkIn"].toString()),
              _dialogRow("Late by", "${employee["lateMinutes"]} minutes"),
              _dialogRow("Status", employee["status"].toString()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Close"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Reminder sent to ${employee["name"]}."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text("Send Reminder"),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xff081A63),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
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
    if (status == "Very Late") {
      return const Color(0xffEF4444);
    }

    return const Color(0xffF59E0B);
  }

  BoxDecoration _card() {
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
