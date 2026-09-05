import 'package:deutsch_garden/mini_story.dart';
import 'package:deutsch_garden/stories.dart';
import 'package:deutsch_garden/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every reader has one complete mini-story drill', () {
    // 60 narrated readers plus the four ensemble stories added in 4.9,
    // which are written as scenes for two, three, four and five voices.
    expect(stories, hasLength(64));
    expect(allStoryChapters, hasLength(204));
    expect(miniStoryDrills, hasLength(stories.length));
    expect(
      miniStoryDrills.map((drill) => drill.id).toSet(),
      hasLength(miniStoryDrills.length),
    );
    for (final drill in miniStoryDrills) {
      final List<StoryLine> allLines = drill.story.chapters
          .expand<StoryLine>((StoryChapter chapter) => chapter.lines)
          .toList(growable: false);
      expect(drill.transcript, orderedEquals(allLines), reason: drill.id);
      expect(drill.transcript, isNotEmpty, reason: drill.id);
      expect(drill.transcript.length, greaterThan(1), reason: drill.id);
      expect(drill.questions, hasLength(15), reason: drill.id);
      expect(drill.retellPrompts, hasLength(4), reason: drill.id);
      for (final question in drill.questions) {
        expect(question.options.length, greaterThanOrEqualTo(2));
        expect(
          question.correctIndex,
          inInclusiveRange(0, question.options.length - 1),
        );
      }
    }
  });

  test('mini-story audio preserves explicit ensemble voices', () {
    final Story ensemble = stories.firstWhere(
      (Story story) => story.id == 'st-a2-12',
    );
    final List<SpokenTurn> spoken = miniStoryFor(ensemble).spokenTurns;
    expect(
      spoken
          .where((SpokenTurn turn) => turn.voice != GermanVoiceRole.narrator)
          .map((SpokenTurn turn) => turn.voice),
      containsAll(<GermanVoiceRole>[
        GermanVoiceRole.speakerA,
        GermanVoiceRole.speakerB,
        GermanVoiceRole.speakerC,
      ]),
    );
  });
}
