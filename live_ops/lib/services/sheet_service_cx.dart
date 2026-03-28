  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:live_ops/models/cx_request_model.dart';

  class CXService {
    static const String webAppUrl =
        'https://script.google.com/macros/s/AKfycbxABITsPREHcmGyceoJbsXdaLTdzBuGPEMyXOEzyu-4GkYs5Jdq9pyEN_HnUEAoNQ1s2g/exec';

    static const String csvUrl =
        'https://docs.google.com/spreadsheets/d/1ujTe80AtniAdLrLUXG6V5mQGKC829Wek_PirLFLzpNA/export?format=csv&gid=481938133';

    static String _clean(String value) {
      return value.replaceAll('"', '').trim();
    }

    // ================= SUBMIT =================
    static Future<void> submitCX({
      required String jobId,
      required String region,
      required String reason,
      required String expertId,
    }) async {
      try {
        var request = http.Request('POST', Uri.parse(webAppUrl));

        request.headers["Content-Type"] = "application/json";
        request.followRedirects = true;
        request.maxRedirects = 5;

        request.body = jsonEncode({
          "type": "cx",
          "jobId": jobId,
          "region": region,
          "reason": reason,
          "expertId": expertId,
        });

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");

        // ✅ Google Apps Script returns 200 or 302 on success
        // Body may be HTML redirect page — that's normal, NOT an error
        // Only throw if it's a real server error (5xx)
        if (response.statusCode >= 500) {
          throw Exception("Server error: ${response.statusCode}");
        }

        // ✅ Try to parse JSON — but if it's HTML/empty, that's fine too
        // Apps Script often returns HTML on redirect, data is still saved
        final body = response.body.trim();
        if (body.isNotEmpty && body.startsWith('{')) {
          final res = jsonDecode(body);
          if (res["status"] != null && res["status"] != "success") {
            throw Exception(res["message"] ?? "Submit failed");
          }
        }

        // ✅ If we reach here, submit succeeded
        return;
      } on http.ClientException catch (e) {
        throw Exception("Network error: $e");
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

          print("ROW: $cols");

          if (cols.length < 6 || cols[1].trim().isEmpty) continue;

          list.add(CXRequest(
            jobId: _clean(cols[1]),
            region: _clean(cols[2]),
            reason: _clean(cols[3]),
            expertId: _clean(cols[4]),
            status: _clean(cols[5]),
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