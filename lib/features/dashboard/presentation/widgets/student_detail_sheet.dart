import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/formatters/money.dart';
import '../../data/dashboard_models.dart';
import '../../data/dashboard_repository.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_badge.dart';

class StudentDetailSheet extends StatefulWidget {
  const StudentDetailSheet({
    super.key,
    required this.studentId,
    required this.repository,
  });

  final int studentId;
  final DashboardRepository repository;

  static void show(
    BuildContext context, {
    required int studentId,
    required DashboardRepository repository,
  }) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: StudentDetailSheet(studentId: studentId, repository: repository),
      ),
    ),
  );

  @override
  State<StudentDetailSheet> createState() => _StudentDetailSheetState();
}

class _StudentDetailSheetState extends State<StudentDetailSheet> {
  StudentDetails? _details;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await widget.repository.fetchStudentDetails(widget.studentId);
      setState(() {
        _details = d;
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
    return SafeArea(
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load details',
                    style: AppTypography.bodyText(context)
                        .copyWith(color: AppColors.danger),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final d = _details!;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.student.fullName,
                            style: AppTypography.titleText(context),
                          ),
                          Text(
                            '${d.student.admissionNumber} · ${d.student.className}',
                            style: AppTypography.labelText(context)
                                .copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildBalanceCards(d.balance),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Invoices',
                  style: AppTypography.titleText(context)
                      .copyWith(fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
        if (d.invoices.isEmpty)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text('No invoices'),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 4,
                ),
                child: _buildInvoiceRow(d.invoices[i]),
              ),
              childCount: d.invoices.length,
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              'Payment History',
              style: AppTypography.titleText(context).copyWith(fontSize: 16),
            ),
          ),
        ),
        if (d.payments.isEmpty)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text('No payments'),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 4,
                ),
                child: _buildPaymentRow(d.payments[i]),
              ),
              childCount: d.payments.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildBalanceCards(StudentBalance balance) {
    return Row(
      children: [
        Expanded(
          child: _MiniCard(
            label: 'Total Billed',
            value: _format(balance.totalBilledPesewas),
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MiniCard(
            label: 'Paid',
            value: _format(balance.totalPaidPesewas),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MiniCard(
            label: 'Outstanding',
            value: _format(balance.outstandingPesewas),
            color: balance.outstandingPesewas > 0
                ? AppColors.warning
                : AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceRow(StudentInvoice inv) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inv.invoiceNumber,
                  style: AppTypography.labelText(context)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  _format(inv.totalPesewas),
                  style: AppTypography.labelText(context)
                      .copyWith(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Paid: ${_format(inv.paidPesewas)}',
                  style: AppTypography.labelText(context)
                      .copyWith(color: AppColors.primary, fontSize: 12),
                ),
                Text(
                  'Due: ${_format(inv.outstandingPesewas)}',
                  style: AppTypography.labelText(context).copyWith(
                    color: inv.outstandingPesewas > 0
                        ? AppColors.warning
                        : AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppBadge(
            status: inv.status == 'paid'
                ? AppStatus.success
                : inv.status == 'cancelled'
                ? AppStatus.failed
                : AppStatus.pending,
            label: inv.status,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(StudentPayment p) {
    final status = switch (p.state) {
      'success' => AppStatus.success,
      'pending' => AppStatus.pending,
      'failed' => AppStatus.failed,
      _ => AppStatus.information,
    };
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.internalReference,
                  style: AppTypography.labelText(context)
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                Text(
                  p.paidAt != null
                      ? DateFormat('dd MMM yyyy')
                            .format(DateTime.parse(p.paidAt!))
                      : '-',
                  style: AppTypography.labelText(context)
                      .copyWith(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _format(p.customerTotalPesewas),
              style: AppTypography.labelText(context)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppBadge(status: status, label: p.state),
        ],
      ),
    );
  }

  String _format(int pesewas) => MoneyFormatter.formatFull(pesewas);
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelText(context)
                .copyWith(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.titleText(
              context,
            ).copyWith(color: color, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
