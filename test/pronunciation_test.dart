import 'package:deutsch_garden/pronunciation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalisation folds umlauts, eszett and punctuation', () {
    expect(PronunciationScorer.normalize('Schön, größer!'), 'schoen groesser');
    expect(PronunciationScorer.normalize('Übung  macht'), 'uebung macht');
  });

  test('an exact repetition scores full marks', () {
    final PronunciationResult result = PronunciationScorer.compare(
      'Ich hätte gern einen Kaffee.',
      'ich hätte gern einen kaffee',
    );
    expect(result.score, 100);
    expect(result.problemWords, isEmpty);
  });

  test('umlaut spelling variants are not punished', () {
    final PronunciationResult result = PronunciationScorer.compare(
      'Die Tür ist schön.',
      'die Tuer ist schoen',
    );
    expect(result.score, 100);
  });

  test('a dropped word is reported without derailing the rest', () {
    final PronunciationResult result = PronunciationScorer.compare(
      'Ich fahre morgen nach Berlin',
      'Ich fahre nach Berlin',
    );
    expect(result.words.length, 5);
    final WordScore missing =
        result.words.firstWhere((word) => word.expected == 'morgen');
    expect(missing.isMissing, isTrue);
    // The words after the gap must still be recognised as matches.
    expect(
      result.words.where((word) => word.isMatch).length,
      4,
    );
  });

  test('an empty attempt scores zero and is reported as empty', () {
    final PronunciationResult result =
        PronunciationScorer.compare('Guten Morgen', '');
    expect(result.score, 0);
    expect(result.isEmpty, isTrue);
  });

  test('a completely different sentence scores low', () {
    final PronunciationResult result = PronunciationScorer.compare(
      'Wo ist der Bahnhof',
      'heute regnet es stark',
    );
    expect(result.score, lessThan(30));
  });

  test('keyword coverage tolerates inflection', () {
    expect(
      PronunciationScorer.keywordCoverage(
        'Ich wohne seit drei Jahren in Rostock.',
        <String>['wohnen'],
      ),
      1.0,
    );
    expect(
      PronunciationScorer.keywordCoverage('Guten Tag.', <String>['wohnen']),
      0.0,
    );
  });

  test('stars never exceed five and never go negative', () {
    expect(PronunciationScorer.compare('a b', 'a b').stars.length, 5);
    expect(PronunciationScorer.compare('a b', '').stars, '☆☆☆☆☆');
  });
}
