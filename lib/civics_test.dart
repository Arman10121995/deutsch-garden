import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

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
  }) : _byId = <String, CivicsQuestion>{
         for (final CivicsQuestion question in questions) question.id: question,
       };

  final CivicsCatalogMetadata metadata;
  final List<GermanState> states;
  final List<CivicsQuestion> questions;
  final Map<String, CivicsQuestion> _byId;

  static CivicsCatalog? _cache;

  static Future<CivicsCatalog> load() async {
    final CivicsCatalog? cached = _cache;
    if (cached != null) return cached;
    final String source = await rootBundle.loadString(
      'assets/civics/questions.json',
    );
    return _cache ??= CivicsCatalog.fromJsonString(source);
  }

  static CivicsCatalog fromJsonString(String source) {
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
    );
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
    final List<CivicsQuestion> selected = <CivicsQuestion>[
      ...general.take(30),
      ...state.take(3),
    ]..shuffle(random);
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
