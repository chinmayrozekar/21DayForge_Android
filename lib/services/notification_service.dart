import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {},
    );
  }

  static Future<bool> requestAuthorization() async {
    final exactAlarm = await Permission.scheduleExactAlarm.request();
    debugPrint('Exact alarm permission: ${exactAlarm}');
    if (!exactAlarm.isGranted) {
      debugPrint('Exact alarm permission not granted');
      return false;
    }

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final notificationsPermission =
          await android.requestNotificationsPermission();
      debugPrint('Notification permission: $notificationsPermission');
      return notificationsPermission == true;
    }

    return true;
  }

  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await cancelDailyReminder();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('Scheduling reminder for: $scheduledDate (now: $now)');

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminder',
      channelDescription: 'Daily reminder to log your challenge progress',
      importance: Importance.high,
      priority: Priority.high,
      channelShowBadge: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      0,
      '21DayForge',
      "Don't break the chain! Log your progress today.",
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    debugPrint('Reminder scheduled successfully');
  }

  static Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0);
  }
}