import 'dart:math';

import 'package:deutsch_garden/driving_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the original Class B bank covers every subject area', () {
    expect(DrivingTheoryCatalog.questions, hasLength(72));
    expect(
      DrivingTheoryCatalog.questions.every(
        (DrivingQuestion question) => question.isUsable,
      ),
      isTrue,
    );
    expect(
      DrivingTheoryCatalog.questions
          .map((DrivingQuestion question) => question.id)
          .toSet(),
      hasLength(72),
    );
    expect(
      DrivingTheoryCatalog.questions
          .map((DrivingQuestion question) => question.category)
          .toSet(),
      hasLength(8),
    );
  });

  test('question shuffling keeps German and English options paired', () {
    final DrivingQuestion original = DrivingTheoryCatalog.questions.first;
    final DrivingQuestion shuffled = original.shuffled(Random(20260902));
    expect(shuffled.options, hasLength(4));
    expect(shuffled.correctOption.german, original.correctOption.german);
    expect(shuffled.correctOption.english, original.correctOption.english);
    for (final DrivingOption option in shuffled.options) {
      final DrivingOption source = original.options.firstWhere(
        (DrivingOption item) => item.german == option.german,
      );
      expect(option.english, source.english);
    }
  });

  test(
    'mock generation is deterministic and reports official-style errors',
    () {
      final DrivingMock first = DrivingTheoryCatalog.buildMock(seed: 17);
      final DrivingMock again = DrivingTheoryCatalog.buildMock(seed: 17);
      expect(first.questions, hasLength(30));
      expect(
        first.questions.map((DrivingQuestion q) => q.id).toList(),
        again.questions.map((DrivingQuestion q) => q.id).toList(),
      );
      final Map<String, int> answers = <String, int>{
        for (final DrivingQuestion question in first.questions)
          question.id: question.correctIndex,
      };
      final DrivingTestResult perfect = first.score(answers);
      expect(perfect.correct, 30);
      expect(perfect.errorPoints, 0);
      expect(perfect.passed, isTrue);

      final DrivingQuestion fivePoint = first.questions.firstWhere(
        (DrivingQuestion question) => question.points == 5,
      );
      final Map<String, int> oneError = Map<String, int>.of(answers)
        ..[fivePoint.id] = (fivePoint.correctIndex + 1) % 4;
      expect(first.score(oneError).passed, isTrue);
    },
  );
}
