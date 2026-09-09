/// Honest, deterministic offline feedback for German writing practice tasks.
///
/// Replaces naive length/keyword rubrics with comprehensive linguistic checks:
/// - Exact and stem-aware target vocabulary verification via [GermanStem].
/// - German noun capitalization detection (words following articles/possessives
///   as well as common German core nouns).
/// - Sentence-initial capitalization and sentence termination punctuation.
/// - Connective language and cohesion appropriate to CEFR levels.
/// - Lexical diversity and repetition protection against trivial spam.
/// - Transparent diagnostic scoring and actionable coaching tips.
library;

import 'dart:math';

import 'conversation_engine.dart';
import 'models.dart';

class WritingAttemptEvaluation {
  const WritingAttemptEvaluation({
    required this.score,
    required this.wordCount,
    required this.targetWords,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.sentenceCount,
    required this.connectorsUsed,
    required this.capitalizationErrors,
    required this.sentenceCapitalizationErrors,
    required this.taskScore,
    required this.vocabScore,
    required this.cohesionScore,
    required this.mechanicsScore,
    required this.tips,
  });

  /// Overall composite score (0-100).
  final int score;

  /// Whether the attempt passes the threshold (>= 70).
  bool get passed => score >= 70;

  final int wordCount;
  final int targetWords;
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final int sentenceCount;
  final List<String> connectorsUsed;

  /// Specific words flagged as uncapitalized German nouns.
  final List<String> capitalizationErrors;

  /// Number of sentences failing to start with a capital letter.
  final int sentenceCapitalizationErrors;

  /// Dimension sub-scores (0-100).
  final int taskScore;
  final int vocabScore;
  final int cohesionScore;
  final int mechanicsScore;

  /// Actionable coaching recommendations.
  final List<String> tips;
}

class WritingEvaluator {
  const WritingEvaluator._();

  /// Determinative markers that require the following noun/nominal to be capitalized.
  static const Set<String> _articlesAndDeterminers = <String>{
    // Definite articles
    'der', 'die', 'das', 'den', 'dem', 'des',
    // Indefinite articles
    'ein', 'eine', 'einen', 'einem', 'einer', 'eines',
    // Negative articles
    'kein', 'keine', 'keinen', 'keinem', 'keiner', 'keines',
    // Possessive determiners
    'mein', 'meine', 'meinen', 'meinem', 'meiner', 'meines',
    'dein', 'deine', 'deinen', 'deinem', 'deiner', 'deines',
    'sein', 'seine', 'seinen', 'seinem', 'seiner', 'seines',
    'ihr', 'ihre', 'ihren', 'ihrem', 'ihrer', 'ihres',
    'unser', 'unsere', 'unserem', 'unseren', 'unserer', 'unseres',
    'euer', 'eure', 'eurem', 'euren', 'eurer', 'eures',
    // Preposition + article contractions
    'im', 'am', 'zum', 'zur', 'vom', 'beim', 'ins', 'ans', 'aufs', 'fürs',
    'durchs', 'übers', 'unters', 'hinters',
    // Demonstratives
    'dieser', 'diese', 'dieses', 'diesen', 'diesem', 'jener', 'jene', 'jenes',
  };

