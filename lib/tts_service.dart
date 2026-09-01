import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'neural_tts.dart';
import 'platform_support.dart';
import 'system_tts_stub.dart'
    if (dart.library.io) 'system_tts_io.dart'
    as system_tts;

/// How German audio is being produced on this device.
enum TtsBackend {
  /// The bundled Piper voice, run on device through sherpa-onnx. Preferred
  /// where it loads, because it sounds the same on every platform and does not
  /// depend on which voices the operating system happens to have installed.
  neural,

  /// The flutter_tts plugin, backed by the OS speech engine.
  plugin,

  /// A local command-line synthesiser (`spd-say` / `espeak-ng`) on Linux.
  system,

  /// Nothing available; the UI disables audio controls and explains why.
  none,
}

/// Stable semantic speaker roles; screens do not need to know model names.
enum GermanVoiceRole { narrator, speakerA, speakerB }

class SpokenTurn {
  const SpokenTurn(this.text, {this.voice = GermanVoiceRole.narrator});

  final String text;
  final GermanVoiceRole voice;
}

/// German speech, routed to whichever synthesiser this platform actually has.
///
/// Android, iOS, macOS, Windows and web go through `flutter_tts`. Linux has no
/// flutter_tts implementation, so it goes through the system synthesiser
/// instead. Every path runs locally: no audio is streamed and no text leaves
/// the machine.
class TtsService {
  TtsService();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  TtsBackend _backend = TtsBackend.none;
  bool _initialized = false;
  bool _neuralDisabled = false;
  bool _pluginInitialized = false;
  final List<Map<String, String>> _germanPluginVoices = <Map<String, String>>[];
  int _playlistGeneration = 0;

  TtsBackend get backend => _backend;

  Future<TtsBackend> _ensureInitialized() async {
    if (_initialized) return _backend;
    _initialized = true;

    // The bundled voice first. It is the only path that sounds identical
    // everywhere, and on Linux it replaces espeak, which is the worst audio in
    // the app. If it does not load -- an unexpected architecture, a truncated
    // install -- the OS engine below still runs, so nothing regresses.
    if (!_neuralDisabled && await NeuralTts.instance.initialise()) {
      _backend = TtsBackend.neural;
      return _backend;
    }

    if (PlatformSupport.hasPluginTts) {
      if (await _ensurePluginInitialized()) {
        _backend = TtsBackend.plugin;
        return _backend;
      }
    }

    if (await system_tts.systemTtsAvailable()) {
      _backend = TtsBackend.system;
      return _backend;
    }

    _backend = TtsBackend.none;
    return _backend;
  }

  /// Slower than conversational German: learners need the word boundaries.
  /// Desktop engines tend to run faster at the same nominal rate.
  static double get _defaultRate => PlatformSupport.isDesktop ? 0.50 : 0.42;

