import 'cloze_bank.dart' show clozeGap;
import 'models.dart';
import 'vocabulary.dart';

/// The twelve structures `docs/UPGRADE_PLAN.md` Phase 0 item 4 asks for, each
/// its own collection so a learner drills one confusion at a time instead of
/// a shuffled grab-bag of every rule at once.
enum GrammarFeature {
  nominativeArticles,
  accusativeAfterPrepositions,
  dativeAfterPrepositions,
  twoWayPrepositions,
  adjectiveEndings,
  perfektAuxiliary,
  separableVerbs,
  reflexives,
  konjunktivII,
  passive,
  relativePronouns,
  genitiv,
}

extension GrammarFeatureX on GrammarFeature {
  String get label {
    switch (this) {
      case GrammarFeature.nominativeArticles:
        return 'Nominative articles';
      case GrammarFeature.accusativeAfterPrepositions:
        return 'Accusative after prepositions';
      case GrammarFeature.dativeAfterPrepositions:
        return 'Dative after prepositions';
      case GrammarFeature.twoWayPrepositions:
        return 'Two-way prepositions';
      case GrammarFeature.adjectiveEndings:
        return 'Adjective endings';
      case GrammarFeature.perfektAuxiliary:
        return 'Perfekt: haben vs. sein';
      case GrammarFeature.separableVerbs:
        return 'Separable verbs';
      case GrammarFeature.reflexives:
        return 'Reflexive pronouns';
      case GrammarFeature.konjunktivII:
        return 'Konjunktiv II';
      case GrammarFeature.passive:
        return 'Passive voice';
      case GrammarFeature.relativePronouns:
        return 'Relative pronouns';
      case GrammarFeature.genitiv:
        return 'Genitiv';
    }
  }

  String get description {
    switch (this) {
      case GrammarFeature.nominativeArticles:
        return 'der, die or das for the sentence subject';
      case GrammarFeature.accusativeAfterPrepositions:
        return 'für, durch, ohne, gegen, um and bis always take the accusative';
      case GrammarFeature.dativeAfterPrepositions:
        return 'mit, nach, bei, seit, von and aus always take the dative';
      case GrammarFeature.twoWayPrepositions:
        return 'im/am for location, ins/ans for movement';
      case GrammarFeature.adjectiveEndings:
        return 'the ending an attributive adjective takes before its noun';
      case GrammarFeature.perfektAuxiliary:
        return 'haben or sein to build the Perfekt';
      case GrammarFeature.separableVerbs:
        return 'the prefix that splits off to the end of the clause';
      case GrammarFeature.reflexives:
        return 'mich, dich, sich, uns or euch with a reflexive verb';
      case GrammarFeature.konjunktivII:
        return 'würde-, hätte- and wäre-forms for the hypothetical';
      case GrammarFeature.passive:
        return 'wird, wurde, werden or wurden with a participle';
      case GrammarFeature.relativePronouns:
        return 'der, die, das and their case forms introducing a relative clause';
      case GrammarFeature.genitiv:
        return 'des, der, eines or einer after a genitive preposition';
    }
  }
}

/// One grammar-focused gap-fill item: a real corpus sentence with the marker
/// for one grammatical feature removed, rather than the vocabulary headword
/// [ClozeItem] in `cloze_bank.dart` blanks. Same shape, same deterministic
/// shuffle, same gap marker -- the blank is a case ending, an auxiliary, a
/// preposition-triggered article or a reflexive pronoun instead of the word a
/// card teaches.
class GrammarChallengeItem {
  const GrammarChallengeItem({
    required this.id,
    required this.feature,
    required this.level,
    required this.gapped,
    required this.answer,
    required this.full,
    required this.english,
    required this.distractors,
  });

  final String id;
  final GrammarFeature feature;
  final CefrLevel level;
  final String gapped;
  final String answer;
  final String full;
  final String english;

  /// Wrong answers from the same paradigm as [answer] -- other case forms of
  /// the same determiner family, the sibling Perfekt auxiliary, the other
  /// grammatical genders. Nominative articles only ever has two, because
  /// German has exactly three genders and the correct one is never offered
  /// twice; every other feature carries three.
  final List<String> distractors;

  List<String> optionsFor(int seed) {
    final List<String> options = <String>[answer, ...distractors];
    // Deterministic shuffle: the same item always presents its options in the
    // same order, so a learner who meets it twice is not re-reading a new
    // layout, and a test can assert against it. Mirrors ClozeItem.optionsFor.
    for (int i = options.length - 1; i > 0; i--) {
      final int j = (seed * 31 + i * 17) % (i + 1);
      final String tmp = options[i];
      options[i] = options[j];
      options[j] = tmp;
    }
    return options;
  }
}

