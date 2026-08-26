import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'neural_tts_cache.dart';

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
  /// copy of a 61 MB staging operation.
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

      // The worker sends its command port once the model is loaded, or null if
      // loading threw. A worker that never answers would hang the app, so the
      // handshake is bounded.
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

  String _pathFor(Directory dir, String text, double rate) =>
      '${dir.path}/${neuralTtsCacheFileName(text, rate)}';

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
  Future<bool> isCached(String text, {double rate = 1.0}) async {
    final Directory? dir = _voiceDir;
    if (dir == null) return false;
    return _isValidWave(File(_pathFor(dir, text, rate)));
  }

  /// Synthesises [text] to a wav file and returns its path, or null if the
  /// voice is not available.
  ///
  /// [rate] is a multiplier on the normal speaking pace, matching the
  /// interface the OS backend already exposes.
  Future<String?> synthesiseToFile(String text, {double rate = 1.0}) async {
    if (!await initialise()) return null;
    final SendPort? worker = _toWorker;
    final Directory? dir = _voiceDir;
    if (worker == null || dir == null) return null;

    final String path = _pathFor(dir, text, rate);

    // Check the cache *before* synthesising. This used to run the model first
    // and then skip only the file write, so every replay of an episode paid
    // the full generation cost again for a file that was already on disk.
    final File cached = File(path);
    if (await _isValidWave(cached)) return path;
    if (await cached.exists()) await cached.delete();

    final Future<String?>? running = _inFlight[path];
    if (running != null) return running;

    final int id = _nextRequest++;
    final Completer<String?> completer = Completer<String?>();
    _pending[id] = completer;

    final Future<String?> future = completer.future
        .timeout(
          const Duration(minutes: 3),
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

    worker.send(<Object?>['say', id, text, rate, path]);
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
  final String dataPath = boot[3]! as String;

  sherpa.OfflineTts tts;
  try {
    // Bindings are per-isolate, so this has to run here and not only on the
    // isolate that spawned this one.
    sherpa.initBindings();
    tts = sherpa.OfflineTts(
      sherpa.OfflineTtsConfig(
        model: sherpa.OfflineTtsModelConfig(
          vits: sherpa.OfflineTtsVitsModelConfig(
            model: modelPath,
            tokens: tokensPath,
            dataDir: dataPath,
          ),
          numThreads: 2,
          // The package defaults this to true, which prints the whole config
          // and per-utterance timings to the log on every call.
          debug: false,
        ),
        maxNumSenetences: 1,
      ),
    );
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
        final String temporary = '$path.part-$id';
        String? result;
        try {
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
        }
        replies?.send(<Object?>[id, result]);
      case 'stop':
        tts.free();
        commands.close();
    }
  });
}
