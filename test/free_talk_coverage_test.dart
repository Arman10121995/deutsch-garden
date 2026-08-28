import 'package:deutsch_garden/conversation.dart';
import 'package:deutsch_garden/conversation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

FreeTalkPrompt promptFor(String id) =>
    freeTalkPrompts.firstWhere((FreeTalkPrompt p) => p.id == id);

void main() {
  group('the stemmer', () {
    test('folds the inflections that separate one verb from itself', () {
      final String wohn = GermanStem.stem('wohnen');
      expect(GermanStem.stem('wohnt'), wohn);
      expect(GermanStem.stem('wohne'), wohn);
      expect(GermanStem.stem('Wohnen'), wohn);
    });

    test('folds umlauts and the sharp s', () {
      expect(GermanStem.stem('groß'), GermanStem.stem('gross'));
      expect(GermanStem.stem('Väter'), GermanStem.stem('vater'));
    });

    test('is consistent rather than correct', () {
      // `Preis` stems to something short and slightly wrong. That is fine, so
      // long as every form of it stems to the same short wrong thing.
      expect(GermanStem.stem('Preise'), GermanStem.stem('Preis'));
      expect(GermanStem.stem('Preisen'), GermanStem.stem('Preis'));
    });

    test('does not strip a short word down to nothing', () {
      expect(GermanStem.stem('und'), 'und');
      expect(GermanStem.stem('ist'), 'ist');
      expect(GermanStem.stem('wer').length, greaterThan(0));
    });

    test('finds a keyword inside a compound', () {
      final Set<String> tokens = GermanStem.tokens('Der Nahverkehr ist teuer.');
      expect(GermanStem.present(tokens, 'Verkehr'), isTrue);
    });

    test('does not match a short stem by accident', () {
      final Set<String> tokens = GermanStem.tokens('Ich bin heute müde.');
      expect(GermanStem.present(tokens, 'Miete'), isFalse);
      expect(GermanStem.present(tokens, 'Bruder'), isFalse);
    });

    test('matches a two-word phrase only when both words are adjacent', () {
      expect(
          GermanStem.present(
              GermanStem.tokens('Meiner Meinung nach ist das falsch.'),
              'meiner meinung'),
          isTrue);
      expect(
          GermanStem.present(
              GermanStem.tokens('Die Meinung war meiner Mutter wichtig.'),
              'meiner meinung'),
          isFalse);
    });
  });

  group('free-talk coverage', () {
    test('an on-topic answer is credited for the points it addresses', () {
      final FreeTalkEvaluation e = ConversationEngine.evaluateFreeTalk(
        promptFor('ft-a1-01'),
        'Meine Familie ist klein. Meine Eltern wohnen in Hamburg. '
            'Mein Bruder arbeitet als Lehrer und meine Schwester studiert.',
      );
      expect(e.coveredPoints, hasLength(3));
      expect(e.coverage, closeTo(1.0, 0.001));
    });

    test('an off-topic answer of the right length no longer scores well', () {
      // This is the whole point of the item. The old scoring counted length
      // and connectors, so this answer -- fluent, correct German, nothing to
      // do with the question -- was told it had covered everything.
      final FreeTalkPrompt prompt = promptFor('ft-a1-01');
      final FreeTalkEvaluation e = ConversationEngine.evaluateFreeTalk(
        prompt,
        'Gestern war das Wetter sehr schön und auch ziemlich warm, aber '
            'am Abend hat es geregnet und der Himmel war grau und dunkel, '
            'und danach wurde es kalt und windig draußen.',
      );
      expect(e.coveredPoints, isEmpty);
      expect(e.coverage, 0);
      expect(e.score, lessThan(45),
          reason: 'length and connectors alone must not carry an answer that '
              'addressed none of the question');
      expect(e.tips.join(' '), contains('Not yet covered'));
      expect(e.tips.join(' '), contains(prompt.expectedPoints.first));
    });

    test('a partial answer is credited partially', () {
      final FreeTalkEvaluation e = ConversationEngine.evaluateFreeTalk(
        promptFor('ft-a1-01'),
        'Ich habe eine Schwester und einen Bruder.',
      );
      expect(e.coveredPoints, hasLength(1));
      expect(e.coverage, closeTo(1 / 3, 0.001));
    });

    test('the rhetorical points at B1 are matched on discourse markers', () {
      final FreeTalkEvaluation e = ConversationEngine.evaluateFreeTalk(
        promptFor('ft-b1-01'),
        'Meiner Meinung nach sollten Schulen Handys verbieten. '
            'Erstens stören sie den Unterricht, zweitens lenken sie ab. '
            'Allerdings brauchen manche Eltern Kontakt zu ihren Kindern. '
            'Insgesamt überwiegen für mich die Vorteile eines Verbots.',
      );
      expect(e.coveredPoints, hasLength(4),
          reason: 'position, arguments, counterargument and conclusion are '
              'each signalled by a marker the learner used');
    });

    test('an opinion with no counterargument is told which move is missing',
        () {
      final FreeTalkEvaluation e = ConversationEngine.evaluateFreeTalk(
        promptFor('ft-b1-01'),
        'Ich finde, Schulen sollten Handys verbieten. Erstens stören sie den '
            'Unterricht und zweitens lenken sie stark ab. Insgesamt bin ich '
            'klar dafür, weil der Unterricht wichtiger ist.',
      );
      expect(e.coveredPoints, contains('Eigene Position'));
      expect(e.coveredPoints, isNot(contains('Gegenargument')));
      expect(e.tips.join(' '), contains('Gegenargument'));
    });
  });

  group('the authored keyword sets', () {
    test('every prompt has one keyword list per content point', () {
      for (final FreeTalkPrompt p in freeTalkPrompts) {
        expect(p.pointKeywords, hasLength(p.expectedPoints.length),
            reason: '${p.id} would silently fall back to counting length');
        for (final List<String> set in p.pointKeywords) {
          expect(set, isNotEmpty, reason: p.id);
        }
      }
    });

    test('every prompt is fully covered by its own model answer', () {
      // The model answer is what the learner is shown as a good response. If
      // it does not satisfy the keywords, the keywords are wrong.
      for (final FreeTalkPrompt p in freeTalkPrompts) {
        final FreeTalkEvaluation e =
            ConversationEngine.evaluateFreeTalk(p, p.modelAnswer);
        expect(e.coveredPoints, hasLength(p.expectedPoints.length),
            reason: '${p.id} model answer misses '
                '${p.expectedPoints.where((String x) => !e.coveredPoints.contains(x)).toList()}');
      }
    });
  });
}
