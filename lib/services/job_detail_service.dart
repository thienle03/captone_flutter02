import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiverr/config.dart';

class JobDetailService {
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt') ?? '';
    return {
      "Content-Type": "application/json",
      "tokenCyberSoft": API_TOKEN,
      if (jwt.isNotEmpty) "Authorization": "Bearer $jwt",
      if (jwt.isNotEmpty) "token": jwt,
    };
  }

  Map<String, String> _publicHeaders() => {
    "TokenCybersoft": API_TOKEN,
    "Content-Type": "application/json",
  };

  Future<Map<String, dynamic>?> fetchJobDetail(int maCongViec) async {
    final url = Uri.parse(
      "$API_BASE_URL/api/cong-viec/lay-cong-viec-chi-tiet/$maCongViec",
    );

    final response = await http.get(
      url,
      headers: {"TokenCybersoft": API_TOKEN},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      if (body is Map && body.containsKey("content")) {
        final content = body["content"];
        if (content is List && content.isNotEmpty) {
          final item = content.first;
          return {
            "tenCongViec": item["congViec"]["tenCongViec"],
            "hinhAnh": item["congViec"]["hinhAnh"],
            "avatar": item["avatar"],
            "tenNguoiTao": item["tenNguoiTao"],
            "saoCongViec": item["congViec"]["saoCongViec"],
            "danhGia": item["congViec"]["danhGia"],
            "moTa": item["congViec"]["moTa"],
            "moTaNgan": item["congViec"]["moTaNgan"],
            "giaTien": item["congViec"]["giaTien"],
          };
        }
      }
    }
    return null;
  }

  Future<List<dynamic>> fetchComments(int maCongViec) async {
    final url = Uri.parse(
      "$API_BASE_URL/api/binh-luan/lay-binh-luan-theo-cong-viec/$maCongViec",
    );

    final response = await http.get(
      url,
      headers: {"TokenCybersoft": API_TOKEN},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      if (body is Map && body.containsKey("content")) {
        return body["content"] is List ? (body["content"] as List) : [];
      }
    }
    return [];
  }

  Future<({bool ok, String message})> postComment({
    required int maCongViec,
    required String content,
    int saoBinhLuan = 5,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId'); // 👈 lấy userId sau khi login
      if (userId == null) {
        return (ok: false, message: "Bạn cần đăng nhập trước khi bình luận");
      }

      final headers = await _authHeaders();

      final body = {
        "id": 0,
        "maCongViec": maCongViec,
        "maNguoiBinhLuan": userId,
        "ngayBinhLuan":
            DateTime.now().toIso8601String(), // 👈 ngày giờ hiện tại
        "noiDung": content,
        "saoBinhLuan": saoBinhLuan,
      };

      final url = Uri.parse("$API_BASE_URL/api/binh-luan");
      final res = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return (ok: true, message: "Đã thêm bình luận");
      }
      return (ok: false, message: "(${res.statusCode}) ${res.body}");
    } catch (e) {
      return (ok: false, message: "Lỗi kết nối: $e");
    }
  }

  Future<bool> hireJob(int maCongViec) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final jwt = prefs.getString('jwt') ?? '';

    if (userId == null || jwt.isEmpty) {
      return false;
    }

    final payload = {
      "id": 0,
      "maCongViec": maCongViec,
      "maNguoiThue": userId,
      "ngayThue": DateTime.now().toIso8601String(),
      "hoanThanh": false,
    };

    final url = Uri.parse("$API_BASE_URL/api/thue-cong-viec");
    final res = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(payload),
    );

    return res.statusCode >= 200 && res.statusCode < 300;
  }
}
