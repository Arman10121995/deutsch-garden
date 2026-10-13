/// Offline measurement of collected learner recordings; no model download or
/// accuracy claim. See docs/SPEECH_VALIDATION.md for the corpus protocol.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:deutsch_garden/acoustic.dart';
import 'package:deutsch_garden/pronunciation_audio.dart';

List<String> transcriptWords(String text) =>
    RegExp(r"[\p{L}\p{N}]+(?:['’][\p{L}\p{N}]+)*", unicode: true)
        .allMatches(text.toLowerCase().replaceAll('’', "'"))
        .map((m) => m.group(0)!)
        .toList();

class WordErrors {
  const WordErrors(
    this.substitutions,
    this.deletions,
    this.insertions,
    this.referenceWords,
  );
  final int substitutions, deletions, insertions, referenceWords;
  int get errors => substitutions + deletions + insertions;
  double get wer => errors / referenceWords;
  Map<String, Object> toJson() => {
    'substitutions': substitutions,
    'deletions': deletions,
    'insertions': insertions,
    'referenceWords': referenceWords,
    'wer': wer,
  };
}

/// Standard word edit distance. The reference is a human transcript of the
/// recording, never the sentence the learner was asked to say.
WordErrors wordErrors(String reference, String hypothesis) {
  final a = transcriptWords(reference), b = transcriptWords(hypothesis);
  if (a.isEmpty) {
    throw const FormatException('Reference transcript has no words');
  }
  var previous = List.generate(
    b.length + 1,
    (j) => WordErrors(0, 0, j, a.length),
  );
  for (int i = 1; i <= a.length; i++) {
    final current = <WordErrors>[WordErrors(0, i, 0, a.length)];
    for (int j = 1; j <= b.length; j++) {
      final diagonal = previous[j - 1],
          above = previous[j],
          left = current[j - 1];
      final choices = [
        WordErrors(
          diagonal.substitutions + (a[i - 1] == b[j - 1] ? 0 : 1),
          diagonal.deletions,
          diagonal.insertions,
          a.length,
        ),
        WordErrors(
          above.substitutions,
          above.deletions + 1,
          above.insertions,
          a.length,
        ),
        WordErrors(
          left.substitutions,
          left.deletions,
          left.insertions + 1,
          a.length,
        ),
      ];
      current.add(choices.reduce((x, y) => x.errors <= y.errors ? x : y));
    }
    previous = current;
  }
  return previous.last;
}

class ValidationWave {
  const ValidationWave(this.samples, this.sampleRate);
  final Float64List samples;
  final int sampleRate;
}

/// Explicitly supports PCM16 mono/stereo only. Reject other encodings rather
/// than silently interpreting floating-point audio as integer samples.
ValidationWave readValidationWave(Uint8List bytes) {
  String ascii(int at, int count) => asciiDecode(bytes.sublist(at, at + count));
  if (bytes.length < 44 || ascii(0, 4) != 'RIFF' || ascii(8, 4) != 'WAVE') {
    throw const FormatException('Not a RIFF/WAVE recording');
  }
  final data = ByteData.sublistView(bytes);
  if (data.getUint32(4, Endian.little) + 8 != bytes.length) {
    throw const FormatException('WAV size does not match the file');
  }
  int? rate, channels, align;
  Uint8List? pcm;
  for (int at = 12; at + 8 <= bytes.length;) {
    final length = data.getUint32(at + 4, Endian.little), start = at + 8;
    final end = start + length;
    if (end > bytes.length) throw const FormatException('Truncated WAV chunk');
    if (ascii(at, 4) == 'fmt ') {
      if (length < 16 ||
          data.getUint16(start, Endian.little) != 1 ||
          data.getUint16(start + 14, Endian.little) != 16) {
        throw const FormatException('Convert recording to PCM16 WAV first');
      }
      channels = data.getUint16(start + 2, Endian.little);
      rate = data.getUint32(start + 4, Endian.little);
      align = data.getUint16(start + 12, Endian.little);
      if (channels < 1 ||
          channels > 2 ||
          rate < 8000 ||
          rate > 96000 ||
          align != channels * 2 ||
          data.getUint32(start + 8, Endian.little) != rate * align) {
        throw const FormatException('Invalid PCM16 WAV format');
      }
    } else if (ascii(at, 4) == 'data') {
      if (pcm != null) throw const FormatException('Multiple WAV data chunks');
      pcm = Uint8List.sublistView(bytes, start, end);
    }
    at = end + (length.isOdd ? 1 : 0);
  }
  if (rate == null ||
      channels == null ||
      align == null ||
      pcm == null ||
      pcm.isEmpty ||
      pcm.length % align != 0 ||
      pcm.length ~/ align > rate * 30) {
    throw const FormatException(
      'Expected a nonempty recording of at most 30 seconds',
    );
  }
  return ValidationWave(pcm16ToMono(pcm, channels: channels), rate);
}

