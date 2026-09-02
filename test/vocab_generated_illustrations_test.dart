import 'dart:io';

import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every generated vocabulary illustration exists and is a PNG', () {
    expect(generatedVocabIllustrations, hasLength(32));
    for (final MapEntry<String, String> entry
        in generatedVocabIllustrations.entries) {
      final File file = File(entry.value);
      expect(file.existsSync(), isTrue, reason: '${entry.key}: ${entry.value}');
      final List<int> bytes = file.readAsBytesSync();
      expect(bytes.take(8), <int>[137, 80, 78, 71, 13, 10, 26, 10]);
      expect(bytes.length, greaterThan(20 * 1024));
    }
  });

  test('illustrations resolve by lemma across stable card ids', () {
    const GermanWord word = GermanWord(
      id: 'any-stable-id',
      article: '',
      german: 'schwimmen',
      plural: '—',
      english: 'to swim',
      exampleGerman: 'Wir schwimmen im See.',
      exampleEnglish: 'We swim in the lake.',
      category: 'Actions',
      level: 'A1',
    );

    expect(hasGeneratedVocabIllustration(word), isTrue);
    expect(
      generatedVocabIllustrationFor(word),
      'assets/vocab_generated/schwimmen.png',
    );
  });
}