  /// Unambiguous German nouns frequently used by learners across A1 to C2.
  /// Words that share spelling with common lowercase verbs/adverbs (e.g. essen, morgen, bitte)
  /// are omitted here; they are caught safely by [_articlesAndDeterminers] when used as nouns.
  static const Set<String> _commonGermanNounsLower = <String>{
    'abend', 'abende', 'arzt', 'ärztin', 'ärzte',
    'aufgabe', 'aufgaben', 'ausflug', 'ausflüge', 'auto', 'autos',
    'bahnhof', 'bahnhöfe', 'bahn', 'bahnen', 'beispiel', 'beispiele',
    'beruf', 'berufe', 'besuch', 'besuche', 'besprechung', 'besprechungen',
    'bett', 'betten', 'bild', 'bilder', 'brief', 'briefe',
    'brot', 'brote', 'buch', 'bücher', 'bus', 'busse', 'büro', 'büros',
    'chef', 'chefin', 'computer', 'deutschland', 'eltern', 'entscheidung',
    'entscheidungen', 'erfahrung', 'erfahrungen', 'fahrkarte',
    'fahrkarten', 'fahrrad', 'fahrräder', 'familie', 'familien', 'fehler',
    'fernsehen', 'frage', 'fragen', 'frau', 'frauen', 'freizeit', 'freund',
    'freunde', 'freundin', 'freundinnen', 'frühstück', 'garten', 'gärten',
    'geburtstag', 'geld', 'geschäft', 'geschäfte', 'geschichte', 'geschichten',
    'geschenk', 'geschenke', 'gesundheit', 'glück', 'grund', 'gründe',
    'handy', 'handys', 'haus', 'häuser', 'heimat', 'hilfe', 'hobby', 'hobbys',
    'hotel', 'hotels', 'hund', 'hunde', 'idee', 'ideen', 'information',
    'informationen', 'jahr', 'jahre', 'kaffee', 'katze', 'katzen', 'kind',
    'kinder', 'kino', 'kinos', 'klasse', 'klassen', 'kleidung', 'kollege',
    'kollegen', 'kollegin', 'kolleginnen', 'kontakt', 'kontakte', 'küche',
    'küchen', 'kurs', 'kurse', 'land', 'länder', 'lehrer', 'lehrerin',
    'leute', 'lust', 'mann', 'männer', 'markt', 'märkte', 'meinung',
    'meinungen', 'mensch', 'menschen', 'minute', 'minuten', 'mittag', 'monat',
    'monate', 'musik', 'nachmittag', 'nachricht', 'nachrichten',
    'name', 'namen', 'natur', 'organisation', 'ort', 'orte', 'pause',
    'pausen', 'person', 'personen', 'platz', 'plätze', 'preis', 'preise',
    'problem', 'probleme', 'prüfung', 'prüfungen', 'reise', 'reisen',
    'reparatur', 'restaurant', 'restaurants', 'schule', 'schulen', 'schwester',
    'schwestern', 'sommer', 'sonne', 'spaß', 'sprache', 'sprachen', 'stadt',
    'städte', 'stelle', 'stellen', 'straße', 'straßen', 'student', 'studenten',
    'studentin', 'studentinnen', 'studium', 'stunde', 'stunden', 'tag', 'tage',
    'tee', 'telefon', 'termin', 'termine', 'thema', 'themen', 'tisch', 'tische',
    'uhr', 'uhren', 'universität', 'universitäten', 'unterricht', 'urlaub',
    'urlaube', 'vater', 'väter', 'verbindung', 'verbindungen', 'verkehr',
    'vorschlag', 'vorschläge', 'vorteil', 'vorteile', 'nachteil', 'nachteile',
    'wasser', 'weg', 'wege', 'wetter', 'woche', 'wochen', 'wochenende',
    'wochenenden', 'wohnung', 'wohnungen', 'wort', 'wörter', 'worte', 'zeit',
    'zeiten', 'zimmer', 'zug', 'züge', 'zukunft', 'zusammenhang',
  };

  /// Conjunctions and discourse markers by CEFR level.
  static const Map<CefrLevel, List<String>> _levelConnectors = <CefrLevel, List<String>>{
    CefrLevel.a1: <String>['und', 'aber', 'oder', 'denn', 'dann'],
    CefrLevel.a2: <String>[
      'weil', 'dass', 'wenn', 'deshalb', 'sondern', 'danach', 'zuerst',
      'später', 'leider', 'also', 'daher',
    ],
    CefrLevel.b1: <String>[
      'obwohl', 'trotzdem', 'während', 'da', 'damit', 'nachdem', 'bevor',
      'jedoch', 'entweder', 'schließlich', 'außerdem', 'besonders', 'zwar',
      'nämlich', 'darum',
    ],
    CefrLevel.b2: <String>[
      'einerseits', 'andererseits', 'zudem', 'dennoch', 'folglich',
      'infolgedessen', 'sodass', 'weder', 'vorausgesetzt', 'meines erachtens',
      'demgegenüber', 'hingegen', 'allerdings',
    ],
    CefrLevel.c1: <String>[
      'nichtsdestotrotz', 'demnach', 'insofern', 'darüber hinaus',
      'unter der bedingung', 'ungeachtet', 'hinsichtlich', 'maßgeblich',
      'gleichwohl', 'zugleich', 'vielmehr',
    ],
    CefrLevel.c2: <String>[
      'geschweige denn', 'alldieweil', 'indes', 'gewissermaßen',
      'zugegebenermaßen', 'resümierend', 'stattdessen',
    ],
  };

  static List<String> _extractWords(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .map((String w) => w.replaceAll(RegExp(r'^[^\wäöüÄÖÜß]+|[^\wäöüÄÖÜß]+$'), ''))
        .where((String w) => w.isNotEmpty)
        .toList(growable: false);
  }

