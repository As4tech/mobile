import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/formatters/money.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../data/dashboard_models.dart';
import '../../data/dashboard_repository.dart';
import '../receipt_detail_screen.dart';
import 'student_detail_sheet.dart';

class PaymentsTable extends StatefulWidget {
  const PaymentsTable({super.key, required this.repository});

  final DashboardRepository repository;

  @override
  State<PaymentsTable> createState() => _PaymentsTableState();
}

class _PaymentsTableState extends State<PaymentsTable> {
  final _searchController = TextEditingController();
  String? _stateFilter;
  String? _channelFilter;
  String? _classFilter;
  String? _dateFrom;
  String? _dateTo;
  int _currentPage = 1;
  static const int _perPage = 25;
  PaginatedPayments? _payments;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.repository.fetchPayments(
        page: _currentPage,
        perPage: _perPage,
        state: _stateFilter,
        channel: _channelFilter,
        className: _classFilter,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      );
      setState(() {
        _payments = result;
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
    return AppCard(
      title: 'Payments',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchField(),
          const SizedBox(width: AppSpacing.sm),
          _buildFilters(),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterBar(),
          const SizedBox(height: AppSpacing.md),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load payments',
                      style: AppTypography.bodyText(context)
                          .copyWith(color: AppColors.danger),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: _loadPayments,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_payments == null || _payments!.data.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'No payments found',
                  style: AppTypography.bodyText(context)
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
            )
          else ...[
            _buildDataTable(),
            const SizedBox(height: AppSpacing.md),
            _buildPagination(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: 220,
      height: 36,
      child: TextField(
        controller: _searchController,
        style: AppTypography.bodyText(context).copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search ref, student, parent...',
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
        onSubmitted: (_) => _loadPayments(),
      ),
    );
  }

  Widget _buildFilters() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              'Filters',
              style: AppTypography.labelText(context).copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      onSelected: (_) {},
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: _FilterMenu(
            stateFilter: _stateFilter,
            channelFilter: _channelFilter,
            classFilter: _classFilter,
            dateFrom: _dateFrom,
            dateTo: _dateTo,
            onStateChanged: (v) => setState(() => _stateFilter = v),
            onChannelChanged: (v) => setState(() => _channelFilter = v),
            onClassChanged: (v) => setState(() => _classFilter = v),
            onDateFromChanged: (v) => setState(() => _dateFrom = v),
            onDateToChanged: (v) => setState(() => _dateTo = v),
            onApply: () {
              Navigator.of(context).pop();
              _currentPage = 1;
              _loadPayments();
            },
            onClear: () {
              setState(() {
                _stateFilter = null;
                _channelFilter = null;
                _classFilter = null;
                _dateFrom = null;
                _dateTo = null;
              });
              Navigator.of(context).pop();
              _currentPage = 1;
              _loadPayments();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final hasFilters =
        _stateFilter != null ||
        _channelFilter != null ||
        _classFilter != null ||
        _dateFrom != null ||
        _dateTo != null;
    if (!hasFilters) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        if (_stateFilter != null)
          _FilterChip(
            label: 'Status: $_stateFilter',
            onRemove: () {
              setState(() => _stateFilter = null);
              _currentPage = 1;
              _loadPayments();
            },
          ),
        if (_channelFilter != null)
          _FilterChip(
            label: 'Channel: $_channelFilter',
            onRemove: () {
              setState(() => _channelFilter = null);
              _currentPage = 1;
              _loadPayments();
            },
          ),
        if (_classFilter != null)
          _FilterChip(
            label: 'Class: $_classFilter',
            onRemove: () {
              setState(() => _classFilter = null);
              _currentPage = 1;
              _loadPayments();
            },
          ),
        if (_dateFrom != null)
          _FilterChip(
            label: 'From: $_dateFrom',
            onRemove: () {
              setState(() => _dateFrom = null);
              _currentPage = 1;
              _loadPayments();
            },
          ),
        if (_dateTo != null)
          _FilterChip(
            label: 'To: $_dateTo',
            onRemove: () {
              setState(() => _dateTo = null);
              _currentPage = 1;
              _loadPayments();
            },
          ),
      ],
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Reference')),
          DataColumn(label: Text('Student')),
          DataColumn(label: Text('Admission')),
          DataColumn(label: Text('Parent')),
          DataColumn(label: Text('PTA Amount')),
          DataColumn(label: Text('Platform Fee')),
          DataColumn(label: Text('Gateway Fee')),
          DataColumn(label: Text('Total Paid')),
          DataColumn(label: Text('Channel')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Receipt')),
        ],
        rows: _payments!.data.map((p) {
          return DataRow(
            cells: [
              DataCell(
                Text(p.internalReference, style: const TextStyle(fontSize: 12)),
              ),
              DataCell(
                Text(
                  p.student?.fullName ?? '-',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: p.student == null
                    ? null
                    : () => StudentDetailSheet.show(
                        context,
                        studentId: p.student!.id,
                        repository: widget.repository,
                      ),
              ),
              DataCell(
                Text(
                  p.student?.admissionNumber ?? '-',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Text(
                  p.parent?.fullName ?? '-',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Text(
                  _formatPesewas(p.ptaPesewas),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Text(
                  _formatPesewas(p.platformFeePesewas),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Text(
                  _formatPesewas(p.gatewayFeePesewas),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Text(
                  _formatPesewas(p.customerTotalPesewas),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(
                Text(
                  p.channel.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(_buildStatusBadge(p.state)),
              DataCell(
                Text(
                  p.paidAt != null
                      ? DateFormat('dd MMM yyyy')
                            .format(DateTime.parse(p.paidAt!))
                      : '-',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                p.state == 'success'
                    ? IconButton(
                        icon: const Icon(
                          Icons.receipt_long,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        tooltip: 'View Receipt',
                        onPressed: () => _openReceipt(p.id),
                      )
                    : const Text('-', style: TextStyle(fontSize: 12)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String state) {
    final status = switch (state) {
      'success' => AppStatus.success,
      'pending' => AppStatus.pending,
      'failed' => AppStatus.failed,
      _ => AppStatus.information,
    };
    return AppBadge(status: status, label: state);
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page ${_payments!.currentPage} of ${_payments!.lastPage} '
          '(${_payments!.total} total)',
          style: AppTypography.labelText(context)
              .copyWith(color: AppColors.textMuted, fontSize: 12),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: _payments!.currentPage > 1
                  ? () {
                      setState(() => _currentPage--);
                      _loadPayments();
                    }
                  : null,
              color: AppColors.textMuted,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: _payments!.currentPage < _payments!.lastPage
                  ? () {
                      setState(() => _currentPage++);
                      _loadPayments();
                    }
                  : null,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ],
    );
  }

  void _openReceipt(int paymentId) async {
    try {
      final receipt = await widget.repository.fetchReceiptByPayment(paymentId);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReceiptDetailScreen(
            repository: widget.repository,
            receiptId: receipt.id,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No receipt available: $e')));
    }
  }

  String _formatPesewas(int pesewas) => MoneyFormatter.formatFull(pesewas);
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelText(context)
                .copyWith(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterMenu extends StatefulWidget {
  const _FilterMenu({
    required this.stateFilter,
    required this.channelFilter,
    required this.classFilter,
    required this.dateFrom,
    required this.dateTo,
    required this.onStateChanged,
    required this.onChannelChanged,
    required this.onClassChanged,
    required this.onDateFromChanged,
    required this.onDateToChanged,
    required this.onApply,
    required this.onClear,
  });

  final String? stateFilter;
  final String? channelFilter;
  final String? classFilter;
  final String? dateFrom;
  final String? dateTo;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String?> onChannelChanged;
  final ValueChanged<String?> onClassChanged;
  final ValueChanged<String?> onDateFromChanged;
  final ValueChanged<String?> onDateToChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  State<_FilterMenu> createState() => _FilterMenuState();
}

class _FilterMenuState extends State<_FilterMenu> {
  late String? _state;
  late String? _channel;
  late String? _class;

  @override
  void initState() {
    super.initState();
    _state = widget.stateFilter;
    _channel = widget.channelFilter;
    _class = widget.classFilter;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: AppTypography.labelText(context)
                .copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _state,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'success', child: Text('Success')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'failed', child: Text('Failed')),
            ],
            onChanged: (v) => setState(() {
              _state = v;
              widget.onStateChanged(v);
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Channel',
            style: AppTypography.labelText(context)
                .copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _channel,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'card', child: Text('Card')),
              DropdownMenuItem(
                value: 'mobile_money',
                child: Text('Mobile Money'),
              ),
              DropdownMenuItem(
                value: 'bank_transfer',
                child: Text('Bank Transfer'),
              ),
              DropdownMenuItem(value: 'ussd', child: Text('USSD')),
            ],
            onChanged: (v) => setState(() {
              _channel = v;
              widget.onChannelChanged(v);
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Class',
            style: AppTypography.labelText(context)
                .copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _class,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'Form 1', child: Text('Form 1')),
              DropdownMenuItem(value: 'Form 2', child: Text('Form 2')),
              DropdownMenuItem(value: 'Form 3', child: Text('Form 3')),
              DropdownMenuItem(value: 'Form 4', child: Text('Form 4')),
            ],
            onChanged: (v) => setState(() {
              _class = v;
              widget.onClassChanged(v);
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: widget.onClear, child: const Text('Clear')),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                onPressed: widget.onApply,
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
