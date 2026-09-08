import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ptacollect_mobile/shared/widgets/app_sidebar.dart';
import 'package:ptacollect_mobile/theme/app_colors.dart';
import 'package:ptacollect_mobile/theme/app_theme.dart';

void main() {
  group('AppSidebar', () {
    final items = [
      const SidebarItem(label: 'Dashboard', icon: Icons.dashboard_outlined),
      const SidebarItem(
        label: 'Reconciliation',
        icon: Icons.sync_alt,
        requiresSuperAdmin: true,
      ),
    ];

    Widget wrap(Widget child) => MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );

    testWidgets('renders brand and item labels', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppSidebar(
            items: [
              SidebarItem(label: 'Dashboard', icon: Icons.dashboard_outlined),
            ],
            selectedIndex: 0,
          ),
        ),
      );

      expect(find.text('PTA Collect'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('highlights the selected item', (tester) async {
      await tester.pumpWidget(
        wrap(AppSidebar(items: items, selectedIndex: 1, onSelected: (_) {})),
      );

      final selectedIcon = tester.widget<Icon>(find.byIcon(Icons.sync_alt));
      expect(selectedIcon.color, AppColors.primary);
    });

    testWidgets('fires onSelected when an item is tapped', (tester) async {
      int selected = -1;
      await tester.pumpWidget(
        wrap(
          AppSidebar(
            items: items,
            selectedIndex: 0,
            onSelected: (index) => selected = index,
          ),
        ),
      );

      await tester.tap(find.text('Reconciliation'));
      expect(selected, 1);
    });

    testWidgets('shows user name and role label', (tester) async {
      await tester.pumpWidget(
        wrap(
          AppSidebar(
            items: items,
            selectedIndex: 0,
            onSelected: (_) {},
            userName: 'Demo Admin',
            userRoleLabel: 'School Admin',
            onLogout: () {},
          ),
        ),
      );

      expect(find.text('Demo Admin'), findsOneWidget);
      expect(find.text('School Admin'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('collapsed mode shows icons only', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppSidebar(
            items: [
              SidebarItem(label: 'Dashboard', icon: Icons.dashboard_outlined),
            ],
            selectedIndex: 0,
            collapsed: true,
          ),
        ),
      );

      expect(find.text('PTA Collect'), findsNothing);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget);
    });
  });
}
