import 'package:flutter/material.dart';

class EmployeeNotificationsScreen extends StatelessWidget {
  const EmployeeNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const List<_EmployeeNotification> notifications = [
      _EmployeeNotification(
        title: 'Leave request approved',
        message: 'Your sick leave request has been approved.',
        time: '10 minutes ago',
        icon: Icons.check_circle_outline,
        color: Colors.green,
      ),
      _EmployeeNotification(
        title: 'New task assigned',
        message: 'Complete the monthly sales report before 4:00 PM.',
        time: '1 hour ago',
        icon: Icons.task_alt_outlined,
        color: Colors.blue,
      ),
      _EmployeeNotification(
        title: 'Company meeting',
        message: 'Monthly employee meeting is scheduled for Friday.',
        time: 'Yesterday',
        icon: Icons.campaign_outlined,
        color: Colors.orange,
      ),
      _EmployeeNotification(
        title: 'Salary credited',
        message: 'Your July salary has been processed.',
        time: '2 days ago',
        icon: Icons.payments_outlined,
        color: Colors.deepPurple,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: notifications.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 10);
        },
        itemBuilder: (BuildContext context, int index) {
          final _EmployeeNotification notification = notifications[index];

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: CircleAvatar(
                backgroundColor: notification.color.withValues(alpha: 0.13),
                child: Icon(notification.icon, color: notification.color),
              ),
              title: Text(
                notification.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text('${notification.message}\n${notification.time}'),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

class _EmployeeNotification {
  const _EmployeeNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
}
