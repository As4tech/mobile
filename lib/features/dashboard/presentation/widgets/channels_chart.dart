import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../data/dashboard_models.dart';

class ChannelsChart extends StatelessWidget {
  const ChannelsChart({super.key, required this.data});

  final List<ChannelData> data;

  static const _channelColors = <String, Color>{
    'card': AppColors.blue,
    'mobile_money': AppColors.secondary,
    'bank_transfer': AppColors.warning,
    'ussd': AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    final maxVal = data.isEmpty
        ? 0
        : data.map((d) => d.totalPesewas).reduce((a, b) => a > b ? a : b);
    return AppCard(
      title: 'Payment Channels',
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        height: 200,
        child: data.isEmpty
            ? Center(
                child: Text(
                  'No data',
                  style: AppTypography.bodyText(context)
                      .copyWith(color: AppColors.textMuted),
                ),
              )
            : Column(
                children: [
                  for (final d in data)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              d.channel.replaceAll('_', ' '),
                              style: AppTypography.labelText(context)
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final fraction = maxVal > 0
                                    ? d.totalPesewas / maxVal
                                    : 0.0;
                                return Stack(
                                  children: [
                                    Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    Container(
                                      height: 20,
                                      width: constraints.maxWidth * fraction,
                                      decoration: BoxDecoration(
                                        color:
                                            _channelColors[d.channel] ??
                                            AppColors.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 80,
                            child: Text(
                              _formatPesewas(d.totalPesewas),
                              style: AppTypography.labelText(context).copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.end,
                            ),
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

String _formatPesewas(int pesewas) {
  final ghc = pesewas / 100;
  if (ghc >= 1000) return 'GH₵${(ghc / 1000).toStringAsFixed(1)}k';
  return 'GH₵${ghc.toStringAsFixed(0)}';
}
