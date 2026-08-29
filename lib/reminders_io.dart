/// Local notifications, where the platform has them.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'reminders.dart';

Reminders createReminders() => LocalReminders();

class LocalReminders implements Reminders {
  LocalReminders();

  static const int _id = 1;
  static const String _channel = 'daily_review';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Windows has no implementation in this plugin, and Linux has no scheduling
  /// support -- it can show a notification now but cannot book one for 19:00.
  /// Claiming otherwise would give the learner a switch that silently does
  /// nothing, which is worse than not offering it.
  @override
  bool get isSupported =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  @override
  Future<void> initialise() async {
    if (_ready || !isSupported) return;
    tzdata.initializeTimeZones();
    // The device's own zone, so 19:00 means 19:00 where the learner is and
    // keeps meaning it after they fly somewhere.
    tz.setLocalLocation(tz.getLocation(await _deviceTimeZone()));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  Future<String> _deviceTimeZone() async {
    // An offset alone is not a time zone: Berlin and Lagos can share one in
    // winter but only Berlin changes for summer time. Ask the OS for its IANA
    // identifier so a daily reminder remains at the learner's chosen wall
    // time across daylight-saving changes and travel.
    try {
      final TimezoneInfo zone = await FlutterTimezone.getLocalTimezone();
      if (tz.timeZoneDatabase.locations.containsKey(zone.identifier)) {
        return zone.identifier;
      }
    } catch (error) {
      debugPrint('could not read the device time zone: $error');
    }

    // A best-effort fallback for unusual platform identifiers. Scheduling a
    // reminder in a matching offset is still better than failing the setting.
    final Duration offset = DateTime.now().timeZoneOffset;
    for (final String name in tz.timeZoneDatabase.locations.keys) {
      final tz.Location location = tz.getLocation(name);
      if (location.currentTimeZone.offset == offset) {
        return name;
      }
    }
    return 'UTC';
  }

  @override
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await initialise();
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final bool granted =
          await android?.requestNotificationsPermission() ?? false;
      return granted;
    }
    final IOSFlutterLocalNotificationsPlugin? apple = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (apple != null) {
      return await apple.requestPermissions(alert: true, badge: true) ?? false;
    }
    final MacOSFlutterLocalNotificationsPlugin? mac = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    return await mac?.requestPermissions(alert: true, badge: true) ?? false;
  }

  @override
  Future<void> schedule(ReminderPlan plan) async {
    if (!isSupported) return;
    await initialise();
    await cancel();
    try {
      await _plugin.zonedSchedule(
        id: _id,
        title: 'DeutschGarden',
        body: plan.body,
        scheduledDate: _nextOccurrence(plan.hour, plan.minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channel,
            'Daily review',
            channelDescription: 'A once-a-day reminder that reviews are due.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (error) {
      // A reminder is a convenience. Losing it must never take the app with
      // it, and the learner has already been told it is best-effort.
      debugPrint('could not schedule the reminder: $error');
    }
  }

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime when = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // Setting a reminder for 08:00 at lunchtime means tomorrow, not a
    // notification that fires immediately.
    if (!when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }
    return when;
  }

  @override
  Future<void> cancel() async {
    if (!isSupported) return;
    await initialise();
    try {
      await _plugin.cancel(id: _id);
    } catch (error) {
      debugPrint('could not cancel the reminder: $error');
    }
  }
}
