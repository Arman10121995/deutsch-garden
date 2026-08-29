/// Linguistic metadata derived from a vocabulary card.
///
/// The imported deck predates an explicit part-of-speech field. Rewriting ten
/// thousand stable cards would be noisy and would make future source updates
/// unnecessarily difficult, so the app derives a conservative label here.
/// Where German genuinely permits the same form as an adjective and an adverb,
/// the label says that instead of inventing a false distinction.
library;

import 'models.dart';

enum GermanWordClass {
  noun,
  verb,
  adjective,
  adjectiveAdverb,
  adverb,
  pronoun,
  preposition,
  conjunction,
  number,
  expression,
  other,
}

extension GermanWordClassText on GermanWordClass {
  String get label {
    switch (this) {
      case GermanWordClass.noun:
        return 'Noun';
      case GermanWordClass.verb:
        return 'Verb';
      case GermanWordClass.adjective:
        return 'Adjective';
      case GermanWordClass.adjectiveAdverb:
        return 'Adjective / adverb (same form)';
      case GermanWordClass.adverb:
        return 'Adverb';
      case GermanWordClass.pronoun:
        return 'Pronoun';
      case GermanWordClass.preposition:
        return 'Preposition';
      case GermanWordClass.conjunction:
        return 'Conjunction';
      case GermanWordClass.number:
        return 'Number';
      case GermanWordClass.expression:
        return 'Expression';
      case GermanWordClass.other:
        return 'Other word';
    }
  }

  String get shortLabel {
    switch (this) {
      case GermanWordClass.noun:
        return 'N';
      case GermanWordClass.verb:
        return 'V';
      case GermanWordClass.adjective:
        return 'ADJ';
      case GermanWordClass.adjectiveAdverb:
        return 'ADJ/ADV';
      case GermanWordClass.adverb:
        return 'ADV';
      case GermanWordClass.pronoun:
        return 'PRO';
      case GermanWordClass.preposition:
        return 'PREP';
      case GermanWordClass.conjunction:
        return 'CONJ';
      case GermanWordClass.number:
        return 'NUM';
      case GermanWordClass.expression:
        return 'PHR';
      case GermanWordClass.other:
        return 'WORD';
    }
  }

  String get learningNote {
    switch (this) {
      case GermanWordClass.noun:
        return 'Learn the article and plural together with the noun.';
      case GermanWordClass.verb:
        return 'Learn the infinitive, present forms and past participle.';
      case GermanWordClass.adjective:
        return 'An adjective describes a noun. Before a noun it takes an '
            'ending; used predicatively it keeps its base form.';
      case GermanWordClass.adjectiveAdverb:
        return 'German normally uses the same base form as an adjective and '
            'as an adverb; only attributive adjectives take endings.';
      case GermanWordClass.adverb:
        return 'An adverb modifies a verb, adjective or whole statement.';
      case GermanWordClass.pronoun:
        return 'Pronouns change with person, number and often case.';
      case GermanWordClass.preposition:
        return 'Learn the case governed by this preposition.';
      case GermanWordClass.conjunction:
        return 'Notice whether it keeps main-clause order or sends the verb '
            'to the end.';
      case GermanWordClass.number:
        return 'A number or quantity expression.';
      case GermanWordClass.expression:
        return 'Learn this as a complete chunk, not word by word.';
      case GermanWordClass.other:
        return 'Use the example sentence to learn how this word functions.';
    }
  }
}

const Set<String> _pronouns = <String>{
  'ich',
  'du',
  'er',
  'sie',
  'es',
  'wir',
  'ihr',
  'ihnen',
  'ihm',
  'mir',
  'mich',
  'dich',
  'uns',
  'euch',
  'man',
  'jemand',
  'niemand',
  'etwas',
  'nichts',
  'wer',
  'was',
  'welcher',
  'welche',
  'welches',
  'dieser',
  'diese',
  'dieses',
  'jeder',
  'jede',
  'jedes',
  'mein',
  'dein',
  'sein',
  'unser',
  'euer',
  'ihrer',
};

