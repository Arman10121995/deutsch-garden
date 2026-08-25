import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_garden/curriculum.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocabulary.dart';

void main() {
  test('bundled vocabulary covers A1 through C2 and is internally consistent', () {
    expect(vocabulary.length, 10000);
    expect(vocabulary.map((word) => word.id).toSet().length, vocabulary.length);
    expect(
      vocabulary.every(
        (word) => word.article.isEmpty ||
            const <String>{'der', 'die', 'das'}.contains(word.article),
      ),
      isTrue,
    );
    // Every level has to carry enough material to be worth studying, but the
    // split between them is a pedagogical judgement rather than a quota.
    // Asserting an exact distribution meant that correcting a word's level
    // broke the build, and the only way to keep the numbers was to file words
    // under the wrong level -- which is how everyday nouns ended up at C2,
    // out of reach of the beginners who need them.
    for (final level in CefrLevel.values) {
      expect(
        vocabulary.where((word) => word.level == level.label).length,
        greaterThanOrEqualTo(400),
        reason: '${level.label} needs at least 400 cards',
      );
    }
    expect(vocabulary.length, greaterThanOrEqualTo(6000));
    expect(
      vocabulary.any(
        (word) => word.exampleGerman.startsWith('Das Lernwort heute ist'),
      ),
      isFalse,
    );
  });

  test('every CEFR level has all six learning skills', () {
    for (final level in CefrLevel.values) {
      expect(grammarFor(level).length, greaterThanOrEqualTo(34));
      expect(listeningFor(level).length, greaterThanOrEqualTo(6));
      expect(readingFor(level).length, greaterThanOrEqualTo(6));
      expect(writingFor(level).length, greaterThanOrEqualTo(6));
      expect(speakingFor(level).length, greaterThanOrEqualTo(3));
    }
  });
}
