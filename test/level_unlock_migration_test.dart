import 'dart:convert';

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/curriculum.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const String kStateKey = 'deutsch_garden_state_v4';

void main() {
  late SharedPreferencesAsync prefs;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = SharedPreferencesAsync();
  });

  String todayKey() {
    final DateTime now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  bool isExpandedWordId(String id) {
    if (id.length < 2 || id[0].toLowerCase() != 'x') return false;
    final int? number = int.tryParse(id.substring(1));
    return number != null && number >= 20000;
  }

  bool isExpandedGrammarId(String id) {
    final RegExpMatch? match = RegExp(r'-x(\d+)$').firstMatch(id);
    final int? number = int.tryParse(match?.group(1) ?? '');
    return number != null && number >= 13;
  }

  Map<String, dynamic> passedActivity() => <String, dynamic>{
    'bestScore': 70,
    'completed': true,
    // Keep this realistic old progress out of the unrelated review-date
    // staggering migration, so only the unlock migration dirties the blob.
    'dueAt': DateTime(2099).toIso8601String(),
  };

  test('old progress keeps the level it unlocked before expansion', () async {
    final List<GermanWord> legacyA1Words = vocabulary
        .where(
          (word) =>
              word.level == CefrLevel.a1.label && !isExpandedWordId(word.id),
        )
        .toList(growable: false);
    final List<String> legacyA1Grammar = grammarFor(CefrLevel.a1)
        .where((lesson) => !isExpandedGrammarId(lesson.id))
        .map((lesson) => lesson.id)
        .toList(growable: false);
    final List<String> listening = listeningFor(
      CefrLevel.a1,
    ).map((lesson) => lesson.id).toList(growable: false);
    final List<String> reading = readingFor(
      CefrLevel.a1,
    ).map((lesson) => lesson.id).toList(growable: false);

    expect(legacyA1Words, isNotEmpty);
    expect(legacyA1Grammar, hasLength(16));
    expect(grammarFor(CefrLevel.a1).length, greaterThan(16));

    await prefs.setString(
      kStateKey,
      jsonEncode(<String, dynamic>{
        'dailyCounterDay': todayKey(),
        'questDay': todayKey(),
        // No earnedUnlockedOrder: this is a pre-migration profile.
        'progress': <String, dynamic>{
          for (final GermanWord word in legacyA1Words)
            word.id: <String, dynamic>{'mastery': 3, 'seen': true},
        },
        'activities': <String, dynamic>{
          for (final String id in <String>[
            ...legacyA1Grammar,
            ...listening,
            ...reading,
          ])
            id: passedActivity(),
        },
      }),
    );

    final AppController controller = AppController();
    await controller.load();

    // Under the old 150-word/16-grammar denominator, four of six skills were
    // complete (4 / 6 > .65), so A2 had been earned. The expanded denominator
    // now puts live A1 progress below the threshold, but must not relock A2.
    expect(
      controller.levelProgress(CefrLevel.a1),
      lessThan(AppController.levelUnlockThreshold),
    );
    expect(controller.earnedUnlockedOrder, CefrLevel.a2.order);
    expect(controller.isLevelUnlocked(CefrLevel.a2), isTrue);
    expect(controller.isLevelUnlocked(CefrLevel.b1), isFalse);

    final Map<String, dynamic> persisted =
        jsonDecode((await prefs.getString(kStateKey))!) as Map<String, dynamic>;
    expect(persisted['earnedUnlockedOrder'], CefrLevel.a2.order);
  });

  test(
    'a newly earned floor survives progress loss and a load round trip',
    () async {
      final List<String> completedA1Activities = <String>[
        ...grammarFor(CefrLevel.a1).map((lesson) => lesson.id),
        ...listeningFor(CefrLevel.a1).map((lesson) => lesson.id),
        ...readingFor(CefrLevel.a1).map((lesson) => lesson.id),
        ...writingFor(CefrLevel.a1).map((lesson) => lesson.id),
      ];
      final AppController source = AppController();
      await source.restoreFrom(<String, dynamic>{
        'earnedUnlockedOrder': CefrLevel.a1.order,
        'placementUnlockedOrder': -1,
        'dailyCounterDay': todayKey(),
        'questDay': todayKey(),
        'activities': <String, dynamic>{
          for (final String id in completedA1Activities) id: passedActivity(),
        },
      });

      expect(source.levelProgress(CefrLevel.a1), greaterThanOrEqualTo(2 / 3));
      expect(source.earnedUnlockedOrder, CefrLevel.a2.order);

      final Map<String, dynamic> saved =
          jsonDecode((await prefs.getString(kStateKey))!)
              as Map<String, dynamic>;
      expect(saved['earnedUnlockedOrder'], CefrLevel.a2.order);

      // Simulate curriculum progress becoming unavailable after that save. The
      // stored floor, not today's denominator, remains authoritative.
      saved['progress'] = <String, dynamic>{};
      saved['activities'] = <String, dynamic>{};
      await prefs.setString(kStateKey, jsonEncode(saved));

      final AppController roundTripped = AppController();
      await roundTripped.load();

      expect(roundTripped.levelProgress(CefrLevel.a1), 0);
      expect(roundTripped.earnedUnlockedOrder, CefrLevel.a2.order);
      expect(roundTripped.highestUnlockedLevel, CefrLevel.a2);
    },
  );

  test('placement unlocks remain independent of the earned floor', () async {
    final AppController controller = AppController();
    await controller.load();

    await controller.savePlacementResult(CefrLevel.b1, score: 88);

    expect(controller.placementUnlockedOrder, CefrLevel.b1.order);
    expect(controller.earnedUnlockedOrder, CefrLevel.a1.order);
    expect(controller.highestUnlockedLevel, CefrLevel.b1);

    final Map<String, dynamic> persisted =
        jsonDecode((await prefs.getString(kStateKey))!) as Map<String, dynamic>;
    expect(persisted['placementUnlockedOrder'], CefrLevel.b1.order);
    expect(persisted['earnedUnlockedOrder'], CefrLevel.a1.order);
  });
}