const Set<String> _prepositions = <String>{
  'an',
  'auf',
  'aus',
  'außer',
  'bei',
  'bis',
  'durch',
  'entlang',
  'für',
  'gegen',
  'gegenüber',
  'hinter',
  'in',
  'innerhalb',
  'mit',
  'nach',
  'neben',
  'ohne',
  'seit',
  'statt',
  'trotz',
  'über',
  'um',
  'unter',
  'von',
  'vor',
  'während',
  'wegen',
  'zu',
  'zwischen',
};

const Set<String> _conjunctions = <String>{
  'aber',
  'als',
  'bevor',
  'bis',
  'da',
  'damit',
  'dass',
  'denn',
  'doch',
  'falls',
  'indem',
  'nachdem',
  'ob',
  'obwohl',
  'oder',
  'seitdem',
  'sobald',
  'sodass',
  'solange',
  'sondern',
  'und',
  'während',
  'weil',
  'wenn',
};

const Set<String> _adverbs = <String>{
  'auch',
  'außerdem',
  'bald',
  'bereits',
  'besonders',
  'deshalb',
  'dort',
  'draußen',
  'drinnen',
  'eben',
  'fast',
  'gestern',
  'gern',
  'gerne',
  'heute',
  'hier',
  'immer',
  'jedoch',
  'kaum',
  'manchmal',
  'morgen',
  'nie',
  'noch',
  'nun',
  'nur',
  'oben',
  'oft',
  'schon',
  'sehr',
  'so',
  'trotzdem',
  'unten',
  'ungefähr',
  'vielleicht',
  'wieder',
  'zuerst',
  'zusammen',
};

const Set<String> _numberWords = <String>{
  'null',
  'eins',
  'ein',
  'eine',
  'zwei',
  'drei',
  'vier',
  'fünf',
  'sechs',
  'sieben',
  'acht',
  'neun',
  'zehn',
  'elf',
  'zwölf',
  'hundert',
  'tausend',
  'erste',
  'erster',
  'erstes',
  'zweite',
  'zweiter',
  'zweites',
};

GermanWordClass wordClassFor(GermanWord word) {
  if (word.article.isNotEmpty) return GermanWordClass.noun;

  final String german = word.german.trim().toLowerCase();
  final String english = word.english.trim().toLowerCase();
  if (_pronouns.contains(german)) return GermanWordClass.pronoun;
  if (_prepositions.contains(german)) return GermanWordClass.preposition;
  if (_conjunctions.contains(german)) return GermanWordClass.conjunction;
  if (_numberWords.contains(german) || RegExp(r'^\d').hasMatch(german)) {
    return GermanWordClass.number;
  }
  if (_adverbs.contains(german) ||
      german.endsWith('weise') ||
      german.endsWith('wärts') ||
      english.contains('(adverb)')) {
    return GermanWordClass.adverb;
  }
  if (english.startsWith('to ') ||
      english.contains('; to ') ||
      german.startsWith('sich ')) {
    return GermanWordClass.verb;
  }
  if (german.contains(' ') || german.contains('-')) {
    return GermanWordClass.expression;
  }
  if (word.category.toLowerCase() == 'description' ||
      english.contains('(adjective)') ||
      RegExp(r'(ig|lich|isch|bar|los|sam|voll|haft)$').hasMatch(german)) {
    return GermanWordClass.adjective;
  }
  if (english.startsWith('being ') ||
      RegExp(r'^(very |rather |quite )?[a-z-]+$').hasMatch(english)) {
    return GermanWordClass.adjectiveAdverb;
  }
  // A bare lowercase lexical entry in this deck is overwhelmingly an
  // adjective/participle that can also be used adverbially. German does not
  // mark that adverbial use with a separate form, so this is the honest label
  // when the source gloss supplies no narrower function tag.
  return GermanWordClass.adjectiveAdverb;
}

enum NounGender { masculine, feminine, neuter }

extension NounGenderText on NounGender {
  String get article {
    switch (this) {
      case NounGender.masculine:
        return 'der';
      case NounGender.feminine:
        return 'die';
      case NounGender.neuter:
        return 'das';
    }
  }

  String get label {
    switch (this) {
      case NounGender.masculine:
        return 'Masculine';
      case NounGender.feminine:
        return 'Feminine';
      case NounGender.neuter:
        return 'Neuter';
    }
  }
}

enum RuleStrength { reliable, common }