  static List<String> _extractSentences(String text) {
    return text
        .split(RegExp(r'[.!?]+(?:\s+|$)'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
  }

  static bool _keywordMatches(String lowerText, String foldedText, Set<String> stemmedTokens, String keyword) {
    final String kwLower = keyword.trim().toLowerCase();
    if (GermanStem.present(stemmedTokens, keyword) || lowerText.contains(kwLower)) {
      return true;
    }
    // Root tolerance for longer German words (e.g. Transparenz vs transparent, Prüfung vs Prüfungen)
    if (kwLower.length >= 6) {
      final int rootLen = max(5, (kwLower.length * 0.72).round());
      final String root = GermanStem.fold(kwLower.substring(0, rootLen));
      if (foldedText.contains(root)) return true;
    }
    return false;
  }

  static WritingAttemptEvaluation evaluate(WritingLesson lesson, String text) {
    final String trimmed = text.trim();
    final List<String> rawWords = _extractWords(trimmed);
    final int wordCount = rawWords.length;
    final int targetWords = lesson.minWords;

    if (wordCount == 0) {
      return WritingAttemptEvaluation(
        score: 0,
        wordCount: 0,
        targetWords: targetWords,
        matchedKeywords: const <String>[],
        missingKeywords: List<String>.from(lesson.keywords),
        sentenceCount: 0,
        connectorsUsed: const <String>[],
        capitalizationErrors: const <String>[],
        sentenceCapitalizationErrors: 0,
        taskScore: 0,
        vocabScore: 0,
        cohesionScore: 0,
        mechanicsScore: 0,
        tips: <String>[
          'Draft your response in German adhering to the guidance and target of at least $targetWords words.',
        ],
      );
    }

    // 1. Vocabulary & Target Structures (using GermanStem and root matching)
    final Set<String> stemmedTokens = GermanStem.tokens(trimmed);
    final String lowerText = trimmed.toLowerCase();
    final String foldedText = GermanStem.fold(trimmed);
    final List<String> matchedKeywords = <String>[];
    final List<String> missingKeywords = <String>[];

    for (final String keyword in lesson.keywords) {
      if (_keywordMatches(lowerText, foldedText, stemmedTokens, keyword)) {
        matchedKeywords.add(keyword);
      } else {
        missingKeywords.add(keyword);
      }
    }


    final double keywordRatio = lesson.keywords.isEmpty
        ? 1.0
        : (matchedKeywords.length / lesson.keywords.length).clamp(0.0, 1.0);
    final int vocabScore = (keywordRatio * 100).round();

    // 2. Task Completion & Length
    // Linear length progress with baseline credit for complete substantive sentences
    final double lengthRatio = (wordCount / targetWords).clamp(0.0, 1.0);
    final bool hasParagraphBreak = trimmed.contains('\n');
    final double paragraphBonus = (wordCount < 80 || hasParagraphBreak || targetWords <= 80) ? 1.0 : 0.88;
    // Substantive text base credit: a coherent German response with 25+ words gets proportional base
    final double baseCredit = wordCount >= 25 ? 0.25 : (wordCount / 100.0);
    final double adjustedLength = (lengthRatio * 0.75 + baseCredit) * paragraphBonus;
    final int taskScore = (adjustedLength * 100).round().clamp(0, 100);

    // 3. Sentence Structure & Cohesion
    final List<String> sentences = _extractSentences(trimmed);
    final int sentenceCount = sentences.length;
    final int expectedSentences = max(3, lesson.level.order + 3);
    final double sentenceRatio = (sentenceCount / expectedSentences).clamp(0.0, 1.0);

    // Check connectors from learner's level and all lower levels
    final List<String> poolOfConnectors = <String>[
      for (final CefrLevel lvl in CefrLevel.values)
        if (lvl.order <= lesson.level.order + 1)
          ...?_levelConnectors[lvl],
    ];

    final Set<String> foundConnectors = <String>{};
    for (final String conn in poolOfConnectors) {
      if (GermanStem.present(stemmedTokens, conn) ||
          lowerText.contains(' $conn ') ||
          lowerText.startsWith('$conn ') ||
          lowerText.contains(', $conn ')) {
        foundConnectors.add(conn);
      }
    }
    final List<String> connectorsUsed = foundConnectors.toList()..sort();

    final int targetConnectorCount = max(1, min(3, lesson.level.order + 1));
    final double connectorRatio = (connectorsUsed.length / targetConnectorCount).clamp(0.0, 1.0);
    final int cohesionScore = ((sentenceRatio * 0.50 + connectorRatio * 0.50) * 100)
        .round()
        .clamp(0, 100);

    // 4. German Mechanics & Orthography
    // A. Sentence-initial capitalization
    int sentenceCapErrors = 0;
    for (final String s in sentences) {
      if (s.isEmpty) continue;
      final String firstChar = s[0];
      if (RegExp(r'[a-zäöü]').hasMatch(firstChar)) {
        sentenceCapErrors++;
      }
    }

    // B. German Noun Capitalization
    final List<String> capitalizationErrors = <String>[];
    for (int i = 0; i < rawWords.length; i++) {
      final String word = rawWords[i];
      final String wLower = word.toLowerCase();

      // Rule 1: word immediately preceded by an article/determiner that is lowercase
      if (i > 0) {
        final String prev = rawWords[i - 1].toLowerCase();
        if (_articlesAndDeterminers.contains(prev)) {
          if (RegExp(r'^[a-zäöü]').hasMatch(word)) {
            // If the next word exists and is capitalized, this word might be an adjective
            final bool nextIsCapitalizedNoun = (i + 1 < rawWords.length) &&
                RegExp(r'^[A-ZÄÖÜ]').hasMatch(rawWords[i + 1]);
            if (!nextIsCapitalizedNoun) {
              if (!capitalizationErrors.contains(wLower)) {
                capitalizationErrors.add(wLower);
              }
            }
          }
        }
      }

      // Rule 2: unambiguous common German noun written in lowercase
      if (_commonGermanNounsLower.contains(wLower) && RegExp(r'^[a-zäöü]').hasMatch(word)) {
        if (!capitalizationErrors.contains(wLower)) {
          capitalizationErrors.add(wLower);
        }
      }
    }

    // C. Lexical diversity (protection against spamming repeated words)
    final Set<String> uniqueWords = rawWords.map((String w) => w.toLowerCase()).toSet();
    final double diversityRatio = wordCount >= 10
        ? (uniqueWords.length / wordCount).clamp(0.0, 1.0)
        : 1.0;
    final double spamPenalty = (diversityRatio < 0.35) ? 0.25 : (diversityRatio < 0.50 ? 0.65 : 1.0);

    // Compute mechanics score
    double mechanicsBase = 100.0;
    mechanicsBase -= min(35.0, capitalizationErrors.length * 7.0);
    mechanicsBase -= min(25.0, sentenceCapErrors * 8.0);
    if (!trimmed.endsWith('.') && !trimmed.endsWith('!') && !trimmed.endsWith('?')) {
      mechanicsBase -= 5.0;
    }
    mechanicsBase *= spamPenalty;
    final int mechanicsScore = mechanicsBase.round().clamp(0, 100);

    // 5. Composite Score Calculation
    // Balanced weighting across pedagogical pillars:
    // Task & Length: 25%
    // Target Vocabulary: 35%
    // Cohesion & Connectors: 15%
    // German Mechanics: 25%
    final double weighted = (taskScore * 0.25) +
        (vocabScore * 0.35) +
        (cohesionScore * 0.15) +
        (mechanicsScore * 0.25);
    final int score = weighted.round().clamp(0, 100);

    // 6. Pedagogical Feedback & Tips
    final List<String> tips = <String>[];

    if (wordCount < targetWords) {
      final int diff = targetWords - wordCount;
      tips.add(
        'Expand your response: you wrote $wordCount words (target: $targetWords, need $diff more). Elaborate with an additional sentence, detail or reason.',
      );
    }

    if (missingKeywords.isNotEmpty) {
      final String missingList = missingKeywords.take(3).map((String k) => '„$k“').join(', ');
      tips.add('Integrate key target structures: incorporate $missingList.');
    }

    if (capitalizationErrors.isNotEmpty) {
      final String sample = capitalizationErrors
          .take(3)
          .map((String w) => '„$w“ → „${w[0].toUpperCase()}${w.substring(1)}“')
          .join(', ');
      tips.add(
        'Capitalize German nouns: in German, all nouns must be capitalized (e.g. $sample).',
      );
    }

    if (sentenceCapErrors > 0) {
      tips.add('Ensure every German sentence begins with a capital letter.');
    }

    if (connectorsUsed.isEmpty && wordCount >= 15) {
      final String suggested = (_levelConnectors[lesson.level] ?? <String>['weil', 'denn', 'aber'])
          .take(3)
          .join(', ');
      tips.add(
        'Improve flow with connective words: link your thoughts using connectors like $suggested.',
      );
    }

    if (targetWords >= 100 && !hasParagraphBreak && wordCount >= 70) {
      tips.add('Format with paragraphs: use a blank line between your introduction, main points and conclusion.');
    }

    if (spamPenalty < 0.8) {
      tips.add('Avoid repeating the same words; vary your vocabulary and phrasing.');
    }

    if (tips.isEmpty) {
      tips.add(
        'Excellent work! Your text meets the word count, incorporates the target structures, and shows solid German mechanics.',
      );
    }

    return WritingAttemptEvaluation(
      score: score,
      wordCount: wordCount,
      targetWords: targetWords,
      matchedKeywords: matchedKeywords,
      missingKeywords: missingKeywords,
      sentenceCount: sentenceCount,
      connectorsUsed: connectorsUsed,
      capitalizationErrors: capitalizationErrors,
      sentenceCapitalizationErrors: sentenceCapErrors,
      taskScore: taskScore,
      vocabScore: vocabScore,
      cohesionScore: cohesionScore,
      mechanicsScore: mechanicsScore,
      tips: tips,
    );
  }
}
