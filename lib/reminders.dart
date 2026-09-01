/// A private, on-device nudge to study.
///
/// The app has streaks, daily goals and rotating quests -- an entire habit
/// loop -- and until now nothing that could prompt the habit. A learner who
/// forgets on Tuesday loses a streak the app spent three weeks building, and
/// the app never said a word.
///
/// Deliberately small. At most one reminder per day, at a time the learner
/// picks. Monday–Saturday report the daily minute target; Sunday combines the
/// daily and weekly targets. No marketing and no second notification when the
/// first is ignored.
///
/// Off by default. Asking permission on first launch, before anyone knows what
/// the app is, is how you get told no permanently.
library;

export 'reminders_stub.dart'
    if (dart.library.io) 'reminders_io.dart'
    show createReminders;

/// What a scheduled reminder needs to know.
class ReminderPlan {
  const ReminderPlan({
    required this.hour,
    required this.minute,
    required this.dueCount,
    required this.minutesToday,
    required this.dailyMinuteGoal,
    required this.minutesThisWeek,
    required this.weeklyMinuteGoal,
  });

  final int hour;
  final int minute;

  /// Cards and lessons due today, so the text can say something true rather
  /// than "time to study!".
  final int dueCount;

  final int minutesToday;
  final int dailyMinuteGoal;
  final int minutesThisWeek;
  final int weeklyMinuteGoal;

  int get dailyMinutesRemaining =>
      (dailyMinuteGoal - minutesToday).clamp(0, dailyMinuteGoal);

  int get weeklyMinutesRemaining =>
      (weeklyMinuteGoal - minutesThisWeek).clamp(0, weeklyMinuteGoal);

  String get dueSummary {
    if (dueCount <= 0) return 'Nichts ist fällig.';
    if (dueCount == 1) return '1 Wiederholung ist fällig.';
    return '$dueCount Wiederholungen sind fällig.';
  }

  String get dailyBody {
    if (dailyMinutesRemaining == 0) {
      return 'Tagesziel geschafft: $minutesToday Min. $dueSummary';
    }
    return 'Noch $dailyMinutesRemaining Min. bis zum Tagesziel. $dueSummary';
  }

  String get weeklyBody {
    final String week = weeklyMinutesRemaining == 0
        ? 'Wochenziel geschafft: $minutesThisWeek Min.'
        : 'Noch $weeklyMinutesRemaining Min. bis zum Wochenziel.';
    return '$week Heute: $minutesToday/$dailyMinuteGoal Min.';
  }

  /// Backwards-compatible name for callers that only display the daily copy.
  String get body => dailyBody;
}

abstract class Reminders {
  /// Whether this platform can show a scheduled local notification at all.
  bool get isSupported;

  /// Prepares the plugin. Safe to call more than once.
  Future<void> initialise();

  /// Asks the operating system, returning whether it was granted.
  ///
  /// Called when the learner turns reminders on, never before: a permission
  /// prompt on first launch is answered by someone who does not yet know what
  /// the app is, and the answer is usually no and usually final.
  Future<bool> requestPermission();

  /// Replaces any existing reminder with this one.
  Future<void> schedule(ReminderPlan plan);

  /// Removes the reminder.
  Future<void> cancel();
}
