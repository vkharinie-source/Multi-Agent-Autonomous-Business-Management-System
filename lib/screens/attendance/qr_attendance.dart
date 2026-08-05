import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';

class QRAttendanceScreen extends StatefulWidget {
  const QRAttendanceScreen({super.key});

  @override
  State<QRAttendanceScreen> createState() => _QRAttendanceScreenState();
}

class _QRAttendanceScreenState extends State<QRAttendanceScreen> {
  bool qrGenerated = false;

  static const double _mobileBreakpoint = 700;

  final List<Map<String, String>> scannedEmployees = [
    {
      "id": "EMP001",
      "name": "Harinie V K",
      "time": "09:02 AM",
      "status": "Present",
    },
    {
      "id": "EMP002",
      "name": "Priya S",
      "time": "09:10 AM",
      "status": "Present",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < _mobileBreakpoint;

          return Column(
            children: [
              header(isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 26),
                  child: Column(
                    children: [
                      isMobile
                          ? Column(
                              children: [
                                qrCard(isMobile),
                                const SizedBox(height: 24),
                                instructionCard(isMobile),
                              ],
                            )
                          : IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  qrCard(isMobile),
                                  const SizedBox(width: 24),
                                  instructionCard(isMobile),
                                ],
                              ),
                            ),
                      SizedBox(height: isMobile ? 18 : 26),
                      scannedList(isMobile),
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

  Widget header(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 28,
        isMobile ? 20 : 30,
        isMobile ? 16 : 28,
        isMobile ? 24 : 34,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff020A3D), Color(0xff2563EB), Color(0xff9333EA)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          SizedBox(width: isMobile ? 6 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "QR Attendance",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 22 : 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Generate QR code and mark employee attendance",
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
          if (!isMobile) ...[
            const Spacer(),
            const Icon(Icons.qr_code_scanner, color: Colors.white, size: 42),
          ] else
            const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
        ],
      ),
    );
  }

  Widget qrCard(bool isMobile) {
    final content = Container(
      height: isMobile ? null : 420,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: card(),
      child: Column(
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Text(
            "Today's Attendance QR",
            style: TextStyle(
              fontSize: isMobile ? 19 : 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff081A63),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: isMobile ? 180 : 210,
            width: isMobile ? 180 : 210,
            decoration: BoxDecoration(
              color: qrGenerated ? Colors.white : const Color(0xffEEF4FF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xff2563EB), width: 2),
            ),
            child: qrGenerated
                ? QrImageView(
                    data:
                        "EMP_ATTENDANCE_${DateTime.now().millisecondsSinceEpoch}",
                    version: QrVersions.auto,
                    size: isMobile ? 150 : 180,
                    backgroundColor: Colors.white,
                  )
                : Icon(
                    Icons.qr_code,
                    size: isMobile ? 100 : 120,
                    color: const Color(0xff2563EB),
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            qrGenerated
                ? "QR Code Active • Valid until 10:00 AM"
                : "Click below to generate today's QR code",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: qrGenerated ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 24 : 0),
          if (!isMobile) const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              setState(() {
                qrGenerated = true;
              });
            },
            icon: const Icon(Icons.qr_code_2),
            label: Text(qrGenerated ? "Regenerate QR" : "Generate QR"),
          ),
        ],
      ),
    );

    return isMobile ? content : Expanded(child: content);
  }

  Widget instructionCard(bool isMobile) {
    final content = Container(
      height: isMobile ? null : 420,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: card(),
      child: Column(
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How QR Attendance Works",
            style: TextStyle(
              fontSize: isMobile ? 19 : 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff081A63),
            ),
          ),
          const SizedBox(height: 22),
          step(Icons.qr_code_2, "Admin generates daily QR code."),
          step(Icons.phone_android, "Employee scans the QR using mobile."),
          step(Icons.check_circle, "Attendance is marked automatically."),
          step(Icons.block, "Duplicate scan is prevented."),
          SizedBox(height: isMobile ? 8 : 0),
          if (!isMobile) const Spacer(),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xffEEF4FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Color(0xff2563EB)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Future backend integration can validate employee ID, location, and scan time.",
                    style: TextStyle(
                      color: Color(0xff081A63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return isMobile ? content : Expanded(child: content);
  }

  Widget step(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xff2563EB).withValues(alpha: 0.12),
            child: Icon(icon, color: const Color(0xff2563EB)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget scannedList(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Scanned Employees",
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
            itemCount: scannedEmployees.length,
            itemBuilder: (context, index) {
              final emp = scannedEmployees[index];

              final statusChip = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  emp["status"]!,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffF8FAFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xffDCFCE7),
                                child: Icon(Icons.check, color: Colors.green),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  emp["name"]!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              statusChip,
                            ],
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 54),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    emp["id"]!,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    emp["time"]!,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xffDCFCE7),
                            child: Icon(Icons.check, color: Colors.green),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              emp["id"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(flex: 2, child: Text(emp["name"]!)),
                          Expanded(child: Text(emp["time"]!)),
                          statusChip,
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  BoxDecoration card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
