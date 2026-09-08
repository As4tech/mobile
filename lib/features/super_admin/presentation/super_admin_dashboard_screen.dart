import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../dashboard/presentation/widgets/stat_card.dart';
import '../data/super_admin_models.dart';
import '../data/super_admin_repository.dart';
import '../../../networking/api_client.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  late final SuperAdminRepository _repo;
  SuperAdminDashboardData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = SuperAdminRepository(widget.apiClient);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.fetchDashboard();
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Platform Dashboard',
          style: AppTypography.headingText(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMuted),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? _buildError()
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
          ElevatedButton(onPressed: _load, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final data = _data!;
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: AppTypography.headingText(context)),
            const SizedBox(height: AppSpacing.md),
            _buildStatCards(data.stats),
            const SizedBox(height: AppSpacing.lg),
            Text('Analytics', style: AppTypography.headingText(context)),
            const SizedBox(height: AppSpacing.md),
            _buildCharts(data.charts),
            const SizedBox(height: AppSpacing.lg),
            _buildSchoolRanking(data.charts.schoolRanking),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(SuperAdminStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
            ? 3
            : 2;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.8,
          children: [
            StatCard(
              label: 'Total Schools',
              value: stats.totalSchools.toString(),
              icon: Icons.school,
              accentColor: AppColors.secondary,
            ),
            StatCard(
              label: 'Active Schools',
              value: stats.activeSchools.toString(),
              icon: Icons.check_circle_outline,
              accentColor: AppColors.primary,
            ),
            StatCard(
              label: 'Total Students',
              value: stats.totalStudents.toString(),
              icon: Icons.people,
              accentColor: AppColors.blue,
            ),
            StatCard(
              label: 'Total Parents',
              value: stats.totalParents.toString(),
              icon: Icons.family_restroom,
              accentColor: AppColors.blue,
            ),
            StatCard(
              label: 'Total Transactions',
              value: stats.totalTransactions.toString(),
              icon: Icons.receipt_long,
              accentColor: AppColors.textSecondary,
            ),
            StatCard(
              label: 'Successful',
              value: stats.successfulTransactions.toString(),
              icon: Icons.check_circle,
              accentColor: AppColors.primary,
            ),
            StatCard(
              label: 'Failed',
              value: stats.failedTransactions.toString(),
              icon: Icons.cancel,
              accentColor: AppColors.danger,
            ),
            StatCard(
              label: 'Pending',
              value: stats.pendingTransactions.toString(),
              icon: Icons.hourglass_empty,
              accentColor: AppColors.warning,
            ),
            StatCard(
              label: 'PTA Collections',
              value: _format(stats.totalPtaCollectionsPesewas),
              icon: Icons.account_balance_wallet,
              accentColor: AppColors.primary,
            ),
            StatCard(
              label: 'Platform Fees',
              value: _format(stats.totalPlatformFeesPesewas),
              icon: Icons.trending_up,
              accentColor: AppColors.secondary,
            ),
            StatCard(
              label: 'Gateway Fees',
              value: _format(stats.totalGatewayFeesPesewas),
              icon: Icons.payment,
              accentColor: AppColors.warning,
            ),
            StatCard(
              label: 'Platform Revenue',
              value: _format(stats.platformRevenuePesewas),
              icon: Icons.monetization_on,
              accentColor: AppColors.primary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCharts(SuperAdminCharts charts) {
    return Column(
      children: [
        _buildMonthlyChart(charts.monthlyCollections),
        const SizedBox(height: AppSpacing.md),
        _buildSuccessRateCard(charts.successRate),
      ],
    );
  }

  Widget _buildMonthlyChart(List<MonthlyCollection> data) {
    final maxVal = data.isEmpty
        ? 0
        : data.map((d) => d.totalPesewas).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Collections', style: AppTypography.titleText(context)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: data.isEmpty
                ? const Center(child: Text('No data'))
                : CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: _BarChartPainter(data: data, maxVal: maxVal),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateCard(double rate) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(painter: _MiniDonutPainter(rate: rate)),
          ),
          const SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Success Rate',
                style: AppTypography.titleText(context),
              ),
              const SizedBox(height: 4),
              Text(
                '${rate.toStringAsFixed(1)}%',
                style: AppTypography.displayText(context).copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: rate >= 90
                      ? AppColors.primary
                      : rate >= 70
                      ? AppColors.warning
                      : AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolRanking(List<SchoolRanking> ranking) {
    if (ranking.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'School Collection Ranking',
            style: AppTypography.titleText(context),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < ranking.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '#${i + 1}',
                      style: AppTypography.labelText(context).copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      ranking[i].schoolName,
                      style: AppTypography.labelText(context),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${ranking[i].count} txns',
                      style: AppTypography.labelText(context)
                          .copyWith(color: AppColors.textMuted, fontSize: 12),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _format(ranking[i].totalPesewas),
                      style: AppTypography.labelText(context)
                          .copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _format(int pesewas) {
    final ghc = pesewas / 100;
    if (ghc >= 1000) return 'GH₵${(ghc / 1000).toStringAsFixed(1)}k';
    return 'GH₵${ghc.toStringAsFixed(2)}';
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.data, required this.maxVal});
  final List<MonthlyCollection> data;
  final int maxVal;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxVal == 0) return;
    final padding = const EdgeInsets.fromLTRB(40, 8, 8, 24);
    final chartW = size.width - padding.left - padding.right;
    final chartH = size.height - padding.top - padding.bottom;
    final barW = chartW / data.length * 0.7;
    final gap = chartW / data.length * 0.3;

    for (var i = 0; i < data.length; i++) {
      final fraction = data[i].totalPesewas / maxVal;
      final h = chartH * fraction;
      final x = padding.left + i * (barW + gap);
      final y = padding.top + chartH - h;

      final paint = Paint()..color = AppColors.primary;
      canvas.drawRect(Rect.fromLTWH(x, y, barW, h), paint);

      if (i % 3 == 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: data[i].month.substring(5),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
          ),
        )..layout();
        tp.paint(canvas, Offset(x, padding.top + chartH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.data != data || old.maxVal != maxVal;
}

class _MiniDonutPainter extends CustomPainter {
  _MiniDonutPainter({required this.rate});
  final double rate;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const stroke = 8.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.surfaceLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    final sweep = (rate / 100) * 2 * 3.14159;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweep,
      false,
      Paint()
        ..color = rate >= 90
            ? AppColors.primary
            : rate >= 70
            ? AppColors.warning
            : AppColors.danger
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniDonutPainter old) => old.rate != rate;
}
