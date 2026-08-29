import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'achievements.dart';
import 'clock.dart';
import 'conversation.dart';
import 'course.dart';
import 'curriculum.dart';
import 'glosses.dart';
import 'models.dart';
import 'radio.dart';
import 'reminders.dart';
import 'review_store.dart';
import 'srs.dart';
import 'stories.dart';
import 'vocabulary.dart';

class AppController extends ChangeNotifier {
  AppController();

  static const String _storageKey = 'deutsch_garden_state_v4';
  static const String _legacyStorageKey = 'deutsch_garden_state_v3';
  static const String _oldLegacyStorageKey = 'deutsch_garden_state_v2';
  static const String _ancientStorageKey = 'deutsch_garden_state_v1';

  /// The last blob that was known to parse cleanly. Written only after a
  /// successful load, so it is by construction restorable.
  static const String _snapshotKey = 'deutsch_garden_state_v4_snapshot';

  /// Where a blob that failed to parse is moved to. It is never silently
  /// discarded: a learner who loses a year of reviews to a bad write deserves
  /// the bytes kept around for recovery rather than overwritten with a blank
  /// profile on the very next frame.
  static const String _quarantineKey = 'deutsch_garden_state_corrupt';

  /// Set when [load] could not read the primary blob. The UI surfaces this so
  /// a silent reset can never masquerade as a fresh install.
  String recoveryNotice = '';

  /// How many mistakes the bank keeps. Beyond this the oldest are dropped:
  /// an unbounded list would grow forever and the oldest entries are the
  /// least useful to review.
  static const int mistakeBankLimit = 200;

  /// How many graded reviews the log keeps. Beyond this the oldest are
  /// dropped.
  ///
  /// Every event currently lives inside the single JSON blob that is rewritten
  /// on save, so the ceiling is set by what is reasonable to re-encode rather
  /// than by what a scheduler would like. Measured, an event costs 35 bytes
  /// and a full log is 175 KB against a 761-byte empty profile -- the log is
  /// the profile, essentially. At twenty reviews a day it holds around eight
  /// months of history, which is enough to fit a scheduler against. Moving
  /// the profile into a real store is what lifts the ceiling; debouncing the
  /// writes is what makes carrying it in the blob tolerable until then.
  static const int reviewLogLimit = 5000;
  static const double levelUnlockThreshold = 0.65;

  /// How long a burst of mutations is allowed to settle before it reaches
  /// disk. A single answer touches state several times -- the grade, the
  /// counters, the quests, the streak -- and each one used to re-encode the
  /// whole profile and rewrite it. On Android that is a complete XML file per
  /// call. Coalescing them costs half a second of durability and removes most
  /// of the writes.
  static const Duration saveDebounce = Duration(milliseconds: 500);

  /// A ceiling on that deferral. A learner answering steadily keeps resetting
  /// the debounce, so without this the write could be pushed back forever and
  /// a crash would cost the whole session rather than half a second.
  /// Not const: a test shortens it, because the ceiling is measured against
  /// real wall-clock and busy-waiting five seconds to reach it is both slow
  /// and unreliable under load.
  @visibleForTesting
  static Duration saveMaxDeferral = const Duration(seconds: 5);

  /// Whether [_save] defers. Production always does.
  ///
  /// `testWidgets` fails a test that ends with a timer outstanding, and it
  /// checks before `addTearDown` runs, so a controller holding a debounce
  /// timer would trip every widget test that touches progress -- none of
  /// which are about persistence. Those tests turn deferral off and get the
  /// immediate write they were written against. The debounce itself, the
  /// deferral ceiling and the flush-on-background are covered directly in
  /// `test/save_debounce_test.dart`, which leaves this on.
  @visibleForTesting
  static bool debounceWrites = true;

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  /// Where this controller reads the current time.
  ///
  /// Every day-boundary decision in here -- streaks, the daily-counter
  /// rollover, quest days -- goes through it, so a test can stand at one
  /// minute to midnight and step over.
  @visibleForTesting
  AppClock clock = AppClock();

  /// Drives the spread applied to review intervals, so a session's cards do
  /// not all come due on the same later day. Held on the controller rather
  /// than created per call so a test can substitute a seeded source.
  @visibleForTesting
  Random scheduleFuzz = Random();

  Timer? _saveTimer;
  DateTime? _deferringSince;
  bool _disposed = false;

  /// Writes run one after another. Each encodes the profile at its own turn,
  /// so a slow write cannot land on top of a newer one and undo it.
  Future<void> _writeChain = Future<void>.value();

  /// Writes that have been requested but not yet performed. Exposed so a test
  /// can assert the coalescing actually happened rather than assume it.
  @visibleForTesting
  bool get hasPendingSave => _saveTimer?.isActive ?? false;
  final Map<String, WordProgress> _progress = <String, WordProgress>{};
  final Map<String, ActivityProgress> _activityProgress =
      <String, ActivityProgress>{};
  final List<MistakeEntry> _mistakes = <MistakeEntry>[];
  final List<ReviewEvent> _reviewLog = <ReviewEvent>[];

  /// Where the log is kept. On every native target this is its own SQLite
  /// table; on web it is still the profile blob.
  @visibleForTesting
  ReviewStore reviewStore = createReviewStore();

  /// Local, opt-in study reminder. The conditional implementation reports
  /// unsupported on web, Windows and Linux rather than showing a switch that
  /// cannot keep its promise.
  @visibleForTesting
  Reminders reminders = createReminders();

  /// Whether the log has left the profile blob on this platform.
  bool get reviewLogIsExternal => reviewStore.isPersistent;
  final Map<String, int> _dailyCounters = <String, int>{};
  final Set<String> _completedQuestIds = <String>{};
  final Set<String> _seenAchievementIds = <String>{};

  bool ready = false;
  int xp = 0;
  int streak = 0;
  int dailyGoal = 20;
  bool remindersEnabled = false;
  int reminderHour = 19;
  int reminderMinute = 0;

  bool get remindersSupported => reminders.isSupported;

  /// Audio-course days completed, per CEFR level label.
  ///
  /// One integer per level is the whole persisted state of the audio course.
  /// See `lib/audio_course.dart` for why the alternative -- an SM-2 record per
  /// sentence -- was not worth several thousand profile entries.
  final Map<String, int> _audioCourseDay = <String, int>{};
  int todayReviews = 0;
  int totalCorrect = 0;
  int totalWrong = 0;
  bool ttsEnabled = true;
  ThemeMode themeMode = ThemeMode.dark;

  /// Language of the app's own text.
  ///
  /// Null means follow the device. This never changes the language being
  /// taught: the cards, stories and grammar stay German whatever this is set
  /// to. Keeping the two separate matters, because a learner who switches the
  /// interface to German has not asked for their English glosses to disappear.
  Locale? uiLocale;

  /// Language the card meanings are shown in.
  ///
  /// Empty means English, which lives on the card itself. This is separate
  /// from [uiLocale] and neither implies the other: reading the interface in
  /// German while glossing cards into Turkish is a perfectly ordinary thing
  /// for a Turkish speaker living in Germany to want.
  String glossLanguage = '';
  String lastStudyDay = '';
  String dailyCounterDay = '';
  String lastPlacementLevel = '';
  int lastPlacementScore = 0;
  String lastPlacementDate = '';
  int placementUnlockedOrder = -1;

  /// Offline Leben-in-Deutschland / citizenship-test preparation state.
  String civicsStateCode = '';
  final Set<String> _civicsCorrectQuestionIds = <String>{};
  String lastCivicsKind = '';
  String lastCivicsStateCode = '';
  String lastCivicsDate = '';
  int lastCivicsCorrect = 0;
  int lastCivicsTotal = 0;
  int civicsTestsCompleted = 0;

  /// The highest level that must remain available because the learner has
  /// already earned it through curriculum progress. Unlike the live progress
  /// calculation this floor never moves backwards when content is added.
  int earnedUnlockedOrder = 0;

  /// An old profile has no earned floor. Remember that fact through [load] so
  /// the migrated value is written to the primary blob even when no unrelated
  /// daily rollover happens to make the profile dirty.
  bool _unlockFloorNeedsPersistence = false;

  /// German-only mode: translations and English hints stay hidden until the
  /// learner explicitly asks for them, which is Rosetta Stone's core idea
  /// applied to a text-based app.
  bool immersionMode = false;

  /// Whether the learner has been shown what this app is and how it works.
  ///
  /// Defaults to false, so an existing profile that predates onboarding sees
  /// it once. That is the right way round: showing a short intro to someone
  /// who has used the app for months is a mild annoyance, whereas skipping it
  /// for someone who has never seen it is the bug.
  bool onboardingDone = false;

  /// Lifetime counters that cannot be derived from the progress maps.
  int storyChaptersDone = 0;
  int conversationsDone = 0;
  int speakingTurns = 0;
  int dailyGoalsHit = 0;
  int mistakesCleared = 0;
  String questDay = '';

  Map<String, WordProgress> get progress => Map.unmodifiable(_progress);
  Map<String, ActivityProgress> get activities =>
      Map.unmodifiable(_activityProgress);
  List<MistakeEntry> get mistakes => List.unmodifiable(_mistakes);
  Set<String> get civicsCorrectQuestionIds =>
      Set<String>.unmodifiable(_civicsCorrectQuestionIds);
  Set<String> get civicsMistakeQuestionIds => _mistakes
      .where((MistakeEntry entry) => entry.source == 'civics')
      .map((MistakeEntry entry) => entry.id.replaceFirst('civics:', ''))
      .toSet();

