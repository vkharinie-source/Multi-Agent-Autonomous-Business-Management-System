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

  final List<Map<String, dynamic>> attendanceRecords = [
    {
      "employeeId": "EMP001",
      "name": "Harinie V K",
      "department": "IT",
      "date": "12 Jul 2026",
      "checkIn": "09:02 AM",
      "checkOut": "06:05 PM",
      "status": "Present",
      "workingHours": "9h 03m",
    },
    {
      "employeeId": "EMP002",
      "name": "Priya S",
      "department": "Sales",
      "date": "12 Jul 2026",
      "checkIn": "09:34 AM",
      "checkOut": "06:10 PM",
      "status": "Late",
      "workingHours": "8h 36m",
    },
    {
      "employeeId": "EMP003",
      "name": "Arun K",
      "department": "Finance",
      "date": "12 Jul 2026",
      "checkIn": "--",
      "checkOut": "--",
      "status": "Absent",
      "workingHours": "0h",
    },
    {
      "employeeId": "EMP004",
      "name": "Rahul M",
      "department": "HR",
      "date": "11 Jul 2026",
      "checkIn": "08:55 AM",
      "checkOut": "05:58 PM",
      "status": "Present",
      "workingHours": "9h 03m",
    },
    {
      "employeeId": "EMP005",
      "name": "Divya R",
      "department": "IT",
      "date": "11 Jul 2026",
      "checkIn": "--",
      "checkOut": "--",
      "status": "Leave",
      "workingHours": "0h",
    },
    {
      "employeeId": "EMP006",
      "name": "Karthik S",
      "department": "Sales",
      "date": "10 Jul 2026",
      "checkIn": "09:18 AM",
      "checkOut": "06:00 PM",
      "status": "Late",
      "workingHours": "8h 42m",
    },
  ];

  List<Map<String, dynamic>> get filteredRecords {
    final query = searchController.text.trim().toLowerCase();

    return attendanceRecords.where((record) {
      final matchesSearch =
          record["name"].toString().toLowerCase().contains(query) ||
          record["employeeId"].toString().toLowerCase().contains(query) ||
          record["department"].toString().toLowerCase().contains(query);

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
    final records = filteredRecords;

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summarySection(),
                  const SizedBox(height: 24),
                  _filterSection(),
                  const SizedBox(height: 24),
                  _historyTable(records),
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
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 34),
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
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Attendance History",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "View employee attendance, check-in, check-out and working hours",
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summarySection() {
    final present = attendanceRecords
        .where((e) => e["status"] == "Present")
        .length;
    final late = attendanceRecords.where((e) => e["status"] == "Late").length;
    final absent = attendanceRecords
        .where((e) => e["status"] == "Absent")
        .length;
    final leave = attendanceRecords.where((e) => e["status"] == "Leave").length;

    return Row(
      children: [
        _summaryCard(
          "Present",
          "$present",
          Icons.check_circle,
          const Color(0xff16A34A),
        ),
        const SizedBox(width: 18),
        _summaryCard(
          "Late",
          "$late",
          Icons.access_time_filled,
          const Color(0xffF59E0B),
        ),
        const SizedBox(width: 18),
        _summaryCard(
          "Absent",
          "$absent",
          Icons.cancel,
          const Color(0xffEF4444),
        ),
        const SizedBox(width: 18),
        _summaryCard(
          "Leave",
          "$leave",
          Icons.event_available,
          const Color(0xff8B5CF6),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            CircleAvatar(
              radius: 29,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xff8A8FA3),
                    fontSize: 14,
                  ),
                ),
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
      ),
    );
  }

  Widget _filterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search employee name, ID or department...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xffF8FAFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedDepartment,
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
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
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
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyTable(List<Map<String, dynamic>> records) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Employee Attendance Records",
                style: TextStyle(
                  color: Color(0xff081A63),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffEEF4FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${records.length} Records",
                  style: const TextStyle(
                    color: Color(0xff2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _tableHeader(),
          const SizedBox(height: 10),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 55, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      "No attendance records found",
                      style: TextStyle(color: Colors.grey, fontSize: 17),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (context, index) {
                return _recordRow(records[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
          Expanded(child: Text("Working Hours")),
          Expanded(child: Text("Status")),
        ],
      ),
    );
  }

  Widget _recordRow(Map<String, dynamic> record) {
    final status = record["status"].toString();
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      decoration: BoxDecoration(
        color: const Color(0xffFAFBFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE7EAF3)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: const Color(
                    0xff2563EB,
                  ).withValues(alpha: 0.10),
                  child: Text(
                    record["name"].toString().substring(0, 1),
                    style: const TextStyle(
                      color: Color(0xff2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record["name"].toString(),
                        style: const TextStyle(
                          color: Color(0xff081A63),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        record["employeeId"].toString(),
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
          Expanded(child: Text(record["department"].toString())),
          Expanded(child: Text(record["date"].toString())),
          Expanded(child: Text(record["checkIn"].toString())),
          Expanded(child: Text(record["checkOut"].toString())),
          Expanded(child: Text(record["workingHours"].toString())),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
