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
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityBgColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFFEE2E2);
      case 'medium':
        return const Color(0xFFFEF3C7);
      case 'low':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData _getPriorityLeadingIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.priority_high_rounded;
      case 'medium':
        return Icons.flag_rounded;
      case 'low':
        return Icons.fact_check_outlined;
      default:
        return Icons.task_alt_rounded;
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
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'My Tasks',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            _buildTaskSummary(context, completedTasks, progressValue),
            const SizedBox(height: 24),
            const Text(
              'Assigned Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: 14),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF7C3AED),
                  size: 26,
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
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$completedTasks of ${_tasks.length} tasks completed',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDE9FE),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, int index) {
    final _EmployeeTask task = _tasks[index];
    final Color priorityColor = _getPriorityColor(task.priority);
    final Color priorityBg = _getPriorityBgColor(task.priority);
    final IconData leadingIcon = _getPriorityLeadingIcon(task.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            setState(() {
              task.completed = !task.completed;
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: priorityBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    leadingIcon,
                    color: priorityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: task.completed
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF1E293B),
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildInformationChip(
                            icon: Icons.access_time_rounded,
                            label: task.deadline,
                            color: const Color(0xFF0284C7),
                            bgColor: const Color(0xFFE0F2FE),
                          ),
                          _buildInformationChip(
                            icon: Icons.flag_outlined,
                            label: '${task.priority} Priority',
                            color: priorityColor,
                            bgColor: priorityBg,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (task.completed)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 22,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInformationChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 56,
            color: Color(0xFF7C3AED),
          ),
          SizedBox(height: 14),
          Text(
            'No Tasks Assigned',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your assigned tasks will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 13,
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

