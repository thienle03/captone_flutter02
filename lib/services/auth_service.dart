import 'dart:convert';
import 'package:fiverr/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // --- Đăng ký ---
  static Future<http.Response> signUp(Map<String, dynamic> data) async {
    final url = Uri.parse("$API_BASE_URL/api/auth/signup");
    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "tokenCyberSoft": API_TOKEN,
      },
      body: jsonEncode(data),
    );
    return res;
  }

  // --- Đăng nhập ---
  static Future<http.Response> signIn(String email, String password) async {
    final url = Uri.parse("$API_BASE_URL/api/auth/signin");
    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "tokenCyberSoft": API_TOKEN,
      },
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      try {
        final data = jsonDecode(res.body);
        final content = (data is Map) ? data["content"] ?? data : data;
        final token = content["token"] ?? content["accessToken"];
        final user = content["user"] ?? content;
        final prefs = await SharedPreferences.getInstance();
        if (token is String) await prefs.setString("jwt", token);
        if (user?["id"] != null) await prefs.setInt("userId", user["id"]);
      } catch (_) {}
    }
    return res;
  }
}
