import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'curriculum.dart';
import 'models.dart';
import 'vocabulary.dart';

class AppController extends ChangeNotifier {
  AppController();

  static const String _storageKey = 'deutsch_garden_state_v3';
  static const String _legacyStorageKey = 'deutsch_garden_state_v2';
  static const String _oldLegacyStorageKey = 'deutsch_garden_state_v1';
  static const double levelUnlockThreshold = 0.65;

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  final Map<String, WordProgress> _progress = <String, WordProgress>{};
  final Map<String, ActivityProgress> _activityProgress =
      <String, ActivityProgress>{};

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

  Map<String, WordProgress> get progress => Map.unmodifiable(_progress);
  Map<String, ActivityProgress> get activities =>
      Map.unmodifiable(_activityProgress);

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
    list.sort((a, b) =>
        _progress[a.id]!.dueAt.compareTo(_progress[b.id]!.dueAt));
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

  Future<void> load() async {
    String? raw = await _prefs.getString(_storageKey);
    raw ??= await _prefs.getString(_legacyStorageKey);
    raw ??= await _prefs.getString(_oldLegacyStorageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final root = jsonDecode(raw) as Map<String, dynamic>;
        xp = (root['xp'] as num?)?.toInt() ?? 0;
        streak = (root['streak'] as num?)?.toInt() ?? 0;
        dailyGoal = (root['dailyGoal'] as num?)?.toInt() ?? 20;
        todayReviews = (root['todayReviews'] as num?)?.toInt() ?? 0;
        totalCorrect = (root['totalCorrect'] as num?)?.toInt() ?? 0;
        totalWrong = (root['totalWrong'] as num?)?.toInt() ?? 0;
        ttsEnabled = root['ttsEnabled'] as bool? ?? true;
        lastStudyDay = root['lastStudyDay'] as String? ?? '';
        dailyCounterDay = root['dailyCounterDay'] as String? ?? '';
        lastPlacementLevel = root['lastPlacementLevel'] as String? ?? '';
        lastPlacementScore = (root['lastPlacementScore'] as num?)?.toInt() ?? 0;
        lastPlacementDate = root['lastPlacementDate'] as String? ?? '';
        placementUnlockedOrder =
            (root['placementUnlockedOrder'] as num?)?.toInt() ?? -1;
        final theme = root['themeMode'] as String? ?? 'dark';
        themeMode = theme == 'light'
            ? ThemeMode.light
            : theme == 'system'
                ? ThemeMode.system
                : ThemeMode.dark;

        _loadProgressMap(root['progress'], _progress, WordProgress.fromJson);
        _loadProgressMap(
          root['activities'],
          _activityProgress,
          ActivityProgress.fromJson,
        );
      } catch (_) {
        // Corrupt local state must never prevent the app from launching.
      }
    }

    _rollDailyCounterIfNeeded();
    _normalizeStreak();
    ready = true;
    notifyListeners();
    await _save();
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

  void _rollDailyCounterIfNeeded() {
    final today = _dayKey(DateTime.now());
    if (dailyCounterDay != today) {
      dailyCounterDay = today;
      todayReviews = 0;
    }
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

  Future<void> answer(GermanWord word, {required bool correct}) async {
    _rollDailyCounterIfNeeded();
    _recordStudyDay();
    final p = progressFor(word.id);
    p.seen = true;
    todayReviews += 1;

    if (correct) {
      totalCorrect += 1;
      p.correct += 1;
      p.mastery = min(5, p.mastery + 1);
      xp += 10 + (p.mastery * 2);
      const intervals = <int>[0, 1, 2, 4, 8, 16];
      p.dueAt = DateTime.now().add(Duration(days: intervals[p.mastery]));
    } else {
      totalWrong += 1;
      p.wrong += 1;
      p.mastery = max(0, p.mastery - 1);
      p.dueAt = DateTime.now().add(const Duration(minutes: 10));
    }
    notifyListeners();
    await _save();
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
    _rollDailyCounterIfNeeded();
    _recordStudyDay();
    final p = progressForActivity(activityId);
    final oldBest = p.bestScore;
    p.attempts += 1;
    p.bestScore = max(p.bestScore, score.clamp(0, 100).toInt());
    p.completed = p.bestScore >= passingScore;
    todayReviews += 1;
    final improvement = max(0, p.bestScore - oldBest);
    xp += 8 + (score ~/ 10) + (improvement ~/ 5);
    notifyListeners();
    await _save();
  }

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
        final words = wordsForLevel(level);
        if (words.isEmpty) return 0;
        // Full-deck mastery: every bundled card contributes. This avoids
        // reporting a level as mastered after learning only a small subset.
        final points = words.fold<int>(
          0,
          (total, word) => total + min(3, _progress[word.id]?.mastery ?? 0),
        );
        return (points / (words.length * 3)).clamp(0.0, 1.0).toDouble();
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

  bool isLevelUnlocked(CefrLevel level) {
    if (level == CefrLevel.a1 || level.order <= placementUnlockedOrder) {
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
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final json = <String, dynamic>{
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
      'progress': _progress.map((key, value) => MapEntry(key, value.toJson())),
      'activities':
          _activityProgress.map((key, value) => MapEntry(key, value.toJson())),
    };
    await _prefs.setString(_storageKey, jsonEncode(json));
  }
}
