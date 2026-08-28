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
  await controller.load();
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
  // Which vocabulary cards have a drawing. One manifest read, so the word
  // list can decide per card without attempting a load that will usually fail.
  unawaited(loadVocabIconIndex(rootBundle));

  unawaited(NeuralTts.instance.initialise());
}
