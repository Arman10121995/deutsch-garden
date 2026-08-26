/// Web fallback for the bundled neural voice.
///
/// `dart:io` does not exist on the web, and sherpa-onnx needs real file paths,
/// so the real implementation lives in `neural_tts_io.dart` and is selected by
/// conditional import. On the web the browser speech synthesiser handles
/// German through flutter_tts, which is why there is nothing to do here.
class NeuralTts {
  NeuralTts._();

  static final NeuralTts instance = NeuralTts._();

  bool get isReady => false;
  bool get hasFailed => true;

  Future<bool> initialise() async => false;

  Future<String?> synthesiseToFile(String text, {double rate = 1.0}) async =>
      null;

  void dispose() {}
}
