import 'package:deutsch_garden/radio.dart';
import 'package:deutsch_garden/radio_ensemble.dart';
import 'package:deutsch_garden/tts_service.dart';
import 'package:flutter_test/flutter_test.dart';

int speakersIn(RadioEpisode episode) =>
    episode.lines.map((RadioLine l) => l.voice).toSet().length;

void main() {
  group('the ensemble programmes', () {
    test('cover two, three, four and five speakers', () {
      // The point of writing them. Anything less and the extra voices are
      // bundled but never heard.
      final Set<int> counts =
          radioEnsembleEpisodes.map(speakersIn).toSet();
      expect(counts, containsAll(<int>[2, 3, 4, 5]),
          reason: 'got $counts');
    });

    test('every voice used maps to a distinct speaking role', () {
      for (final RadioEpisode episode in radioEnsembleEpisodes) {
        final Set<RadioVoice> voices =
            episode.lines.map((RadioLine l) => l.voice).toSet();
        final Set<GermanVoiceRole> roles =
            voices.map((RadioVoice v) => v.role).toSet();
        expect(roles, hasLength(voices.length),
            reason: '${episode.id} collapses two voices onto one role');
      }
    });

    test('the host is always the narrator role', () {
      // A listener has to be able to tell the programme's own voice from the
      // people it is talking to.
      expect(RadioVoice.host.role, GermanVoiceRole.narrator);
      for (final RadioEpisode episode in radioEnsembleEpisodes) {
        final Iterable<RadioLine> hostLines = episode.lines
            .where((RadioLine l) => l.voice == RadioVoice.host);
        expect(hostLines, isNotEmpty, reason: '${episode.id} has no host');
      }
    });

    test('they survive into the built library with their voices intact', () {
      // The library is generated from seeds, and a builder that rewrote the
      // lines would silently flatten every speaker back to one.
      for (final RadioEpisode seed in radioEnsembleEpisodes) {
        final RadioEpisode built =
            radioEpisodes.firstWhere((RadioEpisode e) => e.id == seed.id);
        expect(speakersIn(built), speakersIn(seed),
            reason: '${seed.id} lost speakers when the library was built');
      }
    });

    test('every line has both German and English', () {
      for (final RadioEpisode episode in radioEnsembleEpisodes) {
        for (final RadioLine line in episode.lines) {
          expect(line.german.trim(), isNotEmpty, reason: episode.id);
          expect(line.english.trim(), isNotEmpty, reason: episode.id);
        }
      }
    });

    test('speakers are distinguishable by content, not only by voice', () {
      // The honest fallback: on a phone whose engine has one German voice,
      // pitch is all that separates two speakers. A learner who cannot hear
      // that difference must still be able to follow who is talking, so each
      // programme names or characterises its participants in the script.
      for (final RadioEpisode episode in radioEnsembleEpisodes) {
        final String script =
            episode.lines.map((RadioLine l) => l.german).join(' ');
        expect(script.length, greaterThan(120), reason: episode.id);
        // Somebody is introduced, addressed by name, or self-identified.
        expect(
          RegExp(r'(ich heiße|ich bin |wir hören|frau |herr |'
                  r'begrüße|gäste|gast|ich rufe|im studio)')
              .hasMatch(script.toLowerCase()),
          isTrue,
          reason: '${episode.id} never says who is speaking',
        );
      }
    });
  });
}
