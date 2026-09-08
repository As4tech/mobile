import 'package:flutter/material.dart';

import '../../../networking/api_client.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_typography.dart';
import '../../super_admin/data/super_admin_models.dart';
import '../data/registration_models.dart';
import '../data/registration_repository.dart';
import 'widgets/record_list.dart';
import 'widgets/registration_sheets.dart';

/// Registration module: role-aware records tables for Regions, Schools,
/// Students and School Users. Super admins see all four tabs; any other role
/// only registers students for their own school.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    super.key,
    required this.apiClient,
    this.isSuperAdmin = false,
  });

  final ApiClient apiClient;
  final bool isSuperAdmin;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  late final RegistrationRepository _repo;
  late final TabController _tab;

  List<SchoolListItem> _schools = const [];
  List<Region> _regions = const [];

  @override
  void initState() {
    super.initState();
    _repo = RegistrationRepository(widget.apiClient);
    final tabCount = widget.isSuperAdmin ? 4 : 1;
    _tab = TabController(length: tabCount, vsync: this);
    if (widget.isSuperAdmin) {
      _loadRegions();
      _loadSchools();
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadRegions() async {
    try {
      final regions = await _repo.fetchRegions();
      if (mounted) {
        setState(() => _regions = regions);
      }
    } catch (_) {
      // Region dropdown stays empty; the sheet still reports live errors.
    }
  }

  Future<void> _loadSchools() async {
    try {
      final result = await _repo.fetchSchools(perPage: 200);
      if (mounted) {
        setState(() => _schools = result.data);
      }
    } catch (_) {
      // Dropdowns stay empty; the add/bulk sheets still report errors.
    }
  }

  Future<void> _confirmToggle(
    BuildContext context, {
    required String label,
    Color color = AppColors.primary,
    required Future<void> Function() onConfirm,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Confirm $label',
          style: AppTypography.titleText(dialogContext),
        ),
        content: Text(
          'Are you sure you want to $label this record?',
          style: AppTypography.bodyText(dialogContext),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: AppColors.background,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(label),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await onConfirm();
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('$label successful'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.isSuperAdmin
        ? const [
            (label: 'Regions', icon: Icons.map_outlined),
            (label: 'Schools', icon: Icons.school_outlined),
            (label: 'Students', icon: Icons.people_outline),
            (label: 'Users', icon: Icons.group_outlined),
          ]
        : const [(label: 'Students', icon: Icons.people_outline)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registration', style: AppTypography.headingText(context)),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                widget.isSuperAdmin
                    ? 'Register regions, schools, students and school users.'
                    : 'Register students for your school.',
                style: AppTypography.bodyText(context)
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tab,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: AppTypography.labelText(context),
              tabs: [
                for (final t in tabs)
                  Tab(
                    icon: Icon(t.icon, size: 18),
                    iconMargin: const EdgeInsets.only(right: 6),
                    text: t.label,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              if (widget.isSuperAdmin) _regionsTab(),
              if (widget.isSuperAdmin) _schoolsTab(),
              _studentsTab(pickSchool: widget.isSuperAdmin),
              if (widget.isSuperAdmin) _usersTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _regionsTab() {
    return _RecordsView<Region>(
      title: 'Regions',
      leadingIcon: (_) => Icons.map_outlined,
      columns: [
        RecordColumn('Region', (r) => r.name),
        RecordColumn('Code', (r) => r.code ?? '-'),
      ],
      titleText: (r) => r.name,
      subtitleText: (r) => r.code ?? '',
      emptyText: 'No regions yet. Add your first region below.',
      fetch: ({int page = 1}) async {
        final regions = await _repo.fetchRegions();
        return PaginatedRecords.plain(regions);
      },
      showAdd: () => showRegionForm(context, _repo),
      showBulk: () => showBulkUploadSheet(
        context,
        _repo,
        kind: BulkKind.region,
        pickSchool: false,
      ),
      rowActions: (r) => [
        PopupMenuItem<Future<void> Function()>(
          value: () async => showRegionForm(context, _repo, existing: r),
          child: const ListTile(
            dense: true,
            leading: Icon(Icons.edit_outlined, size: 18),
            title: Text('Edit'),
          ),
        ),
      ],
    );
  }

  Widget _schoolsTab() {
    return _RecordsView<SchoolListItem>(
      title: 'Schools',
      leadingIcon: (_) => Icons.school_outlined,
      columns: [
        RecordColumn('School', (s) => s.name),
        RecordColumn('Code', (s) => s.code),
        RecordColumn('Region', (s) => s.region ?? '-'),
        RecordColumn('District', (s) => s.district ?? '-'),
      ],
      titleText: (s) => s.name,
      subtitleText: (s) => '${s.code} · ${s.region ?? '-'}',
      trailing: (s) => AppBadge(
        status: s.active ? AppStatus.success : AppStatus.failed,
        label: s.active ? 'Active' : 'Inactive',
      ),
      emptyText: 'No schools yet. Register the first school below.',
      fetch: ({int page = 1}) => _repo.fetchSchools(page: page, perPage: 50),
      onReload: () {
        if (widget.isSuperAdmin) {
          _loadRegions();
          _loadSchools();
        }
      },
      showAdd: () => showSchoolForm(context, _repo, regions: _regions),
      showBulk: () => showBulkUploadSheet(
        context,
        _repo,
        kind: BulkKind.school,
        pickSchool: false,
      ),
      rowActions: (s) => [
        if (s.active)
          PopupMenuItem<Future<void> Function()>(
            value: () => _confirmToggle(
              context,
              label: 'Deactivate',
              color: AppColors.danger,
              onConfirm: () async =>
                  _repo.updateSchoolActive(id: s.id, active: false),
            ),
            child: const ListTile(
              dense: true,
              leading: Icon(
                Icons.block_outlined,
                size: 18,
                color: AppColors.danger,
              ),
              title: Text('Deactivate'),
            ),
          )
        else
          PopupMenuItem<Future<void> Function()>(
            value: () => _confirmToggle(
              context,
              label: 'Activate',
              onConfirm: () async =>
                  _repo.updateSchoolActive(id: s.id, active: true),
            ),
            child: const ListTile(
              dense: true,
              leading: Icon(
                Icons.check_circle_outline,
                size: 18,
                color: AppColors.primary,
              ),
              title: Text('Activate'),
            ),
          ),
      ],
    );
  }

  Widget _studentsTab({required bool pickSchool}) {
    return _RecordsView<StudentRecord>(
      title: 'Students',
      leadingIcon: (_) => Icons.person_outline,
      columns: [
        RecordColumn('Admission No', (s) => s.admissionNumber),
        RecordColumn('Name', (s) => s.fullName),
        RecordColumn('Class', (s) => s.className ?? '-'),
        RecordColumn('Status', (s) => s.status),
      ],
      titleText: (s) => s.fullName,
      subtitleText: (s) => '${s.admissionNumber} · ${s.className ?? '-'}',
      trailing: (s) => AppBadge(
        status: s.status == 'active' ? AppStatus.success : AppStatus.pending,
        label: s.status,
      ),
      emptyText: 'No students yet. Register the first student below.',
      fetch: ({int page = 1}) => _repo.fetchStudents(page: page, perPage: 50),
      showAdd: () => showStudentForm(
        context,
        _repo,
        pickSchool: pickSchool,
        schools: _schools,
      ),
      showBulk: () => showBulkUploadSheet(
        context,
        _repo,
        kind: BulkKind.student,
        pickSchool: pickSchool,
        schools: _schools,
      ),
      rowActions: (s) => [
        PopupMenuItem<Future<void> Function()>(
          value: () async => showStudentForm(
            context,
            _repo,
            pickSchool: pickSchool,
            schools: _schools,
            existing: s,
          ),
          child: const ListTile(
            dense: true,
            leading: Icon(Icons.edit_outlined, size: 18),
            title: Text('Edit'),
          ),
        ),
      ],
    );
  }

  Widget _usersTab() {
    return _RecordsView<SchoolUserRecord>(
      title: 'Users',
      leadingIcon: (_) => Icons.group_outlined,
      columns: [
        RecordColumn('Name', (u) => u.name),
        RecordColumn('Email', (u) => u.email),
        RecordColumn('Role', (u) => u.role),
        RecordColumn('Status', (u) => u.status),
      ],
      titleText: (u) => u.name,
      subtitleText: (u) => '${u.email} · ${u.role}',
      trailing: (u) => AppBadge(
        status: u.status == 'active' ? AppStatus.success : AppStatus.pending,
        label: u.status,
      ),
      emptyText: 'No users yet. Register the first user below.',
      fetch: ({int page = 1}) =>
          _repo.fetchSchoolUsers(page: page, perPage: 50),
      showAdd: () => showSchoolUserForm(context, _repo),
      showBulk: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bulk upload is available for regions, schools and students.',
            ),
          ),
        );
      },
      rowActions: (u) => [
        PopupMenuItem<Future<void> Function()>(
          value: () async => showSchoolUserForm(context, _repo, existing: u),
          child: const ListTile(
            dense: true,
            leading: Icon(Icons.edit_outlined, size: 18),
            title: Text('Edit'),
          ),
        ),
        if (u.status == 'active')
          PopupMenuItem<Future<void> Function()>(
            value: () => _confirmToggle(
              context,
              label: 'Deactivate',
              color: AppColors.danger,
              onConfirm: () async => _repo.deactivateSchoolUser(id: u.id),
            ),
            child: const ListTile(
              dense: true,
              leading: Icon(
                Icons.block_outlined,
                size: 18,
                color: AppColors.danger,
              ),
              title: Text('Deactivate'),
            ),
          )
        else
          PopupMenuItem<Future<void> Function()>(
            value: () => _confirmToggle(
              context,
              label: 'Activate',
              onConfirm: () async => _repo.activateSchoolUser(id: u.id),
            ),
            child: const ListTile(
              dense: true,
              leading: Icon(
                Icons.check_circle_outline,
                size: 18,
                color: AppColors.primary,
              ),
              title: Text('Activate'),
            ),
          ),
      ],
    );
  }
}

/// Generic, self-contained records tab: header with Add / Bulk Upload actions,
/// a responsive [RecordList], pull-to-refresh and load-more pagination.
class _RecordsView<T> extends StatefulWidget {
  const _RecordsView({
    required this.title,
    required this.fetch,
    required this.showAdd,
    required this.showBulk,
    required this.columns,
    required this.titleText,
    this.subtitleText,
    this.trailing,
    this.rowActions,
    this.leadingIcon,
    this.emptyText,
    this.onReload,
  });

  final String title;
  final Future<PaginatedRecords<T>> Function({int page}) fetch;
  final Future<bool> Function() showAdd;
  final Future<void> Function() showBulk;
  final List<RecordColumn<T>> columns;
  final String Function(T) titleText;
  final String Function(T)? subtitleText;
  final Widget Function(T)? trailing;

  /// Row actions rendered behind a "more" menu; after an action completes the
  /// list reloads.
  final List<PopupMenuEntry<Future<void> Function()>> Function(T)? rowActions;

  final IconData Function(T)? leadingIcon;
  final String? emptyText;

  /// Called before each page-1 reload so the parent can refresh dropdown data.
  final VoidCallback? onReload;

  @override
  State<_RecordsView<T>> createState() => _RecordsViewState<T>();
}

class _RecordsViewState<T> extends State<_RecordsView<T>> {
  List<T> _items = const [];
  int _page = 1;
  int _total = 0;
  bool _hasMore = false;
  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1, bool silent = false}) async {
    if (page == 1) {
      widget.onReload?.call();
    }
    if (!silent) {
      setState(() {
        _loading = page == 1 && _items.isEmpty;
        _error = null;
      });
    }
    try {
      final result = await widget.fetch(page: page);
      if (!mounted) return;
      setState(() {
        if (page == 1) {
          _items = result.data;
        } else {
          _items = [..._items, ...result.data];
        }
        _page = result.currentPage;
        _total = result.total;
        _hasMore = _page < result.lastPage;
        _loading = false;
        _refreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _refreshing = false;
        if (_items.isEmpty) {
          _error = e.toString();
        }
      });
    }
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await _load(page: 1, silent: true);
  }

  Future<void> _add() async {
    final saved = await widget.showAdd();
    if (saved) {
      await _refresh();
    }
  }

  Future<void> _bulk() async {
    await widget.showBulk();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceLight,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xxs,
              AppSpacing.md,
              AppSpacing.md,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  if (_refreshing && _items.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.primary,
                      backgroundColor: AppColors.surfaceLight,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (_error != null && _items.isEmpty)
                    _buildError(context)
                  else
                    _buildBody(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _total > 0 ? '$_total ${widget.title.toLowerCase()}' : widget.title,
          style: AppTypography.titleText(context).copyWith(fontSize: 15),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            OutlinedButton.icon(
              onPressed: _bulk,
              icon: const Icon(Icons.upload_file_outlined, size: 16),
              label: const Text('Bulk Upload'),
            ),
            FilledButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecordList<T>(
          items: _items,
          columns: widget.columns,
          title: widget.titleText,
          subtitle: widget.subtitleText,
          trailing: widget.trailing,
          actionItems: widget.rowActions,
          onAction: () => _refresh(),
          leadingIcon: widget.leadingIcon,
          emptyText: widget.emptyText ?? 'No records yet.',
        ),
        if (_hasMore)
          Center(
            child: TextButton(
              onPressed: () => _load(page: _page + 1),
              child: const Text('Load more'),
            ),
          ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Failed to load ${widget.title.toLowerCase()}',
              style: AppTypography.bodyText(context)
                  .copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
