import 'package:flutter/material.dart';

class MySalaryScreen extends StatelessWidget {
  const MySalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> payslips = [
      {
        'month': 'July 2026',
        'amount': '₹38,500',
        'status': 'Paid',
        'date': 'Jul 31, 2026',
      },
      {
        'month': 'June 2026',
        'amount': '₹38,500',
        'status': 'Paid',
        'date': 'Jun 30, 2026',
      },
      {
        'month': 'May 2026',
        'amount': '₹37,800',
        'status': 'Paid',
        'date': 'May 31, 2026',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FC),
      body: SafeArea(
        child: Stack(
          children: [
            // Background glow decorations
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
                // Top Custom Header
                _buildHeader(context),

                // Main Content List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    children: [
                      // Featured Salary Hero Card
                      _buildSalaryHeroCard(),

                      const SizedBox(height: 22),

                      // Detailed Salary Breakdown Section
                      _buildBreakdownSection(),

                      const SizedBox(height: 24),

                      // Payslip History Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.history_edu_rounded,
                                color: Color(0xFF6C5CE7),
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Payslip History',
                                style: TextStyle(
                                  color: Color(0xFF201A3D),
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFEAFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '3 Months',
                              style: TextStyle(
                                color: Color(0xFF6C5CE7),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // History Cards
                      ...payslips.map(
                        (Map<String, String> payslip) =>
                            _buildPayslipCard(context, payslip),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            onPressed: () {
              Navigator.of(context).maybePop();
            },
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Salary',
                style: TextStyle(
                  color: Color(0xFF201A3D),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Earnings & Payslip Statements',
                style: TextStyle(color: Color(0xFF756E8A), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF21A366).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF21A366).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF21A366),
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'Active Payroll',
                  style: TextStyle(
                    color: Color(0xFF1E8654),
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

  Widget _buildSalaryHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle pattern circle
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Net Take-Home Pay',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'July 2026',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                '₹38,500',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              Divider(color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF55E6C1),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Disbursed & Credited to Bank Account',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF55E6C1).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '100% Paid',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEBE6F8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                color: Color(0xFF6C5CE7),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Salary Breakdown',
                style: TextStyle(
                  color: Color(0xFF201A3D),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBreakdownItem(
            title: 'Basic Salary',
            subtitle: 'Base component',
            value: '₹32,000',
            icon: Icons.payments_rounded,
            iconColor: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFEFF6FF),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFF0ECFA)),
          ),
          _buildBreakdownItem(
            title: 'Allowances',
            subtitle: 'HRA + Special allowances',
            value: '+₹8,500',
            valueColor: const Color(0xFF10B981),
            icon: Icons.add_chart_rounded,
            iconColor: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFF0ECFA)),
          ),
          _buildBreakdownItem(
            title: 'Deductions',
            subtitle: 'PF & Tax deductions',
            value: '-₹2,000',
            valueColor: const Color(0xFFEF4444),
            icon: Icons.remove_circle_outline_rounded,
            iconColor: const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEF2F2),
          ),
          const SizedBox(height: 16),

          // Total Highlight Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF3EEFF), Color(0xFFECE5FF)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCD2FA)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Payable Salary',
                  style: TextStyle(
                    color: Color(0xFF201A3D),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '₹38,500',
                  style: TextStyle(
                    color: Color(0xFF6C5CE7),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    Color valueColor = const Color(0xFF201A3D),
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF201A3D),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF8B849E), fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildPayslipCard(
    BuildContext context,
    Map<String, String> payslip,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBE6F8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4BB7).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF8E5BEF)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      payslip['month']!,
                      style: const TextStyle(
                        color: Color(0xFF201A3D),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        payslip['status']!,
                        style: const TextStyle(
                          color: Color(0xFF059669),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Credited on ${payslip['date']!}',
                  style: const TextStyle(
                    color: Color(0xFF8B849E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                payslip['amount']!,
                style: const TextStyle(
                  color: Color(0xFF201A3D),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Downloading ${payslip['month']} Payslip...',
                      ),
                      backgroundColor: const Color(0xFF6C5CE7),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.download_rounded,
                      color: Color(0xFF6C5CE7),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Payslip',
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
        ],
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

