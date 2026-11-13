/// Wrong options that make a vocabulary question worth answering.
///
/// The session used to draw its three wrong options from the whole level at
/// random. For *der Mann* that produced "to allow; to permit", "sadly" and a
/// preposition: one noun among three things that could not be a noun, so the
/// question was answered by word class and nothing was retrieved. A choice
/// only tests recall when the alternatives are things the word could have
/// been.
///
/// Pure logic with no Flutter imports, so the selection rule is unit-tested
/// against the real deck rather than through a widget.
library;

import 'dart:math';

import 'models.dart';
import 'vocabulary_metadata.dart';

/// Adjectives and the deck's "adjective or adverb" entries are one family for
/// this purpose: German does not mark the adverbial use, and a learner cannot
/// tell them apart from the gloss either.
GermanWordClass _family(GermanWordClass wordClass) =>
    wordClass == GermanWordClass.adjectiveAdverb
    ? GermanWordClass.adjective
    : wordClass;

String _normal(String text) => text.trim().toLowerCase();

/// Picks up to [count] words from [pool] to stand beside [target] as wrong
/// options.
///
/// [label] is what the option will display. No two options share a label and
/// none repeats the target's, so a question never shows the right answer
/// twice. [conflict] is the *other* side of the card: when the options are
/// German words, a distractor whose meaning equals the target's would be a
/// second correct answer, so it is excluded on that side too.
///
/// Preference runs from the closest confusers outwards: the same word class
/// in the same topic, then the same word class, then anything. At most two
/// come from the first tier so a question keeps some variety and a small
/// topic is not exhausted into the same three neighbours every time.
List<GermanWord> pickDistractors({
  required GermanWord target,
  required Iterable<GermanWord> pool,
  required String Function(GermanWord word) label,
  String Function(GermanWord word)? conflict,
  required Random random,
  int count = 3,
  Map<String, GermanWordClass>? classCache,
}) {
  GermanWordClass classOf(GermanWord word) {
    final GermanWordClass? cached = classCache?[word.id];
    if (cached != null) return cached;
    final GermanWordClass computed = _family(wordClassFor(word));
    classCache?[word.id] = computed;
    return computed;
  }

  final GermanWordClass targetClass = classOf(target);
  final String targetLabel = _normal(label(target));
  final String? targetConflict = conflict == null
      ? null
      : _normal(conflict(target));
  final String targetCategory = _normal(target.category);

  final List<GermanWord> sameTopic = <GermanWord>[];
  final List<GermanWord> sameClass = <GermanWord>[];
  final List<GermanWord> rest = <GermanWord>[];
  for (final GermanWord word in pool) {
    if (word.id == target.id) continue;
    if (_normal(label(word)) == targetLabel) continue;
    if (targetConflict != null && _normal(conflict!(word)) == targetConflict) {
      continue;
    }
    if (classOf(word) != targetClass) {
      rest.add(word);
    } else if (_normal(word.category) == targetCategory) {
      sameTopic.add(word);
    } else {
      sameClass.add(word);
    }
  }
  sameTopic.shuffle(random);
  sameClass.shuffle(random);
  rest.shuffle(random);

  final List<GermanWord> chosen = <GermanWord>[];
  final Set<String> used = <String>{targetLabel};
  void take(List<GermanWord> from, int limit) {
    for (final GermanWord word in from) {
      if (chosen.length >= limit) return;
      if (used.add(_normal(label(word)))) chosen.add(word);
    }
  }

  take(sameTopic, min(2, count));
  take(sameClass, count);
  // A word class with too few members at this level (numbers, conjunctions)
  // runs out; the rest of its own topic is still closer than a random card.
  take(sameTopic, count);
  take(rest, count);
  return chosen;
}

/// The longest an option label aims to be.
const int optionLabelTarget = 40;

/// The meaning as it is shown on an answer option.
///
/// Part of the deck carries dictionary glosses: "wild animal; any animal that
/// is not domesticated, living under natural conditions". As one of four
/// options that is hard to scan, and its length alone marks it out. An option
/// shows the first sense without its parenthetical notes; the card itself, the
/// feedback and the flashcard keep the full gloss.
///
/// Measured on the 10,000-card deck in 4.25: 1,571 glosses run over 40
/// characters (16%); 81 option labels still do (0.8%), almost all of them
/// grammatical descriptions that have no shorter sense.
String shortOptionLabel(String gloss) {
  final String original = gloss.trim();
  String label = original.split(';').first;
  label = label.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
  label = label.replaceAll(RegExp(r'\s*\[[^\]]*\]'), '');
  // A gloss cut short upstream can leave an unclosed note.
  final int open = label.indexOf('(');
  if (open > 0) label = label.substring(0, open);
  label = label.replaceAll(RegExp(r'\s+'), ' ').trim();
  label = label.replaceAll(RegExp(r'[,:]+$'), '').trim();
  if (label.length > optionLabelTarget && label.contains(',')) {
    final List<String> parts = label.split(',').map((p) => p.trim()).toList();
    String kept = parts.first;
    for (final String part in parts.skip(1)) {
      if (kept.length + part.length + 2 > optionLabelTarget) break;
      kept = '$kept, $part';
    }
    label = kept;
  }
  return label.isEmpty ? original : label;
}
