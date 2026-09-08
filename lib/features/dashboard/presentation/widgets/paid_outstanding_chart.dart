import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/dashboard_models.dart';

class PaidOutstandingChart extends StatelessWidget {
  const PaidOutstandingChart({super.key, required this.data});

  final PaidVsOutstanding data;

  @override
  Widget build(BuildContext context) {
    final total = data.paidPesewas + data.outstandingPesewas;
    return AppCard(
      title: 'Paid vs Outstanding',
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        height: 180,
        child: total == 0
            ? Center(
                child: Text(
                  'No data',
                  style: AppTypography.bodyText(context)
                      .copyWith(color: AppColors.textMuted),
                ),
              )
            : Row(
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CustomPaint(
                      painter: _DonutPainter(
                        paid: data.paidPesewas,
                        outstanding: data.outstandingPesewas,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatPesewas(total),
                              style: AppTypography.titleText(context).copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Total',
                              style: AppTypography.labelText(context).copyWith(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Legend(
                          color: AppColors.primary,
                          label: 'Paid',
                          value: _formatPesewas(data.paidPesewas),
                          percentage: total > 0
                              ? (data.paidPesewas / total * 100)
                                    .toStringAsFixed(0)
                              : '0',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _Legend(
                          color: AppColors.warning,
                          label: 'Outstanding',
                          value: _formatPesewas(data.outstandingPesewas),
                          percentage: total > 0
                              ? (data.outstandingPesewas / total * 100)
                                    .toStringAsFixed(0)
                              : '0',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
    required this.percentage,
  });

  final Color color;
  final String label;
  final String value;
  final String percentage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: AppTypography.labelText(context)
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        Text(
          '$percentage%',
          style: AppTypography.labelText(context)
              .copyWith(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.labelText(
            context,
          ).copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.paid, required this.outstanding});

  final int paid;
  final int outstanding;

  @override
  void paint(Canvas canvas, Size size) {
    final total = paid + outstanding;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const stroke = 14.0;

    final paidAngle = (paid / total) * 2 * pi;

    final bgPaint = Paint()
      ..color = AppColors.warning
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final paidPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi,
      false,
      bgPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      paidAngle,
      false,
      paidPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.paid != paid || old.outstanding != outstanding;
}

String _formatPesewas(int pesewas) {
  final ghc = pesewas / 100;
  if (ghc >= 1000) return 'GH₵${(ghc / 1000).toStringAsFixed(1)}k';
  return 'GH₵${ghc.toStringAsFixed(0)}';
}
