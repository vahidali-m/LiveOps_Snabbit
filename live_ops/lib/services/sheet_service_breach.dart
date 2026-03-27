import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/breach_model.dart';

class BreachService {
  static const String csvUrl =
      'https://docs.google.com/spreadsheets/d/1ujTe80AtniAdLrLUXG6V5mQGKC829Wek_PirLFLzpNA/export?format=csv&gid=85731508';

  static Future<List<Breach>> fetchBreaches() async {
  final response = await http.get(Uri.parse(csvUrl));

  final rows = const LineSplitter().convert(response.body);
  List<Breach> list = [];

  for (int i = 1; i < rows.length; i++) {
    final cols = rows[i].split(',');

    if (cols.length < 14) continue;

    final status = cols[8];

    if (status.contains("NOT_CHECKED_IN")) {
      final mins = _extractMinutes(status);

      if (mins >= 30) {
        list.add(Breach(
          region: cols[4],
          cluster: cols[5],
          hood: cols[6],
          jobId: cols[2],
          runnerName: cols[9],
          acceptedAt: cols[13],
          minutes: mins,
        ));
      }
    }
  }


    return list;
  }

  static int _extractMinutes(String text) {
    final match = RegExp(r'(\d+)').firstMatch(text);
    return match != null ? int.parse(match.group(1)!) : 0;
  }
}