import 'package:deutsch_garden/curriculum.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/story_writing.dart';
import 'package:deutsch_garden/writing_evaluation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final WritingLesson sampleLesson = writingLessons.first;

  group('WritingEvaluator basic requirements', () {
    test('pronouns, adjective chains and ordinary verbs stay lowercase', () {
      final eval = WritingEvaluator.evaluate(
        sampleLesson,
        'Das ist gut. Die neue kleine Wohnung ist hell. '
        'Die Menschen, die reisen, fragen mich. Wir reisen morgen. '
        'Ich werde fernsehen und gehe danach weg.',
      );
      expect(eval.capitalizationErrors, isEmpty);
    });

    test('noun homographs are checked when the context is clearly nominal', () {
      final eval = WritingEvaluator.evaluate(
        sampleLesson,
        'Beim essen lesen wir. Am morgen trinken wir Kaffee. '
        'Meine fragen sind wichtig.',
      );
      expect(
        eval.capitalizationErrors,
        containsAll(<String>['essen', 'morgen', 'fragen']),
      );
    });

    test('a short target must be a word rather than part of another word', () {
      const lesson = WritingLesson(
        id: 'word-boundaries',
        level: CefrLevel.a1,
        title: 'Colours',
        prompt: '',
        guidance: <String>[],
        minWords: 10,
        keywords: <String>['rot', 'und'],
        example: '',
      );
      final eval = WritingEvaluator.evaluate(
        lesson,
        'Ich esse Brot. Der Hund schläft.',
      );
      expect(eval.matchedKeywords, isEmpty);
      expect(eval.missingKeywords, lesson.keywords);
    });

    test('every word of a target phrase has to occur together', () {
      const lesson = WritingLesson(
        id: 'phrase-boundaries',
        level: CefrLevel.a1,
        title: 'Plans',
        prompt: '',
        guidance: <String>[],
        minWords: 10,
        keywords: <String>['ich habe vor'],
        example: '',
      );
      expect(
        WritingEvaluator.evaluate(lesson, 'Ich habe Zeit.').matchedKeywords,
        isEmpty,
      );
      expect(
        WritingEvaluator.evaluate(
          lesson,
          'Ich habe vor, morgen zu reisen.',
        ).matchedKeywords,
        lesson.keywords,
      );
    });

    test('punctuation does not add words or hide sentence capitalization', () {
      final eval = WritingEvaluator.evaluate(
        sampleLesson,
        '„ich wohne hier.“ !!!',
      );
      expect(eval.wordCount, 3);
      expect(eval.sentenceCapitalizationErrors, 1);
    });

    test('an empty text gives 0 score and helpful guidance', () {
      final WritingAttemptEvaluation eval = WritingEvaluator.evaluate(
        sampleLesson,
        '',
      );
      expect(eval.score, 0);
      expect(eval.wordCount, 0);
      expect(eval.passed, isFalse);
      expect(eval.missingKeywords, sampleLesson.keywords);
      expect(eval.tips.isNotEmpty, isTrue);
    });

    test('detects sentence capitalization errors', () {
      const String text = 'ich wohne hier. das ist schön.';
      final WritingAttemptEvaluation eval = WritingEvaluator.evaluate(
        sampleLesson,
        text,
      );
      expect(eval.sentenceCapitalizationErrors, greaterThanOrEqualTo(1));
      expect(eval.tips.join(' '), contains('begins with a capital letter'));
    });

    test('detects German noun capitalization errors', () {
      const String text = 'Ich habe ein haus und einen hund im garten.';
      final WritingAttemptEvaluation eval = WritingEvaluator.evaluate(
        sampleLesson,
        text,
      );
      expect(eval.capitalizationErrors, contains('haus'));
      expect(eval.capitalizationErrors, contains('hund'));
      expect(eval.capitalizationErrors, contains('garten'));
      expect(eval.tips.join(' '), contains('Capitalize German nouns'));
    });

    test('penalizes repetitive spam or keyword stuffing', () {
      const String repetitiveText =
          'ich wohne wohne wohne wohne wohne wohne wohne wohne wohne '
          'wohne wohne wohne wohne wohne wohne wohne wohne wohne wohne '
          'wohne wohne wohne wohne wohne wohne wohne wohne wohne wohne.';
      final WritingAttemptEvaluation eval = WritingEvaluator.evaluate(
        sampleLesson,
        repetitiveText,
      );
      expect(eval.mechanicsScore, lessThan(50));
      expect(eval.passed, isFalse);
    });

    test('identifies connectors across CEFR bands', () {
      const String textWithConnectors =
          'Ich wohne in Berlin, aber ich arbeite in Potsdam, weil es dort ruhiger ist. '
          'Deshalb fahre ich jeden Tag mit dem Zug.';
      final WritingAttemptEvaluation eval = WritingEvaluator.evaluate(
        sampleLesson,
        textWithConnectors,
      );
      expect(eval.connectorsUsed, contains('aber'));
      expect(eval.connectorsUsed, contains('weil'));
      expect(eval.connectorsUsed, contains('deshalb'));
    });

    test('matches inflected keywords using German stemmer', () {
      // Lesson keyword might be "wohne" or "arbeite", let's test with sample lesson
      final WritingAttemptEvaluation eval = WritingEvaluator.evaluate(
        sampleLesson,
        sampleLesson.example,
      );
      expect(eval.matchedKeywords.length, sampleLesson.keywords.length);
      expect(eval.missingKeywords, isEmpty);
      expect(eval.passed, isTrue);
      expect(eval.score, greaterThanOrEqualTo(75));
    });
  });

  group('Curriculum model answers satisfy WritingEvaluator', () {
    test('story writing lessons pass their own evaluation', () {
      for (final WritingLesson lesson in storyWritingLessons) {
        final WritingAttemptEvaluation eval = WritingEvaluator.evaluate(
          lesson,
          lesson.example,
        );
        expect(
          eval.passed,
          isTrue,
          reason:
              'Story writing lesson ${lesson.id} failed evaluator: score ${eval.score}',
        );
        expect(eval.score, greaterThanOrEqualTo(70));
      }
    });

    test('a fully developed C1 response achieves a high passing score', () {
      final WritingLesson c1Lesson = writingLessons.firstWhere(
        (l) => l.id == 'wr-c1-01',
      );
      const String fullAnswer =
          'Automatisierte Auswahlverfahren können Prozesse in Unternehmen deutlich beschleunigen '
          'und Entscheidungen konsistenter machen. Einerseits bietet der Einsatz moderner '
          'Algorithmen das Potenzial, menschliche Voreingenommenheit bei der ersten Sichtung '
          'zu reduzieren. Andererseits ist rein technische Konsistenz keineswegs mit echter '
          'Fairness gleichzusetzen. Werden historische Daten verwendet, die bereits strukturelle '
          'Benachteiligungen widerspiegeln, so reproduziert das System diese Ungleichheiten '
          'in automatisierter Form. Eine ethisch verantwortungsvolle Einführung setzt daher '
          'vollkommen transparente Kriterien, regelmäßige unabhängige Prüfungen und wirksame '
          'menschliche Kontrollmöglichkeiten voraus. Zudem müssen klare Beschwerdewege existieren.';
      final WritingAttemptEvaluation eval = WritingEvaluator.evaluate(
        c1Lesson,
        fullAnswer,
      );
      expect(eval.passed, isTrue);
      expect(eval.score, greaterThanOrEqualTo(70));
      expect(eval.missingKeywords, isEmpty);
      expect(eval.connectorsUsed, contains('einerseits'));
      expect(eval.connectorsUsed, contains('andererseits'));
    });
  });
}
