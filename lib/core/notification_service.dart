import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey:         'trainy_channel',
          channelName:        'Trainy',
          channelDescription: 'إشعارات تطبيق تريني',
          importance:         NotificationImportance.High,
          defaultColor:       Colors.black,
          ledColor:           Colors.black,
        ),
        NotificationChannel(
          channelKey:         'trainy_reminder',
          channelName:        'Trainy Reminders',
          channelDescription: 'تذكيرات مواعيد القطارات',
          importance:         NotificationImportance.High,
          defaultColor:       Colors.black,
          ledColor:           Colors.black,
        ),
      ],
    );
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // ── إشعار فوري ──────────────────────────────────────────────────────
  static Future<void> show({
    required int    id,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id:         id,
        channelKey: 'trainy_channel',
        title:      title,
        body:       body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  // ── إشعار مجدول ─────────────────────────────────────────────────────
  static Future<void> schedule({
    required int      id,
    required String   title,
    required String   body,
    required DateTime scheduledTime,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) return;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id:         id,
        channelKey: 'trainy_reminder',
        title:      title,
        body:       body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime),
    );
  }

  // ── إلغاء إشعار ─────────────────────────────────────────────────────
  static Future<void> cancel(int id) async =>
      await AwesomeNotifications().cancel(id);
}
