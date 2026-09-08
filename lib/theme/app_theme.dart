import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Material 3 theme for the PTA Collect design system.
///
/// `AppTheme.dark` is the default "dark fintech dashboard" look; a matching
/// light theme is provided for completeness. Every value is derived from the
/// centralized tokens so screens and widgets never deal in raw colours.
class AppTheme {
  const AppTheme._();

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final Color background = isDark
        ? AppColors.background
        : const Color(0xFFF6F8F8);
    final Color surface = isDark ? AppColors.surface : Colors.white;
    final Color surfaceLight = isDark
        ? AppColors.surfaceLight
        : const Color(0xFFEEF2F1);
    final Color textPrimary = isDark
        ? AppColors.textPrimary
        : const Color(0xFF10201E);
    final Color textSecondary = isDark
        ? AppColors.textSecondary
        : const Color(0xFF41504E);
    final Color textMuted = isDark
        ? AppColors.textMuted
        : const Color(0xFF6D7C79);
    final Color border = isDark ? AppColors.border : const Color(0xFFD5DEDC);

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: const Color(0xFF101A05),
      secondary: AppColors.secondary,
      onSecondary: const Color(0xFF00211C),
      error: AppColors.danger,
      onError: const Color(0xFF40010C),
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceLight,
      onSurfaceVariant: textMuted,
      outline: border,
      outlineVariant: border,
    );

    final TextTheme textTheme = AppTypography.buildTextTheme(brightness);

    final InputDecorationTheme inputDecoration = InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: textTheme.bodyMedium!.copyWith(color: textMuted),
      labelStyle: textTheme.bodyMedium!.copyWith(color: textSecondary),
      prefixIconColor: textMuted,
      suffixIconColor: textMuted,
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
      ),
    );

    final ElevatedButtonThemeData elevated = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: const Color(0xFF101A05),
        disabledBackgroundColor: AppColors.surfaceLight,
        disabledForegroundColor: textMuted,
        minimumSize: const Size(64, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        textStyle: textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w700),
      ),
    );

    final OutlinedButtonThemeData outlined = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: BorderSide(color: border),
        disabledForegroundColor: textMuted,
        minimumSize: const Size(64, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        textStyle: textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w600),
      ),
    );

    final TextButtonThemeData textButton = TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w600),
      ),
    );

    final CardThemeData cardTheme = CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: border),
      ),
    );

    final DialogThemeData dialogTheme = DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: border),
      ),
    );

    final AppBarTheme appBarTheme = AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge!.copyWith(color: textPrimary),
      iconTheme: IconThemeData(color: textPrimary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      dividerColor: border,
      inputDecorationTheme: inputDecoration,
      elevatedButtonTheme: elevated,
      outlinedButtonTheme: outlined,
      textButtonTheme: textButton,
      cardTheme: cardTheme,
      dialogTheme: dialogTheme,
      appBarTheme: appBarTheme,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(surfaceLight),
        dataRowColor: WidgetStatePropertyAll(surface),
        headingTextStyle: textTheme.labelLarge!.copyWith(color: textSecondary),
        dataTextStyle: textTheme.bodyMedium!.copyWith(color: textPrimary),
        headingRowHeight: 48,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 56,
        columnSpacing: 24,
        dividerThickness: 1,
        horizontalMargin: AppSpacing.md,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: textTheme.bodyMedium!.copyWith(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
    );
  }
}
