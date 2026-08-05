import 'package:flutter/material.dart';

class ScanAttendanceScreen extends StatefulWidget {
  const ScanAttendanceScreen({super.key});

  @override
  State<ScanAttendanceScreen> createState() => _ScanAttendanceScreenState();
}

class _ScanAttendanceScreenState extends State<ScanAttendanceScreen> {
  final TextEditingController _qrTokenController = TextEditingController();

  bool _isSubmitting = false;
  bool _attendanceRecorded = false;

  @override
  void dispose() {
    _qrTokenController.dispose();
    super.dispose();
  }

  Future<void> _recordAttendance() async {
    final String qrToken = _qrTokenController.text.trim();

    if (qrToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan or enter the attendance QR token.'),
        ),
      );

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Temporary development delay.
      // Backend attendance API will be connected later.
      await Future<void>.delayed(const Duration(seconds: 1));

      if (!mounted) {
        return;
      }

      setState(() {
        _attendanceRecorded = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Attendance recorded successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Unable to record attendance: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Scan Attendance QR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 110,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Scan the attendance QR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan the QR code displayed by your Admin or Manager.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _qrTokenController,
                        enabled: !_isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Attendance QR token',
                          hintText: 'Enter QR token for testing',
                          prefixIcon: Icon(Icons.qr_code_rounded),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _isSubmitting ? null : _recordAttendance,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            _isSubmitting
                                ? 'Recording...'
                                : 'Record Attendance',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_attendanceRecorded) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.30),
                      ),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFFDFF7E5),
                          child: Icon(Icons.check_rounded, color: Colors.green),
                        ),
                        SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attendance Recorded',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              SizedBox(height: 3),
                              Text('Your attendance check-in was successful.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
