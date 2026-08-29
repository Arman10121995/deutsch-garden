import 'dart:convert';

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/backup.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  /// Swaps in an empty preferences store, so the next controller behaves like
  /// a clean install on a different machine rather than reading back what the
  /// previous controller just saved.
  void freshDevice() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  }

  setUp(freshDevice);

  Future<AppController> loadedController({bool onNewDevice = false}) async {
    if (onNewDevice) freshDevice();
    final AppController controller = AppController();
    await controller.load();
    return controller;
  }

  test('an exported profile restores onto a fresh install exactly', () async {
    final AppController source = await loadedController();
    final GermanWord word = vocabulary.first;
    await source.gradeWord(word, ReviewGrade.good);
    await source.gradeWord(word, ReviewGrade.good);
    await source.setMnemonic(word.id, 'a picture of a man waiting');
    await source.setDailyGoal(45);
    await source.setImmersionMode(true);
    await source.addMistake(
      MistakeEntry(
        id: 'test-1',
        prompt: 'p',
        correctAnswer: 'c',
        givenAnswer: 'g',
        source: 'vocabulary',
        level: 'A1',
        timestamp: DateTime.now(),
      ),
    );

    final String payload = ProgressBackup.export(source);
    final BackupImportResult exported = ProgressBackup.parse(payload);
    expect(
      exported.state!['reviewLog'],
      hasLength(2),
      reason:
          'a native backup must carry the log even when the saved '
          'profile keeps it in SQLite',
    );

    final AppController target = await loadedController(onNewDevice: true);
    expect(target.xp, 0, reason: 'target starts empty');

    final BackupImportResult result = ProgressBackup.parse(payload);
    expect(result.isSuccess, isTrue, reason: result.error);
    await target.restoreFrom(result.state!);

    expect(target.xp, source.xp);
    expect(target.dailyGoal, 45);
    expect(target.immersionMode, isTrue);
    expect(target.mistakes.length, 1);
    expect(target.progressFor(word.id).mnemonic, 'a picture of a man waiting');
    expect(
      target.progressFor(word.id).intervalDays,
      source.progressFor(word.id).intervalDays,
    );
    expect(target.progressFor(word.id).ease, source.progressFor(word.id).ease);
  });

  test('restoring replaces rather than merges', () async {
    final AppController source = await loadedController();
    final String payload = ProgressBackup.export(source);

    final AppController target = await loadedController(onNewDevice: true);
    await target.addMistake(
      MistakeEntry(
        id: 'local-only',
        prompt: 'p',
        correctAnswer: 'c',
        givenAnswer: 'g',
        source: 'grammar',
        level: 'A1',
        timestamp: DateTime.now(),
      ),
    );
    expect(target.mistakes, isNotEmpty);

    await target.restoreFrom(ProgressBackup.parse(payload).state!);
    expect(
      target.mistakes,
      isEmpty,
      reason: 'local state must not survive a restore',
    );
  });

  test('a malformed paste is rejected with a usable reason', () {
    expect(ProgressBackup.parse('').error, contains('Nothing'));
    expect(ProgressBackup.parse('not json at all').error, contains('JSON'));
    expect(
      ProgressBackup.parse('[1,2,3]').error,
      contains('not a DeutschGarden'),
    );
    expect(
      ProgressBackup.parse('{"format":"something.else"}').error,
      contains('not a DeutschGarden'),
    );
  });

  test('a backup from a newer format version is refused, not half-applied', () {
    final String payload = jsonEncode(<String, dynamic>{
      'format': ProgressBackup.magic,
      'formatVersion': ProgressBackup.formatVersion + 5,
      'state': <String, dynamic>{'xp': 10},
    });
    final BackupImportResult result = ProgressBackup.parse(payload);
    expect(result.isSuccess, isFalse);
    expect(result.error, contains('newer version'));
  });

  test('a backup missing its state section is refused', () {
    final String payload = jsonEncode(<String, dynamic>{
      'format': ProgressBackup.magic,
      'formatVersion': 1,
    });
    expect(ProgressBackup.parse(payload).isSuccess, isFalse);
  });

  test('the summary reports what the learner is about to overwrite', () async {
    final AppController source = await loadedController();
    await source.gradeWord(vocabulary.first, ReviewGrade.good);
    final BackupImportResult result = ProgressBackup.parse(
      ProgressBackup.export(source),
    );
    final String summary = ProgressBackup.describe(result.state!);
    expect(summary, contains('XP'));
    expect(summary, contains('words'));
    expect(result.sourcePlatform, isNotEmpty);
  });

  test('merge keeps disjoint learning and local device preferences', () {
    final String firstId = vocabulary[0].id;
    final String secondId = vocabulary[1].id;
    final Map<String, dynamic> local = <String, dynamic>{
      'themeMode': 'dark',
      'ttsEnabled': false,
      'remindersEnabled': true,
      'progress': <String, dynamic>{
        firstId: WordProgress(seen: true, mastery: 2, favorite: true).toJson(),
      },
      'activities': <String, dynamic>{
        'local-lesson': ActivityProgress(
          completed: true,
          bestScore: 80,
        ).toJson(),
      },
    };
    final Map<String, dynamic> incoming = <String, dynamic>{
      'themeMode': 'light',
      'ttsEnabled': true,
      'remindersEnabled': false,
      'progress': <String, dynamic>{
        secondId: WordProgress(seen: true, mastery: 3).toJson(),
      },
      'activities': <String, dynamic>{
        'remote-lesson': ActivityProgress(
          completed: true,
          bestScore: 90,
        ).toJson(),
      },
    };

    final Map<String, dynamic> merged = ProgressBackup.merge(local, incoming);
    expect(
      (merged['progress'] as Map).keys,
      containsAll(<String>[firstId, secondId]),
    );
    expect(
      (merged['activities'] as Map).keys,
      containsAll(<String>['local-lesson', 'remote-lesson']),
    );
    expect(merged['themeMode'], 'dark');
    expect(merged['ttsEnabled'], isFalse);
    expect(merged['remindersEnabled'], isTrue);
  });

  test(
    'merge de-duplicates shared history and uses the newer item schedule',
    () {
      final String id = vocabulary.first.id;
      ReviewEvent event(int seconds, ReviewGrade grade, int repsBefore) =>
          ReviewEvent(
            itemId: id,
            at: DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
            grade: grade,
            intervalBefore: repsBefore * 2,
            easeBefore: 2.5,
            dueBefore: DateTime.fromMillisecondsSinceEpoch(
              (seconds - 86400) * 1000,
            ),
            repsBefore: repsBefore,
            lapsesBefore: 0,
            stepBefore: 2,
          );

      final ReviewEvent common = event(1700000000, ReviewGrade.good, 1);
      final ReviewEvent localOnly = event(1700100000, ReviewGrade.hard, 2);
      final ReviewEvent newerRemote = event(1700200000, ReviewGrade.easy, 3);
      final Map<String, dynamic> local = <String, dynamic>{
        'progress': <String, dynamic>{
          id: WordProgress(
            seen: true,
            reps: 3,
            intervalDays: 8,
            dueAt: DateTime(2026, 9, 1),
            favorite: true,
          ).toJson(),
        },
        'reviewLog': <Object>[common.toJson(), localOnly.toJson()],
      };
      final Map<String, dynamic> incoming = <String, dynamic>{
        'progress': <String, dynamic>{
          id: WordProgress(
            seen: true,
            reps: 4,
            intervalDays: 21,
            dueAt: DateTime(2026, 9, 20),
            mnemonic: 'remote memory hook',
          ).toJson(),
        },
        'reviewLog': <Object>[common.toJson(), newerRemote.toJson()],
      };

      final Map<String, dynamic> merged = ProgressBackup.merge(local, incoming);
      expect(merged['reviewLog'], hasLength(3));
      final Map<String, dynamic> item = Map<String, dynamic>.from(
        (merged['progress'] as Map)[id] as Map,
      );
      expect(item['intervalDays'], 21);
      expect(
        item['favorite'],
        isTrue,
        reason: 'an independent flag is unioned',
      );
      expect(item['mnemonic'], 'remote memory hook');
    },
  );
}
