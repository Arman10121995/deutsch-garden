/// The real recogniser, on platforms that have a filesystem.
library;

import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'asr.dart';

SpeechRecogniser createSpeechRecogniser() => SherpaSpeechRecogniser();

/// Fetches bytes. Replaced in tests, which must not touch the network.
abstract class ModelFetcher {
  /// Emits (receivedBytes, totalBytes) as it writes to [target].
  Stream<List<int>> download(String url, File target);
}

class HttpModelFetcher implements ModelFetcher {
  const HttpModelFetcher();

  @override
  Stream<List<int>> download(String url, File target) async* {
    final HttpClient client = HttpClient();
    try {
      final HttpClientRequest request =
          await client.getUrl(Uri.parse(url));
      final HttpClientResponse response = await request.close();
      if (response.statusCode != 200) {
        throw HttpException('the server answered ${response.statusCode}');
      }
      final int total = response.contentLength;
      int received = 0;
      // Streamed to disk rather than held in memory: this is a hundred
      // megabytes, and a phone that has to hold all of it at once is a phone
      // that does not finish.
      final IOSink sink = target.openWrite();
      try {
        await for (final List<int> chunk in response) {
          sink.add(chunk);
          received += chunk.length;
          yield <int>[received, total];
        }
      } finally {
        await sink.close();
      }
    } finally {
      client.close(force: true);
    }
  }
}

class SherpaSpeechRecogniser implements SpeechRecogniser {
  SherpaSpeechRecogniser({
    this.fetcher = const HttpModelFetcher(),
    Directory? root,
  }) : _root = root;

  /// NVIDIA FastConformer German, int8, as repackaged for sherpa-onnx.
  ///
  /// CC-BY-4.0. Attribution ships in the installed directory, and the same
  /// note is shown in the app before the download is offered.
  static const String modelUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/'
      'sherpa-onnx-nemo-stt_de_fastconformer_hybrid_large_pc-int8.tar.bz2';

  static const int approximateBytes = 105 * 1024 * 1024;

  /// Integrity rests on HTTPS to a pinned host, which
  /// `tool/check_network_use.py` enforces: the transport authenticates GitHub,
  /// and the URL cannot be moved without failing the build.
  ///
  /// What that does *not* cover is the release asset being replaced upstream.
  /// A pinned SHA-256 would, and belongs here -- but only with the digest
  /// actually published for this file. Shipping a guessed one would break
  /// every install, and shipping one computed from whatever happened to
  /// download would verify nothing at all. So the gap is written down rather
  /// than papered over with a hash that only looks like assurance.
  static const String pinnedDigest = '';

  static const String attributionText =
      'German speech model: NVIDIA stt_de_fastconformer_hybrid_large_pc, '
      'CC-BY-4.0, repackaged for sherpa-onnx by the k2-fsa project. '
      'NVIDIA report 5.1% word error rate on Common Voice German, which is '
      'native read speech; accented learner speech will be worse.';

  final ModelFetcher fetcher;
  final Directory? _root;

  sherpa.OfflineRecognizer? _recognizer;
  AsrModelStatus _status =
      const AsrModelStatus(state: AsrModelState.absent);

  /// Desktop only, and that is a decision rather than a technical limit.
  ///
  /// The model would run perfectly well on a phone. What it cannot do is get
  /// there: `tool/patch_android_manifest.py` deliberately strips the INTERNET
  /// permission, so on Android the promise -- no server, works in aeroplane
  /// mode -- is enforced by the operating system rather than by this project
  /// remembering. Declaring INTERNET would hand that guarantee back for every
  /// learner, including the overwhelming majority who never open this setting,
  /// in exchange for an optional extra. Android and iOS also already have a
  /// system recogniser, and 105 MB over a mobile data plan is a poor default.
  ///
  /// Desktop is where the gap actually is: Linux has no recogniser at all, and
  /// speaking practice there has been score-without-words since 3.17.
  ///
  /// Reversing this is one line here plus the INTERNET permission in
  /// `tool/patch_android_manifest.py`; the cost of doing so is written down in
  /// `docs/ASSET_POLICY.md` so it is a decision and not a slip.
  @override
  bool get isSupported =>
      Platform.isLinux || Platform.isMacOS || Platform.isWindows;

  @override
  int get approximateDownloadBytes => approximateBytes;

  @override
  String get attribution => attributionText;

  Future<Directory> _modelDir() async {
    final Directory base =
        _root ?? await getApplicationSupportDirectory();
    return Directory(p.join(base.path, 'asr-de'));
  }

  /// The model and tokens files, found rather than assumed.
  ///
  /// The archive's internal layout is upstream's business and has changed
  /// before; hunting for the files is one line and survives a rename, whereas
  /// a hard-coded path fails at the worst possible moment — on a learner's
  /// device, after a hundred-megabyte download.
  Future<({File model, File tokens})?> _locate(Directory dir) async {
    if (!dir.existsSync()) return null;
    File? model;
    File? tokens;
    await for (final FileSystemEntity entity
        in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final String name = p.basename(entity.path).toLowerCase();
      if (name.endsWith('.onnx')) {
        // Prefer the quantised weights when both are present.
        if (model == null || name.contains('int8')) model = entity;
      } else if (name == 'tokens.txt') {
        tokens = entity;
      }
    }
    if (model == null || tokens == null) return null;
    return (model: model, tokens: tokens);
  }

