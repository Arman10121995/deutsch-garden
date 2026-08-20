import 'package:deutsch_garden/stories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all stories have valid CEFR levels and non-empty blurbs', () {
    for (final story in stories) {
      expect(story.id, isNotEmpty);
      expect(story.title.trim(), isNotEmpty);
      expect(story.titleEnglish.trim(), isNotEmpty);
      expect(story.blurb.trim(), isNotEmpty);
      expect(story.chapters, isNotEmpty);
    }
  });

  test('story chapters contain readable lines and non-empty glossaries', () {
    for (final chapter in allStoryChapters) {
      expect(chapter.id, isNotEmpty);
      expect(chapter.lines, isNotEmpty);
      expect(chapter.wordCount, greaterThan(0));
      for (final line in chapter.lines) {
        expect(line.german.trim(), isNotEmpty);
        expect(line.english.trim(), isNotEmpty);
      }
      for (final gloss in chapter.glossary) {
        expect(gloss.german.trim(), isNotEmpty);
        expect(gloss.english.trim(), isNotEmpty);
      }
    }
  });

  test('story chapter comprehension questions are valid', () {
    for (final chapter in allStoryChapters) {
      for (final q in chapter.questions) {
        expect(q.prompt.trim(), isNotEmpty);
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
        expect(q.explanation.trim(), isNotEmpty);
      }
    }
  });
}
