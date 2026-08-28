/// Web fallback for voice capture.
///
/// `dart:io` does not exist in the browser, and more to the point neither does
/// the bundled voice, so there is no reference audio to score against. The web
/// build scores pronunciation from the recognised words, as it always has.
library;

enum RecorderAvailability { unknown, ready, denied, unsupported }

class VoiceRecorder {
  VoiceRecorder();

  RecorderAvailability availability = RecorderAvailability.unsupported;
  String lastError = '';

  bool get isRecording => false;

  Future<bool> initialise() async => false;

  Future<bool> start(String directoryPath) async => false;

  Future<String?> stop() async => null;

  Future<void> cancel() async {}

  Future<void> dispose() async {}

  String get unavailableReason =>
      'The web build has no bundled voice to compare against, so pronunciation '
      'is scored from the recognised words.';
}
