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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Apply Leave',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Leave Request',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        initialValue: _leaveType,
                        decoration: const InputDecoration(
                          labelText: 'Leave type',
                          prefixIcon: Icon(Icons.event_note_outlined),
                          border: OutlineInputBorder(),
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
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _leaveType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 17),
                      InkWell(
                        onTap: _selectDates,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Leave dates',
                            prefixIcon: Icon(Icons.date_range_outlined),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _selectedRange == null
                                ? 'Select start and end date'
                                : '${_selectedRange!.start.day}/${_selectedRange!.start.month}/${_selectedRange!.start.year} - ${_selectedRange!.end.day}/${_selectedRange!.end.month}/${_selectedRange!.end.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Reason',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.description_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().length < 5) {
                            return 'Enter a valid reason';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _submitLeave,
                          icon: const Icon(Icons.send_outlined),
                          label: const Text('Submit Leave Request'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
