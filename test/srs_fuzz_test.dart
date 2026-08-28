import 'dart:math';

import 'package:deutsch_garden/srs.dart';
import 'package:flutter_test/flutter_test.dart';

/// One graduated review, returning the interval it produced.
int intervalFor(Random? fuzz, {int from = 20, double ease = 2.5}) {
  return Sm2Scheduler.schedule(
    ease: ease,
    intervalDays: from,
    reps: 5,
    lapses: 0,
    learningStep: 2,
    grade: ReviewGrade.good,
    fuzz: fuzz,
  ).intervalDays;
}

void main() {
  group('interval spread', () {
    test('without a source the interval is exactly what SM-2 computed', () {
      // 20 days at ease 2.5 is 50. Nothing may move it: this is the value the
      // grade buttons promise.
      expect(intervalFor(null), 50);
    });

    test('a session of identical cards no longer lands on one day', () {
      final Random seeded = Random(1234);
      final Set<int> days = <int>{
        for (int i = 0; i < 200; i++) intervalFor(seeded),
      };
      expect(days.length, greaterThan(1),
          reason: 'every card would come due on the same day, which is the '
              'clumping this exists to prevent');
    });

    test('the spread stays within five per cent and does not drift the mean',
        () {
      final Random seeded = Random(99);
      final List<int> runs = <int>[
        for (int i = 0; i < 2000; i++) intervalFor(seeded),
      ];

      // 5% of 50 is 3 (rounded), so the reachable band is 47..53.
      expect(runs.reduce(min), greaterThanOrEqualTo(47));
      expect(runs.reduce(max), lessThanOrEqualTo(53));

      // Spreading must not systematically lengthen or shorten the schedule.
      final double mean = runs.reduce((a, b) => a + b) / runs.length;
      expect((mean - 50).abs(), lessThan(0.5),
          reason: 'the spread should be symmetric about the computed value');
    });

    test('short intervals are left alone', () {
      final Random seeded = Random(7);
      // A card that has just graduated sits at 1 day. Moving it by a day is a
      // 100% change, which is not a spread but a different schedule.
      for (int i = 0; i < 50; i++) {
        final int next = Sm2Scheduler.schedule(
          ease: 2.5,
          intervalDays: 1,
          reps: 1,
          lapses: 0,
          learningStep: 2,
          grade: ReviewGrade.hard,
          fuzz: seeded,
        ).intervalDays;
        expect(next, lessThan(Sm2Scheduler.fuzzFloorDays));
      }
    });

    test('never returns less than a day or more than the ceiling', () {
      final Random seeded = Random(5);
      for (int i = 0; i < 500; i++) {
        final int next = intervalFor(seeded, from: 364, ease: 2.5);
        expect(next, greaterThanOrEqualTo(1));
        expect(next, lessThanOrEqualTo(Sm2Scheduler.maximumIntervalDays));
      }
    });

    test('the grade-button preview is not spread', () {
      // previewLabel must agree with the unfuzzed schedule, or the button
      // would advertise a number the scheduler then quietly changes.
      final String label = Sm2Scheduler.previewLabel(
        ease: 2.5,
        intervalDays: 20,
        reps: 5,
        lapses: 0,
        learningStep: 2,
        grade: ReviewGrade.good,
      );
      expect(label, '2 mo');
    });

    test('dueAt matches the interval that was returned', () {
      final Random seeded = Random(42);
      final DateTime now = DateTime(2026, 3, 1, 9);
      for (int i = 0; i < 100; i++) {
        final SrsOutcome outcome = Sm2Scheduler.schedule(
          ease: 2.5,
          intervalDays: 20,
          reps: 5,
          lapses: 0,
          learningStep: 2,
          grade: ReviewGrade.good,
          now: now,
          fuzz: seeded,
        );
        expect(outcome.dueAt, now.add(Duration(days: outcome.intervalDays)),
            reason: 'the stored due date must follow the spread interval, '
                'not the value before it was spread');
      }
    });
  });
}
