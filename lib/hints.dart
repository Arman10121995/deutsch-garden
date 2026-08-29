/// Hints that remind you of the rule without answering the question.
///
/// The distinction is the whole design. Every question already carries an
/// `explanation`, and showing that on demand would be trivial and useless:
/// explanations say *which option is right and why*, so a learner who taps for
/// help gets the answer, learns nothing, and the exercise stops measuring
/// anything. A hint has to be the thing you would say to someone stuck --
/// which rule applies, what to look at first -- and then leave them to apply
/// it.
///
/// So there is one hard invariant here, enforced by
/// `tool/check_hints.py` and by `test/hints_test.dart`: **a hint never
/// contains the text of the correct option.** Where a candidate hint would
/// breach that, it is dropped and a weaker structural hint is used instead. A
/// weaker hint is a cost worth paying; a hint that answers the question is not
/// a hint.
///
/// Hints are also deliberately absent from assessment. The placement test
/// decides which level a learner starts at, and its confidence intervals
/// assume answers reflect ability; a hinted answer measures the hint. Same for
/// the civics mock, which exists to simulate a real sitting. Practice gets
/// help, measurement does not.
library;

import 'models.dart';

/// What a learner sees when they ask for help.
class Hint {
  const Hint({required this.text, required this.kind});

  final String text;

  /// Where the hint came from, so the UI can label it honestly: a rule from
  /// the lesson is worth more than a structural guess, and saying which is
  /// which stops the weaker kind from looking authoritative.
  final HintKind kind;
}

enum HintKind {
  /// The rule the lesson is actually teaching.
  rule,

  /// Derived from the shape of the question: what to look at first.
  structural,

  /// Derived from the card itself: gender, category, an example with the
  /// answer masked out.
  card,
}

/// Folds case and umlauts so a leak check cannot be defeated by spelling.
String _fold(String value) => value
    .toLowerCase()
    .replaceAll('ä', 'a')
    .replaceAll('ö', 'o')
    .replaceAll('ü', 'u')
    .replaceAll('ß', 'ss')
    .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// Whether [candidate] would give away [answer].
///
/// Matched on the folded forms: whole-word for a one-word answer, substring
/// for a phrase. See the comment inside for why that asymmetry is deliberate
/// rather than an oversight.
bool leaksAnswer(String candidate, String answer) {
  final String foldedAnswer = _fold(answer);
  if (foldedAnswer.isEmpty) return false;
  final String foldedCandidate = _fold(candidate);

  // A single-word answer is matched as a whole word, never as a substring.
  //
  // Substring matching looks safer and is not: the answer "der" is inside
  // "gender", so a hint saying "work out which gender the noun is" was
  // rejected as a leak and the learner got no hint at all. German makes this
  // worse than usual -- "den" is inside "denken", "das" inside "dass".
  if (!foldedAnswer.contains(' ')) {
    return foldedCandidate.split(' ').contains(foldedAnswer);
  }
  // A phrase cannot hide inside an unrelated word, so substring is right here.
  return foldedCandidate.contains(foldedAnswer);
}

/// A hint for a lesson question.
///
/// [ruleText] is the lesson's own explanation of what it teaches -- the right
/// answer to "what rule applies here". It is used when it does not give the
/// game away, which is the common case: a rule describes a pattern, while the
/// option is one instance of it.
Hint? hintForChoice(ChoiceQuestion question, {String ruleText = ''}) {
  final String answer = question.correctIndex >= 0 &&
          question.correctIndex < question.options.length
      ? question.options[question.correctIndex]
      : '';

  final String rule = ruleText.trim();
  if (rule.isNotEmpty && !leaksAnswer(rule, answer)) {
    return Hint(text: _trim(rule), kind: HintKind.rule);
  }

  final String? structural = _structuralHint(question);
  if (structural != null && !leaksAnswer(structural, answer)) {
    return Hint(text: structural, kind: HintKind.structural);
  }
  return null;
}

