import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/clock.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// A clock a test can wind by hand.
class Winder {
  Winder(this.at);
  DateTime at;
  AppClock get clock => AppClock(read: () => at);
}

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<AppController> bootAt(Winder w) async {
    final AppController c = AppController();
    addTearDown(c.dispose);
    c.clock = w.clock;
    await c.load();
    return c;
  }

  group('the clock', () {
    test('defaults to the system clock', () {
      final DateTime before = DateTime.now();
      final DateTime read = AppClock().now();
      expect(read.difference(before).inSeconds.abs(), lessThan(5));
    });

    test('a fixed clock does not move', () {
      final DateTime at = DateTime(2026, 3, 29, 1, 30);
      final AppClock clock = AppClock.fixed(at);
      expect(clock.now(), at);
      expect(clock.now(), at);
    });
  });

  group('day boundaries', () {
    testWidgets('studying either side of midnight extends the streak once',
        (WidgetTester tester) async {
      final Winder w = Winder(DateTime(2026, 5, 10, 23, 59));
      final AppController c = await bootAt(w);

      await c.gradeWord(vocabulary[0], ReviewGrade.good);
      final int afterFirstDay = c.streak;
      expect(afterFirstDay, greaterThanOrEqualTo(1));

      // Two minutes later, but the next calendar day.
      w.at = DateTime(2026, 5, 11, 0, 1);
      await c.gradeWord(vocabulary[1], ReviewGrade.good);

      expect(c.streak, afterFirstDay + 1,
          reason: 'a new calendar day continues the streak, and does so '
              'exactly once however many cards are answered');

      await c.gradeWord(vocabulary[2], ReviewGrade.good);
      expect(c.streak, afterFirstDay + 1,
          reason: 'a second card the same day must not bump it again');
    });

    testWidgets('the daily counter rolls over at midnight, not after 24 hours',
        (WidgetTester tester) async {
      final Winder w = Winder(DateTime(2026, 5, 10, 23, 50));
      final AppController c = await bootAt(w);

      await c.gradeWord(vocabulary[0], ReviewGrade.good);
      await c.gradeWord(vocabulary[1], ReviewGrade.good);
      final int reviewsBefore = c.todayReviews;
      expect(reviewsBefore, greaterThan(0));

      w.at = DateTime(2026, 5, 11, 0, 5);
      await c.gradeWord(vocabulary[2], ReviewGrade.good);

      expect(c.todayReviews, lessThan(reviewsBefore + 3),
          reason: 'fifteen minutes later is a new day, so the count restarts '
              'rather than continuing');
    });

    testWidgets('a missed day breaks the streak',
        (WidgetTester tester) async {
      final Winder w = Winder(DateTime(2026, 5, 10, 12));
      final AppController c = await bootAt(w);
      await c.gradeWord(vocabulary[0], ReviewGrade.good);
      final int built = c.streak;

      // Skip the 11th entirely.
      w.at = DateTime(2026, 5, 12, 12);
      await c.gradeWord(vocabulary[1], ReviewGrade.good);

      expect(c.streak, lessThanOrEqualTo(built),
          reason: 'a day with no study cannot leave the streak longer');
    });

    testWidgets('a 23-hour spring-forward day still rolls over once',
        (WidgetTester tester) async {
      // Central European summer time begins at 02:00 on 29 March 2026: the
      // local day is 23 hours long. Anything that measures a day as
      // "now minus 24 hours" gets this wrong.
      final Winder w = Winder(DateTime(2026, 3, 29, 1, 30));
      final AppController c = await bootAt(w);
      await c.gradeWord(vocabulary[0], ReviewGrade.good);
      final int before = c.streak;

      w.at = DateTime(2026, 3, 30, 1, 0);
      await c.gradeWord(vocabulary[1], ReviewGrade.good);

      expect(c.streak, before + 1,
          reason: 'the calendar day changed once, so the streak moves once, '
              'however many hours the day actually held');
    });
  });

  group('scheduling reads the same clock', () {
    testWidgets('a card graded at a fixed time is due relative to it',
        (WidgetTester tester) async {
      final Winder w = Winder(DateTime(2026, 5, 10, 9));
      final AppController c = await bootAt(w);

      await c.gradeWord(vocabulary[0], ReviewGrade.good);

      expect(c.progressFor(vocabulary[0].id).dueAt.isAfter(w.at), isTrue);
      expect(c.reviewLog.single.at, w.at,
          reason: 'the logged timestamp must come from the same clock as the '
              'scheduling, or history and schedule disagree');
    });
  });
}
