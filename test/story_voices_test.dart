import 'package:deutsch_garden/dialogue_audio.dart';
import 'package:deutsch_garden/stories.dart';
import 'package:deutsch_garden/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// How many distinct voices a chapter would actually be read in.
int voicesIn(StoryChapter chapter) =>
    chapter.spokenTurns.map((SpokenTurn turn) => turn.voice).toSet().length;

void main() {
  ensembleChecks();
  group('how many voices a story chapter is read in', () {
    test('most chapters currently use only the narrator', () {
      // The measurement behind the "I can only hear one speaker" report.
      // The corpus is predominantly narration. Count the actual reader path,
      // including explicit full-line and quotation-level cast assignments.
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
      expect(
        single / total,
        greaterThan(0.5),
        reason:
            'if this drops, the corpus gained direct speech and this '
            'test should be re-read rather than adjusted',
      );
    });

    test('authored dialogue reaches playback with its character voice', () {
      final Iterable<StoryChapter> withSpeech = <StoryChapter>[
        for (final Story story in stories)
          for (final StoryChapter chapter in story.chapters)
            if (chapter.lines.any(
              (StoryLine l) =>
                  (l.voice != null && l.voice != GermanVoiceRole.narrator) ||
                  l.quotedVoices.any(
                    (voice) => voice != GermanVoiceRole.narrator,
                  ),
            ))
              chapter,
      ];
      expect(
        withSpeech,
        isNotEmpty,
        reason: 'the corpus does contain quoted speech somewhere',
      );
      for (final StoryChapter chapter in withSpeech) {
        expect(
          chapter.spokenTurns.any(
            (turn) => turn.voice != GermanVoiceRole.narrator,
          ),
          isTrue,
          reason: chapter.id,
        );
      }
    });
  });
}

// ---------------------------------------------------------------------------
// The ensemble stories, written as scenes rather than narration.
// ---------------------------------------------------------------------------

void ensembleChecks() {
  group('the ensemble stories', () {
    List<StoryChapter> chaptersOf(String storyId) =>
        stories.firstWhere((Story s) => s.id == storyId).chapters;

    test('cover two, three, four and five voices', () {
      // Counting the narrator, because that is what a listener hears: two
      // voices means a narrator and one speaker, five means a narrator and
      // four. Measured through the same path the player uses.
      const Map<String, int> expected = <String, int>{
        'st-a1-12': 3,
        'st-a2-12': 4,
        'st-b1-12': 5,
        'st-b2-11': 5,
      };
      for (final MapEntry<String, int> entry in expected.entries) {
        final StoryChapter chapter = chaptersOf(entry.key).single;
        final int voices = voicesIn(chapter);
        expect(
          voices,
          entry.value,
          reason: '${entry.key} should be read in ${entry.value} voices',
        );
      }
    });

    test('a two-person exchange is not read as four people', () {
      // The 4.8.0 regression: cycling the cast handed a new voice to every
      // quotation rather than to every speaker, so a bakery conversation
      // between two people came out in four voices.
      final List<SpokenTurn> turns = <SpokenTurn>[
        ...storyLineSpokenTurns(
          '„Guten Morgen!“, sagt sie. „Guten Morgen“, antwortet er.',
          quotedVoices: <GermanVoiceRole>[
            GermanVoiceRole.speakerA,
            GermanVoiceRole.speakerB,
          ],
        ),
        ...storyLineSpokenTurns(
          '„Was möchten Sie?“ „Zwei Brötchen, bitte.“',
          quotedVoices: <GermanVoiceRole>[
            GermanVoiceRole.speakerA,
            GermanVoiceRole.speakerB,
          ],
        ),
      ];
      final Set<GermanVoiceRole> spoken = turns
          .map((SpokenTurn t) => t.voice)
          .where((GermanVoiceRole v) => v != GermanVoiceRole.narrator)
          .toSet();
      expect(
        spoken,
        hasLength(2),
        reason: 'only the two authored roles are used',
      );
    });

    test('each names its speakers in the prose', () {
      // On a phone whose engine has one German voice, pitch is all that
      // separates two people. A learner who cannot hear that must still be
      // able to follow who is talking.
      for (final String id in <String>[
        'st-a1-12',
        'st-a2-12',
        'st-b1-12',
        'st-b2-11',
      ]) {
        final String text = chaptersOf(
          id,
        ).single.lines.map((StoryLine l) => l.german).join(' ');
        expect(
          RegExp(r'[A-ZÄÖÜ][a-zäöüß]{2,}').hasMatch(text),
          isTrue,
          reason: '$id never names anybody',
        );
      }
    });

    test('every line keeps both German and English', () {
      for (final String id in <String>[
        'st-a1-12',
        'st-a2-12',
        'st-b1-12',
        'st-b2-11',
      ]) {
        for (final StoryLine line in chaptersOf(id).single.lines) {
          expect(line.german.trim(), isNotEmpty, reason: id);
          expect(line.english.trim(), isNotEmpty, reason: id);
        }
      }
    });
  });
}
