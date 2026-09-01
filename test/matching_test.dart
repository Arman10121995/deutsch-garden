import 'dart:math';

import 'package:deutsch_garden/matching.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter_test/flutter_test.dart';

GermanWord word(int index, {String? english}) => GermanWord(
  id: 'w$index',
  article: index.isEven ? 'der' : '',
  german: 'Wort$index',
  plural: 'Wörter$index',
  english: english ?? 'meaning $index',
  exampleGerman: 'Das ist Wort$index.',
  exampleEnglish: 'That is word $index.',
  category: 'Test',
  level: 'A1',
);

void main() {
  test('matching excludes every vocabulary card not seen yet', () {
    final List<GermanWord> words = List<GermanWord>.generate(8, word);
    final Map<String, WordProgress> progress = <String, WordProgress>{
      for (final GermanWord item in words.take(6))
        item.id: WordProgress(seen: true),
    };

    final List<GermanWord> eligible = eligibleMatchingWords(
      words: words,
      progress: progress,
    );

    expect(
      eligible.map((GermanWord item) => item.id),
      words.take(6).map((GermanWord item) => item.id),
    );
    expect(
      eligible.every((GermanWord item) => progress[item.id]!.seen),
      isTrue,
    );
  });

  test(
    'fewer than six seen cards cannot create an unwinnable partial round',
    () {
      final List<GermanWord> cards = List<GermanWord>.generate(5, word);
      expect(dealMatchingRounds(cards, Random(1)), isEmpty);
    },
  );

  test(
    'three rounds are complete and disjoint when eighteen cards are seen',
    () {
      final List<GermanWord> cards = List<GermanWord>.generate(18, word);
      final List<List<GermanWord>> rounds = dealMatchingRounds(
        cards,
        Random(2),
      );

      expect(rounds, hasLength(matchingRoundCount));
      expect(
        rounds.every(
          (List<GermanWord> round) => round.length == matchingPairsPerRound,
        ),
        isTrue,
      );
      expect(
        rounds
            .expand((List<GermanWord> round) => round)
            .map((word) => word.id)
            .toSet(),
        hasLength(18),
      );
    },
  );

  test('ambiguous duplicate labels are not dealt as fake choices', () {
    final List<GermanWord> words = <GermanWord>[
      word(1, english: 'to go'),
      word(2, english: 'to go'),
      ...List<GermanWord>.generate(6, (int i) => word(i + 3)),
    ];
    final Map<String, WordProgress> progress = <String, WordProgress>{
      for (final GermanWord item in words) item.id: WordProgress(seen: true),
    };

    final List<GermanWord> eligible = eligibleMatchingWords(
      words: words,
      progress: progress,
    );

    expect(
      eligible.where((GermanWord item) => item.english == 'to go'),
      hasLength(1),
    );
    expect(
      eligible.map((GermanWord item) => item.id).toSet(),
      hasLength(eligible.length),
    );
  });
}
