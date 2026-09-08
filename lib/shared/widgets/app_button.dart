import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Visual style of an [AppButton].
enum AppButtonVariant {
  /// Green primary CTA (default).
  primary,

  /// Teal secondary action.
  secondary,

  /// Quiet, bordered action.
  outlined,

  /// Borderless text action.
  text,

  /// Destructive action.
  danger,
}

/// The primary button component for the design system.
///
/// Centralizes button theming so screens never style buttons ad-hoc. Supports
/// a built-in busy state (spinner + disabled) and an optional leading icon.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.isDense = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    final bool busy = isLoading;
    final void Function()? action = busy ? null : onPressed;

    final Widget child = busy
        ? const _BusyIndicator()
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );

    final Widget content = SizedBox(
      height: isDense ? 36 : 44,
      width: fullWidth ? double.infinity : null,
      child: Center(child: child),
    );

    return switch (variant) {
      AppButtonVariant.primary => _generic(
        context,
        action,
        content,
        background: AppColors.primary,
        foreground: const Color(0xFF101A05),
        outlined: false,
      ),
      AppButtonVariant.secondary => _generic(
        context,
        action,
        content,
        background: AppColors.secondary,
        foreground: const Color(0xFF00211C),
        outlined: false,
      ),
      AppButtonVariant.danger => _generic(
        context,
        action,
        content,
        background: AppColors.danger,
        foreground: const Color(0xFF40010C),
        outlined: false,
      ),
      AppButtonVariant.outlined => _generic(
        context,
        action,
        content,
        background: Colors.transparent,
        foreground: Theme.of(context).colorScheme.onSurface,
        outlined: true,
      ),
      AppButtonVariant.text => _generic(
        context,
        action,
        content,
        background: Colors.transparent,
        foreground: AppColors.primary,
        outlined: false,
      ),
    };
  }

  Widget _generic(
    BuildContext context,
    VoidCallback? action,
    Widget child, {
    required Color background,
    required Color foreground,
    required bool outlined,
  }) {
    if (variant == AppButtonVariant.text) {
      return TextButton(
        onPressed: action,
        style: TextButton.styleFrom(foregroundColor: foreground),
        child: child,
      );
    }

    if (outlined) {
      return OutlinedButton(
        onPressed: action,
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: BorderSide(
            color: action != null ? AppColors.border : AppColors.surfaceLight,
          ),
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: action,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: AppColors.surfaceLight,
        disabledForegroundColor: AppColors.textMuted,
        elevation: 0,
      ),
      child: child,
    );
  }
}

class _BusyIndicator extends StatelessWidget {
  const _BusyIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
