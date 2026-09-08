import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../data/super_admin_models.dart';
import '../data/super_admin_repository.dart';
import '../../../networking/api_client.dart';

class SchoolManagementScreen extends StatefulWidget {
  const SchoolManagementScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<SchoolManagementScreen> createState() => _SchoolManagementScreenState();
}

class _SchoolManagementScreenState extends State<SchoolManagementScreen> {
  late final SuperAdminRepository _repo;
  final _searchController = TextEditingController();
  String? _statusFilter;
  PaginatedSchools? _schools;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = SuperAdminRepository(widget.apiClient);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({int page = 1}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repo.fetchSchools(
        page: page,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        status: _statusFilter,
      );
      setState(() {
        _schools = result;
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
        title: Text('Schools', style: AppTypography.headingText(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMuted),
            onPressed: () => _load(),
          ),
        ],
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
                : _buildList(),
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
            child: TextField(
              controller: _searchController,
              style: AppTypography.bodyText(context).copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search schools...',
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
              onSubmitted: (_) => _load(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                isDense: true,
                dropdownColor: AppColors.surface,
                style: AppTypography.labelText(context).copyWith(fontSize: 13),
                hint: Text(
                  'Status',
                  style: AppTypography.labelText(context)
                      .copyWith(color: AppColors.textMuted),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (v) {
                  setState(() => _statusFilter = v);
                  _load();
                },
              ),
            ),
          ),
        ],
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
            'Failed to load schools',
            style: AppTypography.bodyText(context)
                .copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: AppSpacing.sm),
          ElevatedButton(onPressed: () => _load(), child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_schools == null || _schools!.data.isEmpty) {
      return Center(
        child: Text(
          'No schools found',
          style: AppTypography.bodyText(context)
              .copyWith(color: AppColors.textMuted),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: _schools!.data.length,
      itemBuilder: (context, i) => _buildSchoolRow(_schools!.data[i]),
    );
  }

  Widget _buildSchoolRow(SchoolListItem school) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: school.active
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.school,
                color: school.active ? AppColors.primary : AppColors.danger,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    style: AppTypography.labelText(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${school.code} · ${school.region ?? '-'}',
                    style: AppTypography.labelText(context)
                        .copyWith(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            AppBadge(
              status: school.active ? AppStatus.success : AppStatus.failed,
              label: school.active ? 'Active' : 'Inactive',
            ),
          ],
        ),
      ),
    );
  }
}
