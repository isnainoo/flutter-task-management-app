import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(initSettings);

    _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showDeadlineNotification({required String title, required String body}) async {
    AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      'todo_deadline_channel',
      'Pengingat Deadline',
      channelDescription: 'Notifikasi untuk tugas yang mendekati deadline',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF7C5CFC),
      icon: '@mipmap/ic_launcher',
    );

    NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(0, title, body, details);
  }
}