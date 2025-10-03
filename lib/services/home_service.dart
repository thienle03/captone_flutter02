import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fiverr/config.dart';

class JobRepository {
  Future<List<dynamic>> searchJobs(String keyword) async {
    final url = Uri.parse(
      "$API_BASE_URL/api/cong-viec/lay-danh-sach-cong-viec-theo-ten/$keyword",
    );

    final res = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "tokenCyberSoft": API_TOKEN,
      },
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      if (body is Map && body.containsKey("content")) return body["content"];
      return body;
    }
    throw Exception("Search jobs failed: ${res.statusCode} ${res.body}");
  }
}
