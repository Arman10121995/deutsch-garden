import 'dart:math';

/// Self-rated recall quality, using the four-button model popularised by
/// Anki and used in one form or another by every serious SRS app.
enum ReviewGrade { again, hard, good, easy }

extension ReviewGradeX on ReviewGrade {
  String get label {
    switch (this) {
      case ReviewGrade.again:
        return 'Again';
      case ReviewGrade.hard:
        return 'Hard';
      case ReviewGrade.good:
        return 'Good';
      case ReviewGrade.easy:
        return 'Easy';
    }
  }

  String get emoji {
    switch (this) {
      case ReviewGrade.again:
        return '🔁';
      case ReviewGrade.hard:
        return '😓';
      case ReviewGrade.good:
        return '🙂';
      case ReviewGrade.easy:
        return '⚡';
    }
  }

  bool get isCorrect => this != ReviewGrade.again;
}

/// The scheduling state of a single card after a review.
class SrsOutcome {
  const SrsOutcome({
    required this.ease,
    required this.intervalDays,
    required this.reps,
    required this.lapses,
    required this.dueAt,
    required this.learningStep,
  });

  final double ease;
  final int intervalDays;
  final int reps;
  final int lapses;
  final DateTime dueAt;
  final int learningStep;
}

/// A pragmatic SM-2 implementation with short learning steps.
///
/// The original DeutschGarden scheduler used a fixed 0/1/2/4/8/16-day ladder
/// keyed to a 0-5 mastery counter. That ladder cannot adapt: an item the
/// learner finds trivial and an item they barely recall receive exactly the
/// same interval. SM-2 keeps a per-card ease factor instead, so intervals
/// diverge according to measured difficulty.
class Sm2Scheduler {
  const Sm2Scheduler._();

  /// Minutes used for the two learning steps before a card graduates.
  static const List<int> learningStepMinutes = <int>[1, 10];

  static const double minimumEase = 1.3;
  static const double startingEase = 2.5;

  /// Cards that lapse re-enter learning rather than being scheduled days out.
  static const int relearnMinutes = 10;

  static SrsOutcome schedule({
    required double ease,
    required int intervalDays,
    required int reps,
    required int lapses,
    required int learningStep,
    required ReviewGrade grade,
    DateTime? now,
  }) {
    final DateTime moment = now ?? DateTime.now();
    double nextEase = ease <= 0 ? startingEase : ease;
    int nextInterval = intervalDays;
    int nextReps = reps;
    int nextLapses = lapses;
    int nextStep = learningStep;

    if (grade == ReviewGrade.again) {
      nextEase = max(minimumEase, nextEase - 0.20);
      nextLapses += 1;
      nextStep = 0;
      nextInterval = 0;
      return SrsOutcome(
        ease: nextEase,
        intervalDays: 0,
        reps: nextReps,
        lapses: nextLapses,
        dueAt: moment.add(Duration(minutes: relearnMinutes)),
        learningStep: nextStep,
      );
    }

    final bool inLearning = nextInterval <= 0;
    if (inLearning) {
      // Easy answers graduate immediately; good answers walk the steps.
      if (grade == ReviewGrade.easy) {
        nextReps += 1;
        nextStep = learningStepMinutes.length;
        nextInterval = 4;
        nextEase = min(3.2, nextEase + 0.15);
        return SrsOutcome(
          ease: nextEase,
          intervalDays: nextInterval,
          reps: nextReps,
          lapses: nextLapses,
          dueAt: moment.add(Duration(days: nextInterval)),
          learningStep: nextStep,
        );
      }
      if (grade == ReviewGrade.hard) {
        // Repeat the current step rather than advancing.
        final int minutes = learningStepMinutes[
            nextStep.clamp(0, learningStepMinutes.length - 1)];
        return SrsOutcome(
          ease: max(minimumEase, nextEase - 0.05),
          intervalDays: 0,
          reps: nextReps,
          lapses: nextLapses,
          dueAt: moment.add(Duration(minutes: minutes)),
          learningStep: nextStep,
        );
      }
      nextStep += 1;
      nextReps += 1;
      if (nextStep >= learningStepMinutes.length) {
        nextInterval = 1;
        return SrsOutcome(
          ease: nextEase,
          intervalDays: nextInterval,
          reps: nextReps,
          lapses: nextLapses,
          dueAt: moment.add(const Duration(days: 1)),
          learningStep: nextStep,
        );
      }
      return SrsOutcome(
        ease: nextEase,
        intervalDays: 0,
        reps: nextReps,
        lapses: nextLapses,
        dueAt: moment.add(Duration(minutes: learningStepMinutes[nextStep])),
        learningStep: nextStep,
      );
    }

    // Graduated review card.
    nextReps += 1;
    switch (grade) {
      case ReviewGrade.hard:
        nextEase = max(minimumEase, nextEase - 0.15);
        nextInterval = max(1, (nextInterval * 1.2).round());
        break;
      case ReviewGrade.good:
        nextInterval = max(1, (nextInterval * nextEase).round());
        break;
      case ReviewGrade.easy:
        nextEase = min(3.2, nextEase + 0.15);
        nextInterval = max(1, (nextInterval * nextEase * 1.3).round());
        break;
      case ReviewGrade.again:
        break;
    }
    nextInterval = min(nextInterval, 365);
    return SrsOutcome(
      ease: nextEase,
      intervalDays: nextInterval,
      reps: nextReps,
      lapses: nextLapses,
      dueAt: moment.add(Duration(days: nextInterval)),
      learningStep: nextStep,
    );
  }

  /// Human-readable preview of the next interval, shown on the grade buttons
  /// exactly as Anki and Memrise do, so the learner can see the consequence
  /// of their self-rating before committing to it.
  static String previewLabel({
    required double ease,
    required int intervalDays,
    required int reps,
    required int lapses,
    required int learningStep,
    required ReviewGrade grade,
  }) {
    final SrsOutcome outcome = schedule(
      ease: ease,
      intervalDays: intervalDays,
      reps: reps,
      lapses: lapses,
      learningStep: learningStep,
      grade: grade,
    );
    if (outcome.intervalDays <= 0) {
      final int minutes = outcome.dueAt.difference(DateTime.now()).inMinutes;
      return '${max(1, minutes)} min';
    }
    if (outcome.intervalDays == 1) return '1 day';
    if (outcome.intervalDays < 30) return '${outcome.intervalDays} days';
    final int months = (outcome.intervalDays / 30).round();
    if (months < 12) return '$months mo';
    return '${(outcome.intervalDays / 365).toStringAsFixed(1)} yr';
  }
}
