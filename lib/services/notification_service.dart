import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Inisialisasi Timezone (Sangat penting untuk penjadwalan)
    tz.initializeTimeZones();
    // Sesuaikan zona waktu dengan lokasi target, misalnya Asia/Jakarta
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); 

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(initSettings);

    _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Konfigurasi tampilan notifikasi
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

  /// Fungsi utama untuk mengatur jadwal notifikasi suatu task
  /// [taskId] harus unik untuk setiap task (bisa pakai ID dari database)
  /// [deadline] adalah waktu maksimal pengumpulan tugas
  static Future<void> scheduleTaskNotifications({
    required int taskId,
    required String taskName,
    required DateTime deadline,
  }) async {
    final tz.TZDateTime tzDeadline = tz.TZDateTime.from(deadline, tz.local);

    // 1. Jadwal H-3 (Jika waktu H-3 masih di masa depan)
    final tz.TZDateTime hMinus3 = tzDeadline.subtract(const Duration(days: 3));
    if (hMinus3.isAfter(tz.TZDateTime.now(tz.local))) {
      await _notificationsPlugin.zonedSchedule(
        taskId * 10 + 1, // ID unik untuk H-3
        'Pengingat H-3: $taskName',
        'Waktu pengumpulan tugas Anda tersisa 3 hari lagi!',
        hMinus3,
        _notificationDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    // 2. Jadwal H-1 (Jika waktu H-1 masih di masa depan)
    final tz.TZDateTime hMinus1 = tzDeadline.subtract(const Duration(days: 1));
    if (hMinus1.isAfter(tz.TZDateTime.now(tz.local))) {
      await _notificationsPlugin.zonedSchedule(
        taskId * 10 + 2, // ID unik untuk H-1
        'Besok Deadline: $taskName',
        'Segera kumpulkan! Waktu tersisa 1 hari lagi.',
        hMinus1,
        _notificationDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    // 3. Pengingat Terlambat (Setiap Hari setelah Deadline)
    // Akan mulai berbunyi pada jam deadline, dan diulang setiap hari di jam yang sama.
    await _notificationsPlugin.zonedSchedule(
      taskId * 10 + 3, // ID unik untuk Overdue harian
      'Tugas Terlambat: $taskName',
      'Anda belum mengumpulkan tugas ini. Segera selesaikan!',
      tzDeadline,
      _notificationDetails(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // INI KUNCI AGAR DIULANG SETIAP HARI
    );
  }

  /// PENTING: Panggil fungsi ini saat user BERHASIL MENGUMPULKAN TASK
  /// Ini berfungsi untuk membatalkan semua notifikasi terkait task tersebut 
  /// (terutama notifikasi terlambat yang diset berulang setiap hari).
  static Future<void> cancelTaskNotifications(int taskId) async {
    await _notificationsPlugin.cancel(taskId * 10 + 1); // Batal H-3
    await _notificationsPlugin.cancel(taskId * 10 + 2); // Batal H-1
    await _notificationsPlugin.cancel(taskId * 10 + 3); // Batal Overdue harian
  }
  /// Fungsi untuk menampilkan notifikasi instan (seperti saat user menyalakan switch di Profil)
  static Future<void> showDeadlineNotification({
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      0, // ID 0 khusus untuk notifikasi instan/testing
      title,
      body,
      _notificationDetails(), // Menggunakan desain notifikasi yang sudah kita buat
    );
  }
}