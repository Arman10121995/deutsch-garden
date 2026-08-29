/// A daily nudge to study.
///
/// The app has streaks, daily goals and rotating quests -- an entire habit
/// loop -- and until now nothing that could prompt the habit. A learner who
/// forgets on Tuesday loses a streak the app spent three weeks building, and
/// the app never said a word.
///
/// Deliberately small. One reminder, at a time the learner picks, saying how
/// many cards are due. No marketing, no re-engagement campaign, no second
/// notification when the first is ignored: an app that nags gets its
/// notifications switched off, and then it has none.
///
/// Off by default. Asking permission on first launch, before anyone knows what
/// the app is, is how you get told no permanently.
library;

export 'reminders_stub.dart'
    if (dart.library.io) 'reminders_io.dart' show createReminders;

/// What a scheduled reminder needs to know.
class ReminderPlan {
  const ReminderPlan({
    required this.hour,
    required this.minute,
    required this.dueCount,
  });

  final int hour;
  final int minute;

  /// Cards and lessons due today, so the text can say something true rather
  /// than "time to study!".
  final int dueCount;

  String get body {
    if (dueCount <= 0) {
      return 'Nichts fällig heute — ein paar neue Wörter?';
    }
    if (dueCount == 1) return '1 Karte ist fällig.';
    return '$dueCount Karten sind fällig.';
  }
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
