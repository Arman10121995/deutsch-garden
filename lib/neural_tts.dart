/// The bundled neural voice, or a no-op where it cannot run.
///
/// Selected by conditional import: the real implementation needs `dart:io` and
/// real file paths, neither of which exists on the web.
library;

export 'neural_tts_stub.dart'
    if (dart.library.io) 'neural_tts_io.dart';
