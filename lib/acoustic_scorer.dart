/// Acoustic pronunciation scoring, or a no-op where the pieces do not exist.
library;

export 'acoustic_scorer_stub.dart'
    if (dart.library.io) 'acoustic_scorer_io.dart';
