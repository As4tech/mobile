import 'package:flutter/material.dart';

/// Centralized color palette for the PTA Collect design system.
///
/// Raw hex values are defined in exactly one place. Screens and widgets must
/// reference these tokens and never hard-code `Color(...)` values directly.
///
/// Design language: dark fintech dashboard with a near-black teal background,
/// a green primary (main CTA), a teal secondary and restrained status colors.
@immutable
class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------------------
  // Surfaces
  // ---------------------------------------------------------------------------
  static const Color background = Color(0xFF111A1A);
  static const Color sidebar = Color(0xFF162222);
  static const Color surface = Color(0xFF202E2E);
  static const Color surfaceLight = Color(0xFF2A3A3A);
  static const Color border = Color(0xFF455656);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE1E8E6);
  static const Color textMuted = Color(0xFFB8C5C2);

  // ---------------------------------------------------------------------------
  // Brand & feedback
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFFA6E83A);
  static const Color secondary = Color(0xFF29D9BE);
  static const Color warning = Color(0xFFFFC857);
  static const Color danger = Color(0xFFFF6B7A);
  static const Color blue = Color(0xFF63AEFF);
}

/// A small set of semantic variants used to colour status badges, indicators
/// and table rows consistently across the app.
enum AppStatus {
  /// Successful — positive/payable states.
  success(AppColors.primary),

  /// Pending / awaiting action.
  pending(AppColors.warning),

  /// Failed / rejected states.
  failed(AppColors.danger),

  /// In-progress / processing / informational emphasis.
  processing(AppColors.blue),

  /// Neutral / informational.
  information(AppColors.blue);

  const AppStatus(this.color);

  final Color color;
}
