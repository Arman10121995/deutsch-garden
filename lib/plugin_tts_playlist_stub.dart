import 'package:flutter_tts/flutter_tts.dart';

import 'neural_voice.dart';

Future<String?> synthesisePluginPlaylist({
  required FlutterTts tts,
  required List<NeuralTurn> turns,
  required List<Map<String, String>> germanVoices,
  required double speechRate,
  required Duration speakerGap,
  required Duration lineGap,
}) async => null;
