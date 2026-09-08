import 'package:flutter/widgets.dart';

/// Spacing scale, built on a consistent 8pt grid.
///
/// Use these tokens for `EdgeInsets`, `SizedBox` and margin/padding values so
/// spacing stays uniform across the app (see `docs/architecture`).
@immutable
class AppSpacing {
  const AppSpacing._();

  // 8pt grid atoms.
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Common canned paddings.
  static const EdgeInsets page = EdgeInsets.all(md);
  static const EdgeInsets card = EdgeInsets.all(md);
  static const EdgeInsets cardDense = EdgeInsets.all(sm);
  static const EdgeInsets field = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
}
