import 'dart:async';
import 'dart:io';

import 'package:deutsch_garden/neural_tts.dart';
import 'package:deutsch_garden/neural_tts_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('both bundled voices render off the UI isolate and are cached', (
    WidgetTester tester,
  ) async {
    final NeuralTts tts = NeuralTts.instance;
    // Printed timestamps are retained because this is a native integration
    // probe: when a platform runner stalls, they identify whether loading,
    // synthesis or cache replay failed without changing production logging.
    // ignore: avoid_print
    print('neural integration: initialise start ${DateTime.now()}');
    expect(await tts.initialise(), isTrue);
    // ignore: avoid_print
    print('neural integration: initialise done ${DateTime.now()}');

    final String nonce = DateTime.now().microsecondsSinceEpoch.toString();
    final String text = <String>[
      'Dies ist ein vollständiger Test der gebündelten deutschen Stimme.',
      'Während dieser längere Absatz gesprochen wird, muss die Oberfläche',
      'weiterhin Bilder zeichnen, Eingaben annehmen und Zeitgeber ausführen.',
      'Die Synthese läuft deshalb in einem eigenen Isolat und nicht in dem',
      'Isolat, das Flutter für die Benutzeroberfläche verwendet.',
      'Nach der ersten Erzeugung wird dieselbe Aufnahme aus dem lokalen',
      'Zwischenspeicher geladen. Testkennung $nonce.',
    ].join(' ');

    var ticks = 0;
    final Timer heartbeat = Timer.periodic(
      const Duration(milliseconds: 10),
      (_) => ticks++,
    );
    // ignore: avoid_print
    print('neural integration: synthesis start ${DateTime.now()}');
    final String? path = await tts.synthesiseToFile(
      text,
      voice: NeuralVoice.thorsten,
    );
    // ignore: avoid_print
    print('neural integration: synthesis done ${DateTime.now()} path=$path');
    heartbeat.cancel();

    expect(path, isNotNull);
    expect(
      ticks,
      greaterThan(10),
      reason: 'synchronous FFI synthesis blocked the Flutter isolate',
    );

    final File wave = File(path!);
    expect(
      wave.uri.pathSegments.last,
      matches(RegExp(r'^thorsten-utterance-[0-9a-f]{16}-100\.wav$')),
    );
    expect(await wave.length(), greaterThan(44));
    final RandomAccessFile input = await wave.open();
    final List<int> header = await input.read(12);
    await input.close();
    expect(hasWaveHeader(header), isTrue);

    final Stopwatch replay = Stopwatch()..start();
    expect(await tts.synthesiseToFile(text, voice: NeuralVoice.thorsten), path);
    replay.stop();
    expect(
      replay.elapsed,
      lessThan(const Duration(milliseconds: 500)),
      reason: 'a cached utterance was synthesised again',
    );

    final String? secondPath = await tts.synthesiseToFile(
      'Guten Tag! Ich bin die zweite deutsche Stimme. $nonce',
      voice: NeuralVoice.kerstin,
    );
    expect(secondPath, isNotNull);
    expect(secondPath, isNot(path));
    final File secondWave = File(secondPath!);
    expect(
      secondWave.uri.pathSegments.last,
      matches(RegExp(r'^kerstin-utterance-[0-9a-f]{16}-100\.wav$')),
    );
    expect(await secondWave.length(), greaterThan(44));
    final RandomAccessFile secondInput = await secondWave.open();
    expect(hasWaveHeader(await secondInput.read(12)), isTrue);
    await secondInput.close();

    tts.dispose();
  });
}
