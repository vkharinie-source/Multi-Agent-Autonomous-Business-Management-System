import 'package:flutter/material.dart';

class MyAttendanceScreen extends StatelessWidget {
  const MyAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> attendance = [
      {
        'date': '26 July 2026',
        'checkIn': '09:05 AM',
        'checkOut': '05:42 PM',
        'status': 'Present',
      },
      {
        'date': '25 July 2026',
        'checkIn': '09:12 AM',
        'checkOut': '05:35 PM',
        'status': 'Present',
      },
      {
        'date': '24 July 2026',
        'checkIn': '09:42 AM',
        'checkOut': '05:45 PM',
        'status': 'Late',
      },
      {
        'date': '23 July 2026',
        'checkIn': '--',
        'checkOut': '--',
        'status': 'Leave',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Attendance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: const [
              _AttendanceSummary(
                title: 'Present',
                value: '21',
                color: Colors.green,
              ),
              _AttendanceSummary(
                title: 'Absent',
                value: '1',
                color: Colors.red,
              ),
              _AttendanceSummary(
                title: 'Late',
                value: '2',
                color: Colors.orange,
              ),
              _AttendanceSummary(
                title: 'Percentage',
                value: '94%',
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Attendance History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...attendance.map((Map<String, String> record) {
            final String status = record['status']!;

            final Color color = status == 'Present'
                ? Colors.green
                : status == 'Late'
                ? Colors.orange
                : status == 'Leave'
                ? Colors.blue
                : Colors.red;

            return Card(
              margin: const EdgeInsets.only(bottom: 11),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.13),
                  child: Icon(Icons.event_available_outlined, color: color),
                ),
                title: Text(
                  record['date']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'In: ${record['checkIn']}  •  Out: ${record['checkOut']}',
                ),
                trailing: Text(
                  status,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AttendanceSummary extends StatelessWidget {
  const _AttendanceSummary({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }
}
