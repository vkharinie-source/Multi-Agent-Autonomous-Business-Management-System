import 'package:flutter/material.dart';

class MyPerformanceScreen extends StatelessWidget {
  const MyPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const List<_PerformanceMetric> metrics = [
      _PerformanceMetric(
        title: 'Task Completion',
        value: 0.92,
        displayValue: '92%',
        color: Colors.blue,
      ),
      _PerformanceMetric(
        title: 'Attendance',
        value: 0.94,
        displayValue: '94%',
        color: Colors.green,
      ),
      _PerformanceMetric(
        title: 'Work Quality',
        value: 0.88,
        displayValue: '88%',
        color: Colors.deepPurple,
      ),
      _PerformanceMetric(
        title: 'Team Collaboration',
        value: 0.90,
        displayValue: '90%',
        color: Colors.orange,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Performance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(23),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF35168A), Color(0xFF7757F4)],
              ),
              borderRadius: BorderRadius.circular(23),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Text(
                    '90',
                    style: TextStyle(
                      color: Color(0xFF35168A),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: 17),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Performance Score',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Excellent',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 21),
          ...metrics.map((_PerformanceMetric metric) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            metric.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          metric.displayValue,
                          style: TextStyle(
                            color: metric.color,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: metric.value,
                      minHeight: 10,
                      color: metric.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          const Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.emoji_events_outlined, color: Colors.green),
              ),
              title: Text(
                'Manager Feedback',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Consistently completes assigned tasks and collaborates well with the team.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceMetric {
  const _PerformanceMetric({
    required this.title,
    required this.value,
    required this.displayValue,
    required this.color,
  });

  final String title;
  final double value;
  final String displayValue;
  final Color color;
}
