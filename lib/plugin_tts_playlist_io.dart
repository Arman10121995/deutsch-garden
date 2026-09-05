import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

import 'neural_tts_cache.dart';
import 'neural_voice.dart';
import 'wave_join.dart';
import 'voice_selection.dart';

final Map<String, Future<String?>> _inFlight = <String, Future<String?>>{};

/// Renders an Android system-TTS programme to one private, seekable WAV.
///
/// `flutter_tts` delegates this to Android's installed speech engine. No text
/// or audio leaves the device when an offline German voice is installed, and
/// the output lives in application support rather than shared storage.
Future<String?> synthesisePluginPlaylist({
  required FlutterTts tts,
  required List<NeuralTurn> turns,
  required List<Map<String, String>> germanVoices,
  required double speechRate,
  required Duration speakerGap,
  required Duration lineGap,
}) async {
  if (!Platform.isAndroid || turns.isEmpty) return null;
  final Directory support = await getApplicationSupportDirectory();
  final Directory cache = Directory('${support.path}/tts-os-programmes');
  await cache.create(recursive: true);
  final String roster = germanVoices
      .map(
        (Map<String, String> voice) => voice.entries
            .map(
              (MapEntry<String, String> entry) => '${entry.key}=${entry.value}',
            )
            .join(';'),
      )
      .join('|');
  final String fileName =
      'android-${neuralTtsPlaylistCacheFileName(turns, speechRate, speakerGap: speakerGap, lineGap: lineGap, cacheSalt: 'android-cast-v2\u0000$roster\u0000')}';
  final String path = '${cache.path}/$fileName';
  final File target = File(path);
  if (await _validWave(target)) return path;
  return _inFlight.putIfAbsent(
    path,
    () =>
        _render(
          tts: tts,
          turns: turns,
          germanVoices: germanVoices,
          speechRate: speechRate,
          speakerGap: speakerGap,
          lineGap: lineGap,
          target: target,
        ).whenComplete(() {
          _inFlight.remove(path);
        }),
  );
}

Future<String?> _render({
  required FlutterTts tts,
  required List<NeuralTurn> turns,
  required List<Map<String, String>> germanVoices,
  required double speechRate,
  required Duration speakerGap,
  required Duration lineGap,
  required File target,
}) async {
  final Directory parts = Directory('${target.path}.parts');
  try {
    if (await parts.exists()) await parts.delete(recursive: true);
    await parts.create(recursive: true);
    await tts.stop();
    await tts.setLanguage('de-DE');
    await tts.setSpeechRate(speechRate.clamp(0.05, 1.0));
    await tts.setVolume(1.0);
    await tts.awaitSynthCompletion(true);

    final List<Uint8List> recordings = <Uint8List>[];
    for (var i = 0; i < turns.length; i++) {
      final NeuralTurn turn = turns[i];
      // This is the fallback path: the device's own engine, not the bundled
      // cast. It rarely has five German voices, so the roster is spread over
      // however many it does have and pitch does the rest of the separating.
      final int role = turn.voice.index;

      // A voice the device refuses must not end the programme.
      //
      // This threw until 4.8.1, and the throw was reachable in a way it had
      // not been before: while only two roles existed the selection was
      // always index 0 or 1, and widening it to five roles started reaching
      // entries the engine will not accept -- network-only voices, or ones
      // it lists but cannot load. One rejection failed the whole playlist,
      // which fell back to plain sequential speech in a single voice. The
      // symptom was the opposite of the change that caused it: adding voices
      // made everything sound like one person.
      await selectGermanVoice(
        roleIndex: role,
        voices: germanVoices,
        setVoice: tts.setVoice,
      );

      // Pitch is keyed to the role, not to whichever voice was accepted, so
      // two characters sharing one system voice still differ. Narrator stays
      // near neutral and the characters fan out either side of it, so
      // neighbouring roles are never the closest pair.
      await tts.setPitch(germanPitchForRole(role));
      final File part = File('${parts.path}/turn-$i.wav');
      final Object? outcome = await tts.synthesizeToFile(
        turn.text,
        part.path,
        true,
      );
      if (outcome != 1 || !await _validWave(part)) {
        throw StateError('Android TTS did not create turn $i');
      }
      recordings.add(await part.readAsBytes());
    }

    final List<WaveSegment> segments = <WaveSegment>[];
    for (var i = 0; i < recordings.length; i++) {
      final Duration gap = i + 1 >= recordings.length
          ? Duration.zero
          : turns[i].voice == turns[i + 1].voice
          ? lineGap
          : speakerGap;
      segments.add(WaveSegment(recordings[i], gapAfter: gap));
    }
    final Uint8List joined = await Isolate.run<Uint8List>(
      () => joinWaveSegments(segments),
      debugName: 'android-tts-wave-join',
    );
    final File partial = File('${target.path}.part');
    await partial.writeAsBytes(joined, flush: true);
    if (!await _validWave(partial)) {
      throw StateError('Joined Android TTS programme is invalid');
    }
    if (await target.exists()) await target.delete();
    await partial.rename(target.path);
    return target.path;
  } catch (error, stackTrace) {
    debugPrint('Android TTS programme render failed: $error\n$stackTrace');
    final File partial = File('${target.path}.part');
    if (await partial.exists()) await partial.delete();
    return null;
  } finally {
    if (await parts.exists()) await parts.delete(recursive: true);
  }
}

Future<bool> _validWave(File file) async {
  try {
    if (!await file.exists() || await file.length() < 44) return false;
    return hasWaveHeader(
      await file
          .openRead(0, 12)
          .fold<List<int>>(
            <int>[],
            (List<int> bytes, List<int> chunk) => bytes..addAll(chunk),
          ),
    );
  } on FileSystemException {
    return false;
  }
}
