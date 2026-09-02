import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'neural_tts_cache.dart';
import 'neural_voice.dart';

/// The bundled German voices, synthesised on device.
///
/// The OS synthesiser is fine on iOS, macOS and Windows, acceptable on Android
/// and genuinely poor on Linux, where the app falls back to `espeak-ng` and the
/// result is robotic enough to be worth avoiding. A bundled Piper VITS model
/// run through sherpa-onnx gives every platform the same voice, which also
/// means a listening exercise sounds the same for every learner rather than
/// depending on which voices happen to be installed.
///
/// Both datasets are CC0 and the model repository is MIT, so they are
/// compatible with this app's licence — see both `assets/tts/MODEL_CARD`
/// files.
///
/// This is deliberately a *preferred* backend rather than the only one. If the
/// model fails to initialise for any reason — an unsupported architecture, a
/// truncated install, a platform the plugin has not reached yet — the caller
/// falls back to the OS synthesiser and the app keeps working.
///
/// ## Why the model lives in its own isolate
///
/// `OfflineTts.generate` is a synchronous FFI call. It returns a
/// `GeneratedAudio`, not a `Future`, and it does not yield: it holds whichever
/// isolate calls it for the whole synthesis. Measured on a desktop CPU that is
/// roughly 650 ms for one sentence and twelve seconds for a two-hundred-word
/// radio episode. On the main isolate that is not slow, it is *frozen* — no
/// frames, no scrolling, not even the spinner that was supposed to say the app
/// was busy.
///
/// So the model is loaded inside a long-lived worker isolate and driven by
/// messages. The worker is spawned once and kept, because loading the model
/// costs about three seconds and `Isolate.run` would pay that per utterance.
/// Only file paths and strings cross the boundary; nothing native does.
class NeuralTts {
  NeuralTts._();

  static final NeuralTts instance = NeuralTts._();

  SendPort? _toWorker;
  Isolate? _isolate;
  ReceivePort? _fromWorker;
  ReceivePort? _workerLifecycle;
  ReceivePort? _workerErrors;

  Future<bool>? _initialising;
  bool _failed = false;
  bool _stopping = false;

  /// Where the staged voice lives once copied out of the asset bundle.
  Directory? _voiceDir;

  int _nextRequest = 0;
  final Map<int, Completer<String?>> _pending = <int, Completer<String?>>{};

  /// Synthesis already running for a given output path.
  ///
  /// Two screens asking for the same utterance at the same moment — a warmup
  /// racing the learner's tap, most often — must not both drive the model
  /// through the same twelve seconds of work. They share one future.
  final Map<String, Future<String?>> _inFlight = <String, Future<String?>>{};

  /// True once the voice is loaded and usable.
  bool get isReady => _toWorker != null;

  /// True when initialisation was attempted and did not work.
  bool get hasFailed => _failed;

  /// Loads the voice, at most once.
  ///
  /// Concurrent callers share one future rather than each starting their own
  /// copy of a roughly 126 MB staging operation.
  Future<bool> initialise() {
    if (_toWorker != null) return Future<bool>.value(true);
    if (_failed) return Future<bool>.value(false);
    return _initialising ??= _doInitialise();
  }

  Future<bool> _doInitialise() async {
    try {
      // Staging has to happen here rather than in the worker: it reads the
      // asset bundle and the application support directory, and neither
      // rootBundle nor path_provider is available in a plain spawned isolate.
      final Directory dir = await _stageVoice();
      _voiceDir = dir;

      final ReceivePort handshake = ReceivePort();
      final ReceivePort lifecycle = ReceivePort();
      final ReceivePort errors = ReceivePort();
      _workerLifecycle = lifecycle;
      _workerErrors = errors;

      final Completer<void> ended = Completer<void>();
      void workerEnded(Object? _) {
        if (!ended.isCompleted) ended.complete();
        _onWorkerTerminated();
      }

      lifecycle.listen(workerEnded);
      errors.listen(workerEnded);

      _isolate = await Isolate.spawn<List<Object?>>(
        _ttsWorker,
        <Object?>[
          handshake.sendPort,
          '${dir.path}/de_DE-thorsten-medium.onnx',
          '${dir.path}/tokens.txt',
          '${dir.path}/de_DE-kerstin-low.onnx',
          '${dir.path}/tokens-kerstin.txt',
          '${dir.path}/espeak-ng-data',
        ],
        debugName: 'neural-tts',
        onExit: lifecycle.sendPort,
        onError: errors.sendPort,
        errorsAreFatal: true,
      );

      final ReceivePort replies = ReceivePort();
      _fromWorker = replies;
      replies.listen(_onWorkerMessage);

      // The worker sends its command port once native bindings are ready. The
      // voices themselves are intentionally lazy: keeping both models alive
      // here made opening a radio episode exceed the memory budget on some
      // Android devices.
      final Object? ready = await Future.any<Object?>(<Future<Object?>>[
        handshake.first,
        ended.future.then<Object?>((_) => null),
      ]).timeout(const Duration(seconds: 60), onTimeout: () => null);
      handshake.close();

      if (ready is! SendPort) {
        _teardown();
        _failed = true;
        return false;
      }

      _toWorker = ready;
      ready.send(<Object?>['port', replies.sendPort]);
      return true;
    } catch (_) {
      // Any failure here is recoverable: the caller uses the OS synthesiser.
      _teardown();
      _failed = true;
      return false;
    } finally {
      _initialising = null;
    }
  }

