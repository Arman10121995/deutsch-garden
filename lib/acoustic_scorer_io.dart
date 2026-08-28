/// Compare a learner recording with the bundled voice saying the same thing.
///
/// The reference is synthesised on demand, so this works for any sentence in
/// the app without shipping a single audio file. That is the whole reason the
/// acoustic path was possible at all after bundling a German recogniser turned
/// out not to be — see the header of `lib/acoustic.dart`.
library;

import 'dart:typed_data';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'acoustic.dart';
import 'neural_tts.dart';
import 'pronunciation_audio.dart';

class AcousticPronunciationScorer {
  const AcousticPronunciationScorer();

  /// Score [recording] against [targetGerman], or null when the bundled voice
  /// is unavailable and there is therefore no reference to compare with.
  Future<AcousticScore?> score({
    required String targetGerman,
    required String recordingPath,
  }) async {
    final String? referencePath =
        await NeuralTts.instance.synthesiseToFile(targetGerman);
    if (referencePath == null) return null;

    final _Clip? learner = _read(recordingPath);
    final _Clip? reference = _read(referencePath);
    if (learner == null || reference == null) return null;

    return compareAudio(
      learner: prepare(learner.samples, learner.sampleRate),
      reference: prepare(reference.samples, reference.sampleRate),
      extractor: analysisExtractor(),
    );
  }

  _Clip? _read(String path) {
    try {
      sherpa.initBindings();
      final sherpa.WaveData wave = sherpa.readWave(path);
      final Float64List samples = Float64List(wave.samples.length);
      for (int i = 0; i < wave.samples.length; i++) {
        samples[i] = wave.samples[i].toDouble();
      }
      return _Clip(samples, wave.sampleRate);
    } catch (_) {
      // An unreadable clip is a scoring failure, not a crash: the caller
      // falls back to the text comparison.
      return null;
    }
  }
}

class _Clip {
  const _Clip(this.samples, this.sampleRate);
  final Float64List samples;
  final int sampleRate;
}
