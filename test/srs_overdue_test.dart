import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

final DateTime kNow = DateTime(2026, 6, 1, 10);

int graded(ReviewGrade grade, {required int daysLate, int from = 10}) {
  return Sm2Scheduler.schedule(
    ease: 2.5,
    intervalDays: from,
    reps: 6,
    lapses: 0,
    learningStep: 2,
    grade: grade,
    now: kNow,
    dueAt: kNow.subtract(Duration(days: daysLate)),
  ).intervalDays;
}

void main() {
  group('overdue reviews', () {
    test('a late Good is scheduled further out than an on-time one', () {
      final int onTime = graded(ReviewGrade.good, daysLate: 0);
      final int late = graded(ReviewGrade.good, daysLate: 30);

      expect(onTime, 25, reason: '10 days at ease 2.5');
      // Half of the 30-day delay is credited: (10 + 15) * 2.5.
      expect(late, 63);
      expect(late, greaterThan(onTime),
          reason: 'thirty extra days of retention is evidence the interval '
              'was too short, and throwing it away asks the learner the same '
              'card on the same old cadence');
    });

    test('Easy credits the whole delay, Good half of it', () {
      final int good = graded(ReviewGrade.good, daysLate: 20);
      final int easy = graded(ReviewGrade.easy, daysLate: 20);
      expect(good, 50); // (10 + 10) * 2.5
      expect(easy, 103); // (10 + 20) * 2.65 * 1.3
      expect(easy, greaterThan(good));
    });

    test('Hard credits nothing, however late it was', () {
      expect(graded(ReviewGrade.hard, daysLate: 0),
          graded(ReviewGrade.hard, daysLate: 40),
          reason: 'a struggled recall is not evidence of retention');
    });

    test('answering early is never punished', () {
      // difference() is negative here; it must not shorten the interval.
      final int early = Sm2Scheduler.schedule(
        ease: 2.5,
        intervalDays: 10,
        reps: 6,
        lapses: 0,
        learningStep: 2,
        grade: ReviewGrade.good,
        now: kNow,
        dueAt: kNow.add(const Duration(days: 5)),
      ).intervalDays;
      expect(early, 25);
    });

    test('a very long absence is capped rather than compounded', () {
      final int twoMonths = graded(ReviewGrade.good, daysLate: 60);
      final int twoYears = graded(ReviewGrade.good, daysLate: 730);
      expect(twoYears, twoMonths,
          reason: 'coming back after two years says little about retention, '
              'and should not hand out a multi-year interval');
    });

    test('omitting the due date behaves exactly as before', () {
      final int without = Sm2Scheduler.schedule(
        ease: 2.5,
        intervalDays: 10,
        reps: 6,
        lapses: 0,
        learningStep: 2,
        grade: ReviewGrade.good,
        now: kNow,
      ).intervalDays;
      expect(without, 25);
    });
  });

  group('through the controller', () {
    setUp(() {
      AppController.debounceWrites = false;
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    testWidgets('a restored card with no due date is not decades overdue',
        (WidgetTester tester) async {
      // Both progress models default dueAt to the epoch. A profile that
      // carries an interval but no due date -- an older export, a partial
      // restore -- would otherwise reach the graduated branch looking like it
      // was due in 1970 and collect the full lateness credit on the next
      // answer.
      final GermanWord word = vocabulary.first;
      final AppController controller = AppController();
      addTearDown(controller.dispose);
      await controller.load();
      await controller.restoreFrom(<String, dynamic>{
        'progress': <String, dynamic>{
          word.id: <String, dynamic>{
            'seen': true,
            'ease': 2.5,
            'intervalDays': 10,
            'reps': 6,
            'lapses': 0,
            'learningStep': 2,
            // deliberately no dueAt
          },
        },
      });

      final WordProgress restored = controller.progressFor(word.id);
      expect(restored.intervalDays, 10);
      expect(restored.dueAt.millisecondsSinceEpoch, 0,
          reason: 'the sentinel this test exists to guard against');

      await controller.gradeWord(word, ReviewGrade.good);

      // Unfuzzed this is 25; the spread reaches 24..26. Full lateness credit
      // would instead give (10 + 30) * 2.5 = 100.
      expect(controller.progressFor(word.id).intervalDays, lessThan(30),
          reason: 'a missing due date must not be read as decades of '
              'retention and inflate the interval');
    });
  });
}
