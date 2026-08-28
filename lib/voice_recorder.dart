/// Voice capture, or a no-op where it cannot help.
///
/// Selected by conditional import. The web build has no bundled voice, so it
/// has no reference rendering to compare a recording against — acoustic
/// scoring is not merely unimplemented there, it has nothing to measure. The
/// browser keeps the text comparison through the speech API, which is what it
/// could always do.
library;

export 'voice_recorder_stub.dart'
    if (dart.library.io) 'voice_recorder_io.dart';
