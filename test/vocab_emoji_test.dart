import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocab_emoji.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

GermanWord byId(String id) =>
    vocabulary.firstWhere((GermanWord w) => w.id == id);

Widget host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('the emoji table', () {
    test('is not empty and every entry names a real card', () {
      expect(vocabEmoji, isNotEmpty);
      final Set<String> ids = <String>{
        for (final GermanWord w in vocabulary) w.id,
      };
      for (final String id in vocabEmoji.keys) {
        expect(ids, contains(id), reason: '$id is not a card');
      }
    });

    test('every value is a picture, never notation', () {
      // CLDR annotates & and the maths symbols too, because they are on the
      // emoji keyboard. A card showing an ampersand has gained nothing.
      for (final MapEntry<String, String> e in vocabEmoji.entries) {
        for (final int point in e.value.runes) {
          if (point == 0x200D || point == 0xFE0F) continue;
          expect(
            point >= 0x1F000 || (point >= 0x2600 && point <= 0x27BF),
            isTrue,
            reason: '${e.key} maps to U+${point.toRadixString(16)}',
          );
        }
      }
    });

    test('a known good mapping is present', () {
      // Spot-checks that the German-to-German match really did land where it
      // should, rather than the table merely being large.
      final GermanWord nose =
          vocabulary.firstWhere((GermanWord w) => w.german == 'Nase');
      expect(vocabEmoji[nose.id], '👃');
    });
  });

  group('precedence', () {
    testWidgets('a drawing still wins over an emoji', (WidgetTester t) async {
      debugResetVocabIcons();
      await loadVocabIconIndex(rootBundle);
      // Mann has an authored drawing; it must not be downgraded.
      final GermanWord mann = byId('001');
      expect(hasVocabIcon(mann), isTrue);
      expect(hasVocabEmoji(mann), isFalse,
          reason: 'the generator excludes cards that already have art');
    });

    testWidgets('an emoji card renders its glyph', (WidgetTester t) async {
      debugResetVocabIcons();
      await loadVocabIconIndex(rootBundle);
      final String id = vocabEmoji.keys.first;
      await t.pumpWidget(host(VocabIcon(word: byId(id))));
      expect(find.text(vocabEmoji[id]!), findsOneWidget);
    });

    test('emoji cards count as having an image', () {
      final String id = vocabEmoji.keys.first;
      expect(hasAnyVocabImage(byId(id)), isTrue);
    });
  });

  test('the emoji tier measurably increased coverage', () {
    // The point of the exercise. Recorded as a number so a regression that
    // quietly empties the table shows up as a failure rather than as a
    // slightly emptier screen.
    expect(vocabEmoji.length, greaterThanOrEqualTo(200));
  });
}
