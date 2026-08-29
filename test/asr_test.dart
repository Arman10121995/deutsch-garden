import 'dart:io';

import 'package:archive/archive.dart';
import 'package:deutsch_garden/asr.dart';
import 'package:deutsch_garden/asr_io.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves a prepared archive without touching the network.
class FakeFetcher implements ModelFetcher {
  FakeFetcher(this.payload, {this.total = -1, this.failWith});

  final List<int> payload;
  final int total;
  final Object? failWith;
  int calls = 0;

  @override
  Stream<List<int>> download(String url, File target) async* {
    calls += 1;
    if (failWith != null) throw failWith!;
    final IOSink sink = target.openWrite();
    const int chunk = 64;
    int sent = 0;
    for (int i = 0; i < payload.length; i += chunk) {
      final List<int> slice =
          payload.sublist(i, (i + chunk).clamp(0, payload.length));
      sink.add(slice);
      sent += slice.length;
      yield <int>[sent, total < 0 ? payload.length : total];
    }
    await sink.close();
  }
}

/// A tar.bz2 shaped like the real model archive.
List<int> archiveWith(Map<String, String> files) {
  final Archive archive = Archive();
  for (final MapEntry<String, String> entry in files.entries) {
    final List<int> bytes = entry.value.codeUnits;
    archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
  }
  final List<int> tar = TarEncoder().encode(archive);
  return BZip2Encoder().encode(tar);
}

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('dg_asr_test_');
  });

  tearDown(() {
    try {
      root.deleteSync(recursive: true);
    } catch (_) {
      // Windows can hold a handle briefly; a stale temp dir is not a failure.
    }
  });

  SherpaSpeechRecogniser build(FakeFetcher fetcher) =>
      SherpaSpeechRecogniser(fetcher: fetcher, root: root);

  group('before anything is installed', () {
    test('reports absent, and the lab is expected to work anyway', () async {
      final SherpaSpeechRecogniser asr = build(FakeFetcher(const <int>[]));
      final AsrModelStatus status = await asr.status();
      expect(status.state, AsrModelState.absent);
      expect(status.isReady, isFalse);
    });

    test('transcribing without a model declines instead of throwing',
        () async {
      final SherpaSpeechRecogniser asr = build(FakeFetcher(const <int>[]));
      final AsrResult result = await asr.transcribe(<double>[0.1, 0.2], 16000);
      expect(result.ok, isFalse);
      expect(result.error, contains('not installed'));
    });

    test('says what the download costs before asking for it', () {
      final SherpaSpeechRecogniser asr = build(FakeFetcher(const <int>[]));
      expect(asr.approximateDownloadBytes, greaterThan(50 * 1024 * 1024));
      expect(asr.attribution, contains('CC-BY-4.0'));
      expect(asr.attribution, contains('learner speech will be worse'),
          reason: 'the accuracy caveat travels with the model, because 5.1% '
              'is native read speech and the learner is not that');
    });
  });

  group('installing', () {
    test('downloads, unpacks and reports ready', () async {
      final FakeFetcher fetcher = FakeFetcher(archiveWith(<String, String>{
        'model-dir/model.int8.onnx': 'not a real model, but a real file',
        'model-dir/tokens.txt': 'a b c',
      }));
      final SherpaSpeechRecogniser asr = build(fetcher);

      final List<AsrModelState> seen = <AsrModelState>[];
      await for (final AsrModelStatus status in asr.install()) {
        seen.add(status.state);
      }

      expect(seen.first, AsrModelState.downloading);
      expect(seen, contains(AsrModelState.installing));
      expect(seen.last, AsrModelState.ready);
      expect((await asr.status()).isReady, isTrue);
    });

    test('reports progress the caller can show', () async {
      final FakeFetcher fetcher = FakeFetcher(archiveWith(<String, String>{
        'm/model.onnx': 'x' * 4000,
        'm/tokens.txt': 'a',
      }));
      final SherpaSpeechRecogniser asr = build(fetcher);

      final List<double> progress = <double>[];
      await for (final AsrModelStatus status in asr.install()) {
        final double? value = status.progress;
        if (status.state == AsrModelState.downloading && value != null) {
          progress.add(value);
        }
      }
      expect(progress, isNotEmpty);
      expect(progress.last, closeTo(1.0, 0.001));
      expect(progress.first, lessThan(progress.last));
    });

    test('an unknown total leaves progress null rather than guessing at it',
        () async {
      final FakeFetcher fetcher = FakeFetcher(
        archiveWith(<String, String>{'m/model.onnx': 'x', 'm/tokens.txt': 'a'}),
        total: 0,
      );
      final SherpaSpeechRecogniser asr = build(fetcher);
      final List<AsrModelStatus> all = await asr.install().toList();
      final AsrModelStatus downloading =
          all.firstWhere((AsrModelStatus s) => s.state == AsrModelState.downloading);
      expect(downloading.progress, isNull);
    });

    test('finds the model whatever the archive calls its directory', () async {
      // The internal layout is upstream's business and has changed before. A
      // hard-coded path would fail on a learner's device after a 100 MB
      // download, which is the worst possible moment.
      final FakeFetcher fetcher = FakeFetcher(archiveWith(<String, String>{
        'some-renamed-dir-2027/nested/model.int8.onnx': 'weights',
        'some-renamed-dir-2027/nested/tokens.txt': 'a b',
      }));
      final SherpaSpeechRecogniser asr = build(fetcher);
      await asr.install().drain<void>();
      expect((await asr.status()).isReady, isTrue);
    });

    test('an archive with no model leaves nothing behind claiming to be one',
        () async {
      final FakeFetcher fetcher = FakeFetcher(archiveWith(<String, String>{
        'junk/readme.txt': 'nothing useful here',
      }));
      final SherpaSpeechRecogniser asr = build(fetcher);
      final List<AsrModelStatus> all = await asr.install().toList();

      expect(all.last.state, AsrModelState.failed);
      expect(all.last.message, contains('usable model'));
      expect((await asr.status()).state, AsrModelState.absent,
          reason: 'a half-installed directory must not report itself ready');
    });

    test('a failed download is reported, not thrown', () async {
      final SherpaSpeechRecogniser asr = build(FakeFetcher(
        const <int>[],
        failWith: const SocketException('no route to host'),
      ));
      final List<AsrModelStatus> all = await asr.install().toList();
      expect(all.last.state, AsrModelState.failed);
      expect(all.last.message, contains('could not be installed'));
    });

    test('the temporary download is cleaned up either way', () async {
      final SherpaSpeechRecogniser asr = build(FakeFetcher(
        const <int>[],
        failWith: const SocketException('interrupted'),
      ));
      await asr.install().drain<void>();
      final List<String> leftovers = root
          .listSync()
          .map((FileSystemEntity e) => e.path)
          .where((String path) => path.contains('download.tmp'))
          .toList();
      expect(leftovers, isEmpty);
    });

    test('the attribution is written beside the model it belongs to',
        () async {
      final SherpaSpeechRecogniser asr = build(FakeFetcher(
        archiveWith(<String, String>{
          'm/model.onnx': 'weights',
          'm/tokens.txt': 'a',
        }),
      ));
      await asr.install().drain<void>();
      final File note = File('${root.path}/asr-de/ATTRIBUTION.txt');
      expect(note.existsSync(), isTrue,
          reason: 'CC-BY-4.0 requires attribution to travel with the file');
      expect(note.readAsStringSync(), contains('NVIDIA'));
    });
  });

  group('removing', () {
    test('frees the space and reports absent again', () async {
      final SherpaSpeechRecogniser asr = build(FakeFetcher(
        archiveWith(<String, String>{
          'm/model.onnx': 'weights',
          'm/tokens.txt': 'a',
        }),
      ));
      await asr.install().drain<void>();
      expect((await asr.status()).isReady, isTrue);

      await asr.remove();
      expect((await asr.status()).state, AsrModelState.absent);
      expect(Directory('${root.path}/asr-de').existsSync(), isFalse);
    });
  });

  group('the archive is treated as untrusted', () {
    test('an entry naming a parent directory is not written', () async {
      // This comes off the network. An archive naming ../../ is the oldest
      // trick there is.
      final SherpaSpeechRecogniser asr = build(FakeFetcher(
        archiveWith(<String, String>{
          '../../escaped.txt': 'should never be written',
          'm/model.onnx': 'weights',
          'm/tokens.txt': 'a',
        }),
      ));
      await asr.install().drain<void>();
      expect(File('${root.parent.path}/escaped.txt').existsSync(), isFalse);
      expect(File('${root.path}/escaped.txt').existsSync(), isFalse);
    });
  });
}
