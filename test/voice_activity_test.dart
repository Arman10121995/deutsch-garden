import 'package:deutsch_garden/voice_activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
