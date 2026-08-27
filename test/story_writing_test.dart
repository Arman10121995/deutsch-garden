import 'package:deutsch_garden/curriculum.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/story_writing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('story retellings complete the 120-task writing track', () {
    expect(storyWritingLessons, hasLength(storyWritingTarget));
    final List<WritingLesson> all = <WritingLesson>[
      for (final CefrLevel level in CefrLevel.values) ...writingFor(level),
    ];
    expect(all, hasLength(120));
    expect(all.map((lesson) => lesson.id).toSet(), hasLength(all.length));
  });

  test('every generated model answer satisfies its transparent rubric', () {
    for (final WritingLesson lesson in storyWritingLessons) {
      final String lower = lesson.example.toLowerCase();
      final int words = lesson.example
          .trim()
          .split(RegExp(r'\s+'))
          .where((String value) => value.isNotEmpty)
          .length;
      expect(words, greaterThanOrEqualTo(lesson.minWords), reason: lesson.id);
      expect(lesson.keywords, hasLength(4), reason: lesson.id);
      for (final String keyword in lesson.keywords) {
        expect(lower, contains(keyword), reason: '${lesson.id}: $keyword');
      }
    }
  });
}
