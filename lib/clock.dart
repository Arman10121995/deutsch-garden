/// Where the app reads the current time.
///
/// Streaks, the daily-counter rollover, quest days and every "is this due yet"
/// question depend on what day it is. With `DateTime.now()` called directly
/// from inside that logic, none of it can be tested at the moments it is most
/// likely to be wrong: the minute either side of midnight, the day a streak
/// lapses, and the two nights a year when a local day is 23 or 25 hours long.
/// Those are exactly the cases a learner notices, because losing a 40-day
/// streak to a timezone edge is not a rounding error to them.
///
/// This is deliberately the smallest thing that solves that. It is not a
/// scheduler, it holds no state, and production uses the default.
library;

class AppClock {
  /// Reads the real system clock.
  AppClock({DateTime Function()? read}) : _read = read ?? DateTime.now;

  /// A clock stopped at [at]. Useful when a test needs one instant.
  AppClock.fixed(DateTime at) : _read = (() => at);

  final DateTime Function() _read;

  DateTime now() => _read();
}
