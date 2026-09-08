import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Identifies which shell content a sidebar item maps to, so the shell can
/// route correctly even when the visible list varies by role.
enum SidebarKind {
  dashboard,
  platformOverview,
  schoolManagement,
  platformPayments,
  reconciliation,
  registration,
}

/// A single destination in the app's navigation sidebar.
class SidebarItem {
  const SidebarItem({
    required this.label,
    required this.icon,
    this.kind = SidebarKind.dashboard,
    this.requiresSuperAdmin = false,
  });

  final String label;
  final IconData icon;
  final SidebarKind kind;

  /// When true the item is only shown to super admins.
  final bool requiresSuperAdmin;
}

void _noop(int index) {}

/// Collapsible branded navigation rail for the PTA Collect shell.
///
/// Full width on wide screens (label + icon); collapses to an icon-only rail
/// on narrow screens to preserve space for the content column.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onSelected = _noop,
    this.userName,
    this.userRoleLabel,
    this.onLogout,
    this.collapsed = false,
  });

  final List<SidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String? userName;
  final String? userRoleLabel;
  final VoidCallback? onLogout;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: collapsed ? 72 : 260,
      color: AppColors.sidebar,
      child: Column(
        children: [
          _buildBrand(context),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _buildItem(context, index, items[index]),
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildBrand(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: AppColors.primary,
            size: 28,
          ),
          if (!collapsed) ...[
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'PTA Collect',
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headingText(context)
                    .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, SidebarItem item) {
    final selected = index == selectedIndex;
    return Tooltip(
      message: collapsed ? item.label : '',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 2,
        ),
        child: InkWell(
          onTap: () => onSelected(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.surfaceLight : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (selected)
                  Container(
                    width: 3,
                    height: 20,
                    margin: EdgeInsets.only(
                      right: collapsed ? 0 : AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Icon(
                  item.icon,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyText(context).copyWith(
                        color: selected
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceLight,
            child: Icon(Icons.person, size: 18, color: AppColors.textMuted),
          ),
          if (!collapsed) ...[
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName ?? 'User',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelText(context)
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  Text(
                    userRoleLabel ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelText(context)
                        .copyWith(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (onLogout != null)
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.textMuted),
                tooltip: 'Sign out',
                onPressed: onLogout,
              ),
          ] else if (onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.textMuted),
              tooltip: 'Sign out',
              onPressed: onLogout,
            ),
        ],
      ),
    );
  }
}
