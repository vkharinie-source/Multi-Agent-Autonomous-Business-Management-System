import 'package:flutter/material.dart';

class MyLeaveScreen extends StatelessWidget {
  const MyLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> leaves = [
      {
        'type': 'Sick Leave',
        'date': '23 July 2026',
        'days': '1 Day',
        'status': 'Approved',
      },
      {
        'type': 'Casual Leave',
        'date': '15 July 2026',
        'days': '2 Days',
        'status': 'Pending',
      },
      {
        'type': 'Personal Leave',
        'date': '04 July 2026',
        'days': '1 Day',
        'status': 'Rejected',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Leave',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1548E8), Color(0xFF7056F5)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                Icon(Icons.event_available, color: Colors.white, size: 45),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Leave',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '8 Days',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Leave Requests',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...leaves.map((Map<String, String> leave) {
            final String status = leave['status']!;

            final Color color = status == 'Approved'
                ? Colors.green
                : status == 'Pending'
                ? Colors.orange
                : Colors.red;

            return Card(
              margin: const EdgeInsets.only(bottom: 11),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.13),
                  child: Icon(Icons.event_note_outlined, color: color),
                ),
                title: Text(
                  leave['type']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${leave['date']} • ${leave['days']}'),
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
