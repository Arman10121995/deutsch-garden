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
    const expectedByLevel = <String, int>{
      'A1': 650,
      'A2': 750,
      'B1': 1200,
      'B2': 1600,
      'C1': 2600,
      'C2': 3200,
    };
    for (final level in CefrLevel.values) {
      expect(
        vocabulary.where((word) => word.level == level.label).length,
        expectedByLevel[level.label],
      );
    }
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
