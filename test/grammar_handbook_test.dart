import 'package:deutsch_garden/curriculum.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every CEFR level has grammar lessons available for the handbook', () {
    final allLessons = CefrLevel.values
        .expand((level) => grammarFor(level))
        .toList();
    expect(allLessons.length, 96);
    for (final level in CefrLevel.values) {
      final list = grammarFor(level);
      expect(list.length, 16, reason: '${level.label} must have 16 grammar lessons');
    }
  });

  test('grammar lesson explanations and questions are complete', () {
    final allLessons = CefrLevel.values
        .expand((level) => grammarFor(level))
        .toList();
    for (final lesson in allLessons) {
      expect(lesson.title.trim(), isNotEmpty);
      expect(lesson.explanation.trim(), isNotEmpty);
      expect(lesson.examples, isNotEmpty);
      expect(lesson.questions, isNotEmpty);
      for (final q in lesson.questions) {
        expect(q.prompt.trim(), isNotEmpty);
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
      }
    }
  });
}
