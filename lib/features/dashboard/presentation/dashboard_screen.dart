import 'package:flutter/material.dart';

import '../../../shared/formatters/money.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../networking/api_client.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';
import 'widgets/stat_card.dart';
import 'widgets/collections_chart.dart';
import 'widgets/channels_chart.dart';
import 'widgets/paid_outstanding_chart.dart';
import 'widgets/class_chart.dart';
import 'widgets/payments_table.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardRepository _repo;
  DashboardData? _dashboard;
  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = DashboardRepository(widget.apiClient);
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (_dashboard == null) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      // Keep the current content mounted so the scroll position survives a
      // pull-to-refresh or a refresh from the app bar. Only the first load
      // shows a full-body spinner.
      setState(() {
        _refreshing = true;
        _error = null;
      });
    }
    try {
      final data = await _repo.fetchDashboard();
      if (!mounted) return;
      setState(() {
        _dashboard = data;
        _loading = false;
        _refreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
        _refreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('PTA Dashboard', style: AppTypography.headingText(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMuted),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: _dashboard == null
          ? _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _buildError()
          : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Failed to load dashboard',
            style: AppTypography.bodyText(context)
                .copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _error!,
            style: AppTypography.labelText(context)
                .copyWith(color: AppColors.textMuted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(onPressed: _loadDashboard, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final data = _dashboard!;
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_refreshing)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceLight,
                ),
              )
            else if (_error != null)
              _buildInlineError(),
            Text('Overview', style: AppTypography.headingText(context)),
            const SizedBox(height: AppSpacing.md),
            _buildStatCards(data.stats),
            const SizedBox(height: AppSpacing.lg),
            Text('Analytics', style: AppTypography.headingText(context)),
            const SizedBox(height: AppSpacing.md),
            _buildCharts(data.charts),
            const SizedBox(height: AppSpacing.lg),
            PaymentsTable(repository: _repo),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.danger),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Could not refresh: ${_error!}',
              style: AppTypography.labelText(context)
                  .copyWith(color: AppColors.danger, fontSize: 12),
            ),
          ),
          TextButton(onPressed: _loadDashboard, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildStatCards(DashboardStats stats) {
    final statCards = <Widget>[
      StatCard(
        label: "Today's Collections",
        value: MoneyFormatter.formatCompact(stats.todayCollectionsPesewas),
        icon: Icons.today,
        accentColor: AppColors.primary,
      ),
      StatCard(
        label: 'Monthly Collections',
        value: MoneyFormatter.formatCompact(stats.monthCollectionsPesewas),
        icon: Icons.calendar_month,
        accentColor: AppColors.primary,
      ),
      StatCard(
        label: 'Total PTA Collections',
        value: MoneyFormatter.formatCompact(stats.totalCollectionsPesewas),
        icon: Icons.account_balance_wallet,
        accentColor: AppColors.secondary,
      ),
      StatCard(
        label: 'Outstanding Dues',
        value: MoneyFormatter.formatCompact(stats.outstandingDuesPesewas),
        icon: Icons.receipt_long,
        accentColor: AppColors.warning,
      ),
      StatCard(
        label: 'Paid Students',
        value: stats.paidStudents.toString(),
        suffix: 'students',
        icon: Icons.check_circle_outline,
        accentColor: AppColors.primary,
      ),
      StatCard(
        label: 'Unpaid Students',
        value: stats.unpaidStudents.toString(),
        suffix: 'students',
        icon: Icons.cancel_outlined,
        accentColor: AppColors.warning,
      ),
      StatCard(
        label: 'Pending Payments',
        value: stats.pendingPayments.toString(),
        icon: Icons.hourglass_empty,
        accentColor: AppColors.blue,
      ),
      StatCard(
        label: 'Failed Payments',
        value: stats.failedPayments.toString(),
        icon: Icons.error_outline,
        accentColor: AppColors.danger,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 760
            ? 3
            : constraints.maxWidth > 480
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: statCards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisExtent: 104,
          ),
          itemBuilder: (context, index) => statCards[index],
        );
      },
    );
  }

  Widget _buildCharts(DashboardCharts charts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWide)
                  Expanded(
                    child: CollectionsChart(data: charts.collectionsOverTime),
                  ),
                if (isWide) const SizedBox(width: AppSpacing.md),
                if (!isWide) CollectionsChart(data: charts.collectionsOverTime),
                if (isWide)
                  Expanded(
                    child: PaidOutstandingChart(data: charts.paidVsOutstanding),
                  ),
                if (!isWide)
                  PaidOutstandingChart(data: charts.paidVsOutstanding),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWide)
                  Expanded(child: ChannelsChart(data: charts.paymentChannels)),
                if (isWide) const SizedBox(width: AppSpacing.md),
                if (!isWide) ChannelsChart(data: charts.paymentChannels),
                if (isWide)
                  Expanded(child: ClassChart(data: charts.classCollections)),
                if (!isWide) ClassChart(data: charts.classCollections),
              ],
            ),
          ],
        );
      },
    );
  }
}
