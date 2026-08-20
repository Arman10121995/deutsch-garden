import 'package:deutsch_garden/sentence_bank.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/pronunciation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dictation sentences are available for all CEFR levels', () {
    for (final level in CefrLevel.values) {
      final sentences = sentencesFor(level);
      expect(sentences, isNotEmpty, reason: '${level.label} must have dictation practice sentences');
      for (final sentence in sentences) {
        expect(sentence.german.trim(), isNotEmpty);
        expect(sentence.english.trim(), isNotEmpty);
      }
    }
  });

  test('pronunciation scorer evaluates dictation input correctly', () {
    const target = 'Ich wohne in Berlin';
    const exact = 'Ich wohne in Berlin';
    const typo = 'Ich wone in Berlin';
    const wrong = 'Das Haus ist rot';

    final exactResult = PronunciationScorer.compare(target, exact);
    expect(exactResult.score, 100);

    final typoResult = PronunciationScorer.compare(target, typo);
    expect(typoResult.score, greaterThan(60));
    expect(typoResult.score, lessThan(100));

    final wrongResult = PronunciationScorer.compare(target, wrong);
    expect(wrongResult.score, lessThan(40));
  });
}
