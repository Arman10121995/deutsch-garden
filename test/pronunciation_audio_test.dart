import 'dart:math' as math;
import 'dart:typed_data';

import 'package:deutsch_garden/acoustic.dart';
import 'package:deutsch_garden/pronunciation_audio.dart';
import 'package:flutter_test/flutter_test.dart';

Float64List tone(double hz, int sampleRate, double seconds, {double gain = 1}) {
  final int n = (sampleRate * seconds).round();
  final Float64List out = Float64List(n);
  for (int i = 0; i < n; i++) {
    out[i] = gain * math.sin(2 * math.pi * hz * i / sampleRate);
  }
  return out;
}

void main() {
  group('resampling', () {
    test('changes the length by the rate ratio', () {
      final Float64List at22k = tone(440, 22050, 1.0);
      final Float64List at16k = resample(at22k, 22050, toRate: 16000);
      expect(at16k.length, closeTo(16000, 2));

      final Float64List up = resample(tone(440, 8000, 1.0), 8000);
      expect(up.length, closeTo(analysisSampleRate, 2));
    });

    test('is a no-op at the analysis rate, which is the common path', () {
      // The recorder asks for analysisSampleRate and the bundled voice
      // produces it, so in normal use nothing is resampled at all.
      final Float64List signal = tone(440, analysisSampleRate, 0.5);
      expect(identical(resample(signal, analysisSampleRate), signal), isTrue);
    });

    test('is lossy enough that the common path must avoid it', () {
      // Recorded rather than asserted away. Downsampling 22.05 to 16 kHz by
      // linear interpolation leaves artefacts worth about 10 DTW distance
      // against the same tone generated natively — a fifth of the whole
      // scoring range. This test exists so that anyone tempted to resample
      // the reference sees the cost first.
      final Float64List a = resample(tone(440, 22050, 1.0), 22050, toRate: 16000);
      final Float64List b = tone(440, 16000, 1.0);
      final Mfcc mfcc = Mfcc.forRate(16000);
      final double d = dtwDistance(
        cepstralMeanNormalise(mfcc.extract(a)),
        cepstralMeanNormalise(mfcc.extract(b)),
      );
      expect(d, greaterThan(1.0),
          reason: 'if this ever drops, resampling got better and the note on '
              'analysisSampleRate should be revisited');
    });

    test('frame sizes follow the rate rather than assuming 16 kHz', () {
      final Mfcc at22k = Mfcc.forRate(22050);
      expect(at22k.frameLength, (22050 * 0.025).round());
      expect(at22k.hopLength, (22050 * 0.010).round());
      expect(at22k.fftSize, greaterThanOrEqualTo(at22k.frameLength));
      // Power of two, or the FFT is wrong.
      expect(at22k.fftSize & (at22k.fftSize - 1), 0);
    });

    test('handles an empty clip', () {
      expect(resample(Float64List(0), 22050), isEmpty);
    });
  });

  group('silence trimming', () {
    test('removes dead air at both ends', () {
      final Float64List speech = tone(300, 16000, 0.5);
      final Float64List padded = Float64List(16000 * 2);
      padded.setRange(8000, 8000 + speech.length, speech);

      final Float64List trimmed = trimSilence(padded);
      expect(trimmed.length, lessThan(padded.length));
      expect(trimmed.length, greaterThan(speech.length ~/ 2));
    });

    test('a silent clip trims to nothing rather than throwing', () {
      expect(trimSilence(Float64List(16000)), isEmpty);
      expect(trimSilence(Float64List(0)), isEmpty);
    });

    test('leaves a clip that is speech throughout almost alone', () {
      final Float64List speech = tone(300, 16000, 1.0);
      final Float64List trimmed = trimSilence(speech);
      expect(trimmed.length, greaterThan((speech.length * 0.9).round()));
    });
  });

  group('level normalisation', () {
    test('makes a quiet and a loud recording comparable', () {
      final Float64List loud = tone(300, 16000, 0.5, gain: 0.95);
      final Float64List quiet = tone(300, 16000, 0.5, gain: 0.05);

      final Float64List a = normaliseLevel(loud);
      final Float64List b = normaliseLevel(quiet);

      double peak(Float64List x) =>
          x.fold<double>(0, (m, v) => v.abs() > m ? v.abs() : m);
      expect(peak(a), closeTo(0.9, 1e-9));
      expect(peak(b), closeTo(0.9, 1e-9));
    });

    test('leaves silence alone instead of dividing by zero', () {
      final Float64List silent = Float64List(1000);
      final Float64List out = normaliseLevel(silent);
      expect(out.every((v) => v == 0), isTrue);
    });
  });

  group('pcm16 decoding', () {
    test('maps full scale to the unit interval', () {
      final ByteData data = ByteData(4);
      data.setInt16(0, 32767, Endian.little);
      data.setInt16(2, -32768, Endian.little);
      final Float64List mono = pcm16ToMono(data.buffer.asUint8List());
      expect(mono, hasLength(2));
      expect(mono[0], closeTo(1.0, 1e-4));
      expect(mono[1], closeTo(-1.0, 1e-9));
    });

    test('averages stereo down rather than dropping a channel', () {
      final ByteData data = ByteData(8);
      // Frame 1: left full, right silent. Frame 2: both full.
      data.setInt16(0, 32767, Endian.little);
      data.setInt16(2, 0, Endian.little);
      data.setInt16(4, 32767, Endian.little);
      data.setInt16(6, 32767, Endian.little);
      final Float64List mono =
          pcm16ToMono(data.buffer.asUint8List(), channels: 2);
      expect(mono, hasLength(2));
      expect(mono[0], closeTo(0.5, 1e-4));
      expect(mono[1], closeTo(1.0, 1e-4));
    });
  });

  group('prepare', () {
    test('a quiet, padded clip still matches its clean twin', () {
      // The pipeline's reason for existing: the learner's clip and the
      // synthesised reference differ in level and leading silence before a
      // single thing has been said about pronunciation.
      final Float64List clean = tone(300, analysisSampleRate, 0.8);

      final Float64List speech = tone(300, analysisSampleRate, 0.8, gain: 0.08);
      final Float64List messy = Float64List(analysisSampleRate * 2);
      messy.setRange(analysisSampleRate ~/ 2,
          analysisSampleRate ~/ 2 + speech.length, speech);

      final AcousticScore score = compareAudio(
        learner: prepare(messy, analysisSampleRate),
        reference: prepare(clean, analysisSampleRate),
        extractor: analysisExtractor(),
      );
      expect(score.score, greaterThan(70),
          reason: 'rate, gain and padding must not look like a pronunciation '
              'error');
    });
  });
}
