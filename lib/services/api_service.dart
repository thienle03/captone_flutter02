import 'package:fiverr/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Helper: header mặc định
  static Future<Map<String, String>> defaultHeaders({bool json = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString("jwt");

    return {
      if (json) "Content-Type": "application/json",
      "tokenCybersoft": API_TOKEN,
      if (jwt != null && jwt.isNotEmpty) "Authorization": "Bearer $jwt",
    };
  }
}
