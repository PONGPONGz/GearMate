import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata; // <- alias changed
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'gearmate_default_channel';
  static const String _channelName = 'GearMate Alerts';
  static const String _channelDesc = 'Daily + maintenance reminders';

  Future<void> init() async {
    if (_initialized) return;

    // Fixed to Bangkok time (no native plugin required)
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _fln.initialize(initSettings);

    // Permissions + channel
    if (Platform.isAndroid) {
      final android = _fln.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
     await android?.requestNotificationsPermission(); // <- correct method
      await android?.createNotificationChannel(const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ));
    } else if (Platform.isIOS) {
      final ios = _fln.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true); // optional
    }

    _initialized = true;
  }

  NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
    importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  Future<void> showNow({
    int id = 1,
    String title = 'GearMate',
    String body = 'Immediate test',
  }) async {
    await _fln.show(id, title, body, _details());
  }

  Future<void> scheduleDailyMorning({
    int id = 1000,
    required int hour,
    int minute = 0,
    String title = 'GearMate',
    String body = "Don't forget to check your gear",
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    if (kDebugMode) {
      debugPrint('Daily schedule id=$id at $scheduled tz=${tz.local.name}');
    }

    await _fln.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleOneShot({
    required int id,
    required DateTime whenLocal,
    required String title,
    required String body,
  }) async {
    final scheduled = tz.TZDateTime(
      tz.local,
      whenLocal.year,
      whenLocal.month,
      whenLocal.day,
      whenLocal.hour,
      whenLocal.minute,
      whenLocal.second,
      whenLocal.millisecond,
      whenLocal.microsecond,
    );

    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      if (kDebugMode) debugPrint('Skip past time for id=$id @ $scheduled');
      return;
    }

    if (kDebugMode) {
      debugPrint('One-shot id=$id at $scheduled tz=${tz.local.name}');
    }

    await _fln.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() => _fln.cancelAll();
}