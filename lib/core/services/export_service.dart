import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  ExportService._();

  /// Generate a high quality corporate PDF and prompt Download/Share/Save
  static Future<void> generateAndDownloadPdf({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<String> headers,
    required List<List<dynamic>> rows,
    Map<String, String>? summaryStats,
  }) async {
    try {
      final pw.Document pdf = pw.Document();
      final DateTime now = DateTime.now();
      final String timestamp =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context ctx) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 20),
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.blue800, width: 2),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'AUTONOMOUS BUSINESS AI',
                      style: pw.TextStyle(
                        color: PdfColors.blue900,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Enterprise Management & Analytics Report',
                      style: const pw.TextStyle(
                        color: PdfColors.grey700,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  'Date: $timestamp',
                  style: const pw.TextStyle(
                    color: PdfColors.grey700,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          footer: (pw.Context ctx) => pw.Container(
            margin: const pw.EdgeInsets.only(top: 20),
            padding: const pw.EdgeInsets.only(top: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated automatically by Autonomous Business AI System',
                  style: const pw.TextStyle(
                    color: PdfColors.grey600,
                    fontSize: 8,
                  ),
                ),
                pw.Text(
                  'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                  style: const pw.TextStyle(
                    color: PdfColors.grey600,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          build: (pw.Context ctx) => [
            // Report Header
            pw.Text(
              title,
              style: pw.TextStyle(
                color: PdfColors.blue900,
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                subtitle,
                style: const pw.TextStyle(
                  color: PdfColors.grey700,
                  fontSize: 11,
                ),
              ),
            ],
            pw.SizedBox(height: 16),

            // Summary Stats Cards if present
            if (summaryStats != null && summaryStats.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: summaryStats.entries.map((entry) {
                    return pw.Column(
                      children: [
                        pw.Text(
                          entry.key,
                          style: const pw.TextStyle(
                            color: PdfColors.grey700,
                            fontSize: 9,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          entry.value,
                          style: pw.TextStyle(
                            color: PdfColors.blue900,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              pw.SizedBox(height: 20),
            ],

            // Data Table
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: rows,
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue800,
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                ),
              ),
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.black,
              ),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      final sanitizedTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final fileName = '${sanitizedTitle}_Report.pdf';

      // Save to device file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Open natively or show share sheet
      await Printing.sharePdf(bytes: bytes, filename: fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $title PDF downloaded successfully!'),
            backgroundColor: const Color(0xff16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Generate formatted Excel/CSV and open/download directly on device
  static Future<void> generateAndDownloadExcel({
    required BuildContext context,
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    try {
      final StringBuffer csvBuffer = StringBuffer();

      // Write UTF-8 Byte Order Mark (BOM) so Excel opens UTF-8 properly
      csvBuffer.write('\uFEFF');

      // Title header row
      csvBuffer.writeln('"$title - Autonomous Business AI Report"');
      csvBuffer.writeln('"Exported on: ${DateTime.now().toLocal().toString().split('.')[0]}"');
      csvBuffer.writeln();

      // Headers row
      csvBuffer.writeln(headers.map((h) => '"${h.replaceAll('"', '""')}"').join(','));

      // Data rows
      for (final row in rows) {
        csvBuffer.writeln(
          row.map((cell) => '"${cell.toString().replaceAll('"', '""')}"').join(','),
        );
      }

      final sanitizedTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final fileName = '${sanitizedTitle}_Report.csv';

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csvBuffer.toString());

      // Open or share the Excel CSV file directly
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        // Fallback to share sheet if no direct default app is set
        await Share.shareXFiles(
          [XFile(file.path)],
          text: '$title Report (Excel Compatible)',
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $title Excel/CSV file downloaded successfully!'),
            backgroundColor: const Color(0xff16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export Excel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Print layout directly via System Print dialog
  static Future<void> printReport({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<String> headers,
    required List<List<dynamic>> rows,
    Map<String, String>? summaryStats,
  }) async {
    try {
      final pw.Document pdf = pw.Document();
      final DateTime now = DateTime.now();
      final String timestamp =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) => [
            pw.Text(
              title,
              style: pw.TextStyle(
                color: PdfColors.blue900,
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'Date: $timestamp | Autonomous Business AI',
              style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
            ),
            pw.SizedBox(height: 16),
            if (summaryStats != null) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: summaryStats.entries.map((entry) {
                    return pw.Column(
                      children: [
                        pw.Text(entry.key, style: const pw.TextStyle(fontSize: 8)),
                        pw.Text(
                          entry.value,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              pw.SizedBox(height: 16),
            ],
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: rows,
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                ),
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: '$title.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Official corporate salary payslip PDF generation & download
  static Future<void> generateAndDownloadPayslipPdf({
    required BuildContext context,
    required Map<String, dynamic> payslip,
    required String employeeName,
    String employeeId = 'EMP001',
    String designation = 'Employee',
    String department = 'Management',
  }) async {
    try {
      final pw.Document pdf = pw.Document();

      final month = payslip['month'] ?? 'Current Month';
      final basic = payslip['basic'] ?? '₹38,000';
      final hra = payslip['hra'] ?? '₹12,000';
      final allowances = payslip['allowances'] ?? '₹8,000';
      final gross = payslip['gross'] ?? '₹58,000';
      final pf = payslip['pf'] ?? '₹3,000';
      final tax = payslip['tax'] ?? '₹2,500';
      final deductions = payslip['deductions'] ?? '₹5,500';
      final net = payslip['net'] ?? payslip['amount'] ?? '₹52,500';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (pw.Context ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Company Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 16),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.blue800, width: 2),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'AUTONOMOUS BUSINESS AI',
                          style: pw.TextStyle(
                            color: PdfColors.blue900,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          '100 Innovation Boulevard, Tech City, India',
                          style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: PdfColors.blue200),
                      ),
                      child: pw.Text(
                        'PAYSLIP - $month',
                        style: pw.TextStyle(
                          color: PdfColors.blue900,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Employee Details Grid
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Employee Name: $employeeName',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text('Employee ID: $employeeId',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Designation: $designation',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text('Department: $department',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Earnings & Deductions Tables
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Earnings
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          color: PdfColors.blue800,
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('EARNINGS', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9)),
                              pw.Text('AMOUNT', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9)),
                            ],
                          ),
                        ),
                        _payslipRow('Basic Salary', basic.toString()),
                        _payslipRow('House Rent Allowance (HRA)', hra.toString()),
                        _payslipRow('Special Allowances', allowances.toString()),
                        pw.Divider(color: PdfColors.grey300),
                        _payslipRow('Gross Earnings', gross.toString(), isBold: true),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  // Deductions
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          color: PdfColors.red800,
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('DEDUCTIONS', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9)),
                              pw.Text('AMOUNT', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9)),
                            ],
                          ),
                        ),
                        _payslipRow('Provident Fund (PF)', pf.toString()),
                        _payslipRow('Professional Tax', tax.toString()),
                        _payslipRow('Other Deductions', '₹0'),
                        pw.Divider(color: PdfColors.grey300),
                        _payslipRow('Total Deductions', deductions.toString(), isBold: true),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Net Salary Card
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.green300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('NET TAKE-HOME SALARY', style: pw.TextStyle(color: PdfColors.green900, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.SizedBox(height: 2),
                        pw.Text('Transferred directly to registered bank account', style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 8)),
                      ],
                    ),
                    pw.Text(
                      net.toString(),
                      style: pw.TextStyle(color: PdfColors.green900, fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 120, height: 1, color: PdfColors.grey400),
                      pw.SizedBox(height: 4),
                      pw.Text('Employee Signature', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 120, height: 1, color: PdfColors.grey400),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized HR Manager', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      final bytes = await pdf.save();
      final fileName = 'Payslip_${month.toString().replaceAll(' ', '_')}.pdf';
      await Printing.sharePdf(bytes: bytes, filename: fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $month Payslip PDF downloaded successfully!'),
            backgroundColor: const Color(0xff16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download Payslip PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static pw.Widget _payslipRow(String title, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isBold ? PdfColors.black : PdfColors.grey800,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isBold ? PdfColors.black : PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }
}
