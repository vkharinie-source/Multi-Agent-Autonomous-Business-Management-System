import 'package:flutter/material.dart';

import '../../core/exceptions/api_exception.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../auth/login_screen.dart';
import '../settings/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'pages/apply_leave_screen.dart';
import 'pages/employee_notifications_screen.dart';
import 'pages/my_attendance_screen.dart';
import 'pages/my_leave_screen.dart';
import 'pages/my_performance_screen.dart';
import 'pages/my_salary_screen.dart';
import 'pages/my_tasks_screen.dart';
import 'pages/scan_attendance_screen.dart';
import 'pages/device_registration_screen.dart';
import 'pages/employee_ai_screen.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() {
    return _EmployeeDashboardState();
  }
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  bool _isLoadingUser = true;
  String? _loadError;

  Map<String, dynamic> _employee = <String, dynamic>{};

  String get _employeeName {
    final String name = _employee['name']?.toString().trim() ?? '';

    if (name.isEmpty) {
      return 'Employee';
    }

    return name;
  }

  String get _employeeId {
    final String employeeId = _employee['employee_id']?.toString().trim() ?? '';

    if (employeeId.isEmpty) {
      return 'Employee ID unavailable';
    }

    return employeeId;
  }

  String get _department {
    final String department = _employee['department']?.toString().trim() ?? '';

    if (department.isEmpty) {
      return 'Department unavailable';
    }

    return department;
  }

  String get _designation {
    final String designation =
        _employee['designation']?.toString().trim() ?? '';

    if (designation.isEmpty) {
      return 'Employee';
    }

    return designation;
  }

  String get _email {
    return _employee['email']?.toString().trim() ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentEmployee();
  }

  Future<void> _loadCurrentEmployee() async {
    if (mounted) {
      setState(() {
        _isLoadingUser = true;
        _loadError = null;
      });
    }

    try {
      final String? accessToken = await SecureStorageService.instance
          .readAccessToken();

      if (accessToken == null || accessToken.trim().isEmpty) {
        throw const ApiException(
          message: 'Login session was not found. Please sign in again.',
          statusCode: 401,
        );
      }

      final Map<String, dynamic> response = await AuthService.instance
          .getCurrentUser(accessToken: accessToken);

      final dynamic rawUser = response['user'] ?? response;

      if (rawUser is! Map) {
        throw const ApiException(
          message: 'Employee information was not returned by the backend.',
        );
      }

      final Map<String, dynamic> employee = Map<String, dynamic>.from(rawUser);

      if (!mounted) {
        return;
      }

      setState(() {
        _employee = employee;
        _isLoadingUser = false;
        _loadError = null;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingUser = false;
        _loadError = error.message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      String message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('ApiException: ', '')
          .trim();

      if (message.isEmpty) {
        message = 'Unable to load employee information.';
      }

      setState(() {
        _isLoadingUser = false;
        _loadError = message;
      });
    }
  }

  Future<void> _logout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text(
            'Are you sure you want to sign out of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await AuthService.instance.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return const LoginScreen();
        },
      ),
      (Route<dynamic> route) {
        return false;
      },
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }

  List<_EmployeeMenuItem> _menuItems() {
    return const [
      _EmployeeMenuItem(
        title: 'Scan Attendance QR',
        subtitle: 'Check in using company QR',
        icon: Icons.qr_code_scanner_rounded,
        page: ScanAttendanceScreen(),
      ),
      _EmployeeMenuItem(
        title: 'Attendance Device',
        subtitle: 'Register and check device approval',
        icon: Icons.phonelink_lock_rounded,
        page: DeviceRegistrationScreen(),
      ),
      _EmployeeMenuItem(
        title: 'My Attendance',
        subtitle: 'View personal attendance',
        icon: Icons.fact_check_outlined,
        page: MyAttendanceScreen(),
      ),
      _EmployeeMenuItem(
        title: 'My Leave',
        subtitle: 'View leave requests',
        icon: Icons.event_note_outlined,
        page: MyLeaveScreen(),
      ),
      _EmployeeMenuItem(
        title: 'Apply Leave',
        subtitle: 'Submit a new leave request',
        icon: Icons.event_available_outlined,
        page: ApplyLeaveScreen(),
      ),
      _EmployeeMenuItem(
        title: 'My Salary',
        subtitle: 'View salary and payslips',
        icon: Icons.payments_outlined,
        page: MySalaryScreen(),
      ),
      _EmployeeMenuItem(
        title: 'My Tasks',
        subtitle: 'View assigned work',
        icon: Icons.task_alt_rounded,
        page: MyTasksScreen(),
      ),
      _EmployeeMenuItem(
        title: 'My Performance',
        subtitle: 'View personal performance',
        icon: Icons.trending_up_rounded,
        page: MyPerformanceScreen(),
      ),
      _EmployeeMenuItem(
        title: 'AI Business Assistant',
        subtitle: 'Ask queries, leaves, policies & help',
        icon: Icons.smart_toy_outlined,
        page: EmployeeAiChatScreen(),
      ),
      _EmployeeMenuItem(
        title: 'My Profile',
        subtitle: 'Manage personal details',
        icon: Icons.person_outline_rounded,
        page: ProfileScreen(),
      ),
      _EmployeeMenuItem(
        title: 'Notifications',
        subtitle: 'View company updates',
        icon: Icons.notifications_outlined,
        page: EmployeeNotificationsScreen(),
      ),
      _EmployeeMenuItem(
        title: 'Settings',
        subtitle: 'Application preferences',
        icon: Icons.settings_outlined,
        page: SettingsScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<_EmployeeMenuItem> items = _menuItems();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool desktop = constraints.maxWidth >= 900;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.smart_toy_rounded),
            label: const Text(
              'AI Assistant',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmployeeAiChatScreen(),
                ),
              );
            },
          ),
          appBar: desktop
              ? null
              : AppBar(
                  title: const Text(
                    'Employee Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _isLoadingUser ? null : _loadCurrentEmployee,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    IconButton(
                      tooltip: 'Sign out',
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ],
                ),
          drawer: desktop
              ? null
              : Drawer(child: _buildSidebar(context, items, closeDrawer: true)),
          body: SafeArea(
            child: Row(
              children: [
                if (desktop)
                  SizedBox(width: 280, child: _buildSidebar(context, items)),
                Expanded(child: _buildMainContent(context, items)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    List<_EmployeeMenuItem> items, {
    bool closeDrawer = false,
  }) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF06114D), Color(0xFF1237B8), Color(0xFF1548E8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Text(
                      _employeeName.isEmpty
                          ? 'E'
                          : _employeeName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF1548E8),
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoadingUser
                              ? 'Loading employee...'
                              : _employeeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _employeeId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final _EmployeeMenuItem item = items[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      leading: Icon(item.icon, color: Colors.white),
                      title: Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onTap: () {
                        if (closeDrawer) {
                          Navigator.of(context).pop();
                        }

                        _openPage(context, item.page);
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.badge_outlined, color: Color(0xFF1548E8)),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _designation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _department,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    List<_EmployeeMenuItem> items,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool mobile = constraints.maxWidth < 650;

        final int columns = mobile
            ? 2
            : constraints.maxWidth < 1100
            ? 3
            : 4;

        return RefreshIndicator(
          onRefresh: _loadCurrentEmployee,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(mobile ? 16 : 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoadingUser)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: LinearProgressIndicator(),
                      ),
                    if (_loadError != null) _buildErrorCard(),
                    _buildWelcomeCard(context, mobile),
                    const SizedBox(height: 24),
                    _buildEmployeeInformationCard(context, mobile),
                    const SizedBox(height: 24),
                    _buildAttendanceSummary(context, mobile),
                    const SizedBox(height: 28),
                    const Text(
                      'Employee Services',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 15),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: mobile ? 1.05 : 1.35,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final _EmployeeMenuItem item = items[index];

                        return _buildMenuCard(context, item);
                      },
                    ),
                    const SizedBox(height: 28),
                    _buildAnnouncementCard(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE74C3C)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE74C3C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_loadError ?? 'Unable to load employee details.'),
          ),
          IconButton(
            onPressed: _loadCurrentEmployee,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, bool mobile) {
    final Widget textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, $_employeeName',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 7),
        const Text(
          'Employee Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage your attendance, leave, salary and assigned work.',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 22 : 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF07134F), Color(0xFF1749E5), Color(0xFF7556F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: mobile
          ? textContent
          : Row(
              children: [
                Expanded(child: textContent),
                const Icon(
                  Icons.work_outline_rounded,
                  color: Colors.white,
                  size: 70,
                ),
              ],
            ),
    );
  }

  Widget _buildEmployeeInformationCard(BuildContext context, bool mobile) {
    final List<Widget> details = [
      _informationItem(
        icon: Icons.badge_outlined,
        label: 'Employee ID',
        value: _employeeId,
      ),
      _informationItem(
        icon: Icons.business_outlined,
        label: 'Department',
        value: _department,
      ),
      _informationItem(
        icon: Icons.work_outline_rounded,
        label: 'Designation',
        value: _designation,
      ),
      _informationItem(
        icon: Icons.email_outlined,
        label: 'Email',
        value: _email.isEmpty ? 'Email unavailable' : _email,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: mobile
          ? Column(children: details)
          : Row(
              children: details.map((Widget item) {
                return Expanded(child: item);
              }).toList(),
            ),
    );
  }

  Widget _informationItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE8EEFF),
            child: Icon(icon, color: const Color(0xFF1548E8)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary(BuildContext context, bool mobile) {
    final List<Widget> cards = [
      _summaryCard(
        context,
        title: 'Today',
        value: 'Not marked',
        icon: Icons.schedule_rounded,
        color: Colors.orange,
      ),
      _summaryCard(
        context,
        title: 'Check In',
        value: '--:--',
        icon: Icons.login_rounded,
        color: Colors.blue,
      ),
      _summaryCard(
        context,
        title: 'Attendance',
        value: '--',
        icon: Icons.fact_check_outlined,
        color: Colors.deepPurple,
      ),
      _summaryCard(
        context,
        title: 'Leave Balance',
        value: '--',
        icon: Icons.event_available_outlined,
        color: Colors.green,
      ),
    ];

    return GridView.count(
      crossAxisCount: mobile ? 2 : 4,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: mobile ? 1.25 : 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.13),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, _EmployeeMenuItem item) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          _openPage(context, item.page);
        },
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  item.icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFFFF0D8),
            child: Icon(Icons.campaign_outlined, color: Colors.orange),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Announcement',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
                SizedBox(height: 6),
                Text(
                  'Important company updates and announcements will appear here.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeMenuItem {
  const _EmployeeMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
}
