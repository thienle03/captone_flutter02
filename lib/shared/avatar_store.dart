import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarStore {
  static const _kKey = 'avatar';
  static final ValueNotifier<String?> avatar = ValueNotifier<String?>(null);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    avatar.value = prefs.getString(_kKey);
  }

  static Future<void> set(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url == null || url.isEmpty) {
      await prefs.remove(_kKey);
      avatar.value = null;
    } else {
      await prefs.setString(_kKey, url);
      avatar.value = url;
    }
  }
}
