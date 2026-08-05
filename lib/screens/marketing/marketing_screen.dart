import 'package:flutter/material.dart';

enum CampaignStatus { active, scheduled, paused, completed }

class MarketingDashboard extends StatefulWidget {
  const MarketingDashboard({super.key});

  @override
  State<MarketingDashboard> createState() => _MarketingDashboardState();
}

class _MarketingDashboardState extends State<MarketingDashboard> {
  String _selectedFilter = 'All';

  final List<_MarketingCampaign> _campaigns = [
    _MarketingCampaign(
      name: 'Summer Product Promotion',
      channel: 'Social Media',
      budget: 50000,
      spent: 37500,
      leads: 680,
      conversions: 124,
      status: CampaignStatus.active,
      startDate: DateTime(2026, 7, 1),
      endDate: DateTime(2026, 7, 31),
    ),
    _MarketingCampaign(
      name: 'Google Search Campaign',
      channel: 'Google Ads',
      budget: 35000,
      spent: 21000,
      leads: 430,
      conversions: 92,
      status: CampaignStatus.active,
      startDate: DateTime(2026, 7, 5),
      endDate: DateTime(2026, 8, 5),
    ),
    _MarketingCampaign(
      name: 'Customer Email Campaign',
      channel: 'Email',
      budget: 12000,
      spent: 8500,
      leads: 295,
      conversions: 68,
      status: CampaignStatus.completed,
      startDate: DateTime(2026, 6, 10),
      endDate: DateTime(2026, 6, 30),
    ),
    _MarketingCampaign(
      name: 'Influencer Partnership',
      channel: 'Influencer',
      budget: 45000,
      spent: 10000,
      leads: 170,
      conversions: 32,
      status: CampaignStatus.paused,
      startDate: DateTime(2026, 7, 15),
      endDate: DateTime(2026, 8, 15),
    ),
    _MarketingCampaign(
      name: 'Festival Offer Campaign',
      channel: 'Social Media',
      budget: 60000,
      spent: 0,
      leads: 0,
      conversions: 0,
      status: CampaignStatus.scheduled,
      startDate: DateTime(2026, 8, 1),
      endDate: DateTime(2026, 8, 25),
    ),
  ];

  List<_MarketingCampaign> get _filteredCampaigns {
    if (_selectedFilter == 'All') {
      return _campaigns;
    }

    return _campaigns.where((campaign) {
      return _statusText(campaign.status) == _selectedFilter;
    }).toList();
  }

  double get _totalBudget {
    return _campaigns.fold(0, (total, campaign) => total + campaign.budget);
  }

  double get _totalSpent {
    return _campaigns.fold(0, (total, campaign) => total + campaign.spent);
  }

  int get _totalLeads {
    return _campaigns.fold(0, (total, campaign) => total + campaign.leads);
  }

  int get _totalConversions {
    return _campaigns.fold(
      0,
      (total, campaign) => total + campaign.conversions,
    );
  }

  int get _activeCampaigns {
    return _campaigns.where((campaign) {
      return campaign.status == CampaignStatus.active;
    }).length;
  }

  double get _conversionRate {
    if (_totalLeads == 0) {
      return 0;
    }

    return (_totalConversions / _totalLeads) * 100;
  }

  Map<String, _ChannelPerformance> get _channelPerformance {
    final Map<String, _ChannelPerformance> result = {};

    for (final campaign in _campaigns) {
      if (!result.containsKey(campaign.channel)) {
        result[campaign.channel] = _ChannelPerformance(
          channel: campaign.channel,
          spent: 0,
          leads: 0,
          conversions: 0,
        );
      }

      result[campaign.channel]!.spent += campaign.spent;

      result[campaign.channel]!.leads += campaign.leads;

      result[campaign.channel]!.conversions += campaign.conversions;
    }

    return result;
  }

  Future<void> _showAddCampaignDialog() async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController nameController = TextEditingController();

    final TextEditingController budgetController = TextEditingController();

    String selectedChannel = 'Social Media';

    CampaignStatus selectedStatus = CampaignStatus.scheduled;

