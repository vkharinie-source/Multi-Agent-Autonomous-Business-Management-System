import 'package:flutter/material.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  final List<_EmployeeTask> _tasks = [
    _EmployeeTask(
      title: 'Complete monthly sales report',
      deadline: 'Today, 4:00 PM',
      priority: 'High',
    ),
    _EmployeeTask(
      title: 'Update customer information',
      deadline: 'Tomorrow',
      priority: 'Medium',
    ),
    _EmployeeTask(
      title: 'Attend team meeting',
      deadline: 'Friday, 3:00 PM',
      priority: 'Medium',
    ),
    _EmployeeTask(
      title: 'Review assigned documents',
      deadline: '30 July 2026',
      priority: 'Low',
    ),
  ];

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;

      case 'medium':
        return Colors.orange;

      case 'low':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.priority_high_rounded;

      case 'medium':
        return Icons.flag_outlined;

      case 'low':
        return Icons.low_priority_rounded;

      default:
        return Icons.flag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int completedTasks = _tasks
        .where((_EmployeeTask task) => task.completed)
        .length;

    final double progressValue = _tasks.isEmpty
        ? 0.0
        : completedTasks / _tasks.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildTaskSummary(context, completedTasks, progressValue),
            const SizedBox(height: 22),
            const Text(
              'Assigned Tasks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (_tasks.isEmpty)
              _buildEmptyState(context)
            else
              ...List.generate(_tasks.length, (int index) {
                return _buildTaskCard(context, index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSummary(
    BuildContext context,
    int completedTasks,
    double progressValue,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.task_alt_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Task Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedTasks of ${_tasks.length} tasks completed',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progressValue * 100).round()}%',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: progressValue,
            minHeight: 10,
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, int index) {
    final _EmployeeTask task = _tasks[index];

    final Color priorityColor = _getPriorityColor(task.priority);

    final IconData priorityIcon = _getPriorityIcon(task.priority);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: CheckboxListTile(
        value: task.completed,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        activeColor: Theme.of(context).colorScheme.primary,
        controlAffinity: ListTileControlAffinity.trailing,
        onChanged: (bool? value) {
          setState(() {
            task.completed = value ?? false;
          });

          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                task.completed
                    ? 'Task marked as completed.'
                    : 'Task marked as incomplete.',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        secondary: CircleAvatar(
          radius: 23,
          backgroundColor: priorityColor.withAlpha(33),
          child: Icon(priorityIcon, color: priorityColor),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            decoration: task.completed
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.completed
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 10,
            runSpacing: 7,
            children: [
              _buildInformationChip(
                icon: Icons.schedule_outlined,
                label: task.deadline,
                color: Colors.blue,
              ),
              _buildInformationChip(
                icon: Icons.flag_outlined,
                label: '${task.priority} Priority',
                color: priorityColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 14),
          const Text(
            'No Tasks Assigned',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Your assigned tasks will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeTask {
  _EmployeeTask({
    required this.title,
    required this.deadline,
    required this.priority,
  });

  final String title;
  final String deadline;
  final String priority;

  bool completed = false;
}
