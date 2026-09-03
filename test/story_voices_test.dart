import 'package:deutsch_garden/dialogue_audio.dart';
import 'package:deutsch_garden/stories.dart';
import 'package:deutsch_garden/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// How many distinct voices a chapter would actually be read in.
int voicesIn(StoryChapter chapter) => storySpokenTurns(
      chapter.lines.map((StoryLine line) => line.german),
    ).map((SpokenTurn t) => t.voice).toSet().length;

void main() {
  group('how many voices a story chapter is read in', () {
    test('most chapters currently use only the narrator', () {
      // The measurement behind the "I can only hear one speaker" report.
      // storySpokenTurns gives a character voice only to text inside German
      // quotation marks, and the corpus is overwhelmingly narration: 13.5% of
      // lines carry a quote at all.
      int single = 0;
      int total = 0;
      for (final Story story in stories) {
        for (final StoryChapter chapter in story.chapters) {
          total += 1;
          if (voicesIn(chapter) <= 1) single += 1;
        }
      }
      expect(total, greaterThan(0));
      // Pinned as a fact, not as an aspiration: this is what the app does
      // today and the number is what makes the complaint reasonable.
      expect(single / total, greaterThan(0.5),
          reason: 'if this drops, the corpus gained direct speech and this '
              'test should be re-read rather than adjusted');
    });

    test('a chapter with dialogue does use more than one voice', () {
      final Iterable<StoryChapter> withSpeech = <StoryChapter>[
        for (final Story story in stories)
          for (final StoryChapter chapter in story.chapters)
            if (chapter.lines.any((StoryLine l) =>
                l.german.contains('„') || l.german.contains('"')))
              chapter,
      ];
      expect(withSpeech, isNotEmpty,
          reason: 'the corpus does contain quoted speech somewhere');
      for (final StoryChapter chapter in withSpeech) {
        expect(voicesIn(chapter), greaterThan(1), reason: chapter.id);
      }
    });
  });
}
