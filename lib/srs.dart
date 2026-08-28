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

  /// How far a day-based interval is spread, as a fraction of itself.
  ///
  /// Without this every card graded in one sitting comes due on exactly the
  /// same later day, so a session's work arrives back as a single spike and
  /// the queue develops peaks and empty days instead of levelling out. Anki
  /// randomises for the same reason. Five per cent is enough to break the
  /// clump without meaningfully changing when anything is asked.
  static const double intervalFuzz = 0.05;

  /// Below this, intervals are left exactly as computed. Spreading a one or
  /// two day interval would move it by a day, which is a large relative
  /// change to a card the learner has only just started to retain.
  static const int fuzzFloorDays = 3;

  /// The longest interval the scheduler will ever produce.
  static const int maximumIntervalDays = 365;

  /// A ceiling on how much lateness is treated as evidence.
  ///
  /// Recalling a card a fortnight late says something about how well it was
  /// known. Recalling one two years late, after the learner stopped using the
  /// app and came back, says almost nothing -- they may simply have relearned
  /// it elsewhere. Beyond this the extra delay is ignored rather than
  /// compounding into an interval nobody intended.
  static const int maximumCreditedLatenessDays = 60;

  /// Spreads [days] by up to [intervalFuzz] either side.
  ///
  /// [random] is injected rather than created here so a test can seed it and
  /// see the distribution. Passing null disables the spread entirely, which
  /// is what [previewLabel] does: the grade buttons should promise the honest
  /// interval, not one particular draw the learner will never see again.
  static int _spread(int days, Random? random) {
    if (random == null || days < fuzzFloorDays) return days;
    final int reach = max(1, (days * intervalFuzz).round());
    final int shifted = days + random.nextInt(reach * 2 + 1) - reach;
    return shifted.clamp(1, maximumIntervalDays);
  }

  static SrsOutcome schedule({
    required double ease,
    required int intervalDays,
    required int reps,
    required int lapses,
    required int learningStep,
    required ReviewGrade grade,
    DateTime? now,
    Random? fuzz,
    DateTime? dueAt,
  }) {
    final DateTime moment = now ?? DateTime.now();

    // How long past its due date the card was actually answered.
    //
    // A card recalled correctly thirty days late was retained for thirty days
    // longer than the schedule assumed, and that is evidence the interval was
    // too short. Discarding it -- which is what happens when the next
    // interval is computed from the old one alone -- means a learner who
    // returns after a break is asked everything again on the old cadence,
    // however well they still know it. SM-2 as Anki implements it folds half
    // the delay in on Good and all of it on Easy; Hard gets none, because a
    // struggled recall is not evidence of retention.
    int lateness = 0;
    if (dueAt != null) {
      final int days = moment.difference(dueAt).inDays;
      if (days > 0) lateness = min(days, maximumCreditedLatenessDays);
    }
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
        nextInterval = _spread(4, fuzz);
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
        // No credit: the recall was a struggle, so the extra elapsed time is
        // not evidence the card was comfortably retained.
        nextEase = max(minimumEase, nextEase - 0.15);
        nextInterval = max(1, (nextInterval * 1.2).round());
        break;
      case ReviewGrade.good:
        nextInterval =
            max(1, ((nextInterval + lateness / 2) * nextEase).round());
        break;
      case ReviewGrade.easy:
        nextEase = min(3.2, nextEase + 0.15);
        nextInterval =
            max(1, ((nextInterval + lateness) * nextEase * 1.3).round());
        break;
      case ReviewGrade.again:
        break;
    }
    nextInterval = _spread(min(nextInterval, maximumIntervalDays), fuzz);
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
