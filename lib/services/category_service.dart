import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fiverr/config.dart';

class CategoryService {
  static Future<List<dynamic>> fetchMenuLoai() async {
    final url = Uri.parse(
      "$API_BASE_URL/api/cong-viec/lay-menu-loai-cong-viec",
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
      return (body is Map ? body["content"] : body) ?? [];
    } else {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }
  }
}
