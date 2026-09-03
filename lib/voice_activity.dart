/// Device-independent end-of-speech detection for recorded speaking attempts.
///
/// Platform speech recognisers normally decide this themselves. DeutschGarden
/// also records audio when the optional offline recogniser is installed (and
/// for acoustic pronunciation feedback), so that path needs the same hands-off
/// behaviour without sending audio anywhere.
library;


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

  /// Whether [_noiseFloor] has met the actual room yet.
  ///
  /// It used to start at a fixed -60 dBFS and creep towards the truth at
  /// 0.15 per sample. In a room at -30 that took about twenty samples, and
  /// long before then the still-low threshold had already declared the
  /// background to be speech -- which froze the floor, because it only
  /// updates while waiting. The room then counted as a voice for the rest of
  /// the recording. Seeding from the first sample removes that whole window.
  bool _noiseFloorSeeded = false;
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

    // The floor follows the room: fast downwards, slow upwards.
    //
    // Asymmetry is what keeps the learner's own voice out of it. A quieter
    // sample is evidence about the room and is taken almost at once; a louder
    // one might be speech, so it moves the floor only a little. Updating just
    // while waiting is a second guard on the same thing.
    if (!_speechStarted) {
      if (!_noiseFloorSeeded) {
        _noiseFloor = dbfs;
        _noiseFloorSeeded = true;
      } else if (dbfs < -18) {
        final double rate = dbfs < _noiseFloor ? 0.5 : 0.08;
        _noiseFloor = _noiseFloor * (1 - rate) + dbfs * rate;
      }
    }
    // Speech has to stand *above* the room, so the threshold tracks the noise
    // floor upwards.
    //
    // This was `min(-32, _noiseFloor + 12)`, which did the opposite: min takes
    // the more negative value, so once a real room pushed the floor up to
    // around -30 the threshold stayed pinned at -32 and the background itself
    // read as voiced. Every sample renewed the utterance, the trailing-silence
    // timer never ran, and recording continued to the hard maximum instead of
    // stopping when the learner did.
    //
    // The clamp keeps it sane at both ends: a near-silent room does not get a
    // threshold so low that the microphone's own hiss counts, and a very loud
    // one does not get a threshold no voice could cross.
    final double threshold = (_noiseFloor + 12).clamp(-50.0, -12.0);
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