  Future<bool> _ensurePluginInitialized() async {
    if (_pluginInitialized) return true;
    if (!PlatformSupport.hasPluginTts) return false;
    try {
      await _tts.setLanguage('de-DE');
      await _tts.setSpeechRate(_defaultRate);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      try {
        final Object? raw = await _tts.getVoices;
        if (raw is List) {
          for (final Object? item in raw) {
            if (item is! Map) continue;
            final String locale = item['locale']?.toString() ?? '';
            if (!locale.toLowerCase().startsWith('de')) continue;
            final Map<String, String> voice = <String, String>{};
            for (final Object? key in item.keys) {
              final Object? value = item[key];
              if (value != null) voice[key.toString()] = value.toString();
            }
            if (voice.isNotEmpty) _germanPluginVoices.add(voice);
          }
        }
      } catch (_) {
        // Voice enumeration is an enhancement. Pitch still separates roles.
      }
      _pluginInitialized = true;
      return true;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> get isAvailable async =>
      await _ensureInitialized() != TtsBackend.none;

  /// Speaks German, optionally faster or slower than the learner default.
  ///
  /// [rate] is a multiplier, not an absolute rate: 0.75 is three quarters of
  /// the normal pace. The dictation and shadowing screens offered speed chips
  /// that only ever set a field -- nothing was passed to the engine, so the
  /// audio never changed pace. This is the parameter they needed.
  Future<void> speakGerman(
    String text, {
    double rate = 1.0,
    GermanVoiceRole voice = GermanVoiceRole.narrator,
  }) async {
    _playlistGeneration += 1;
    await _speakGerman(text, rate: rate, voice: voice, waitForAudio: false);
  }

  /// Speaks turn-taking content in order, waiting for each voice to finish.
  Future<void> speakTurns(
    Iterable<SpokenTurn> turns, {
    double rate = 1.0,
  }) async {
    final int generation = ++_playlistGeneration;
    for (final SpokenTurn turn in turns) {
      if (generation != _playlistGeneration) return;
      await _speakGerman(
        turn.text,
        rate: rate,
        voice: turn.voice,
        waitForAudio: true,
      );
    }
  }

  Future<void> _speakGerman(
    String text, {
    required double rate,
    required GermanVoiceRole voice,
    required bool waitForAudio,
  }) async {
    if (text.trim().isEmpty) return;
    switch (await _ensureInitialized()) {
      case TtsBackend.neural:
        final String? wav = await NeuralTts.instance.synthesiseToFile(
          text,
          rate: rate,
          voice: voice == GermanVoiceRole.speakerB
              ? NeuralVoice.kerstin
              : NeuralVoice.thorsten,
        );
        if (wav == null) {
          // Synthesis failed for this utterance rather than at load time.
          // Speak it with the OS engine instead of going silent.
          _neuralDisabled = true;
          _initialized = false;
          _backend = TtsBackend.none;
          await _speakGerman(
            text,
            rate: rate,
            voice: voice,
            waitForAudio: waitForAudio,
          );
          return;
        }
        try {
          await _player.stop();
          final Future<void> completed = _player.onPlayerComplete.first;
          await _player.play(DeviceFileSource(wav));
          if (waitForAudio) {
            await completed.timeout(
              Duration(seconds: (text.length / 5).ceil().clamp(5, 180)),
              onTimeout: () {},
            );
          }
        } catch (_) {
          // A playback failure is not worth an error dialog.
        }
        break;
      case TtsBackend.plugin:
        try {
          await _ensurePluginInitialized();
          await _tts.stop();
          await _tts.setLanguage('de-DE');
          if (_germanPluginVoices.isNotEmpty) {
            final int index =
                voice == GermanVoiceRole.speakerB &&
                    _germanPluginVoices.length > 1
                ? 1
                : 0;
            await _tts.setVoice(_germanPluginVoices[index]);
          }
          await _tts.setSpeechRate((_defaultRate * rate).clamp(0.05, 1.0));
          await _tts.setPitch(voice == GermanVoiceRole.speakerB ? 1.16 : 0.96);
          await _tts.speak(text);
        } on MissingPluginException {
          _backend = TtsBackend.none;
        } catch (_) {
          // A failed utterance is not worth an error dialog.
        }
        break;
      case TtsBackend.system:
        await system_tts.systemTtsSpeak(
          text,
          rate: rate,
          pitch: voice == GermanVoiceRole.speakerB ? 1.2 : 1.0,
          waitForCompletion: waitForAudio,
        );
        break;
      case TtsBackend.none:
        break;
    }
  }

  /// Whether the active backend produces a real audio file.
  ///
  /// Only the bundled voice does. The OS engines are told to speak a string
  /// and give nothing back that can be scrubbed, paused mid-word or seeked --
  /// so a player with a progress bar and a skip-back button is offered on the
  /// neural path and withheld everywhere else, rather than shown as controls
  /// that quietly do nothing. That was the bug the speed chips had.
  bool get canScrub => _backend == TtsBackend.neural;

  /// Resolve the backend without speaking anything, so a screen can decide
  /// which transport controls to show before the first tap.
  Future<TtsBackend> ensureReady() => _ensureInitialized();

  /// Playback position. Only meaningful when [canScrub].
  Stream<Duration> get onPosition => _player.onPositionChanged;

  /// Total length of the current file. Only meaningful when [canScrub].
  Stream<Duration> get onDuration => _player.onDurationChanged;

  Stream<void> get onComplete => _player.onPlayerComplete;

  Future<void> seek(Duration to) async {
    if (!canScrub) return;
    try {
      await _player.seek(to < Duration.zero ? Duration.zero : to);
    } catch (_) {
      // Seeking a stopped player is harmless.
    }
  }

  Future<void> pause() async {
    if (!canScrub) {
      // Nothing else can pause: an OS engine mid-utterance can only be
      // stopped, and stopping is not pausing, so say so by doing it.
      await stop();
      return;
    }
    try {
      await _player.pause();
    } catch (_) {
      // Pausing an idle player is harmless.
    }
  }

  Future<void> resume() async {
    if (!canScrub) return;
    try {
      await _player.resume();
    } catch (_) {
      // Resuming a stopped player is harmless.
    }
  }

  Future<void> stop() async {
    _playlistGeneration += 1;
    if (_backend == TtsBackend.neural) {
      try {
        await _player.stop();
      } catch (_) {
        // Stopping an idle player is harmless.
      }
      return;
    }
    switch (_backend) {
      case TtsBackend.neural:
        // Handled above, before this switch.
        break;
      case TtsBackend.plugin:
        try {
          await _tts.stop();
        } catch (_) {
          // Stopping an idle engine is harmless.
        }
        break;
      case TtsBackend.system:
        await system_tts.systemTtsStop();
        break;
      case TtsBackend.none:
        break;
    }
  }

  /// Human-readable description of the active backend, shown in Settings.
  String describe() {
    switch (_backend) {
      case TtsBackend.neural:
        return 'Bundled German voices (Thorsten + Kerstin, on device)';
      case TtsBackend.plugin:
        return '${PlatformSupport.displayName} speech engine';
      case TtsBackend.system:
        final String binary = system_tts.systemTtsBinaryName;
        return binary.isEmpty
            ? 'System speech synthesiser'
            : 'System speech synthesiser ($binary)';
      case TtsBackend.none:
        return 'No speech synthesiser found';
    }
  }
}
