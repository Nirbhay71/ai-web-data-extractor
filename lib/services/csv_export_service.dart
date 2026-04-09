import 'package:flutter/services.dart';
import 'dart:convert';

class CsvExportService {
  /// Converts list of maps to CSV string
  static String toCsv(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';

    final headers = data.first.keys.toList();
    final rows = <List<dynamic>>[headers];

    for (final row in data) {
      rows.add(headers.map((h) => row[h] ?? '').toList());
    }

    final csvLines = rows.map((row) {
      return row.map((cell) {
        final str = cell.toString();
        if (str.contains(',') || str.contains('"') || str.contains('\n')) {
          return '"${str.replaceAll('"', '""')}"';
        }
        return str;
      }).join(',');
    }).join('\n');

    return csvLines;
  }

  /// Copy CSV to clipboard (fallback for desktop where file_saver may not work)
  static Future<void> copyToClipboard(List<Map<String, dynamic>> data) async {
    final csv = toCsv(data);
    await Clipboard.setData(ClipboardData(text: csv));
  }

  /// Returns JSON string for copying
  static String toJson(List<Map<String, dynamic>> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
