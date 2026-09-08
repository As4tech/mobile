import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../shared/formatters/money.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_badge.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';

class ReceiptDetailScreen extends StatefulWidget {
  const ReceiptDetailScreen({
    super.key,
    required this.repository,
    required this.receiptId,
  });

  final DashboardRepository repository;
  final int receiptId;

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  ReceiptDetail? _receipt;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final receipt = await widget.repository.fetchReceipt(widget.receiptId);
      setState(() {
        _receipt = receipt;
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
        backgroundColor: AppColors.sidebar,
        title: Text('Receipt Detail', style: AppTypography.titleText(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? _buildError()
          : _buildReceipt(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed to load receipt',
              style: AppTypography.bodyText(context)
                  .copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(onPressed: _loadReceipt, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildReceipt() {
    final r = _receipt!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.receiptNumber,
                            style: AppTypography.displayText(context)
                                .copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            r.schoolName,
                            style: AppTypography.bodyText(context).copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppBadge(
                      status: r.paymentStatus == 'success'
                          ? AppStatus.success
                          : AppStatus.pending,
                      label: r.paymentStatus,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: AppSpacing.md),
                _infoRow(
                  context,
                  'Receipt Date',
                  _formatDate(r.createdAt ?? r.paymentDate),
                ),
                _infoRow(context, 'Payment Date', _formatDate(r.paymentDate)),
                _infoRow(context, 'Internal Reference', r.internalReference),
                if (r.gatewayReference != null)
                  _infoRow(context, 'Gateway Reference', r.gatewayReference!),
                _infoRow(
                  context,
                  'Channel',
                  r.paymentChannel.replaceAll('_', ' '),
                ),
                _infoRow(context, 'Currency', r.currency),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Information',
                  style: AppTypography.headingText(context),
                ),
                const SizedBox(height: AppSpacing.md),
                _infoRow(context, 'Full Name', r.studentFullName),
                _infoRow(context, 'Admission Number', r.studentAdmissionNumber),
                _infoRow(context, 'Class', r.studentClassName),
                _infoRow(context, 'Parent/Guardian', r.parentName),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Details',
                  style: AppTypography.headingText(context),
                ),
                const SizedBox(height: AppSpacing.md),
                _amountRow(
                  context,
                  'PTA Amount',
                  MoneyFormatter.formatFull(r.ptaAmountPesewas),
                ),
                _amountRow(
                  context,
                  'Platform Fee',
                  MoneyFormatter.formatFull(r.platformFeePesewas),
                ),
                _amountRow(
                  context,
                  'Gateway Fee',
                  MoneyFormatter.formatFull(r.gatewayFeePesewas),
                ),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: AppSpacing.sm),
                _amountRow(
                  context,
                  'Total Paid',
                  MoneyFormatter.formatFull(r.totalPaidPesewas),
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Print/Share coming soon')),
                );
              },
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Print Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: AppTypography.labelText(context)
                  .copyWith(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyText(context).copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelText(context)
                .copyWith(color: AppColors.textMuted, fontSize: 12),
          ),
          Text(
            value,
            style: AppTypography.bodyText(context).copyWith(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: isBold ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return isoDate;
    }
  }
}