// ---------------------------------------------------------------------------
// Determiner paradigms, shared by every feature that gaps an article.
// ---------------------------------------------------------------------------

/// Every determiner family used as an answer anywhere below, mapped to its
/// full case paradigm so a wrong answer is always "the same determiner, the
/// wrong case" rather than an unrelated token.
final Map<String, List<String>> _articleParadigms = _buildArticleParadigms();

Map<String, List<String>> _buildArticleParadigms() {
  final Map<String, List<String>> map = <String, List<String>>{};
  void add(List<String> forms) {
    for (final String form in forms) {
      map[form] = forms;
    }
  }

  add(const <String>['der', 'den', 'dem', 'des']);
  add(const <String>['ein', 'einen', 'einem', 'eines', 'einer']);
  add(const <String>['kein', 'keinen', 'keinem', 'keines']);
  add(const <String>['jeder', 'jeden', 'jedem', 'jedes']);
  add(const <String>['dieser', 'diesen', 'diesem', 'dieses']);
  add(const <String>['sein', 'seinen', 'seinem', 'seines', 'seiner']);
  add(const <String>['ihr', 'ihren', 'ihrem', 'ihres', 'ihrer']);
  return map;
}

List<String> _articleDistractors(String answer) {
  final List<String> forms = _articleParadigms[answer.toLowerCase()] ?? const <String>[];
  return forms.where((form) => form != answer.toLowerCase()).take(3).toList();
}

List<String> _without(List<String> pool, String answer) =>
    pool.where((candidate) => candidate.toLowerCase() != answer.toLowerCase()).toList();

/// Dart's [Match] exposes only the position of the whole match, not of any
/// individual capture group. Every group located this way is a short,
/// distinctive function word searched for from the match's own start, which
/// is unambiguous in practice.
int _groupStart(String s, RegExpMatch m, String group) => s.indexOf(group, m.start);

/// The result of one feature matcher: where to gap the sentence and what the
/// right and wrong answers are.
class _Match {
  const _Match(this.gapped, this.answer, this.distractors);
  final String gapped;
  final String answer;
  final List<String> distractors;
}

// ---------------------------------------------------------------------------
// 1. Nominative articles
// ---------------------------------------------------------------------------

final RegExp _reNominative = RegExp(r'^(Der|Die|Das)\s');

_Match? _matchNominativeArticles(String s) {
  final RegExpMatch? m = _reNominative.firstMatch(s);
  if (m == null) return null;
  final String answer = m.group(1)!;
  final List<String> distractors = <String>['Der', 'Die', 'Das']..remove(answer);
  return _Match(clozeGap + s.substring(answer.length), answer, distractors);
}

// ---------------------------------------------------------------------------
// 2. Accusative after prepositions (für, durch, ohne, gegen, um, bis)
// ---------------------------------------------------------------------------

final RegExp _reAccusativePrep = RegExp(
  r'\b(?:für|durch|ohne|gegen|um|bis)\s+(den|einen|keinen|jeden|diesen|seinen|ihren)\b',
  caseSensitive: false,
);

_Match? _matchAccusativeAfterPrepositions(String s) {
  final RegExpMatch? m = _reAccusativePrep.firstMatch(s);
  if (m == null) return null;
  final String answer = m.group(1)!;
  final int start = _groupStart(s, m, answer);
  return _Match(
    s.substring(0, start) + clozeGap + s.substring(start + answer.length),
    answer,
    _articleDistractors(answer),
  );
}

// ---------------------------------------------------------------------------
// 3. Dative after prepositions (mit, nach, bei, seit, von, aus)
// ---------------------------------------------------------------------------

final RegExp _reDativePrep = RegExp(
  r'\b(?:mit|nach|bei|seit|von|aus)\s+(dem|einem|keinem|jedem|diesem|seinem|ihrem)\b',
  caseSensitive: false,
);

_Match? _matchDativeAfterPrepositions(String s) {
  final RegExpMatch? m = _reDativePrep.firstMatch(s);
  if (m == null) return null;
  final String answer = m.group(1)!;
  final int start = _groupStart(s, m, answer);
  return _Match(
    s.substring(0, start) + clozeGap + s.substring(start + answer.length),
    answer,
    _articleDistractors(answer),
  );
}

// ---------------------------------------------------------------------------
// 4. Two-way prepositions: im/am for location, ins/ans for movement
// ---------------------------------------------------------------------------

