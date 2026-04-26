import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotification {
  final int    id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;

  LocalNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id':        id,
    'title':     title,
    'message':   message,
    'type':      type,
    'createdAt': createdAt.toIso8601String(),
  };

  factory LocalNotification.fromJson(Map<String, dynamic> j) => LocalNotification(
    id:        j['id']        ?? 0,
    title:     j['title']     ?? '',
    message:   j['message']   ?? '',
    type:      j['type']      ?? '',
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );
}

class NotificationsStorage {
  static const _key = 'local_notifications';

  static Future<List<LocalNotification>> getAll() async {
    final p    = await SharedPreferences.getInstance();
    final json = p.getString(_key);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => LocalNotification.fromJson(e)).toList();
  }

  static Future<void> add(LocalNotification n) async {
    final list = await getAll();
    list.insert(0, n);
    await _saveAll(list);
  }

  static Future<void> delete(int id) async {
    final list = await getAll();
    list.removeWhere((n) => n.id == id);
    await _saveAll(list);
  }

  static Future<void> _saveAll(List<LocalNotification> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(list.map((n) => n.toJson()).toList()));
  }
}
