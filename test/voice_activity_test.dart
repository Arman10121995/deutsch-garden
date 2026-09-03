import 'package:deutsch_garden/voice_activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _noisyRoom();
  test('speech followed by quiet ends the recording once', () {
    final DateTime start = DateTime(2026, 1, 1, 12);
    final VoiceActivityDetector detector = VoiceActivityDetector(
      startedAt: start,
      trailingSilence: const Duration(milliseconds: 1500),
    );

    expect(
      detector.add(-58, start.add(const Duration(milliseconds: 150))),
      isNull,
    );
    expect(
      detector.add(-22, start.add(const Duration(milliseconds: 300))),
      isNull,
    );
    expect(
      detector.add(-20, start.add(const Duration(milliseconds: 450))),
      isNull,
    );
    expect(detector.speechStarted, isTrue);
    expect(detector.add(-58, start.add(const Duration(seconds: 1))), isNull);
    expect(
      detector.add(-58, start.add(const Duration(seconds: 2))),
      SpeechEndReason.silence,
    );
    expect(
      detector.add(-58, start.add(const Duration(seconds: 3))),
      isNull,
      reason: 'completion must not be emitted twice',
    );
  });

  test('one noise spike does not count as an utterance', () {
    final DateTime start = DateTime(2026, 1, 1, 12);
    final VoiceActivityDetector detector = VoiceActivityDetector(
      startedAt: start,
      noSpeechTimeout: const Duration(seconds: 3),
    );

    detector.add(-18, start.add(const Duration(milliseconds: 200)));
    detector.add(-60, start.add(const Duration(milliseconds: 400)));
    expect(detector.speechStarted, isFalse);
    expect(
      detector.add(-60, start.add(const Duration(seconds: 3))),
      SpeechEndReason.noSpeech,
    );
  });

  test('maximum duration is a hard stop even during speech', () {
    final DateTime start = DateTime(2026, 1, 1, 12);
    final VoiceActivityDetector detector = VoiceActivityDetector(
      startedAt: start,
      maximumDuration: const Duration(seconds: 2),
    );

    detector.add(-20, start.add(const Duration(milliseconds: 200)));
    detector.add(-20, start.add(const Duration(milliseconds: 400)));
    expect(
      detector.add(-20, start.add(const Duration(seconds: 2))),
      SpeechEndReason.maximumDuration,
    );
  });
}

// ---------------------------------------------------------------------------
// Regression: a noisy room never stopped recording.
// ---------------------------------------------------------------------------

void _noisyRoom() {
  test('background noise does not count as speech forever', () {
    // The bug behind "auto-stop is wonky on Android". The threshold was
    // min(-32, floor + 12), and min takes the *more negative* value -- so
    // once the noise floor rose in a real room, the threshold stayed pinned
    // at -32 and the background itself sat above it. Every sample read as
    // voiced, the trailing-silence timer never ran, and the recording went
    // the full maximum duration instead of stopping when the learner did.
    final DateTime start = DateTime(2026, 1, 1, 12);
    final VoiceActivityDetector detector = VoiceActivityDetector(
      startedAt: start,
      trailingSilence: const Duration(milliseconds: 800),
      noSpeechTimeout: const Duration(seconds: 8),
      maximumDuration: const Duration(seconds: 20),
    );

    DateTime at = start;
    SpeechEndReason? reason;
    void feed(double dbfs, int ms) {
      at = at.add(Duration(milliseconds: ms));
      reason ??= detector.add(dbfs, at);
    }

    // A moderately noisy room: background around -30 dBFS.
    for (int i = 0; i < 20; i++) {
      feed(-30, 150);
    }
    // Then the learner speaks, clearly above the room.
    for (int i = 0; i < 10; i++) {
      feed(-12, 150);
    }
    expect(detector.speechStarted, isTrue, reason: 'speech must be detected');

    // And then stops. Background returns; this must end the utterance.
    for (int i = 0; i < 12; i++) {
      feed(-30, 150);
    }
    expect(reason, SpeechEndReason.silence,
        reason: 'the recording must end when the learner stops talking, not '
            'run to the maximum duration because the room is noisy');
  });
}