const List<String> _twoWayForms = <String>['im', 'am', 'ins', 'ans'];
final RegExp _reTwoWay = RegExp(r'\b(im|am|ins|ans)\b', caseSensitive: false);

_Match? _matchTwoWayPrepositions(String s) {
  final RegExpMatch? m = _reTwoWay.firstMatch(s);
  if (m == null) return null;
  final String answer = m.group(1)!;
  return _Match(
    s.substring(0, m.start) + clozeGap + s.substring(m.end),
    answer,
    _without(_twoWayForms, answer),
  );
}

// ---------------------------------------------------------------------------
// 5. Adjective endings
// ---------------------------------------------------------------------------

/// Common attributive adjectives with a fully regular ending -- no stem-vowel
/// elision (teuer -> teure, dunkel -> dunkle drop a stem "e" and are left out
/// on purpose) so blanking just the suffix and keeping the stem is safe.
const List<String> _regularAdjectives = <String>[
  'klein', 'groß', 'neu', 'alt', 'gut', 'jung', 'lang', 'kurz', 'schön',
  'billig', 'wichtig', 'einfach', 'schnell', 'langsam', 'laut', 'leise',
  'hell', 'breit', 'schmal', 'tief', 'warm', 'kalt', 'frisch', 'sauber',
  'gesund', 'müde', 'glücklich', 'traurig', 'interessant', 'langweilig',
  'bekannt', 'berühmt', 'modern', 'richtig', 'falsch', 'ruhig', 'freundlich',
  'hübsch', 'stark', 'schwach', 'reich', 'arm', 'voll', 'leer', 'günstig',
  'bequem', 'gemütlich',
];

final RegExp _reAdjectiveEnding = RegExp(
  r'\b(?:der|die|das|den|dem|des|ein|eine|einen|einem|einer|kein|keine|keinen|keinem|keiner)\s+'
  '(${_regularAdjectives.join('|')})'
  r'(e|en|er|es)\b',
);

_Match? _matchAdjectiveEndings(String s) {
  final RegExpMatch? m = _reAdjectiveEnding.firstMatch(s);
  if (m == null) return null;
  final String stem = m.group(1)!;
  final String ending = m.group(2)!;
  final int stemStart = _groupStart(s, m, stem);
  final int stemEnd = stemStart + stem.length;
  return _Match(
    s.substring(0, stemStart) + stem + clozeGap + s.substring(stemEnd + ending.length),
    ending,
    _without(const <String>['e', 'en', 'er', 'es'], ending),
  );
}

// ---------------------------------------------------------------------------
// 6. Perfekt auxiliary: haben vs. sein
// ---------------------------------------------------------------------------

const Map<String, String> _auxPair = <String, String>{
  'habe': 'bin', 'hast': 'bist', 'hat': 'ist', 'haben': 'sind', 'habt': 'seid',
  'bin': 'habe', 'bist': 'hast', 'ist': 'hat', 'sind': 'haben', 'seid': 'habt',
};
final RegExp _rePerfekt = RegExp(
  r'\b(habe|hast|hat|haben|habt|bin|bist|ist|sind|seid)\b.{0,40}?\bge[a-zA-Zäöüß]+(?:t|en)\b',
);

_Match? _matchPerfektAuxiliary(String s) {
  final RegExpMatch? m = _rePerfekt.firstMatch(s);
  if (m == null) return null;
  final String answer = m.group(1)!;
  final String pair = _auxPair[answer.toLowerCase()] ?? 'ist';
  final int start = _groupStart(s, m, answer);
  return _Match(
    s.substring(0, start) + clozeGap + s.substring(start + answer.length),
    answer,
    <String>[pair, 'war', 'hatte'],
  );
}

// ---------------------------------------------------------------------------
// 7. Separable verbs: the prefix stranded at the end of the clause
// ---------------------------------------------------------------------------

/// Subset of the separable-prefix list `tool/validate_content.py` already
/// uses for its example-sentence check. "über" is left out here on purpose:
/// it starts with an umlaut, and Dart's `\b` is ASCII-only, so a pattern
/// anchored on `\büber\b` never matches "über" at all.
const List<String> _separablePrefixes = <String>[
  'zusammen', 'zurück', 'vorbei', 'durch', 'nach', 'statt', 'fort', 'weg',
  'vor', 'auf', 'aus', 'ein', 'ab', 'an', 'bei', 'mit', 'los', 'her', 'hin',
  'um', 'zu', 'fest', 'frei', 'teil',
];
final RegExp _reSeparable = RegExp('\\b(${_separablePrefixes.join('|')})[.!?]?\$');

