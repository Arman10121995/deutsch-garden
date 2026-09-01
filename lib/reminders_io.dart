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

  static const int _firstId = 1;
  static const int _lastId = 7;
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
      // Seven weekly slots let Sunday carry the weekly progress without also
      // delivering a separate daily notification. The plugin documents
      // dayOfWeekAndTime as its cross-platform weekly recurrence primitive.
      for (
        int weekday = DateTime.monday;
        weekday <= DateTime.sunday;
        weekday += 1
      ) {
        await _plugin.zonedSchedule(
          id: _firstId + weekday - 1,
          title: weekday == DateTime.sunday
              ? 'DeutschGarden · Wochenziel'
              : 'DeutschGarden · Tagesziel',
          body: weekday == DateTime.sunday ? plan.weeklyBody : plan.dailyBody,
          scheduledDate: _nextWeekdayOccurrence(
            weekday,
            plan.hour,
            plan.minute,
          ),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _channel,
              'Study goals',
              channelDescription:
                  'One local reminder a day for daily and weekly study goals.',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
            macOS: DarwinNotificationDetails(),
          ),
          // A learning reminder does not justify exact-alarm permission.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } catch (error) {
      // A reminder is a convenience. Losing it must never take the app with
      // it, and the learner has already been told it is best-effort.
      debugPrint('could not schedule the reminder: $error');
    }
  }

  tz.TZDateTime _nextWeekdayOccurrence(int weekday, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    int daysAhead = (weekday - now.weekday + 7) % 7;
    tz.TZDateTime when = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysAhead,
      hour,
      minute,
    );
    // Setting Monday 08:00 on Monday lunchtime means next Monday, not an
    // immediate notification or a date in the past.
    if (!when.isAfter(now)) {
      daysAhead = daysAhead == 0 ? 7 : daysAhead;
      when = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + daysAhead,
        hour,
        minute,
      );
    }
    return when;
  }

  @override
  Future<void> cancel() async {
    if (!isSupported) return;
    await initialise();
    try {
      for (int id = _firstId; id <= _lastId; id += 1) {
        await _plugin.cancel(id: id);
      }
    } catch (error) {
      debugPrint('could not cancel the reminder: $error');
    }
  }
}
