import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/radio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gartenradio episodes', () {
    test('every episode has a unique id', () {
      final Set<String> ids = radioEpisodes
          .map((RadioEpisode e) => e.id)
          .toSet();
      expect(ids.length, radioEpisodes.length);
    });

    test('every episode has lines and questions', () {
      for (final RadioEpisode episode in radioEpisodes) {
        expect(
          episode.lines,
          isNotEmpty,
          reason: '${episode.id} has no script',
        );
        expect(
          episode.questions,
          hasLength(5),
          reason:
              '${episode.id} needs three listening and two comprehension questions',
        );
        expect(
          episode.listenPrompts,
          hasLength(3),
          reason: '${episode.id} needs three listen-and-select prompts',
        );
        expect(
          episode.matchingPairs,
          hasLength(5),
          reason: '${episode.id} needs one five-pair matching checkpoint',
        );
        expect(
          episode.checkpointCount,
          6,
          reason: '${episode.id} must expose six checkpoint blocks',
        );
        expect(episode.title.trim(), isNotEmpty);
      }
    });

    test('the library has the planned 120-episode CEFR distribution', () {
      const Map<CefrLevel, int> expected = <CefrLevel, int>{
        CefrLevel.a1: 30,
        CefrLevel.a2: 30,
        CefrLevel.b1: 25,
        CefrLevel.b2: 20,
        CefrLevel.c1: 10,
        CefrLevel.c2: 5,
      };
      expect(radioEpisodeCount, 120);
      for (final MapEntry<CefrLevel, int> target in expected.entries) {
        expect(
          radioFor(target.key),
          hasLength(target.value),
          reason: '${target.key.label} distribution drifted',
        );
      }
      expect(
        radioEpisodes.fold<int>(
          0,
          (int total, RadioEpisode episode) => total + episode.checkpointCount,
        ),
        720,
      );
    });

    test('every line carries both German and English', () {
      // The English is what makes the transcript usable as a fallback on a
      // platform where the voice disappoints, so it is required even at the
      // levels that hide it by default.
      for (final RadioEpisode episode in radioEpisodes) {
        for (final RadioLine line in episode.lines) {
          expect(line.german.trim(), isNotEmpty, reason: episode.id);
          expect(line.english.trim(), isNotEmpty, reason: episode.id);
          expect(
            line.german.trim().substring(line.german.trim().length - 1),
            anyOf('.', '!', '?'),
            reason: '${episode.id}: a line has no sentence punctuation',
          );
        }
      }
    });

    test('every question is answerable and its answer is in range', () {
      for (final RadioEpisode episode in radioEpisodes) {
        for (final ChoiceQuestion q in episode.questions) {
          expect(q.options.length, greaterThanOrEqualTo(2), reason: episode.id);
          expect(q.correctIndex, greaterThanOrEqualTo(0), reason: episode.id);
          expect(
            q.correctIndex,
            lessThan(q.options.length),
            reason: '${episode.id}: correctIndex is out of range',
          );
          expect(q.prompt.trim(), isNotEmpty);
          expect(
            q.explanation.trim(),
            isNotEmpty,
            reason: '${episode.id}: an answer has no explanation',
          );
          expect(
            q.options.toSet().length,
            q.options.length,
            reason: '${episode.id}: a question repeats an option',
          );
        }
      }
    });

    test('listening prompts and matching pairs are real and unique', () {
      for (final RadioEpisode episode in radioEpisodes) {
        for (final String prompt in episode.listenPrompts) {
          expect(prompt.trim(), isNotEmpty, reason: episode.id);
          expect(
            episode.transcript,
            contains(prompt),
            reason: '${episode.id}: spoken prompt is absent from transcript',
          );
        }
        expect(
          episode.matchingPairs
              .map((RadioMatchPair pair) => pair.german)
              .toSet(),
          hasLength(5),
          reason: '${episode.id}: repeated German matching item',
        );
        expect(
          episode.matchingPairs
              .map((RadioMatchPair pair) => pair.english)
              .toSet(),
          hasLength(5),
          reason: '${episode.id}: repeated English matching item',
        );
      }
    });

    test('every transcript is a substantive two-to-three-minute script', () {
      for (final RadioEpisode episode in radioEpisodes) {
        expect(episode.transcript, contains(episode.lines.first.german));
        final int words = episode.transcript
            .split(RegExp(r'\s+'))
            .where((String token) => token.isNotEmpty)
            .length;
        // Three minutes at the measured pace of the bundled voice, which is
        // about 2.6 words a second for dense prose. The ceiling used to be
        // 400, derived from a pace constant of 1.7 that measurement showed to
        // be wrong by more than half; 400 words is 154 seconds, not the three
        // minutes it was meant to represent.
        //
        // The floor is deliberately left where it is and is looser than the
        // name of this test implies: 250 words is about a minute and forty
        // seconds, and 77 of the 120 episodes sit between 250 and 310. Raising
        // it to a true two minutes is a content job -- lengthening most of the
        // library -- not a number to change here.
        expect(
          words,
          inInclusiveRange(250, 460),
          reason: '${episode.id} has $words German words',
        );
      }
    });

    test(
      'titles, transcripts and the great majority of lines are distinct',
      () {
        expect(
          radioEpisodes.map((RadioEpisode episode) => episode.title).toSet(),
          hasLength(radioEpisodeCount),
        );
        expect(
          radioEpisodes
              .map((RadioEpisode episode) => episode.transcript)
              .toSet(),
          hasLength(radioEpisodeCount),
        );
        final List<String> lines = <String>[
          for (final RadioEpisode episode in radioEpisodes)
            for (final RadioLine line in episode.lines) line.german,
        ];
        expect(
          lines.toSet().length / lines.length,
          greaterThan(0.80),
          reason: 'The library is repeating too many whole lines',
        );
      },
    );

    test('radioFor returns only that level', () {
      for (final CefrLevel level in CefrLevel.values) {
        for (final RadioEpisode episode in radioFor(level)) {
          expect(episode.level, level);
        }
      }
    });
  });
}
