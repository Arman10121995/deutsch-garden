/// Local, privacy-preserving records of time spent in learning activities.
library;

class StudyInterval {
  const StudyInterval({
    required this.startedAt,
    required this.endedAt,
    required this.activity,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final String activity;

  Duration get duration => endedAt.isAfter(startedAt)
      ? endedAt.difference(startedAt)
      : Duration.zero;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt.toIso8601String(),
    'activity': activity,
  };

  static StudyInterval? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final DateTime? start = DateTime.tryParse(
      raw['startedAt']?.toString() ?? '',
    );
    final DateTime? end = DateTime.tryParse(raw['endedAt']?.toString() ?? '');
    final String activity = raw['activity']?.toString().trim() ?? '';
    if (start == null ||
        end == null ||
        !end.isAfter(start) ||
        activity.isEmpty) {
      return null;
    }
    return StudyInterval(startedAt: start, endedAt: end, activity: activity);
  }

  String get stableKey =>
      '${startedAt.toIso8601String()}|${endedAt.toIso8601String()}|$activity';
}

/// Returns only the part of [interval] that falls on [day] in local time.
Duration intervalOnDay(StudyInterval interval, DateTime day) {
  final DateTime startOfDay = DateTime(day.year, day.month, day.day);
  final DateTime endOfDay = startOfDay.add(const Duration(days: 1));
  final DateTime start = interval.startedAt.isAfter(startOfDay)
      ? interval.startedAt
      : startOfDay;
  final DateTime end = interval.endedAt.isBefore(endOfDay)
      ? interval.endedAt
      : endOfDay;
  return end.isAfter(start) ? end.difference(start) : Duration.zero;
}

Duration studyDurationOnDay(Iterable<StudyInterval> intervals, DateTime day) =>
    studyDurationBetween(
      intervals,
      DateTime(day.year, day.month, day.day),
      DateTime(day.year, day.month, day.day).add(const Duration(days: 1)),
    );

Duration studyDurationBetween(
  Iterable<StudyInterval> intervals,
  DateTime start,
  DateTime end,
) {
  if (!end.isAfter(start)) return Duration.zero;
  final List<(DateTime, DateTime)> overlaps = <(DateTime, DateTime)>[];
  for (final StudyInterval interval in intervals) {
    final DateTime overlapStart = interval.startedAt.isAfter(start)
        ? interval.startedAt
        : start;
    final DateTime overlapEnd = interval.endedAt.isBefore(end)
        ? interval.endedAt
        : end;
    if (overlapEnd.isAfter(overlapStart)) {
      overlaps.add((overlapStart, overlapEnd));
    }
  }
  if (overlaps.isEmpty) return Duration.zero;
  overlaps.sort(
    ((DateTime, DateTime) a, (DateTime, DateTime) b) => a.$1.compareTo(b.$1),
  );

  Duration total = Duration.zero;
  DateTime mergedStart = overlaps.first.$1;
  DateTime mergedEnd = overlaps.first.$2;
  for (final (DateTime nextStart, DateTime nextEnd) in overlaps.skip(1)) {
    if (nextStart.isAfter(mergedEnd)) {
      total += mergedEnd.difference(mergedStart);
      mergedStart = nextStart;
      mergedEnd = nextEnd;
    } else if (nextEnd.isAfter(mergedEnd)) {
      mergedEnd = nextEnd;
    }
  }
  total += mergedEnd.difference(mergedStart);
  return total;
}

/// Sorts imported intervals and collapses overlapping snapshots of the same
/// activity, as produced when a profile is exported twice during one session.
List<StudyInterval> normalizeStudyIntervals(Iterable<StudyInterval> intervals) {
  final List<StudyInterval> sorted = intervals.toList()
    ..sort(
      (StudyInterval a, StudyInterval b) => a.startedAt.compareTo(b.startedAt),
    );
  final List<StudyInterval> result = <StudyInterval>[];
  for (final StudyInterval interval in sorted) {
    final StudyInterval? previous = result.isEmpty ? null : result.last;
    if (previous != null &&
        previous.activity == interval.activity &&
        !interval.startedAt.isAfter(previous.endedAt)) {
      result[result.length - 1] = StudyInterval(
        startedAt: previous.startedAt,
        endedAt: interval.endedAt.isAfter(previous.endedAt)
            ? interval.endedAt
            : previous.endedAt,
        activity: previous.activity,
      );
    } else {
      result.add(interval);
    }
  }
  return result;
}

int roundedStudyMinutes(Duration duration) {
  if (duration <= Duration.zero) return 0;
  return (duration.inSeconds / 60).round();
}
