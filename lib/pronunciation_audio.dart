/// Reading and preparing audio for acoustic pronunciation scoring.
///
/// Two recordings have to be made comparable before `lib/acoustic.dart` can
/// say anything useful about them: the learner's microphone and the bundled
/// voice do not agree on sample rate, and the mel filterbank is defined
/// against the rate, so comparing 22.05 kHz cepstra with 16 kHz cepstra would
/// be comparing two different frequency ranges and calling the difference
/// pronunciation.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'acoustic.dart';

/// The rate both clips are analysed at.
///
/// 22.05 kHz because that is what the bundled voice produces, and the
/// reference is the one signal whose rate is not negotiable. Recording the
/// learner at the same rate means the common path resamples nothing.
///
/// That is not fussiness. Linear resampling of a 440 Hz tone from 22.05 to
/// 16 kHz measured a DTW distance of 10.3 against the same tone generated
/// natively at 16 kHz — on a scale where 6 scores full marks and 26 scores
/// zero. Downsampling the reference would therefore have docked roughly
/// twenty points from every learner before they opened their mouth. The fix
/// is to not resample, not to widen the scoring band until the artefact fits
/// inside it.
const int analysisSampleRate = 22050;

/// Linear resampling to [analysisSampleRate].
///
/// The fallback for a platform that cannot record at the reference rate. It is
/// lossy enough to matter — see the note on [analysisSampleRate] — so the
/// recorder asks for 22.05 kHz and this should normally do nothing.
Float64List resample(Float64List input, int fromRate, {int toRate = analysisSampleRate}) {
  if (input.isEmpty) return input;
  if (fromRate == toRate) return input;

  final double ratio = toRate / fromRate;
  final int n = (input.length * ratio).round();
  final Float64List out = Float64List(n);
  for (int i = 0; i < n; i++) {
    final double src = i / ratio;
    final int lo = src.floor();
    if (lo >= input.length - 1) {
      out[i] = input[input.length - 1];
      continue;
    }
    final double frac = src - lo;
    out[i] = input[lo] * (1 - frac) + input[lo + 1] * frac;
  }
  return out;
}

/// Strip leading and trailing near-silence.
///
/// A learner taps record, breathes, speaks, and taps stop, so their clip has
/// dead air at both ends that the synthesised reference does not. DTW would
/// otherwise spend its alignment budget matching silence against speech.
///
/// The threshold is relative to the clip's own peak, so it does not care how
/// loud the microphone was.
Float64List trimSilence(
  Float64List samples, {
  double relativeThreshold = 0.02,
  int windowSamples = 160,
}) {
  if (samples.isEmpty) return samples;

  double peak = 0;
  for (final double s in samples) {
    final double a = s.abs();
    if (a > peak) peak = a;
  }
  if (peak == 0) return Float64List(0);
  final double threshold = peak * relativeThreshold;

  bool loud(int start) {
    final int end = math.min(start + windowSamples, samples.length);
    double sum = 0;
    for (int i = start; i < end; i++) {
      sum += samples[i] * samples[i];
    }
    final int count = end - start;
    if (count == 0) return false;
    return math.sqrt(sum / count) > threshold;
  }

  int first = 0;
  while (first < samples.length && !loud(first)) {
    first += windowSamples;
  }
  if (first >= samples.length) return Float64List(0);

  int last = samples.length - windowSamples;
  while (last > first && !loud(last)) {
    last -= windowSamples;
  }
  final int end = math.min(last + windowSamples, samples.length);
  return Float64List.sublistView(samples, first, end);
}

/// Normalise to a fixed peak so the two clips are equally loud.
///
/// Recording gain is not pronunciation. Cepstral mean normalisation already
/// removes a constant channel offset, but doing this first keeps the log
/// energies in a sane range for both signals.
Float64List normaliseLevel(Float64List samples, {double target = 0.9}) {
  if (samples.isEmpty) return samples;
  double peak = 0;
  for (final double s in samples) {
    final double a = s.abs();
    if (a > peak) peak = a;
  }
  if (peak == 0) return samples;
  final double gain = target / peak;
  final Float64List out = Float64List(samples.length);
  for (int i = 0; i < samples.length; i++) {
    out[i] = samples[i] * gain;
  }
  return out;
}

/// Everything a clip needs before it can be compared: resampled, trimmed and
/// levelled.
Float64List prepare(Float64List samples, int sampleRate) =>
    normaliseLevel(trimSilence(resample(samples, sampleRate)));

/// The feature extractor matching [analysisSampleRate].
Mfcc analysisExtractor() => Mfcc.forRate(analysisSampleRate);

/// Convert interleaved 16-bit PCM to mono doubles in [-1, 1].
///
/// [channels] above one is averaged down rather than taking the first
/// channel, so a stereo microphone does not lose half its signal.
Float64List pcm16ToMono(Uint8List bytes, {int channels = 1}) {
  final int frames = bytes.length ~/ (2 * channels);
  final Float64List out = Float64List(frames);
  final ByteData view = ByteData.sublistView(bytes);
  for (int f = 0; f < frames; f++) {
    double sum = 0;
    for (int c = 0; c < channels; c++) {
      final int offset = (f * channels + c) * 2;
      sum += view.getInt16(offset, Endian.little) / 32768.0;
    }
    out[f] = sum / channels;
  }
  return out;
}
