import 'package:deutsch_garden/neural_tts_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cache names are deterministic and sensitive to text and rate', () {
    final String first = neuralTtsCacheFileName('Grüße aus Köln.', 1.0);
    expect(neuralTtsCacheFileName('Grüße aus Köln.', 1.0), first);
    expect(neuralTtsCacheFileName('Grüße aus Köln!', 1.0), isNot(first));
    expect(neuralTtsCacheFileName('Grüße aus Köln.', 0.75), isNot(first));
    expect(first, matches(RegExp(r'^utterance-[0-9a-f]{16}-100\.wav$')));
    for (var i = 0; i < 1000; i++) {
      expect(
        neuralTtsCacheFileName('Satz Nummer $i mit Umlaut ä.', 1.0),
        matches(RegExp(r'^utterance-[0-9a-f]{16}-100\.wav$')),
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
}
