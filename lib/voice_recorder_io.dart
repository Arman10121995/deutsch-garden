/// Capturing the learner's voice as a waveform.
///
/// `speech_to_text` returns words and nothing else, which is all the text
/// comparison ever needed. Acoustic scoring needs the audio itself, so this
/// records a wav alongside — or instead of — recognition.
///
/// It matters most where recognition does not exist. On Linux there is no
/// `speech_to_text` implementation at all, so speaking practice has been
/// typed-only since the app shipped; recording works there, which means Linux
/// can have a pronunciation score even though it cannot have a transcript.
library;

import 'dart:async';
import 'dart:io';

import 'package:record/record.dart';

import 'pronunciation_audio.dart';
import 'voice_activity.dart';

/// Why recording is not available, when it is not.
enum RecorderAvailability { unknown, ready, denied, unsupported }

class VoiceRecorder {
  VoiceRecorder();

  final AudioRecorder _recorder = AudioRecorder();

  RecorderAvailability availability = RecorderAvailability.unknown;
  String lastError = '';
  String? _path;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Timer? _maximumTimer;

  bool get isRecording => _path != null;

  /// Ask once whether the microphone is usable.
  ///
  /// Separated from [start] so a screen can decide which controls to offer
  /// before the learner taps anything, rather than discovering the answer as
  /// a failure.
  Future<bool> initialise() async {
    if (availability == RecorderAvailability.ready) return true;
    try {
      final bool granted = await _recorder.hasPermission();
      availability = granted
          ? RecorderAvailability.ready
          : RecorderAvailability.denied;
      return granted;
    } catch (error) {
      // A platform without the plugin throws rather than answering, which is
      // the same shape of problem as a refused permission but not the same
      // cause, so it is reported separately.
      lastError = error.toString();
      availability = RecorderAvailability.unsupported;
      return false;
    }
  }

  /// Begin recording to a wav in [directory].
  ///
  /// Recorded at [analysisSampleRate] deliberately: that is the rate the
  /// bundled voice produces, so the learner's clip and the reference need no
  /// resampling before they are compared. Resampling one of them costs real
  /// score — see the note on `analysisSampleRate`.
  Future<bool> start(
    String directoryPath, {
    void Function(SpeechEndReason reason)? onSpeechEnd,
    void Function(double dbfs)? onLevel,
    Duration trailingSilence = const Duration(milliseconds: 1700),
    Duration noSpeechTimeout = const Duration(seconds: 10),
    Duration maximumDuration = const Duration(minutes: 3),
  }) async {
    if (!await initialise()) return false;
    try {
      await Directory(directoryPath).create(recursive: true);
      final String path = '$directoryPath/learner-utterance.wav';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: analysisSampleRate,
          numChannels: 1,
        ),
        path: path,
      );
      _path = path;
      if (onSpeechEnd != null) {
        _monitorVoice(
          onSpeechEnd: onSpeechEnd,
          onLevel: onLevel,
          trailingSilence: trailingSilence,
          noSpeechTimeout: noSpeechTimeout,
          maximumDuration: maximumDuration,
        );
      }
      return true;
    } catch (error) {
      lastError = error.toString();
      _path = null;
      return false;
    }
  }

  /// Stop and return the path of the recorded file, or null if nothing was
  /// captured.
  ///
  /// A path rather than a `File` so that this and the web stub have the same
  /// signature: a conditional import has to present one type to callers, and
  /// `dart:io` does not exist on the other side of it.
  Future<String?> stop() async {
    if (_path == null) return null;
    _stopVoiceMonitor();
    try {
      final String? result = await _recorder.stop();
      final String path = result ?? _path!;
      _path = null;
      final File file = File(path);
      if (!await file.exists()) return null;
      // A clip of a few hundred bytes is a header and nothing else, which
      // happens when the learner taps stop immediately.
      if (await file.length() < 1024) {
        await file.delete();
        return null;
      }
      return path;
    } catch (error) {
      lastError = error.toString();
      _path = null;
      return null;
    }
  }

  Future<void> cancel() async {
    if (_path == null) return;
    _stopVoiceMonitor();
    final String path = _path!;
    try {
      await _recorder.cancel();
    } catch (_) {
      // Cancelling an idle recorder is harmless.
    }
    _path = null;
    try {
      final File partial = File(path);
      if (await partial.exists()) await partial.delete();
    } catch (_) {
      // The recorder may already have removed the cancelled partial file.
    }
  }

  Future<void> dispose() async {
    _stopVoiceMonitor();
    await cancel();
    await _recorder.dispose();
  }

  /// Removes a completed speaking attempt after it has been transcribed.
  Future<void> deleteRecording(String path) async {
    try {
      final File file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A temporary learner recording must never make the lesson crash during
      // cleanup. The next recording uses the same name and replaces it.
    }
  }

  void _monitorVoice({
    required void Function(SpeechEndReason reason) onSpeechEnd,
    required void Function(double dbfs)? onLevel,
    required Duration trailingSilence,
    required Duration noSpeechTimeout,
    required Duration maximumDuration,
  }) {
    _stopVoiceMonitor();
    final VoiceActivityDetector detector = VoiceActivityDetector(
      startedAt: DateTime.now(),
      trailingSilence: trailingSilence,
      noSpeechTimeout: noSpeechTimeout,
      maximumDuration: maximumDuration,
    );
    bool completed = false;

    void finish(SpeechEndReason reason) {
      if (completed) return;
      completed = true;
      _stopVoiceMonitor();
      onSpeechEnd(reason);
    }

    _amplitudeSubscription = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 150))
        .listen(
          (Amplitude amplitude) {
            onLevel?.call(amplitude.current);
            final SpeechEndReason? reason = detector.add(
              amplitude.current,
              DateTime.now(),
            );
            if (reason != null) finish(reason);
          },
          onError: (_) {
            // The hard timer below still prevents an endless recording on a
            // platform that can record but cannot report amplitude.
          },
        );
    _maximumTimer = Timer(
      maximumDuration + const Duration(milliseconds: 250),
      () => finish(SpeechEndReason.maximumDuration),
    );
  }

  void _stopVoiceMonitor() {
    _maximumTimer?.cancel();
    _maximumTimer = null;
    final StreamSubscription<Amplitude>? subscription = _amplitudeSubscription;
    _amplitudeSubscription = null;
    if (subscription != null) unawaited(subscription.cancel());
  }

  String get unavailableReason {
    switch (availability) {
      case RecorderAvailability.ready:
        return '';
      case RecorderAvailability.denied:
        return 'Microphone permission was refused, so pronunciation cannot be '
            'scored. Grant it in system settings, or keep typing.';
      case RecorderAvailability.unsupported:
        return 'Recording is not available on this device, so pronunciation '
            'is scored from the recognised words alone.';
      case RecorderAvailability.unknown:
        return 'The microphone has not been started yet.';
    }
  }
}
