import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_garden/curriculum.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocabulary.dart';

void main() {
  test('bundled vocabulary covers A1 through C2 and is internally consistent', () {
    expect(vocabulary.length, greaterThanOrEqualTo(850));
    expect(vocabulary.map((word) => word.id).toSet().length, vocabulary.length);
    expect(
      vocabulary.every(
        (word) => word.article.isEmpty ||
            const <String>{'der', 'die', 'das'}.contains(word.article),
      ),
      isTrue,
    );
    for (final level in CefrLevel.values) {
      expect(
        vocabulary.where((word) => word.level == level.label).length,
        greaterThanOrEqualTo(120),
      );
    }
  });

  test('every CEFR level has all six learning skills', () {
    for (final level in CefrLevel.values) {
      expect(grammarFor(level).length, greaterThanOrEqualTo(16));
      expect(listeningFor(level).length, greaterThanOrEqualTo(6));
      expect(readingFor(level).length, greaterThanOrEqualTo(6));
      expect(writingFor(level).length, greaterThanOrEqualTo(6));
      expect(speakingFor(level).length, greaterThanOrEqualTo(3));
    }
  });
}
