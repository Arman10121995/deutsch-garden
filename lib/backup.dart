import 'dart:convert';

import 'app_state.dart';
import 'models.dart';
import 'platform_support.dart';

/// Outcome of trying to read a pasted backup.
class BackupImportResult {
  const BackupImportResult.detailed({
    required this.state,
    required this.exportedAt,
    required this.sourcePlatform,
  }) : error = '';

  const BackupImportResult.failure(this.error)
    : state = null,
      exportedAt = '',
      sourcePlatform = '';

  final Map<String, dynamic>? state;
  final String error;
  final String exportedAt;
  final String sourcePlatform;

  bool get isSuccess => state != null;
}

/// Moving a profile between platforms, without a server.
///
/// DeutschGarden has no account system and no backend, which is what keeps it
/// genuinely offline — but it also means a learner who studies on Android and
/// on a Windows desktop has two unrelated profiles. This turns the whole local
/// state into a portable text blob they can carry across by any means they
/// like: clipboard, a text file, a messaging app, a USB stick.
class ProgressBackup {
  const ProgressBackup._();

  static const String magic = 'deutschgarden.backup';
  static const int formatVersion = 2;

  static String export(AppController controller) {
    final Map<String, dynamic> envelope = <String, dynamic>{
      'format': magic,
      'formatVersion': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'platform': PlatformSupport.displayName,
      'state': controller.toBackupJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  /// Parses and validates a pasted backup without touching app state, so a
  /// malformed paste reports a clear reason instead of half-applying.
  static BackupImportResult parse(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const BackupImportResult.failure('Nothing was pasted.');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(trimmed);
    } catch (_) {
      return const BackupImportResult.failure(
        'That is not valid JSON. Paste the whole backup, including the '
        'opening and closing braces.',
      );
    }

    if (decoded is! Map) {
      return const BackupImportResult.failure(
        'That JSON is not a DeutschGarden backup.',
      );
    }
    final Map<String, dynamic> envelope = decoded.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    if (envelope['format'] != magic) {
      return const BackupImportResult.failure(
        'That JSON is not a DeutschGarden backup.',
      );
    }

    final int version = (envelope['formatVersion'] as num?)?.toInt() ?? 0;
    if (version > formatVersion) {
      return BackupImportResult.failure(
        'This backup was written by a newer version of DeutschGarden '
        '(format $version, this build reads $formatVersion). Update the app '
        'first.',
      );
    }

    final Object? state = envelope['state'];
    if (state is! Map) {
      return const BackupImportResult.failure(
        'The backup is missing its state section.',
      );
    }

    return BackupImportResult.detailed(
      state: state.map((key, value) => MapEntry(key.toString(), value)),
      exportedAt: envelope['exportedAt'] as String? ?? 'unknown date',
      sourcePlatform: envelope['platform'] as String? ?? 'unknown platform',
    );
  }

  /// A one-line summary of what a valid backup contains, so the learner can
  /// confirm they are restoring the right profile before it overwrites theirs.
  static String describe(Map<String, dynamic> state) {
    final int xp = (state['xp'] as num?)?.toInt() ?? 0;
    final int streak = (state['streak'] as num?)?.toInt() ?? 0;
    final Object? progress = state['progress'];
    final int words = progress is Map ? progress.length : 0;
    final Object? activities = state['activities'];
    final int lessons = activities is Map ? activities.length : 0;
    return '$xp XP • $streak-day streak • $words words • $lessons activities';
  }

  /// Reconciles an imported profile with the profile already on this device.
  ///
  /// This is intentionally a pure map operation: the merged result still goes
  /// through [AppController.restoreFrom], so there is one decoder and one
  /// durability path. Device preferences remain local. Learning records are
  /// combined per item; when both devices reviewed the same item, the snapshot
  /// belonging to the newer review supplies its scheduler state. The complete
  /// de-duplicated event history is retained for statistics and future tuning.
  static Map<String, dynamic> merge(
    Map<String, dynamic> local,
    Map<String, dynamic> incoming,
  ) {
    final List<ReviewEvent> localEvents = _events(local['reviewLog']);
    final List<ReviewEvent> incomingEvents = _events(incoming['reviewLog']);
    final Map<String, DateTime> localLatest = _latestByItem(localEvents);
    final Map<String, DateTime> incomingLatest = _latestByItem(incomingEvents);

    // Incoming first, local second: visual, reminder and accessibility
    // preferences belong to this device and must not change because someone
    // imported learning progress from a laptop or phone.
    final Map<String, dynamic> result = <String, dynamic>{
      ...incoming,
      ...local,
    };

    result['progress'] = _mergeItemMaps(
      local['progress'],
      incoming['progress'],
      localLatest,
      incomingLatest,
      activity: false,
    );
    result['activities'] = _mergeItemMaps(
      local['activities'],
      incoming['activities'],
      localLatest,
      incomingLatest,
      activity: true,
    );
    result['reviewLog'] = _mergeEvents(
      localEvents,
      incomingEvents,
    ).map((ReviewEvent event) => event.toJson()).toList(growable: false);

    for (final String field in <String>[
      'xp',
      'streak',
      'totalCorrect',
      'totalWrong',
      'storyChaptersDone',
      'conversationsDone',
      'speakingTurns',
      'dailyGoalsHit',
      'mistakesCleared',
      'placementUnlockedOrder',
      'earnedUnlockedOrder',
      'lastPlacementScore',
      'lastCivicsCorrect',
      'lastCivicsTotal',
      'civicsTestsCompleted',
    ]) {
      result[field] = _maxInt(local[field], incoming[field]);
    }

    result['onboardingDone'] =
        jsonBool(local['onboardingDone'], false) ||
        jsonBool(incoming['onboardingDone'], false);
    result['completedQuests'] = _unionStrings(
      local['completedQuests'],
      incoming['completedQuests'],
    );
    result['seenAchievements'] = _unionStrings(
      local['seenAchievements'],
      incoming['seenAchievements'],
    );
    result['civicsCorrectQuestionIds'] = _unionStrings(
      local['civicsCorrectQuestionIds'],
      incoming['civicsCorrectQuestionIds'],
    );
    result['audioCourseDay'] = _mergeIntMap(
      local['audioCourseDay'],
      incoming['audioCourseDay'],
    );
    result['mistakes'] = _mergeMistakes(
      local['mistakes'],
      incoming['mistakes'],
    );

    final String localDaily = jsonString(local['dailyCounterDay'], '');
    final String incomingDaily = jsonString(incoming['dailyCounterDay'], '');
    if (incomingDaily.compareTo(localDaily) > 0) {
      result['dailyCounterDay'] = incomingDaily;
      result['todayReviews'] = jsonInt(incoming['todayReviews'], 0);
      result['dailyCounters'] = incoming['dailyCounters'] ?? <String, int>{};
      result['questDay'] = jsonString(incoming['questDay'], incomingDaily);
    } else if (incomingDaily == localDaily) {
      result['todayReviews'] = _maxInt(
        local['todayReviews'],
        incoming['todayReviews'],
      );
      result['dailyCounters'] = _mergeIntMap(
        local['dailyCounters'],
        incoming['dailyCounters'],
      );
    }

    result['lastStudyDay'] = _newerDate(
      local['lastStudyDay'],
      incoming['lastStudyDay'],
    );
    _takeNewerResult(
      result,
      local,
      incoming,
      dateField: 'lastPlacementDate',
      fields: <String>['lastPlacementDate', 'lastPlacementLevel'],
    );
    _takeNewerResult(
      result,
      local,
      incoming,
      dateField: 'lastCivicsDate',
      fields: <String>[
        'lastCivicsDate',
        'lastCivicsKind',
        'lastCivicsStateCode',
      ],
    );
    return result;
  }

  static List<ReviewEvent> _events(Object? raw) {
    if (raw is! List) return <ReviewEvent>[];
    return <ReviewEvent>[
      for (final Object? item in raw)
        if (ReviewEvent.fromJson(item) case final ReviewEvent event) event,
    ];
  }

  static Map<String, DateTime> _latestByItem(List<ReviewEvent> events) {
    final Map<String, DateTime> latest = <String, DateTime>{};
    for (final ReviewEvent event in events) {
      final DateTime? previous = latest[event.itemId];
      if (previous == null || event.at.isAfter(previous)) {
        latest[event.itemId] = event.at;
      }
    }
    return latest;
  }

  static List<ReviewEvent> _mergeEvents(
    List<ReviewEvent> local,
    List<ReviewEvent> incoming,
  ) {
    final Map<String, ReviewEvent> unique = <String, ReviewEvent>{};
    for (final ReviewEvent event in <ReviewEvent>[...local, ...incoming]) {
      unique[jsonEncode(event.toJson())] = event;
    }
    final List<ReviewEvent> merged = unique.values.toList();
    merged.sort((ReviewEvent a, ReviewEvent b) {
      final int byTime = a.at.compareTo(b.at);
      if (byTime != 0) return byTime;
      final int byItem = a.itemId.compareTo(b.itemId);
      if (byItem != 0) return byItem;
      return a.grade.index.compareTo(b.grade.index);
    });
    return merged;
  }

  static Map<String, dynamic> _mergeItemMaps(
    Object? localRaw,
    Object? incomingRaw,
    Map<String, DateTime> localLatest,
    Map<String, DateTime> incomingLatest, {
    required bool activity,
  }) {
    final Map<String, dynamic> local = _stringMap(localRaw);
    final Map<String, dynamic> incoming = _stringMap(incomingRaw);
    final Map<String, dynamic> merged = <String, dynamic>{};
    for (final String id in <String>{...local.keys, ...incoming.keys}) {
      final Map<String, dynamic> left = _stringMap(local[id]);
      final Map<String, dynamic> right = _stringMap(incoming[id]);
      if (left.isEmpty) {
        merged[id] = right;
        continue;
      }
      if (right.isEmpty) {
        merged[id] = left;
        continue;
      }

      final DateTime? leftAt = localLatest[id];
      final DateTime? rightAt = incomingLatest[id];
      final bool takeRight =
          rightAt != null && (leftAt == null || rightAt.isAfter(leftAt)) ||
          rightAt == leftAt &&
              _progressWeight(right, activity) >
                  _progressWeight(left, activity);
      final Map<String, dynamic> chosen = takeRight ? right : left;
      final Map<String, dynamic> other = takeRight ? left : right;
      final Map<String, dynamic> item = <String, dynamic>{...chosen};

      if (activity) {
        item['bestScore'] = _maxInt(
          left['bestScore'],
          right['bestScore'],
        ).clamp(0, 100);
        item['attempts'] = _maxInt(left['attempts'], right['attempts']);
        item['completed'] =
            jsonBool(left['completed'], false) ||
            jsonBool(right['completed'], false);
        final String draft = jsonString(chosen['draft'], '');
        final String otherDraft = jsonString(other['draft'], '');
        item['draft'] = draft.isNotEmpty ? draft : otherDraft;
      } else {
        item['seen'] =
            jsonBool(left['seen'], false) || jsonBool(right['seen'], false);
        item['favorite'] =
            jsonBool(left['favorite'], false) ||
            jsonBool(right['favorite'], false);
        item['correct'] = _maxInt(left['correct'], right['correct']);
        item['wrong'] = _maxInt(left['wrong'], right['wrong']);
        item['mastery'] = _maxInt(
          left['mastery'],
          right['mastery'],
        ).clamp(0, 5);
        final String mnemonic = jsonString(chosen['mnemonic'], '');
        item['mnemonic'] = mnemonic.isNotEmpty
            ? mnemonic
            : jsonString(other['mnemonic'], '');
      }
      merged[id] = item;
    }
    return merged;
  }

  static int _progressWeight(Map<String, dynamic> item, bool activity) {
    if (activity) {
      return jsonInt(item['attempts'], 0) * 1000 +
          jsonInt(item['bestScore'], 0);
    }
    return jsonInt(item['reps'], 0) * 1000 +
        jsonInt(item['correct'], 0) +
        jsonInt(item['wrong'], 0);
  }

  static Map<String, dynamic> _stringMap(Object? raw) {
    if (raw is! Map) return <String, dynamic>{};
    return raw.map(
      (Object? key, Object? value) => MapEntry(key.toString(), value),
    );
  }

  static int _maxInt(Object? a, Object? b) =>
      jsonInt(a, 0) > jsonInt(b, 0) ? jsonInt(a, 0) : jsonInt(b, 0);

  static List<String> _unionStrings(Object? a, Object? b) {
    final Set<String> values = <String>{};
    if (a is List) values.addAll(a.map((Object? value) => value.toString()));
    if (b is List) values.addAll(b.map((Object? value) => value.toString()));
    return values.toList()..sort();
  }

  static Map<String, int> _mergeIntMap(Object? a, Object? b) {
    final Map<String, dynamic> left = _stringMap(a);
    final Map<String, dynamic> right = _stringMap(b);
    return <String, int>{
      for (final String key in <String>{...left.keys, ...right.keys})
        key: _maxInt(left[key], right[key]),
    };
  }

  static List<Map<String, dynamic>> _mergeMistakes(Object? a, Object? b) {
    final Map<String, Map<String, dynamic>> byId =
        <String, Map<String, dynamic>>{};
    for (final Object? raw in <Object?>[
      if (a is List) ...a,
      if (b is List) ...b,
    ]) {
      final Map<String, dynamic> item = _stringMap(raw);
      final String id = jsonString(item['id'], '');
      if (id.isEmpty) continue;
      final Map<String, dynamic>? previous = byId[id];
      if (previous == null ||
          jsonDate(
            item['timestamp'],
          ).isAfter(jsonDate(previous['timestamp']))) {
        byId[id] = item;
      }
    }
    final List<Map<String, dynamic>> merged = byId.values.toList();
    merged.sort(
      (Map<String, dynamic> a, Map<String, dynamic> b) =>
          jsonDate(b['timestamp']).compareTo(jsonDate(a['timestamp'])),
    );
    return merged.take(AppController.mistakeBankLimit).toList(growable: false);
  }

  static String _newerDate(Object? a, Object? b) {
    final String left = jsonString(a, '');
    final String right = jsonString(b, '');
    return right.compareTo(left) > 0 ? right : left;
  }

  static void _takeNewerResult(
    Map<String, dynamic> result,
    Map<String, dynamic> local,
    Map<String, dynamic> incoming, {
    required String dateField,
    required List<String> fields,
  }) {
    final bool takeIncoming =
        jsonString(
          incoming[dateField],
          '',
        ).compareTo(jsonString(local[dateField], '')) >
        0;
    final Map<String, dynamic> source = takeIncoming ? incoming : local;
    for (final String field in fields) {
      result[field] = source[field];
    }
  }
}
