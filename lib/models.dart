import 'package:flutter/material.dart';

import 'srs.dart';

enum CefrLevel { a1, a2, b1, b2, c1, c2 }

extension CefrLevelX on CefrLevel {
  String get label => name.toUpperCase();
  int get order => CefrLevel.values.indexOf(this);
  CefrLevel? get previous => order == 0 ? null : CefrLevel.values[order - 1];
  CefrLevel? get next => order == CefrLevel.values.length - 1 ? null : CefrLevel.values[order + 1];

  String get description {
    switch (this) {
      case CefrLevel.a1:
        return 'Beginner • everyday basics';
      case CefrLevel.a2:
        return 'Elementary • routine communication';
      case CefrLevel.b1:
        return 'Intermediate • independent communication';
      case CefrLevel.b2:
        return 'Upper-intermediate • complex topics';
      case CefrLevel.c1:
        return 'Advanced • flexible, precise language';
      case CefrLevel.c2:
        return 'Mastery • nuanced, near-native control';
    }
  }
}

enum SkillType { vocabulary, grammar, listening, reading, writing, speaking }

extension SkillTypeX on SkillType {
  String get label {
    switch (this) {
      case SkillType.vocabulary:
        return 'Vocabulary';
      case SkillType.grammar:
        return 'Grammar';
      case SkillType.listening:
        return 'Listening';
      case SkillType.reading:
        return 'Reading';
      case SkillType.writing:
        return 'Writing';
      case SkillType.speaking:
        return 'Speaking';
    }
  }

  String get emoji {
    switch (this) {
      case SkillType.vocabulary:
        return '🌱';
      case SkillType.grammar:
        return '🧩';
      case SkillType.listening:
        return '🎧';
      case SkillType.reading:
        return '📖';
      case SkillType.writing:
        return '✍️';
      case SkillType.speaking:
        return '🗣️';
    }
  }
}

enum SessionKind { learn, review, practice }

enum QuizMode { flashcard, meaning, german, article, typing }

class GermanWord {
  const GermanWord({
    required this.id,
    required this.article,
    required this.german,
    required this.plural,
    required this.english,
    required this.exampleGerman,
    required this.exampleEnglish,
    required this.category,
    required this.level,
  });

  final String id;
  final String article;
  final String german;
  final String plural;
  final String english;
  final String exampleGerman;
  final String exampleEnglish;
  final String category;
  final String level;

  CefrLevel get cefr => CefrLevel.values.firstWhere(
        (value) => value.label == level.toUpperCase(),
        orElse: () => CefrLevel.a1,
      );

  String get displayGerman => article.isEmpty ? german : '$article $german';

  Color genderColor(Brightness brightness) {
    switch (article.toLowerCase()) {
      case 'der':
        return brightness == Brightness.dark
            ? const Color(0xFF64B5F6)
            : const Color(0xFF1565C0);
      case 'die':
        return brightness == Brightness.dark
            ? const Color(0xFFEF9A9A)
            : const Color(0xFFC62828);
      case 'das':
        return brightness == Brightness.dark
            ? const Color(0xFF81C784)
            : const Color(0xFF2E7D32);
      default:
        return brightness == Brightness.dark
            ? const Color(0xFFB0BEC5)
            : const Color(0xFF546E7A);
    }
  }
}

/// Coercions used by every `fromJson` below.
///
/// Persisted state is decoded with `as` casts nowhere: a single value of the
/// wrong type in a hand-edited or truncated profile must cost that one field,
/// not throw part-way through rehydrating and leave the profile half-applied.
int jsonInt(Object? value, int fallback) =>
    value is num && value.isFinite ? value.toInt() : fallback;

double jsonDouble(Object? value, double fallback) =>
    value is num && value.isFinite ? value.toDouble() : fallback;

bool jsonBool(Object? value, bool fallback) => value is bool ? value : fallback;

String jsonString(Object? value, String fallback) =>
    value is String ? value : fallback;

DateTime jsonDate(Object? value) =>
    (value is String ? DateTime.tryParse(value) : null) ??
    DateTime.fromMillisecondsSinceEpoch(0);

