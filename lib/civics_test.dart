import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'answer_shuffle.dart';

/// The two official outcomes that use the same 33-question test format.
enum CivicsTestKind { lebenInDeutschland, citizenship }

extension CivicsTestKindX on CivicsTestKind {
  String get label => switch (this) {
    CivicsTestKind.lebenInDeutschland => 'Leben in Deutschland',
    CivicsTestKind.citizenship => 'Einbürgerungstest',
  };

  String get shortLabel => switch (this) {
    CivicsTestKind.lebenInDeutschland => 'LiD',
    CivicsTestKind.citizenship => 'Einbürgerung',
  };

  int get passMark => switch (this) {
    CivicsTestKind.lebenInDeutschland => 15,
    CivicsTestKind.citizenship => 17,
  };
}

enum CivicsQuestionScope { general, state }

class GermanState {
  const GermanState({required this.code, required this.name});

  final String code;
  final String name;

  factory GermanState.fromJson(Map<String, dynamic> json) => GermanState(
    code: json['code']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
  );
}

class CivicsImage {
  const CivicsImage({required this.asset, required this.sha256});

  final String asset;
  final String sha256;

  factory CivicsImage.fromJson(Map<String, dynamic> json) => CivicsImage(
    asset: json['asset']?.toString() ?? '',
    sha256: json['sha256']?.toString() ?? '',
  );
}

/// A bundled English helper for a German civics question.
///
/// The German catalogue remains the authoritative text. These strings are a
/// learner-facing aid generated at authoring time and are deliberately kept
/// separate from the official question data so that a missing translation can
/// never make the catalogue unloadable.
class CivicsTranslation {
  const CivicsTranslation({required this.question, required this.options});

  final String question;
  final List<String> options;

  bool get isUsable =>
      question.trim().isNotEmpty &&
      options.length == 4 &&
      options.every((String option) => option.trim().isNotEmpty);

  factory CivicsTranslation.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawOptions =
        json['options'] as List<dynamic>? ?? const <dynamic>[];
    return CivicsTranslation(
      question: json['question']?.toString() ?? '',
      options: List<String>.unmodifiable(
        rawOptions.map((Object? value) => value?.toString() ?? ''),
      ),
    );
  }
}

class CivicsQuestion {
  const CivicsQuestion({
    required this.id,
    required this.officialNumber,
    required this.scope,
    required this.stateCode,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.images,
  });

  final String id;
  final int officialNumber;
  final CivicsQuestionScope scope;
  final String? stateCode;
  final String question;
  final List<String> options;
  final int correctIndex;
  final List<CivicsImage> images;

  String get correctAnswer => options[correctIndex];

  /// The same question with its options permuted. See
  /// `lib/answer_shuffle.dart`.
  ///
  /// The official Leben in Deutschland catalogue publishes its answer first,
  /// so importing it faithfully imported the bias too. Sitting the real test
  /// means reading the options, and practising against a fixed position
  /// rehearses the wrong skill.
  CivicsQuestion shuffled(Random random) {
    final ShuffledChoices s = shuffleChoices(options, correctIndex, random);
    return CivicsQuestion(
      id: id,
      officialNumber: officialNumber,
      scope: scope,
      stateCode: stateCode,
      question: question,
      options: s.options,
      correctIndex: s.correctIndex,
      images: images,
    );
  }

  factory CivicsQuestion.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawOptions =
        json['options'] as List<dynamic>? ?? const [];
    final List<dynamic> rawImages =
        json['images'] as List<dynamic>? ?? const [];
    return CivicsQuestion(
      id: json['id']?.toString() ?? '',
      officialNumber: (json['officialNumber'] as num?)?.toInt() ?? 0,
      scope: json['scope'] == 'state'
          ? CivicsQuestionScope.state
          : CivicsQuestionScope.general,
      stateCode: json['stateCode']?.toString(),
      question: json['question']?.toString() ?? '',
      options: List<String>.unmodifiable(
        rawOptions.map((Object? value) => value.toString()),
      ),
      correctIndex: (json['correctIndex'] as num?)?.toInt() ?? -1,
      images: List<CivicsImage>.unmodifiable(
        rawImages.map(
          (Object? value) => CivicsImage.fromJson(
            (value as Map).map(
              (Object? key, Object? item) => MapEntry(key.toString(), item),
            ),
          ),
        ),
      ),
    );
  }
}

