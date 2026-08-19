import 'package:flutter/material.dart';

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
    final int mastery = (json['mastery'] as num?)?.toInt() ?? 0;
    return WordProgress(
      mastery: mastery,
      dueAt: DateTime.tryParse(json['dueAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      wrong: (json['wrong'] as num?)?.toInt() ?? 0,
      favorite: json['favorite'] as bool? ?? false,
      seen: json['seen'] as bool? ?? false,
      ease: (json['ease'] as num?)?.toDouble() ?? 2.5,
      // Cards saved before 3.1 have no SM-2 state. Seeding the interval from
      // the old fixed ladder keeps their schedule roughly where the learner
      // left it instead of resetting every card to "new".
      intervalDays: (json['intervalDays'] as num?)?.toInt() ??
          const <int>[0, 1, 2, 4, 8, 16][mastery.clamp(0, 5)],
      reps: (json['reps'] as num?)?.toInt() ?? mastery,
      lapses: (json['lapses'] as num?)?.toInt() ?? 0,
      learningStep: (json['learningStep'] as num?)?.toInt() ?? (mastery > 0 ? 2 : 0),
      mnemonic: json['mnemonic'] as String? ?? '',
    );
  }
}

class ActivityProgress {
  ActivityProgress({
    this.bestScore = 0,
    this.attempts = 0,
    this.completed = false,
    this.draft = '',
  });

  int bestScore;
  int attempts;
  bool completed;
  String draft;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'bestScore': bestScore,
        'attempts': attempts,
        'completed': completed,
        'draft': draft,
      };

  factory ActivityProgress.fromJson(Map<String, dynamic> json) {
    return ActivityProgress(
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
      draft: json['draft'] as String? ?? '',
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
        id: json['id'] as String? ?? '',
        prompt: json['prompt'] as String? ?? '',
        correctAnswer: json['correctAnswer'] as String? ?? '',
        givenAnswer: json['givenAnswer'] as String? ?? '',
        source: json['source'] as String? ?? 'vocabulary',
        level: json['level'] as String? ?? 'A1',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}
