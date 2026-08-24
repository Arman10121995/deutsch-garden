import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'achievements.dart';
import 'conversation.dart';
import 'curriculum.dart';
import 'models.dart';
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
  static const double levelUnlockThreshold = 0.65;

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  final Map<String, WordProgress> _progress = <String, WordProgress>{};
  final Map<String, ActivityProgress> _activityProgress =
      <String, ActivityProgress>{};
  final List<MistakeEntry> _mistakes = <MistakeEntry>[];
  final Map<String, int> _dailyCounters = <String, int>{};
  final Set<String> _completedQuestIds = <String>{};
  final Set<String> _seenAchievementIds = <String>{};

  bool ready = false;
  int xp = 0;
  int streak = 0;
  int dailyGoal = 20;
  int todayReviews = 0;
  int totalCorrect = 0;
  int totalWrong = 0;
  bool ttsEnabled = true;
  ThemeMode themeMode = ThemeMode.dark;
  String lastStudyDay = '';
  String dailyCounterDay = '';
  String lastPlacementLevel = '';
  int lastPlacementScore = 0;
  String lastPlacementDate = '';
  int placementUnlockedOrder = -1;

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

  int get learnedCount => _progress.values.where((p) => p.seen).length;
  int get masteredCount => _progress.values.where((p) => p.mastered).length;
  int get dueCount => reviewWords.length;
  int get attempts => totalCorrect + totalWrong;
  double get accuracy => attempts == 0 ? 0 : totalCorrect / attempts;
  double get dailyGoalProgress =>
      dailyGoal <= 0 ? 0.0 : min<double>(1.0, todayReviews / dailyGoal);

  List<GermanWord> wordsForLevel(CefrLevel level) => vocabulary
      .where((word) => word.level.toUpperCase() == level.label)
      .toList(growable: false);

  List<GermanWord> reviewWordsForLevel(CefrLevel level) {
    final now = DateTime.now();
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
    final now = DateTime.now();
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
        _unlockFloorNeedsPersistence ||
        (hadStoredProfile && loaded && primary == null)) {
      await _save();
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
    earnedUnlockedOrder = hasEarnedUnlockFloor
        ? jsonInt(
            earnedUnlockRaw,
            0,
          ).clamp(CefrLevel.a1.order, CefrLevel.c2.order)
        : CefrLevel.a1.order;
    immersionMode = jsonBool(root['immersionMode'], false);
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
    final today = _dayKey(DateTime.now());
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
    final now = DateTime.now();
    final today = _dayKey(now);
    final yesterday = _dayKey(now.subtract(const Duration(days: 1)));
    if (lastStudyDay != today && lastStudyDay != yesterday) streak = 0;
  }

  void _recordStudyDay() {
    final now = DateTime.now();
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
    if (p.dueAt.millisecondsSinceEpoch == 0) p.dueAt = DateTime.now();
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

    // Schedule the lesson for review. The score the learner just earned is the
    // self-rating: there is no separate Again/Hard/Good/Easy prompt on a
    // lesson, so the grade is derived from how well they did.
    if (p.completed) {
      _scheduleActivity(p, _gradeForScore(score, passingScore));
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

  void _scheduleActivity(ActivityProgress p, ReviewGrade grade) {
    final SrsOutcome outcome = Sm2Scheduler.schedule(
      ease: p.ease,
      intervalDays: p.intervalDays,
      reps: p.reps,
      lapses: p.lapses,
      learningStep: p.learningStep,
      grade: grade,
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

    final DateTime now = DateTime.now();
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

  /// Exposed so the migration can be exercised directly instead of only
  /// through a full [load].
  @visibleForTesting
  bool debugStaggerUnscheduledActivities() => _staggerUnscheduledActivities();

  /// Every passed lesson whose review has come due, oldest first.
  List<String> get dueActivityIds {
    final DateTime now = DateTime.now();
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
        levelProgress(previous) >= levelUnlockThreshold;
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
    lastPlacementDate = _dayKey(DateTime.now());
    placementUnlockedOrder = max(placementUnlockedOrder, level.order);
    _recordStudyDay();
    xp += 50;
    notifyListeners();
    await _save();
  }

  Future<void> resetAllProgress() async {
    _progress.clear();
    _activityProgress.clear();
    _mistakes.clear();
    _dailyCounters.clear();
    _completedQuestIds.clear();
    _seenAchievementIds.clear();
    immersionMode = false;
    storyChaptersDone = 0;
    conversationsDone = 0;
    speakingTurns = 0;
    dailyGoalsHit = 0;
    mistakesCleared = 0;
    questDay = '';
    xp = 0;
    streak = 0;
    todayReviews = 0;
    totalCorrect = 0;
    totalWrong = 0;
    lastStudyDay = '';
    dailyCounterDay = _dayKey(DateTime.now());
    lastPlacementLevel = '';
    lastPlacementScore = 0;
    lastPlacementDate = '';
    placementUnlockedOrder = -1;
    earnedUnlockedOrder = CefrLevel.a1.order;
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

  List<DailyQuest> get todaysQuests => questsForDay(_dayKey(DateTime.now()));

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

    final SrsOutcome outcome = Sm2Scheduler.schedule(
      ease: p.ease,
      intervalDays: p.intervalDays,
      reps: p.reps,
      lapses: p.lapses,
      learningStep: p.learningStep,
      grade: grade,
    );
    p.ease = outcome.ease;
    p.intervalDays = outcome.intervalDays;
    p.reps = outcome.reps;
    p.lapses = outcome.lapses;
    p.learningStep = outcome.learningStep;
    p.dueAt = outcome.dueAt;

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

  /// The complete persisted state, also used as the backup payload.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'xp': xp,
      'streak': streak,
      'dailyGoal': dailyGoal,
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
      'earnedUnlockedOrder': earnedUnlockedOrder,
      'immersionMode': immersionMode,
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
      'progress': _progress.map((key, value) => MapEntry(key, value.toJson())),
      'activities': _activityProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  Future<void> _save() async {
    if (_captureEarnedUnlockFloor()) {
      _unlockFloorNeedsPersistence = true;
    }
    await _prefs.setString(_storageKey, jsonEncode(toJson()));
    _unlockFloorNeedsPersistence = false;
  }

  /// Replaces all local state with a previously exported profile.
  Future<void> restoreFrom(Map<String, dynamic> state) async {
    applyJson(state);
    _rollDailyCounterIfNeeded();
    _normalizeStreak();
    notifyListeners();
    await _save();
  }
}
