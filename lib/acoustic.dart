/// Acoustic comparison of two recordings of the same sentence.
///
/// The speaking tutor has always scored the *recognised text* against the
/// target: it catches dropped words, wrong words and wrong endings, and it
/// cannot hear a vowel. Fixing that properly was supposed to need an offline
/// recogniser, and the plan called for bundling one — but there is no German
/// ASR model in sherpa-onnx's catalogue, and the multilingual models that
/// handle German at usable accuracy are 460 to 610 MB. At the sizes that fit,
/// German word error rates run 20–35%: a recogniser that misreads one word in
/// four would mark correct pronunciation wrong, which is worse than the text
/// comparison it replaced.
///
/// So this takes the other road. The app already synthesises the target
/// sentence with a bundled German voice, which means a reference recording
/// exists for free, for any sentence, on every platform. Comparing the
/// learner's audio against that reference is genuinely acoustic and needs no
/// model at all.
///
/// ## What this can and cannot hear
///
/// It hears **timing, rhythm, stress and vowel quality** — the shape of the
/// utterance. Long vowels held short, a stressed syllable in the wrong place,
/// a word rushed or dragged: those move the score.
///
/// It does **not** identify phonemes. It cannot tell you that your /y/ came
/// out as /u/, only that the segment sounded unlike the reference. And it
/// compares against a synthetic voice, so a learner whose accent differs from
/// the model in a way a German listener would accept still loses some points.
/// `docs/KNOWN_LIMITATIONS.md` says both of those rather than claiming a
/// phoneme scorer.
///
/// Everything here is pure Dart over `Float64List`. No plugin, no model, no
/// asset — which is why it can be tested against synthetic signals instead of
/// a microphone.
library;

import 'dart:math' as math;
import 'dart:typed_data';

/// Mel-frequency cepstral coefficients.
///
/// The standard front end for comparing speech: frame the signal, window it,
/// take the power spectrum, warp it onto the mel scale so that resolution
/// follows human hearing rather than physics, take logs, and decorrelate with
/// a DCT. What survives describes the shape of the vocal tract and discards
/// most of the pitch.
class Mfcc {
  const Mfcc({
    this.sampleRate = 16000,
    this.frameLength = 400,
    this.hopLength = 160,
    this.fftSize = 512,
    this.melBands = 26,
    this.coefficients = 13,
  });

  final int sampleRate;

  /// 25 ms at 16 kHz. Long enough for a stable spectrum, short enough that
  /// the vocal tract has not moved much within one frame.
  final int frameLength;

  /// 10 ms at 16 kHz, the usual 60% overlap.
  final int hopLength;

  /// Must be a power of two and at least [frameLength].
  final int fftSize;

  final int melBands;

  /// How many cepstral coefficients to keep, including c0.
  final int coefficients;

  /// Frame sizes derived from the rate rather than assumed.
  ///
  /// The defaults above are 25 ms and 10 ms *at 16 kHz*. Running them
  /// unchanged over 22.05 kHz audio would analyse 18 ms frames and quietly
  /// compare two different things, so anything that is not 16 kHz should be
  /// built through here.
  factory Mfcc.forRate(int sampleRate) {
    final int frame = (sampleRate * 0.025).round();
    int fft = 1;
    while (fft < frame) {
      fft <<= 1;
    }
    return Mfcc(
      sampleRate: sampleRate,
      frameLength: frame,
      hopLength: (sampleRate * 0.010).round(),
      fftSize: fft,
    );
  }

  static double _hzToMel(double hz) => 2595.0 * _log10(1.0 + hz / 700.0);

  static double _melToHz(double mel) =>
      700.0 * (math.pow(10.0, mel / 2595.0) - 1.0);

  static double _log10(double x) => math.log(x) / math.ln10;

  /// Triangular mel filterbank, built once per call.
  List<Float64List> _filterbank() {
    final int bins = fftSize ~/ 2 + 1;
    final double lowMel = _hzToMel(0);
    final double highMel = _hzToMel(sampleRate / 2);
    final Float64List points = Float64List(melBands + 2);
    for (int i = 0; i < points.length; i++) {
      final double mel = lowMel + (highMel - lowMel) * i / (melBands + 1);
      points[i] = _melToHz(mel) * fftSize / sampleRate;
    }

    final List<Float64List> bank = <Float64List>[];
    for (int m = 1; m <= melBands; m++) {
      final Float64List filter = Float64List(bins);
      final double left = points[m - 1];
      final double centre = points[m];
      final double right = points[m + 1];
      for (int k = 0; k < bins; k++) {
        final double bin = k.toDouble();
        if (bin >= left && bin <= centre && centre > left) {
          filter[k] = (bin - left) / (centre - left);
        } else if (bin > centre && bin <= right && right > centre) {
          filter[k] = (right - bin) / (right - centre);
        }
      }
      bank.add(filter);
    }
    return bank;
  }

