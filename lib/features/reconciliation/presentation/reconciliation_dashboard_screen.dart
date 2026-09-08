import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../../shared/formatters/money.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_badge.dart';
import '../data/reconciliation_models.dart';
import '../data/reconciliation_repository.dart';

class ReconciliationDashboardScreen extends StatefulWidget {
  const ReconciliationDashboardScreen({super.key, required this.repository});

  final ReconciliationRepository repository;

  @override
  State<ReconciliationDashboardScreen> createState() =>
      _ReconciliationDashboardScreenState();
}

class _ReconciliationDashboardScreenState
    extends State<ReconciliationDashboardScreen> {
  ReconciliationSummary? _summary;
  PaginatedReconciliation? _records;
  bool _loadingSummary = true;
  bool _loadingRecords = true;
  String? _summaryError;
  String? _recordsError;
  int _currentPage = 1;
  static const int _perPage = 25;

  String? _statusFilter;
  String? _settlementFilter;
  String? _searchQuery;
  String? _dateFrom;
  String? _dateTo;

  @override
  void initState() {
    super.initState();
    _loadSummary();
    _loadRecords();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _loadingSummary = true;
      _summaryError = null;
    });
    try {
      final summary = await widget.repository.fetchSummary(
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      );
      setState(() {
        _summary = summary;
        _loadingSummary = false;
      });
    } catch (e) {
      setState(() {
        _summaryError = e.toString();
        _loadingSummary = false;
      });
    }
  }

  Future<void> _loadRecords() async {
    setState(() {
      _loadingRecords = true;
      _recordsError = null;
    });
    try {
      final records = await widget.repository.fetchRecords(
        page: _currentPage,
        perPage: _perPage,
        status: _statusFilter,
        search: _searchQuery,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        settlementStatus: _settlementFilter,
      );
      setState(() {
        _records = records;
        _loadingRecords = false;
      });
    } catch (e) {
      setState(() {
        _recordsError = e.toString();
        _loadingRecords = false;
      });
    }
  }

  Future<void> _runReconciliation() async {
    try {
      final result = await widget.repository.runReconciliation(
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reconciliation complete: ${result.summary['matched'] ?? 0} matched, '
            '${result.summary['amount_mismatch'] ?? 0} mismatches',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      _loadSummary();
      _loadRecords();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.sidebar,
        title: Text(
          'Payment Reconciliation',
          style: AppTypography.titleText(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: ElevatedButton.icon(
              onPressed: _runReconciliation,
              icon: const Icon(Icons.sync, size: 16),
              label: const Text('Run Reconciliation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: AppSpacing.lg),
            _buildFilterBar(),
            const SizedBox(height: AppSpacing.md),
            _buildRecordsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_loadingSummary) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_summaryError != null) {
      return Center(
        child: Text(
          'Error: $_summaryError',
          style: AppTypography.bodyText(context)
              .copyWith(color: AppColors.danger),
        ),
      );
    }

    final s = _summary!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status Overview', style: AppTypography.headingText(context)),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _SummaryCard(
              label: 'Total Records',
              value: '${s.totalRecords}',
              color: AppColors.textPrimary,
            ),
            _SummaryCard(
              label: 'Matched',
              value: '${s.statusCounts['matched'] ?? 0}',
              color: AppColors.primary,
            ),
            _SummaryCard(
              label: 'Amount Mismatch',
              value: '${s.statusCounts['amount_mismatch'] ?? 0}',
              color: AppColors.warning,
            ),
            _SummaryCard(
              label: 'Missing Gateway',
              value: '${s.statusCounts['missing_from_gateway'] ?? 0}',
              color: AppColors.danger,
            ),
            _SummaryCard(
              label: 'Missing Internal',
              value: '${s.statusCounts['missing_internally'] ?? 0}',
              color: AppColors.secondary,
            ),
            _SummaryCard(
              label: 'Unmatched',
              value: '${s.statusCounts['unmatched'] ?? 0}',
              color: AppColors.blue,
            ),
            _SummaryCard(
              label: 'Exceptions',
              value: '${s.exceptionCount}',
              color: AppColors.danger,
            ),
            _SummaryCard(
              label: 'Exception Rate',
              value: '${s.exceptionRate}%',
              color: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Settlement', style: AppTypography.headingText(context)),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _SummaryCard(
              label: 'Settled',
              value: '${s.settlementCounts['settled'] ?? 0}',
              color: AppColors.primary,
            ),
            _SummaryCard(
              label: 'Unsettled',
              value: '${s.settlementCounts['unsettled'] ?? 0}',
              color: AppColors.textMuted,
            ),
            _SummaryCard(
              label: 'Pending',
              value: '${s.settlementCounts['settlement_pending'] ?? 0}',
              color: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 36,
          child: TextField(
            style: AppTypography.bodyText(context).copyWith(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search ref, student...',
              hintStyle: AppTypography.bodyText(context)
                  .copyWith(color: AppColors.textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 16),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              filled: true,
              fillColor: AppColors.surfaceLight,
            ),
            onSubmitted: (v) {
              _searchQuery = v.isEmpty ? null : v;
              _currentPage = 1;
              _loadRecords();
            },
          ),
        ),
        _buildStatusDropdown(),
        _buildSettlementDropdown(),
        _buildDateButton('From', _dateFrom, (v) => _dateFrom = v),
        _buildDateButton('To', _dateTo, (v) => _dateTo = v),
        TextButton(
          onPressed: () {
            setState(() {
              _statusFilter = null;
              _settlementFilter = null;
              _searchQuery = null;
              _dateFrom = null;
              _dateTo = null;
            });
            _currentPage = 1;
            _loadRecords();
            _loadSummary();
          },
          child: const Text('Clear'),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _statusFilter,
          isDense: true,
          dropdownColor: AppColors.surface,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          hint: Text(
            'Status',
            style: AppTypography.labelText(context).copyWith(fontSize: 12),
          ),
          items: const [
            DropdownMenuItem(value: 'matched', child: Text('Matched')),
            DropdownMenuItem(value: 'unmatched', child: Text('Unmatched')),
            DropdownMenuItem(
              value: 'amount_mismatch',
              child: Text('Amount Mismatch'),
            ),
            DropdownMenuItem(
              value: 'missing_from_gateway',
              child: Text('Missing Gateway'),
            ),
            DropdownMenuItem(
              value: 'missing_internally',
              child: Text('Missing Internal'),
            ),
            DropdownMenuItem(value: 'reversed', child: Text('Reversed')),
            DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
            DropdownMenuItem(
              value: 'pending_review',
              child: Text('Pending Review'),
            ),
          ],
          onChanged: (v) {
            setState(() => _statusFilter = v);
            _currentPage = 1;
            _loadRecords();
          },
        ),
      ),
    );
  }

  Widget _buildSettlementDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _settlementFilter,
          isDense: true,
          dropdownColor: AppColors.surface,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          hint: Text(
            'Settlement',
            style: AppTypography.labelText(context).copyWith(fontSize: 12),
          ),
          items: const [
            DropdownMenuItem(value: 'settled', child: Text('Settled')),
            DropdownMenuItem(value: 'unsettled', child: Text('Unsettled')),
            DropdownMenuItem(
              value: 'settlement_pending',
              child: Text('Pending'),
            ),
          ],
          onChanged: (v) {
            setState(() => _settlementFilter = v);
            _currentPage = 1;
            _loadRecords();
          },
        ),
      ),
    );
  }

  Widget _buildDateButton(
    String label,
    String? value,
    ValueChanged<String?> setter,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value != null ? DateTime.parse(value) : DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primary,
                  surface: AppColors.surface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => setter(DateFormat('yyyy-MM-dd').format(picked)));
          _currentPage = 1;
          _loadRecords();
          _loadSummary();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          value ?? label,
          style: AppTypography.labelText(context).copyWith(
            fontSize: 12,
            color: value != null ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsTable() {
    if (_loadingRecords) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_recordsError != null) {
      return Center(
        child: Text(
          'Error: $_recordsError',
          style: AppTypography.bodyText(context)
              .copyWith(color: AppColors.danger),
        ),
      );
    }
    if (_records == null || _records!.data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'No reconciliation records found',
            style: AppTypography.bodyText(context)
                .copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Records', style: AppTypography.headingText(context)),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _openSettlementDialog,
              icon: const Icon(Icons.task_alt, size: 16),
              label: const Text('Mark Settlement'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 14,
            columns: const [
              DataColumn(label: Text('Internal Ref')),
              DataColumn(label: Text('Student')),
              DataColumn(label: Text('School')),
              DataColumn(label: Text('Internal')),
              DataColumn(label: Text('Gateway')),
              DataColumn(label: Text('Internal Amt')),
              DataColumn(label: Text('Gateway Amt')),
              DataColumn(label: Text('Platform Fee')),
              DataColumn(label: Text('Gateway Fee')),
              DataColumn(label: Text('GW Gateway Fee')),
              DataColumn(label: Text('School Ent.')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Settlement')),
              DataColumn(label: Text('Action')),
            ],
            rows: _records!.data.map((r) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      r.internalReference,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  DataCell(
                    Text(
                      r.studentName ?? '-',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  DataCell(
                    Text(
                      r.schoolName ?? '-',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  DataCell(
                    Text(r.internalState, style: const TextStyle(fontSize: 10)),
                  ),
                  DataCell(
                    Text(
                      r.gatewayState ?? '-',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  DataCell(
                    Text(
                      _formatPesewas(r.internalAmountPesewas),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  DataCell(
                    Text(
                      r.gatewayAmountPesewas != null
                          ? _formatPesewas(r.gatewayAmountPesewas!)
                          : '-',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  DataCell(
                    Text(
                      r.internalPlatformFeePesewas != null
                          ? _formatPesewas(r.internalPlatformFeePesewas!)
                          : '-',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  DataCell(
                    Text(
                      r.internalGatewayFeePesewas != null
                          ? _formatPesewas(r.internalGatewayFeePesewas!)
                          : '-',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  DataCell(
                    Text(
                      r.gatewayGatewayFeePesewas != null
                          ? _formatPesewas(r.gatewayGatewayFeePesewas!)
                          : '-',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  DataCell(
                    Text(
                      r.internalSchoolEntitlementPesewas != null
                          ? _formatPesewas(r.internalSchoolEntitlementPesewas!)
                          : '-',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  DataCell(_buildStatusBadge(r.status)),
                  DataCell(_buildSettlementBadge(r.settlementStatus)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.visibility,
                            size: 14,
                            color: AppColors.blue,
                          ),
                          tooltip: 'Details',
                          onPressed: () => _showDetailDialog(r),
                        ),
                        if (r.status == 'pending_review')
                          IconButton(
                            icon: const Icon(
                              Icons.edit_note,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            tooltip: 'Review',
                            onPressed: () => _openReviewDialog(r),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPagination(),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final appStatus = switch (status) {
      'matched' => AppStatus.success,
      'pending_review' => AppStatus.pending,
      'unmatched' ||
      'missing_from_gateway' ||
      'missing_internally' => AppStatus.failed,
      'amount_mismatch' => AppStatus.pending,
      'reversed' || 'refunded' => AppStatus.information,
      _ => AppStatus.pending,
    };
    return AppBadge(status: appStatus, label: status.replaceAll('_', ' '));
  }

  Widget _buildSettlementBadge(String? status) {
    if (status == null || status == 'unsettled') {
      return AppBadge(status: AppStatus.pending, label: 'unsettled');
    }
    final appStatus = switch (status) {
      'settled' => AppStatus.success,
      'settlement_pending' => AppStatus.pending,
      _ => AppStatus.information,
    };
    return AppBadge(status: appStatus, label: status.replaceAll('_', ' '));
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page ${_records!.currentPage} of ${_records!.lastPage} '
          '(${_records!.total} total)',
          style: AppTypography.labelText(context)
              .copyWith(color: AppColors.textMuted, fontSize: 12),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: _records!.currentPage > 1
                  ? () {
                      setState(() => _currentPage--);
                      _loadRecords();
                    }
                  : null,
              color: AppColors.textMuted,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: _records!.currentPage < _records!.lastPage
                  ? () {
                      setState(() => _currentPage++);
                      _loadRecords();
                    }
                  : null,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ],
    );
  }

  void _showDetailDialog(ReconciliationRecord r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Reconciliation Detail',
          style: AppTypography.titleText(context),
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailSection('Identifiers', [
                  _detailRow('Internal Ref', r.internalReference),
                  _detailRow('Gateway Ref', r.gatewayReference ?? '-'),
                  _detailRow('Student', r.studentName ?? '-'),
                  _detailRow('School', r.schoolName ?? '-'),
                  _detailRow('Invoice ID', '${r.invoiceId ?? '-'}'),
                ]),
                const SizedBox(height: AppSpacing.md),
                _detailSection('Internal Snapshot', [
                  _detailRow('State', r.internalState),
                  _detailRow('Amount', _formatPesewas(r.internalAmountPesewas)),
                  _detailRow('Currency', r.internalCurrency),
                  _detailRow(
                    'PTA Fee',
                    r.internalPlatformFeePesewas != null
                        ? _formatPesewas(r.internalPlatformFeePesewas!)
                        : '-',
                  ),
                  _detailRow(
                    'Gateway Fee',
                    r.internalGatewayFeePesewas != null
                        ? _formatPesewas(r.internalGatewayFeePesewas!)
                        : '-',
                  ),
                  _detailRow(
                    'School Entitlement',
                    r.internalSchoolEntitlementPesewas != null
                        ? _formatPesewas(r.internalSchoolEntitlementPesewas!)
                        : '-',
                  ),
                  _detailRow('Paid At', _formatDateTime(r.internalPaidAt)),
                ]),
                const SizedBox(height: AppSpacing.md),
                _detailSection('Gateway Snapshot', [
                  _detailRow('State', r.gatewayState ?? '-'),
                  _detailRow(
                    'Amount',
                    r.gatewayAmountPesewas != null
                        ? _formatPesewas(r.gatewayAmountPesewas!)
                        : '-',
                  ),
                  _detailRow('Currency', r.gatewayCurrency ?? '-'),
                  _detailRow(
                    'Platform Fee',
                    r.gatewayPlatformFeePesewas != null
                        ? _formatPesewas(r.gatewayPlatformFeePesewas!)
                        : '-',
                  ),
                  _detailRow(
                    'Gateway Fee',
                    r.gatewayGatewayFeePesewas != null
                        ? _formatPesewas(r.gatewayGatewayFeePesewas!)
                        : '-',
                  ),
                  _detailRow('Paid At', _formatDateTime(r.gatewayPaidAt)),
                ]),
                const SizedBox(height: AppSpacing.md),
                _detailSection('Settlement', [
                  _detailRow('Status', r.settlementStatus ?? 'unsettled'),
                  _detailRow('Batch Ref', r.settlementBatchRef ?? '-'),
                  _detailRow('Date', _formatDateTime(r.settlementDate)),
                ]),
                if (r.discrepancyNotes != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _detailSection('Discrepancy', [
                    Text(
                      r.discrepancyNotes!,
                      style: AppTypography.bodyText(context)
                          .copyWith(fontSize: 12, color: AppColors.warning),
                    ),
                  ]),
                ],
                if (r.reviewedAt != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Reviewed: ${_formatDateTime(r.reviewedAt)}',
                    style: AppTypography.labelText(context)
                        .copyWith(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelText(context).copyWith(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        ...children,
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.labelText(context)
                  .copyWith(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyText(context).copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  void _openReviewDialog(ReconciliationRecord record) {
    String selectedStatus = record.status;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Review Record', style: AppTypography.titleText(context)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Internal Ref: ${record.internalReference}',
                style: AppTypography.bodyText(context).copyWith(fontSize: 12),
              ),
              if (record.studentName != null)
                Text(
                  'Student: ${record.studentName}',
                  style: AppTypography.bodyText(context).copyWith(fontSize: 12),
                ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'matched', child: Text('Matched')),
                  DropdownMenuItem(
                    value: 'unmatched',
                    child: Text('Unmatched'),
                  ),
                  DropdownMenuItem(
                    value: 'amount_mismatch',
                    child: Text('Amount Mismatch'),
                  ),
                  DropdownMenuItem(
                    value: 'missing_from_gateway',
                    child: Text('Missing Gateway'),
                  ),
                  DropdownMenuItem(
                    value: 'missing_internally',
                    child: Text('Missing Internal'),
                  ),
                  DropdownMenuItem(value: 'reversed', child: Text('Reversed')),
                  DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
                  DropdownMenuItem(
                    value: 'pending_review',
                    child: Text('Pending Review'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) selectedStatus = v;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: notesController,
                maxLines: 3,
                style: AppTypography.bodyText(context).copyWith(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Notes (optional)',
                  hintStyle: AppTypography.bodyText(context)
                      .copyWith(color: AppColors.textMuted, fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await widget.repository.reviewRecord(
                  record.id,
                  selectedStatus,
                  notesController.text.isEmpty ? null : notesController.text,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Review saved'),
                    backgroundColor: AppColors.primary,
                  ),
                );
                _loadRecords();
                _loadSummary();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
            ),
            child: const Text('Save Review'),
          ),
        ],
      ),
    );
  }

  String _formatPesewas(int pesewas) => MoneyFormatter.formatFull(pesewas);

  String _formatDateTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  void _openSettlementDialog() {
    final records = _records?.data ?? const <ReconciliationRecord>[];
    final available = records
        .where((r) => r.settlementStatus != 'settled')
        .toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No unsettled records on this page to mark.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final selected = <String>{};
    final batchRef = TextEditingController(
      text: 'STL-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}',
    );
    String? settlementDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final canSubmit = selected.isNotEmpty && batchRef.text.isNotEmpty;

          void submit() async {
            if (!canSubmit) return;
            Navigator.of(ctx).pop();
            try {
              await widget.repository.markSettlement(
                references: selected.toList(),
                batchRef: batchRef.text.trim(),
                settlementDate: settlementDate,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Marked ${selected.length} record(s) settled '
                    '(batch ${batchRef.text.trim()})',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
              _loadRecords();
              _loadSummary();
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          }

          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              'Mark Settlement',
              style: AppTypography.titleText(context),
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select records to mark as settled (${available.length} '
                      'unsettled on this page):',
                      style: AppTypography.bodyText(context)
                          .copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => setDialogState(() {
                            if (selected.length == available.length) {
                              selected.clear();
                            } else {
                              selected
                                ..clear()
                                ..addAll(
                                  available.map((r) => r.internalReference),
                                );
                            }
                          }),
                          child: Text(
                            selected.length == available.length &&
                                    available.isNotEmpty
                                ? 'Deselect all'
                                : 'Select all',
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${selected.length} selected',
                          style: AppTypography.labelText(context)
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 240),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final r in available)
                            CheckboxListTile(
                              dense: true,
                              value: selected.contains(r.internalReference),
                              onChanged: (checked) {
                                setDialogState(() {
                                  if (checked ?? false) {
                                    selected.add(r.internalReference);
                                  } else {
                                    selected.remove(r.internalReference);
                                  }
                                });
                              },
                              title: Text(
                                r.internalReference,
                                style: AppTypography.labelText(context)
                                    .copyWith(fontSize: 12),
                              ),
                              subtitle: Text(
                                [
                                  if (r.studentName != null) r.studentName!,
                                  _formatPesewas(r.internalAmountPesewas),
                                ].join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelText(context)
                                    .copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                              ),
                              activeColor: AppColors.primary,
                              checkColor: AppColors.background,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: batchRef,
                      style: AppTypography.bodyText(context)
                          .copyWith(fontSize: 13),
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Batch reference *',
                        hintText: 'e.g. STL-20260904-1030',
                        hintStyle: AppTypography.bodyText(context)
                            .copyWith(color: AppColors.textMuted, fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: settlementDate != null
                              ? DateTime.parse(settlementDate!)
                              : DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primary,
                                  surface: AppColors.surface,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            settlementDate = DateFormat('yyyy-MM-dd')
                                .format(picked);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          settlementDate == null
                              ? 'Settlement date (optional)'
                              : 'Settlement date: $settlementDate',
                          style: AppTypography.labelText(context).copyWith(
                            fontSize: 12,
                            color: settlementDate != null
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: canSubmit ? submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                ),
                child: const Text('Mark Settled'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelText(context)
                  .copyWith(color: AppColors.textMuted, fontSize: 11),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.displayText(context)
                  .copyWith(color: color, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
