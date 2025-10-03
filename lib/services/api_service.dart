import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fiverr/config.dart';
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

  // Load menu loại công việc (để build dropdown)
  static Future<http.Response> fetchCategoriesMenu() async {
    final url = Uri.parse(
      "$API_BASE_URL/api/cong-viec/lay-menu-loai-cong-viec",
    );
    return http.get(url, headers: await defaultHeaders());
    // Trả về JSON bạn đã dùng ở các màn trước
  }

  // Tạo yêu cầu thuê công việc
  // TODO: đổi endpoint cho đúng backend của bạn
  static Future<http.Response> createHireRequest(
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse(
      "$API_BASE_URL/api/thue-cong-viec",
    ); // <--- CHỈNH NẾU KHÁC
    return http.post(
      url,
      headers: await defaultHeaders(),
      body: jsonEncode(data),
    );
  }

  // Helper: header mặc định (gắn jwt nếu có)
  static Future<Map<String, String>> defaultHeaders({bool json = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString("jwt");

    return {
      if (json) "Content-Type": "application/json",
      "tokenCybersoft": API_TOKEN,
      if (jwt != null && jwt.isNotEmpty) "Authorization": "Bearer $jwt",
    };
  }

  /// Headers mặc định: kèm tokenCyberSoft + token user
  static Future<Map<String, String>> authedHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString("jwt");
    return {
      "Content-Type": "application/json",
      "tokenCyberSoft": API_TOKEN,
      // Tùy backend: một số API yêu cầu "token", số khác yêu cầu Authorization
      if (jwt != null && jwt.isNotEmpty) "token": jwt,
      if (jwt != null && jwt.isNotEmpty) "Authorization": "Bearer $jwt",
    };
  }

  // Ví dụ GET user by id dùng header chuẩn
  static Future<http.Response> getUser(int id) async {
    final url = Uri.parse("$API_BASE_URL/api/users/$id");
    return http.get(url, headers: await defaultHeaders());
  }

  /// GET /api/skill
  /// Trả về List skill (mảng string hoặc mảng object có {id, tenSkill})
  static Future<List<String>> fetchSkills() async {
    final res = await http.get(
      Uri.parse("$API_BASE_URL/api/skill"),
      headers: await defaultHeaders(),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      final content = (data is Map) ? data["content"] : data;

      if (content is List) {
        // content có thể là ["Dart", "Flutter"] hoặc [{id, tenSkill}, ...]
        return content
            .map(
              (e) => e is Map ? (e["tenSkill"] ?? e["name"] ?? e["title"]) : e,
            )
            .map((e) => e?.toString() ?? "")
            .where((s) => s.trim().isNotEmpty)
            .cast<String>()
            .toList();
      }
    }
    return [];
  }
}
