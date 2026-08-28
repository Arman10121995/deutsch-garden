import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

final DateTime kNow = DateTime(2026, 6, 1, 12);

/// One stored event. [intervalBefore] of 0 means the card was still in its
/// learning steps, which retention must ignore.
List<Object> event({
  required String id,
  required int daysAgo,
  required ReviewGrade grade,
  int intervalBefore = 10,
  bool scheduled = true,
}) {
  final DateTime at = kNow.subtract(Duration(days: daysAgo));
  return <Object>[
    id,
    at.millisecondsSinceEpoch ~/ 1000,
    grade.index,
    intervalBefore,
    2.5,
    scheduled
        ? at.subtract(Duration(days: intervalBefore)).millisecondsSinceEpoch ~/
            1000
        : 0,
    3,
    0,
    2,
  ];
}

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<AppController> withLog(List<List<Object>> log) async {
    final AppController c = AppController();
    addTearDown(c.dispose);
    await c.load();
    await c.restoreFrom(<String, dynamic>{'reviewLog': log});
    return c;
  }

  group('true retention', () {
    testWidgets('is the share of scheduled reviews recalled',
        (WidgetTester tester) async {
      final AppController c = await withLog(<List<Object>>[
        for (int i = 0; i < 15; i++)
          event(id: 'w$i', daysAgo: 3, grade: ReviewGrade.good),
        for (int i = 0; i < 5; i++)
          event(id: 'f$i', daysAgo: 3, grade: ReviewGrade.again),
      ]);
      expect(c.trueRetention(now: kNow), closeTo(0.75, 0.001));
    });

    testWidgets('ignores answers given while the card was still in learning',
        (WidgetTester tester) async {
      // Getting a card right ten minutes after first seeing it is not
      // evidence of retention, and counting it inflates the figure toward
      // meaninglessness -- which is exactly what all-time accuracy does.
      final AppController c = await withLog(<List<Object>>[
        for (int i = 0; i < 20; i++)
          event(id: 'g$i', daysAgo: 2, grade: ReviewGrade.good),
        for (int i = 0; i < 200; i++)
          event(
              id: 'learn$i',
              daysAgo: 2,
              grade: ReviewGrade.good,
              intervalBefore: 0,
              scheduled: false),
        for (int i = 0; i < 20; i++)
          event(id: 'b$i', daysAgo: 2, grade: ReviewGrade.again),
      ]);
      expect(c.trueRetention(now: kNow), closeTo(0.5, 0.001),
          reason: '200 learning-step answers must not drag it toward 1.0');
    });

    testWidgets('covers a window, so it can fall',
        (WidgetTester tester) async {
      final AppController c = await withLog(<List<Object>>[
        // Long ago: all correct.
        for (int i = 0; i < 40; i++)
          event(id: 'old$i', daysAgo: 200, grade: ReviewGrade.good),
        // Recently: half wrong.
        for (int i = 0; i < 10; i++)
          event(id: 'new$i', daysAgo: 2, grade: ReviewGrade.good),
        for (int i = 0; i < 10; i++)
          event(id: 'bad$i', daysAgo: 2, grade: ReviewGrade.again),
      ]);
      expect(c.trueRetention(now: kNow), closeTo(0.5, 0.001),
          reason: 'a figure that can only rise is not a measurement');
      expect(c.trueRetention(window: const Duration(days: 365), now: kNow),
          closeTo(50 / 60, 0.001));
    });

    testWidgets('declines to answer on too small a sample',
        (WidgetTester tester) async {
      final AppController c = await withLog(<List<Object>>[
        for (int i = 0; i < 3; i++)
          event(id: 'w$i', daysAgo: 1, grade: ReviewGrade.good),
      ]);
      expect(c.trueRetention(now: kNow), isNull,
          reason: 'three answers is not a percentage worth printing');
      expect(c.trueRetention(now: kNow, minimumSample: 3), closeTo(1.0, 0.001));
    });

    testWidgets('is null on an empty log', (WidgetTester tester) async {
      final AppController c = await withLog(<List<Object>>[]);
      expect(c.trueRetention(now: kNow), isNull);
    });
  });

  group('retention by interval', () {
    testWidgets('groups by how long the card had been waiting',
        (WidgetTester tester) async {
      final AppController c = await withLog(<List<Object>>[
        // Short intervals: recalled well.
        for (int i = 0; i < 20; i++)
          event(
              id: 's$i',
              daysAgo: 5,
              grade: ReviewGrade.good,
              intervalBefore: 1),
        // Long intervals: falling over.
        for (int i = 0; i < 10; i++)
          event(
              id: 'l$i',
              daysAgo: 5,
              grade: ReviewGrade.good,
              intervalBefore: 90),
        for (int i = 0; i < 10; i++)
          event(
              id: 'x$i',
              daysAgo: 5,
              grade: ReviewGrade.again,
              intervalBefore: 90),
      ]);

      final Map<String, double> buckets = c.retentionByInterval();
      expect(buckets['1 day'], closeTo(1.0, 0.001));
      expect(buckets['60+ days'], closeTo(0.5, 0.001));
      expect(buckets.containsKey('2-7 days'), isFalse,
          reason: 'an empty bucket is omitted rather than shown as 0%');
    });

    testWidgets('omits buckets too thin to mean anything',
        (WidgetTester tester) async {
      final AppController c = await withLog(<List<Object>>[
        for (int i = 0; i < 4; i++)
          event(
              id: 't$i',
              daysAgo: 1,
              grade: ReviewGrade.good,
              intervalBefore: 3),
      ]);
      expect(c.retentionByInterval(), isEmpty);
      expect(c.retentionByInterval(minimumSample: 4)['2-7 days'],
          closeTo(1.0, 0.001));
    });
  });

  group('due forecast', () {
    testWidgets('counts what falls due on each of the next days',
        (WidgetTester tester) async {
      final AppController c = AppController();
      addTearDown(c.dispose);
      await c.load();
      await c.restoreFrom(<String, dynamic>{
        'progress': <String, dynamic>{
          vocabulary[0].id: <String, dynamic>{
            'seen': true,
            'intervalDays': 3,
            'dueAt': kNow.add(const Duration(days: 2)).toIso8601String(),
          },
          vocabulary[1].id: <String, dynamic>{
            'seen': true,
            'intervalDays': 3,
            'dueAt': kNow.add(const Duration(days: 2)).toIso8601String(),
          },
          // Overdue by a fortnight: belongs to today, not to a negative day.
          vocabulary[2].id: <String, dynamic>{
            'seen': true,
            'intervalDays': 3,
            'dueAt': kNow.subtract(const Duration(days: 14)).toIso8601String(),
          },
        },
      });

      final List<int> forecast = c.dueForecast(days: 7, now: kNow);
      expect(forecast, hasLength(7));
      expect(forecast[0], 1, reason: 'the overdue card lands on today');
      expect(forecast[2], 2);
      expect(forecast.reduce((int a, int b) => a + b), 3);
    });

    testWidgets('an unseen card is not forecast', (WidgetTester tester) async {
      final AppController c = AppController();
      addTearDown(c.dispose);
      await c.load();
      expect(c.dueForecast(days: 5, now: kNow), <int>[0, 0, 0, 0, 0]);
    });
  });
}
