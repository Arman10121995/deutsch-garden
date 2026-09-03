import 'package:deutsch_garden/dialogue_audio.dart';
import 'package:deutsch_garden/stories.dart';
import 'package:deutsch_garden/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// How many distinct voices a chapter would actually be read in.
int voicesIn(StoryChapter chapter) => storySpokenTurns(
      chapter.lines.map((StoryLine line) => line.german),
    ).map((SpokenTurn t) => t.voice).toSet().length;

void main() {
  ensembleChecks();
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

// ---------------------------------------------------------------------------
// The ensemble stories, written as scenes rather than narration.
// ---------------------------------------------------------------------------

void ensembleChecks() {
  group('the ensemble stories', () {
    List<StoryChapter> chaptersOf(String storyId) => stories
        .firstWhere((Story s) => s.id == storyId)
        .chapters;

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
        final int voices = storyTurnsFromLines(
          chapter.lines.map(
            (StoryLine line) => (german: line.german, voice: line.voice),
          ),
        ).map((SpokenTurn t) => t.voice).toSet().length;
        expect(voices, entry.value,
            reason: '${entry.key} should be read in ${entry.value} voices');
      }
    });

    test('a two-person exchange is not read as four people', () {
      // The 4.8.0 regression: cycling the cast handed a new voice to every
      // quotation rather than to every speaker, so a bakery conversation
      // between two people came out in four voices.
      final List<SpokenTurn> turns = storySpokenTurns(<String>[
        '„Guten Morgen!“, sagt sie. „Guten Morgen“, antwortet er.',
        '„Was möchten Sie?“ „Zwei Brötchen, bitte.“',
      ]);
      final Set<GermanVoiceRole> spoken = turns
          .map((SpokenTurn t) => t.voice)
          .where((GermanVoiceRole v) => v != GermanVoiceRole.narrator)
          .toSet();
      expect(spoken, hasLength(2),
          reason: 'quoted speech alternates between two people');
    });

    test('each names its speakers in the prose', () {
      // On a phone whose engine has one German voice, pitch is all that
      // separates two people. A learner who cannot hear that must still be
      // able to follow who is talking.
      for (final String id in <String>[
        'st-a1-12', 'st-a2-12', 'st-b1-12', 'st-b2-11',
      ]) {
        final String text = chaptersOf(id)
            .single
            .lines
            .map((StoryLine l) => l.german)
            .join(' ');
        expect(RegExp(r'[A-ZÄÖÜ][a-zäöüß]{2,}').hasMatch(text), isTrue,
            reason: '$id never names anybody');
      }
    });

    test('every line keeps both German and English', () {
      for (final String id in <String>[
        'st-a1-12', 'st-a2-12', 'st-b1-12', 'st-b2-11',
      ]) {
        for (final StoryLine line in chaptersOf(id).single.lines) {
          expect(line.german.trim(), isNotEmpty, reason: id);
          expect(line.english.trim(), isNotEmpty, reason: id);
        }
      }
    });
  });
}
