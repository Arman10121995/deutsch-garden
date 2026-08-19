import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() {
    _configure();
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> _configure() async {
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  Future<void> speakGerman(String text) async {
    await _tts.stop();
    await _tts.setLanguage('de-DE');
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
