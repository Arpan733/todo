import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotification {
  static final FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialization() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

    await notification.initialize(
      initializationSettings,
    );
  }

  static void showNotification(String title, String message) async {
    notification.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "update",
          "Update channel",
          category: AndroidNotificationCategory.alarm,
          channelDescription: "description",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required String dateTime,
  }) async {
    await notification.zonedSchedule(
      id,
      'Task time for $title',
      body,
      tz.TZDateTime.from(DateTime.parse(dateTime), tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "main_channel",
          "Main Channel",
          category: AndroidNotificationCategory.alarm,
          channelDescription: "description",
          importance: Importance.max,
          priority: Priority.max,
          // visibility: NotificationVisibility.public,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
