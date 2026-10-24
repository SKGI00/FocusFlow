import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Device-local, optional study reminders: no cloud or account is required.
/// Having separate methods allows real device checks and isolated widget tests.
abstract class ReminderScheduler {
  Future<bool> requestPermission();
  Future<void> scheduleDaily(int minuteOfDay);
  Future<bool> isScheduled();
  Future<void> sendTestNotification();
  Future<void> cancel();
}

/// Avoids platform calls in widget tests that inject a fake settings store.
class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleDaily(int minuteOfDay) async {}

  @override
  Future<bool> isScheduled() async => true;

  @override
  Future<void> sendTestNotification() async {}

  @override
  Future<void> cancel() async {}
}

/// A single quiet, repeating study reminder using Android's notification system.
/// Inexact scheduling avoids restricted exact-alarm permissions. Delivery can
/// be delayed by the operating system, especially during battery saving.
class SystemReminderScheduler implements ReminderScheduler {
  SystemReminderScheduler() : _plugin = FlutterLocalNotificationsPlugin();

  static const int notificationId = 7101;
  static const int testNotificationId = 7102;
  static const String channelId = 'focusflow_gentle_reminder_v1';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const NotificationDetails _quietDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      'FocusFlow gentle reminders',
      channelDescription: 'Optional, quiet reminders to return to studying',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: false,
      enableVibration: false,
    ),
    iOS: DarwinNotificationDetails(presentSound: false, presentBadge: false),
  );

  Future<void> _initialize() async {
    if (_initialized) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: false,
            sound: false,
          ) ??
          false;
    }
    return false;
  }

  @override
  Future<void> scheduleDaily(int minuteOfDay) async {
    if (minuteOfDay < 0 || minuteOfDay >= 24 * 60) {
      throw RangeError.range(minuteOfDay, 0, 1439, 'minuteOfDay');
    }
    await _initialize();
    tzdata.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    final next = nextDailyNotificationTime(
      tz.TZDateTime.now(tz.local),
      minuteOfDay,
    );

    await _plugin.zonedSchedule(
      id: notificationId,
      title: 'FocusFlow 🌱',
      body: 'A little study time? Start whenever you are ready.',
      scheduledDate: next,
      notificationDetails: _quietDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Confirms the plugin has the daily reminder in its pending queue.
  /// This is NOT proof that Android has delivered it yet.
  @override
  Future<bool> isScheduled() async {
    await _initialize();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any((item) => item.id == notificationId);
  }

  /// An immediate, separate diagnostic. Does not change the daily reminder.
  @override
  Future<void> sendTestNotification() async {
    await _initialize();
    await _plugin.show(
      id: testNotificationId,
      title: 'FocusFlow test 🌱',
      body: 'Notifications are working. This is only a test.',
      notificationDetails: _quietDetails,
    );
  }

  @override
  Future<void> cancel() async {
    await _initialize();
    await _plugin.cancel(id: notificationId);
    await _plugin.cancel(id: testNotificationId);
  }
}

/// Finds the next matching local clock time, taking the timezone into account.
tz.TZDateTime nextDailyNotificationTime(tz.TZDateTime now, int minuteOfDay) {
  if (minuteOfDay < 0 || minuteOfDay >= 1440) {
    throw RangeError.range(minuteOfDay, 0, 1439, 'minuteOfDay');
  }
  final hour = minuteOfDay ~/ 60;
  final minute = minuteOfDay % 60;
  var next = tz.TZDateTime(
    now.location,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  if (!next.isAfter(now)) {
    next = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day + 1,
      hour,
      minute,
    );
  }
  return next;
}
