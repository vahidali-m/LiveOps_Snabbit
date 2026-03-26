import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ops_data.dart';

class SheetService {
static const String sheetId = '1eg7tirdn1em-g8LaNngNhKDneezoYlL1nELE7nDR-GM';
  static const String apiKey = 'AIzaSyDuVWLA4dYQShJHMq2iqNedF4S1XIjPfCM';

  static const String range = 'Sheet1!A2:Z';

  static Future<List<JobRow>> fetchData() async {
  final url =
  'https://sheets.googleapis.com/v4/spreadsheets/$sheetId/values/$range?key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch data: ${response.statusCode}');
  }

  final decoded = jsonDecode(response.body);

  // Safely get the 'values' key, default to empty list if null
  final List<dynamic> values = decoded['values'] ?? [];

  if (values.isEmpty) {
    return []; // No data
  }

  // Convert to List<List<dynamic>>
  final List<List<dynamic>> rows =
      values.map((e) => (e as List<dynamic>)).toList();

  // Assume first row is headers
  final headers = rows.first;

  // Remaining rows = actual data
  final dataRows = rows.skip(1);

  return dataRows.map((row) {
    final Map<String, dynamic> rowMap = {};

    for (int i = 0; i < headers.length; i++) {
      rowMap[headers[i]] = i < row.length ? row[i] : '';
    }

    return JobRow.fromJson(rowMap);
  }).toList();
}
}