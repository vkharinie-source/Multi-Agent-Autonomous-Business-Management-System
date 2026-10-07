import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum FinanceTransactionType { income, expense }

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  static const double _monthlyBudget = 100000;
  static const double _openingBalance = 97000;

  final List<_FinanceTransaction> _transactions = [
    _FinanceTransaction(
      title: 'Product sales',
      category: 'Sales',
      amount: 85000,
      type: FinanceTransactionType.income,
      date: DateTime(2026, 7, 26),
    ),
    _FinanceTransaction(
      title: 'Client payment',
      category: 'Services',
      amount: 60000,
      type: FinanceTransactionType.income,
      date: DateTime(2026, 7, 25),
    ),
    _FinanceTransaction(
      title: 'Office rent',
      category: 'Rent',
      amount: 25000,
      type: FinanceTransactionType.expense,
      date: DateTime(2026, 7, 24),
    ),
    _FinanceTransaction(
      title: 'Employee salaries',
      category: 'Salary',
      amount: 30000,
      type: FinanceTransactionType.expense,
      date: DateTime(2026, 7, 23),
    ),
    _FinanceTransaction(
      title: 'Software subscription',
      category: 'Technology',
      amount: 7500,
      type: FinanceTransactionType.expense,
      date: DateTime(2026, 7, 22),
    ),
    _FinanceTransaction(
      title: 'Consulting income',
      category: 'Services',
      amount: 40000,
      type: FinanceTransactionType.income,
      date: DateTime(2026, 7, 21),
    ),
    _FinanceTransaction(
      title: 'Marketing campaign',
      category: 'Marketing',
      amount: 5000,
      type: FinanceTransactionType.expense,
      date: DateTime(2026, 7, 20),
    ),
  ];

  double get _totalIncome {
    return _transactions
        .where(
          (transaction) => transaction.type == FinanceTransactionType.income,
        )
        .fold(0, (total, transaction) => total + transaction.amount);
  }

  double get _totalExpense {
    return _transactions
        .where(
          (transaction) => transaction.type == FinanceTransactionType.expense,
        )
        .fold(0, (total, transaction) => total + transaction.amount);
  }

  double get _netProfit {
    return _totalIncome - _totalExpense;
  }

  double get _currentBalance {
    return _openingBalance + _netProfit;
  }

  Map<String, double> get _expenseCategories {
    final Map<String, double> categories = {};

    for (final transaction in _transactions) {
      if (transaction.type == FinanceTransactionType.expense) {
        categories.update(
          transaction.category,
          (currentAmount) => currentAmount + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return categories;
  }

  Future<void> _showAddTransactionDialog() async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController titleController = TextEditingController();

    final TextEditingController amountController = TextEditingController();

    FinanceTransactionType selectedType = FinanceTransactionType.expense;

    String selectedCategory = 'Operations';

    const List<String> categories = [
      'Sales',
      'Services',
      'Salary',
      'Rent',
      'Marketing',
      'Technology',
      'Operations',
      'Transport',
      'Other',
    ];

    final _FinanceTransaction? newTransaction =
        await showDialog<_FinanceTransaction>(
          context: context,
          builder: (BuildContext dialogContext) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return AlertDialog(
                  title: const Text(
                    'Add Transaction',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: SizedBox(
                    width: 430,
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButtonFormField<FinanceTransactionType>(
                              initialValue: selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Transaction type',
                                prefixIcon: Icon(Icons.swap_vert_rounded),
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: FinanceTransactionType.income,
                                  child: Text('Income'),
                                ),
                                DropdownMenuItem(
                                  value: FinanceTransactionType.expense,
                                  child: Text('Expense'),
                                ),
                              ],
                              onChanged: (FinanceTransactionType? value) {
                                if (value == null) {
                                  return;
                                }

                                setDialogState(() {
                                  selectedType = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                labelText: 'Transaction title',
                                hintText: 'Example: Office rent',
                                prefixIcon: Icon(Icons.receipt_long_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter transaction title';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                prefixText: '₹ ',
                                prefixIcon: Icon(Icons.currency_rupee),
                                border: OutlineInputBorder(),
                              ),
                              validator: (String? value) {
                                final double? amount = double.tryParse(
                                  value?.trim() ?? '',
                                );

                                if (amount == null || amount <= 0) {
                                  return 'Enter a valid amount';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              initialValue: selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category_outlined),
                                border: OutlineInputBorder(),
                              ),
                              items: categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                if (value == null) {
                                  return;
                                }

                                setDialogState(() {
                                  selectedCategory = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Cancel'),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        final bool isValid =
                            formKey.currentState?.validate() ?? false;

                        if (!isValid) {
                          return;
                        }

                        Navigator.pop(
                          dialogContext,
                          _FinanceTransaction(
                            title: titleController.text.trim(),
                            category: selectedCategory,
                            amount: double.parse(amountController.text.trim()),
                            type: selectedType,
                            date: DateTime.now(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
        );

    titleController.dispose();
    amountController.dispose();

    if (newTransaction == null || !mounted) {
      return;
    }

    setState(() {
      _transactions.insert(0, newTransaction);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction added successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Color(0xFF0F172A),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ),
        title: Text(
          'Finance Management',
          style: GoogleFonts.poppins(
            color: const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
            height: 1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: 'Refresh',
                  onPressed: () {
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        onPressed: _showAddTransactionDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final bool compact = width < 700;
            final bool stackSections = width < 1050;

            return SingleChildScrollView(
              padding: EdgeInsets.all(compact ? 16 : 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1450),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(compact),

                      const SizedBox(height: 24),

                      _buildSummaryCards(width),

                      const SizedBox(height: 24),

                      if (stackSections)
                        Column(
                          children: [
                            _buildTransactionsCard(),
                            const SizedBox(height: 22),
                            _buildMonthlyOverview(),
                            const SizedBox(height: 22),
                            _buildBudgetCard(),
                            const SizedBox(height: 22),
                            _buildCategoryCard(),
                          ],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildTransactionsCard()),
                            const SizedBox(width: 22),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildMonthlyOverview(),
                                  const SizedBox(height: 22),
                                  _buildBudgetCard(),
                                  const SizedBox(height: 22),
                                  _buildCategoryCard(),
                                ],
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool compact) {
    final Widget information = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Overview',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: compact ? 24 : 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Track income, expenses, profit and business budgets.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );

    final Widget button = FilledButton.icon(
      onPressed: _showAddTransactionDialog,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff2563EB),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'New Transaction',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 22 : 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff020A3D), Color(0xff2563EB), Color(0xff9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2563EB).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [information, const SizedBox(height: 18), button],
            )
          : Row(
              children: [
                Expanded(child: information),
                button,
              ],
            ),
    );
  }

  Widget _buildSummaryCards(double availableWidth) {
    final List<Widget> cards = [
      _summaryCard(
        title: 'Total Income',
        value: _formatMoney(_totalIncome),
        icon: Icons.south_west_rounded,
        color: const Color(0xff10B981),
        change: '+12.5% this month',
      ),
      _summaryCard(
        title: 'Total Expenses',
        value: _formatMoney(_totalExpense),
        icon: Icons.north_east_rounded,
        color: const Color(0xffEF4444),
        change: 'Monthly spending',
      ),
      _summaryCard(
        title: 'Net Profit',
        value: _formatMoney(_netProfit),
        icon: Icons.trending_up_rounded,
        color: const Color(0xff2563EB),
        change: 'Income minus expenses',
      ),
      _summaryCard(
        title: 'Current Balance',
        value: _formatMoney(_currentBalance),
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xff8B5CF6),
        change: 'Available business funds',
      ),
    ];

    int columnCount;

    if (availableWidth < 520) {
      columnCount = 1;
    } else if (availableWidth < 1000) {
      columnCount = 2;
    } else {
      columnCount = 4;
    }

    const double spacing = 16;

    final double cardWidth =
        (availableWidth - spacing * (columnCount - 1)) / columnCount;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: cards.map((Widget card) {
        return SizedBox(width: cardWidth, child: card);
      }).toList(),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
  }) {
    final Color surface = Theme.of(context).colorScheme.surface;

    return Container(
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: color.withValues(alpha: 0.13),
            child: Icon(icon, color: color, size: 27),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 7),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  change,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Recent Transactions',
            subtitle: '${_transactions.length} transactions available',
            icon: Icons.receipt_long_outlined,
          ),

          const SizedBox(height: 12),

          if (_transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(child: Text('No transactions found')),
            )
          else
            ..._transactions.take(7).map(_buildTransactionTile),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(_FinanceTransaction transaction) {
    final bool isIncome = transaction.type == FinanceTransactionType.income;

    final Color color = isIncome
        ? const Color(0xff10B981)
        : const Color(0xffEF4444);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(
              isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.category} • ${_formatDate(transaction.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${isIncome ? '+' : '-'}${_formatMoney(transaction.amount)}',
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverview() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Monthly Overview',
            subtitle: 'Income and expense comparison',
            icon: Icons.show_chart_rounded,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _legend(const Color(0xff2563EB), 'Income'),
              const SizedBox(width: 18),
              _legend(const Color(0xffF97316), 'Expense'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xff16A34A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Net +₹37k',
                  style: TextStyle(
                    color: Color(0xff16A34A),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: FinanceOverviewChartPainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    final double progress = (_totalExpense / _monthlyBudget).clamp(0, 1);

    final double remaining = (_monthlyBudget - _totalExpense).clamp(
      0,
      _monthlyBudget,
    );

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Monthly Budget',
            subtitle: 'Expense limit monitoring',
            icon: Icons.savings_outlined,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatMoney(_totalExpense),
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'of ${_formatMoney(_monthlyBudget)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.85
                    ? const Color(0xffEF4444)
                    : const Color(0xff2563EB),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% used • ${_formatMoney(remaining)} remaining',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard() {
    final List<MapEntry<String, double>> categories =
        _expenseCategories.entries.toList()..sort(
          (MapEntry<String, double> first, MapEntry<String, double> second) =>
              second.value.compareTo(first.value),
        );

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Expense Categories',
            subtitle: 'Where business money is spent',
            icon: Icons.donut_large_rounded,
          ),
          const SizedBox(height: 16),
          if (categories.isEmpty)
            const Text('No expense data available')
          else
            ...categories.take(5).map((MapEntry<String, double> entry) {
              final double progress = _totalExpense == 0
                  ? 0
                  : entry.value / _totalExpense;

              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          _formatMoney(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xff2563EB).withValues(alpha: 0.12),
          child: Icon(icon, color: const Color(0xff2563EB)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legend(Color color, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }

  String _formatMoney(double value) {
    final String digits = value.abs().round().toString();
    final StringBuffer buffer = StringBuffer();

    for (int index = 0; index < digits.length; index++) {
      buffer.write(digits[index]);

      final int remaining = digits.length - index - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }

    return '₹${buffer.toString()}';
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _FinanceTransaction {
  const _FinanceTransaction({
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
  });

  final String title;
  final String category;
  final double amount;
  final FinanceTransactionType type;
  final DateTime date;
}

class FinanceOverviewChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final List<double> incomeValues = [52, 68, 61, 79, 72, 92];
    final List<double> expenseValues = [30, 42, 36, 48, 41, 55];
    final List<String> months = ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];

    const double leftPadding = 36.0;
    const double rightPadding = 18.0;
    const double topPadding = 26.0;
    const double bottomPadding = 28.0;

    final double plotWidth = size.width - leftPadding - rightPadding;
    final double plotHeight = size.height - topPadding - bottomPadding;
    final double chartBottom = topPadding + plotHeight;
    const double maxScale = 100.0;

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 1. Draw horizontal reference gridlines & Y-axis currency labels (₹100k, ₹75k, ₹50k, ₹25k, ₹0)
    final List<int> yTicks = [100, 75, 50, 25, 0];
    final Paint gridLinePaint = Paint()
      ..color = const Color(0xffE2E8F0).withValues(alpha: 0.8)
      ..strokeWidth = 1.0;

    for (final int tick in yTicks) {
      final double y = topPadding + (1.0 - (tick / maxScale)) * plotHeight;

      const double dashWidth = 4.0;
      const double dashSpace = 4.0;
      double startX = leftPadding;
      while (startX < size.width - rightPadding) {
        canvas.drawLine(
          Offset(startX, y),
          Offset(
            (startX + dashWidth).clamp(leftPadding, size.width - rightPadding),
            y,
          ),
          gridLinePaint,
        );
        startX += dashWidth + dashSpace;
      }

      textPainter.text = TextSpan(
        text: tick == 0 ? "₹0" : "₹${tick}k",
        style: const TextStyle(
          color: Color(0xff94A3B8),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    // 2. Compute plot points for Income and Expense
    final double stepX = plotWidth / (months.length - 1);
    final List<Offset> incomePoints = [];
    final List<Offset> expensePoints = [];

    for (int i = 0; i < months.length; i++) {
      final double px = leftPadding + i * stepX;
      final double pyIncome = topPadding + (1.0 - (incomeValues[i] / maxScale)) * plotHeight;
      final double pyExpense = topPadding + (1.0 - (expenseValues[i] / maxScale)) * plotHeight;

      incomePoints.add(Offset(px, pyIncome));
      expensePoints.add(Offset(px, pyExpense));
    }

    // Helper to generate smooth cubic spline curve
    Path buildSplinePath(List<Offset> pts) {
      final Path path = Path();
      path.moveTo(pts.first.dx, pts.first.dy);
      for (int i = 0; i < pts.length - 1; i++) {
        final Offset p0 = pts[i];
        final Offset p1 = pts[i + 1];
        final double controlDx = (p1.dx - p0.dx) * 0.45;
        final Offset cp1 = Offset(p0.dx + controlDx, p0.dy);
        final Offset cp2 = Offset(p1.dx - controlDx, p1.dy);
        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
      }
      return path;
    }

    final Path incomeCurve = buildSplinePath(incomePoints);
    final Path expenseCurve = buildSplinePath(expensePoints);

    // 3. Draw Area Fills
    // Income Area Fill (Electric Blue Gradient)
    final Path incomeArea = Path.from(incomeCurve)
      ..lineTo(incomePoints.last.dx, chartBottom)
      ..lineTo(incomePoints.first.dx, chartBottom)
      ..close();

    final Paint incomeAreaPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xff2563EB).withValues(alpha: 0.26),
          const Color(0xff06B6D4).withValues(alpha: 0.08),
          const Color(0xff06B6D4).withValues(alpha: 0.00),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(leftPadding, topPadding, plotWidth, plotHeight));

    canvas.drawPath(incomeArea, incomeAreaPaint);

    // Expense Area Fill (Coral Orange Gradient)
    final Path expenseArea = Path.from(expenseCurve)
      ..lineTo(expensePoints.last.dx, chartBottom)
      ..lineTo(expensePoints.first.dx, chartBottom)
      ..close();

    final Paint expenseAreaPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xffF97316).withValues(alpha: 0.20),
          const Color(0xffEF4444).withValues(alpha: 0.06),
          const Color(0xffEF4444).withValues(alpha: 0.00),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(leftPadding, topPadding, plotWidth, plotHeight));

    canvas.drawPath(expenseArea, expenseAreaPaint);

    // 4. Draw Glowing curve strokes
    // Income Curve Stroke
    final Paint incomeStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [Color(0xff2563EB), Color(0xff06B6D4)],
      ).createShader(Rect.fromLTWH(leftPadding, topPadding, plotWidth, plotHeight));

    final Paint incomeGlow = Paint()
      ..color = const Color(0xff2563EB).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(incomeCurve, incomeGlow);
    canvas.drawPath(incomeCurve, incomeStroke);

    // Expense Curve Stroke
    final Paint expenseStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [Color(0xffF97316), Color(0xffEF4444)],
      ).createShader(Rect.fromLTWH(leftPadding, topPadding, plotWidth, plotHeight));

    final Paint expenseGlow = Paint()
      ..color = const Color(0xffF97316).withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(expenseCurve, expenseGlow);
    canvas.drawPath(expenseCurve, expenseStroke);

    // 5. Draw Data Nodes & Month labels
    for (int i = 0; i < months.length; i++) {
      final Offset incPt = incomePoints[i];
      final Offset expPt = expensePoints[i];
      final bool isLast = i == months.length - 1;

      // Vertical guide line
      final Paint dropGuide = Paint()
        ..color = isLast
            ? const Color(0xff2563EB).withValues(alpha: 0.35)
            : const Color(0xffE2E8F0).withValues(alpha: 0.5)
        ..strokeWidth = isLast ? 1.4 : 0.8;

      canvas.drawLine(Offset(incPt.dx, incPt.dy + 6), Offset(incPt.dx, chartBottom), dropGuide);

      // Income Node
      canvas.drawCircle(incPt, 6.5, Paint()..color = const Color(0xff2563EB).withValues(alpha: 0.18));
      canvas.drawCircle(incPt, 4.2, Paint()..color = Colors.white);
      canvas.drawCircle(incPt, 2.8, Paint()..color = const Color(0xff2563EB));

      // Expense Node
      canvas.drawCircle(expPt, 6.0, Paint()..color = const Color(0xffF97316).withValues(alpha: 0.18));
      canvas.drawCircle(expPt, 4.0, Paint()..color = Colors.white);
      canvas.drawCircle(expPt, 2.6, Paint()..color = const Color(0xffF97316));

      // Tooltip pill on the latest month (July peak)
      if (isLast) {
        const double badgeW = 48.0;
        const double badgeH = 20.0;
        final double badgeX = incPt.dx - badgeW / 2;
        final double badgeY = incPt.dy - badgeH - 8;

        final RRect badgeRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(badgeX, badgeY, badgeW, badgeH),
          const Radius.circular(10),
        );
        canvas.drawRRect(badgeRRect, Paint()..color = const Color(0xff0F172A));

        final Path pointerPath = Path()
          ..moveTo(incPt.dx - 3.5, badgeY + badgeH)
          ..lineTo(incPt.dx + 3.5, badgeY + badgeH)
          ..lineTo(incPt.dx, badgeY + badgeH + 3.5)
          ..close();
        canvas.drawPath(pointerPath, Paint()..color = const Color(0xff0F172A));

        textPainter.text = const TextSpan(
          text: "+₹92k",
          style: TextStyle(
            color: Color(0xff38BDF8),
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            badgeX + (badgeW - textPainter.width) / 2,
            badgeY + (badgeH - textPainter.height) / 2,
          ),
        );
      }

      // X-Axis Month label
      textPainter.text = TextSpan(
        text: months[i],
        style: TextStyle(
          color: isLast ? const Color(0xff0F172A) : const Color(0xff64748B),
          fontSize: size.width < 400 ? 10 : 11,
          fontWeight: isLast ? FontWeight.w800 : FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(incPt.dx - textPainter.width / 2, size.height - 18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FinanceOverviewChartPainter oldDelegate) => false;
}