class GenderEndingRule {
  const GenderEndingRule({
    required this.endings,
    required this.gender,
    required this.strength,
    required this.note,
  });

  final List<String> endings;
  final NounGender gender;
  final RuleStrength strength;
  final String note;

  String get endingsLabel => endings.map((String e) => '-$e').join(', ');
}

/// Productive noun-ending clues, ordered from the strongest and most specific
/// to the broader tendencies. They are clues, never a replacement for learning
/// an article; every UI that presents one also labels exceptions explicitly.
const List<GenderEndingRule> genderEndingRules = <GenderEndingRule>[
  GenderEndingRule(
    endings: <String>['ung', 'heit', 'keit', 'schaft'],
    gender: NounGender.feminine,
    strength: RuleStrength.reliable,
    note: 'Abstract-noun endings in this group are almost always feminine.',
  ),
  GenderEndingRule(
    endings: <String>['ion', 'tät', 'ik', 'ur', 'enz', 'anz', 'ei'],
    gender: NounGender.feminine,
    strength: RuleStrength.common,
    note: 'These borrowed and derived endings strongly favour feminine nouns.',
  ),
  GenderEndingRule(
    endings: <String>['chen', 'lein'],
    gender: NounGender.neuter,
    strength: RuleStrength.reliable,
    note: 'Diminutives are neuter, regardless of the source noun’s gender.',
  ),
  GenderEndingRule(
    endings: <String>['um'],
    gender: NounGender.neuter,
    strength: RuleStrength.reliable,
    note:
        'Most nouns ending in -um are neuter; their plural often ends in -en.',
  ),
  GenderEndingRule(
    endings: <String>['ment', 'nis'],
    gender: NounGender.neuter,
    strength: RuleStrength.common,
    note:
        'These endings often indicate neuter, but important exceptions exist.',
  ),
  GenderEndingRule(
    endings: <String>['ling', 'ismus'],
    gender: NounGender.masculine,
    strength: RuleStrength.reliable,
    note: 'Nouns with these endings are overwhelmingly masculine.',
  ),
  GenderEndingRule(
    endings: <String>['or', 'ist'],
    gender: NounGender.masculine,
    strength: RuleStrength.common,
    note: 'Agent and borrowed nouns with these endings are commonly masculine.',
  ),
];

class GenderEndingMatch {
  const GenderEndingMatch({required this.rule, required this.ending});

  final GenderEndingRule rule;
  final String ending;
}

GenderEndingMatch? genderEndingFor(GermanWord word) {
  if (word.article.isEmpty) return null;
  final String lower = word.german.toLowerCase();
  GenderEndingMatch? best;
  for (final GenderEndingRule rule in genderEndingRules) {
    for (final String ending in rule.endings) {
      if (!lower.endsWith(ending)) continue;
      if (best == null || ending.length > best.ending.length) {
        best = GenderEndingMatch(rule: rule, ending: ending);
      }
    }
  }
  return best;
}

extension GermanWordMetadata on GermanWord {
  GermanWordClass get wordClass => wordClassFor(this);

  NounGender? get nounGender {
    switch (article.toLowerCase()) {
      case 'der':
        return NounGender.masculine;
      case 'die':
        return NounGender.feminine;
      case 'das':
        return NounGender.neuter;
      default:
        return null;
    }
  }

  String get grammarLabel {
    final NounGender? gender = nounGender;
    if (gender == null) return wordClass.label;
    return '${wordClass.label} · ${gender.label} (${gender.article})';
  }

  String get genderEndingComment {
    final GenderEndingMatch? match = genderEndingFor(this);
    if (match == null) {
      return nounGender == null
          ? wordClass.learningNote
          : 'No dependable ending rule applies here; learn the noun together '
                'with ${article.toLowerCase()}.';
    }
    final GenderEndingRule rule = match.rule;
    final bool agrees = rule.gender.article == article.toLowerCase();
    final String tendency = rule.strength == RuleStrength.reliable
        ? 'is a strong ${rule.gender.article} clue'
        : 'often suggests ${rule.gender.article}';
    if (agrees) {
      return 'The ending -${match.ending} $tendency. ${rule.note}';
    }
    return 'Exception: -${match.ending} $tendency, but this noun is '
        '${article.toLowerCase()} $german. Learn this article explicitly.';
  }
}