_Match? _matchSeparableVerbs(String s, int seedIndex) {
  final String trimmed = s.trimRight();
  final RegExpMatch? m = _reSeparable.firstMatch(trimmed);
  if (m == null) return null;
  // A one- or two-word fragment ending in a preposition is not a clause with
  // a genuinely separated verb; skip rather than guess.
  if (trimmed.split(RegExp(r'\s+')).length < 4) return null;

  final String answer = m.group(1)!;
  final List<String> pool = _separablePrefixes.where((p) => p != answer).toList();
  final List<String> distractors = <String>[];
  int step = (seedIndex * 7) % pool.length;
  while (distractors.length < 3) {
    final String candidate = pool[step % pool.length];
    if (!distractors.contains(candidate)) distractors.add(candidate);
    step += 1;
  }
  final int start = _groupStart(trimmed, m, answer);
  return _Match(
    trimmed.substring(0, start) + clozeGap + trimmed.substring(start + answer.length),
    answer,
    distractors,
  );
}

// ---------------------------------------------------------------------------
// 8. Reflexive pronouns
// ---------------------------------------------------------------------------

const List<String> _reflexivePronouns = <String>['mich', 'dich', 'sich', 'uns', 'euch'];
final RegExp _reReflexive = RegExp(r'\b(mich|dich|sich|uns|euch)\b');

_Match? _matchReflexives(String s) {
  final RegExpMatch? m = _reReflexive.firstMatch(s);
  if (m == null) return null;
  final String answer = m.group(1)!;
  return _Match(
    s.substring(0, m.start) + clozeGap + s.substring(m.end),
    answer,
    _reflexivePronouns.where((p) => p != answer).take(3).toList(),
  );
}

// ---------------------------------------------------------------------------
// 9. Konjunktiv II
// ---------------------------------------------------------------------------

final RegExp _reKonjII = RegExp(
  r'\b(würde|würdest|würden|würdet|hätte|hättest|hätten|hättet|wäre|wärst|wären|wärt|wäret)\b',
  caseSensitive: false,
);
const List<String> _konjReps = <String>['würde', 'hätte', 'wäre'];
const List<String> _konjAlts = <String>['würden', 'hätten', 'wären'];

_Match? _matchKonjunktivII(String s) {
  final RegExpMatch? m = _reKonjII.firstMatch(s);
  if (m == null) return null;
  final String answer = m.group(1)!;
  final List<String> distractors = <String>[
    for (int i = 0; i < _konjReps.length; i++)
      _konjReps[i].toLowerCase() == answer.toLowerCase() ? _konjAlts[i] : _konjReps[i],
  ];
  return _Match(
    s.substring(0, m.start) + clozeGap + s.substring(m.end),
    answer,
    distractors,
  );
}

// ---------------------------------------------------------------------------
// 10. Passive voice
// ---------------------------------------------------------------------------

const List<String> _passiveForms = <String>['wird', 'wurde', 'werden', 'wurden'];
final RegExp _rePassive = RegExp(
  r'\b(wird|wurde|werden|wurden)\b.{0,60}?\bge[a-zA-Zäöüß]+(?:t|en)\b',
  caseSensitive: false,
);

_Match? _matchPassive(String s) {
  final RegExpMatch? m = _rePassive.firstMatch(s);
  if (m == null) return null;
  final String answer = m.group(1)!;
  final int start = _groupStart(s, m, answer);
  return _Match(
    s.substring(0, start) + clozeGap + s.substring(start + answer.length),
    answer,
    _without(_passiveForms, answer),
  );
}

// ---------------------------------------------------------------------------
// 11. Relative pronouns
// ---------------------------------------------------------------------------

const List<String> _relativeForms = <String>[
  'der', 'die', 'das', 'dem', 'den', 'deren', 'dessen', 'denen',
];
final RegExp _reRelative = RegExp(r',\s*(der|die|das|dem|den|deren|dessen|denen)\b');

_Match? _matchRelativePronouns(String s) {
  final RegExpMatch? m = _reRelative.firstMatch(s);
  if (m == null) return null;
  final String answer = m.group(1)!;
  final int start = _groupStart(s, m, answer);
  return _Match(
    s.substring(0, start) + clozeGap + s.substring(start + answer.length),
    answer,
    _relativeForms.where((p) => p != answer).take(3).toList(),
  );
}

// ---------------------------------------------------------------------------
// 12. Genitiv
// ---------------------------------------------------------------------------

