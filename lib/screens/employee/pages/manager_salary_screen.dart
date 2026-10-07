import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/services/secure_storage_service.dart';

// ---------------------------------------------------------------------------
// Manager Monthly Salary Details Screen
// Fetches data from GET /api/salary/monthly?month=YYYY-MM
// Uses the same backend calculation engine as the employee My Salary screen.
// ---------------------------------------------------------------------------

class ManagerSalaryScreen extends StatefulWidget {
  const ManagerSalaryScreen({super.key});

  @override
  State<ManagerSalaryScreen> createState() => _ManagerSalaryScreenState();
}

class _ManagerSalaryScreenState extends State<ManagerSalaryScreen> {
  static const double _mobileBreakpoint = 700;

  // --- month selector ---
  late int _selectedYear;
  late int _selectedMonth;

  // --- data ---
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;
  List<Map<String, dynamic>> _salaries = <Map<String, dynamic>>[];

  // --- expanded employee index for detail view ---
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _fetchSalaries();
  }

  // -------------------------------------------------------------------------
  // API
  // -------------------------------------------------------------------------

  Future<String?> _token() async =>
      SecureStorageService.instance.readAccessToken();

  Future<void> _fetchSalaries() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final String? token = await _token();
      final String monthStr =
          '${_selectedYear.toString().padLeft(4, '0')}-${_selectedMonth.toString().padLeft(2, '0')}';
      final uri = ApiConfig.uri(
        '${ApiConfig.salaryMonthlyEndpoint}?month=$monthStr',
      );
      final res = await http.get(
        uri,
        headers: <String, String>{
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 25));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode >= 400) {
        throw Exception(body['detail'] ?? 'Failed to load salary data');
      }

      final List<dynamic> list =
          body['salaries'] as List<dynamic>? ?? <dynamic>[];

      if (!mounted) return;
      setState(() {
        _data = body;
        _salaries = list
            .map((dynamic e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  String _formatCurrency(dynamic val) {
    if (val == null) return '₹0';
    final double v = (val is num) ? val.toDouble() : 0;
    if (v >= 100000) {
      return '₹${(v / 100000).toStringAsFixed(2)}L';
    }
    return '₹${v.toStringAsFixed(0)}';
  }

  String _monthName(int m) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[m];
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear--;
      }
      _expandedIndex = null;
    });
    _fetchSalaries();
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isMobile = constraints.maxWidth < _mobileBreakpoint;
          return Column(
            children: <Widget>[
              _buildHeader(isMobile),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildErrorView()
                        : SingleChildScrollView(
                            padding: EdgeInsets.all(isMobile ? 16 : 26),
                            child: Column(
                              children: <Widget>[
                                _buildMonthSelector(isMobile),
                                SizedBox(height: isMobile ? 16 : 22),
                                _buildSummaryCards(isMobile),
                                SizedBox(height: isMobile ? 16 : 22),
                                _buildSalaryTable(isMobile),
                              ],
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Header
  // -------------------------------------------------------------------------

  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xff020A3D),
            Color(0xff2563EB),
            Color(0xff9333EA),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 28,
            isMobile ? 16 : 22,
            isMobile ? 16 : 28,
            isMobile ? 22 : 32,
          ),
          child: Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Monthly Salary Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 20 : 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View salary breakdown for all employees',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isMobile ? 12 : 14,
                      ),
                      maxLines: isMobile ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.account_balance_wallet, color: Colors.white, size: 36),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Month selector
  // -------------------------------------------------------------------------

  Widget _buildMonthSelector(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: _cardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon:
                const Icon(Icons.chevron_left, color: Color(0xff2563EB)),
          ),
          Text(
            '${_monthName(_selectedMonth)} $_selectedYear',
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xff081A63),
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right,
                color: Color(0xff2563EB)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Summary cards
  // -------------------------------------------------------------------------

  Widget _buildSummaryCards(bool isMobile) {
    final int count = _data?['count'] as int? ?? _salaries.length;
    final dynamic totalPayroll = _data?['total_payroll'] ?? 0;
    final dynamic totalGross = _data?['total_gross'] ?? 0;
    final dynamic totalDeductions = _data?['total_deductions'] ?? 0;

    final cards = <Widget>[
      _summaryCard(
        'Employees',
        '$count',
        Icons.groups,
        const Color(0xff2563EB),
      ),
      _summaryCard(
        'Total Payroll',
        _formatCurrency(totalPayroll),
        Icons.account_balance_wallet,
        const Color(0xff10B981),
      ),
      _summaryCard(
        'Gross Total',
        _formatCurrency(totalGross),
        Icons.currency_rupee,
        const Color(0xff8B5CF6),
      ),
      _summaryCard(
        'Total Deductions',
        _formatCurrency(totalDeductions),
        Icons.remove_circle_outline,
        const Color(0xffEF4444),
      ),
    ];

    if (isMobile) {
      return SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, int i) => SizedBox(width: 190, child: cards[i]),
        ),
      );
    }

    return Row(
      children: <Widget>[
        for (int i = 0; i < cards.length; i++) ...<Widget>[
          if (i != 0) const SizedBox(width: 18),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withValues(alpha: 0.13),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff081A63),
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

  // -------------------------------------------------------------------------
  // Salary table
  // -------------------------------------------------------------------------

  Widget _buildSalaryTable(bool isMobile) {
    if (_salaries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: _cardDecoration(),
        child: const Center(
          child: Text(
            'No salary records found for this month.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Employee Salary Breakdown',
            style: TextStyle(
              fontSize: isMobile ? 19 : 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff081A63),
            ),
          ),
          const SizedBox(height: 18),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _salaries.length,
            itemBuilder: (BuildContext context, int index) {
              final s = _salaries[index];
              final bool isExpanded = _expandedIndex == index;
              return _buildEmployeeSalaryRow(s, index, isExpanded, isMobile);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeSalaryRow(
    Map<String, dynamic> s,
    int index,
    bool isExpanded,
    bool isMobile,
  ) {
    final String name = s['employee_name'] as String? ?? '—';
    final String empId = s['employee_id'] as String? ?? '—';
    final String dept = s['department'] as String? ?? '';
    final String designation = s['designation'] as String? ?? '';
    final double netSalary =
        (s['net_salary'] as num?)?.toDouble() ?? 0;
    final double grossSalary =
        (s['gross_salary'] as num?)?.toDouble() ?? 0;
    final double totalDeductions =
        (s['total_deductions'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isExpanded ? const Color(0xffEEF4FF) : const Color(0xffF8FAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              isExpanded ? const Color(0xff2563EB) : Colors.grey.shade200,
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: <Widget>[
          // --- main row ---
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xff2563EB),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xff081A63),
                                    ),
                                  ),
                                  Text(
                                    '$empId • $dept',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: const Color(0xff2563EB),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Net: ${_formatCurrency(netSalary)}',
                              style: const TextStyle(
                                color: Color(0xff10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Gross: ${_formatCurrency(grossSalary)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xff2563EB),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Color(0xff081A63),
                                ),
                              ),
                              Text(
                                '$empId • $dept • $designation',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Text(
                                _formatCurrency(grossSalary),
                                style: const TextStyle(
                                  color: Color(0xff081A63),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Text('Gross',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Text(
                                '-${_formatCurrency(totalDeductions)}',
                                style: const TextStyle(
                                  color: Color(0xffEF4444),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Text('Deductions',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Text(
                                _formatCurrency(netSalary),
                                style: const TextStyle(
                                  color: Color(0xff10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text('Net Pay',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xff2563EB),
                        ),
                      ],
                    ),
            ),
          ),

          // --- expanded detail ---
          if (isExpanded) _buildExpandedDetail(s, isMobile),
        ],
      ),
    );
  }

  Widget _buildExpandedDetail(Map<String, dynamic> s, bool isMobile) {
    final double basicSalary =
        (s['basic_salary'] as num?)?.toDouble() ?? 0;
    final double hra = (s['hra'] as num?)?.toDouble() ?? 0;
    final double specialAllowance =
        (s['special_allowance'] as num?)?.toDouble() ?? 0;
    final double pfDeduction =
        (s['pf_deduction'] as num?)?.toDouble() ?? 0;
    final double taxDeduction =
        (s['tax_deduction'] as num?)?.toDouble() ?? 0;
    final double lossOfPay =
        (s['loss_of_pay'] as num?)?.toDouble() ?? 0;
    final int workingDays =
        (s['working_days'] as num?)?.toInt() ?? 0;
    final int presentDays =
        (s['present_days'] as num?)?.toInt() ??
            (s['days_present'] as num?)?.toInt() ??
            0;
    final int absentDays =
        (s['absent_days'] as num?)?.toInt() ??
            (s['days_absent'] as num?)?.toInt() ??
            0;
    final int approvedLeave =
        (s['approved_leave_days'] as num?)?.toInt() ?? 0;
    final int lateDays =
        (s['late_days'] as num?)?.toInt() ?? 0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        0,
        isMobile ? 16 : 24,
        16,
      ),
      child: Column(
        children: <Widget>[
          const Divider(),
          const SizedBox(height: 8),

          // Attendance summary row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffF0F4FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: isMobile
                ? Column(
                    children: <Widget>[
                      _attendanceChip(
                          'Working', '$workingDays', const Color(0xff2563EB)),
                      const SizedBox(height: 8),
                      _attendanceChip(
                          'Present', '$presentDays', const Color(0xff10B981)),
                      const SizedBox(height: 8),
                      _attendanceChip(
                          'Absent', '$absentDays', const Color(0xffEF4444)),
                      const SizedBox(height: 8),
                      _attendanceChip(
                          'Leave', '$approvedLeave', const Color(0xff8B5CF6)),
                      const SizedBox(height: 8),
                      _attendanceChip(
                          'Late', '$lateDays', const Color(0xffF97316)),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _attendanceChip(
                          'Working Days', '$workingDays', const Color(0xff2563EB)),
                      _attendanceChip(
                          'Present', '$presentDays', const Color(0xff10B981)),
                      _attendanceChip(
                          'Absent', '$absentDays', const Color(0xffEF4444)),
                      _attendanceChip(
                          'Approved Leave', '$approvedLeave', const Color(0xff8B5CF6)),
                      _attendanceChip(
                          'Late', '$lateDays', const Color(0xffF97316)),
                    ],
                  ),
          ),

          const SizedBox(height: 14),

          // Earnings & Deductions
          isMobile
              ? Column(
                  children: <Widget>[
                    _breakdownSection('Earnings', <_BreakdownItem>[
                      _BreakdownItem('Basic Salary', basicSalary),
                      _BreakdownItem('HRA', hra),
                      _BreakdownItem('Special Allowance', specialAllowance),
                    ], const Color(0xff10B981)),
                    const SizedBox(height: 14),
                    _breakdownSection('Deductions', <_BreakdownItem>[
                      _BreakdownItem('PF Deduction', pfDeduction),
                      _BreakdownItem('Tax Deduction', taxDeduction),
                      _BreakdownItem('Loss of Pay', lossOfPay),
                    ], const Color(0xffEF4444)),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _breakdownSection('Earnings', <_BreakdownItem>[
                        _BreakdownItem('Basic Salary', basicSalary),
                        _BreakdownItem('HRA', hra),
                        _BreakdownItem('Special Allowance', specialAllowance),
                      ], const Color(0xff10B981)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _breakdownSection('Deductions', <_BreakdownItem>[
                        _BreakdownItem('PF Deduction', pfDeduction),
                        _BreakdownItem('Tax Deduction', taxDeduction),
                        _BreakdownItem('Loss of Pay', lossOfPay),
                      ], const Color(0xffEF4444)),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _attendanceChip(String label, String value, Color color) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }

  Widget _breakdownSection(
    String title,
    List<_BreakdownItem> items,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: accentColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    item.label,
                    style:
                        const TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                  Text(
                    _formatCurrency(item.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xff081A63),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Error view
  // -------------------------------------------------------------------------

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, color: Colors.red, size: 56),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563EB),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _fetchSalaries,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Shared decoration
  // -------------------------------------------------------------------------

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}

class _BreakdownItem {
  final String label;
  final double amount;
  const _BreakdownItem(this.label, this.amount);
}
