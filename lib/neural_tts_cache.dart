import 'dart:convert';

import 'neural_voice.dart';

/// Stable file name for a rendered utterance.
///
/// Dart does not promise that [String.hashCode] is stable between runtimes.
/// A cache written by one app version must still be addressable by the next,
/// and two different German strings must not accidentally share a short
/// 32-bit name. A 63-bit FNV-1a variant over UTF-8 is small, deterministic and
/// sufficient for a local cache where this is an identifier rather than a
/// security boundary. Keeping the high sign bit clear also makes file names
/// identical on Dart runtimes that represent integers differently.
String neuralTtsCacheFileName(
  String text,
  double rate, {
  String voice = 'thorsten',
}) {
  final int rateMillis = (rate * 1000).round();
  final List<int> bytes = utf8.encode('$voice\u0000$rateMillis\u0000$text');
  var hash = 0xcbf29ce484222325;
  for (final int byte in bytes) {
    hash ^= byte;
    hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
  }
  final String digest = hash.toRadixString(16).padLeft(16, '0');
  return '$voice-utterance-$digest-${(rate * 100).round()}.wav';
}

/// Stable cache name for a complete multi-speaker programme.
///
/// Voice assignments and both pause lengths are part of the identity: changing
/// who speaks or making turn-taking easier to hear must never reuse an older
/// file whose sound no longer matches the player settings.
String neuralTtsPlaylistCacheFileName(
  Iterable<NeuralTurn> turns,
  double rate, {
  required Duration speakerGap,
  required Duration lineGap,
  String cacheSalt = '',
}) {
  final StringBuffer identity = StringBuffer()
    ..write('playlist\u0000')
    ..write(cacheSalt)
    ..write((rate * 1000).round())
    ..write('\u0000')
    ..write(speakerGap.inMilliseconds)
    ..write('\u0000')
    ..write(lineGap.inMilliseconds);
  for (final NeuralTurn turn in turns) {
    identity
      ..write('\u0000')
      ..write(turn.voice.name)
      ..write('\u0000')
      ..write(turn.text);
  }
  final List<int> bytes = utf8.encode(identity.toString());
  var hash = 0xcbf29ce484222325;
  for (final int byte in bytes) {
    hash ^= byte;
    hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
  }
  final String digest = hash.toRadixString(16).padLeft(16, '0');
  return 'programme-$digest-${(rate * 100).round()}.wav';
}

/// Minimum structural check before treating a file as a cached WAV.
///
/// It catches interrupted writes and unrelated files without decoding the
/// whole recording. The synthesiser writes PCM RIFF/WAVE files, whose first
/// twelve bytes are `RIFF`, a length, then `WAVE`.
bool hasWaveHeader(List<int> bytes) {
  if (bytes.length < 12) return false;
  return bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x41 &&
      bytes[10] == 0x56 &&
      bytes[11] == 0x45;
}
