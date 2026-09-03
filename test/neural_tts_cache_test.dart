import 'package:deutsch_garden/neural_tts_cache.dart';
import 'package:deutsch_garden/neural_voice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cache names are deterministic and sensitive to text and rate', () {
    final String first = neuralTtsCacheFileName('Grüße aus Köln.', 1.0);
    expect(neuralTtsCacheFileName('Grüße aus Köln.', 1.0), first);
    expect(neuralTtsCacheFileName('Grüße aus Köln!', 1.0), isNot(first));
    expect(neuralTtsCacheFileName('Grüße aus Köln.', 0.75), isNot(first));
    expect(
      first,
      matches(RegExp(r'^thorsten-utterance-[0-9a-f]{16}-100\.wav$')),
    );
    expect(
      neuralTtsCacheFileName('Grüße aus Köln.', 1.0, voice: 'kerstin'),
      isNot(first),
    );
    for (var i = 0; i < 1000; i++) {
      expect(
        neuralTtsCacheFileName('Satz Nummer $i mit Umlaut ä.', 1.0),
        matches(RegExp(r'^thorsten-utterance-[0-9a-f]{16}-100\.wav$')),
      );
    }
  });

  test('only a RIFF/WAVE header is accepted', () {
    expect(
      hasWaveHeader(<int>[
        0x52,
        0x49,
        0x46,
        0x46,
        0,
        0,
        0,
        0,
        0x57,
        0x41,
        0x56,
        0x45,
      ]),
      isTrue,
    );
    expect(hasWaveHeader(<int>[0x52, 0x49, 0x46, 0x46]), isFalse);
    expect(
      hasWaveHeader(<int>[
        0x52,
        0x49,
        0x46,
        0x46,
        0,
        0,
        0,
        0,
        0x4e,
        0x4f,
        0x50,
        0x45,
      ]),
      isFalse,
    );
  });

  test('programme cache includes order, voices, rate, and pause lengths', () {
    const List<NeuralTurn> turns = <NeuralTurn>[
      NeuralTurn('Guten Morgen.', voice: NeuralVoice.narrator),
      NeuralTurn('Hallo!', voice: NeuralVoice.speakerA),
    ];
    final String first = neuralTtsPlaylistCacheFileName(
      turns,
      1.0,
      speakerGap: const Duration(milliseconds: 850),
      lineGap: const Duration(milliseconds: 250),
    );
    expect(
      neuralTtsPlaylistCacheFileName(
        turns,
        1.0,
        speakerGap: const Duration(milliseconds: 850),
        lineGap: const Duration(milliseconds: 250),
      ),
      first,
    );
    expect(first, matches(RegExp(r'^programme-[0-9a-f]{16}-100\.wav$')));
    expect(
      neuralTtsPlaylistCacheFileName(
        turns.reversed,
        1.0,
        speakerGap: const Duration(milliseconds: 850),
        lineGap: const Duration(milliseconds: 250),
      ),
      isNot(first),
    );
    expect(
      neuralTtsPlaylistCacheFileName(
        turns,
        0.75,
        speakerGap: const Duration(milliseconds: 850),
        lineGap: const Duration(milliseconds: 250),
      ),
      isNot(first),
    );
    expect(
      neuralTtsPlaylistCacheFileName(
        turns,
        1.0,
        speakerGap: const Duration(milliseconds: 1000),
        lineGap: const Duration(milliseconds: 250),
      ),
      isNot(first),
    );
  });
}