class CivicsCatalogMetadata {
  const CivicsCatalogMetadata({
    required this.catalogStand,
    required this.officialCatalogUrl,
    required this.officialPdfUrl,
  });

  final String catalogStand;
  final String officialCatalogUrl;
  final String officialPdfUrl;

  factory CivicsCatalogMetadata.fromJson(Map<String, dynamic> json) =>
      CivicsCatalogMetadata(
        catalogStand: json['catalogStand']?.toString() ?? '',
        officialCatalogUrl: json['officialCatalogUrl']?.toString() ?? '',
        officialPdfUrl: json['officialPdfUrl']?.toString() ?? '',
      );
}

class CivicsCatalog {
  CivicsCatalog._({
    required this.metadata,
    required this.states,
    required this.questions,
    required Map<String, CivicsTranslation> translations,
  }) : _byId = <String, CivicsQuestion>{
         for (final CivicsQuestion question in questions) question.id: question,
       },
       translations = Map<String, CivicsTranslation>.unmodifiable(translations);

  final CivicsCatalogMetadata metadata;
  final List<GermanState> states;
  final List<CivicsQuestion> questions;
  final Map<String, CivicsTranslation> translations;
  final Map<String, CivicsQuestion> _byId;

  static CivicsCatalog? _cache;

  static Future<CivicsCatalog> load() async {
    final CivicsCatalog? cached = _cache;
    if (cached != null) return cached;
    final String source = await rootBundle.loadString(
      'assets/civics/questions.json',
    );
    String? translationSource;
    try {
      translationSource = await rootBundle.loadString(
        'assets/civics/translations.json',
      );
    } catch (_) {
      // Older or deliberately slim builds may omit the optional helper. The
      // German catalogue must still work in that case.
    }
    return _cache ??= CivicsCatalog.fromJsonSources(source, translationSource);
  }

  static CivicsCatalog fromJsonString(String source) =>
      fromJsonSources(source, null);

