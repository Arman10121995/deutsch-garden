import 'package:deutsch_garden/speaking_curriculum.dart';
import 'package:deutsch_garden/speaking_evaluation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lesson = speakingLessons.first;

  test('an empty transcript cannot complete a speaking lesson', () {
    final result = SpeakingEvaluator.evaluate(lesson, '');
    expect(result.score, 0);
    expect(result.wordCount, 0);
  });

  test(
    'feedback rewards useful language without requiring an exact script',
    () {
      final result = SpeakingEvaluator.evaluate(
        lesson,
        'Ich heiße Amina und ich komme aus Marokko. Jetzt wohne ich in Berlin. '
        'Ich arbeite in einem Büro, aber in meiner Freizeit lese ich gern und '
        'spiele Fußball.',
      );

      expect(result.wordCount, greaterThanOrEqualTo(result.targetWords));
      expect(result.phrasesCovered, greaterThanOrEqualTo(3));
      expect(result.connectors, contains('aber'));
      expect(result.score, greaterThanOrEqualTo(75));
    },
  );

  test('short transcripts receive concrete next-step feedback', () {
    final result = SpeakingEvaluator.evaluate(lesson, 'Ich heiße Amina.');
    expect(result.score, lessThan(70));
    expect(result.tips.join(' '), contains('Build toward about'));
  });
}
