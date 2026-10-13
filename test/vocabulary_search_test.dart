import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:deutsch_garden/vocabulary_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  GermanWord word(String lemma) =>
      vocabulary.firstWhere((word) => word.german == lemma);

  test('reference lookup accepts umlaut and eszett keyboard alternatives', () {
    expect(vocabularyMatchesQuery(word('Straße'), 'STRASSE'), isTrue);
    expect(vocabularyMatchesQuery(word('Mädchen'), ' das   Maedchen '), isTrue);
    expect(vocabularyMatchesQuery(word('Mann'), 'die Maenner'), isTrue);
    expect(vocabularyMatchesQuery(word('Mädchen'), 'boy'), isFalse);
  });

  test('selected meanings supplement English rather than hiding it', () {
    expect(
      vocabularyMatchesQuery(word('Mann'), 'adam', meaning: 'adam'),
      isTrue,
    );
    expect(
      vocabularyMatchesQuery(word('Mann'), 'man', meaning: 'adam'),
      isTrue,
    );
    expect(vocabularyMatchesQuery(word('Mann'), '   '), isTrue);
  });
}
