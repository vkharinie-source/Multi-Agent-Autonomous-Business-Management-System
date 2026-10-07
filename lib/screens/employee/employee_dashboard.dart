import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      return 'EMP-001';
    }
    return employeeId;
  }

  String get _department {
    final String department = _employee['department']?.toString().trim() ?? '';
    if (department.isEmpty) {
      return 'General Department';
    }
    return department;
  }

  String get _designation {
    final String designation =
        _employee['designation']?.toString().trim() ?? '';
    if (designation.isEmpty) {
      return 'Team Member';
    }
    return designation;
  }

  String get _email {
    final String email = _employee['email']?.toString().trim() ?? '';
    return email.isEmpty ? 'employee@company.com' : email;
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
              ),
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
      (Route<dynamic> route) => false,
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => page,
      ),
    );
  }

  List<_EmployeeMenuItem> _menuItems() {
    return const [
      _EmployeeMenuItem(
        title: 'Scan Attendance QR',
        subtitle: 'Check in with live QR scanner',
        icon: Icons.qr_code_scanner_rounded,
        color: Color(0xFF2563EB),
        page: ScanAttendanceScreen(),
      ),
      _EmployeeMenuItem(
        title: 'Attendance Device',
        subtitle: 'Device approval & identity',
        icon: Icons.phonelink_lock_rounded,
        color: Color(0xFF7C3AED),
        page: DeviceRegistrationScreen(),
      ),
      _EmployeeMenuItem(
        title: 'My Attendance',
        subtitle: 'Logs, history & statistics',
        icon: Icons.fact_check_rounded,
        color: Color(0xFF059669),
        page: MyAttendanceScreen(),
      ),
      _EmployeeMenuItem(
        title: 'My Leave',
        subtitle: 'Track leave status & history',
        icon: Icons.event_note_rounded,
        color: Color(0xFFD97706),
        page: MyLeaveScreen(),
      ),
      _EmployeeMenuItem(
        title: 'Apply Leave',
        subtitle: 'Request time-off with AI advice',
        icon: Icons.event_available_rounded,
        color: Color(0xFF0284C7),
        page: ApplyLeaveScreen(),
      ),
      _EmployeeMenuItem(
        title: 'My Salary',
        subtitle: 'View payslips & salary details',
        icon: Icons.payments_rounded,
        color: Color(0xFF10B981),
        page: MySalaryScreen(),
      ),
      _EmployeeMenuItem(
        title: 'My Tasks',
        subtitle: 'Assigned workflow & targets',
        icon: Icons.task_alt_rounded,
        color: Color(0xFF8B5CF6),
        page: MyTasksScreen(),
      ),
      _EmployeeMenuItem(
        title: 'My Performance',
        subtitle: 'KPI score & growth analysis',
        icon: Icons.trending_up_rounded,
        color: Color(0xFFEC4899),
        page: MyPerformanceScreen(),
      ),
      _EmployeeMenuItem(
        title: 'AI Business Assistant',
        subtitle: 'Ask queries, leaves & policies',
        icon: Icons.smart_toy_rounded,
        color: Color(0xFF6366F1),
        page: EmployeeAiChatScreen(),
      ),
      _EmployeeMenuItem(
        title: 'My Profile',
        subtitle: 'Manage personal & contact info',
        icon: Icons.person_rounded,
        color: Color(0xFF3B82F6),
        page: ProfileScreen(),
      ),
      _EmployeeMenuItem(
        title: 'Notifications',
        subtitle: 'Updates & company broadcasts',
        icon: Icons.notifications_active_rounded,
        color: Color(0xFFF59E0B),
        page: EmployeeNotificationsScreen(),
      ),
      _EmployeeMenuItem(
        title: 'Settings',
        subtitle: 'Security & system preferences',
        icon: Icons.settings_rounded,
        color: Color(0xFF64748B),
        page: SettingsScreen(),
      ),
    ];
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xff081A63).withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_EmployeeMenuItem> items = _menuItems();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool desktop = constraints.maxWidth >= 960;

        return Scaffold(
          backgroundColor: const Color(0xffF4F7FE),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              elevation: 0,
              icon: const Icon(Icons.smart_toy_rounded, size: 22),
              label: Text(
                'AI Assistant',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: () {
                _openPage(context, const EmployeeAiChatScreen());
              },
            ),
          ),
          appBar: desktop
              ? null
              : AppBar(
                  elevation: 0,
                  backgroundColor: const Color(0xff081A63),
                  surfaceTintColor: Colors.transparent,
                  title: Text(
                    'Employee Dashboard',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _isLoadingUser ? null : _loadCurrentEmployee,
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    ),
                    IconButton(
                      tooltip: 'Sign out',
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFFF87171)),
                    ),
                    const SizedBox(width: 8),
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
          colors: [Color(0xFF130D36), Color(0xFF1E1452), Color(0xFF2E1C74)],
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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C69FF).withValues(alpha: 0.45),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFF7C69FF),
                      child: Text(
                        _employeeName.isEmpty
                            ? 'E'
                            : _employeeName.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoadingUser
                              ? 'Loading...'
                              : _employeeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _employeeId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final _EmployeeMenuItem item = items[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        item.title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.badge_rounded, color: Color(0xff2563EB), size: 20),
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
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          _department,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
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
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text('Sign Out', style: GoogleFonts.inter()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
        final bool mobile = constraints.maxWidth < 700;
        final bool tablet = constraints.maxWidth >= 700 && constraints.maxWidth < 1100;

        final int serviceColumns = mobile
            ? 2
            : tablet
                ? 3
                : 4;

        return RefreshIndicator(
          onRefresh: _loadCurrentEmployee,
          color: const Color(0xff2563EB),
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
                        child: LinearProgressIndicator(
                          backgroundColor: Color(0xFFE2E8F0),
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    if (_loadError != null) _buildErrorCard(),
                    _buildWelcomeHero(context, mobile),
                    SizedBox(height: mobile ? 18 : 24),
                    _buildEmployeeQuickInfo(context, mobile),
                    SizedBox(height: mobile ? 18 : 24),
                    _buildAttendanceOverviewMetrics(context, mobile),
                    SizedBox(height: mobile ? 18 : 24),
                    _buildAiInsightsSection(mobile),
                    SizedBox(height: mobile ? 22 : 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Employee Services',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff081A63),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xff2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${items.length} Services',
                            style: GoogleFonts.inter(
                              color: const Color(0xff2563EB),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: serviceColumns,
                        crossAxisSpacing: mobile ? 12 : 18,
                        mainAxisSpacing: mobile ? 12 : 18,
                        childAspectRatio: mobile ? 1.05 : 1.35,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final _EmployeeMenuItem item = items[index];
                        return _buildServiceCard(context, item, mobile);
                      },
                    ),
                    SizedBox(height: mobile ? 22 : 28),
                    _buildAnnouncementCard(context),
                    const SizedBox(height: 40),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE74C3C).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE74C3C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _loadError ?? 'Unable to load employee details.',
              style: GoogleFonts.inter(color: const Color(0xFF991B1B)),
            ),
          ),
          IconButton(
            onPressed: _loadCurrentEmployee,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF991B1B)),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHero(BuildContext context, bool mobile) {
    return Container(
      padding: EdgeInsets.all(mobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF130D36), Color(0xFF1E1452), Color(0xFF2E1C74)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1452).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C69FF).withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: mobile ? 26 : 34,
              backgroundColor: const Color(0xFF7C69FF),
              child: Text(
                _employeeName.isEmpty
                    ? 'E'
                    : _employeeName.substring(0, 1).toUpperCase(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: mobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: mobile ? 14 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, color: Colors.white, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            _designation,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Welcome back, $_employeeName 👋',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: mobile ? 20 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your attendance, tasks, leaves & work records effortlessly.',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: mobile ? 12 : 14,
                  ),
                  maxLines: mobile ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!mobile) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmployeeQuickInfo(BuildContext context, bool mobile) {
    final List<_QuickInfoData> infoList = [
      _QuickInfoData(
        icon: Icons.badge_rounded,
        label: 'Employee ID',
        value: _employeeId,
        color: const Color(0xFF2563EB),
      ),
      _QuickInfoData(
        icon: Icons.corporate_fare_rounded,
        label: 'Department',
        value: _department,
        color: const Color(0xFF7C3AED),
      ),
      _QuickInfoData(
        icon: Icons.work_rounded,
        label: 'Designation',
        value: _designation,
        color: const Color(0xFF059669),
      ),
      _QuickInfoData(
        icon: Icons.alternate_email_rounded,
        label: 'Email',
        value: _email,
        color: const Color(0xFFD97706),
      ),
    ];

    if (mobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            for (int i = 0; i < infoList.length; i++) ...[
              if (i != 0) const Divider(height: 16, color: Color(0xFFF1F5F9)),
              _buildSingleInfoRow(infoList[i]),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: _cardDecoration(),
      child: Row(
        children: infoList.map((info) {
          return Expanded(child: _buildSingleInfoRow(info));
        }).toList(),
      ),
    );
  }

  Widget _buildSingleInfoRow(_QuickInfoData info) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: info.color.withValues(alpha: 0.12),
            child: Icon(info.icon, color: info.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info.label,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  info.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xff081A63),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceOverviewMetrics(BuildContext context, bool mobile) {
    final metrics = [
      _EmployeeMetricData(
        title: 'Work Shift',
        value: '09:00 - 18:00',
        badge: 'General',
        icon: Icons.schedule_rounded,
        color: const Color(0xFF2563EB),
      ),
      _EmployeeMetricData(
        title: 'Attendance',
        value: 'Present',
        badge: 'On Track',
        icon: Icons.verified_user_rounded,
        color: const Color(0xFF10B981),
      ),
      _EmployeeMetricData(
        title: 'Leave Balance',
        value: '14 Days',
        badge: 'Available',
        icon: Icons.event_available_rounded,
        color: const Color(0xFF8B5CF6),
      ),
      _EmployeeMetricData(
        title: 'Active Tasks',
        value: '4 Pending',
        badge: 'In Progress',
        icon: Icons.task_alt_rounded,
        color: const Color(0xFFF59E0B),
      ),
    ];

    if (mobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: metrics.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
        ),
        itemBuilder: (context, index) {
          final m = metrics[index];
          return _buildMetricCardContent(m.title, m.value, m.badge, m.icon, m.color, true);
        },
      );
    }

    return Row(
      children: [
        for (int i = 0; i < metrics.length; i++) ...[
          if (i != 0) const SizedBox(width: 16),
          Expanded(
            child: _buildMetricCardContent(
              metrics[i].title,
              metrics[i].value,
              metrics[i].badge,
              metrics[i].icon,
              metrics[i].color,
              false,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricCardContent(
    String title,
    String value,
    String badge,
    IconData icon,
    Color color,
    bool mobile,
  ) {
    return Container(
      padding: EdgeInsets.all(mobile ? 12 : 18),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: mobile ? 20 : 24,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: mobile ? 20 : 24),
          ),
          SizedBox(width: mobile ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: mobile ? 14 : 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff081A63),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge,
                  style: GoogleFonts.inter(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightsSection(bool mobile) {
    final aiInsights = [
      _AiInsight(
        title: 'Attendance Agent',
        text: 'Your check-in records are consistent this month. 100% on-time rate.',
        icon: Icons.access_time_filled_rounded,
        color: const Color(0xFF10B981),
      ),
      _AiInsight(
        title: 'Task Assistant',
        text: 'You have 2 prioritized tasks due before the weekend. Tap tasks to review.',
        icon: Icons.assignment_turned_in_rounded,
        color: const Color(0xFF2563EB),
      ),
      _AiInsight(
        title: 'Leave & Wellness AI',
        text: 'Upcoming holiday on Friday. You can apply for a long weekend off with 1 click.',
        icon: Icons.beach_access_rounded,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    if (mobile) {
      return Column(
        children: [
          for (int i = 0; i < aiInsights.length; i++) ...[
            if (i != 0) const SizedBox(height: 12),
            _buildAiInsightCard(aiInsights[i]),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < aiInsights.length; i++) ...[
          if (i != 0) const SizedBox(width: 16),
          Expanded(child: _buildAiInsightCard(aiInsights[i])),
        ],
      ],
    );
  }

  Widget _buildAiInsightCard(_AiInsight item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item.color.withValues(alpha: 0.10), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: item.color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: item.color.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: item.color,
            child: Icon(item.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff081A63),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.text,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF475569),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, _EmployeeMenuItem item, bool mobile) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _openPage(context, item.page),
        child: Container(
          padding: EdgeInsets.all(mobile ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff081A63).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: mobile ? 22 : 26,
                backgroundColor: item.color.withValues(alpha: 0.12),
                child: Icon(item.icon, color: item.color, size: mobile ? 22 : 26),
              ),
              SizedBox(height: mobile ? 8 : 10),
              Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: mobile ? 12 : 14,
                  color: const Color(0xff081A63),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 10,
                  height: 1.2,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFFEF3C7),
            child: Icon(Icons.campaign_rounded, color: Color(0xFFD97706)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Announcement',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: const Color(0xff081A63),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome to the Autonomous Business AI platform. All attendance, leave applications, and HR requests are actively processed in real-time.',
                  style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 13, height: 1.4),
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
    required this.color,
    required this.page,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;
}

class _QuickInfoData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickInfoData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _EmployeeMetricData {
  final String title;
  final String value;
  final String badge;
  final IconData icon;
  final Color color;

  const _EmployeeMetricData({
    required this.title,
    required this.value,
    required this.badge,
    required this.icon,
    required this.color,
  });
}

class _AiInsight {
  final String title;
  final String text;
  final IconData icon;
  final Color color;

  const _AiInsight({
    required this.title,
    required this.text,
    required this.icon,
    required this.color,
  });
}
