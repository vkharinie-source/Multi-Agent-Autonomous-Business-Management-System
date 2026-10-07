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
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Color(0xFF0F172A),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
            height: 1,
          ),
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
