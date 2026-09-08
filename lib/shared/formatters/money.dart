import 'package:intl/intl.dart';

/// Centralised Ghana Cedi money formatting for minor-unit (pesewas) integers.
///
/// Every screen must go through this helper so that currency formatting is
/// identical across the app (symbol, grouping, decimals, abbreviation).
class MoneyFormatter {
  const MoneyFormatter._();

  static const String cedi = 'GH₵';

  static final NumberFormat _full = NumberFormat.currency(
    symbol: cedi,
    decimalDigits: 2,
  );

  /// `120000` -> `GH₵1,200.00`. Use in tables, receipts and detail views.
  static String formatFull(int pesewas) => _full.format(pesewas / 100);

  /// Abbreviates thousands: `200000` -> `GH₵2.0k`; otherwise `GH₵12.00`.
  /// Use in stat cards and chart labels where width is limited.
  static String formatCompact(int pesewas) {
    final ghc = pesewas / 100;
    if (ghc >= 1000) {
      return '$cedi${(ghc / 1000).toStringAsFixed(1)}k';
    }
    return '$cedi${ghc.toStringAsFixed(2)}';
  }
}
