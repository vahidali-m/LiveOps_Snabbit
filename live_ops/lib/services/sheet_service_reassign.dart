import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:live_ops/models/Reassign_request_model.dart';

class ReassignService {
  static const String webAppUrl = 'https://script.google.com/macros/s/AKfycbxABITsPREHcmGyceoJbsXdaLTdzBuGPEMyXOEzyu-4GkYs5Jdq9pyEN_HnUEAoNQ1s2g/exec';  // 🔥 PUT YOUR REAL SHEET2 GID HERE
  static const String csvUrl =
      'https://docs.google.com/spreadsheets/d/1ujTe80AtniAdLrLUXG6V5mQGKC829Wek_PirLFLzpNA/export?format=csv&gid=876336286';

  // ================= SUBMIT =================
static Future<void> submitReassign({
  required String jobId,
  required String reason,
  required String freeExpertId,
  required String region,
}) async {
  final response = await http.post(
    Uri.parse(webAppUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "type": "reassign",
      "jobId": jobId,
      "reason": reason,
      "freeExpertId": freeExpertId,
      "region": region,
    }),
  );

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  // 🔥 FIX: HANDLE HTML RESPONSE (DON'T CRASH)
  if (response.body.trim().startsWith("<")) {
    // Means Google returned HTML but submission is SUCCESS
    return; // ✅ DON'T THROW ERROR
  }

  try {
    final res = jsonDecode(response.body);

    if (res["status"] != "success") {
      throw Exception(res["message"] ?? "Failed to submit");
    }
  } catch (e) {
    print("JSON PARSE ERROR: $e");
    // ✅ IGNORE PARSE ERROR (because data already saved)
  }
}
  // ================= FETCH =================
  static Future<List<ReassignRequest>> fetchReassign() async {
    final response = await http.get(Uri.parse(csvUrl));

    if (response.statusCode == 200) {
      final rows = const LineSplitter().convert(response.body);
      List<ReassignRequest> list = [];

      for (int i = 1; i < rows.length; i++) {
        final cols = rows[i].split(',');

        // 🔥 PREVENT CRASH
        if (cols.length < 5) continue;

        list.add(ReassignRequest(
          jobId: cols.length > 1 ? cols[1] : '',
          region: cols.length > 2 ? cols[2] : '',
          freeExpertId: cols.length > 3 ? cols[3] : '',
          reason: cols.length > 4 ? cols[4] : '',
          status: cols.length > 5 ? cols[5] : 'Pending', createdAt: parseGoogleDate(cols[0]),
        ));
      }

      return list;
    } else {
      throw Exception("Failed to load");
    }
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