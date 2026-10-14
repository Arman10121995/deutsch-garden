import 'dart:math';

import 'l10n/app_localizations.dart';
import 'srs.dart';

String reviewGradeText(AppText t, ReviewGrade grade) => switch (grade) {
  ReviewGrade.again => t.gradeAgain,
  ReviewGrade.hard => t.gradeHard,
  ReviewGrade.good => t.gradeGood,
  ReviewGrade.easy => t.gradeEasy,
};

/// Format the unfuzzed schedule in the interface language. Capture the clock
/// once so a minute-long learning step is not shown as zero minutes.
String reviewIntervalText(
  AppText t, {
  required double ease,
  required int intervalDays,
  required int reps,
  required int lapses,
  required int learningStep,
  required ReviewGrade grade,
}) {
  final now = DateTime.now();
  final next = Sm2Scheduler.schedule(
    ease: ease,
    intervalDays: intervalDays,
    reps: reps,
    lapses: lapses,
    learningStep: learningStep,
    grade: grade,
    now: now,
  );
  if (next.intervalDays <= 0) {
    return t.reviewMinutes(max(1, next.dueAt.difference(now).inMinutes));
  }
  if (next.intervalDays < 30) return t.reviewDays(next.intervalDays);
  final months = (next.intervalDays / 30).round();
  if (months < 12) return t.reviewMonths(months);
  return t.reviewYears((next.intervalDays / 365 * 10).round() / 10);
}