  int get learnedCount => _progress.values.where((p) => p.seen).length;
  int get masteredCount => _progress.values.where((p) => p.mastered).length;

  /// How many cards are due, without building or sorting a list.
  ///
  /// This is read from build methods on the practice hub and the home screen,
  /// so it runs on most frames. Going through [reviewWords] meant allocating a
  /// list of every due card and sorting it by due date purely to read its
  /// length -- affordable at 900 cards, not at 10,000.
  int get dueCount {
    final DateTime now = clock.now();
    int count = 0;
    for (final GermanWord word in vocabulary) {
      final WordProgress? p = _progress[word.id];
      if (p != null && p.seen && !p.dueAt.isAfter(now)) count++;
    }
    return count;
  }

  int get attempts => totalCorrect + totalWrong;

  /// All-time correct answers over all answers.
  ///
  /// Kept because the running totals predate the review log and other things
  /// read them, but it is close to meaningless on its own: it mixes a card's
  /// first exposure with a year-long interval, and it can only ever rise
  /// slowly toward a number that says nothing about whether the schedule is
  /// working. [trueRetention] is the figure to prefer.
  double get accuracy => attempts == 0 ? 0 : totalCorrect / attempts;

  /// The share of *scheduled* reviews recalled correctly in the last [window].
  ///
  /// This is what spaced-repetition tools mean by retention, and it differs
  /// from [accuracy] in two ways that matter. It ignores cards still in their
  /// learning steps, because getting a card right minutes after seeing it is
  /// not evidence of anything. And it covers a window rather than all time,
  /// so it can fall -- which is the entire point of measuring it. A number
  /// that can only go up is not a measurement.
  ///
  /// Returns null when the window holds too few reviews to say anything.
  /// [minimumSample] exists so the screen can decline to print a percentage
  /// derived from three answers.
  double? trueRetention({
    Duration window = const Duration(days: 30),
    int minimumSample = 20,
    DateTime? now,
  }) {
    final DateTime cutoff = (now ?? clock.now()).subtract(window);
    int seen = 0;
    int recalled = 0;
    for (final ReviewEvent event in _reviewLog) {
      if (event.at.isBefore(cutoff)) continue;
      // Only graduated cards. A learning-step answer is not a retention test.
      if (!event.wasScheduled || event.intervalBefore <= 0) continue;
      seen += 1;
      if (event.grade != ReviewGrade.again) recalled += 1;
    }
    if (seen < minimumSample) return null;
    return recalled / seen;
  }

  /// Recall rate grouped by how long the card had been waiting.
  ///
  /// The shape of this is what says whether the intervals are right: if
  /// retention collapses in the longest bucket, the scheduler is pushing
  /// cards out faster than they are being retained. Buckets with fewer than
  /// [minimumSample] reviews are omitted rather than shown as noise.
  Map<String, double> retentionByInterval({int minimumSample = 10}) {
    const List<int> edges = <int>[1, 7, 21, 60];
    const List<String> labels = <String>[
      '1 day',
      '2-7 days',
      '8-21 days',
      '22-60 days',
      '60+ days',
    ];
    final List<int> seen = List<int>.filled(labels.length, 0);
    final List<int> recalled = List<int>.filled(labels.length, 0);

    for (final ReviewEvent event in _reviewLog) {
      if (!event.wasScheduled || event.intervalBefore <= 0) continue;
      int bucket = edges.length;
      for (int i = 0; i < edges.length; i++) {
        if (event.intervalBefore <= edges[i]) {
          bucket = i;
          break;
        }
      }
      seen[bucket] += 1;
      if (event.grade != ReviewGrade.again) recalled[bucket] += 1;
    }

    return <String, double>{
      for (int i = 0; i < labels.length; i++)
        if (seen[i] >= minimumSample) labels[i]: recalled[i] / seen[i],
    };
  }

  /// How many cards and lessons fall due on each of the next [days] days.
  ///
  /// Reads current scheduler state rather than the log: the log is history,
  /// and this is the forecast the history makes possible to trust.
  List<int> dueForecast({int days = 14, DateTime? now}) {
    final DateTime start = now ?? clock.now();
    final DateTime midnight = DateTime(start.year, start.month, start.day);
    final List<int> counts = List<int>.filled(days, 0);
    void place(DateTime dueAt) {
      if (dueAt.millisecondsSinceEpoch == 0) return;
      final int offset = DateTime(
        dueAt.year,
        dueAt.month,
        dueAt.day,
      ).difference(midnight).inDays;
      // Anything already overdue belongs to today, not to a negative day.
      final int index = offset < 0 ? 0 : offset;
      if (index < days) counts[index] += 1;
    }

    for (final WordProgress p in _progress.values) {
      if (p.seen) place(p.dueAt);
    }
    for (final ActivityProgress p in _activityProgress.values) {
      if (p.completed) place(p.dueAt);
    }
    return counts;
  }

  double get dailyGoalProgress =>
      dailyGoal <= 0 ? 0.0 : min<double>(1.0, todayReviews / dailyGoal);

  List<GermanWord> wordsForLevel(CefrLevel level) => vocabulary
      .where((word) => word.level.toUpperCase() == level.label)
      .toList(growable: false);

  /// The next audio-course day for a level: one past however many are done.
  int audioCourseDay(CefrLevel level) =>
      (_audioCourseDay[level.label] ?? 0) + 1;

  int audioCourseDaysDone(CefrLevel level) => _audioCourseDay[level.label] ?? 0;

  /// Record a finished audio-course day.
  ///
  /// Guarded on the day actually being the next one, so replaying an old day
  /// -- which the UI allows, because re-listening is a reasonable thing to
  /// want -- does not rewind the counter or double-count it.
  Future<void> completeAudioCourseDay(CefrLevel level, int day) async {
    _registerAction();
    final int done = _audioCourseDay[level.label] ?? 0;
    if (day == done + 1) {
      _audioCourseDay[level.label] = day;
      xp += 15;
      _bumpDaily(DailyMetric.xp, 15);
    }
    _recordStudyDay();
    _settleQuests();
    notifyListeners();
    await _save();
  }

