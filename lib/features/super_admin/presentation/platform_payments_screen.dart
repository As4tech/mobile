import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/formatters/money.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../data/super_admin_models.dart';
import '../data/super_admin_repository.dart';
import '../../../networking/api_client.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../dashboard/presentation/widgets/student_detail_sheet.dart';

class PlatformPaymentsScreen extends StatefulWidget {
  const PlatformPaymentsScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<PlatformPaymentsScreen> createState() => _PlatformPaymentsScreenState();
}

class _PlatformPaymentsScreenState extends State<PlatformPaymentsScreen> {
  late final SuperAdminRepository _repo;
  late final DashboardRepository _detailRepo;
  final _searchController = TextEditingController();
  String? _stateFilter;
  String? _channelFilter;
  int? _schoolFilter;
  int _currentPage = 1;
  PaginatedAdminPayments? _payments;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = SuperAdminRepository(widget.apiClient);
    _detailRepo = DashboardRepository(widget.apiClient);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({int? page}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repo.fetchPayments(
        page: page ?? _currentPage,
        state: _stateFilter,
        channel: _channelFilter,
        schoolId: _schoolFilter,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
      setState(() {
        _payments = result;
        _currentPage = result.currentPage;
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
          'Platform Payments',
          style: AppTypography.headingText(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _error != null
                ? _buildError()
                : _payments == null || _payments!.data.isEmpty
                ? Center(
                    child: Text(
                      'No payments found',
                      style: AppTypography.bodyText(context)
                          .copyWith(color: AppColors.textMuted),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(child: _buildTable()),
                      _buildPagination(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(color: AppColors.background),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              style: AppTypography.bodyText(context).copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search ref, student, school...',
                prefixIcon: const Icon(Icons.search, size: 16),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
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
              onSubmitted: (_) => _load(page: 1),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildDropdown(
            value: _stateFilter,
            hint: 'Status',
            items: const [
              DropdownMenuItem(value: 'success', child: Text('Success')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'failed', child: Text('Failed')),
            ],
            onChanged: (v) {
              setState(() => _stateFilter = v);
              _load(page: 1);
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildDropdown(
            value: _channelFilter,
            hint: 'Channel',
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
            ],
            onChanged: (v) {
              setState(() => _channelFilter = v);
              _load(page: 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          dropdownColor: AppColors.surface,
          style: AppTypography.labelText(context).copyWith(fontSize: 13),
          hint: Text(
            hint,
            style: AppTypography.labelText(context)
                .copyWith(color: AppColors.textMuted),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
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
            'Failed to load payments',
            style: AppTypography.bodyText(context)
                .copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton(onPressed: () => _load(), child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text('School')),
          DataColumn(label: Text('Student')),
          DataColumn(label: Text('Admission')),
          DataColumn(label: Text('Parent')),
          DataColumn(label: Text('PTA Amount')),
          DataColumn(label: Text('Platform Fee')),
          DataColumn(label: Text('Gateway Fee')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('School Ent.')),
          DataColumn(label: Text('Platform Ent.')),
          DataColumn(label: Text('Reference')),
          DataColumn(label: Text('Channel')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Date')),
        ],
        rows: _payments!.data.map((p) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  p.school?.name ?? '-',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              DataCell(
                Text(
                  p.student?.fullName ?? '-',
                  style: const TextStyle(fontSize: 11),
                ),
                onTap: p.student == null
                    ? null
                    : () => StudentDetailSheet.show(
                        context,
                        studentId: p.student!.id,
                        repository: _detailRepo,
                      ),
              ),
              DataCell(
                Text(
                  p.student?.admissionNumber ?? '-',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              DataCell(
                Text(
                  p.parent?.fullName ?? '-',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              DataCell(
                Text(
                  _format(p.ptaPesewas),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              DataCell(
                Text(
                  _format(p.platformFeePesewas),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              DataCell(
                Text(
                  _format(p.gatewayFeePesewas),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              DataCell(
                Text(
                  _format(p.customerTotalPesewas),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(
                Text(
                  _format(p.schoolEntitlementPesewas),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              DataCell(
                Text(
                  _format(p.platformEntitlementPesewas),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              DataCell(
                Text(
                  p.gatewayReference ?? p.internalReference,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              DataCell(
                Text(
                  p.channel.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              DataCell(_buildStatusBadge(p.state)),
              DataCell(
                Text(
                  p.paidAt != null
                      ? DateFormat('dd MMM yy')
                            .format(DateTime.parse(p.paidAt!))
                      : '-',
                  style: const TextStyle(fontSize: 11),
                ),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
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
                    ? () => _load(page: _currentPage - 1)
                    : null,
                color: AppColors.textMuted,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: _payments!.currentPage < _payments!.lastPage
                    ? () => _load(page: _currentPage + 1)
                    : null,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _format(int pesewas) => MoneyFormatter.formatFull(pesewas);
}
