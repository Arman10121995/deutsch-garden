/// Device-independent end-of-speech detection for recorded speaking attempts.
///
/// Platform speech recognisers normally decide this themselves. DeutschGarden
/// also records audio when the optional offline recogniser is installed (and
/// for acoustic pronunciation feedback), so that path needs the same hands-off
/// behaviour without sending audio anywhere.
library;

import 'dart:math';

enum SpeechEndReason { silence, noSpeech, maximumDuration }

/// Consumes microphone levels in dBFS and reports when an utterance is over.
///
/// The threshold follows the room noise instead of assuming every microphone
/// has the same gain. Two consecutive voiced samples are required so a click
/// or a chair moving does not start an attempt. Once speech has begun, a short
/// run of quiet completes it; hard timeouts keep a damaged microphone from
/// recording forever.
class VoiceActivityDetector {
  VoiceActivityDetector({
    required this.startedAt,
    this.trailingSilence = const Duration(milliseconds: 1700),
    this.noSpeechTimeout = const Duration(seconds: 10),
    this.maximumDuration = const Duration(minutes: 3),
  });

  final DateTime startedAt;
  final Duration trailingSilence;
  final Duration noSpeechTimeout;
  final Duration maximumDuration;

  double _noiseFloor = -60;
  int _consecutiveVoice = 0;
  bool _speechStarted = false;
  DateTime? _lastVoiceAt;
  SpeechEndReason? _ended;

  bool get speechStarted => _speechStarted;
  SpeechEndReason? get ended => _ended;

  /// Adds one level sample. Returns a reason exactly once, then stays ended.
  SpeechEndReason? add(double dbfs, DateTime at) {
    if (_ended != null) return null;
    final Duration elapsed = at.difference(startedAt);
    if (elapsed >= maximumDuration) {
      _ended = SpeechEndReason.maximumDuration;
      return _ended;
    }

    // `record` documents 0/0 as the value on a platform without amplitude
    // support. Treat it as unknown rather than a permanently clipped voice.
    final bool usableLevel = dbfs.isFinite && dbfs < -0.5;
    if (!usableLevel) {
      if (!_speechStarted && elapsed >= noSpeechTimeout) {
        _ended = SpeechEndReason.noSpeech;
        return _ended;
      }
      return null;
    }

    // In a quiet room this settles around -48 dBFS; in a noisy room it rises,
    // but never above -32 dBFS, where ordinary background sound would become
    // "speech". Updating only while waiting prevents the learner's own voice
    // from becoming the new noise floor.
    if (!_speechStarted && dbfs < -24) {
      _noiseFloor = _noiseFloor * 0.85 + dbfs * 0.15;
    }
    final double threshold = min(-32, _noiseFloor + 12);
    final bool voiced = dbfs >= threshold;

    if (voiced) {
      _consecutiveVoice += 1;
      if (_consecutiveVoice >= 2) {
        _speechStarted = true;
        _lastVoiceAt = at;
      }
    } else {
      _consecutiveVoice = 0;
      if (_speechStarted &&
          _lastVoiceAt != null &&
          at.difference(_lastVoiceAt!) >= trailingSilence) {
        _ended = SpeechEndReason.silence;
        return _ended;
      }
    }

    if (!_speechStarted && elapsed >= noSpeechTimeout) {
      _ended = SpeechEndReason.noSpeech;
      return _ended;
    }
    return null;
  }
}