class WordProgress {
  WordProgress({
    this.mastery = 0,
    DateTime? dueAt,
    this.correct = 0,
    this.wrong = 0,
    this.favorite = false,
    this.seen = false,
    this.ease = 2.5,
    this.intervalDays = 0,
    this.reps = 0,
    this.lapses = 0,
    this.learningStep = 0,
    this.mnemonic = '',
  }) : dueAt = dueAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  int mastery;
  DateTime dueAt;
  int correct;
  int wrong;
  bool favorite;
  bool seen;

  /// SM-2 scheduling state. [ease] is the per-card difficulty multiplier,
  /// [intervalDays] the last scheduled interval (0 while the card is still in
  /// its learning steps), [lapses] the number of times it was forgotten after
  /// graduating, and [learningStep] the index into the learning ladder.
  double ease;
  int intervalDays;
  int reps;
  int lapses;
  int learningStep;

  /// The learner's own memory hook for this word — Memrise calls these
  /// "mems", and a self-authored one is worth more than any stock example.
  String mnemonic;

  int get attempts => correct + wrong;
  double get accuracy => attempts == 0 ? 0 : correct / attempts;
  bool get mastered => mastery >= 5;

  /// A card is "leech-like" once it has been forgotten repeatedly: it needs a
  /// mnemonic or a different approach, not more of the same drilling.
  bool get isLeech => lapses >= 4;

  /// What [plantIcon] conveys, in words.
  ///
  /// The emoji alone is announced by a screen reader as "seedling" or
  /// "tulip", which tells a learner who cannot see it nothing at all about
  /// where the card stands.
  String get masteryLabel {
    if (!seen) return 'Not started';
    if (mastery >= 5) return 'Mastered';
    return 'Mastery $mastery of 5';
  }

  String get plantIcon {
    if (mastery <= 0) return '🌰';
    if (mastery == 1) return '🌱';
    if (mastery == 2) return '🌿';
    if (mastery == 3) return '🌷';
    if (mastery == 4) return '🌻';
    return '🌳';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mastery': mastery,
        'dueAt': dueAt.toIso8601String(),
        'correct': correct,
        'wrong': wrong,
        'favorite': favorite,
        'seen': seen,
        'ease': ease,
        'intervalDays': intervalDays,
        'reps': reps,
        'lapses': lapses,
        'learningStep': learningStep,
        'mnemonic': mnemonic,
      };

  factory WordProgress.fromJson(Map<String, dynamic> json) {
    final int mastery = jsonInt(json['mastery'], 0).clamp(0, 5);
    return WordProgress(
      mastery: mastery,
      dueAt: jsonDate(json['dueAt']),
      correct: jsonInt(json['correct'], 0).clamp(0, 1 << 30),
      wrong: jsonInt(json['wrong'], 0).clamp(0, 1 << 30),
      favorite: jsonBool(json['favorite'], false),
      seen: jsonBool(json['seen'], false),
      // Bounds are the scheduler's own. An out-of-range ease from a corrupt or
      // hand-edited profile would otherwise produce absurd intervals for the
      // life of the card.
      ease: jsonDouble(json['ease'], 2.5).clamp(1.3, 3.2),
      // Cards saved before 3.1 have no SM-2 state. Seeding the interval from
      // the old fixed ladder keeps their schedule roughly where the learner
      // left it instead of resetting every card to "new".
      intervalDays: jsonInt(
        json['intervalDays'],
        const <int>[0, 1, 2, 4, 8, 16][mastery],
      ).clamp(0, 365),
      reps: jsonInt(json['reps'], mastery).clamp(0, 1 << 30),
      lapses: jsonInt(json['lapses'], 0).clamp(0, 1 << 30),
      learningStep:
          jsonInt(json['learningStep'], mastery > 0 ? 2 : 0).clamp(0, 8),
      mnemonic: jsonString(json['mnemonic'], ''),
    );
  }
}

class ActivityProgress {
  ActivityProgress({
    this.bestScore = 0,
    this.attempts = 0,
    this.completed = false,
    this.draft = '',
    DateTime? dueAt,
    this.ease = 2.5,
    this.intervalDays = 0,
    this.reps = 0,
    this.lapses = 0,
    this.learningStep = 0,
  }) : dueAt = dueAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  int bestScore;
  int attempts;
  bool completed;
  String draft;

