import 'dart:convert';

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// The literal keys the controller persists under. Spelling them out here is
/// deliberate: a rename that silently orphans a learner's saved profile should
/// break this test rather than ship.
const String kStateKey = 'deutsch_garden_state_v4';
const String kSnapshotKey = 'deutsch_garden_state_v4_snapshot';
const String kQuarantineKey = 'deutsch_garden_state_corrupt';
const String kLegacyV3Key = 'deutsch_garden_state_v3';

void main() {
  late SharedPreferencesAsync prefs;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = SharedPreferencesAsync();
  });

  /// A streak only survives a load if the profile was last studied today or
  /// yesterday, so stamp it with today's key.
  String todayKey() {
    final DateTime now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String profileJson({int xp = 1234, int streak = 7}) => jsonEncode(
        <String, dynamic>{
          'xp': xp,
          'streak': streak,
          'lastStudyDay': todayKey(),
          'progress': <String, dynamic>{
            '001': <String, dynamic>{
              'mastery': 3,
              'seen': true,
              'correct': 9,
              'ease': 2.4,
              'intervalDays': 12,
            },
          },
        },
      );

  group('corrupt state recovery', () {
    test('a corrupt profile is never overwritten by a blank save', () async {
      const String corrupt = '{"xp": 999, this is not json';
      await prefs.setString(kStateKey, corrupt);

      final AppController controller = AppController();
      await controller.load();

      // The unreadable bytes are preserved for recovery...
      expect(await prefs.getString(kQuarantineKey), corrupt);
      // ...and the learner is told, rather than silently seeing a fresh start.
      expect(controller.recoveryNotice, isNotEmpty);
      expect(await controller.quarantinedProfile(), corrupt);
    });

    test('a corrupt profile falls back to the last good snapshot', () async {
      await prefs.setString(kSnapshotKey, profileJson(xp: 4242, streak: 9));
      await prefs.setString(kStateKey, 'totally corrupt {{{');

      final AppController controller = AppController();
      await controller.load();

      expect(controller.xp, 4242);
      expect(controller.streak, 9);
      expect(controller.recoveryNotice, contains('backup'));
      // The recovered profile is promoted back to being the live one.
      expect(await prefs.getString(kStateKey), isNotNull);
    });

    test('a clean load writes a snapshot for next time', () async {
      await prefs.setString(kStateKey, profileJson(xp: 55));

      final AppController controller = AppController();
      await controller.load();

      expect(controller.xp, 55);
      expect(controller.recoveryNotice, isEmpty);
      final String? snapshot = await prefs.getString(kSnapshotKey);
      expect(snapshot, isNotNull);
      expect(jsonDecode(snapshot!), isA<Map<String, dynamic>>());
    });

    test('a fresh install reports no recovery notice', () async {
      final AppController controller = AppController();
      await controller.load();

      expect(controller.recoveryNotice, isEmpty);
      expect(controller.xp, 0);
      expect(await prefs.getString(kQuarantineKey), isNull);
    });

    test('dismissing the notice clears the quarantined blob', () async {
      await prefs.setString(kStateKey, 'nope');
      final AppController controller = AppController();
      await controller.load();
      expect(await prefs.getString(kQuarantineKey), isNotNull);

      await controller.dismissRecoveryNotice();

      expect(controller.recoveryNotice, isEmpty);
      expect(await prefs.getString(kQuarantineKey), isNull);
    });

    test('a legacy v3 profile still migrates', () async {
      await prefs.setString(kLegacyV3Key, profileJson(xp: 777, streak: 3));

      final AppController controller = AppController();
      await controller.load();

      expect(controller.xp, 777);
      expect(controller.recoveryNotice, isEmpty);
      // Migrated forward into the current key.
      expect(await prefs.getString(kStateKey), isNotNull);
    });
  });

  group('hostile and malformed values', () {
    test('wrong-typed scalars fall back instead of throwing', () async {
      await prefs.setString(
        kStateKey,
        jsonEncode(<String, dynamic>{
          'xp': 'not a number',
          'streak': <String>['also', 'wrong'],
          'dailyGoal': null,
          'ttsEnabled': 'yes',
          'themeMode': 42,
          'lastStudyDay': 99,
        }),
      );

      final AppController controller = AppController();
      await controller.load();

      // Every bad field independently falls back to its default.
      expect(controller.xp, 0);
      expect(controller.streak, 0);
      expect(controller.dailyGoal, 20);
      expect(controller.ttsEnabled, isTrue);
      expect(controller.lastStudyDay, '');
      // A structurally valid profile is not a recovery case.
      expect(controller.recoveryNotice, isEmpty);
    });

    test('a top-level JSON array is rejected as unreadable', () async {
      await prefs.setString(kStateKey, '[1, 2, 3]');

      final AppController controller = AppController();
      await controller.load();

      expect(controller.recoveryNotice, isNotEmpty);
      expect(await prefs.getString(kQuarantineKey), '[1, 2, 3]');
    });

    test('out-of-range scheduler state is clamped, not trusted', () {
      final WordProgress poisoned = WordProgress.fromJson(<String, dynamic>{
        'ease': 9999.0,
        'intervalDays': 1000000,
        'mastery': 99,
        'lapses': -5,
        'learningStep': 12345,
        'correct': -1,
      });

      expect(poisoned.ease, lessThanOrEqualTo(3.2));
      expect(poisoned.ease, greaterThanOrEqualTo(1.3));
      expect(poisoned.intervalDays, lessThanOrEqualTo(365));
      expect(poisoned.mastery, lessThanOrEqualTo(5));
      expect(poisoned.lapses, greaterThanOrEqualTo(0));
      expect(poisoned.learningStep, lessThanOrEqualTo(8));
      expect(poisoned.correct, greaterThanOrEqualTo(0));
    });

    test('a negative or absurd ease cannot poison the scheduler', () {
      final WordProgress negative =
          WordProgress.fromJson(<String, dynamic>{'ease': -12.0});
      expect(negative.ease, 1.3);
    });

    test('an unparseable date degrades to the epoch rather than throwing', () {
      final WordProgress bad =
          WordProgress.fromJson(<String, dynamic>{'dueAt': 'not-a-date'});
      expect(bad.dueAt, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });
}