  @override
  Future<AsrModelStatus> status() async {
    if (!isSupported) {
      return const AsrModelStatus(state: AsrModelState.unsupported);
    }
    if (_status.isBusy) return _status;
    final Directory dir = await _modelDir();
    final ({File model, File tokens})? files = await _locate(dir);
    _status = files == null
        ? const AsrModelStatus(state: AsrModelState.absent)
        : const AsrModelStatus(state: AsrModelState.ready);
    return _status;
  }

  @override
  Stream<AsrModelStatus> install() async* {
    if (!isSupported) {
      yield const AsrModelStatus(state: AsrModelState.unsupported);
      return;
    }
    final Directory dir = await _modelDir();
    final File archive = File(p.join(dir.parent.path, 'asr-de-download.tmp'));
    try {
      if (!dir.existsSync()) dir.createSync(recursive: true);

      _status = const AsrModelStatus(state: AsrModelState.downloading);
      yield _status;
      await for (final List<int> progress
          in fetcher.download(modelUrl, archive)) {
        _status = AsrModelStatus(
          state: AsrModelState.downloading,
          receivedBytes: progress[0],
          totalBytes: progress.length > 1 ? progress[1] : 0,
        );
        yield _status;
      }

      _status = const AsrModelStatus(state: AsrModelState.installing);
      yield _status;
      await _extract(archive, dir);

      final ({File model, File tokens})? files = await _locate(dir);
      if (files == null) {
        // Do not leave a half-installed directory claiming to be a model.
        if (dir.existsSync()) dir.deleteSync(recursive: true);
        _status = const AsrModelStatus(
          state: AsrModelState.failed,
          message: 'The download did not contain a usable model.',
        );
        yield _status;
        return;
      }
      File(p.join(dir.path, 'ATTRIBUTION.txt'))
          .writeAsStringSync(attributionText);
      _status = const AsrModelStatus(state: AsrModelState.ready);
      yield _status;
    } catch (error) {
      _status = AsrModelStatus(
        state: AsrModelState.failed,
        message: 'The model could not be installed: $error',
      );
      yield _status;
    } finally {
      if (archive.existsSync()) {
        try {
          archive.deleteSync();
        } catch (_) {
          // A stray temp file is not worth failing the install over.
        }
      }
    }
  }

  Future<void> _extract(File archive, Directory into) async {
    final Uint8List raw = await archive.readAsBytes();
    final List<int> tar = BZip2Decoder().decodeBytes(raw);
    final Archive entries = TarDecoder().decodeBytes(tar);
    for (final ArchiveFile entry in entries) {
      if (!entry.isFile) continue;
      // Never write outside the target: an archive naming ../../ is the
      // oldest trick there is, and this one comes off the network.
      final String name = entry.name.replaceAll(chr92, '/');
      if (name.contains('..')) continue;
      final File out = File(p.join(into.path, p.basename(name)));
      out.parent.createSync(recursive: true);
      out.writeAsBytesSync(entry.content as List<int>);
    }
  }

  static const String chr92 = r'\';

  @override
  Future<void> remove() async {
    await dispose();
    final Directory dir = await _modelDir();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    _status = const AsrModelStatus(state: AsrModelState.absent);
  }

  Future<sherpa.OfflineRecognizer?> _ensureRecognizer() async {
    if (_recognizer != null) return _recognizer;
    final Directory dir = await _modelDir();
    final ({File model, File tokens})? files = await _locate(dir);
    if (files == null) return null;
    sherpa.initBindings();
    _recognizer = sherpa.OfflineRecognizer(
      sherpa.OfflineRecognizerConfig(
        model: sherpa.OfflineModelConfig(
          nemoCtc: sherpa.OfflineNemoEncDecCtcModelConfig(
            model: files.model.path,
          ),
          tokens: files.tokens.path,
          numThreads: 1,
          debug: false,
        ),
      ),
    );
    return _recognizer;
  }

  @override
  Future<AsrResult> transcribe(List<double> samples, int sampleRate) async {
    if (!isSupported) {
      return const AsrResult.failed('not supported on this platform');
    }
    if (samples.isEmpty) {
      return const AsrResult.failed('there was no audio to read');
    }
    try {
      final sherpa.OfflineRecognizer? recognizer = await _ensureRecognizer();
      if (recognizer == null) {
        return const AsrResult.failed('the model is not installed');
      }
      final sherpa.OfflineStream stream = recognizer.createStream();
      try {
        stream.acceptWaveform(
          samples: Float32List.fromList(samples),
          sampleRate: sampleRate,
        );
        recognizer.decode(stream);
        return AsrResult(text: recognizer.getResult(stream).text, ok: true);
      } finally {
        stream.free();
      }
    } catch (error) {
      // The speaking lab has to survive this. An acoustic score with no
      // transcript is the behaviour from before the model existed.
      debugPrint('transcription failed: $error');
      return AsrResult.failed('$error');
    }
  }

  @override
  Future<AsrResult> transcribeFile(String path) async {
    if (!isSupported) {
      return const AsrResult.failed('not supported on this platform');
    }
    try {
      sherpa.initBindings();
      final sherpa.WaveData wave = sherpa.readWave(path);
      return await transcribe(
        List<double>.from(wave.samples.map((num s) => s.toDouble())),
        wave.sampleRate,
      );
    } catch (error) {
      return AsrResult.failed('the recording could not be read: $error');
    }
  }

  @override
  Future<void> dispose() async {
    _recognizer?.free();
    _recognizer = null;
  }
}
