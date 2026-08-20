/// German-aware comparison of what a learner typed against what was expected.
///
/// The app used to compare typed answers with `trim().toLowerCase()` and an
/// exact string equality. On a keyboard without umlauts — which is most
/// keyboards outside the German-speaking world — that marks `Madchen`,
/// `Strasse` and `uber` wrong even though the learner knew the word. Treating
/// that as a failure teaches nothing except that the app is unfair.
///
/// The convention this implements is the one German speakers already use when
/// they are stuck on an ASCII keyboard: ä→ae, ö→oe, ü→ue, ß→ss. An answer that
/// matches only after that folding is *accepted*, but reported as
/// [GermanMatch.umlautVariant] so the UI can still show the correct spelling.
/// The learner is credited and corrected at the same time.
library;

const Map<String, String> _umlautFolds = <String, String>{
  'ä': 'ae',
  'ö': 'oe',
  'ü': 'ue',
  'ß': 'ss',
};

/// How closely a typed answer matched.
enum GermanMatch {
  /// Character-for-character, ignoring case, surrounding space and final
  /// sentence punctuation.
  exact,

  /// Correct except that umlauts were typed in their ASCII form, or the
  /// learner wrote `ss` for `ß` (or the reverse).
  umlautVariant,

  /// Not the expected answer.
  wrong,
}

/// Lowercases, collapses runs of whitespace and drops trailing sentence
/// punctuation. Capitalisation of nouns matters in German, but not for judging
/// whether a learner recalled the word, and a stray full stop never should.
String normalizeGerman(String value) {
  final String collapsed =
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  return collapsed.replaceAll(RegExp(r'[.!?]+$'), '').trim();
}

/// Rewrites umlauts and eszett into their ASCII equivalents.
///
/// Applied to *both* sides of a comparison, so it also accepts a learner who
/// types `Straße` when the card happens to spell it `Strasse`.
String foldUmlauts(String value) {
  final StringBuffer out = StringBuffer();
  for (final int rune in value.runes) {
    final String character = String.fromCharCode(rune);
    out.write(_umlautFolds[character] ?? character);
  }
  return out.toString();
}

/// Classifies [input] against [expected].
GermanMatch classifyGermanAnswer(String input, String expected) {
  final String typed = normalizeGerman(input);
  final String target = normalizeGerman(expected);
  if (typed.isEmpty) return GermanMatch.wrong;
  if (typed == target) return GermanMatch.exact;
  if (foldUmlauts(typed) == foldUmlauts(target)) {
    return GermanMatch.umlautVariant;
  }
  return GermanMatch.wrong;
}

/// True when the answer should be credited, umlaut spelling aside.
bool isGermanAnswerAccepted(String input, String expected) =>
    classifyGermanAnswer(input, expected) != GermanMatch.wrong;

/// The characters offered by the umlaut helper row, in the order a German
/// keyboard presents them.
const List<String> germanSpecialCharacters = <String>[
  'ä',
  'ö',
  'ü',
  'ß',
  'Ä',
  'Ö',
  'Ü',
];
