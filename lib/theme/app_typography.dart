import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography system for the design system.
///
/// Strong typography is a core part of the "dark fintech dashboard" language:
/// bold, highly legible headings with generous line height, and compact but
/// readable body/label text. No raw `TextStyle` colors are used here — colours
/// are resolved from the active `ThemeData` so the same text scale works in
/// both light and dark modes.
@immutable
class AppTypography {
  const AppTypography._();

  // Font family & scale constants.
  static const String fontFamily = 'Roboto';
  static const double heading1 = 32;
  static const double heading2 = 26;
  static const double heading3 = 22;
  static const double title = 18;
  static const double subtitle = 16;
  static const double body = 14;
  static const double label = 12;
  static const double caption = 11;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  /// Build a [TextTheme] for the app, coloured from [Brightness]-aware scheme.
  static TextTheme buildTextTheme(Brightness brightness) {
    final scheme = brightness == Brightness.dark
        ? const ColorScheme.dark(
            primary: AppColors.primary,
            onSurface: AppColors.textPrimary,
          )
        : const ColorScheme.light();

    final s = TextStyle(fontFamily: fontFamily, color: scheme.onSurface);

    return TextTheme(
      displayLarge: s.copyWith(
        fontSize: heading1 * 1.5,
        fontWeight: bold,
        height: 1.1,
      ),
      displayMedium: s.copyWith(
        fontSize: heading1,
        fontWeight: bold,
        height: 1.15,
      ),
      displaySmall: s.copyWith(
        fontSize: heading2,
        fontWeight: bold,
        height: 1.2,
      ),
      headlineLarge: s.copyWith(
        fontSize: heading2,
        fontWeight: semibold,
        height: 1.2,
      ),
      headlineMedium: s.copyWith(
        fontSize: heading3,
        fontWeight: semibold,
        height: 1.25,
      ),
      headlineSmall: s.copyWith(
        fontSize: title,
        fontWeight: semibold,
        height: 1.3,
      ),
      titleLarge: s.copyWith(
        fontSize: title,
        fontWeight: semibold,
        height: 1.3,
      ),
      titleMedium: s.copyWith(
        fontSize: subtitle,
        fontWeight: medium,
        height: 1.35,
      ),
      titleSmall: s.copyWith(fontSize: body, fontWeight: medium, height: 1.35),
      bodyLarge: s.copyWith(fontSize: body, fontWeight: regular, height: 1.5),
      bodyMedium: s.copyWith(fontSize: body, fontWeight: regular, height: 1.5),
      bodySmall: s.copyWith(fontSize: label, fontWeight: regular, height: 1.45),
      labelLarge: s.copyWith(
        fontSize: label,
        fontWeight: semibold,
        letterSpacing: 0.2,
      ),
      labelMedium: s.copyWith(
        fontSize: caption,
        fontWeight: medium,
        letterSpacing: 0.4,
      ),
      labelSmall: s.copyWith(
        fontSize: caption,
        fontWeight: medium,
        letterSpacing: 0.4,
      ),
    );
  }

  // Convenience styles layered on top of an existing [TextTheme].
  static TextStyle displayText(BuildContext context) =>
      Theme.of(context).textTheme.displayMedium!;

  static TextStyle headingText(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!;

  static TextStyle titleText(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!;

  static TextStyle bodyText(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;

  static TextStyle labelText(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge!;
}