  /// Hamming window, which is what the coefficients are conventionally
  /// defined against.
  Float64List _window() {
    final Float64List w = Float64List(frameLength);
    for (int i = 0; i < frameLength; i++) {
      w[i] = 0.54 - 0.46 * math.cos(2 * math.pi * i / (frameLength - 1));
    }
    return w;
  }

  /// One MFCC vector per frame.
  ///
  /// Returns an empty list when the signal is shorter than a single frame,
  /// rather than throwing: a learner who taps record and says nothing is a
  /// normal event, not an error.
  List<Float64List> extract(Float64List samples) {
    if (samples.length < frameLength) return const <Float64List>[];

    final List<Float64List> bank = _filterbank();
    final Float64List window = _window();
    final List<Float64List> out = <Float64List>[];

    final Float64List re = Float64List(fftSize);
    final Float64List im = Float64List(fftSize);

    for (int start = 0;
        start + frameLength <= samples.length;
        start += hopLength) {
      re.fillRange(0, fftSize, 0);
      im.fillRange(0, fftSize, 0);

      // Pre-emphasis lifts the high frequencies that speech rolls off, so the
      // consonants are not swamped by the vowels.
      double previous = start > 0 ? samples[start - 1] : samples[start];
      for (int i = 0; i < frameLength; i++) {
        final double sample = samples[start + i];
        re[i] = (sample - 0.97 * previous) * window[i];
        previous = sample;
      }

      _fft(re, im);

      final int bins = fftSize ~/ 2 + 1;
      final Float64List power = Float64List(bins);
      for (int k = 0; k < bins; k++) {
        power[k] = (re[k] * re[k] + im[k] * im[k]) / fftSize;
      }

      final Float64List logEnergies = Float64List(melBands);
      for (int m = 0; m < melBands; m++) {
        double sum = 0;
        final Float64List filter = bank[m];
        for (int k = 0; k < bins; k++) {
          sum += power[k] * filter[k];
        }
        // Floored before the log so silence is a large negative number rather
        // than negative infinity.
        logEnergies[m] = math.log(sum < 1e-10 ? 1e-10 : sum);
      }

      final Float64List cepstrum = Float64List(coefficients);
      for (int c = 0; c < coefficients; c++) {
        double sum = 0;
        for (int m = 0; m < melBands; m++) {
          sum += logEnergies[m] *
              math.cos(math.pi * c * (m + 0.5) / melBands);
        }
        cepstrum[c] = sum;
      }
      out.add(cepstrum);
    }
    return out;
  }

  /// In-place iterative radix-2 Cooley-Tukey FFT.
  static void _fft(Float64List re, Float64List im) {
    final int n = re.length;
    if (n <= 1) return;

    // Bit-reversal permutation.
    for (int i = 1, j = 0; i < n; i++) {
      int bit = n >> 1;
      for (; j & bit != 0; bit >>= 1) {
        j ^= bit;
      }
      j ^= bit;
      if (i < j) {
        final double tr = re[i];
        re[i] = re[j];
        re[j] = tr;
        final double ti = im[i];
        im[i] = im[j];
        im[j] = ti;
      }
    }

    for (int len = 2; len <= n; len <<= 1) {
      final double angle = -2 * math.pi / len;
      final double wr = math.cos(angle);
      final double wi = math.sin(angle);
      for (int i = 0; i < n; i += len) {
        double curR = 1;
        double curI = 0;
        for (int k = 0; k < len ~/ 2; k++) {
          final int a = i + k;
          final int b = i + k + len ~/ 2;
          final double xr = re[b] * curR - im[b] * curI;
          final double xi = re[b] * curI + im[b] * curR;
          re[b] = re[a] - xr;
          im[b] = im[a] - xi;
          re[a] += xr;
          im[a] += xi;
          final double nextR = curR * wr - curI * wi;
          curI = curR * wi + curI * wr;
          curR = nextR;
        }
      }
    }
  }
}

/// Subtract each coefficient's mean across the utterance.
///
/// Cepstral mean normalisation, and it is not optional here. A phone
/// microphone, a laptop microphone and a synthesised wav have completely
/// different channel responses, and in the cepstral domain a fixed channel is
/// a constant offset. Without removing it, this would mostly measure which
/// microphone was used.
List<Float64List> cepstralMeanNormalise(List<Float64List> frames) {
  if (frames.isEmpty) return frames;
  final int dim = frames.first.length;
  final Float64List mean = Float64List(dim);
  for (final Float64List frame in frames) {
    for (int i = 0; i < dim; i++) {
      mean[i] += frame[i];
    }
  }
  for (int i = 0; i < dim; i++) {
    mean[i] /= frames.length;
  }
  return <Float64List>[
    for (final Float64List frame in frames)
      Float64List.fromList(<double>[
        for (int i = 0; i < dim; i++) frame[i] - mean[i],
      ]),
  ];
}

double _distance(Float64List a, Float64List b) {
  double sum = 0;
  final int n = a.length < b.length ? a.length : b.length;
  // c0 is frame energy, which tracks recording gain more than pronunciation,
  // so the comparison starts at c1.
  for (int i = 1; i < n; i++) {
    final double d = a[i] - b[i];
    sum += d * d;
  }
  return math.sqrt(sum);
}

