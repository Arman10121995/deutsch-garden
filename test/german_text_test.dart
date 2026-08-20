import 'package:deutsch_garden/german_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeGerman', () {
    test('trims, lowercases and collapses whitespace', () {
      expect(normalizeGerman('  Der   Mann '), 'der mann');
    });

    test('drops trailing sentence punctuation', () {
      expect(normalizeGerman('Guten Tag!'), 'guten tag');
      expect(normalizeGerman('Wie geht es dir?'), 'wie geht es dir');
      expect(normalizeGerman('Das ist gut.'), 'das ist gut');
    });

    test('keeps punctuation that is not final', () {
      expect(normalizeGerman('Ja, gern!'), 'ja, gern');
    });
  });

  group('foldUmlauts', () {
    test('folds every umlaut and eszett', () {
      expect(foldUmlauts('mädchen'), 'maedchen');
      expect(foldUmlauts('öl'), 'oel');
      expect(foldUmlauts('über'), 'ueber');
      expect(foldUmlauts('straße'), 'strasse');
    });

    test('leaves unaffected text alone', () {
      expect(foldUmlauts('der mann'), 'der mann');
    });
  });

  group('classifyGermanAnswer', () {
    test('an identical answer is exact', () {
      expect(
        classifyGermanAnswer('das Mädchen', 'das Mädchen'),
        GermanMatch.exact,
      );
    });

    test('case and trailing punctuation do not matter', () {
      expect(
        classifyGermanAnswer('  DAS MÄDCHEN. ', 'das Mädchen'),
        GermanMatch.exact,
      );
    });

    test('ASCII umlauts are accepted but flagged', () {
      expect(
        classifyGermanAnswer('das Maedchen', 'das Mädchen'),
        GermanMatch.umlautVariant,
      );
      expect(
        classifyGermanAnswer('die Strasse', 'die Straße'),
        GermanMatch.umlautVariant,
      );
      expect(
        classifyGermanAnswer('ueber', 'über'),
        GermanMatch.umlautVariant,
      );
    });

    test('the reverse direction is accepted too', () {
      // Card spells it with ss, learner types the eszett.
      expect(
        classifyGermanAnswer('die Straße', 'die Strasse'),
        GermanMatch.umlautVariant,
      );
    });

    test('a genuinely wrong answer stays wrong', () {
      expect(
        classifyGermanAnswer('der Junge', 'das Mädchen'),
        GermanMatch.wrong,
      );
    });

    test('a dropped umlaut without the e is still wrong', () {
      // "Madchen" is not the ASCII convention, it is just a misspelling.
      expect(
        classifyGermanAnswer('das Madchen', 'das Mädchen'),
        GermanMatch.wrong,
      );
    });

    test('a wrong article is wrong', () {
      expect(
        classifyGermanAnswer('der Mädchen', 'das Mädchen'),
        GermanMatch.wrong,
      );
    });

    test('an empty answer is wrong, never an accidental match', () {
      expect(classifyGermanAnswer('', ''), GermanMatch.wrong);
      expect(classifyGermanAnswer('   ', 'das Haus'), GermanMatch.wrong);
    });
  });

  group('isGermanAnswerAccepted', () {
    test('credits exact and umlaut variants alike', () {
      expect(isGermanAnswerAccepted('die Tür', 'die Tür'), isTrue);
      expect(isGermanAnswerAccepted('die Tuer', 'die Tür'), isTrue);
      expect(isGermanAnswerAccepted('die Tor', 'die Tür'), isFalse);
    });
  });
}
