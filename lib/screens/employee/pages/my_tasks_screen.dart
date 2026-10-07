import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/services/secure_storage_service.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  String _selectedFilter = 'All';

  final List<_EmployeeTask> _tasks = [
    _EmployeeTask(
      id: 'TASK-01',
      title: 'Complete monthly sales report',
      deadline: 'Today, 4:00 PM',
      priority: 'High',
    ),
    _EmployeeTask(
      id: 'TASK-02',
      title: 'Update customer information',
      deadline: 'Tomorrow',
      priority: 'Medium',
    ),
    _EmployeeTask(
      id: 'TASK-03',
      title: 'Attend team meeting',
      deadline: 'Friday, 3:00 PM',
      priority: 'Medium',
    ),
    _EmployeeTask(
      id: 'TASK-04',
      title: 'Review assigned documents',
      deadline: '30 July 2026',
      priority: 'Low',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchTasksFromBackend();
  }

  Future<void> _fetchTasksFromBackend() async {
    try {
      final String? token =
          await SecureStorageService.instance.readAccessToken();
      final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/tasks/me');
      final http.Response res = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(res.body) as Map<String, dynamic>;
        final List<dynamic>? list = body['tasks'] as List<dynamic>?;
        if (list != null && list.isNotEmpty && mounted) {
          setState(() {
            _tasks.clear();
            for (final dynamic item in list) {
              final Map<String, dynamic> m = item as Map<String, dynamic>;
              final _EmployeeTask t = _EmployeeTask(
                id: m['task_id'] ?? m['id'] ?? 'TASK-00',
                title: m['title'] ?? 'Assigned Task',
                deadline: m['deadline'] ?? 'Today',
                priority: m['priority'] ?? 'Medium',
              );
              t.completed = m['completed'] == true;
              _tasks.add(t);
            }
          });
        }
      }
    } catch (_) {
      // Graceful fallback to initial seed tasks
    }
  }

  Future<void> _toggleTaskInBackend(String taskId) async {
    try {
      final String? token =
          await SecureStorageService.instance.readAccessToken();
      final Uri uri =
          Uri.parse('${ApiConfig.baseUrl}/api/tasks/$taskId/toggle');
      await http.patch(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      // Handled gracefully
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFD97706);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
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

  List<_EmployeeTask> get _filteredTasks {
    if (_selectedFilter == 'Pending') {
      return _tasks.where((t) => !t.completed).toList();
    } else if (_selectedFilter == 'Completed') {
      return _tasks.where((t) => t.completed).toList();
    }
    return _tasks;
  }

  @override
  Widget build(BuildContext context) {
    final int completedTasks =
        _tasks.where((_EmployeeTask task) => task.completed).length;
    final int totalTasks = _tasks.length;
    final double progressValue =
        totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final int percentInt = (progressValue * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
        title: Text(
          'My Tasks',
          style: GoogleFonts.inter(
            color: const Color(0xFF0F172A),
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Top Task Progress Hero Card
            _buildTaskSummary(
              context,
              completedTasks,
              totalTasks,
              progressValue,
              percentInt,
            ),

            const SizedBox(height: 22),

            // Filter Tabs
            _buildFilterTabs(completedTasks, totalTasks),

            const SizedBox(height: 20),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedFilter == 'All'
                      ? 'Assigned Tasks'
                      : '$_selectedFilter Tasks',
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_filteredTasks.length} tasks',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Task Cards List
            if (_filteredTasks.isEmpty)
              _buildEmptyState(context)
            else
              ..._filteredTasks.map((task) => _buildTaskCard(context, task)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(int completedCount, int totalCount) {
    final int pendingCount = totalCount - completedCount;
    final List<Map<String, dynamic>> tabs = [
      {'key': 'All', 'label': 'All', 'count': totalCount},
      {'key': 'Pending', 'label': 'Pending', 'count': pendingCount},
      {'key': 'Completed', 'label': 'Done', 'count': completedCount},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: tabs.map((tab) {
          final bool isSelected = _selectedFilter == tab['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = tab['key'] as String;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tab['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF4338CA)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEEF2FF)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tab['count']}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? const Color(0xFF4338CA)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskSummary(
    BuildContext context,
    int completedTasks,
    int totalTasks,
    double progressValue,
    int percentInt,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEDE9FE), Color(0xFFDDD6FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF6D28D9),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Progress',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$completedTasks of $totalTasks tasks completed',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: percentInt == 100
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percentInt%',
                  style: GoogleFonts.inter(
                    color: percentInt == 100
                        ? const Color(0xFF15803D)
                        : const Color(0xFF6D28D9),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                percentInt == 100
                    ? const Color(0xFF10B981)
                    : const Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, _EmployeeTask task) {
    final Color priorityColor = _getPriorityColor(task.priority);
    final Color priorityBg = _getPriorityBgColor(task.priority);
    final IconData leadingIcon = _getPriorityLeadingIcon(task.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.completed
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              task.completed = !task.completed;
            });
            _toggleTaskInBackend(task.id);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: task.completed
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF334155),
                content: Text(
                  task.completed
                      ? '✓ "${task.title}" completed!'
                      : 'Task marked as pending.',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: task.completed
                        ? const Color(0xFFF1F5F9)
                        : priorityBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    task.completed ? Icons.task_alt_rounded : leadingIcon,
                    color: task.completed
                        ? const Color(0xFF94A3B8)
                        : priorityColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Task Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: task.completed
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF0F172A),
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: const Color(0xFF94A3B8),
                          letterSpacing: -0.2,
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
                            icon: Icons.flag_rounded,
                            label: '${task.priority} Priority',
                            color: priorityColor,
                            bgColor: priorityBg,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Checkbox status indicator
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.completed
                          ? const Color(0xFF10B981)
                          : Colors.transparent,
                      border: Border.all(
                        color: task.completed
                            ? const Color(0xFF10B981)
                            : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                    ),
                    child: task.completed
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
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
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.task_alt_rounded,
            size: 52,
            color: Color(0xFF6366F1),
          ),
          const SizedBox(height: 14),
          Text(
            'No Tasks Found',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedFilter == 'Completed'
                ? 'You have not completed any tasks yet.'
                : 'No pending tasks right now.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
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
    required this.id,
    required this.title,
    required this.deadline,
    required this.priority,
  });

  final String id;
  final String title;
  final String deadline;
  final String priority;

  bool completed = false;
}


