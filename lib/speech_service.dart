import 'dart:async';

import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'platform_support.dart';
import 'speech_locale.dart';

/// Why the microphone is not usable, so the UI can explain itself instead of
/// silently offering a button that does nothing.
enum SpeechAvailability {
  unknown,
  ready,
  denied,
  unsupported,
  germanUnavailable,
}

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
  void Function()? _onDone;
  bool _sessionActive = false;
  Timer? _terminalStatusTimer;

  bool get isListening => _speech.isListening;
  bool get isReady => availability == SpeechAvailability.ready;

  Future<bool> initialize() async {
    // Re-query after the learner installs a German language pack in settings.
    if (_initialized && availability != SpeechAvailability.germanUnavailable) {
      return isReady;
    }
    _initialized = true;

    // speech_to_text implements android, ios, macos, windows and web. On
    // Linux the plugin channel does not exist, so calling into it would throw
    // MissingPluginException on every attempt. Deciding up front lets the UI
    // say so once instead of failing per button press.
    if (!PlatformSupport.hasSpeechRecognition) {
      availability = SpeechAvailability.unsupported;
      return false;
    }

    try {
      final bool available = await _speech.initialize(
        onError: (SpeechRecognitionError error) {
          lastError = error.errorMsg;
          _completeSession();
        },
        onStatus: _handleStatus,
        debugLogging: false,
      );
      if (!available) {
        availability = SpeechAvailability.denied;
        return false;
      }
      availability = SpeechAvailability.ready;
      await _resolveGermanLocale();
      if (_germanLocaleId == null) {
        availability = SpeechAvailability.germanUnavailable;
        return false;
      }
      return true;
    } on MissingPluginException {
      availability = SpeechAvailability.unsupported;
      return false;
    } catch (error) {
      lastError = error.toString();
      availability = SpeechAvailability.unsupported;
      return false;
    }
  }

  Future<void> _resolveGermanLocale() async {
    try {
      final List<LocaleName> locales = await _speech.locales();
      _germanLocaleId = selectGermanLocale(locales).localeId;
    } catch (_) {
      // Enumeration can be unavailable even when listening is available.
      // Use an explicit German tag so the platform cannot choose its default.
      _germanLocaleId = defaultGermanLocaleId;
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
    bool onDevice = true,
    void Function(double level)? onLevel,
    void Function()? onDone,
  }) async {
    if (!await initialize()) return false;
    try {
      _terminalStatusTimer?.cancel();
      _onDone = onDone;
      _sessionActive = true;
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          onTranscript(result.recognizedWords, result.finalResult);
          if (result.finalResult) _completeSession();
        },
        onSoundLevelChange: onLevel,
        listenOptions: SpeechListenOptions(
          localeId: _germanLocaleId,
          listenFor: listenFor,
          pauseFor: pauseFor,
          partialResults: true,
          cancelOnError: true,
          // Prefer the downloaded OS language pack. Android documents this as
          // a preference rather than a guarantee, but it is the strongest
          // request the platform API exposes and keeps normal speaking
          // practice independent of a connection.
          onDevice: onDevice,
          listenMode: ListenMode.dictation,
        ),
      );
      return true;
    } catch (error) {
      lastError = error.toString();
      _cancelSessionCallback();
      return false;
    }
  }

  void _handleStatus(String status) {
    if (!_sessionActive || !isTerminalSpeechStatus(status)) return;
    // Several Android recognisers emit notListening/done before their final
    // result callback. Give that final transcript one event-loop beat, then
    // finish even if the engine never marks any result as final.
    _terminalStatusTimer?.cancel();
    _terminalStatusTimer = Timer(
      const Duration(milliseconds: 200),
      _completeSession,
    );
  }

  void _completeSession() {
    if (!_sessionActive) return;
    _terminalStatusTimer?.cancel();
    _terminalStatusTimer = null;
    _sessionActive = false;
    final void Function()? callback = _onDone;
    _onDone = null;
    callback?.call();
  }

  void _cancelSessionCallback() {
    _terminalStatusTimer?.cancel();
    _terminalStatusTimer = null;
    _sessionActive = false;
    _onDone = null;
  }

  Future<void> stop() async {
    if (!_initialized) return;
    try {
      await _speech.stop();
      _completeSession();
    } catch (_) {
      // Stopping a recogniser that already stopped is harmless.
    }
  }

  Future<void> cancel() async {
    if (!_initialized) return;
    _cancelSessionCallback();
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
        return PlatformSupport.speechRecognitionNote;
      case SpeechAvailability.germanUnavailable:
        return 'German speech recognition is not advertised by this device. '
            'Install a German speech language pack, or keep typing your answers.';
      case SpeechAvailability.unknown:
        return 'Speech recognition has not been started yet.';
    }
  }
}

/// Platform recognisers disagree about which of these arrives last.
bool isTerminalSpeechStatus(String status) {
  final String normalized = status.trim().toLowerCase();
  return normalized == SpeechToText.doneStatus.toLowerCase() ||
      normalized == SpeechToText.notListeningStatus.toLowerCase() ||
      normalized == 'donenoresult';
}
