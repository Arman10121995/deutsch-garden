import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:deutsch_garden/vocabulary_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

GermanWord named(String value) =>
    vocabulary.firstWhere((GermanWord word) => word.german == value);

void main() {
  test('every bundled card has a specific visible word-class label', () {
    expect(vocabulary, hasLength(10000));
    final List<GermanWord> unspecified = vocabulary
        .where((GermanWord word) => word.wordClass == GermanWordClass.other)
        .toList(growable: false);
    expect(
      unspecified,
      isEmpty,
      reason: 'Every card must say what kind of word it is.',
    );
    expect(
      vocabulary.every((GermanWord word) => word.grammarLabel.isNotEmpty),
      isTrue,
    );
  });

  test('high-confidence classes are not guessed from typography alone', () {
    expect(named('Wohnung').wordClass, GermanWordClass.noun);
    expect(named('arbeiten').wordClass, GermanWordClass.verb);
    expect(named('schön').wordClass, GermanWordClass.adjective);
    expect(named('heute').wordClass, GermanWordClass.adverb);
    expect(named('mit').wordClass, GermanWordClass.preposition);
    expect(named('weil').wordClass, GermanWordClass.conjunction);
  });

  test('noun endings are clues and mismatches are named as exceptions', () {
    final GermanWord wohnung = named('Wohnung');
    expect(genderEndingFor(wohnung)?.rule.gender, NounGender.feminine);
    expect(wohnung.genderEndingComment, contains('strong die clue'));

    final GermanWord moment = named('Moment');
    expect(moment.article, 'der');
    expect(moment.genderEndingComment, startsWith('Exception:'));
  });

  test('all nouns expose one of the three grammatical genders', () {
    final Iterable<GermanWord> nouns = vocabulary.where(
      (GermanWord word) => word.article.isNotEmpty,
    );
    expect(nouns, isNotEmpty);
    for (final GermanWord noun in nouns) {
      expect(noun.wordClass, GermanWordClass.noun, reason: noun.german);
      expect(noun.nounGender, isNotNull, reason: noun.displayGerman);
    }
  });
}
