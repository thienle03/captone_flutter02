import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiverr/config.dart';

class JobsService {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString("jwt") ?? "";
    return {
      "Content-Type": "application/json",
      "tokenCyberSoft": API_TOKEN,
      "TokenCybersoft": API_TOKEN,
      if (jwt.isNotEmpty) "Authorization": "Bearer $jwt",
      if (jwt.isNotEmpty) "token": jwt,
    };
  }

  static Future<List<dynamic>> fetchMyHires() async {
    final res = await http.get(
      Uri.parse("$API_BASE_URL/api/thue-cong-viec/lay-danh-sach-da-thue"),
      headers: await _headers(),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      final content = (body is Map) ? body["content"] : body;
      return (content is List) ? content : [];
    }
    throw Exception("HTTP ${res.statusCode}: ${res.body}");
  }

  static Future<void> completeOne(int hireId) async {
    final res = await http.post(
      Uri.parse(
        "$API_BASE_URL/api/thue-cong-viec/hoan-thanh-cong-viec/$hireId",
      ),
      headers: await _headers(),
    );
    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }
  }

  static Future<void> deleteOne(int hireId) async {
    final res = await http.delete(
      Uri.parse("$API_BASE_URL/api/thue-cong-viec/$hireId"),
      headers: await _headers(),
    );
    if (!(res.statusCode >= 200 && res.statusCode < 300)) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }
  }
}
