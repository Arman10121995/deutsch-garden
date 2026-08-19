import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'platform_support.dart';
import 'system_tts_stub.dart'
    if (dart.library.io) 'system_tts_io.dart' as system_tts;

/// How German audio is being produced on this device.
enum TtsBackend {
  /// The flutter_tts plugin, backed by the OS speech engine.
  plugin,

  /// A local command-line synthesiser (`spd-say` / `espeak-ng`) on Linux.
  system,

  /// Nothing available; the UI disables audio controls and explains why.
  none,
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

  TtsBackend _backend = TtsBackend.none;
  bool _initialized = false;

  TtsBackend get backend => _backend;

  Future<TtsBackend> _ensureInitialized() async {
    if (_initialized) return _backend;
    _initialized = true;

    if (PlatformSupport.hasPluginTts) {
      try {
        await _tts.setLanguage('de-DE');
        await _tts.setSpeechRate(_defaultRate);
        await _tts.setPitch(1.0);
        await _tts.setVolume(1.0);
        _backend = TtsBackend.plugin;
        return _backend;
      } on MissingPluginException {
        // The plugin is declared for this platform but not registered in this
        // build. Fall through to the system synthesiser.
      } catch (_) {
        // A misconfigured engine should not take the whole app down.
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

  Future<bool> get isAvailable async =>
      await _ensureInitialized() != TtsBackend.none;

  Future<void> speakGerman(String text) async {
    if (text.trim().isEmpty) return;
    switch (await _ensureInitialized()) {
      case TtsBackend.plugin:
        try {
          await _tts.stop();
          await _tts.setLanguage('de-DE');
          await _tts.speak(text);
        } on MissingPluginException {
          _backend = TtsBackend.none;
        } catch (_) {
          // A failed utterance is not worth an error dialog.
        }
        break;
      case TtsBackend.system:
        await system_tts.systemTtsSpeak(text);
        break;
      case TtsBackend.none:
        break;
    }
  }

  Future<void> stop() async {
    switch (_backend) {
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
