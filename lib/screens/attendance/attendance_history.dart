import 'package:flutter/material.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedDepartment = "All";
  String selectedStatus = "All";

  final List<Map<String, String>> records = [
    {
      "id": "EMP001",
      "name": "Harinie V K",
      "department": "IT",
      "date": "13 Jul 2026",
      "checkIn": "09:02 AM",
      "checkOut": "06:05 PM",
      "hours": "9h 03m",
      "status": "Present",
    },
    {
      "id": "EMP002",
      "name": "Priya S",
      "department": "Sales",
      "date": "13 Jul 2026",
      "checkIn": "09:35 AM",
      "checkOut": "06:10 PM",
      "hours": "8h 35m",
      "status": "Late",
    },
    {
      "id": "EMP003",
      "name": "Arun K",
      "department": "Finance",
      "date": "13 Jul 2026",
      "checkIn": "--",
      "checkOut": "--",
      "hours": "0h",
      "status": "Absent",
    },
    {
      "id": "EMP004",
      "name": "Rahul M",
      "department": "HR",
      "date": "12 Jul 2026",
      "checkIn": "08:55 AM",
      "checkOut": "05:58 PM",
      "hours": "9h 03m",
      "status": "Present",
    },
    {
      "id": "EMP005",
      "name": "Divya R",
      "department": "IT",
      "date": "12 Jul 2026",
      "checkIn": "--",
      "checkOut": "--",
      "hours": "0h",
      "status": "Leave",
    },
  ];

  List<Map<String, String>> get filteredRecords {
    final query = searchController.text.trim().toLowerCase();

    return records.where((record) {
      final matchesSearch =
          record["name"]!.toLowerCase().contains(query) ||
          record["id"]!.toLowerCase().contains(query) ||
          record["department"]!.toLowerCase().contains(query);

      final matchesDepartment =
          selectedDepartment == "All" ||
          record["department"] == selectedDepartment;

      final matchesStatus =
          selectedStatus == "All" || record["status"] == selectedStatus;

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

          return Column(
            children: [
              _header(context, isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 14 : 26),
                  child: Column(
                    children: [
                      _summarySection(isMobile),
                      SizedBox(height: isMobile ? 16 : 24),
                      _filterSection(isMobile),
                      SizedBox(height: isMobile ? 16 : 24),
                      _historySection(isMobile),
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
                    "Attendance History",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 22 : 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isMobile
                        ? "View previous attendance records"
                        : "View employee check-in, check-out and working-hour records",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isMobile ? 12 : 15,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMobile)
              const Icon(Icons.history_rounded, color: Colors.white, size: 40),
          ],
        ),
      ),
    );
  }

  Widget _summarySection(bool isMobile) {
    final present = records.where((e) => e["status"] == "Present").length;
    final late = records.where((e) => e["status"] == "Late").length;
    final absent = records.where((e) => e["status"] == "Absent").length;
    final leave = records.where((e) => e["status"] == "Leave").length;

    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isMobile ? 10 : 18,
      mainAxisSpacing: isMobile ? 10 : 18,
      childAspectRatio: isMobile ? 1.3 : 1.8,
      children: [
        _summaryCard(
          "Present",
          "$present",
          Icons.check_circle,
          const Color(0xff16A34A),
          isMobile,
        ),
        _summaryCard(
          "Late",
          "$late",
          Icons.access_time,
          const Color(0xffF59E0B),
          isMobile,
        ),
        _summaryCard(
          "Absent",
          "$absent",
          Icons.cancel,
          const Color(0xffEF4444),
          isMobile,
        ),
        _summaryCard(
          "Leave",
          "$leave",
          Icons.event_available,
          const Color(0xff8B5CF6),
          isMobile,
        ),
      ],
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
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
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xff081A63),
                    fontSize: 23,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xff081A63),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
        labelText: "Status",
        filled: true,
        fillColor: const Color(0xffF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: "All", child: Text("All Status")),
        DropdownMenuItem(value: "Present", child: Text("Present")),
        DropdownMenuItem(value: "Late", child: Text("Late")),
        DropdownMenuItem(value: "Absent", child: Text("Absent")),
        DropdownMenuItem(value: "Leave", child: Text("Leave")),
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

  Widget _historySection(bool isMobile) {
    final data = filteredRecords;

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
                  "Employee Attendance Records",
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
                  color: const Color(0xff2563EB).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${data.length} Records",
                  style: const TextStyle(
                    color: Color(0xff2563EB),
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
                  "No records found",
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
                return isMobile
                    ? _mobileRecordCard(data[index])
                    : _desktopRecordRow(data[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _desktopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xffEEF4FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text("Employee")),
          Expanded(child: Text("Department")),
          Expanded(child: Text("Date")),
          Expanded(child: Text("Check-in")),
          Expanded(child: Text("Check-out")),
          Expanded(child: Text("Hours")),
          Expanded(child: Text("Status")),
        ],
      ),
    );
  }

  Widget _desktopRecordRow(Map<String, String> item) {
    final color = _statusColor(item["status"]!);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                    item["name"]![0],
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"]!,
                        style: const TextStyle(
                          color: Color(0xff081A63),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item["id"]!,
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
          Expanded(child: Text(item["department"]!)),
          Expanded(child: Text(item["date"]!)),
          Expanded(child: Text(item["checkIn"]!)),
          Expanded(child: Text(item["checkOut"]!)),
          Expanded(child: Text(item["hours"]!)),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusBadge(item["status"]!, color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileRecordCard(Map<String, String> item) {
    final color = _statusColor(item["status"]!);

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
                  item["name"]![0],
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["name"]!,
                      style: const TextStyle(
                        color: Color(0xff081A63),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${item["id"]} • ${item["department"]}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _statusBadge(item["status"]!, color),
            ],
          ),
          const SizedBox(height: 14),
          _detailRow("Date", item["date"]!),
          _detailRow("Check-in", item["checkIn"]!),
          _detailRow("Check-out", item["checkOut"]!),
          _detailRow("Working Hours", item["hours"]!),
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
    switch (status) {
      case "Present":
        return const Color(0xff16A34A);
      case "Late":
        return const Color(0xffF59E0B);
      case "Absent":
        return const Color(0xffEF4444);
      case "Leave":
        return const Color(0xff8B5CF6);
      default:
        return Colors.grey;
    }
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
