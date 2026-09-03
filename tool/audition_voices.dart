// Renders the same German line in several voices, so a human can choose one.
//
// Which voice sounds right is the one part of a voice swap that cannot be
// decided from a file, and it kept being deferred for exactly that reason.
// This exists so the choice is made by listening, and so it can be repeated
// whenever the shortlist changes.
//
// It also records what the search found, because the obvious answer was wrong
// twice over. Piper publishes no medium-quality Kerstin, so the bundled second
// voice cannot simply be upgraded in place. The apparent alternative,
// de_DE-mls-medium at 22050 Hz, is a 236-speaker model and is *not* in
// sherpa-onnx's pre-converted collection: the raw Piper export lacks the
// metadata sherpa requires and dies with "'sample_rate' does not exist in the
// metadata". What does exist there, and was absent from Piper's own
// voices.json entirely, is de_DE-dii-high and de_DE-miro-high -- single
// speaker German voices at 22050 Hz and high quality, about the same size as
// the low-quality voice they would replace.
//
// Not part of the app or the build. Run it by hand:
//
//   dart run tool/audition_voices.dart MODEL TOKENS ESPEAK_DIR OUT_DIR [sids]
//
// With more than one sid, each rendering announces its own id first, so a
// multi-speaker model can be auditioned in a single pass.
import 'dart:ffi';
import 'dart:io';

import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Loads the ONNX Runtime that ships with sherpa_onnx, by absolute path.
///
/// Windows searches System32 before PATH when one DLL asks for another, and
/// `C:\Windows\System32\onnxruntime.dll` is a much older runtime here (1.17.1,
/// API 17). sherpa-onnx 1.13.6 asks for API 27 and the process dies with an
/// access violation before any Dart error can be raised. Opening the correct
/// library first puts a module with that base name in the process, and the
/// loader then reuses it instead of searching.
///
/// The app itself never hits this: its DLLs sit beside the executable, which
/// *is* searched first. Only host-run tooling like this needs the nudge.
void _preloadOnnxRuntime(String? explicit) {
  if (!Platform.isWindows) return;
  final List<String> candidates = <String>[
    ?explicit,
    r'build\windows\x64\runner\Release\onnxruntime.dll',
    r'build\windows\x64\runner\Debug\onnxruntime.dll',
  ];
  for (final String path in candidates) {
    final File file = File(path);
    if (!file.existsSync()) continue;
    try {
      DynamicLibrary.open(file.absolute.path);
      stdout.writeln('using onnxruntime from ${file.absolute.path}');
      return;
    } catch (_) {
      // Try the next candidate rather than failing here: the useful error is
      // the one sherpa raises when no usable runtime was found at all.
    }
  }
  stderr.writeln(
    'warning: no bundled onnxruntime.dll found; the system one may be too old',
  );
}

const String sentence =
    'Guten Morgen! Wie geht es Ihnen heute? Ich hätte gern einen Kaffee.';

void main(List<String> args) {
  if (args.length < 4) {
    stderr.writeln(
      'usage: dart run tool/audition_mls_speakers.dart '
      '<model.onnx> <tokens.txt> <espeak-data-dir> <out-dir> [sids]',
    );
    exit(2);
  }
  final String model = args[0];
  final String tokens = args[1];
  final String data = args[2];
  final Directory out = Directory(args[3])..createSync(recursive: true);
  final List<int> sids = args.length > 4
      ? args[4].split(',').map((String s) => int.parse(s.trim())).toList()
      : <int>[0, 30, 60, 90, 120, 150, 180, 210];

  _preloadOnnxRuntime(Platform.environment['DG_ONNXRUNTIME']);
  sherpa.initBindings();
  final sherpa.OfflineTts tts = sherpa.OfflineTts(
    sherpa.OfflineTtsConfig(
      model: sherpa.OfflineTtsModelConfig(
        vits: sherpa.OfflineTtsVitsModelConfig(
          model: model,
          tokens: tokens,
          dataDir: data,
        ),
        numThreads: 2,
        debug: false,
      ),
      maxNumSenetences: 1,
    ),
  );

  try {
    for (final int sid in sids) {
      // Only announce the id when there is a choice to make. A
      // single-speaker voice does not need to say "Sprecher 0" first.
      final String line = sids.length > 1 ? 'Sprecher $sid. $sentence'
                                          : sentence;
      final sherpa.GeneratedAudio audio = tts.generate(
        text: line,
        sid: sid,
        speed: 1.0,
      );
      final String path = '${out.path}/speaker-$sid.wav';
      sherpa.writeWave(
        filename: path,
        samples: audio.samples,
        sampleRate: audio.sampleRate,
      );
      final int bytes = File(path).lengthSync();
      stdout.writeln(
        'sid $sid -> ${path.split(Platform.pathSeparator).last} '
        '(${audio.sampleRate} Hz, ${(bytes / 1024).round()} KB)',
      );
    }
  } finally {
    tts.free();
  }
}
