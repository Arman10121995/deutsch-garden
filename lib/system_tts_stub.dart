/// Web fallback for the system speech synthesiser.
///
/// `dart:io` does not exist on the web, so the real implementation lives in
/// `system_tts_io.dart` and is selected by conditional import. On the web the
/// flutter_tts plugin handles speech, so this stub is never the active path.
Future<bool> systemTtsAvailable() async => false;

Future<bool> systemTtsSpeak(
  String text, {
  String locale = 'de',
  double rate = 1.0,
  double pitch = 1.0,
  bool waitForCompletion = false,
}) async => false;

Future<void> systemTtsStop() async {}

String get systemTtsBinaryName => '';
