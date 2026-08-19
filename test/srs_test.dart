import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a new card walks the learning steps before graduating', () {
    final SrsOutcome first = Sm2Scheduler.schedule(
      ease: 2.5,
      intervalDays: 0,
      reps: 0,
      lapses: 0,
      learningStep: 0,
      grade: ReviewGrade.good,
    );
    expect(first.intervalDays, 0, reason: 'still in learning');
    expect(first.learningStep, 1);

    final SrsOutcome second = Sm2Scheduler.schedule(
      ease: first.ease,
      intervalDays: first.intervalDays,
      reps: first.reps,
      lapses: first.lapses,
      learningStep: first.learningStep,
      grade: ReviewGrade.good,
    );
    expect(second.intervalDays, 1, reason: 'graduates to one day');
  });

  test('easy graduates immediately and raises ease', () {
    final SrsOutcome outcome = Sm2Scheduler.schedule(
      ease: 2.5,
      intervalDays: 0,
      reps: 0,
      lapses: 0,
      learningStep: 0,
      grade: ReviewGrade.easy,
    );
    expect(outcome.intervalDays, greaterThan(1));
    expect(outcome.ease, greaterThan(2.5));
  });

  test('intervals grow by the ease factor on a graduated card', () {
    final SrsOutcome outcome = Sm2Scheduler.schedule(
      ease: 2.5,
      intervalDays: 10,
      reps: 4,
      lapses: 0,
      learningStep: 2,
      grade: ReviewGrade.good,
    );
    expect(outcome.intervalDays, 25);
  });

  test('again lapses the card back into relearning and lowers ease', () {
    final SrsOutcome outcome = Sm2Scheduler.schedule(
      ease: 2.5,
      intervalDays: 30,
      reps: 6,
      lapses: 1,
      learningStep: 2,
      grade: ReviewGrade.again,
    );
    expect(outcome.intervalDays, 0);
    expect(outcome.lapses, 2);
    expect(outcome.ease, lessThan(2.5));
  });

  test('ease never falls below the floor', () {
    double ease = 2.5;
    for (int i = 0; i < 20; i++) {
      ease = Sm2Scheduler.schedule(
        ease: ease,
        intervalDays: 5,
        reps: 3,
        lapses: 0,
        learningStep: 2,
        grade: ReviewGrade.again,
      ).ease;
    }
    expect(ease, greaterThanOrEqualTo(Sm2Scheduler.minimumEase));
  });

  test('intervals are capped so a card never disappears for years', () {
    final SrsOutcome outcome = Sm2Scheduler.schedule(
      ease: 3.2,
      intervalDays: 300,
      reps: 20,
      lapses: 0,
      learningStep: 2,
      grade: ReviewGrade.easy,
    );
    expect(outcome.intervalDays, lessThanOrEqualTo(365));
  });

  test('progress written before 3.1 is migrated rather than reset', () {
    final WordProgress legacy = WordProgress.fromJson(<String, dynamic>{
      'mastery': 3,
      'dueAt': '2025-01-01T00:00:00.000',
      'correct': 5,
      'wrong': 1,
      'favorite': false,
      'seen': true,
    });
    expect(legacy.ease, 2.5);
    expect(legacy.intervalDays, 4, reason: 'seeded from the old ladder');
    expect(legacy.reps, 3);
    expect(legacy.mnemonic, isEmpty);
  });

  test('a card is only flagged as difficult after repeated lapses', () {
    expect(WordProgress(lapses: 3).isLeech, isFalse);
    expect(WordProgress(lapses: 4).isLeech, isTrue);
  });
}
