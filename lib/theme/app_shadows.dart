import 'package:flutter/material.dart';

/// Shared shadow tokens for the design system.
///
/// The design language uses subtle, restrained shadows — never heavy drop
/// shadows or excessive elevation. Prefer borders on cards and keep shadows
/// for floating elements, dialogs and popovers.
@immutable
class AppShadows {
  const AppShadows._();

  static List<BoxShadow> get subtle => const [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static List<BoxShadow> get elevated => const [
    BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> get dialog => const [
    BoxShadow(color: Color(0x3D000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}
