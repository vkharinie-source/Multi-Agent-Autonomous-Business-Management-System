import 'package:flutter/material.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _reasonController = TextEditingController();

  String _leaveType = 'Casual Leave';
  DateTimeRange? _selectedRange;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDates() async {
    final DateTime now = DateTime.now();

    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (range == null) {
      return;
    }

    setState(() {
      _selectedRange = range;
    });
  }

  void _submitLeave() {
    final bool valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      return;
    }

    if (_selectedRange == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select the leave dates.')));

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leave request submitted successfully.')),
    );

    _reasonController.clear();

    setState(() {
      _selectedRange = null;
      _leaveType = 'Casual Leave';
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF5842F5);
    const Color bgField = Color(0xFFF8FAFD);
    const Color borderCol = Color(0xFFE4E7ED);

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
          'Apply Leave',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Leave Request',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF525D73),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _leaveType,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF475569)),
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Leave type',
                        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        filled: true,
                        fillColor: bgField,
                        prefixIcon: const Icon(Icons.calendar_month_outlined, color: primaryPurple, size: 22),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: borderCol),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: primaryPurple, width: 1.5),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Casual Leave',
                          child: Text('Casual Leave'),
                        ),
                        DropdownMenuItem(
                          value: 'Sick Leave',
                          child: Text('Sick Leave'),
                        ),
                        DropdownMenuItem(
                          value: 'Personal Leave',
                          child: Text('Personal Leave'),
                        ),
                        DropdownMenuItem(
                          value: 'Emergency Leave',
                          child: Text('Emergency Leave'),
                        ),
                      ],
                      onChanged: (String? value) {
                        if (value == null) return;
                        setState(() {
                          _leaveType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _selectDates,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Leave dates',
                          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          filled: true,
                          fillColor: bgField,
                          prefixIcon: const Icon(Icons.calendar_today_outlined, color: primaryPurple, size: 20),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: borderCol),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: primaryPurple, width: 1.5),
                          ),
                        ),
                        child: Text(
                          _selectedRange == null
                              ? 'Select start and end date'
                              : '${_selectedRange!.start.day}/${_selectedRange!.start.month}/${_selectedRange!.start.year} - ${_selectedRange!.end.day}/${_selectedRange!.end.month}/${_selectedRange!.end.year}',
                          style: TextStyle(
                            color: _selectedRange == null ? const Color(0xFF64748B) : const Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: _selectedRange == null ? FontWeight.normal : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 4,
                      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Reason',
                        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: bgField,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 50),
                          child: Icon(Icons.article_outlined, color: primaryPurple, size: 22),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: borderCol),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: primaryPurple, width: 1.5),
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null || value.trim().length < 5) {
                          return 'Enter a valid reason';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _submitLeave,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Submit Leave Request',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
