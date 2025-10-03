import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fiverr/config.dart';

class SearchService {
  Future<List<dynamic>> fetchLoaiCongViec() async {
    final url = Uri.parse(
      "$API_BASE_URL/api/cong-viec/lay-menu-loai-cong-viec",
    );
    final res = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "TokenCybersoft": API_TOKEN,
      },
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final content = (body is Map ? body["content"] : body) ?? [];
      return content as List<dynamic>;
    }
    throw Exception("Fetch menu failed: ${res.statusCode} - ${res.body}");
  }

  Future<List<dynamic>> searchJobs(String keyword) async {
    final k = keyword.trim();
    if (k.isEmpty) return [];

    final encoded = Uri.encodeComponent(k);
    final url = Uri.parse(
      "$API_BASE_URL/api/cong-viec/lay-danh-sach-cong-viec-theo-ten/$encoded",
    );

    final res = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "TokenCybersoft": API_TOKEN,
      },
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final list = (body is Map ? body["content"] : body) ?? [];
      return list as List<dynamic>;
    }
    throw Exception("Search failed: ${res.statusCode} - ${res.body}");
  }
}