  /// Scheduling state, mirroring [WordProgress].
  ///
  /// Until this existed a lesson was finished once and never came back: 96
  /// grammar lessons, 36 listening, 36 reading, 36 writing and 18 speaking —
  /// 222 in total — were tracked with nothing but a completion flag, while
  /// only vocabulary was ever scheduled for review. German case endings and
  /// verb governance decay exactly like vocabulary does, so they are now
  /// carried by the same SM-2 machinery.
  DateTime dueAt;
  double ease;
  int intervalDays;
  int reps;
  int lapses;
  int learningStep;

  /// A lesson only enters the review rotation once it has been passed. An
  /// unfinished lesson belongs in the learning path, not the review queue.
  bool isDueAt(DateTime now) => completed && !dueAt.isAfter(now);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'bestScore': bestScore,
        'attempts': attempts,
        'completed': completed,
        'draft': draft,
        'dueAt': dueAt.toIso8601String(),
        'ease': ease,
        'intervalDays': intervalDays,
        'reps': reps,
        'lapses': lapses,
        'learningStep': learningStep,
      };

  factory ActivityProgress.fromJson(Map<String, dynamic> json) {
    return ActivityProgress(
      bestScore: jsonInt(json['bestScore'], 0).clamp(0, 100),
      attempts: jsonInt(json['attempts'], 0).clamp(0, 1 << 30),
      completed: jsonBool(json['completed'], false),
      draft: jsonString(json['draft'], ''),
      // Profiles written before lessons were scheduled have no due date. They
      // decode to the epoch, which makes every already-passed lesson due at
      // once — correct, but it would drop hundreds of reviews on the learner
      // in one go, so the controller staggers them on first sight instead.
      dueAt: jsonDate(json['dueAt']),
      ease: jsonDouble(json['ease'], 2.5).clamp(1.3, 3.2),
      intervalDays: jsonInt(json['intervalDays'], 0).clamp(0, 365),
      reps: jsonInt(json['reps'], 0).clamp(0, 1 << 30),
      lapses: jsonInt(json['lapses'], 0).clamp(0, 1 << 30),
      learningStep: jsonInt(json['learningStep'], 0).clamp(0, 8),
    );
  }
}

class ChoiceQuestion {
  const ChoiceQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

class GrammarLesson {
  const GrammarLesson({
    required this.id,
    required this.level,
    required this.title,
    required this.explanation,
    required this.examples,
    required this.questions,
  });

  final String id;
  final CefrLevel level;
  final String title;
  final String explanation;
  final List<String> examples;
  final List<ChoiceQuestion> questions;
}

class ListeningLesson {
  const ListeningLesson({
    required this.id,
    required this.level,
    required this.title,
    required this.transcript,
    required this.translation,
    required this.questions,
  });

  final String id;
  final CefrLevel level;
  final String title;
  final String transcript;
  final String translation;
  final List<ChoiceQuestion> questions;
}

class ReadingLesson {
  const ReadingLesson({
    required this.id,
    required this.level,
    required this.title,
    required this.passage,
    required this.questions,
  });

  final String id;
  final CefrLevel level;
  final String title;
  final String passage;
  final List<ChoiceQuestion> questions;
}

class WritingLesson {
  const WritingLesson({
    required this.id,
    required this.level,
    required this.title,
    required this.prompt,
    required this.guidance,
    required this.minWords,
    required this.keywords,
    required this.example,
  });

  final String id;
  final CefrLevel level;
  final String title;
  final String prompt;
  final List<String> guidance;
  final int minWords;
  final List<String> keywords;
  final String example;
}


class SpeakingLesson {
  const SpeakingLesson({
    required this.id,
    required this.level,
    required this.title,
    required this.prompt,
    required this.guidance,
    required this.modelPhrases,
    required this.targetSeconds,
  });

  final String id;
  final CefrLevel level;
  final String title;
  final String prompt;
  final List<String> guidance;
  final List<String> modelPhrases;
  final int targetSeconds;
}

class SessionQuestion {
  const SessionQuestion({
    required this.word,
    required this.mode,
    this.options = const <String>[],
  });

