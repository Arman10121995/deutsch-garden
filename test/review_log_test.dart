import 'dart:convert';

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const String kStateKey = 'deutsch_garden_state_v4';

Future<AppController> boot() async {
  final AppController controller = AppController();
  await controller.load();
  return controller;
}

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('the review log', () {
    testWidgets('records the state the answer was given against, not the '
        'state it produced', (WidgetTester tester) async {
      final AppController controller = await boot();
      addTearDown(controller.dispose);
      final GermanWord word = vocabulary.first;

      await controller.gradeWord(word, ReviewGrade.good);

      expect(controller.reviewLog, hasLength(1));
      final ReviewEvent event = controller.reviewLog.single;
      expect(event.itemId, word.id);
      expect(event.grade, ReviewGrade.good);
      // A card that has never been reviewed is on no interval and the
      // starting ease. Recording the *outcome* instead would make every
      // event describe a card that was already scheduled, which is useless
      // for fitting anything.
      expect(event.intervalBefore, 0);
      expect(event.easeBefore, Sm2Scheduler.startingEase);

      // Walk it out of learning. Once it is on a real interval, each event's
      // intervalBefore must be the interval the card had when the question
      // was asked -- not the one the answer moved it to.
      await controller.gradeWord(word, ReviewGrade.good);
      await controller.gradeWord(word, ReviewGrade.good);
      final int intervalNow = controller.progressFor(word.id).intervalDays;
      final ReviewEvent last = controller.reviewLog.last;
      expect(last.intervalBefore, 1,
          reason: 'the card had just graduated onto a one-day interval');
      expect(intervalNow, greaterThan(last.intervalBefore),
          reason: 'recording the outcome instead would describe a card that '
              'was already scheduled, which cannot be fitted against');
    });

    testWidgets('lessons are logged as well as cards',
        (WidgetTester tester) async {
      final AppController controller = await boot();
      addTearDown(controller.dispose);

      await controller.recordActivity('some-lesson-id', score: 100);

      expect(controller.reviewLog.map((ReviewEvent e) => e.itemId),
          contains('some-lesson-id'));
      expect(controller.reviewLog.single.grade, ReviewGrade.easy);
    });

    testWidgets('a failed lesson is not silently dropped from the history',
        (WidgetTester tester) async {
      final AppController controller = await boot();
      addTearDown(controller.dispose);

      // Below the pass mark is a lapse, and a lapse is exactly the event a
      // scheduler most needs to see.
      await controller.recordActivity('failed-lesson', score: 10);
      await controller.recordActivity('failed-lesson', score: 100);

      expect(controller.reviewLog.map((ReviewEvent e) => e.grade),
          <ReviewGrade>[ReviewGrade.again, ReviewGrade.easy]);
    });

    testWidgets('the log survives a save and reload',
        (WidgetTester tester) async {
      final AppController first = await boot();
      addTearDown(first.dispose);
      await first.gradeWord(vocabulary[0], ReviewGrade.good);
      await first.gradeWord(vocabulary[1], ReviewGrade.again);
      await first.gradeWord(vocabulary[0], ReviewGrade.easy);
      await first.flushSave();

      final AppController second = AppController();
      addTearDown(second.dispose);
      await second.load();

      expect(second.reviewLog, hasLength(3));
      expect(second.reviewLog.map((ReviewEvent e) => e.grade),
          <ReviewGrade>[ReviewGrade.good, ReviewGrade.again, ReviewGrade.easy]);
      expect(second.reviewLog.map((ReviewEvent e) => e.itemId),
          <String>[vocabulary[0].id, vocabulary[1].id, vocabulary[0].id]);
      expect(second.reviewLog.first.easeBefore, Sm2Scheduler.startingEase);
    });

    testWidgets('the oldest entries are dropped once it is full',
        (WidgetTester tester) async {
      final AppController controller = await boot();
      addTearDown(controller.dispose);

      // Fill past the ceiling by restoring a log rather than grading 5,001
      // cards, which would take minutes and prove the same thing.
      final List<List<Object>> overflowing = <List<Object>>[
        for (int i = 0; i < AppController.reviewLogLimit + 25; i++)
          <Object>['card-$i', 1700000000 + i, 2, 5, 2.5, 1699999000, 3, 0, 2],
      ];
      await controller.restoreFrom(<String, dynamic>{
        'reviewLog': overflowing,
      });

      expect(controller.reviewLog, hasLength(AppController.reviewLogLimit));
      expect(controller.reviewLog.first.itemId, 'card-25',
          reason: 'the oldest 25 should have gone, not the newest');
      expect(controller.reviewLog.last.itemId,
          'card-${AppController.reviewLogLimit + 24}');
    });

    testWidgets('grading past the ceiling drops from the front',
        (WidgetTester tester) async {
      final AppController controller = await boot();
      addTearDown(controller.dispose);
      await controller.restoreFrom(<String, dynamic>{
        'reviewLog': <List<Object>>[
          for (int i = 0; i < AppController.reviewLogLimit; i++)
            <Object>['old-$i', 1700000000 + i, 2, 5, 2.5, 1699999000, 3, 0, 2],
        ],
      });
      expect(controller.reviewLog, hasLength(AppController.reviewLogLimit));

      await controller.gradeWord(vocabulary.first, ReviewGrade.good);

      expect(controller.reviewLog, hasLength(AppController.reviewLogLimit));
      expect(controller.reviewLog.first.itemId, 'old-1');
      expect(controller.reviewLog.last.itemId, vocabulary.first.id);
    });

    testWidgets('one unreadable entry costs that entry, not the history',
        (WidgetTester tester) async {
      final AppController controller = await boot();
      addTearDown(controller.dispose);

      await controller.restoreFrom(<String, dynamic>{
        'reviewLog': <Object>[
          <Object>['good-1', 1700000000, 2, 5, 2.5, 1699999000, 3, 0, 2],
          'not a list at all',
          <Object>['too', 'short'],
          <Object>['bad-grade', 1700000002, 99, 5, 2.5, 1699999000, 3, 0, 2],
          <Object>['good-2', 1700000003, 0, 5, 2.5, 1699999000, 3, 0, 2],
        ],
      });

      expect(controller.reviewLog.map((ReviewEvent e) => e.itemId),
          <String>['good-1', 'good-2']);
    });

    testWidgets('the stored form is positional, so the blob stays small',
        (WidgetTester tester) async {
      final AppController controller = await boot();
      addTearDown(controller.dispose);
      await controller.gradeWord(vocabulary.first, ReviewGrade.good);
      await controller.flushSave();

      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      final Map<String, dynamic> saved =
          jsonDecode((await prefs.getString(kStateKey))!)
              as Map<String, dynamic>;
      final List<dynamic> log = saved['reviewLog'] as List<dynamic>;
      expect(log.single, isA<List<dynamic>>(),
          reason: 'keyed objects would roughly double the log inside a blob '
              'that is rewritten on every save');
      expect((log.single as List<dynamic>).length, 9);
    });
  });

  group('the persisted grade encoding', () {
    test('ReviewGrade order is part of the stored format', () {
      // Events store grade.index. Reordering this enum would silently
      // reinterpret every review already on disk.
      expect(ReviewGrade.values, <ReviewGrade>[
        ReviewGrade.again,
        ReviewGrade.hard,
        ReviewGrade.good,
        ReviewGrade.easy,
      ]);
    });
  });

  group('elapsed days', () {
    testWidgets('is the gap since the previous review, including lateness',
        (WidgetTester tester) async {
      final AppController controller = await boot();
      addTearDown(controller.dispose);
      final GermanWord word = vocabulary.first;

      // A card sitting on a 10-day interval whose due date passed 4 days ago
      // was last reviewed 14 days back.
      await controller.restoreFrom(<String, dynamic>{
        'progress': <String, dynamic>{
          word.id: <String, dynamic>{
            'seen': true,
            'ease': 2.5,
            'intervalDays': 10,
            'reps': 6,
            'learningStep': 2,
            'dueAt': DateTime.now()
                .subtract(const Duration(days: 4))
                .toIso8601String(),
          },
        },
      });

      await controller.gradeWord(word, ReviewGrade.good);

      expect(controller.reviewLog.single.elapsedDays, 14);
    });

    testWidgets('is null, meaning unknown, for a card never scheduled',
        (WidgetTester tester) async {
      // Not zero: zero would read as "reviewed today", which is a different
      // and wrong claim to make to anything fitting a scheduler.
      final AppController controller = await boot();
      addTearDown(controller.dispose);
      await controller.gradeWord(vocabulary.first, ReviewGrade.good);
      expect(controller.reviewLog.single.elapsedDays, isNull);
      expect(controller.reviewLog.single.wasScheduled, isFalse);
    });
  });
}
