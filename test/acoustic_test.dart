import 'dart:math' as math;
import 'dart:typed_data';

import 'package:deutsch_garden/acoustic.dart';
import 'package:flutter_test/flutter_test.dart';

/// A pure tone, so the spectrum has a known answer.
Float64List tone(double hz, {int sampleRate = 16000, double seconds = 1.0}) {
  final int n = (sampleRate * seconds).round();
  final Float64List out = Float64List(n);
  for (int i = 0; i < n; i++) {
    out[i] = math.sin(2 * math.pi * hz * i / sampleRate);
  }
  return out;
}

/// Something with the rough shape of speech: a moving formant over a buzz.
/// Not real speech, but it varies over time the way an utterance does, which
/// is what DTW is being asked to align.
Float64List pseudoSpeech({
  int sampleRate = 16000,
  double seconds = 1.2,
  double seed = 1.0,
}) {
  final int n = (sampleRate * seconds).round();
  final Float64List out = Float64List(n);
  for (int i = 0; i < n; i++) {
    final double t = i / sampleRate;
    final double formant = 400 + 300 * math.sin(2 * math.pi * 1.7 * t * seed);
    final double envelope = 0.5 + 0.5 * math.sin(2 * math.pi * 3.1 * t);
    out[i] = envelope *
        (math.sin(2 * math.pi * formant * t) +
            0.4 * math.sin(2 * math.pi * 2 * formant * t) +
            0.2 * math.sin(2 * math.pi * 120 * t));
  }
  return out;
}

/// Resample by linear interpolation, to make a slower or faster copy of the
/// same utterance.
Float64List stretch(Float64List input, double factor) {
  final int n = (input.length * factor).round();
  final Float64List out = Float64List(n);
  for (int i = 0; i < n; i++) {
    final double src = i / factor;
    final int lo = src.floor();
    final int hi = lo + 1 < input.length ? lo + 1 : input.length - 1;
    final double frac = src - lo;
    out[i] = input[lo] * (1 - frac) + input[hi] * frac;
  }
  return out;
}

void main() {
  group('MFCC', () {
    test('produces one frame per hop and the requested coefficient count', () {
      const Mfcc mfcc = Mfcc();
      final Float64List signal = tone(440, seconds: 1.0);
      final List<Float64List> frames = mfcc.extract(signal);

      // 16000 samples, 400-sample frames, 160-sample hop.
      final int expected = ((16000 - 400) ~/ 160) + 1;
      expect(frames, hasLength(expected));
      expect(frames.first, hasLength(13));
    });

    test('a signal shorter than one frame yields nothing rather than throwing',
        () {
      const Mfcc mfcc = Mfcc();
      expect(mfcc.extract(Float64List(100)), isEmpty);
      expect(mfcc.extract(Float64List(0)), isEmpty);
    });

    test('silence is finite, not negative infinity', () {
      const Mfcc mfcc = Mfcc();
      final List<Float64List> frames = mfcc.extract(Float64List(16000));
      expect(frames, isNotEmpty);
      for (final Float64List frame in frames) {
        for (final double value in frame) {
          expect(value.isFinite, isTrue,
              reason: 'the log floor should keep silence finite');
        }
      }
    });

    test('different tones give different cepstra, the same tone does not', () {
      const Mfcc mfcc = Mfcc();
      final List<Float64List> a = mfcc.extract(tone(300));
      final List<Float64List> b = mfcc.extract(tone(300));
      final List<Float64List> c = mfcc.extract(tone(1200));

      expect(dtwDistance(a, b), lessThan(1e-9));
      expect(dtwDistance(a, c), greaterThan(1.0));
    });
  });

  group('cepstral mean normalisation', () {
    test('removes a constant channel offset', () {
      const Mfcc mfcc = Mfcc();
      final List<Float64List> plain = mfcc.extract(pseudoSpeech());
      // Simulate a different microphone: a fixed offset per coefficient.
      final List<Float64List> coloured = <Float64List>[
        for (final Float64List f in plain)
          Float64List.fromList(<double>[
            for (int i = 0; i < f.length; i++) f[i] + (i + 1) * 0.75,
          ]),
      ];

      final double before = dtwDistance(plain, coloured);
      final double after = dtwDistance(
        cepstralMeanNormalise(plain),
        cepstralMeanNormalise(coloured),
      );

      expect(before, greaterThan(1.0),
          reason: 'the offset should matter before normalisation');
      expect(after, lessThan(1e-9),
          reason: 'and be gone after it — this is the whole point of CMN, '
              'since otherwise the score mostly measures the microphone');
    });

    test('leaves an empty list alone', () {
      expect(cepstralMeanNormalise(const <Float64List>[]), isEmpty);
    });
  });

  group('DTW', () {
    test('a signal against itself is zero', () {
      final Float64List signal = pseudoSpeech();
      final AcousticScore score =
          compareAudio(learner: signal, reference: signal);
      expect(score.distance, lessThan(1e-9));
      expect(score.score, 100);
    });

    test('the same utterance said slower still scores well', () {
      final Float64List reference = pseudoSpeech();
      final Float64List slower = stretch(reference, 1.35);

      final AcousticScore same =
          compareAudio(learner: slower, reference: reference);
      final AcousticScore different = compareAudio(
        learner: pseudoSpeech(seed: 3.4),
        reference: reference,
      );

      // This is the property that justifies warping at all: speaking slowly
      // is not a pronunciation error, and a frame-by-frame comparison would
      // punish it.
      expect(same.distance, lessThan(different.distance),
          reason: 'a time-stretched copy must be closer than a different '
              'utterance');
      expect(same.tempoRatio, greaterThan(1.2),
          reason: 'and the tempo difference should still be reported');
    });

    test('empty input scores zero rather than throwing', () {
      final AcousticScore score = compareAudio(
        learner: Float64List(0),
        reference: pseudoSpeech(),
      );
      expect(score.isEmpty, isTrue);
      expect(score.score, 0);
    });

    test('distance is symmetric', () {
      final Float64List a = pseudoSpeech(seed: 1.0);
      final Float64List b = pseudoSpeech(seed: 2.0);
      final double ab = compareAudio(learner: a, reference: b).distance;
      final double ba = compareAudio(learner: b, reference: a).distance;
      expect((ab - ba).abs(), lessThan(1e-9));
    });
  });

  group('scoring', () {
    test('places the measured anchors where they belong', () {
      // Measured with the bundled voice on Windows: the same sentence
      // re-synthesised at 0.8 speed sits at 12.4, and a different German
      // sentence at 30.7. The scale has to call the first good and the second
      // a failure, or it is not measuring content at all.
      expect(scoreForDistance(12.4), greaterThan(90));
      expect(scoreForDistance(30.7), lessThan(15));
      expect(scoreForDistance(0), 100);
    });

    test('is monotonic and bounded', () {
      expect(scoreForDistance(0), 100);
      expect(scoreForDistance(double.infinity), 0);
      expect(scoreForDistance(1000), 0);

      int previous = 101;
      for (double d = 0; d < 40; d += 0.5) {
        final int score = scoreForDistance(d);
        expect(score, lessThanOrEqualTo(previous),
            reason: 'score must never rise as distance grows');
        expect(score, inInclusiveRange(0, 100));
        previous = score;
      }
    });
  });
}
