import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ut_request_model.dart';

class SheetService {
  // ✅ Your URLs (already correct)
  static const String webAppUrl = 'https://script.google.com/macros/s/AKfycbxABITsPREHcmGyceoJbsXdaLTdzBuGPEMyXOEzyu-4GkYs5Jdq9pyEN_HnUEAoNQ1s2g/exec';
  static const String csvUrl =
      'https://docs.google.com/spreadsheets/d/1ujTe80AtniAdLrLUXG6V5mQGKC829Wek_PirLFLzpNA/export?format=csv';

  // ---------------- SUBMIT ----------------
  static Future<void> submitUT({
    required String requestBy,
    required String expertId,
    required String region,
    required String utHours,
    required String reason,
    required String hasJob, 
  }) async {
    try {
      final response = await http.post(
        Uri.parse(webAppUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "type": 'ut',
          "requestBy": requestBy,
          "expertId": expertId,
          "region": region,
          "utHours": utHours,
          "reason": reason,
          "hasJob": hasJob,
        }),
      );

      // 🔥 IMPORTANT: Google script may not return 200
      print("Submit Status: ${response.statusCode}");
      print("Submit Response: ${response.body}");

      // ✅ Accept multiple success codes
      if (response.statusCode == 200 ||
          response.statusCode == 302 ||
          response.statusCode == 303 ||
          response.statusCode == 0) {
        return;
      } else {
        throw Exception("Submit failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Submit Error: $e");
      throw Exception("Failed to submit");
    }
  }

  // ---------------- FETCH ----------------
  static Future<List<UTRequest>> fetchUTRequests() async {
    try {
      final response = await http.get(Uri.parse(csvUrl));

      if (response.statusCode == 200) {
        List<UTRequest> list = [];

        final lines = const LineSplitter().convert(response.body);

        print("CSV DATA:");
        print(response.body); // 🔥 DEBUG

        for (int i = 1; i < lines.length; i++) {
          final row = lines[i].split(',');

          // ✅ Skip invalid rows
          if (row.length < 8) continue;

          list.add(UTRequest(
           createdAt: parseGoogleDate(row[0]),
            expertId: _clean(row[1]),
            region: _clean(row[2]),
            utHours: _clean(row[3]),
            reason: _clean(row[4]),
            hasJob: _clean(row[5]),
            status: _clean(row[7]),
            requestBy: _clean(row[6]), // ✅ FIXED INDEX
          ));
        }

        return list;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Fetch Error: $e");
      return [];
    }
  }

  // ---------------- CLEAN FUNCTION ----------------
  static String _clean(String value) {
    return value.replaceAll('"', '').trim();
  }
  // 🔥 PARSE GOOGLE DATE (MM/DD/YYYY HH:mm:ss)
static DateTime parseGoogleDate(String raw) {
  try {
    return DateTime.parse(raw); // works if ISO
  } catch (_) {
    try {
      final parts = raw.split(" ");
      final date = parts[0].split("/");
      final time = parts.length > 1 ? parts[1] : "00:00:00";

      return DateTime(
        int.parse(date[2]), // year
        int.parse(date[0]), // month
        int.parse(date[1]), // day
        int.parse(time.split(":")[0]),
        int.parse(time.split(":")[1]),
        int.parse(time.split(":")[2]),
      );
    } catch (e) {
      return DateTime.now(); // fallback (important to avoid crash)
    }
  }
}
}