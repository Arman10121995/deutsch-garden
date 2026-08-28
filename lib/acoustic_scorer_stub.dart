/// Web fallback: no bundled voice, so nothing to score against.
library;

import 'acoustic.dart';

class AcousticPronunciationScorer {
  const AcousticPronunciationScorer();

  Future<AcousticScore?> score({
    required String targetGerman,
    required String recordingPath,
  }) async =>
      null;
}
