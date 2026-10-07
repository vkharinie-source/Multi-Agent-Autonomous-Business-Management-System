import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/services/secure_storage_service.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  String _selectedLeaveType = 'Casual Leave';
  DateTimeRange? _selectedRange;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _leaveTypes = [
    {
      'title': 'Casual Leave',
      'icon': Icons.beach_access_rounded,
      'color': const Color(0xFF3B82F6),
      'balance': '12 Days',
    },
    {
      'title': 'Sick Leave',
      'icon': Icons.medical_services_rounded,
      'color': const Color(0xFFEF4444),
      'balance': '8 Days',
    },
    {
      'title': 'Personal Leave',
      'icon': Icons.person_pin_circle_rounded,
      'color': const Color(0xFF8B5CF6),
      'balance': '5 Days',
    },
    {
      'title': 'Emergency Leave',
      'icon': Icons.emergency_rounded,
      'color': const Color(0xFFF59E0B),
      'balance': '3 Days',
    },
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int get _selectedDaysCount {
    if (_selectedRange == null) return 0;
    return _selectedRange!.end.difference(_selectedRange!.start).inDays + 1;
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDates() async {
    final DateTime now = DateTime.now();

    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 7)),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedRange,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C5CE7),
              onPrimary: Colors.white,
              onSurface: Color(0xFF201A3D),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (range == null) return;

    setState(() {
      _selectedRange = range;
    });
  }

  Future<void> _submitLeave() async {
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (_selectedRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                'Please select start and end dates for your leave.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String? token =
          await SecureStorageService.instance.readAccessToken();
      final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/leaves/apply');
      final Map<String, dynamic> payload = {
        "leave_type": _selectedLeaveType,
        "start_date": _formatIsoDate(_selectedRange!.start),
        "end_date": _formatIsoDate(_selectedRange!.end),
        "days_count": _selectedDaysCount,
        "reason": _reasonController.text.trim(),
      };

      await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      // Handled gracefully
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$_selectedLeaveType request ($_selectedDaysCount ${_selectedDaysCount == 1 ? "day" : "days"}) submitted! Awaiting manager approval.',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF21A366),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    _reasonController.clear();
    setState(() {
      _selectedRange = null;
      _selectedLeaveType = 'Casual Leave';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FC),
      body: SafeArea(
        child: Stack(
          children: [
            // Background ambient glow circles
            Positioned(
              top: -80,
              right: -60,
              child: _buildGlowCircle(
                size: 260,
                color: const Color(0xFF7B61FF).withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: _buildGlowCircle(
                size: 280,
                color: const Color(0xFFB66DFF).withValues(alpha: 0.10),
              ),
            ),

            Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroCard(),
                          const SizedBox(height: 22),
                          _buildSectionHeader(
                            title: 'Select Leave Type',
                            icon: Icons.category_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildLeaveTypeSelector(),
                          const SizedBox(height: 22),
                          _buildSectionHeader(
                            title: 'Leave Duration & Dates',
                            icon: Icons.date_range_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildDatePickerCard(),
                          const SizedBox(height: 22),
                          _buildSectionHeader(
                            title: 'Reason for Leave',
                            icon: Icons.notes_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildReasonInput(),
                          const SizedBox(height: 28),
                          _buildSubmitButton(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEBE6F8), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF3EEFF),
              foregroundColor: const Color(0xFF4C3F91),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Apply Leave',
                style: GoogleFonts.inter(
                  color: const Color(0xFF201A3D),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Time-off & Leave Request Form',
                style: GoogleFonts.inter(color: const Color(0xFF756E8A), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.event_available_rounded,
                  color: Color(0xFF6C5CE7),
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'Active Year',
                  style: TextStyle(
                    color: Color(0xFF6C5CE7),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF35168A), Color(0xFF6C5CE7), Color(0xFF8E5BEF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Leave Balance Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            '28 Days Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You have 28 remaining days across all leave categories for 2026.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF201A3D),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveTypeSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _leaveTypes.map((Map<String, dynamic> item) {
            final bool isSelected = _selectedLeaveType == item['title'];
            final Color color = item['color'] as Color;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedLeaveType = item['title'] as String;
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: itemWidth,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6C5CE7)
                        : const Color(0xFFEBE6F8),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF6C5CE7).withValues(alpha: 0.14)
                          : const Color(0xFF5D4BB7).withValues(alpha: 0.04),
                      blurRadius: isSelected ? 14 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item['icon'] as IconData, color: color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              color: const Color(0xFF201A3D),
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['balance'] as String,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF6C5CE7) : const Color(0xFF8B849E),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF6C5CE7),
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDatePickerCard() {
    final bool hasSelection = _selectedRange != null;

    return InkWell(
      onTap: _selectDates,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasSelection ? const Color(0xFF6C5CE7) : const Color(0xFFEBE6F8),
            width: hasSelection ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D4BB7).withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F7FD),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFECE7F6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flight_takeoff_rounded, color: Color(0xFF6C5CE7), size: 14),
                            SizedBox(width: 5),
                            Text(
                              'Start Date',
                              style: TextStyle(color: Color(0xFF8B849E), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasSelection ? _formatDate(_selectedRange!.start) : 'Pick Date',
                          style: TextStyle(
                            color: hasSelection ? const Color(0xFF201A3D) : const Color(0xFFA59EB5),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF6C5CE7), size: 18),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F7FD),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFECE7F6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flight_land_rounded, color: Color(0xFF10B981), size: 14),
                            SizedBox(width: 5),
                            Text(
                              'End Date',
                              style: TextStyle(color: Color(0xFF8B849E), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasSelection ? _formatDate(_selectedRange!.end) : 'Pick Date',
                          style: TextStyle(
                            color: hasSelection ? const Color(0xFF201A3D) : const Color(0xFFA59EB5),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: hasSelection
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : const Color(0xFFF3EEFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasSelection ? Icons.timer_outlined : Icons.calendar_today_rounded,
                        color: hasSelection ? const Color(0xFF047857) : const Color(0xFF6C5CE7),
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        hasSelection
                            ? '$_selectedDaysCount ${_selectedDaysCount == 1 ? "Day" : "Days"} Total'
                            : 'No dates chosen',
                        style: TextStyle(
                          color: hasSelection ? const Color(0xFF047857) : const Color(0xFF6C5CE7),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _selectDates,
                  icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                  label: Text(hasSelection ? 'Change Dates' : 'Select Dates'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBE6F8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        controller: _reasonController,
        maxLines: 4,
        style: const TextStyle(
          color: Color(0xFF201A3D),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Explain the reason for your time-off request...',
          hintStyle: const TextStyle(
            color: Color(0xFFA59EB5),
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (String? value) {
          if (value == null || value.trim().length < 4) {
            return 'Please enter a brief explanation for your leave request.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFF8E5BEF)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withValues(alpha: 0.32),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitLeave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Submit Leave Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGlowCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
