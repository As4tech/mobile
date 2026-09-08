import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptacollect_mobile/theme/app_theme.dart';
import 'package:ptacollect_mobile/theme/app_colors.dart';
import 'package:ptacollect_mobile/shared/widgets/app_button.dart';
import 'package:ptacollect_mobile/shared/widgets/app_card.dart';
import 'package:ptacollect_mobile/shared/widgets/app_badge.dart';

void main() {
  group('Design system', () {
    testWidgets('AppTheme.dark has correct scaffold background', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const Scaffold()),
      );
      final ctx = tester.element(find.byType(Scaffold));
      expect(Theme.of(ctx).scaffoldBackgroundColor, AppColors.background);
    });

    testWidgets('AppButton renders label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: AppButton(label: 'Pay Now', onPressed: () {}),
          ),
        ),
      );
      expect(find.text('Pay Now'), findsOneWidget);
    });

    testWidgets('AppCard renders title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: AppCard(title: 'Revenue', child: const Text('GH₵ 10,000')),
          ),
        ),
      );
      expect(find.text('Revenue'), findsOneWidget);
    });

    testWidgets('AppBadge renders label with status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: AppBadge(status: AppStatus.success, label: 'paid'),
          ),
        ),
      );
      expect(find.text('paid'), findsOneWidget);
    });
  });
}
