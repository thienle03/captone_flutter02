// lib/features/profile/data/profile_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiverr/config.dart';
import 'package:fiverr/services/api_service.dart';

class ProfileService {
  // userId ưu tiên từ tham số, nếu null thì lấy từ prefs
  static Future<int?> getUserId([int? fromWidget]) async {
    if (fromWidget != null) return fromWidget;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<Map<String, dynamic>?> fetchUser(int uid) async {
    final url = Uri.parse("$API_BASE_URL/api/users/$uid");
    final res = await http.get(url, headers: await ApiService.defaultHeaders());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      return (body is Map ? body["content"] : body) ?? {};
    }
    throw Exception("HTTP ${res.statusCode}: ${res.body}");
  }

  static Future<bool> updateUser(
    int uid,
    Map<String, dynamic> patch,
    Map<String, dynamic> currentUser,
  ) async {
    final full = <String, dynamic>{
      "id": uid,
      "name": patch["name"] ?? currentUser["name"] ?? "",
      "email": patch["email"] ?? currentUser["email"] ?? "",
      "password": patch["password"] ?? currentUser["password"] ?? "",
      "phone": patch["phone"] ?? currentUser["phone"] ?? "",
      "birthday": patch["birthday"] ?? currentUser["birthday"] ?? "",
      "gender": patch["gender"] ?? currentUser["gender"] ?? true,
      "role": patch["role"] ?? currentUser["role"] ?? "USER",
      "skill": (patch["skill"] ?? currentUser["skill"] ?? const []) as List,
      "certification": (patch["certification"] ??
          currentUser["certification"] ??
          const []) as List,
    };

    final url = Uri.parse("$API_BASE_URL/api/users/$uid");

    print("👉 Sending updateUser request:");
    print("URL: $url");
    print("Body: ${jsonEncode(full)}");

    final res = await http.put(
      url,
      headers: await ApiService.defaultHeaders(),
      body: jsonEncode(full),
    );

    print("🔵 Response status: ${res.statusCode}");
    print("🔵 Response body: ${res.body}");

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  // avatar upload trả về URL ảnh
  static Future<String?> uploadAvatar(File file) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt') ?? '';

    final uri = Uri.parse("$API_BASE_URL/api/users/upload-avatar");
    final req = http.MultipartRequest("POST", uri);

    req.headers.addAll({
      "tokenCybersoft": API_TOKEN,
      if (jwt.isNotEmpty) "token": jwt,
    });

    final mime = lookupMimeType(file.path)?.split('/') ?? ['image', 'jpeg'];
    final part = await http.MultipartFile.fromPath(
      'formFile',
      file.path,
      contentType: MediaType(mime[0], mime[1]),
    );
    req.files.add(part);

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body;
    } else {
      throw Exception("Upload failed: ${res.statusCode} ${res.body}");
    }
  }

  // Lấy danh sách kỹ năng
  static Future<List<String>> fetchSkills() async {
    final uri = Uri.parse("$API_BASE_URL/api/skill");
    final headers = await ApiService.defaultHeaders(json: false);
    final res = await http.get(uri, headers: headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("HTTP ${res.statusCode}: ${res.body}");
    }

    final body = jsonDecode(res.body);
    final data =
        (body is Map && body['content'] != null) ? body['content'] : body;
    if (data is! List) return [];

    final list = data
        .map((e) => (e is Map ? e['tenSkill'] : e).toString())
        .where((s) => s.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }
}
