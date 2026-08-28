import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'app_state.dart';
import 'neural_tts.dart';
import 'vocab_icon.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController();
  // Both are small startup reads and neither depends on the other. Loading
  // the icon index before the first frame avoids a race where the vocabulary
  // list builds without drawings and has no state change that would rebuild it.
  await Future.wait<void>(<Future<void>>[
    controller.load(),
    loadVocabIconIndex(rootBundle),
  ]);
  runApp(DeutschGardenApp(controller: controller));

  // Warm the bundled voice after the first frame, never before it.
  //
  // Loading it means staging 61 MB out of the asset bundle on first run and
  // then reading the model, which takes a few seconds. Doing that lazily on
  // the first tap of a speaker icon would freeze the app at exactly the moment
  // the learner asked for something; doing it before runApp would delay the
  // first frame instead. Neither is necessary: it can load while the learner
  // is still reading the home screen. A speech request that arrives mid-warmup
  // awaits the same future rather than starting a second load or falling back
  // prematurely, so the worst case is a short wait on the very first tap
  // instead of a permanent downgrade to the OS voice.
  unawaited(NeuralTts.instance.initialise());
}
