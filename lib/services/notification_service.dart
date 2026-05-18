import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); 

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(initSettings);

    _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'todo_deadline_channel',
        'Pengingat Deadline',
        channelDescription: 'Notifikasi untuk tugas yang mendekati deadline dan terlambat',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF7C5CFC),
        icon: '@mipmap/ic_launcher',
      ),
    );
  }

  /// [taskId] harus unik
  /// [deadline] waktu maksimal pengumpulan
  static Future<void> scheduleTaskNotifications({
    required int taskId,
    required String taskName,
    required DateTime deadline,
  }) async {
    final tz.TZDateTime tzDeadline = tz.TZDateTime.from(deadline, tz.local);

    final tz.TZDateTime hMinus3 = tzDeadline.subtract(const Duration(days: 3));
    if (hMinus3.isAfter(tz.TZDateTime.now(tz.local))) {
      await _notificationsPlugin.zonedSchedule(
        taskId * 10 + 1,
        'Pengingat H-3: $taskName',
        'Waktu pengumpulan tugas Anda tersisa 3 hari lagi!',
        hMinus3,
        _notificationDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    final tz.TZDateTime hMinus1 = tzDeadline.subtract(const Duration(days: 1));
    if (hMinus1.isAfter(tz.TZDateTime.now(tz.local))) {
      await _notificationsPlugin.zonedSchedule(
        taskId * 10 + 2,
        'Besok Deadline: $taskName',
        'Segera kumpulkan! Waktu tersisa 1 hari lagi.',
        hMinus1,
        _notificationDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    await _notificationsPlugin.zonedSchedule(
      taskId * 10 + 3,
      'Tugas Terlambat: $taskName',
      'Anda belum mengumpulkan tugas ini. Segera selesaikan!',
      tzDeadline,
      _notificationDetails(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelTaskNotifications(int taskId) async {
    await _notificationsPlugin.cancel(taskId * 10 + 1);
    await _notificationsPlugin.cancel(taskId * 10 + 2);
    await _notificationsPlugin.cancel(taskId * 10 + 3);
  }

  static Future<void> showDeadlineNotification({
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      0,
      title,
      body,
      _notificationDetails(),
    );
  }
}