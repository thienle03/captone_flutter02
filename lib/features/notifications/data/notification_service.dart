import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  final String id; // uuid ngắn
  final String type; // 'order' | 'done' | ...
  final String title;
  final String body;
  final int createdAt; // msSinceEpoch
  bool read;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        read: read ?? this.read,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "title": title,
        "body": body,
        "createdAt": createdAt,
        "read": read,
      };
  static AppNotification fromJson(Map<String, dynamic> j) => AppNotification(
        id: j["id"],
        type: j["type"],
        title: j["title"],
        body: j["body"],
        createdAt: j["createdAt"],
        read: j["read"] ?? false,
      );
}

class NotificationService {
  static const _kKey = "notifications";
  static final ValueNotifier<int> unread = ValueNotifier<int>(0);

  static Future<List<AppNotification>> fetchAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kKey) ?? const [];
    return raw.map((s) => AppNotification.fromJson(jsonDecode(s))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<int> unreadCount() async {
    final list = await fetchAll();
    return list.where((e) => !e.read).length;
  }

  static Future<void> refreshUnread() async {
    final n = await unreadCount();
    unread.value = n;
  }

  static Future<void> add({
    required String type,
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = now.toString(); // đủ unique cho demo

    final n = AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: now,
      read: false,
    );

    final list = await fetchAll();
    list.insert(0, n);
    await prefs.setStringList(
      _kKey,
      list.map((e) => jsonEncode(e.toJson())).toList(),
    );
    await refreshUnread();
  }

  static Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final list = await fetchAll();
    final newList = list.map((e) => e.copyWith(read: true)).toList();
    await prefs.setStringList(
      _kKey,
      newList.map((e) => jsonEncode(e.toJson())).toList(),
    );
    await refreshUnread();
  }

  static Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await fetchAll();
    list.removeWhere((e) => e.id == id);
    await prefs.setStringList(
      _kKey,
      list.map((e) => jsonEncode(e.toJson())).toList(),
    );
    await refreshUnread();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
    await refreshUnread();
  }
}