/// The rarest feature in the corpus by far -- genitive prepositions are a
/// formal-register construction and this is a general-purpose sentence bank,
/// not a legal-German one. This collection is real but small; see
/// `grammarChallengeItemCount` and the test file for the actual yield rather
/// than assuming it reaches 100 like the other eleven.
final RegExp _reGenitiv = RegExp(
  r'\b(?:wegen|trotz|während|statt|innerhalb|außerhalb|aufgrund|angesichts|anstelle)\s+'
  r'(des|der|eines|einer|dieses|dieser|seines|seiner|ihres|ihrer)\b',
  caseSensitive: false,
);

_Match? _matchGenitiv(String s) {
  final RegExpMatch? m = _reGenitiv.firstMatch(s);
  if (m == null) return null;
  final String answer = m.group(1)!;
  final int start = _groupStart(s, m, answer);
  return _Match(
    s.substring(0, start) + clozeGap + s.substring(start + answer.length),
    answer,
    _articleDistractors(answer),
  );
}

// ---------------------------------------------------------------------------
// The bank
// ---------------------------------------------------------------------------

/// One collection per [GrammarFeature], each capped at 100 items. A feature
/// whose trigger is genuinely rare in the corpus (see [GrammarFeature.genitiv])
/// is shipped smaller rather than padded to the cap with weaker matches.
const int _collectionCap = 100;

Map<GrammarFeature, List<GrammarChallengeItem>>? _cache;

Map<GrammarFeature, List<GrammarChallengeItem>> get _bank {
  final Map<GrammarFeature, List<GrammarChallengeItem>>? cached = _cache;
  if (cached != null) return cached;

  final Map<GrammarFeature, List<GrammarChallengeItem>> built = <GrammarFeature, List<GrammarChallengeItem>>{
    for (final GrammarFeature feature in GrammarFeature.values) feature: <GrammarChallengeItem>[],
  };
  final Map<GrammarFeature, Set<String>> seenSentences = <GrammarFeature, Set<String>>{
    for (final GrammarFeature feature in GrammarFeature.values) feature: <String>{},
  };

  void tryAdd(GrammarFeature feature, GermanWord word, String sentence, _Match? match) {
    if (match == null) return;
    final List<GrammarChallengeItem> list = built[feature]!;
    if (list.length >= _collectionCap) return;
    // Two different cards can share an example sentence; one item per
    // distinct sentence keeps a collection from repeating itself.
    if (!seenSentences[feature]!.add(sentence)) return;
    list.add(GrammarChallengeItem(
      id: 'gc-${feature.name}-${word.id}',
      feature: feature,
      level: word.cefr,
      gapped: match.gapped,
      answer: match.answer,
      full: sentence,
      english: word.exampleEnglish,
      distractors: match.distractors,
    ));
  }

  int serial = 0;
  for (final GermanWord word in vocabulary) {
    final String sentence = word.exampleGerman;
    if (sentence.isEmpty) continue;
    serial += 1;

    tryAdd(GrammarFeature.nominativeArticles, word, sentence, _matchNominativeArticles(sentence));
    tryAdd(GrammarFeature.accusativeAfterPrepositions, word, sentence, _matchAccusativeAfterPrepositions(sentence));
    tryAdd(GrammarFeature.dativeAfterPrepositions, word, sentence, _matchDativeAfterPrepositions(sentence));
    tryAdd(GrammarFeature.twoWayPrepositions, word, sentence, _matchTwoWayPrepositions(sentence));
    tryAdd(GrammarFeature.adjectiveEndings, word, sentence, _matchAdjectiveEndings(sentence));
    tryAdd(GrammarFeature.perfektAuxiliary, word, sentence, _matchPerfektAuxiliary(sentence));
    tryAdd(GrammarFeature.separableVerbs, word, sentence, _matchSeparableVerbs(sentence, serial));
    tryAdd(GrammarFeature.reflexives, word, sentence, _matchReflexives(sentence));
    tryAdd(GrammarFeature.konjunktivII, word, sentence, _matchKonjunktivII(sentence));
    tryAdd(GrammarFeature.passive, word, sentence, _matchPassive(sentence));
    tryAdd(GrammarFeature.relativePronouns, word, sentence, _matchRelativePronouns(sentence));
    tryAdd(GrammarFeature.genitiv, word, sentence, _matchGenitiv(sentence));
  }

  _cache = built;
  return built;
}

/// Every item in one feature's collection.
List<GrammarChallengeItem> challengesFor(GrammarFeature feature) =>
    List<GrammarChallengeItem>.unmodifiable(_bank[feature] ?? const <GrammarChallengeItem>[]);

/// Total across every feature, for the content report.
int get grammarChallengeItemCount =>
    _bank.values.fold<int>(0, (int total, List<GrammarChallengeItem> l) => total + l.length);
