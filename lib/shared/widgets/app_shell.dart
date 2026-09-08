import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/reconciliation/data/reconciliation_repository.dart';
import '../../features/reconciliation/presentation/reconciliation_dashboard_screen.dart';
import '../../features/registration/presentation/registration_screen.dart';
import '../../features/super_admin/presentation/platform_payments_screen.dart';
import '../../features/super_admin/presentation/school_management_screen.dart';
import '../../features/super_admin/presentation/super_admin_dashboard_screen.dart';
import '../../networking/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'app_sidebar.dart';

/// Wraps all authenticated screens in a sidebar layout and switches content
/// based on the selected navigation item. Navigation items are filtered by
/// the signed-in user's role (super admins see platform-wide destinations).
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.apiClient,
    this.userRole,
    this.userName,
    this.onLogout,
  });

  final ApiClient apiClient;
  final String? userRole;
  final String? userName;
  final VoidCallback? onLogout;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selected = 0;

  bool get _isSuperAdmin => widget.userRole == 'super_admin';

  List<SidebarItem> get _items => [
    const SidebarItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      kind: SidebarKind.dashboard,
    ),
    const SidebarItem(
      label: 'Registration',
      icon: Icons.app_registration_outlined,
      kind: SidebarKind.registration,
    ),
    if (_isSuperAdmin)
      const SidebarItem(
        label: 'Platform Overview',
        icon: Icons.insights_outlined,
        kind: SidebarKind.platformOverview,
        requiresSuperAdmin: true,
      ),
    if (_isSuperAdmin)
      const SidebarItem(
        label: 'School Management',
        icon: Icons.school_outlined,
        kind: SidebarKind.schoolManagement,
        requiresSuperAdmin: true,
      ),
    if (_isSuperAdmin)
      const SidebarItem(
        label: 'Platform Payments',
        icon: Icons.payments_outlined,
        kind: SidebarKind.platformPayments,
        requiresSuperAdmin: true,
      ),
    if (_isSuperAdmin)
      const SidebarItem(
        label: 'Reconciliation',
        icon: Icons.sync_alt,
        kind: SidebarKind.reconciliation,
        requiresSuperAdmin: true,
      ),
  ];

  Widget _buildContent(SidebarItem item) {
    switch (item.kind) {
      case SidebarKind.dashboard:
        return DashboardScreen(apiClient: widget.apiClient);
      case SidebarKind.registration:
        return RegistrationScreen(
          apiClient: widget.apiClient,
          isSuperAdmin: _isSuperAdmin,
        );
      case SidebarKind.platformOverview:
        return SuperAdminDashboardScreen(apiClient: widget.apiClient);
      case SidebarKind.schoolManagement:
        return SchoolManagementScreen(apiClient: widget.apiClient);
      case SidebarKind.platformPayments:
        return PlatformPaymentsScreen(apiClient: widget.apiClient);
      case SidebarKind.reconciliation:
        return ReconciliationDashboardScreen(
          repository: ReconciliationRepository(widget.apiClient),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (_selected >= items.length) {
      _selected = 0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Wide layout: full sidebar. Narrow layout: collapsed icon rail.
        final collapsed = constraints.maxWidth < 720;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSidebar(
                items: items,
                selectedIndex: _selected,
                onSelected: (index) => setState(() => _selected = index),
                userName: widget.userName,
                userRoleLabel: _roleLabel(widget.userRole),
                onLogout: widget.onLogout,
                collapsed: collapsed,
              ),
              VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(
                    key: ValueKey(_selected),
                    child: Padding(
                      padding: collapsed
                          ? const EdgeInsets.only(
                              top: AppSpacing.xs,
                              bottom: AppSpacing.xs,
                              right: AppSpacing.xs,
                            )
                          : const EdgeInsets.only(
                              top: AppSpacing.md,
                              bottom: AppSpacing.md,
                              right: AppSpacing.md,
                            ),
                      child: _buildContent(_items[_selected]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _roleLabel(String? role) {
    return switch (role) {
      'super_admin' => 'Super Admin',
      'school_admin' => 'School Admin',
      'finance' => 'PTA Treasurer / Finance',
      'staff' => 'PTA Staff',
      'parent' => 'Parent',
      _ => null,
    };
  }
}
