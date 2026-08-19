import 'dart:math';

import 'conversation.dart';
import 'pronunciation.dart';

/// What the tutor decided about one learner reply.
class TurnEvaluation {
  const TurnEvaluation({
    required this.accepted,
    required this.score,
    required this.matched,
    required this.missing,
    required this.tooShort,
    required this.headline,
    required this.detail,
  });

  final bool accepted;

  /// 0-100 for this single turn.
  final int score;
  final List<String> matched;
  final List<String> missing;
  final bool tooShort;

  /// One-line verdict shown in the chat.
  final String headline;

  /// Longer coaching note.
  final String detail;
}

/// Result of an open-ended speaking answer.
class FreeTalkEvaluation {
  const FreeTalkEvaluation({
    required this.score,
    required this.wordCount,
    required this.coverage,
    required this.connectorsUsed,
    required this.coveredPoints,
    required this.tips,
  });

  final int score;
  final int wordCount;
  final double coverage;
  final List<String> connectorsUsed;
  final List<String> coveredPoints;
  final List<String> tips;
}

/// Deterministic on-device dialogue evaluator.
///
/// This is intentionally *not* a language model. It runs entirely offline,
/// gives the same feedback for the same answer every time, and never invents
/// German that a learner might copy. What it checks is what a scripted
/// role-play can check honestly: did the learner address the turn, with
/// enough language, using the structures the turn was designed to practise.
class ConversationEngine {
  const ConversationEngine._();

  /// Number of hints a learner may take before the tutor moves on anyway, so
  /// nobody gets stuck on one turn forever.
  static const int maxAttemptsPerStep = 3;

  static bool _mentions(String normalizedAnswer, String keyword) {
    final String needle = PronunciationScorer.normalize(keyword);
    if (needle.isEmpty) return false;
    if (normalizedAnswer.contains(needle)) return true;
    // Stem tolerance: 'wohn' should match wohne/wohnst/gewohnt, and a
    // keyword like 'ausgefallen' should still match 'ausgefallene'.
    if (needle.length >= 6) {
      final int stem = max(4, (needle.length * 0.72).round());
      if (normalizedAnswer.contains(needle.substring(0, stem))) return true;
    }
    return false;
  }

  static TurnEvaluation evaluate(DialogueStep step, String reply) {
    final String normalized = PronunciationScorer.normalize(reply);
    final int words = PronunciationScorer.wordCount(reply);
    final List<String> matched = <String>[];
    final List<String> missing = <String>[];
    for (final String keyword in step.keywords) {
      if (_mentions(normalized, keyword)) {
        matched.add(keyword);
      } else {
        missing.add(keyword);
      }
    }

    if (words == 0) {
      return const TurnEvaluation(
        accepted: false,
        score: 0,
        matched: <String>[],
        missing: <String>[],
        tooShort: true,
        headline: 'I did not catch anything.',
        detail: 'Tap the microphone and speak, or type your answer instead.',
      );
    }

    final int minWords = step.effectiveMinWords;
    final bool tooShort = words < minWords;
    final int required = max(1, step.requiredHits);
    final double contentRatio = (matched.length / required).clamp(0.0, 1.0);
    final double lengthRatio =
        (words / max(1, minWords)).clamp(0.0, 1.0).toDouble();

    // Content dominates; length is a supporting signal, not a gate.
    final int score = ((contentRatio * 0.75 + lengthRatio * 0.25) * 100).round();
    final bool accepted = matched.length >= required && !tooShort;

    String headline;
    String detail;
    if (accepted && score >= 90) {
      headline = 'Genau so. 👌';
      detail = 'You addressed the turn fully and at the right length.';
    } else if (accepted) {
      headline = 'Passt. ✅';
      detail = 'That works. Compare it with the model answer to tighten it up.';
    } else if (tooShort && matched.isNotEmpty) {
      headline = 'Right idea — say a bit more.';
      detail = 'This turn expects at least $minWords words. '
          'Add a reason, a detail or a follow-up question.';
    } else if (matched.isEmpty) {
      headline = 'That did not answer the question.';
      detail = 'Re-read the task: ${step.task}';
    } else {
      headline = 'Almost — one element is still missing.';
      detail = 'You need $required of the target elements; you covered '
          '${matched.length}. Try the hint.';
    }

    return TurnEvaluation(
      accepted: accepted,
      score: score,
      matched: matched,
      missing: missing,
      tooShort: tooShort,
      headline: headline,
      detail: detail,
    );
  }

  /// Overall percentage for a completed role-play.
  static int sessionScore(List<TurnEvaluation> evaluations) {
    if (evaluations.isEmpty) return 0;
    final int total = evaluations.fold<int>(0, (sum, e) => sum + e.score);
    return (total / evaluations.length).round().clamp(0, 100).toInt();
  }

  static FreeTalkEvaluation evaluateFreeTalk(
    FreeTalkPrompt prompt,
    String answer,
  ) {
    final String normalized = PronunciationScorer.normalize(answer);
    final int words = PronunciationScorer.wordCount(answer);
    final List<String> connectors = prompt.usefulConnectors
        .where((connector) => _mentions(normalized, connector))
        .toList();

    // Content points are English labels, so they cannot be matched directly.
    // Coverage is approximated from length against the target, which is the
    // honest signal available offline, plus connector use as a proxy for
    // structure.
    final double lengthRatio =
        (words / max(1, prompt.targetWords)).clamp(0.0, 1.2).toDouble();
    final double connectorRatio = prompt.usefulConnectors.isEmpty
        ? 1
        : (connectors.length / prompt.usefulConnectors.length)
            .clamp(0.0, 1.0)
            .toDouble();
    final double coverage = min(1.0, lengthRatio);
    final int score =
        ((min(1.0, lengthRatio) * 0.6 + connectorRatio * 0.4) * 100).round();

    final List<String> tips = <String>[];
    if (words < prompt.targetWords * 0.6) {
      tips.add('Aim for about ${prompt.targetWords} words — you produced $words. '
          'Add an example or a reason to each point.');
    }
    if (connectors.length < (prompt.usefulConnectors.length / 2).ceil()) {
      final List<String> unused = prompt.usefulConnectors
          .where((connector) => !connectors.contains(connector))
          .take(3)
          .toList();
      tips.add('Reach for the level connectors: ${unused.join(', ')}.');
    }
    if (words > prompt.targetWords * 1.6) {
      tips.add('You went well past the target length. Examiners reward '
          'structure, not volume — cut the weakest point.');
    }
    if (tips.isEmpty) {
      tips.add('Good length and good structure. Now compare your wording with '
          'the model answer and steal one phrase from it.');
    }

    return FreeTalkEvaluation(
      score: score.clamp(0, 100).toInt(),
      wordCount: words,
      coverage: coverage,
      connectorsUsed: connectors,
      coveredPoints: prompt.expectedPoints,
      tips: tips,
    );
  }
}