    final _MarketingCampaign? newCampaign =
        await showDialog<_MarketingCampaign>(
          context: context,
          builder: (BuildContext dialogContext) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return AlertDialog(
                  title: const Text(
                    'Create Campaign',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: SizedBox(
                    width: 450,
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Campaign name',
                                hintText: 'Example: Festival Promotion',
                                prefixIcon: Icon(Icons.campaign_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter campaign name';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              initialValue: selectedChannel,
                              decoration: const InputDecoration(
                                labelText: 'Marketing channel',
                                prefixIcon: Icon(Icons.public_rounded),
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Social Media',
                                  child: Text('Social Media'),
                                ),
                                DropdownMenuItem(
                                  value: 'Google Ads',
                                  child: Text('Google Ads'),
                                ),
                                DropdownMenuItem(
                                  value: 'Email',
                                  child: Text('Email'),
                                ),
                                DropdownMenuItem(
                                  value: 'Influencer',
                                  child: Text('Influencer'),
                                ),
                                DropdownMenuItem(
                                  value: 'Website',
                                  child: Text('Website'),
                                ),
                                DropdownMenuItem(
                                  value: 'Other',
                                  child: Text('Other'),
                                ),
                              ],
                              onChanged: (String? value) {
                                if (value == null) {
                                  return;
                                }

                                setDialogState(() {
                                  selectedChannel = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: budgetController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Campaign budget',
                                prefixText: '₹ ',
                                prefixIcon: Icon(Icons.currency_rupee),
                                border: OutlineInputBorder(),
                              ),
                              validator: (String? value) {
                                final double? budget = double.tryParse(
                                  value?.trim() ?? '',
                                );

                                if (budget == null || budget <= 0) {
                                  return 'Enter a valid budget';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            DropdownButtonFormField<CampaignStatus>(
                              initialValue: selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Campaign status',
                                prefixIcon: Icon(Icons.flag_outlined),
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: CampaignStatus.scheduled,
                                  child: Text('Scheduled'),
                                ),
                                DropdownMenuItem(
                                  value: CampaignStatus.active,
                                  child: Text('Active'),
                                ),
                                DropdownMenuItem(
                                  value: CampaignStatus.paused,
                                  child: Text('Paused'),
                                ),
                              ],
                              onChanged: (CampaignStatus? value) {
                                if (value == null) {
                                  return;
                                }

                                setDialogState(() {
                                  selectedStatus = value;
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
                        final bool valid =
                            formKey.currentState?.validate() ?? false;

                        if (!valid) {
                          return;
                        }

                        final DateTime startDate = DateTime.now();

                        Navigator.pop(
                          dialogContext,
                          _MarketingCampaign(
                            name: nameController.text.trim(),
                            channel: selectedChannel,
                            budget: double.parse(budgetController.text.trim()),
                            spent: 0,
                            leads: 0,
                            conversions: 0,
                            status: selectedStatus,
                            startDate: startDate,
                            endDate: startDate.add(const Duration(days: 30)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create'),
                    ),
                  ],
                );
              },
            );
          },
        );

    nameController.dispose();
    budgetController.dispose();

    if (newCampaign == null || !mounted) {
      return;
    }

    setState(() {
      _campaigns.insert(0, newCampaign);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marketing campaign created successfully')),
    );
  }

  void _changeCampaignStatus(
    _MarketingCampaign campaign,
    CampaignStatus status,
  ) {
    setState(() {
      campaign.status = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${campaign.name} changed to ${_statusText(status)}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Marketing Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCampaignDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Campaign'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool mobile = constraints.maxWidth < 700;

            final bool stackSections = constraints.maxWidth < 1050;

            final double horizontalPadding = mobile ? 16 : 28;

            final double contentWidth =
                (constraints.maxWidth - horizontalPadding * 2)
                    .clamp(0.0, 1450.0)
                    .toDouble();

            return SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1450),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(mobile),

                      const SizedBox(height: 24),

                      _buildSummaryCards(contentWidth),

                      const SizedBox(height: 24),

                      _buildFilterSection(),

                      const SizedBox(height: 20),

                      if (stackSections)
                        Column(
                          children: [
                            _buildCampaignSection(),
                            const SizedBox(height: 22),
                            _buildChannelPerformance(),
                            const SizedBox(height: 22),
                            _buildLeadFunnel(),
                            const SizedBox(height: 22),
                            _buildBudgetOverview(),
                          ],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildCampaignSection()),
                            const SizedBox(width: 22),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildChannelPerformance(),
                                  const SizedBox(height: 22),
                                  _buildLeadFunnel(),
                                  const SizedBox(height: 22),
                                  _buildBudgetOverview(),
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

  Widget _buildHeader(bool mobile) {
    final Widget information = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Marketing Overview',
          style: TextStyle(
            color: Colors.white,
            fontSize: mobile ? 25 : 32,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage campaigns, leads, channels and marketing performance.',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
      ],
    );

    final Widget button = FilledButton.icon(
      onPressed: _showAddCampaignDialog,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff1D4ED8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      icon: const Icon(Icons.add),
      label: const Text(
        'Create Campaign',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 22 : 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff020A3D), Color(0xff1544E5), Color(0xff6D4AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [information, const SizedBox(height: 20), button],
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
        title: 'Total Campaigns',
        value: '${_campaigns.length}',
        subtitle: '$_activeCampaigns currently active',
        icon: Icons.campaign_rounded,
        color: const Color(0xff2563EB),
      ),
      _summaryCard(
        title: 'Marketing Spent',
        value: _formatMoney(_totalSpent),
        subtitle: 'Budget ${_formatMoney(_totalBudget)}',
        icon: Icons.payments_outlined,
        color: const Color(0xffF97316),
      ),
      _summaryCard(
        title: 'Total Leads',
        value: _formatNumber(_totalLeads),
        subtitle: 'Generated from all channels',
        icon: Icons.groups_rounded,
        color: const Color(0xff10B981),
      ),
      _summaryCard(
        title: 'Conversions',
        value: _formatNumber(_totalConversions),
        subtitle: '${_conversionRate.toStringAsFixed(1)}% conversion rate',
        icon: Icons.trending_up_rounded,
        color: const Color(0xff8B5CF6),
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
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(20),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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

  Widget _buildFilterSection() {
    const List<String> filters = [
      'All',
      'Active',
      'Scheduled',
      'Paused',
      'Completed',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: filters.map((String filter) {
        final bool selected = filter == _selectedFilter;

        return FilterChip(
          label: Text(filter),
          selected: selected,
          onSelected: (bool value) {
            setState(() {
              _selectedFilter = filter;
            });
          },
          avatar: selected ? const Icon(Icons.check, size: 17) : null,
        );
      }).toList(),
    );
  }

  Widget _buildCampaignSection() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Marketing Campaigns',
            subtitle: '${_filteredCampaigns.length} campaigns displayed',
            icon: Icons.campaign_outlined,
          ),

          const SizedBox(height: 14),

          if (_filteredCampaigns.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.campaign_outlined, size: 50),
                    SizedBox(height: 12),
                    Text('No campaigns found'),
                  ],
                ),
              ),
            )
          else
            ..._filteredCampaigns.map(_buildCampaignCard),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(_MarketingCampaign campaign) {
    final double progress = campaign.budget == 0
        ? 0
        : (campaign.spent / campaign.budget).clamp(0, 1);

    final Color statusColor = _statusColor(campaign.status);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.14),
                child: Icon(_channelIcon(campaign.channel), color: statusColor),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${campaign.channel} • ${_formatDate(campaign.startDate)} - ${_formatDate(campaign.endDate)}',
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
              const SizedBox(width: 8),
              PopupMenuButton<CampaignStatus>(
                tooltip: 'Change campaign status',
                onSelected: (CampaignStatus status) {
                  _changeCampaignStatus(campaign, status);
                },
                itemBuilder: (BuildContext context) {
                  return CampaignStatus.values.map((CampaignStatus status) {
                    return PopupMenuItem(
                      value: status,
                      child: Text(_statusText(status)),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: statusColor),
                      const SizedBox(width: 7),
                      Text(
                        _statusText(campaign.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _metricChip(
                Icons.account_balance_wallet_outlined,
                'Budget',
                _formatMoney(campaign.budget),
              ),
              _metricChip(
                Icons.payments_outlined,
                'Spent',
                _formatMoney(campaign.spent),
              ),
              _metricChip(Icons.groups_outlined, 'Leads', '${campaign.leads}'),
              _metricChip(
                Icons.check_circle_outline,
                'Conversions',
                '${campaign.conversions}',
              ),
            ],
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              const Text(
                'Budget usage',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.9 ? Colors.red : statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricChip(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '$title: ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelPerformance() {
    final List<_ChannelPerformance> channels =
        _channelPerformance.values.toList()
          ..sort((_ChannelPerformance first, _ChannelPerformance second) {
            return second.leads.compareTo(first.leads);
          });

    int maximumLeads = 1;

    for (final channel in channels) {
      if (channel.leads > maximumLeads) {
        maximumLeads = channel.leads;
      }
    }

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Channel Performance',
            subtitle: 'Lead generation by channel',
            icon: Icons.public_rounded,
          ),

          const SizedBox(height: 18),

          ...channels.map((_ChannelPerformance channel) {
            final double progress = channel.leads / maximumLeads;

            return Padding(
              padding: const EdgeInsets.only(bottom: 17),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _channelIcon(channel.channel),
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          channel.channel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${channel.leads} leads',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
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

  Widget _buildLeadFunnel() {
    final int impressions = 125000;
    final int clicks = 9200;

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Lead Funnel',
            subtitle: 'Customer conversion journey',
            icon: Icons.filter_alt_outlined,
          ),

          const SizedBox(height: 20),

          _funnelItem(
            title: 'Impressions',
            value: impressions,
            progress: 1,
            color: const Color(0xff2563EB),
          ),

          _funnelItem(
            title: 'Clicks',
            value: clicks,
            progress: clicks / impressions,
            color: const Color(0xff06B6D4),
          ),

          _funnelItem(
            title: 'Leads',
            value: _totalLeads,
            progress: _totalLeads / impressions,
            color: const Color(0xff10B981),
          ),

          _funnelItem(
            title: 'Conversions',
            value: _totalConversions,
            progress: _totalConversions / impressions,
            color: const Color(0xff8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _funnelItem({
    required String title,
    required int value,
    required double progress,
    required Color color,
  }) {
    final double visibleProgress = progress.clamp(0.08, 1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                _formatNumber(value),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: visibleProgress,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOverview() {
    final double progress = _totalBudget == 0
        ? 0
        : (_totalSpent / _totalBudget).clamp(0, 1);

    final double remaining = (_totalBudget - _totalSpent).clamp(
      0,
      _totalBudget,
    );

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Marketing Budget',
            subtitle: 'Overall campaign spending',
            icon: Icons.savings_outlined,
          ),

          const SizedBox(height: 22),

          Text(
            _formatMoney(_totalSpent),
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 5),

          Text(
            'Spent from ${_formatMoney(_totalBudget)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.85 ? Colors.red : const Color(0xff2563EB),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% used',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${_formatMoney(remaining)} remaining',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
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

  String _statusText(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.active:
        return 'Active';
      case CampaignStatus.scheduled:
        return 'Scheduled';
      case CampaignStatus.paused:
        return 'Paused';
      case CampaignStatus.completed:
        return 'Completed';
    }
  }

  Color _statusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.active:
        return const Color(0xff10B981);
      case CampaignStatus.scheduled:
        return const Color(0xff2563EB);
      case CampaignStatus.paused:
        return const Color(0xffF59E0B);
      case CampaignStatus.completed:
        return const Color(0xff8B5CF6);
    }
  }

  IconData _channelIcon(String channel) {
    switch (channel) {
      case 'Social Media':
        return Icons.thumb_up_alt_outlined;
      case 'Google Ads':
        return Icons.search_rounded;
      case 'Email':
        return Icons.email_outlined;
      case 'Influencer':
        return Icons.person_pin_outlined;
      case 'Website':
        return Icons.language_rounded;
      default:
        return Icons.campaign_outlined;
    }
  }

  String _formatMoney(double amount) {
    final String digits = amount.abs().round().toString();

    final StringBuffer result = StringBuffer();

    for (int index = 0; index < digits.length; index++) {
      result.write(digits[index]);

      final int remaining = digits.length - index - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        result.write(',');
      }
    }

    return '₹${result.toString()}';
  }

  String _formatNumber(int value) {
    final String digits = value.toString();
    final StringBuffer result = StringBuffer();

    for (int index = 0; index < digits.length; index++) {
      result.write(digits[index]);

      final int remaining = digits.length - index - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        result.write(',');
      }
    }

    return result.toString();
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

    return '${months[date.month - 1]} ${date.day}';
  }
}

class _MarketingCampaign {
  _MarketingCampaign({
    required this.name,
    required this.channel,
    required this.budget,
    required this.spent,
    required this.leads,
    required this.conversions,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  final String name;
  final String channel;
  final double budget;
  final double spent;
  final int leads;
  final int conversions;
  CampaignStatus status;
  final DateTime startDate;
  final DateTime endDate;
}

class _ChannelPerformance {
  _ChannelPerformance({
    required this.channel,
    required this.spent,
    required this.leads,
    required this.conversions,
  });

  final String channel;
  double spent;
  int leads;
  int conversions;
}
