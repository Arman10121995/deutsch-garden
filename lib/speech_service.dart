import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Why the microphone is not usable, so the UI can explain itself instead of
/// silently offering a button that does nothing.
enum SpeechAvailability { unknown, ready, denied, unsupported }

/// Thin wrapper around on-device speech recognition.
///
/// Recognition runs through the platform engine (Android SpeechRecognizer /
/// iOS Speech framework). Nothing is sent to a DeutschGarden server, because
/// there is no DeutschGarden server. On Android the engine may still use
/// Google's cloud recogniser unless an offline language pack is installed;
/// that is a platform choice and is documented in docs/PRIVACY.md.
class SpeechService {
  SpeechService();

  final SpeechToText _speech = SpeechToText();

  SpeechAvailability availability = SpeechAvailability.unknown;
  bool _initialized = false;
  String? _germanLocaleId;
  String lastError = '';

  bool get isListening => _speech.isListening;
  bool get isReady => availability == SpeechAvailability.ready;

  Future<bool> initialize() async {
    if (_initialized) return isReady;
    _initialized = true;
    try {
      final bool available = await _speech.initialize(
        onError: (SpeechRecognitionError error) {
          lastError = error.errorMsg;
        },
        onStatus: (String status) {},
        debugLogging: false,
      );
      if (!available) {
        availability = SpeechAvailability.denied;
        return false;
      }
      availability = SpeechAvailability.ready;
      await _resolveGermanLocale();
      return true;
    } catch (error) {
      lastError = error.toString();
      availability = SpeechAvailability.unsupported;
      return false;
    }
  }

  Future<void> _resolveGermanLocale() async {
    try {
      final List<LocaleName> locales = await _speech.locales();
      for (final LocaleName locale in locales) {
        final String id = locale.localeId.toLowerCase();
        if (id.startsWith('de_de') || id.startsWith('de-de')) {
          _germanLocaleId = locale.localeId;
          return;
        }
      }
      for (final LocaleName locale in locales) {
        if (locale.localeId.toLowerCase().startsWith('de')) {
          _germanLocaleId = locale.localeId;
          return;
        }
      }
    } catch (_) {
      // Locale enumeration is best effort; the default locale still works.
    }
  }

  /// Starts listening and streams partial transcripts through [onTranscript].
  ///
  /// Returns false when the microphone could not be started, which lets the
  /// caller fall back to typed input rather than leaving a dead button.
  Future<bool> listen({
    required void Function(String transcript, bool isFinal) onTranscript,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
    void Function(double level)? onLevel,
  }) async {
    if (!await initialize()) return false;
    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          onTranscript(result.recognizedWords, result.finalResult);
        },
        onSoundLevelChange: onLevel,
        listenOptions: SpeechListenOptions(
          localeId: _germanLocaleId,
          listenFor: listenFor,
          pauseFor: pauseFor,
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
      );
      return true;
    } catch (error) {
      lastError = error.toString();
      return false;
    }
  }

  Future<void> stop() async {
    if (!_initialized) return;
    try {
      await _speech.stop();
    } catch (_) {
      // Stopping a recogniser that already stopped is harmless.
    }
  }

  Future<void> cancel() async {
    if (!_initialized) return;
    try {
      await _speech.cancel();
    } catch (_) {
      // As above.
    }
  }

  String get unavailableReason {
    switch (availability) {
      case SpeechAvailability.ready:
        return '';
      case SpeechAvailability.denied:
        return 'Microphone or speech recognition permission was refused. '
            'Grant it in system settings, or keep typing your answers.';
      case SpeechAvailability.unsupported:
        return 'This device has no speech recognition service available. '
            'You can still type every answer.';
      case SpeechAvailability.unknown:
        return 'Speech recognition has not been started yet.';
    }
  }
}
