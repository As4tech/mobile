import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// A compact status pill.
///
/// Coloured by an [AppStatus] so the whole app stays consistent: successful →
/// primary, pending → warning, failed → danger, processing/information → blue.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.status = AppStatus.information,
    this.fill = true,
    this.dot = true,
    this.icon,
  });

  final String label;
  final AppStatus status;
  final bool fill;

  /// Show a small leading colour dot (default true).
  final bool dot;

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color color = status.color;
    final Color bg = fill ? color.withValues(alpha: 0.16) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: fill ? color.withValues(alpha: 0.5) : color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelText(context).copyWith(
              color: fill ? color : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
