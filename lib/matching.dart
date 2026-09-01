import 'dart:math';

import 'models.dart';

/// A matching round is deliberately six pairs.  Fewer than six used to render
/// but could never satisfy the old twelve-tile completion condition.
const int matchingPairsPerRound = 6;
const int matchingRoundCount = 3;

/// Cards that may appear in word matching.
///
/// Matching is retrieval, not first exposure: a card is eligible only after a
/// vocabulary screen has marked it seen.  Visible labels are unique as well.
/// Two buttons both saying "to go" are not a meaningful choice even if their
/// backing ids differ.
List<GermanWord> eligibleMatchingWords({
  required Iterable<GermanWord> words,
  required Map<String, WordProgress> progress,
}) {
  final List<GermanWord> eligible = <GermanWord>[];
  final Set<String> germanLabels = <String>{};
  final Set<String> englishLabels = <String>{};
  final Set<String> ids = <String>{};

  for (final GermanWord word in words) {
    if (!(progress[word.id]?.seen ?? false)) continue;
    final String german = word.displayGerman.trim().toLowerCase();
    final String english = word.english.trim().toLowerCase();
    if (german.isEmpty || english.isEmpty) continue;
    if (ids.contains(word.id) ||
        germanLabels.contains(german) ||
        englishLabels.contains(english)) {
      continue;
    }
    ids.add(word.id);
    germanLabels.add(german);
    englishLabels.add(english);
    eligible.add(word);
  }
  return eligible;
}

/// Deals complete rounds.  No partial round is ever returned.
///
/// With eighteen eligible cards all three rounds are disjoint.  A smaller
/// seen deck is replayed in a new order rather than silently introducing an
/// unseen card just to make up the numbers.
List<List<GermanWord>> dealMatchingRounds(
  List<GermanWord> eligible,
  Random random, {
  int pairsPerRound = matchingPairsPerRound,
  int rounds = matchingRoundCount,
}) {
  if (pairsPerRound <= 0 || rounds <= 0 || eligible.length < pairsPerRound) {
    return const <List<GermanWord>>[];
  }

  final List<GermanWord> source = List<GermanWord>.of(eligible)
    ..shuffle(random);
  final List<List<GermanWord>> dealt = <List<GermanWord>>[];
  int cursor = 0;

  for (int round = 0; round < rounds; round++) {
    if (cursor + pairsPerRound > source.length) {
      source.shuffle(random);
      cursor = 0;
    }
    dealt.add(
      List<GermanWord>.unmodifiable(
        source.sublist(cursor, cursor + pairsPerRound),
      ),
    );
    cursor += pairsPerRound;
  }
  return List<List<GermanWord>>.unmodifiable(dealt);
}