String asciiDecode(List<int> bytes) => String.fromCharCodes(bytes);

Map<String, Object?> summarizeSpeech(List<Map<String, Object?>> rows) {
  final words = rows.fold<int>(
    0,
    (sum, r) => sum + (r['referenceWords'] as int),
  );
  final errors = rows.fold<int>(0, (sum, r) => sum + (r['wordErrors'] as int));
  final rated = rows.where((r) => r['humanScore'] != null).toList();
  return {
    'recordings': rows.length,
    'speakers': rows.map((r) => r['speakerId']).toSet().length,
    'referenceWords': words, 'wordErrors': errors,
    // Micro-average, not a mean of per-utterance percentages.
    'wer': words == 0 ? null : errors / words,
    'exactTranscripts': rows.where((r) => r['wordErrors'] == 0).length,
    'humanRatedRecordings': rated.length,
    'meanAbsoluteScoreError': rated.isEmpty
        ? null
        : rated.fold<double>(
                0,
                (sum, r) =>
                    sum +
                    ((r['acousticScore'] as int) - (r['humanScore'] as num))
                        .abs(),
              ) /
              rated.length,
  };
}

Future<Map<String, Object?>> evaluateSpeech(File manifest) async {
  final input =
      jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
  final model = input['recognizer'];
  if (model is! String || model.trim().isEmpty) {
    throw const FormatException(
      'Name the recognizer and model/version used to collect transcripts',
    );
  }
  final clips = input['clips'];
  if (clips is! List || clips.isEmpty) {
    throw const FormatException('No recordings in corpus');
  }
  final ids = <String>{};
  final rows = <Map<String, Object?>>[];
  for (final raw in clips) {
    final clip = raw as Map<String, dynamic>;
    String field(String key) {
      final value = clip[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing $key in ${clip['id']}');
      }
      return value;
    }

    final id = field('id');
    if (!ids.add(id)) throw FormatException('Duplicate recording id: $id');
    final humanScore = clip['humanScore'];
    if (humanScore != null &&
        (humanScore is! num ||
            !humanScore.isFinite ||
            humanScore < 0 ||
            humanScore > 100)) {
      throw FormatException('humanScore must be in 0..100 for $id');
    }
    final hypothesis = clip['recognizerTranscript'];
    if (hypothesis is! String) {
      throw FormatException(
        'Missing recognizerTranscript for $id (use empty string if none)',
      );
    }
    final errors = wordErrors(field('referenceTranscript'), hypothesis);
    field('targetText'); // Required provenance of the synthesised reference.
    Future<ValidationWave> wave(String key) async {
      final path = field(key);
      final file = File.fromUri(manifest.absolute.uri.resolve(path));
      if (await file.length() > 12000000) {
        throw FormatException('Recording too large: $id/$key');
      }
      return readValidationWave(await file.readAsBytes());
    }

    final learner = await wave('learnerWav'),
        reference = await wave('referenceWav');
    final score = compareAudio(
      learner: prepare(learner.samples, learner.sampleRate),
      reference: prepare(reference.samples, reference.sampleRate),
      extractor: analysisExtractor(),
    );
    if (score.isEmpty) throw FormatException('No speech frames in $id');
    rows.add({
      'id': id,
      'speakerId': field('speakerId'),
      'level': field('level'),
      'condition': field('condition'),
      ...errors.toJson(),
      'wordErrors': errors.errors,
      'acousticScore': score.score,
      'distance': score.distance,
      'tempoRatio': score.tempoRatio,
      'humanScore': humanScore,
    });
  }
  Map<String, Object?> grouped(String key) {
    final values = rows.map((r) => r[key] as String).toSet().toList()..sort();
    return {
      for (final value in values)
        value: summarizeSpeech(rows.where((r) => r[key] == value).toList()),
    };
  }

  return {
    'recognizer': model,
    'analysisSampleRate': analysisSampleRate,
    'note':
        'Descriptive measurements only. Accuracy on learner German requires representative recordings and independent human ratings; no acceptance threshold has been established.',
    'overall': summarizeSpeech(rows),
    'bySpeaker': grouped('speakerId'),
    'byLevel': grouped('level'),
    'byCondition': grouped('condition'),
    'recordings': rows,
  };
}

Future<void> main(List<String> args) async {
  if (args.length != 1 || args.first == '--help') {
    stdout.writeln(
      'Usage: dart run tool/evaluate_speech.dart /path/to/corpus.json > report.json\nSee docs/SPEECH_VALIDATION.md. All inputs stay local.',
    );
    if (args.length != 1) exitCode = 64;
    return;
  }
  try {
    final report = await evaluateSpeech(File(args.single));
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
  } catch (error) {
    stderr.writeln('Speech validation failed: $error');
    exitCode = 1;
  }
}
