import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../tool/evaluate_speech.dart';

Uint8List toneWave({bool silent = false, bool metadata = false}) {
  final pcm = Uint8List(22050);
  final view = ByteData.sublistView(pcm);
  if (!silent) {
    for (int i = 0; i < pcm.length ~/ 2; i++) {
      view.setInt16(
        i * 2,
        (12000 * math.sin(2 * math.pi * 440 * i / 22050)).round(),
        Endian.little,
      );
    }
  }
  final wave = Uint8List(44 + pcm.length + (metadata ? 10 : 0));
  final d = ByteData.sublistView(wave);
  void text(int at, String s) => wave.setRange(at, at + s.length, s.codeUnits);
  text(0, 'RIFF');
  d.setUint32(4, wave.length - 8, Endian.little);
  text(8, 'WAVE');
  text(12, 'fmt ');
  d.setUint32(16, 16, Endian.little);
  d.setUint16(20, 1, Endian.little);
  d.setUint16(22, 1, Endian.little);
  d.setUint32(24, 22050, Endian.little);
  d.setUint32(28, 44100, Endian.little);
  d.setUint16(32, 2, Endian.little);
  d.setUint16(34, 16, Endian.little);
  int at = 36;
  if (metadata) {
    text(at, 'JUNK');
    d.setUint32(at + 4, 1, Endian.little);
    at += 10;
  }
  text(at, 'data');
  d.setUint32(at + 4, pcm.length, Endian.little);
  wave.setRange(at + 8, wave.length, pcm);
  return wave;
}

void main() {
  test('WER counts errors and retains German letter distinctions', () {
    final exact = wordErrors('„Ich heiße Anna!“', 'ich heiße anna');
    expect(exact.errors, 0);
    expect(wordErrors('ich möchte kaffee', 'ich mag kaffee').substitutions, 1);
    expect(
      wordErrors('ich möchte einen kaffee', 'ich möchte kaffee').deletions,
      1,
    );
    expect(
      wordErrors('ich möchte kaffee', 'ich möchte einen kaffee').insertions,
      1,
    );
    expect(wordErrors('Straße schön', 'strasse schon').errors, 2);
    expect(wordErrors('ja', '').deletions, 1);
    expect(wordErrors('ja', 'ja noch viel mehr').wer, 3);
    expect(() => wordErrors('...', 'ja'), throwsFormatException);
  });

  test('corpus WER weights word counts and leaves human evidence missing', () {
    final summary = summarizeSpeech([
      {
        'speakerId': 'a',
        'referenceWords': 1,
        'wordErrors': 1,
        'humanScore': null,
      },
      {
        'speakerId': 'b',
        'referenceWords': 9,
        'wordErrors': 0,
        'humanScore': null,
      },
    ]);
    expect(summary['wer'], 0.1);
    expect(summary['humanRatedRecordings'], 0);
    expect(summary['meanAbsoluteScoreError'], isNull);
    expect(summary['speakers'], 2);
  });

  test('WAV metadata and chunk padding do not become audio samples', () {
    final plain = readValidationWave(toneWave());
    final tagged = readValidationWave(toneWave(metadata: true));
    expect(tagged.samples, orderedEquals(plain.samples));
    expect(tagged.sampleRate, 22050);
    final bad = toneWave();
    ByteData.sublistView(bad).setUint16(20, 3, Endian.little);
    expect(() => readValidationWave(bad), throwsFormatException);
    expect(
      () => readValidationWave(toneWave().sublist(0, 80)),
      throwsFormatException,
    );
  });

  test(
    'real runner compares stored outputs and does not invent human ratings',
    () async {
      final dir = await Directory.systemTemp.createTemp('garden-speech-test-');
      addTearDown(() => dir.delete(recursive: true));
      await File('${dir.path}/tone.wav').writeAsBytes(toneWave(metadata: true));
      final clip = <String, Object?>{
        'id': 'synthetic-pipeline-check',
        'speakerId': 'synthetic',
        'level': 'test',
        'condition': 'synthetic', 'targetText': 'ich möchte kaffee',
        // A learner omission is not an ASR error when it is heard correctly.
        'referenceTranscript': 'ich kaffee',
        'recognizerTranscript': 'ich kaffee',
        'learnerWav': 'tone.wav', 'referenceWav': 'tone.wav',
      };
      final manifest = File('${dir.path}/corpus.json');
      await manifest.writeAsString(
        jsonEncode({
          'recognizer': 'test fixture',
          'clips': [clip],
        }),
      );
      final report = await evaluateSpeech(manifest);
      final overall = report['overall'] as Map;
      expect(overall['wer'], 0);
      expect(overall['humanRatedRecordings'], 0);
      expect(overall['meanAbsoluteScoreError'], isNull);
      final row = (report['recordings'] as List).single as Map;
      expect(row['acousticScore'], 100);
      expect(row['distance'], 0);
      expect(row['tempoRatio'], 1);
      expect(report['note'], contains('no acceptance threshold'));

      await File('${dir.path}/tone.wav').writeAsBytes(toneWave(silent: true));
      await expectLater(evaluateSpeech(manifest), throwsFormatException);
      await manifest.writeAsString(
        jsonEncode({
          'recognizer': 'test',
          'clips': [clip, clip],
        }),
      );
      await File('${dir.path}/tone.wav').writeAsBytes(toneWave());
      await expectLater(evaluateSpeech(manifest), throwsFormatException);
    },
  );
}
