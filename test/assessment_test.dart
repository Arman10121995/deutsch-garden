import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_garden/assessment.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/test_prep.dart';

void main() {
  test('placement instrument has six valid items per CEFR band', () {
    expect(
      placementQuestions.map((question) => question.id).toSet().length,
      placementQuestions.length,
    );
    for (final level in CefrLevel.values) {
      final items = placementQuestionsFor(level);
      expect(items.length, 6);
      expect(items.map((item) => item.domain).toSet().length, 4);
      for (final item in items) {
        expect(item.options.length, greaterThanOrEqualTo(3));
        expect(item.correctIndex, inInclusiveRange(0, item.options.length - 1));
      }
    }
  });

  test('each level has an exam profile and two original mini mocks', () {
    for (final level in CefrLevel.values) {
      final profile = examProfileFor(level);
      expect(profile.level, level);
      expect(profile.readingMinutes, greaterThan(0));
      expect(profile.listeningMinutes, greaterThan(0));
      expect(profile.writingMinutes, greaterThan(0));
      expect(profile.speakingMinutes, greaterThan(0));
      final mocks = examSetsFor(level);
      expect(mocks.length, 2);
      for (final mock in mocks) {
        expect(mock.objectiveQuestions.length, greaterThanOrEqualTo(4));
        expect(mock.writingPrompt, isNotEmpty);
        expect(mock.speakingPrompt, isNotEmpty);
      }
    }
  });
}
