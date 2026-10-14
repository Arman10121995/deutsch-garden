/// Honest, deterministic feedback for an open-ended curriculum speaking task.
///
/// A transcript cannot certify pronunciation or understand every valid answer.
/// It can still replace a vague self-rating with useful measurements: how much
/// was said, whether the learner reached for the lesson's model structures and
/// whether the response had connective language appropriate to a monologue.
library;

import 'dart:math';

import 'conversation_engine.dart';
import 'models.dart';
import 'feedback_message.dart';
import 'pronunciation.dart';

class SpeakingAttemptEvaluation {
  const SpeakingAttemptEvaluation({
    required this.score,
    required this.wordCount,
    required this.targetWords,
    required this.phrasesCovered,
    required this.totalPhrases,
    required this.connectors,
    required this.tips,
    this.feedback = const <FeedbackMessage>[],
  });

  final int score;
  final int wordCount;
  final int targetWords;
  final int phrasesCovered;
  final int totalPhrases;
  final List<String> connectors;
  final List<String> tips;
  final List<FeedbackMessage> feedback;
}

class SpeakingEvaluator {
  const SpeakingEvaluator._();

  static const Set<String> _stopWords = <String>{
    'aber',
    'auch',
    'dann',
    'dass',
    'eine',
    'einen',
    'einer',
    'eines',
    'etwas',
    'habe',
    'haben',
    'ihnen',
    'ihrer',
    'meine',
    'meiner',
    'nicht',
    'oder',
    'sich',
    'sind',
    'unter',
    'wäre',
    'wenn',
    'werden',
    'zwischen',
  };

  static const List<String> _connectors = <String>[
    'zuerst',
    'dann',
    'danach',
    'später',
    'weil',
    'deshalb',
    'aber',
    'obwohl',
    'allerdings',
    'während',
    'einerseits',
    'andererseits',
    'zunächst',
    'insgesamt',
    'abschließend',
  ];

  static SpeakingAttemptEvaluation evaluate(
    SpeakingLesson lesson,
    String transcript,
  ) {
    final int words = PronunciationScorer.wordCount(transcript);
    // A learner's first A1 monologue should not be judged at native broadcast
    // speed. This is a reachable content floor, not a words-per-minute claim.
    final int targetWords = max(8, (lesson.targetSeconds * 0.35).round());
    final Set<String> heard = GermanStem.tokens(transcript);

    int covered = 0;
    for (final String phrase in lesson.modelPhrases) {
      final List<String> candidates = PronunciationScorer.tokenize(phrase)
          .where(
            (String word) =>
                word.length >= 4 && !_stopWords.contains(word.toLowerCase()),
          )
          .toList(growable: false);
      if (candidates.any((String word) => GermanStem.present(heard, word))) {
        covered += 1;
      }
    }

    final List<String> connectors = _connectors
        .where((String word) => GermanStem.present(heard, word))
        .toList(growable: false);
    final double lengthRatio = (words / targetWords).clamp(0.0, 1.0);
    final double phraseRatio = lesson.modelPhrases.isEmpty
        ? 1
        : covered / lesson.modelPhrases.length;
    final double structureRatio = (connectors.length / 3).clamp(0.0, 1.0);
    // Length leads because a valid answer need not copy model language. The
    // other two signals reward lesson structures without pretending to judge
    // meaning or accent from text alone.
    final int score = words == 0
        ? 0
        : ((lengthRatio * 0.55 + phraseRatio * 0.30 + structureRatio * 0.15) *
                  100)
              .round()
              .clamp(0, 100);

    final List<String> tips = <String>[];
    final List<FeedbackMessage> feedback = <FeedbackMessage>[];
    void addTip(String text, FeedbackMessage message) {
      tips.add(text);
      feedback.add(message);
    }

    if (words < targetWords) {
      addTip(
        'You produced $words words. Build toward about $targetWords by adding '
        'one detail, reason or example to each point.',
        FeedbackMessage(
          FeedbackKind.speakingLength,
          count: words,
          target: targetWords,
        ),
      );
    }
    if (covered < min(2, lesson.modelPhrases.length)) {
      addTip(
        'Try one of the model structures below; you used $covered of '
        '${lesson.modelPhrases.length} in this attempt.',
        FeedbackMessage(
          FeedbackKind.speakingModels,
          covered: covered,
          total: lesson.modelPhrases.length,
        ),
      );
    }
    if (connectors.isEmpty && words >= 8) {
      addTip(
        'Link the ideas with words such as dann, weil or allerdings.',
        const FeedbackMessage(FeedbackKind.speakingConnectors),
      );
    }
    if (tips.isEmpty) {
      addTip(
        'Good length and structure. Listen back to a model phrase, then repeat '
        'the answer once with clearer stress and fewer pauses.',
        const FeedbackMessage(FeedbackKind.speakingSuccess),
      );
    }

    return SpeakingAttemptEvaluation(
      score: score,
      wordCount: words,
      targetWords: targetWords,
      phrasesCovered: covered,
      totalPhrases: lesson.modelPhrases.length,
      connectors: connectors,
      tips: tips,
      feedback: feedback,
    );
  }
}
