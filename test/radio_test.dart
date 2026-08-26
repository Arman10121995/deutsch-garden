import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/radio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gartenradio episodes', () {
    test('every episode has a unique id', () {
      final Set<String> ids =
          radioEpisodes.map((RadioEpisode e) => e.id).toSet();
      expect(ids.length, radioEpisodes.length);
    });

    test('every episode has lines and questions', () {
      for (final RadioEpisode episode in radioEpisodes) {
        expect(episode.lines, isNotEmpty, reason: '${episode.id} has no script');
        expect(episode.questions, isNotEmpty,
            reason: '${episode.id} has no questions');
        expect(episode.title.trim(), isNotEmpty);
      }
    });

    test('every line carries both German and English', () {
      // The English is what makes the transcript usable as a fallback on a
      // platform where the voice disappoints, so it is required even at the
      // levels that hide it by default.
      for (final RadioEpisode episode in radioEpisodes) {
        for (final RadioLine line in episode.lines) {
          expect(line.german.trim(), isNotEmpty, reason: episode.id);
          expect(line.english.trim(), isNotEmpty, reason: episode.id);
          expect(line.german.trim().substring(line.german.trim().length - 1),
              anyOf('.', '!', '?'),
              reason: '${episode.id}: a line has no sentence punctuation');
        }
      }
    });

    test('every question is answerable and its answer is in range', () {
      for (final RadioEpisode episode in radioEpisodes) {
        for (final ChoiceQuestion q in episode.questions) {
          expect(q.options.length, greaterThanOrEqualTo(2), reason: episode.id);
          expect(q.correctIndex, greaterThanOrEqualTo(0), reason: episode.id);
          expect(q.correctIndex, lessThan(q.options.length),
              reason: '${episode.id}: correctIndex is out of range');
          expect(q.prompt.trim(), isNotEmpty);
          expect(q.explanation.trim(), isNotEmpty,
              reason: '${episode.id}: an answer has no explanation');
          expect(q.options.toSet().length, q.options.length,
              reason: '${episode.id}: a question repeats an option');
        }
      }
    });

    test('the transcript joins the script and reports a plausible length', () {
      for (final RadioEpisode episode in radioEpisodes) {
        expect(episode.transcript, contains(episode.lines.first.german));
        expect(episode.approximateSeconds, greaterThan(10),
            reason: '${episode.id} is implausibly short');
        expect(episode.approximateSeconds, lessThan(600),
            reason: '${episode.id} is implausibly long');
      }
    });

    test('radioFor returns only that level', () {
      for (final CefrLevel level in CefrLevel.values) {
        for (final RadioEpisode episode in radioFor(level)) {
          expect(episode.level, level);
        }
      }
    });

    test('the library spans at least the lower levels', () {
      expect(radioFor(CefrLevel.a1), isNotEmpty);
      expect(radioFor(CefrLevel.a2), isNotEmpty);
      expect(radioEpisodeCount, greaterThanOrEqualTo(8));
    });
  });
}