  /// Words met, per level, for the course's vocabulary targets.
  ///
  /// One pass over the deck producing all six counts, rather than six passes
  /// producing one each: the course map shows every level at once, so the
  /// per-level form would walk 10,000 cards six times per frame.
  Map<CefrLevel, int> get wordsSeenByLevel {
    final Map<CefrLevel, int> counts = <CefrLevel, int>{
      for (final CefrLevel level in CefrLevel.values) level: 0,
    };
    for (final GermanWord word in vocabulary) {
      if (_progress[word.id]?.seen ?? false) {
        counts[word.cefr] = (counts[word.cefr] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<GermanWord> reviewWordsForLevel(CefrLevel level) {
    final now = clock.now();
    final list = wordsForLevel(level).where((word) {
      final p = _progress[word.id];
      return p != null && p.seen && !p.dueAt.isAfter(now);
    }).toList();
    list.sort((a, b) {
      final pa = _progress[a.id]!;
      final pb = _progress[b.id]!;
      final due = pa.dueAt.compareTo(pb.dueAt);
      if (due != 0) return due;
      return pa.mastery.compareTo(pb.mastery);
    });
    return list;
  }

  List<GermanWord> newWordsForLevel(CefrLevel level) => wordsForLevel(level)
      .where((word) => !(_progress[word.id]?.seen ?? false))
      .toList(growable: false);

  List<GermanWord> get reviewWords {
    final now = clock.now();
    final list = vocabulary.where((word) {
      final p = _progress[word.id];
      return p != null && p.seen && !p.dueAt.isAfter(now);
    }).toList();
    list.sort(
      (a, b) => _progress[a.id]!.dueAt.compareTo(_progress[b.id]!.dueAt),
    );
    return list;
  }

  List<GermanWord> get newWords => vocabulary
      .where((word) => !(_progress[word.id]?.seen ?? false))
      .toList(growable: false);

  List<GermanWord> get favorites => vocabulary
      .where((word) => _progress[word.id]?.favorite ?? false)
      .toList(growable: false);

  WordProgress progressFor(String wordId) =>
      _progress.putIfAbsent(wordId, WordProgress.new);

  ActivityProgress progressForActivity(String activityId) =>
      _activityProgress.putIfAbsent(activityId, ActivityProgress.new);

  /// Decodes one stored blob, returning false if it is unusable.
  ///
  /// Applying is all-or-nothing at the top level: the decode has to produce a
  /// map before any field is touched, so a truncated or non-JSON blob cannot
  /// part-apply.
  bool _tryApply(String? raw) {
    if (raw == null || raw.isEmpty) return false;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return false;
      applyJson(decoded.map((key, value) => MapEntry(key.toString(), value)));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Set when the log could not be moved into its own table, so the profile
  /// keeps carrying it. Read by the tests; never silently ignored.
  @visibleForTesting
  bool reviewLogMigrationDeferred = false;

  Future<void> load() async {
    recoveryNotice = '';

    final String? primary = await _prefs.getString(_storageKey);
    String? legacy;
    if (primary == null || primary.isEmpty) {
      legacy = await _prefs.getString(_legacyStorageKey);
      legacy ??= await _prefs.getString(_oldLegacyStorageKey);
      legacy ??= await _prefs.getString(_ancientStorageKey);
    }

    final String? raw = (primary != null && primary.isNotEmpty)
        ? primary
        : legacy;
    final bool hadStoredProfile = raw != null && raw.isNotEmpty;
    bool loaded = _tryApply(raw);
    bool recovered = false;

    if (hadStoredProfile && !loaded) {
      // The profile exists but will not parse. Keep the bytes — never let the
      // next _save() overwrite a learner's history with a blank profile — and
      // fall back to the last blob that was known to load.
      await _prefs.setString(_quarantineKey, raw);
      final String? snapshot = await _prefs.getString(_snapshotKey);
      loaded = _tryApply(snapshot);
      recovered = loaded;
      recoveryNotice = loaded
          ? 'Your saved profile could not be read, so DeutschGarden restored '
                'the last good backup. Recent progress may be missing.'
          : 'Your saved profile could not be read and no backup was available. '
                'The unreadable data has been kept on the device rather than '
                'deleted, so nothing is lost permanently.';
    }

    final bool rolled = _rollDailyCounterIfNeeded();
    final bool staggered = _staggerUnscheduledActivities();
    final bool renamed = _migrateRadioIds();
    _normalizeStreak();
    ready = true;
    notifyListeners();

    if (loaded) {
      // This exact string parsed, so it is safe to promote to the snapshot.
      await _prefs.setString(_snapshotKey, jsonEncode(toJson()));
    }

    // Only write when there is something to write. A cold start that changed
    // nothing should not re-encode and rewrite the whole profile.
    if (recovered ||
        rolled ||
        staggered ||
        renamed ||
        _unlockFloorNeedsPersistence ||
        (hadStoredProfile && loaded && primary == null)) {
      // A migration performed at startup must be on disk before the app runs,
      // not half a second later.
      await flushSave();
    }

    await _adoptReviewStore();
    // Loaded here rather than lazily at the first card, so a list of two
    // hundred words does not build once in English and then rebuild.
    if (glossLanguage.isNotEmpty) await loadGlosses(glossLanguage);
    if (remindersEnabled) unawaited(refreshReminder());
  }

  /// Moves the review log out of the profile blob and into its own table.
  ///
  /// The order matters and is the whole point: read what the blob holds, write
  /// it to the table, **read it back and count it**, and only then let the
  /// profile stop carrying it. A migration that trusts its own write is how a
  /// learner loses a year of history to a full disk.
  ///
  /// Anything that goes wrong leaves the blob exactly as it was. The log is
  /// then still capped and still duplicated, which is the old behaviour --
  /// worse than the new one, and far better than an empty history.
  Future<void> _adoptReviewStore() async {
    reviewLogMigrationDeferred = false;
    if (!reviewStore.isPersistent) return;

    try {
      await reviewStore.open();
    } catch (error) {
      reviewLogMigrationDeferred = true;
      debugPrint(
        'review store unavailable, keeping the log in the profile: '
        '$error',
      );
      return;
    }

    try {
      final int stored = await reviewStore.count();
      if (stored == 0 && _reviewLog.isNotEmpty) {
        // First run after the change: the blob still holds the history.
        final List<ReviewEvent> carried = List<ReviewEvent>.unmodifiable(
          _reviewLog,
        );
        await reviewStore.replaceAll(carried);

        final List<ReviewEvent> readBack = await reviewStore.readAll();
        if (readBack.length != carried.length) {
          // Do not trust the table, and do not drop the blob's copy.
          reviewLogMigrationDeferred = true;
          debugPrint(
            'review log migration wrote ${carried.length} events and '
            'read back ${readBack.length}; keeping the profile copy',
          );
          return;
        }
        _reviewLog
          ..clear()
          ..addAll(readBack);
        // The profile stops carrying the log from the next save onward, which
        // is what shrinks the blob back to its 761 bytes.
        await flushSave();
        return;
      }

      // Ordinary start: the table is authoritative.
      final List<ReviewEvent> fromStore = await reviewStore.readAll();
      if (fromStore.isNotEmpty || _reviewLog.isEmpty) {
        _reviewLog
          ..clear()
          ..addAll(fromStore);
      }
    } catch (error) {
      reviewLogMigrationDeferred = true;
      debugPrint(
        'review store read failed, keeping the log in the profile: '
        '$error',
      );
    }
  }

  /// Clears a quarantined blob once the learner has acknowledged the loss.
  Future<void> dismissRecoveryNotice() async {
    recoveryNotice = '';
    await _prefs.remove(_quarantineKey);
    notifyListeners();
  }

  /// The unreadable profile, if one was quarantined. Exposed so Settings can
  /// offer it as raw text the learner can copy out and keep.
  Future<String?> quarantinedProfile() => _prefs.getString(_quarantineKey);

  /// Rehydrates the controller from a decoded state map.
  ///
  /// Shared by [load] and by the backup importer, so a transferred profile is
  /// read by exactly the same code that reads local state — there is no second
  /// decoder to drift out of sync.
  void applyJson(Map<String, dynamic> root) {
    final Object? earnedUnlockRaw = root['earnedUnlockedOrder'];
    final bool hasEarnedUnlockFloor =
        earnedUnlockRaw is num && earnedUnlockRaw.isFinite;
    _unlockFloorNeedsPersistence = !hasEarnedUnlockFloor;

    xp = jsonInt(root['xp'], 0);
    streak = jsonInt(root['streak'], 0);
    dailyGoal = jsonInt(root['dailyGoal'], 20);
    remindersEnabled = jsonBool(root['remindersEnabled'], false);
    reminderHour = jsonInt(root['reminderHour'], 19).clamp(0, 23).toInt();
    reminderMinute = jsonInt(root['reminderMinute'], 0).clamp(0, 59).toInt();
    _audioCourseDay.clear();
    final Object? audioDays = root['audioCourseDay'];
    if (audioDays is Map) {
      audioDays.forEach((Object? key, Object? value) {
        if (key is String) {
          final int day = jsonInt(value, 0);
          if (day > 0) _audioCourseDay[key] = day;
        }
      });
    }
    todayReviews = jsonInt(root['todayReviews'], 0);
    totalCorrect = jsonInt(root['totalCorrect'], 0);
    totalWrong = jsonInt(root['totalWrong'], 0);
    ttsEnabled = jsonBool(root['ttsEnabled'], true);
    lastStudyDay = jsonString(root['lastStudyDay'], '');
    dailyCounterDay = jsonString(root['dailyCounterDay'], '');
    lastPlacementLevel = jsonString(root['lastPlacementLevel'], '');
    lastPlacementScore = jsonInt(root['lastPlacementScore'], 0);
    lastPlacementDate = jsonString(root['lastPlacementDate'], '');
    placementUnlockedOrder = jsonInt(root['placementUnlockedOrder'], -1);
    civicsStateCode = jsonString(root['civicsStateCode'], '');
    lastCivicsKind = jsonString(root['lastCivicsKind'], '');
    lastCivicsStateCode = jsonString(root['lastCivicsStateCode'], '');
    lastCivicsDate = jsonString(root['lastCivicsDate'], '');
    lastCivicsCorrect = jsonInt(root['lastCivicsCorrect'], 0);
    lastCivicsTotal = jsonInt(root['lastCivicsTotal'], 0);
    civicsTestsCompleted = jsonInt(root['civicsTestsCompleted'], 0);
    _civicsCorrectQuestionIds.clear();
    final Object? civicsCorrectRaw = root['civicsCorrectQuestionIds'];
    if (civicsCorrectRaw is List) {
      _civicsCorrectQuestionIds.addAll(
        civicsCorrectRaw.map((Object? value) => value.toString()),
      );
    }
    earnedUnlockedOrder = hasEarnedUnlockFloor
        ? jsonInt(
            earnedUnlockRaw,
            0,
          ).clamp(CefrLevel.a1.order, CefrLevel.c2.order)
        : CefrLevel.a1.order;
    immersionMode = jsonBool(root['immersionMode'], false);
    onboardingDone = jsonBool(root['onboardingDone'], false);
    storyChaptersDone = jsonInt(root['storyChaptersDone'], 0);
    conversationsDone = jsonInt(root['conversationsDone'], 0);
    speakingTurns = jsonInt(root['speakingTurns'], 0);
    dailyGoalsHit = jsonInt(root['dailyGoalsHit'], 0);
    mistakesCleared = jsonInt(root['mistakesCleared'], 0);
    questDay = jsonString(root['questDay'], '');

    _dailyCounters.clear();
    final dailyRaw = root['dailyCounters'];
    if (dailyRaw is Map) {
      for (final entry in dailyRaw.entries) {
        final value = entry.value;
        if (value is num) _dailyCounters[entry.key.toString()] = value.toInt();
      }
    }
    _completedQuestIds.clear();
    final questsRaw = root['completedQuests'];
    if (questsRaw is List) {
      _completedQuestIds.addAll(questsRaw.map((e) => e.toString()));
    }
    _seenAchievementIds.clear();
    final seenRaw = root['seenAchievements'];
    if (seenRaw is List) {
      _seenAchievementIds.addAll(seenRaw.map((e) => e.toString()));
    }
    _mistakes.clear();
    final mistakesRaw = root['mistakes'];
    if (mistakesRaw is List) {
      for (final item in mistakesRaw) {
        if (item is Map) {
          _mistakes.add(
            MistakeEntry.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          );
        }
      }
    }
    _reviewLog.clear();
    final reviewLogRaw = root['reviewLog'];
    if (reviewLogRaw is List) {
      for (final item in reviewLogRaw) {
        final ReviewEvent? event = ReviewEvent.fromJson(item);
        // A single unreadable entry costs that entry, not the history.
        if (event != null) _reviewLog.add(event);
      }
      if (!reviewStore.isPersistent && _reviewLog.length > reviewLogLimit) {
        _reviewLog.removeRange(0, _reviewLog.length - reviewLogLimit);
      }
    }
    glossLanguage = jsonString(root['glossLanguage'], '');
    if (GlossLanguage.byCode(glossLanguage) == null) glossLanguage = '';
    final String storedLocale = jsonString(root['uiLocale'], '');
    uiLocale = storedLocale.isEmpty ? null : Locale(storedLocale);
    final theme = jsonString(root['themeMode'], 'dark');
    themeMode = theme == 'light'
        ? ThemeMode.light
        : theme == 'system'
        ? ThemeMode.system
        : ThemeMode.dark;

    _progress.clear();
    _activityProgress.clear();
    _loadProgressMap(root['progress'], _progress, WordProgress.fromJson);
    _loadProgressMap(
      root['activities'],
      _activityProgress,
      ActivityProgress.fromJson,
    );

    if (!hasEarnedUnlockFloor) {
      // Recreate exactly what the old app would have unlocked before the
      // vocabulary and grammar denominators grew. Placement remains part of
      // that old effective result, just as it was before this migration.
      earnedUnlockedOrder = _highestUnlockedOrder(legacyCurriculum: true);
    }
    if (_captureEarnedUnlockFloor()) {
      _unlockFloorNeedsPersistence = true;
    }
  }

  void _loadProgressMap<T>(
    dynamic raw,
    Map<String, T> target,
    T Function(Map<String, dynamic>) decoder,
  ) {
    if (raw is! Map) return;
    for (final entry in raw.entries) {
      final value = entry.value;
      if (value is Map) {
        target[entry.key.toString()] = decoder(
          value.map((key, item) => MapEntry(key.toString(), item)),
        );
      }
    }
  }

  String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Returns true when the rollover actually changed something, so callers can
  /// avoid rewriting an unchanged profile.
  bool _rollDailyCounterIfNeeded() {
    final today = _dayKey(clock.now());
    bool changed = false;
    if (dailyCounterDay != today) {
      dailyCounterDay = today;
      todayReviews = 0;
      _dailyCounters.clear();
      _completedQuestIds.clear();
      changed = true;
    }
    if (questDay != today) {
      questDay = today;
      _completedQuestIds.clear();
      changed = true;
    }
    return changed;
  }

  void _normalizeStreak() {
    if (lastStudyDay.isEmpty) {
      streak = 0;
      return;
    }
    final now = clock.now();
    final today = _dayKey(now);
    final yesterday = _dayKey(now.subtract(const Duration(days: 1)));
    if (lastStudyDay != today && lastStudyDay != yesterday) streak = 0;
  }

  void _recordStudyDay() {
    final now = clock.now();
    final today = _dayKey(now);
    if (lastStudyDay == today) return;
    final yesterday = _dayKey(now.subtract(const Duration(days: 1)));
    streak = lastStudyDay == yesterday ? streak + 1 : 1;
    lastStudyDay = today;
  }

  /// Binary answer path used by the multiple-choice and typing quiz modes,
  /// where the learner does not self-rate. It maps onto the same SM-2 state
  /// as [gradeWord] so both paths share one schedule per card.
  Future<void> answer(GermanWord word, {required bool correct}) async {
    await gradeWord(word, correct ? ReviewGrade.good : ReviewGrade.again);
  }

  Future<void> markSeen(GermanWord word) async {
    final p = progressFor(word.id);
    p.seen = true;
    if (p.dueAt.millisecondsSinceEpoch == 0) p.dueAt = clock.now();
    notifyListeners();
    await _save();
  }

  Future<void> recordActivity(
    String activityId, {
    required int score,
    int passingScore = 70,
  }) async {
    _registerAction();
    final p = progressForActivity(activityId);
    // Before anything moves, so the logged event describes the state the
    // attempt was made against.
    final DateTime at = clock.now();
    final int intervalBefore = p.intervalDays;
    final double easeBefore = p.ease;
    final DateTime dueBefore = p.dueAt;
    final int repsBefore = p.reps;
    final int lapsesBefore = p.lapses;
    final int stepBefore = p.learningStep;
    final ReviewGrade grade = _gradeForScore(score, passingScore);
    final oldBest = p.bestScore;
    final bool wasCompleted = p.completed;
    p.attempts += 1;
    p.bestScore = max(p.bestScore, score.clamp(0, 100).toInt());
    p.completed = p.bestScore >= passingScore;
    final improvement = max(0, p.bestScore - oldBest);
    final int gained = 8 + (score ~/ 10) + (improvement ~/ 5);
    xp += gained;
    _bumpDaily(DailyMetric.xp, gained);
    if (p.completed && !wasCompleted) _bumpDaily(DailyMetric.lessons);

    // Log every graded attempt, then schedule only the ones that passed.
    //
    // These are separate concerns and were briefly conflated: logging lived
    // inside the scheduling call, which runs only when the lesson is
    // complete, so a failed lesson left no trace at all. A lapse is precisely
    // the event a scheduler most needs, and the one an honest retention
    // figure cannot be computed without.
    await _recordReview(
      itemId: activityId,
      grade: grade,
      at: at,
      intervalBefore: intervalBefore,
      easeBefore: easeBefore,
      dueBefore: dueBefore,
      repsBefore: repsBefore,
      lapsesBefore: lapsesBefore,
      stepBefore: stepBefore,
    );

    // The score the learner just earned is the self-rating: there is no
    // separate Again/Hard/Good/Easy prompt on a lesson, so the grade is
    // derived from how well they did.
    if (p.completed) {
      _scheduleActivity(p, grade, at: at);
    }
    _settleQuests();
    notifyListeners();
    await _save();
  }

  /// Maps a lesson score onto the four-button grade the scheduler expects.
  ///
  /// A bare pass is "hard": it earned the tick but not a long interval. A
  /// score below the pass mark is a lapse, exactly as forgetting a card is.
  static ReviewGrade _gradeForScore(int score, int passingScore) {
    if (score < passingScore) return ReviewGrade.again;
    if (score >= 95) return ReviewGrade.easy;
    if (score >= passingScore + 15) return ReviewGrade.good;
    return ReviewGrade.hard;
  }

  /// The reviews this profile has recorded, oldest first.
  List<ReviewEvent> get reviewLog => List<ReviewEvent>.unmodifiable(_reviewLog);

  /// Appends one review to the log, dropping the oldest if it is full.
  ///
  /// Called with the scheduler state as it was *before* the answer, because
  /// that is what a scheduler has to be fitted against; afterwards the values
  /// have already been overwritten.
  Future<void> _recordReview({
    required String itemId,
    required ReviewGrade grade,
    required DateTime at,
    required int intervalBefore,
    required double easeBefore,
    required DateTime dueBefore,
    required int repsBefore,
    required int lapsesBefore,
    required int stepBefore,
  }) async {
    _reviewLog.add(
      ReviewEvent(
        itemId: itemId,
        at: at,
        grade: grade,
        intervalBefore: intervalBefore,
        easeBefore: easeBefore,
        dueBefore: dueBefore,
        repsBefore: repsBefore,
        lapsesBefore: lapsesBefore,
        stepBefore: stepBefore,
      ),
    );
    // The ceiling exists because the log used to be re-encoded inside the
    // profile on every save. Where it has its own table that reason is gone,
    // and a scheduler wants every event it can get.
    if (!reviewStore.isPersistent && _reviewLog.length > reviewLogLimit) {
      _reviewLog.removeRange(0, _reviewLog.length - reviewLogLimit);
    }
    if (reviewStore.isPersistent) {
      // Appended immediately rather than on the debounced save, and awaited
      // rather than fired off: one row is cheap, and an event that never
      // reaches disk is a review the learner did and the history denies.
      await reviewStore.append(_reviewLog.last);
    }
  }

  /// The most recent review of [itemId], or null if there is none in the log.
  ReviewEvent? lastReviewOf(String itemId) {
    for (int i = _reviewLog.length - 1; i >= 0; i--) {
      if (_reviewLog[i].itemId == itemId) return _reviewLog[i];
    }
    return null;
  }

  /// Reverses the most recent review of [itemId] and forgets it happened.
  ///
  /// A misgrade used to be permanent: the answer overwrote the scheduler
  /// state and nothing remembered what it had been. Each event now carries the
  /// complete prior state, so this restores it exactly rather than guessing.
  ///
  /// What is *not* rewound is XP, daily counters, quests and streaks. Those
  /// are gamification rather than scheduling, and clawing back points a
  /// learner has already been shown reads as a bug even when it is arithmetic.
  /// The correctness tallies are rewound, because they feed accuracy.
  ///
  /// Returns false when there is nothing to undo.
  Future<bool> undoLastReview(String itemId) async {
    final int index = _reviewLog.lastIndexWhere(
      (ReviewEvent e) => e.itemId == itemId,
    );
    if (index < 0) return false;
    final ReviewEvent event = _reviewLog.removeAt(index);
    if (reviewStore.isPersistent) {
      await reviewStore.removeLast(itemId);
    }

    final WordProgress? word = _progress[itemId];
    final ActivityProgress? activity = _activityProgress[itemId];

    if (word != null) {
      word.intervalDays = event.intervalBefore;
      word.ease = event.easeBefore;
      word.dueAt = event.dueBefore;
      word.reps = event.repsBefore;
      word.lapses = event.lapsesBefore;
      word.learningStep = event.stepBefore;
      if (event.grade == ReviewGrade.again) {
        word.wrong = max(0, word.wrong - 1);
        totalWrong = max(0, totalWrong - 1);
        word.mastery = min(5, word.mastery + 1);
      } else {
        word.correct = max(0, word.correct - 1);
        totalCorrect = max(0, totalCorrect - 1);
        if (event.grade != ReviewGrade.hard) {
          word.mastery = max(0, word.mastery - 1);
        }
      }
    } else if (activity != null) {
      activity.intervalDays = event.intervalBefore;
      activity.ease = event.easeBefore;
      activity.dueAt = event.dueBefore;
      activity.reps = event.repsBefore;
      activity.lapses = event.lapsesBefore;
      activity.learningStep = event.stepBefore;
    }

    notifyListeners();
    await _save();
    return true;
  }

  void _scheduleActivity(
    ActivityProgress p,
    ReviewGrade grade, {
    DateTime? at,
  }) {
    final SrsOutcome outcome = Sm2Scheduler.schedule(
      ease: p.ease,
      intervalDays: p.intervalDays,
      reps: p.reps,
      lapses: p.lapses,
      learningStep: p.learningStep,
      grade: grade,
      fuzz: scheduleFuzz,
      // What the card was actually due, so a late correct recall is credited
      // rather than scheduled as though it had been answered on time.
      //
      // Both progress models default dueAt to the epoch when a card has never
      // been scheduled. Passing that through would read as decades overdue and
      // hand a card its full lateness credit the first time it graduates, so
      // the sentinel is filtered out here rather than taught to the scheduler.
      dueAt: p.dueAt.millisecondsSinceEpoch == 0 ? null : p.dueAt,
      now: at,
    );
    p.ease = outcome.ease;
    p.intervalDays = outcome.intervalDays;
    p.reps = outcome.reps;
    p.lapses = outcome.lapses;
    p.learningStep = outcome.learningStep;
    p.dueAt = outcome.dueAt;
  }

  /// Lessons that were passed before scheduling existed carry an epoch due
  /// date, which would make all of them due at once. Spread them over the
  /// coming fortnight so an upgrading learner meets a normal daily load
  /// instead of a backlog of two hundred.
  ///
  /// Returns true when anything was rescheduled, so [load] knows to persist.
  bool _staggerUnscheduledActivities() {
    final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final List<MapEntry<String, ActivityProgress>> stale =
        _activityProgress.entries
            .where(
              (entry) => entry.value.completed && entry.value.dueAt == epoch,
            )
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    if (stale.isEmpty) return false;

    final DateTime now = clock.now();
    for (int i = 0; i < stale.length; i++) {
      final ActivityProgress p = stale[i].value;
      // Deterministic, so two devices restoring the same backup agree.
      final int offset = 1 + (i % 14);
      p.intervalDays = offset;
      p.reps = max(1, p.reps);
      p.dueAt = now.add(Duration(days: offset));
    }
    return true;
  }

  /// Move radio-episode progress into the `rd-` namespace it should always
  /// have had.
  ///
  /// Gartenradio episodes shipped with ids like `gr-a1-04`, which is the same
  /// namespace the grammar lessons use. Twenty-one of the fifty-three episodes
  /// collided with a real grammar lesson, so passing one marked the other
  /// complete: the same key, two pieces of content, one record.
  ///
  /// Only the unambiguous half can be migrated. An id that no grammar lesson
  /// claims can only ever have been written by the radio player, so the record
  /// is renamed and nothing is lost. An id that both claimed is genuinely
  /// unknowable, and the choice there is to leave it with the grammar lesson
  /// rather than duplicate it: fabricating a radio completion would mark
  /// content done that may never have been opened, and that inflates level
  /// unlocks and achievements on data already known to be unreliable. Losing a
  /// tick costs one re-listen; inventing one quietly corrupts the record.
  ///
  /// Returns true when anything moved, so [load] knows to persist.
  bool _migrateRadioIds() {
    bool changed = false;
    final Set<String> grammarIds = <String>{
      for (final CefrLevel level in CefrLevel.values)
        for (final GrammarLesson lesson in grammarFor(level)) lesson.id,
    };

    for (final CefrLevel level in CefrLevel.values) {
      for (final RadioEpisode episode in radioFor(level)) {
        if (!episode.id.startsWith('rd-')) continue;
        final String old = 'gr-${episode.id.substring(3)}';
        if (grammarIds.contains(old)) continue;
        final ActivityProgress? record = _activityProgress.remove(old);
        if (record == null) continue;
        // Never overwrite a record already under the new id: a profile that
        // has been through this once and then studied more should keep the
        // newer of the two.
        _activityProgress.putIfAbsent(episode.id, () => record);
        changed = true;
      }
    }
    return changed;
  }

  /// Exposed so the radio-id migration can be exercised directly.
  @visibleForTesting
  bool debugMigrateRadioIds() => _migrateRadioIds();

  /// Exposed so the migration can be exercised directly instead of only
  /// through a full [load].
  @visibleForTesting
  bool debugStaggerUnscheduledActivities() => _staggerUnscheduledActivities();

  /// Every passed lesson whose review has come due, oldest first.
  List<String> get dueActivityIds {
    final DateTime now = clock.now();
    final List<MapEntry<String, ActivityProgress>> due =
        _activityProgress.entries
            .where((entry) => entry.value.isDueAt(now))
            .toList()
          ..sort((a, b) => a.value.dueAt.compareTo(b.value.dueAt));
    return due.map((entry) => entry.key).toList(growable: false);
  }

  int get dueActivityCount => dueActivityIds.length;

  Future<void> saveWritingDraft(String activityId, String draft) async {
    progressForActivity(activityId).draft = draft;
    notifyListeners();
    await _save();
  }

  Future<void> toggleFavorite(String wordId) async {
    final p = progressFor(wordId);
    p.favorite = !p.favorite;
    notifyListeners();
    await _save();
  }

  Future<void> setDailyGoal(int value) async {
    dailyGoal = value.clamp(5, 100).toInt();
    notifyListeners();
    await _save();
  }

  Future<bool> setRemindersEnabled(bool value) async {
    if (value) {
      if (!remindersSupported) return false;
      try {
        if (!await reminders.requestPermission()) return false;
      } catch (error) {
        debugPrint('could not request reminder permission: $error');
        return false;
      }
      remindersEnabled = true;
    } else {
      remindersEnabled = false;
      await reminders.cancel();
    }
    notifyListeners();
    await flushSave();
    if (remindersEnabled) await refreshReminder();
    return remindersEnabled == value;
  }

  Future<void> setReminderTime(int hour, int minute) async {
    reminderHour = hour.clamp(0, 23).toInt();
    reminderMinute = minute.clamp(0, 59).toInt();
    notifyListeners();
    await flushSave();
    if (remindersEnabled) await refreshReminder();
  }

  Future<void> refreshReminder() async {
    if (!remindersEnabled || !remindersSupported) return;
    await reminders.schedule(
      ReminderPlan(
        hour: reminderHour,
        minute: reminderMinute,
        dueCount: dueCount + dueActivityCount,
      ),
    );
  }

  /// Called by the app lifecycle. Save first, then refresh the single daily
  /// notification from the final state of the session.
  Future<void> prepareForBackground() async {
    await flushSave();
    await refreshReminder();
  }

  Future<void> setTtsEnabled(bool value) async {
    ttsEnabled = value;
    notifyListeners();
    await _save();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode = value;
    notifyListeners();
    await _save();
  }

  double skillProgress(CefrLevel level, SkillType skill) {
    switch (skill) {
      case SkillType.vocabulary:
        return _vocabularyProgress(wordsForLevel(level));
      case SkillType.grammar:
        return _lessonProgress(grammarFor(level).map((e) => e.id).toList());
      case SkillType.listening:
        return _lessonProgress(listeningFor(level).map((e) => e.id).toList());
      case SkillType.reading:
        return _lessonProgress(readingFor(level).map((e) => e.id).toList());
      case SkillType.writing:
        return _lessonProgress(writingFor(level).map((e) => e.id).toList());
      case SkillType.speaking:
        return _lessonProgress(speakingFor(level).map((e) => e.id).toList());
    }
  }

  double _vocabularyProgress(Iterable<GermanWord> words) {
    final List<GermanWord> cards = words.toList(growable: false);
    if (cards.isEmpty) return 0;
    // Full-deck mastery: every bundled card contributes. This avoids
    // reporting a level as mastered after learning only a small subset.
    final int points = cards.fold<int>(
      0,
      (total, word) => total + min(3, _progress[word.id]?.mastery ?? 0),
    );
    return (points / (cards.length * 3)).clamp(0.0, 1.0).toDouble();
  }

  double _lessonProgress(List<String> ids) {
    if (ids.isEmpty) return 0;
    final sum = ids.fold<double>(0, (total, id) {
      final p = _activityProgress[id];
      if (p == null) return total;
      return total + min<double>(1.0, p.bestScore / 70.0);
    });
    return (sum / ids.length).clamp(0.0, 1.0).toDouble();
  }

  double levelProgress(CefrLevel level) {
    final sum = SkillType.values.fold<double>(
      0,
      (total, skill) => total + skillProgress(level, skill),
    );
    return sum / SkillType.values.length;
  }

  /// IDs reserved for the generated 10,000-word expansion. Numeric legacy
  /// cards deliberately remain eligible regardless of their position in the
  /// source file, so reordering content cannot change this migration.
  static bool _isExpandedVocabularyId(String id) {
    if (id.length < 2 || id[0].toLowerCase() != 'x') return false;
    final int? number = int.tryParse(id.substring(1));
    return number != null && number >= 20000;
  }

  /// x01-x12 and the original non-x lessons formed the sixteen-lesson legacy
  /// denominator. Every x13+ lesson belongs to a later expansion, including
  /// future additions that did not exist when this migration was written.
  static bool _isExpandedGrammarId(String id) {
    final int marker = id.lastIndexOf('-x');
    if (marker < 0) return false;
    final int? number = int.tryParse(id.substring(marker + 2));
    return number != null && number >= 13;
  }

  double _legacyLevelProgress(CefrLevel level) {
    final double vocabularyProgress = _vocabularyProgress(
      wordsForLevel(
        level,
      ).where((GermanWord word) => !_isExpandedVocabularyId(word.id)),
    );
    final double grammarProgress = _lessonProgress(
      grammarFor(level)
          .where((lesson) => !_isExpandedGrammarId(lesson.id))
          .map((lesson) => lesson.id)
          .toList(growable: false),
    );
    final double unchangedSkills = <SkillType>[
      SkillType.listening,
      SkillType.reading,
      SkillType.writing,
      SkillType.speaking,
    ].fold<double>(0, (total, skill) => total + skillProgress(level, skill));
    return (vocabularyProgress + grammarProgress + unchangedSkills) /
        SkillType.values.length;
  }

  /// Computes the old or current effective unlock result without mutating the
  /// persisted floor. Sequential traversal preserves the original recursive
  /// prerequisite behavior, including a placement result as a starting point.
  int _highestUnlockedOrder({required bool legacyCurriculum}) {
    int result = max(
      CefrLevel.a1.order,
      max(placementUnlockedOrder, earnedUnlockedOrder),
    ).clamp(CefrLevel.a1.order, CefrLevel.c2.order).toInt();
    for (int order = result + 1; order < CefrLevel.values.length; order++) {
      final CefrLevel previous = CefrLevel.values[order - 1];
      final double progress = legacyCurriculum
          ? _legacyLevelProgress(previous)
          : levelProgress(previous);
      if (progress < levelUnlockThreshold) break;
      result = order;
    }
    return result;
  }

  /// Raises the earned floor when current progress opens a new level. The
  /// placement-only portion is intentionally left in its existing field; only
  /// progress beyond the current effective floor is captured here.
  bool _captureEarnedUnlockFloor() {
    final int effectiveFloor = max(
      CefrLevel.a1.order,
      max(placementUnlockedOrder, earnedUnlockedOrder),
    ).clamp(CefrLevel.a1.order, CefrLevel.c2.order).toInt();
    final int currentHighest = _highestUnlockedOrder(legacyCurriculum: false);
    if (currentHighest <= effectiveFloor) return false;
    earnedUnlockedOrder = max(earnedUnlockedOrder, currentHighest);
    return true;
  }

  bool isLevelUnlocked(CefrLevel level) {
    if (level == CefrLevel.a1 ||
        level.order <= placementUnlockedOrder ||
        level.order <= earnedUnlockedOrder) {
      return true;
    }
    final previous = level.previous!;
    return isLevelUnlocked(previous) &&
        (levelProgress(previous) >= levelUnlockThreshold ||
            _courseLevelPassed(previous));
  }

  bool _courseLevelPassed(CefrLevel level) {
    final CourseUnit closing = unitsFor(level).last;
    return (_activityProgress[closing.checkpointId]?.bestScore ?? 0) >=
        courseCheckpointPass;
  }

  CefrLevel get highestUnlockedLevel {
    CefrLevel result = CefrLevel.a1;
    for (final level in CefrLevel.values) {
      if (isLevelUnlocked(level)) result = level;
    }
    return result;
  }

  Future<void> savePlacementResult(
    CefrLevel level, {
    required int score,
  }) async {
    lastPlacementLevel = level.label;
    lastPlacementScore = score.clamp(0, 100).toInt();
    lastPlacementDate = _dayKey(clock.now());
    placementUnlockedOrder = max(placementUnlockedOrder, level.order);
    _recordStudyDay();
    xp += 50;
    notifyListeners();
    await _save();
  }

  Future<void> setCivicsStateCode(String value) async {
    civicsStateCode = value;
    notifyListeners();
    await _save();
  }

  /// Records one immediately checked catalogue-practice answer.
  Future<void> recordCivicsPractice({
    required String questionId,
    required String prompt,
    required String correctAnswer,
    required String givenAnswer,
    required bool correct,
  }) async {
    _registerAction();
    final String mistakeId = 'civics:$questionId';
    if (correct) {
      totalCorrect += 1;
      _civicsCorrectQuestionIds.add(questionId);
      final int before = _mistakes.length;
      _mistakes.removeWhere((MistakeEntry entry) => entry.id == mistakeId);
      if (_mistakes.length < before) mistakesCleared += 1;
      xp += 5;
      _bumpDaily(DailyMetric.xp, 5);
      _bumpDaily(DailyMetric.perfectAnswers);
    } else {
      totalWrong += 1;
      final MistakeEntry entry = MistakeEntry(
        id: mistakeId,
        prompt: prompt,
        correctAnswer: correctAnswer,
        givenAnswer: givenAnswer,
        source: 'civics',
        level: 'LiD',
        timestamp: clock.now(),
      );
      _mistakes.removeWhere((MistakeEntry item) => item.id == mistakeId);
      _mistakes.insert(0, entry);
      if (_mistakes.length > mistakeBankLimit) {
        _mistakes.removeRange(mistakeBankLimit, _mistakes.length);
      }
    }
    _settleQuests();
    notifyListeners();
    await _save();
  }

  /// Records a complete 33-question mock in one profile write.
  Future<void> recordCivicsExam({
    required String kind,
    required String stateCode,
    required int correct,
    required int total,
    required Set<String> correctQuestionIds,
    required List<MistakeEntry> mistakes,
  }) async {
    _registerAction();
    if (total > 1) {
      todayReviews += total - 1;
      _bumpDaily(DailyMetric.reviews, total - 1);
      _checkDailyGoal();
    }
    totalCorrect += correct;
    totalWrong += max(0, total - correct);
    _civicsCorrectQuestionIds.addAll(correctQuestionIds);

    for (final String questionId in correctQuestionIds) {
      _mistakes.removeWhere(
        (MistakeEntry entry) => entry.id == 'civics:$questionId',
      );
    }
    for (final MistakeEntry mistake in mistakes) {
      _mistakes.removeWhere((MistakeEntry entry) => entry.id == mistake.id);
      _mistakes.insert(0, mistake);
    }
    if (_mistakes.length > mistakeBankLimit) {
      _mistakes.removeRange(mistakeBankLimit, _mistakes.length);
    }

    lastCivicsKind = kind;
    lastCivicsStateCode = stateCode;
    lastCivicsCorrect = correct;
    lastCivicsTotal = total;
    lastCivicsDate = _dayKey(clock.now());
    civicsTestsCompleted += 1;
    final int gained = 20 + correct * 2;
    xp += gained;
    _bumpDaily(DailyMetric.xp, gained);
    _settleQuests();
    notifyListeners();
    await _save();
  }

  Future<void> resetAllProgress() async {
    _progress.clear();
    _activityProgress.clear();
    _audioCourseDay.clear();
    _mistakes.clear();
    _dailyCounters.clear();
    _completedQuestIds.clear();
    _seenAchievementIds.clear();
    immersionMode = false;
    onboardingDone = false;
    storyChaptersDone = 0;
    conversationsDone = 0;
    speakingTurns = 0;
    dailyGoalsHit = 0;
    final bool cancelReminder = remindersEnabled;
    remindersEnabled = false;
    reminderHour = 19;
    reminderMinute = 0;
    mistakesCleared = 0;
    questDay = '';
    xp = 0;
    streak = 0;
    todayReviews = 0;
    totalCorrect = 0;
    totalWrong = 0;
    lastStudyDay = '';
    dailyCounterDay = _dayKey(clock.now());
    lastPlacementLevel = '';
    lastPlacementScore = 0;
    lastPlacementDate = '';
    placementUnlockedOrder = -1;
    civicsStateCode = '';
    _civicsCorrectQuestionIds.clear();
    lastCivicsKind = '';
    lastCivicsStateCode = '';
    lastCivicsDate = '';
    lastCivicsCorrect = 0;
    lastCivicsTotal = 0;
    civicsTestsCompleted = 0;
    earnedUnlockedOrder = CefrLevel.a1.order;
    if (cancelReminder) await reminders.cancel();
    notifyListeners();
    await _save();
  }

  // ---------------------------------------------------------------------
  // Daily counters, quests and goal tracking
  // ---------------------------------------------------------------------

  void _bumpDaily(DailyMetric metric, [int amount = 1]) {
    _dailyCounters[metric.name] = (_dailyCounters[metric.name] ?? 0) + amount;
  }

  int dailyValue(DailyMetric metric) => _dailyCounters[metric.name] ?? 0;

  /// Credits the daily goal exactly once per day, the moment it is reached.
  void _checkDailyGoal() {
    if (todayReviews < dailyGoal) return;
    const String marker = 'goalCredited';
    if ((_dailyCounters[marker] ?? 0) > 0) return;
    _dailyCounters[marker] = 1;
    dailyGoalsHit += 1;
    xp += 25;
  }

  void _registerAction() {
    _rollDailyCounterIfNeeded();
    _recordStudyDay();
    todayReviews += 1;
    _bumpDaily(DailyMetric.reviews);
    _checkDailyGoal();
  }

  List<DailyQuest> get todaysQuests => questsForDay(_dayKey(clock.now()));

  int questProgress(DailyQuest quest) => dailyValue(quest.metric);

  bool isQuestComplete(DailyQuest quest) =>
      questProgress(quest) >= quest.target;

  /// Grants any newly completed quest rewards. Called right before the
  /// listeners are notified, so a quest finished mid-action is credited in the
  /// same frame the action lands.
  void _settleQuests() {
    for (final DailyQuest quest in todaysQuests) {
      if (!isQuestComplete(quest)) continue;
      if (_completedQuestIds.contains(quest.id)) continue;
      _completedQuestIds.add(quest.id);
      xp += quest.reward;
    }
  }

  bool isQuestClaimed(DailyQuest quest) =>
      _completedQuestIds.contains(quest.id);

  /// Records that the intro has been seen, so it is not shown again.
  Future<void> completeOnboarding() async {
    if (onboardingDone) return;
    onboardingDone = true;
    notifyListeners();
    // A durability point: if the app is killed straight after the intro, the
    // learner must not be shown it a second time.
    await flushSave();
  }

  /// Sets the language card meanings are shown in.
  ///
  /// Loads the table before announcing the change, so the first frame after
  /// it already has the words rather than showing English and swapping.
  Future<void> setGlossLanguage(String code) async {
    final String next = GlossLanguage.byCode(code) == null ? '' : code;
    if (next.isNotEmpty) await loadGlosses(next);
    glossLanguage = next;
    notifyListeners();
    await _save();
  }

  /// The meaning of [word] in the learner's chosen gloss language.
  String meaningOf(GermanWord word) => meaningFor(word, glossLanguage);

  /// Sets the interface language, or null to follow the device.
  Future<void> setUiLocale(Locale? locale) async {
    uiLocale = locale;
    notifyListeners();
    await _save();
  }

  Future<void> setImmersionMode(bool value) async {
    immersionMode = value;
    notifyListeners();
    await _save();
  }

  // ---------------------------------------------------------------------
  // Spaced repetition
  // ---------------------------------------------------------------------

  /// Grades a card with the four-button SM-2 scale.
  ///
  /// [answer] is kept for the binary quiz modes; this is the richer path used
  /// by the flashcard reviewer, where the learner rates their own recall.
  Future<void> gradeWord(GermanWord word, ReviewGrade grade) async {
    _registerAction();
    final WordProgress p = progressFor(word.id);
    p.seen = true;

    // Captured before the outcome overwrites them: this is the state the
    // answer was given against, which is what a scheduler has to be fitted to.
    final DateTime at = clock.now();
    final int intervalBefore = p.intervalDays;
    final double easeBefore = p.ease;
    final DateTime dueBefore = p.dueAt;
    final int repsBefore = p.reps;
    final int lapsesBefore = p.lapses;
    final int stepBefore = p.learningStep;

    final SrsOutcome outcome = Sm2Scheduler.schedule(
      ease: p.ease,
      intervalDays: p.intervalDays,
      reps: p.reps,
      lapses: p.lapses,
      learningStep: p.learningStep,
      grade: grade,
      fuzz: scheduleFuzz,
      // What the card was actually due, so a late correct recall is credited
      // rather than scheduled as though it had been answered on time.
      //
      // Both progress models default dueAt to the epoch when a card has never
      // been scheduled. Passing that through would read as decades overdue and
      // hand a card its full lateness credit the first time it graduates, so
      // the sentinel is filtered out here rather than taught to the scheduler.
      dueAt: p.dueAt.millisecondsSinceEpoch == 0 ? null : p.dueAt,
      now: at,
    );
    p.ease = outcome.ease;
    p.intervalDays = outcome.intervalDays;
    p.reps = outcome.reps;
    p.lapses = outcome.lapses;
    p.learningStep = outcome.learningStep;
    p.dueAt = outcome.dueAt;

    await _recordReview(
      itemId: word.id,
      grade: grade,
      at: at,
      intervalBefore: intervalBefore,
      easeBefore: easeBefore,
      dueBefore: dueBefore,
      repsBefore: repsBefore,
      lapsesBefore: lapsesBefore,
      stepBefore: stepBefore,
    );

    if (grade == ReviewGrade.again) {
      totalWrong += 1;
      p.wrong += 1;
      p.mastery = max(0, p.mastery - 1);
    } else {
      totalCorrect += 1;
      p.correct += 1;
      if (grade != ReviewGrade.hard) {
        p.mastery = min(5, p.mastery + 1);
        _bumpDaily(DailyMetric.perfectAnswers);
      }
      xp += grade == ReviewGrade.easy ? 8 : 12;
      _bumpDaily(DailyMetric.xp, grade == ReviewGrade.easy ? 8 : 12);
    }
    _settleQuests();
    notifyListeners();
    await _save();
  }

  Future<void> setMnemonic(String wordId, String text) async {
    progressFor(wordId).mnemonic = text.trim();
    notifyListeners();
    await _save();
  }

  /// Cards that keep being forgotten. Memrise surfaces these as "difficult
  /// words"; they deserve a mnemonic rather than another blind repetition.
  List<GermanWord> get difficultWords {
    final List<GermanWord> list = vocabulary
        .where((word) => _progress[word.id]?.isLeech ?? false)
        .toList();
    list.sort(
      (a, b) => (_progress[b.id]?.lapses ?? 0).compareTo(
        _progress[a.id]?.lapses ?? 0,
      ),
    );
    return list;
  }

  // ---------------------------------------------------------------------
  // Mistake bank
  // ---------------------------------------------------------------------

  Future<void> addMistake(MistakeEntry entry) async {
    _mistakes.removeWhere((existing) => existing.id == entry.id);
    _mistakes.insert(0, entry);
    if (_mistakes.length > mistakeBankLimit) {
      _mistakes.removeRange(mistakeBankLimit, _mistakes.length);
    }
    notifyListeners();
    await _save();
  }

  Future<void> clearMistake(String id) async {
    final int before = _mistakes.length;
    _mistakes.removeWhere((entry) => entry.id == id);
    if (_mistakes.length < before) {
      mistakesCleared += 1;
      xp += 5;
    }
    notifyListeners();
    await _save();
  }

  Future<void> clearAllMistakes() async {
    mistakesCleared += _mistakes.length;
    _mistakes.clear();
    notifyListeners();
    await _save();
  }

  // ---------------------------------------------------------------------
  // Stories and conversations
  // ---------------------------------------------------------------------

  Future<void> recordStoryChapter(
    String chapterId, {
    required int score,
  }) async {
    final ActivityProgress p = progressForActivity(chapterId);
    final bool firstCompletion = !p.completed;
    await recordActivity(chapterId, score: score);
    if (firstCompletion && progressForActivity(chapterId).completed) {
      storyChaptersDone += 1;
      _bumpDaily(DailyMetric.storyChapters);
      _settleQuests();
      notifyListeners();
      await _save();
    }
  }

  Future<void> recordConversation(
    String scenarioId, {
    required int score,
    required int turns,
  }) async {
    final ActivityProgress p = progressForActivity(scenarioId);
    final bool firstCompletion = !p.completed;
    speakingTurns += turns;
    _bumpDaily(DailyMetric.conversationTurns, turns);
    await recordActivity(scenarioId, score: score);
    if (firstCompletion && progressForActivity(scenarioId).completed) {
      conversationsDone += 1;
    }
    _settleQuests();
    notifyListeners();
    await _save();
  }

  double conversationProgress(CefrLevel level) {
    final List<ConversationScenario> scenarios = conversationsFor(level);
    if (scenarios.isEmpty) return 0;
    final double sum = scenarios.fold<double>(0, (total, scenario) {
      final ActivityProgress? p = _activityProgress[scenario.id];
      if (p == null) return total;
      return total + min<double>(1.0, p.bestScore / 70.0);
    });
    return (sum / scenarios.length).clamp(0.0, 1.0).toDouble();
  }

  double storyProgress(CefrLevel level) {
    final List<StoryChapter> chapters = storiesFor(
      level,
    ).expand((story) => story.chapters).toList(growable: false);
    if (chapters.isEmpty) return 0;
    final int done = chapters
        .where((chapter) => _activityProgress[chapter.id]?.completed ?? false)
        .length;
    return (done / chapters.length).clamp(0.0, 1.0).toDouble();
  }

  bool isChapterDone(String chapterId) =>
      _activityProgress[chapterId]?.completed ?? false;

  // ---------------------------------------------------------------------
  // Achievements
  // ---------------------------------------------------------------------

  int metricValue(StatMetric metric) {
    switch (metric) {
      case StatMetric.streak:
        return streak;
      case StatMetric.xp:
        return xp;
      case StatMetric.wordsLearned:
        return learnedCount;
      case StatMetric.wordsMastered:
        return masteredCount;
      case StatMetric.lessonsPassed:
        return _activityProgress.values.where((p) => p.completed).length;
      case StatMetric.perfectLessons:
        return _activityProgress.values.where((p) => p.bestScore >= 100).length;
      case StatMetric.storyChapters:
        return storyChaptersDone;
      case StatMetric.conversationsCompleted:
        return conversationsDone;
      case StatMetric.speakingTurns:
        return speakingTurns;
      case StatMetric.levelsUnlocked:
        return CefrLevel.values.where(isLevelUnlocked).length;
      case StatMetric.dailyGoalsHit:
        return dailyGoalsHit;
      case StatMetric.mistakesCleared:
        return mistakesCleared;
      case StatMetric.mnemonicsWritten:
        return _progress.values
            .where((p) => p.mnemonic.trim().isNotEmpty)
            .length;
    }
  }

  bool isAchievementUnlocked(Achievement achievement) =>
      metricValue(achievement.metric) >= achievement.target;

  double achievementProgress(Achievement achievement) => achievement.target <= 0
      ? 1
      : (metricValue(achievement.metric) / achievement.target)
            .clamp(0.0, 1.0)
            .toDouble();

  List<Achievement> get unlockedAchievements =>
      achievements.where(isAchievementUnlocked).toList(growable: false);

  /// Achievements unlocked since the last time the profile screen was opened,
  /// so the app can celebrate them exactly once.
  List<Achievement> get freshAchievements => achievements
      .where(
        (achievement) =>
            isAchievementUnlocked(achievement) &&
            !_seenAchievementIds.contains(achievement.id),
      )
      .toList(growable: false);

  Future<void> acknowledgeAchievements() async {
    final List<Achievement> fresh = freshAchievements;
    if (fresh.isEmpty) return;
    _seenAchievementIds.addAll(fresh.map((achievement) => achievement.id));
    notifyListeners();
    await _save();
  }

  /// The compact profile state written to SharedPreferences.
  ///
  /// On native platforms the review log deliberately lives in SQLite and is
  /// omitted here. Use [toBackupJson] for an export that must carry it.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'xp': xp,
      'streak': streak,
      'dailyGoal': dailyGoal,
      'remindersEnabled': remindersEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'audioCourseDay': _audioCourseDay,
      'todayReviews': todayReviews,
      'totalCorrect': totalCorrect,
      'totalWrong': totalWrong,
      'ttsEnabled': ttsEnabled,
      'themeMode': themeMode.name,
      'lastStudyDay': lastStudyDay,
      'dailyCounterDay': dailyCounterDay,
      'lastPlacementLevel': lastPlacementLevel,
      'lastPlacementScore': lastPlacementScore,
      'lastPlacementDate': lastPlacementDate,
      'placementUnlockedOrder': placementUnlockedOrder,
      'civicsStateCode': civicsStateCode,
      'civicsCorrectQuestionIds': _civicsCorrectQuestionIds.toList()..sort(),
      'lastCivicsKind': lastCivicsKind,
      'lastCivicsStateCode': lastCivicsStateCode,
      'lastCivicsDate': lastCivicsDate,
      'lastCivicsCorrect': lastCivicsCorrect,
      'lastCivicsTotal': lastCivicsTotal,
      'civicsTestsCompleted': civicsTestsCompleted,
      'earnedUnlockedOrder': earnedUnlockedOrder,
      'immersionMode': immersionMode,
      'onboardingDone': onboardingDone,
      'uiLocale': uiLocale?.languageCode ?? '',
      'glossLanguage': glossLanguage,
      'storyChaptersDone': storyChaptersDone,
      'conversationsDone': conversationsDone,
      'speakingTurns': speakingTurns,
      'dailyGoalsHit': dailyGoalsHit,
      'mistakesCleared': mistakesCleared,
      'questDay': questDay,
      'dailyCounters': _dailyCounters,
      'completedQuests': _completedQuestIds.toList(),
      'seenAchievements': _seenAchievementIds.toList(),
      'mistakes': _mistakes.map((entry) => entry.toJson()).toList(),
      // Only carried in the profile where there is nowhere else to put it.
      // On native this would duplicate the whole history into the blob the
      // move was meant to empty.
      //
      // reviewLogMigrationDeferred is not optional here. If the table could
      // not be written or could not be read back, the blob is the only copy
      // left, and dropping it because a database nominally exists would lose
      // the history from both places at once -- which is the exact failure
      // the read-back check was added to prevent.
      if (!reviewStore.isPersistent || reviewLogMigrationDeferred)
        'reviewLog': _reviewLog.map((event) => event.toJson()).toList(),
      'progress': _progress.map((key, value) => MapEntry(key, value.toJson())),
      'activities': _activityProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  /// A portable profile, including the review log on every platform.
  ///
  /// [_reviewLog] is an in-memory mirror of SQLite after [load], and every new
  /// review is appended to both before this method can be called. Exporting it
  /// here avoids a database read while making the backup truthful again.
  Map<String, dynamic> toBackupJson() {
    return <String, dynamic>{
      ...toJson(),
      'reviewLog': _reviewLog
          .map((ReviewEvent event) => event.toJson())
          .toList(),
    };
  }

  /// Requests a save. The write happens once the mutations stop arriving.
  ///
  /// Callers do not await durability -- they never could, since the write was
  /// always asynchronous -- they await the request being registered. Anything
  /// that genuinely needs the bytes on disk before continuing calls
  /// [flushSave] instead.
  Future<void> _save() async {
    if (_disposed) return;
    if (!debounceWrites) {
      await flushSave();
      return;
    }
    final DateTime now = clock.now();
    _deferringSince ??= now;
    if (now.difference(_deferringSince!) >= saveMaxDeferral) {
      await flushSave();
      return;
    }
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDebounce, () {
      unawaited(flushSave());
    });
  }

  /// Writes now, and waits for it.
  ///
  /// Used where the bytes have to be on disk before the next step: a restore,
  /// a migration performed during [load], and the app being backgrounded or
  /// torn down.
  Future<void> flushSave() {
    _saveTimer?.cancel();
    _saveTimer = null;
    _deferringSince = null;
    final Future<void> mine = _writeChain.then((_) => _writeNow());
    // The chain has to survive a failed write. Without this, one error would
    // be inherited by every later save and nothing would ever be written
    // again. The caller still sees the error through [mine].
    _writeChain = mine.catchError((Object _) {});
    return mine;
  }

  Future<void> _writeNow() async {
    if (_captureEarnedUnlockFloor()) {
      _unlockFloorNeedsPersistence = true;
    }
    await _prefs.setString(_storageKey, jsonEncode(toJson()));
    _unlockFloorNeedsPersistence = false;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    final bool wasPending = _saveTimer?.isActive ?? false;
    _saveTimer?.cancel();
    _saveTimer = null;
    if (wasPending) {
      // Deliberately not awaited: dispose cannot be asynchronous. The write is
      // already queued on the chain, so it completes even though nothing here
      // waits for it.
      unawaited(_writeChain.then((_) => _writeNow()));
    }
    super.dispose();
  }

  /// Replaces all local state with a previously exported profile.
  Future<void> restoreFrom(Map<String, dynamic> state) async {
    applyJson(state);
    _rollDailyCounterIfNeeded();
    _normalizeStreak();

    // On native targets the profile blob does not carry the log after a
    // successful migration. Replace the table before saving that blob, then
    // read it back: otherwise a restore appears to work until the next launch,
    // when the old table silently wins and the imported history disappears.
    reviewLogMigrationDeferred = false;
    if (reviewStore.isPersistent) {
      try {
        await reviewStore.open();
        await reviewStore.replaceAll(_reviewLog);
        final List<ReviewEvent> readBack = await reviewStore.readAll();
        if (readBack.length != _reviewLog.length) {
          reviewLogMigrationDeferred = true;
          debugPrint(
            'review-log restore wrote ${_reviewLog.length} events '
            'and read back ${readBack.length}; retaining the profile copy',
          );
        }
      } catch (error) {
        reviewLogMigrationDeferred = true;
        debugPrint('could not restore the review log to its table: $error');
      }
    }
    notifyListeners();
    // A restore is a durability point: callers, including the backup tests,
    // read the stored blob straight afterwards.
    await flushSave();
    await refreshReminder();
  }
}
