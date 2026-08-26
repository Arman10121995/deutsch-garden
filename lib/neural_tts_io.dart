import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// The bundled German voice, synthesised on device.
///
/// The OS synthesiser is fine on iOS, macOS and Windows, acceptable on Android
/// and genuinely poor on Linux, where the app falls back to `espeak-ng` and the
/// result is robotic enough to be worth avoiding. A bundled Piper VITS model
/// run through sherpa-onnx gives every platform the same voice, which also
/// means a listening exercise sounds the same for every learner rather than
/// depending on which voices happen to be installed.
///
/// The dataset behind the voice is CC0 and the model repository is MIT, so it
/// is compatible with this app's licence — see `assets/tts/MODEL_CARD`.
///
/// This is deliberately a *preferred* backend rather than the only one. If the
/// model fails to initialise for any reason — an unsupported architecture, a
/// truncated install, a platform the plugin has not reached yet — the caller
/// falls back to the OS synthesiser and the app keeps working.
class NeuralTts {
  NeuralTts._();

  static final NeuralTts instance = NeuralTts._();

  sherpa.OfflineTts? _tts;
  Future<bool>? _initialising;
  bool _failed = false;

  /// Where the staged voice lives once copied out of the asset bundle.
  Directory? _voiceDir;

  /// True once the voice is loaded and usable.
  bool get isReady => _tts != null;

  /// True when initialisation was attempted and did not work.
  bool get hasFailed => _failed;

  /// Loads the voice, at most once.
  ///
  /// Concurrent callers share one future rather than each starting their own
  /// copy of a 61 MB staging operation.
  Future<bool> initialise() {
    if (_tts != null) return Future<bool>.value(true);
    if (_failed) return Future<bool>.value(false);
    return _initialising ??= _doInitialise();
  }

  Future<bool> _doInitialise() async {
    try {
      sherpa.initBindings();
      final Directory dir = await _stageVoice();
      _voiceDir = dir;

      final String modelPath = '${dir.path}/de_DE-thorsten-medium.onnx';
      final String tokensPath = '${dir.path}/tokens.txt';
      final String dataPath = '${dir.path}/espeak-ng-data';

      final sherpa.OfflineTtsVitsModelConfig vits =
          sherpa.OfflineTtsVitsModelConfig(
        model: modelPath,
        tokens: tokensPath,
        dataDir: dataPath,
      );
      final sherpa.OfflineTtsModelConfig model = sherpa.OfflineTtsModelConfig(
        vits: vits,
        numThreads: 2,
        // The package defaults this to true, which prints the whole config and
        // per-utterance timings to the log on every call.
        debug: false,
      );
      final sherpa.OfflineTtsConfig config = sherpa.OfflineTtsConfig(
        model: model,
        maxNumSenetences: 1,
      );
      _tts = sherpa.OfflineTts(config);
      return true;
    } catch (_) {
      // Any failure here is recoverable: the caller uses the OS synthesiser.
      _failed = true;
      return false;
    } finally {
      _initialising = null;
    }
  }

  /// Copies the voice out of the asset bundle onto disk.
  ///
  /// sherpa-onnx opens real files, and on Android an asset is a compressed
  /// entry inside the APK with no filesystem path, so the model has to be
  /// staged once. Subsequent launches reuse it: the marker file records which
  /// build staged the voice, so an app update replaces it rather than serving
  /// a stale model.
  Future<Directory> _stageVoice() async {
    final Directory support = await getApplicationSupportDirectory();
    final Directory dir = Directory('${support.path}/tts-de-thorsten');
    final File marker = File('${dir.path}/.staged');

    const List<String> files = <String>[
      'de_DE-thorsten-medium.onnx',
      'de_DE-thorsten-medium.onnx.json',
      'tokens.txt',
      'espeak-ng-data/phondata',
      'espeak-ng-data/phonindex',
      'espeak-ng-data/phontab',
      'espeak-ng-data/phondata-manifest',
      'espeak-ng-data/intonations',
      'espeak-ng-data/de_dict',
      'espeak-ng-data/lang/gmw/de',
    ];

    if (await marker.exists()) {
      final String stamped = await marker.readAsString();
      if (stamped == _stageStamp) return dir;
    }

    for (final String name in files) {
      final File target = File('${dir.path}/$name');
      await target.parent.create(recursive: true);
      final ByteData data = await rootBundle.load('assets/tts/$name');
      await target.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }
    await marker.writeAsString(_stageStamp, flush: true);
    return dir;
  }

  /// Bumped when the bundled voice changes, so an update restages it.
  static const String _stageStamp = 'thorsten-medium-1';

  /// Synthesises [text] to a wav file and returns its path, or null if the
  /// voice is not available.
  ///
  /// [rate] is a multiplier on the normal speaking pace, matching the
  /// interface the OS backend already exposes.
  Future<String?> synthesiseToFile(String text, {double rate = 1.0}) async {
    if (!await initialise()) return null;
    final sherpa.OfflineTts? tts = _tts;
    final Directory? dir = _voiceDir;
    if (tts == null || dir == null) return null;

    try {
      final sherpa.GeneratedAudio audio = tts.generate(
        text: text,
        sid: 0,
        speed: rate,
      );
      final String path =
          '${dir.path}/utterance-${text.hashCode.toUnsigned(32)}-'
          '${(rate * 100).round()}.wav';
      final File file = File(path);
      if (!await file.exists()) {
        sherpa.writeWave(
          filename: path,
          samples: audio.samples,
          sampleRate: audio.sampleRate,
        );
      }
      return path;
    } catch (_) {
      return null;
    }
  }

  /// Frees the model. Called when the app no longer needs synthesis.
  void dispose() {
    _tts?.free();
    _tts = null;
  }
}