  final GermanWord word;
  final QuizMode mode;
  final List<String> options;
}


/// A single wrong answer, kept so the learner can drill exactly what they got
/// wrong. Duolingo's "mistakes review" and Memrise's "difficult words" are
/// the same idea: the highest-yield queue is the one you built by failing.
class MistakeEntry {
  const MistakeEntry({
    required this.id,
    required this.prompt,
    required this.correctAnswer,
    required this.givenAnswer,
    required this.source,
    required this.level,
    required this.timestamp,
  });

  final String id;
  final String prompt;
  final String correctAnswer;
  final String givenAnswer;

  /// Where it came from: 'vocabulary', 'grammar', 'listening', 'reading',
  /// 'dictation' or 'story'.
  final String source;
  final String level;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'prompt': prompt,
        'correctAnswer': correctAnswer,
        'givenAnswer': givenAnswer,
        'source': source,
        'level': level,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MistakeEntry.fromJson(Map<String, dynamic> json) => MistakeEntry(
        id: jsonString(json['id'], ''),
        prompt: jsonString(json['prompt'], ''),
        correctAnswer: jsonString(json['correctAnswer'], ''),
        givenAnswer: jsonString(json['givenAnswer'], ''),
        source: jsonString(json['source'], 'vocabulary'),
        level: jsonString(json['level'], 'A1'),
        timestamp: jsonDate(json['timestamp']),
      );
}

/// One graded review, exactly as it happened.
///
/// The scheduler state on [WordProgress] and [ActivityProgress] records where
/// a card is now; nothing recorded how it got there. That absence is what
/// makes SM-2 untunable rather than merely untuned -- FSRS and every other
/// modern scheduler is fitted to a history of reviews, and there was none to
/// fit. It also makes honest retention statistics impossible (an all-time
/// accuracy percentage answers almost nothing), and makes an undo of a
/// misgrade impossible, because the previous state was overwritten.
///
/// Events are immutable facts with timestamps. That is also what makes two
/// devices reconcilable later: logs merge, current-state snapshots can only
/// overwrite each other.
@immutable
class ReviewEvent {
  const ReviewEvent({
    required this.itemId,
    required this.at,
    required this.grade,
    required this.intervalBefore,
    required this.easeBefore,
    required this.elapsedDays,
  });

  /// The vocabulary card id or activity id that was reviewed.
  final String itemId;

  final DateTime at;
  final ReviewGrade grade;

  /// The interval the card was on *before* this answer, in days. Zero while
  /// the card is still in learning.
  final int intervalBefore;

  /// The ease factor before this answer.
  final double easeBefore;

  /// Days between this review and the previous one.
  ///
  /// Derived rather than remembered: the previous review set [intervalBefore]
  /// and a due date, so the gap is that interval plus however late the answer
  /// actually came. Zero when the card had never been scheduled, which is not
  /// the same as "reviewed today" and should be read as unknown.
  final int elapsedDays;

  /// Positional, not keyed.
  ///
  /// Until the profile moves off a single SharedPreferences string, every
  /// event lives inside the same blob that is rewritten on save. Field names
  /// would roughly double the size of the log for no benefit, since nothing
  /// but this class ever reads it. Seconds rather than milliseconds for the
  /// same reason.
  List<Object> toJson() => <Object>[
        itemId,
        at.millisecondsSinceEpoch ~/ 1000,
        grade.index,
        intervalBefore,
        double.parse(easeBefore.toStringAsFixed(2)),
        elapsedDays,
      ];

  /// Returns null for anything that does not parse, so one bad entry costs
  /// that entry rather than the whole log.
  static ReviewEvent? fromJson(Object? raw) {
    if (raw is! List || raw.length < 6) return null;
    final String id = raw[0].toString();
    if (id.isEmpty) return null;
    final int seconds = jsonInt(raw[1], 0);
    if (seconds <= 0) return null;
    final int gradeIndex = jsonInt(raw[2], -1);
    if (gradeIndex < 0 || gradeIndex >= ReviewGrade.values.length) return null;
    return ReviewEvent(
      itemId: id,
      at: DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
      grade: ReviewGrade.values[gradeIndex],
      intervalBefore: jsonInt(raw[3], 0),
      easeBefore: jsonDouble(raw[4], 2.5),
      elapsedDays: jsonInt(raw[5], 0),
    );
  }
}
