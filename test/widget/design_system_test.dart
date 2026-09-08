import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptacollect_mobile/theme/app_theme.dart';
import 'package:ptacollect_mobile/theme/app_colors.dart';
import 'package:ptacollect_mobile/shared/widgets/app_button.dart';
import 'package:ptacollect_mobile/shared/widgets/app_card.dart';
import 'package:ptacollect_mobile/shared/widgets/app_badge.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );
  }

  group('AppTheme', () {
    testWidgets('dark scaffold background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const Scaffold()),
      );
      final ctx = tester.element(find.byType(Scaffold));
      expect(Theme.of(ctx).scaffoldBackgroundColor, AppColors.background);
    });
  });

  group('AppButton', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        wrapInApp(AppButton(label: 'Pay Now', onPressed: () {})),
      );
      expect(find.text('Pay Now'), findsOneWidget);
    });

    testWidgets('onPressed callback fires', (tester) async {
      var fired = false;
      await tester.pumpWidget(
        wrapInApp(AppButton(label: 'Click', onPressed: () => fired = true)),
      );
      await tester.tap(find.text('Click'));
      expect(fired, isTrue);
    });
  });

  group('AppCard', () {
    testWidgets('renders title and child', (tester) async {
      await tester.pumpWidget(
        wrapInApp(AppCard(title: 'Revenue', child: const Text('GH₵ 10,000'))),
      );
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('GH₵ 10,000'), findsOneWidget);
    });
  });

  group('AppBadge', () {
    testWidgets('success status', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const AppBadge(status: AppStatus.success, label: 'paid')),
      );
      expect(find.text('paid'), findsOneWidget);
    });

    testWidgets('pending status', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const AppBadge(status: AppStatus.pending, label: 'pending')),
      );
      expect(find.text('pending'), findsOneWidget);
    });

    testWidgets('failed status', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const AppBadge(status: AppStatus.failed, label: 'failed')),
      );
      expect(find.text('failed'), findsOneWidget);
    });

    testWidgets('information status', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const AppBadge(status: AppStatus.information, label: 'info')),
      );
      expect(find.text('info'), findsOneWidget);
    });
  });
}
