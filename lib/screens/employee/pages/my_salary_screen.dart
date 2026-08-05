import 'package:flutter/material.dart';

class MySalaryScreen extends StatelessWidget {
  const MySalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> payslips = [
      {'month': 'July 2026', 'amount': '₹38,500', 'status': 'Paid'},
      {'month': 'June 2026', 'amount': '₹38,500', 'status': 'Paid'},
      {'month': 'May 2026', 'amount': '₹37,800', 'status': 'Paid'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Salary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(23),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF073B68), Color(0xFF0E83A8)],
              ),
              borderRadius: BorderRadius.circular(23),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Net Salary', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 7),
                Text(
                  '₹38,500',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text('July 2026', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 21),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  _SalaryRow(title: 'Basic Salary', value: '₹32,000'),
                  Divider(),
                  _SalaryRow(title: 'Allowances', value: '₹8,500'),
                  Divider(),
                  _SalaryRow(title: 'Deductions', value: '-₹2,000'),
                  Divider(),
                  _SalaryRow(title: 'Net Salary', value: '₹38,500', bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Payslip History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 11),
          ...payslips.map((Map<String, String> payslip) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.receipt_long_outlined),
                ),
                title: Text(
                  payslip['month']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(payslip['status']!),
                trailing: Text(
                  payslip['amount']!,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SalaryRow extends StatelessWidget {
  const _SalaryRow({
    required this.title,
    required this.value,
    this.bold = false,
  });

  final String title;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
