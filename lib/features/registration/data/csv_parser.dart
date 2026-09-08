/// Minimal RFC-4180 style CSV parser used by the bulk-upload sheets.
///
/// Supports quoted fields containing commas and escaped double quotes. The
/// first row is treated as headers; every following row becomes a map keyed
/// by the (trimmed, lower-cased, space->underscore) header value.
class CsvParser {
  const CsvParser._();

  static List<Map<String, String>> parse(String source) {
    final rows = _splitRows(source);

    final rowsOut = <List<String>>[];
    for (final row in rows) {
      final clean = row.trim();
      if (clean.isEmpty) continue;
      rowsOut.add(_splitRow(clean));
    }

    if (rowsOut.isEmpty) return const [];

    final headers = rowsOut.first.map(_normalizeHeader).toList();

    return rowsOut.skip(1).map((cells) {
      final map = <String, String>{};
      for (var i = 0; i < headers.length; i++) {
        final value = i < cells.length ? cells[i] : '';
        if (value.trim().isNotEmpty) {
          map[headers[i]] = value.trim();
        }
      }
      return map;
    }).toList();
  }

  static String _normalizeHeader(String header) {
    return header.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  /// Splits content into logical rows, handling quoted newlines. Quote
  /// characters are preserved verbatim (including escaped `""`) so
  /// [_splitRow] can decode each field exactly once.
  static List<String> _splitRows(String source) {
    final rows = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < source.length; i++) {
      final char = source[i];
      if (char == '"') {
        if (inQuotes && i + 1 < source.length && source[i + 1] == '"') {
          buffer.write('""');
          i++;
        } else {
          inQuotes = !inQuotes;
          buffer.write(char);
        }
      } else if (char == '\n' && !inQuotes) {
        rows.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    if (buffer.toString().trim().isNotEmpty) {
      rows.add(buffer.toString());
    }
    return rows;
  }

  /// Splits one logical row into cells, handling quoted commas.
  static List<String> _splitRow(String row) {
    final cells = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < row.length; i++) {
      final char = row[i];
      if (char == '"') {
        if (inQuotes && i + 1 < row.length && row[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        cells.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    cells.add(buffer.toString());
    return cells;
  }
}