  void _onWorkerMessage(Object? message) {
    if (message is! List || message.length != 2) return;
    final Object? id = message[0];
    if (id is! int) return;
    final Completer<String?>? waiting = _pending.remove(id);
    if (waiting == null || waiting.isCompleted) return;
    final Object? path = message[1];
    waiting.complete(path is String ? path : null);
  }

  void _onWorkerTerminated() {
    if (_stopping || (_isolate == null && _toWorker == null)) return;
    _failed = true;
    _teardown(killWorker: false);
  }

  void _teardown({bool killWorker = true}) {
    _fromWorker?.close();
    _fromWorker = null;
    _workerLifecycle?.close();
    _workerLifecycle = null;
    _workerErrors?.close();
    _workerErrors = null;
    if (killWorker) _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _toWorker = null;
    for (final Completer<String?> waiting in _pending.values) {
      if (!waiting.isCompleted) waiting.complete(null);
    }
    _pending.clear();
    _inFlight.clear();
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
      'de_DE-kerstin-low.onnx',
      'de_DE-kerstin-low.onnx.json',
      'tokens.txt',
      'tokens-kerstin.txt',
      'MODEL_CARD_KERSTIN',
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

  /// Bumped when either bundled voice changes, so an update restages both.
  static const String _stageStamp = 'thorsten-medium-1_kerstin-low-1';

  String _pathFor(Directory dir, String text, double rate, NeuralVoice voice) =>
      '${dir.path}/${neuralTtsCacheFileName(text, rate, voice: voice.name)}';

  String _playlistPathFor(
    Directory dir,
    Iterable<NeuralTurn> turns,
    double rate,
    Duration speakerGap,
    Duration lineGap,
  ) =>
      '${dir.path}/${neuralTtsPlaylistCacheFileName(turns, rate, speakerGap: speakerGap, lineGap: lineGap)}';

  Future<bool> _isValidWave(File file) async {
    try {
      if (!await file.exists() || await file.length() < 44) return false;
      final RandomAccessFile input = await file.open();
      try {
        return hasWaveHeader(await input.read(12));
      } finally {
        await input.close();
      }
    } on FileSystemException {
      return false;
    }
  }

  /// Whether this exact utterance has already been rendered.
  ///
  /// Lets a caller tell a cached play from one that needs twelve seconds of
  /// work, which is the difference between showing a spinner and not.
  Future<bool> isCached(
    String text, {
    double rate = 1.0,
    NeuralVoice voice = NeuralVoice.thorsten,
  }) async {
    final Directory? dir = _voiceDir;
    if (dir == null) return false;
    return _isValidWave(File(_pathFor(dir, text, rate, voice)));
  }

  /// Synthesises [text] to a wav file and returns its path, or null if the
  /// voice is not available.
  ///
  /// [rate] is a multiplier on the normal speaking pace, matching the
  /// interface the OS backend already exposes.
  Future<String?> synthesiseToFile(
    String text, {
    double rate = 1.0,
    NeuralVoice voice = NeuralVoice.thorsten,
  }) async {
    if (!await initialise()) return null;
    final SendPort? worker = _toWorker;
    final Directory? dir = _voiceDir;
    if (worker == null || dir == null) return null;

    final String path = _pathFor(dir, text, rate, voice);

    // Check the cache *before* synthesising. This used to run the model first
    // and then skip only the file write, so every replay of an episode paid
    // the full generation cost again for a file that was already on disk.
    final File cached = File(path);
    if (await _isValidWave(cached)) return path;
    if (await cached.exists()) await cached.delete();

    return _render(
      path,
      worker,
      (int id) => <Object?>['say', id, text, rate, path, voice.index],
    );
  }

  /// Renders a complete conversation as one seekable WAV.
  ///
  /// The worker batches all Thorsten lines, frees that model, then renders the
  /// Kerstin lines. It finally restores the original order and inserts silence
  /// between turns. Peak native-model memory is therefore one voice rather
  /// than two, while the player receives one ordinary audio file.
  Future<String?> synthesiseTurnsToFile(
    Iterable<NeuralTurn> turns, {
    double rate = 1.0,
    Duration speakerGap = const Duration(milliseconds: 850),
    Duration lineGap = const Duration(milliseconds: 250),
  }) async {
    final List<NeuralTurn> programme = turns
        .where((NeuralTurn turn) => turn.text.trim().isNotEmpty)
        .toList(growable: false);
    if (programme.isEmpty || !await initialise()) return null;
    final SendPort? worker = _toWorker;
    final Directory? dir = _voiceDir;
    if (worker == null || dir == null) return null;

    final String path = _playlistPathFor(
      dir,
      programme,
      rate,
      speakerGap,
      lineGap,
    );
    final File cached = File(path);
    if (await _isValidWave(cached)) return path;
    if (await cached.exists()) await cached.delete();

    final List<List<Object?>> encoded = programme
        .map((NeuralTurn turn) => <Object?>[turn.text, turn.voice.index])
        .toList(growable: false);
    return _render(
      path,
      worker,
      (int id) => <Object?>[
        'playlist',
        id,
        encoded,
        rate,
        path,
        speakerGap.inMilliseconds,
        lineGap.inMilliseconds,
      ],
    );
  }

  Future<String?> _render(
    String path,
    SendPort worker,
    List<Object?> Function(int id) command,
  ) {
    final Future<String?>? running = _inFlight[path];
    if (running != null) return running;

    final int id = _nextRequest++;
    final Completer<String?> completer = Completer<String?>();
    _pending[id] = completer;
    final Future<String?> future = completer.future
        .timeout(
          const Duration(minutes: 5),
          onTimeout: () {
            _pending.remove(id);
            return null;
          },
        )
        .whenComplete(() {
          // A block is intentional: returning Map.remove's value here returns
          // this same Future, and Future.whenComplete then waits on itself.
          _inFlight.remove(path);
        });
    _inFlight[path] = future;
    worker.send(command(id));
    return future;
  }

  /// Frees the model. Called when the app no longer needs synthesis.
  void dispose() {
    _stopping = true;
    _toWorker?.send(<Object?>['stop']);
    _teardown();
    _failed = false;
    _stopping = false;
  }
}

/// Entry point for the synthesis isolate.
///
/// Top-level by necessity — `Isolate.spawn` takes a function, not a closure,
/// so nothing from the enclosing scope can be captured and every path the
/// worker needs is passed in the boot message.
void _ttsWorker(List<Object?> boot) {
  final SendPort handshake = boot[0]! as SendPort;
  final String modelPath = boot[1]! as String;
  final String tokensPath = boot[2]! as String;
  final String secondModelPath = boot[3]! as String;
  final String secondTokensPath = boot[4]! as String;
  final String dataPath = boot[5]! as String;

  sherpa.OfflineTts load(int voice) {
    final bool second = voice == NeuralVoice.kerstin.index;
    return sherpa.OfflineTts(
      sherpa.OfflineTtsConfig(
        model: sherpa.OfflineTtsModelConfig(
          vits: sherpa.OfflineTtsVitsModelConfig(
            model: second ? secondModelPath : modelPath,
            tokens: second ? secondTokensPath : tokensPath,
            dataDir: dataPath,
          ),
          numThreads: 2,
          debug: false,
        ),
        maxNumSenetences: 1,
      ),
    );
  }

  try {
    // Bindings are per-isolate, so this has to run here and not only on the
    // isolate that spawned this one.
    sherpa.initBindings();
  } catch (_) {
    // Tell the parent it failed rather than leaving it waiting on a handshake
    // that will never arrive.
    handshake.send(null);
    return;
  }

  final ReceivePort commands = ReceivePort();
  handshake.send(commands.sendPort);

  SendPort? replies;
  commands.listen((Object? message) {
    if (message is! List || message.isEmpty) return;
    switch (message[0]) {
      case 'port':
        replies = message[1] as SendPort?;
      case 'say':
        final int id = message[1]! as int;
        final String text = message[2]! as String;
        final double rate = message[3]! as double;
        final String path = message[4]! as String;
        final int voice = message[5]! as int;
        final String temporary = '$path.part-$id';
        String? result;
        sherpa.OfflineTts? tts;
        try {
          // sherpa-onnx 1.13.6 can crash inside a second Generate call on the
          // same Android TTS handle. Give every render an isolated native
          // lifetime; the on-disk cache means this cost is paid only once per
          // distinct utterance.
          tts = load(voice);
          final sherpa.GeneratedAudio audio = tts.generate(
            text: text,
            sid: 0,
            speed: rate,
          );
          sherpa.writeWave(
            filename: temporary,
            samples: audio.samples,
            sampleRate: audio.sampleRate,
          );
          final File partial = File(temporary);
          if (!partial.existsSync() || partial.lengthSync() < 44) {
            throw StateError('The synthesiser produced an invalid WAV');
          }
          final File target = File(path);
          if (target.existsSync()) target.deleteSync();
          partial.renameSync(path);
          result = path;
        } catch (_) {
          final File partial = File(temporary);
          if (partial.existsSync()) partial.deleteSync();
          result = null;
        } finally {
          tts?.free();
        }
        replies?.send(<Object?>[id, result]);
      case 'playlist':
        final int id = message[1]! as int;
        final List<Object?> encoded = (message[2]! as List).cast<Object?>();
        final double rate = message[3]! as double;
        final String path = message[4]! as String;
        final int speakerGapMs = message[5]! as int;
        final int lineGapMs = message[6]! as int;
        final String temporary = '$path.part-$id';
        String? result;
        try {
          // Keep every authored line as a bounded render block. Long combined
          // passages and repeated calls on one handle both triggered native
          // Android crashes in sherpa-onnx 1.13.6. A fresh handle per short
          // line avoids both unsafe paths; the finished blocks are assembled
          // below with explicit silence and cached as one seekable programme.
          final List<List<Object?>> blocks = <List<Object?>>[];
          for (final Object? raw in encoded) {
            final List<Object?> turn = (raw! as List).cast<Object?>();
            final String text = (turn[0]! as String).trim();
            final int voice = turn[1]! as int;
            if (text.isEmpty) continue;
            blocks.add(<Object?>[text, voice]);
          }

          final List<Float32List?> rendered = List<Float32List?>.filled(
            blocks.length,
            null,
          );
          final List<int> voices = List<int>.filled(blocks.length, 0);
          int? sampleRate;

          for (var i = 0; i < blocks.length; i++) {
            final List<Object?> block = blocks[i];
            final int voice = block[1]! as int;
            voices[i] = voice;
            final sherpa.OfflineTts tts = load(voice);
            try {
              final sherpa.GeneratedAudio audio = tts.generate(
                text: block[0]! as String,
                sid: 0,
                speed: rate,
              );
              sampleRate ??= audio.sampleRate;
              if (audio.sampleRate != sampleRate) {
                throw StateError('Bundled voices use different sample rates');
              }
              rendered[i] = audio.samples;
            } finally {
              tts.free();
            }
          }

          final int hz = sampleRate ?? 22050;
          var totalSamples = 0;
          for (var i = 0; i < rendered.length; i++) {
            totalSamples += rendered[i]?.length ?? 0;
            if (i + 1 < rendered.length) {
              final int gapMs = voices[i] == voices[i + 1]
                  ? lineGapMs
                  : speakerGapMs;
              totalSamples += (hz * gapMs / 1000).round();
            }
          }
          final Float32List joined = Float32List(totalSamples);
          var offset = 0;
          for (var i = 0; i < rendered.length; i++) {
            final Float32List samples = rendered[i] ?? Float32List(0);
            joined.setAll(offset, samples);
            offset += samples.length;
            if (i + 1 < rendered.length) {
              final int gapMs = voices[i] == voices[i + 1]
                  ? lineGapMs
                  : speakerGapMs;
              offset += (hz * gapMs / 1000).round();
            }
          }
          sherpa.writeWave(
            filename: temporary,
            samples: joined,
            sampleRate: hz,
          );
          final File partial = File(temporary);
          if (!partial.existsSync() || partial.lengthSync() < 44) {
            throw StateError('The synthesiser produced an invalid WAV');
          }
          final File target = File(path);
          if (target.existsSync()) target.deleteSync();
          partial.renameSync(path);
          result = path;
        } catch (_) {
          final File partial = File(temporary);
          if (partial.existsSync()) partial.deleteSync();
          result = null;
        }
        replies?.send(<Object?>[id, result]);
      case 'stop':
        commands.close();
    }
  });
}
