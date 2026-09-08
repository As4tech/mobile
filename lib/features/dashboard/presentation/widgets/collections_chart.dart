import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/dashboard_models.dart';

class CollectionsChart extends StatelessWidget {
  const CollectionsChart({super.key, required this.data});

  final List<DailyCollection> data;

  @override
  Widget build(BuildContext context) {
    final maxVal = data.isEmpty
        ? 0
        : data.map((d) => d.totalPesewas).reduce(max);
    return AppCard(
      title: 'Collections Over Time',
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        height: 220,
        child: data.isEmpty
            ? Center(
                child: Text(
                  'No data',
                  style: AppTypography.bodyText(context)
                      .copyWith(color: AppColors.textMuted),
                ),
              )
            : CustomPaint(
                size: const Size(double.infinity, 220),
                painter: _LineChartPainter(data: data, maxVal: maxVal),
              ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.data, required this.maxVal});

  final List<DailyCollection> data;
  final int maxVal;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || maxVal == 0) return;

    final padding = const EdgeInsets.fromLTRB(50, 16, 16, 30);
    final chartW = size.width - padding.left - padding.right;
    final chartH = size.height - padding.top - padding.bottom;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.3),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, padding.top, size.width, chartH));

    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = padding.left + (i / (data.length - 1)) * chartW;
      final y = padding.top + chartH - (data[i].totalPesewas / maxVal) * chartH;
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, padding.top + chartH);
    fillPath.lineTo(points.first.dx, padding.top + chartH);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < points.length; i += max(1, points.length ~/ 5)) {
      textPainter.text = TextSpan(
        text: data[i].date.substring(5),
        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
      ) as TextSpan?;
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(points[i].dx - textPainter.width / 2, padding.top + chartH + 8),
      );
    }

    textPainter.text = TextSpan(
      text: _formatPesewas(maxVal),
      style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
    ) as TextSpan?;
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, padding.top - 2));
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.data != data || old.maxVal != maxVal;
}

String _formatPesewas(int pesewas) {
  final ghc = pesewas / 100;
  if (ghc >= 1000) return 'GH₵${(ghc / 1000).toStringAsFixed(1)}k';
  return 'GH₵${ghc.toStringAsFixed(0)}';
}