  static CivicsCatalog fromJsonSources(
    String source,
    String? translationSource,
  ) {
    final Object? decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException(
        'The civics catalogue root must be an object.',
      );
    }
    final Map<String, dynamic> json = decoded.map(
      (Object? key, Object? value) => MapEntry(key.toString(), value),
    );
    final Map<String, dynamic> metadataJson = (json['metadata'] as Map).map(
      (Object? key, Object? value) => MapEntry(key.toString(), value),
    );
    final List<dynamic> rawStates =
        json['states'] as List<dynamic>? ?? const [];
    final List<dynamic> rawQuestions =
        json['questions'] as List<dynamic>? ?? const [];
    final Map<String, CivicsTranslation> translations = _parseTranslations(
      translationSource,
    );
    return CivicsCatalog._(
      metadata: CivicsCatalogMetadata.fromJson(metadataJson),
      states: List<GermanState>.unmodifiable(
        rawStates.map(
          (Object? value) => GermanState.fromJson(
            (value as Map).map(
              (Object? key, Object? item) => MapEntry(key.toString(), item),
            ),
          ),
        ),
      ),
      questions: List<CivicsQuestion>.unmodifiable(
        rawQuestions.map(
          (Object? value) => CivicsQuestion.fromJson(
            (value as Map).map(
              (Object? key, Object? item) => MapEntry(key.toString(), item),
            ),
          ),
        ),
      ),
      translations: translations,
    );
  }

  static Map<String, CivicsTranslation> _parseTranslations(String? source) {
    if (source == null || source.trim().isEmpty) {
      return const <String, CivicsTranslation>{};
    }
    try {
      final Object? decoded = jsonDecode(source);
      if (decoded is! Map) return const <String, CivicsTranslation>{};
      final Object? raw = decoded['translations'];
      if (raw is! Map) return const <String, CivicsTranslation>{};
      final Map<String, CivicsTranslation> result =
          <String, CivicsTranslation>{};
      for (final MapEntry<Object?, Object?> entry in raw.entries) {
        if (entry.value is! Map) continue;
        final Map<String, dynamic> value = (entry.value as Map).map(
          (Object? key, Object? item) => MapEntry(key.toString(), item),
        );
        final CivicsTranslation translation = CivicsTranslation.fromJson(value);
        if (translation.isUsable) {
          result[entry.key.toString()] = translation;
        }
      }
      return result;
    } on FormatException {
      return const <String, CivicsTranslation>{};
    }
  }

  List<CivicsQuestion> get generalQuestions => questions
      .where(
        (CivicsQuestion question) =>
            question.scope == CivicsQuestionScope.general,
      )
      .toList(growable: false);

  List<CivicsQuestion> stateQuestions(String stateCode) => questions
      .where((CivicsQuestion question) => question.stateCode == stateCode)
      .toList(growable: false);

  List<CivicsQuestion> relevantQuestions(String stateCode) => <CivicsQuestion>[
    ...generalQuestions,
    ...stateQuestions(stateCode),
  ];

  CivicsQuestion? questionById(String id) => _byId[id];

  CivicsTranslation? translationFor(String id) => translations[id];

  GermanState? stateByCode(String code) {
    for (final GermanState state in states) {
      if (state.code == code) return state;
    }
    return null;
  }

  CivicsMock buildMock({required String stateCode, required int seed}) {
    if (stateByCode(stateCode) == null) {
      throw ArgumentError.value(stateCode, 'stateCode', 'Unknown Bundesland');
    }
    final Random random = Random(seed);
    final List<CivicsQuestion> general = List<CivicsQuestion>.of(
      generalQuestions,
    )..shuffle(random);
    final List<CivicsQuestion> state = List<CivicsQuestion>.of(
      stateQuestions(stateCode),
    )..shuffle(random);
    // The options are permuted here, not in the screen that shows them.
    //
    // A mock is displayed by one widget, graded by CivicsMock.score and read
    // back by the review list, all from this same list. Shuffling at display
    // time would leave the other two grading against the authored order and
    // mark right answers wrong. Doing it once at construction keeps the three
    // in agreement by making them look at the same thing.
    //
    // The official Leben in Deutschland catalogue publishes the answer first,
    // so importing it faithfully imported that bias too.
    final List<CivicsQuestion> selected = <CivicsQuestion>[
      ...general.take(30),
      ...state.take(3),
    ]..shuffle(random);
    for (int i = 0; i < selected.length; i++) {
      selected[i] = selected[i].shuffled(random);
    }
    return CivicsMock(
      stateCode: stateCode,
      seed: seed,
      questions: List<CivicsQuestion>.unmodifiable(selected),
    );
  }
}

class CivicsMock {
  const CivicsMock({
    required this.stateCode,
    required this.seed,
    required this.questions,
  });

  final String stateCode;
  final int seed;
  final List<CivicsQuestion> questions;

  CivicsTestResult score(Map<String, int> answers) {
    int correct = 0;
    for (final CivicsQuestion question in questions) {
      if (answers[question.id] == question.correctIndex) correct += 1;
    }
    return CivicsTestResult(correct: correct, total: questions.length);
  }
}

class CivicsTestResult {
  const CivicsTestResult({required this.correct, required this.total});

  final int correct;
  final int total;

  int get percent => total == 0 ? 0 : ((correct / total) * 100).round();
  bool get passedLebenInDeutschland => correct >= 15;
  bool get passedCitizenship => correct >= 17;

  bool passed(CivicsTestKind kind) => correct >= kind.passMark;
}