/// What to look at first, inferred from the shape of the options.
///
/// This is a small fixed table rather than per-question authoring, which is
/// the only reason it can cover every question in the app for free. It is
/// coarse by construction: it says where to point your attention, not what
/// the answer is, and the UI labels it as the weaker kind of help.
String? _structuralHint(ChoiceQuestion question) {
  final List<String> options = question.options;
  if (options.isEmpty) return null;

  bool all(bool Function(String) test) => options.every(test);

  const Set<String> articles = <String>{
    'der', 'die', 'das', 'den', 'dem', 'des',
    'ein', 'eine', 'einen', 'einem', 'einer', 'eines',
  };
  if (all((String o) => articles.contains(o.trim().toLowerCase()))) {
    return 'This is about case and gender, not vocabulary. Work out which '
        'case the verb or preposition in the sentence takes, then which '
        'gender the noun is. Wechselpräpositionen take the accusative for a '
        'change of place and the dative for a position.';
  }

  final bool sentences = all((String o) => o.trim().split(' ').length >= 4);
  if (sentences) {
    return 'Compare the word order rather than the words -- the options use '
        'nearly the same vocabulary. Find the finite verb in each and count '
        'its position: second in a main clause, last in a subordinate clause '
        'after weil, dass, wenn or ob.';
  }

  if (all((String o) => o.trim().split(' ').length <= 3)) {
    return 'Read the sentence around the gap first and decide what job the '
        'missing piece does, then rule out the options that cannot do that '
        'job. Eliminating is usually faster than choosing.';
  }
  return null;
}

/// A hint for a vocabulary card.
///
/// Built entirely from what the card already carries, so it costs nothing to
/// author and exists for all ten thousand of them. The example sentence is
/// included with the target word masked -- context is the strongest hint
/// there is, and masking is what keeps it a hint.
Hint? hintForWord(GermanWord word, {required String answer}) {
  final List<String> parts = <String>[];

  if (word.article.isNotEmpty && !leaksAnswer(word.article, answer)) {
    parts.add('It is ${word.article} — '
        '${_genderName(word.article)}.');
  }
  if (word.category.isNotEmpty && !leaksAnswer(word.category, answer)) {
    parts.add('Category: ${word.category.toLowerCase()}.');
  }

  final String masked = _maskExample(word);
  if (masked.isNotEmpty && !leaksAnswer(masked, answer)) {
    parts.add('In use: $masked');
  }

  if (parts.isEmpty) return null;
  return Hint(text: parts.join(' '), kind: HintKind.card);
}

String _genderName(String article) => switch (article.toLowerCase()) {
      'der' => 'masculine',
      'die' => 'feminine or plural',
      'das' => 'neuter',
      _ => 'no article',
    };

/// The card's example sentence with the word itself blanked out.
///
/// Masks the stem rather than the exact form, because German inflects: an
/// example for *gehen* says *geht*, and leaving that visible hands over the
/// answer while looking like it was masked.
String _maskExample(GermanWord word) {
  final String example = word.exampleGerman.trim();
  if (example.isEmpty) return '';
  final String base = word.german.trim();
  if (base.isEmpty) return example;

  // Strip the inflectional ending before taking a stem.
  //
  // Taking the first four characters of the lemma is not enough: "gehen"
  // gives "gehe", which does not match "geht", so the example sentence kept
  // the answer in plain view while looking as though it had been masked.
  // Removing the infinitive ending first gives "geh", which does.
  String root = base;
  for (final String ending in const <String>['en', 'n', 'e']) {
    if (root.length > ending.length + 2 && root.endsWith(ending)) {
      root = root.substring(0, root.length - ending.length);
      break;
    }
  }
  final int stemLength = root.length <= 4 ? root.length : 4;
  final String stem = root.substring(0, stemLength);
  final RegExp form = RegExp(
    r'\b' + RegExp.escape(stem) + r'\w*',
    caseSensitive: false,
  );
  final String masked = example.replaceAll(form, '___');
  // If nothing matched, the example does not actually contain the word and is
  // safe as it stands.
  return masked;
}

String _trim(String value) {
  const int limit = 320;
  if (value.length <= limit) return value;
  final int cut = value.lastIndexOf(' ', limit);
  return '${value.substring(0, cut < 40 ? limit : cut)}…';
}
