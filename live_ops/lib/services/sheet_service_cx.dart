import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:live_ops/models/cx_request_model.dart';

class CXService {
  // 🔥 YOUR APPS SCRIPT URL
  static const String webAppUrl =
      'https://script.google.com/macros/s/AKfycbxABITsPREHcmGyceoJbsXdaLTdzBuGPEMyXOEzyu-4GkYs5Jdq9pyEN_HnUEAoNQ1s2g/exec';

  // 🔥 YOUR SHEET4 CSV URL
  static const String csvUrl =
      'https://docs.google.com/spreadsheets/d/1ujTe80AtniAdLrLUXG6V5mQGKC829Wek_PirLFLzpNA/export?format=csv&gid=481938133';

  // ================= SUBMIT =================
  static Future<void> submitCX({
  required String jobId,
  required String region,
  required String reason,
  required String expertId,
}) async {
  var request = http.Request(
    'POST',
    Uri.parse(webAppUrl),
  );

  request.headers["Content-Type"] = "application/json";

  request.body = jsonEncode({
    "type": "cx",
    "jobId": jobId,
    "region": region,
    "reason": reason,
    "expertId": expertId,
  });

  // 🔥 IMPORTANT: FOLLOW REDIRECT
  request.followRedirects = true;
  request.maxRedirects = 5;

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  print("FINAL RESPONSE: ${response.body}");

  try {
    final res = jsonDecode(response.body);

    if (res["status"] != "success") {
      throw Exception(res["message"] ?? "Submit failed");
    }
  } catch (e) {
    throw Exception("Server not returning JSON (fix Apps Script)");
  }
}
  // ================= FETCH =================
  static Future<List<CXRequest>> fetchCX() async {
    final response = await http.get(Uri.parse(csvUrl));

    print("CSV DATA: ${response.body}");

    if (response.statusCode == 200) {
      final rows = const LineSplitter().convert(response.body);

      List<CXRequest> list = [];

      for (int i = 1; i < rows.length; i++) {
        final cols = _parseCsvRow(rows[i]);

        // Skip invalid rows
        if (cols.length < 6) continue;

        list.add(CXRequest(
          jobId: cols[1],
          region: cols[2],
          reason: cols[3],
          expertId: cols[4],
          status: cols[5],
        ));
      }

      return list;
    } else {
      throw Exception("Failed to load CX data");
    }
  }

  // ================= SAFE CSV PARSER =================
  static List<String> _parseCsvRow(String row) {
    return row.split(RegExp(r',(?=(?:[^"]*"[^"]*")*[^"]*$)'));
  }
}