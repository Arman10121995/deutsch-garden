/// Structured reasons from the offline evaluators. Presentation can translate
/// them without parsing English sentences or changing scoring conditions.
enum FeedbackKind {
  writingStart,
  writingLength,
  writingKeywords,
  writingNouns,
  writingSentenceCase,
  writingConnectors,
  writingParagraphs,
  writingRepetition,
  writingSuccess,
  speakingLength,
  speakingModels,
  speakingConnectors,
  speakingSuccess,
}

class FeedbackMessage {
  const FeedbackMessage(
    this.kind, {
    this.count = 0,
    this.target = 0,
    this.missing = 0,
    this.covered = 0,
    this.total = 0,
    this.words = '',
  });

  final FeedbackKind kind;
  final int count, target, missing, covered, total;
  final String words;
}