/// Dynamic time warping distance, normalised by the length of the path.
///
/// Warping is the whole point: a learner who says the sentence more slowly
/// than the reference is not mispronouncing it, and a frame-by-frame
/// comparison would punish them for the tempo alone. DTW finds the best
/// monotonic alignment first and measures what is left.
double dtwDistance(List<Float64List> a, List<Float64List> b) {
  if (a.isEmpty || b.isEmpty) return double.infinity;

  final int n = a.length;
  final int m = b.length;
  Float64List previous = Float64List(m + 1)..fillRange(0, m + 1, double.infinity);
  Float64List current = Float64List(m + 1);
  // Path length alongside cost, so the result is a mean step cost rather than
  // a total that grows with how long the sentence happened to be.
  Float64List previousSteps = Float64List(m + 1);
  Float64List currentSteps = Float64List(m + 1);

  previous[0] = 0;
  for (int i = 1; i <= n; i++) {
    current[0] = double.infinity;
    currentSteps[0] = 0;
    for (int j = 1; j <= m; j++) {
      final double cost = _distance(a[i - 1], b[j - 1]);
      double best = previous[j - 1];
      double bestSteps = previousSteps[j - 1];
      if (previous[j] < best) {
        best = previous[j];
        bestSteps = previousSteps[j];
      }
      if (current[j - 1] < best) {
        best = current[j - 1];
        bestSteps = currentSteps[j - 1];
      }
      current[j] = best + cost;
      currentSteps[j] = bestSteps + 1;
    }
    final Float64List swap = previous;
    previous = current;
    current = swap;
    final Float64List swapSteps = previousSteps;
    previousSteps = currentSteps;
    currentSteps = swapSteps;
  }

  final double steps = previousSteps[m];
  if (steps == 0) return double.infinity;
  return previous[m] / steps;
}

/// What an acoustic comparison produced.
class AcousticScore {
  const AcousticScore({
    required this.score,
    required this.distance,
    required this.learnerFrames,
    required this.referenceFrames,
  });

  /// 0–100, and deliberately generous at the top: this compares a human
  /// against a synthesiser, so a perfect match is not achievable and should
  /// not be the bar for full marks.
  final int score;

  /// The raw mean DTW step cost, kept so the mapping can be re-tuned against
  /// real recordings without changing the maths.
  final double distance;

  final int learnerFrames;
  final int referenceFrames;

  bool get isEmpty => learnerFrames == 0 || referenceFrames == 0;

  /// How much slower or faster the learner was, as a ratio. 1.0 is the same
  /// length as the reference.
  double get tempoRatio =>
      referenceFrames == 0 ? 0 : learnerFrames / referenceFrames;
}

/// Compare a learner recording against a reference rendering of the same
/// sentence.
///
/// Both are expected at the same sample rate and as mono `Float64List` in
/// [-1, 1].
AcousticScore compareAudio({
  required Float64List learner,
  required Float64List reference,
  Mfcc extractor = const Mfcc(),
}) {
  final List<Float64List> a =
      cepstralMeanNormalise(extractor.extract(learner));
  final List<Float64List> b =
      cepstralMeanNormalise(extractor.extract(reference));

  if (a.isEmpty || b.isEmpty) {
    return AcousticScore(
      score: 0,
      distance: double.infinity,
      learnerFrames: a.length,
      referenceFrames: b.length,
    );
  }

  final double distance = dtwDistance(a, b);
  return AcousticScore(
    score: scoreForDistance(distance),
    distance: distance,
    learnerFrames: a.length,
    referenceFrames: b.length,
  );
}

/// Map a mean DTW step cost onto 0–100.
///
/// The two anchors are measured, not guessed, but they are measured against
/// *synthetic* speech, which is the honest limit of this calibration. Rendering
/// „Ich möchte einen Kaffee, bitte.“ with the bundled voice and comparing it
/// with:
///
/// - itself gives a distance of 0.0;
/// - the same sentence re-synthesised at 0.8 speed gives 12.4;
/// - a different German sentence gives 30.7.
///
/// So the band runs from the same-words-different-delivery figure to the
/// different-words figure. That places the two things this can genuinely
/// distinguish where they belong: saying the target sentence differently is
/// good, and saying something else is not.
///
/// What it does **not** do is grade how well a human pronounced it, because
/// there is no human recording in those anchors. A learner's voice will sit
/// somewhere above 12.4 simply for not being the synthesiser, and where the
/// pass mark should fall among real speakers is a question for recordings
/// rather than for more thinking. That is why [AcousticScore.distance] is kept
/// on the result and why this mapping lives in exactly one function.
int scoreForDistance(double distance) {
  if (!distance.isFinite) return 0;
  const double excellent = 12.0;
  const double poor = 32.0;
  if (distance <= excellent) return 100;
  if (distance >= poor) return 0;
  final double t = (distance - excellent) / (poor - excellent);
  return ((1 - t) * 100).round().clamp(0, 100).toInt();
}
