import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// A bordered surface card used across dashboards.
///
/// Clean, flat and restrained: a subtle 1px border and the surface background
/// (no heavy shadow). Optionally carries a header row with a title and an
/// action.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.child,
    this.title,
    this.subtitle,
    this.action,
    this.padding = AppSpacing.card,
    this.onTap,
    this.elevated = false,
  }) : assert(child != null);

  final Widget? child;
  final String? title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || action != null) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(title!, style: AppTypography.titleText(context)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.labelText(context)
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        ?child,
      ],
    );

    final Widget content = InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgAll,
      child: Padding(padding: padding, child: body),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
        boxShadow: elevated ? AppShadows.subtle : null,
      ),
      child: content,
    );
  }
}
