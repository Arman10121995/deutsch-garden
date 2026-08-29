/// Web has no filesystem to install a hundred-megabyte model into, and no way
/// to run it if it did.
///
/// The pronunciation lab still works: the acoustic score compares the learner's
/// audio with the bundled voice, which is what it did everywhere before this
/// existed. Only the transcript is missing.
library;

import 'asr.dart';

SpeechRecogniser createSpeechRecogniser() => const NoSpeechRecogniser();

class NoSpeechRecogniser implements SpeechRecogniser {
  const NoSpeechRecogniser();

  @override
  bool get isSupported => false;

  @override
  int get approximateDownloadBytes => 0;

  @override
  String get attribution => '';

  @override
  Future<AsrModelStatus> status() async =>
      const AsrModelStatus(state: AsrModelState.unsupported);

  @override
  Stream<AsrModelStatus> install() async* {
    yield const AsrModelStatus(state: AsrModelState.unsupported);
  }

  @override
  Future<void> remove() async {}

  @override
  Future<AsrResult> transcribe(List<double> samples, int sampleRate) async =>
      const AsrResult.failed('not available on the web');

  @override
  Future<AsrResult> transcribeFile(String path) async =>
      const AsrResult.failed('not available on the web');

  @override
  Future<void> dispose() async {}
}
