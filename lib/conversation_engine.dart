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
/// A deliberately shallow German stemmer, used only to match content-point
/// keywords against what a learner actually wrote.
///
/// It is not a linguistic analyser and does not try to be. It folds umlauts
/// and strips the inflectional endings that separate "wohnen" from "wohnt"
/// from "wohne", so an authored keyword matches the form the learner reached
/// for. Both sides go through the same function, so consistency matters more
/// here than correctness: it is fine that `Preis` stems to `prei`, as long as
/// `Preise` does too.
class GermanStem {
  const GermanStem._();

  /// Longest first, so `wohnten` loses `ten` rather than `n`.
  static const List<String> _endings = <String>[
    'ern', 'est', 'eten', 'ete', 'end', 'en', 'em', 'er', 'es', 'et',
    'st', 'e', 's', 't', 'n',
  ];

  /// Stripping below this would turn short words into noise.
  static const int _floor = 4;

  static String fold(String input) {
    return input
        .toLowerCase()
        .replaceAll('\u00e4', 'a')
        .replaceAll('\u00f6', 'o')
        .replaceAll('\u00fc', 'u')
        .replaceAll('\u00df', 'ss');
  }

  static String stem(String word) {
    String out = fold(word).replaceAll(RegExp(r'[^a-z0-9]'), '');
    bool stripped = true;
    while (stripped && out.length > _floor) {
      stripped = false;
      for (final String ending in _endings) {
        if (out.length - ending.length >= _floor && out.endsWith(ending)) {
          out = out.substring(0, out.length - ending.length);
          stripped = true;
          break;
        }
      }
    }
    return out;
  }

  /// Every stemmed token in [text], plus the stemmed adjacent pairs.
  ///
  /// Pairs exist because several keywords are phrases -- "meiner meinung",
  /// "ich finde" -- and a bag of single words cannot tell those from their
  /// parts appearing separately.
  static Set<String> tokens(String text) {
    final List<String> words = fold(text)
        .split(RegExp(r'[^a-z0-9]+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    final Set<String> out = <String>{};
    for (int i = 0; i < words.length; i++) {
      final String a = stem(words[i]);
      out.add(a);
      if (i + 1 < words.length) out.add('$a ${stem(words[i + 1])}');
    }
    return out;
  }

  /// Whether [keyword] -- a word or a short phrase -- appears in [tokens].
  static bool present(Set<String> tokens, String keyword) {
    final List<String> parts = fold(keyword)
        .split(RegExp(r'[^a-z0-9]+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    if (parts.isEmpty) return false;
    if (parts.length == 1) {
      final String needle = stem(parts.first);
      if (tokens.contains(needle)) return true;
      // German compounds: "Nahverkehr" should satisfy "Verkehr". Only for
      // stems long enough that the containment is not a coincidence.
      if (needle.length >= 5) {
        for (final String token in tokens) {
          if (!token.contains(' ') && token.contains(needle)) return true;
        }
      }
      return false;
    }
    // Phrases are matched on their first two words, which is what tokens()
    // stores.
    return tokens.contains('${stem(parts[0])} ${stem(parts[1])}');
  }
}

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

    // Coverage used to be approximated from length, and every content point
    // was reported as covered whatever the learner said -- so an off-topic
    // answer of the right length scored well and was told it had addressed
    // everything. Each point now carries the German words a real answer to it
    // contains, and coverage is how many of those actually turned up.
    //
    // This detects the vocabulary of a point, not the point. Someone who
    // names their sister without saying anything about her still counts as
    // having covered "who is in your family", and no offline check can tell
    // otherwise. It is a far better signal than length, and it is not
    // comprehension.
    final Set<String> tokens = GermanStem.tokens(answer);
    final List<String> covered = <String>[];
    final List<String> missing = <String>[];
    final bool checkable = prompt.pointKeywords.length ==
            prompt.expectedPoints.length &&
        prompt.pointKeywords.isNotEmpty;
    if (checkable) {
      for (int i = 0; i < prompt.expectedPoints.length; i++) {
        final bool hit = prompt.pointKeywords[i]
            .any((String keyword) => GermanStem.present(tokens, keyword));
        (hit ? covered : missing).add(prompt.expectedPoints[i]);
      }
    } else {
      covered.addAll(prompt.expectedPoints);
    }

    final double lengthRatio =
        (words / max(1, prompt.targetWords)).clamp(0.0, 1.2).toDouble();
    final double connectorRatio = prompt.usefulConnectors.isEmpty
        ? 1
        : (connectors.length / prompt.usefulConnectors.length)
            .clamp(0.0, 1.0)
            .toDouble();
    final double coverage = checkable && prompt.expectedPoints.isNotEmpty
        ? covered.length / prompt.expectedPoints.length
        : min(1.0, lengthRatio);
    // Coverage dominates. Length and connectors are how an answer is built,
    // but whether it addressed the question is what it is being asked.
    final int score = checkable
        ? ((coverage * 0.6 +
                    min(1.0, lengthRatio) * 0.25 +
                    connectorRatio * 0.15) *
                100)
            .round()
        : ((min(1.0, lengthRatio) * 0.6 + connectorRatio * 0.4) * 100).round();

    final List<String> tips = <String>[];
    if (missing.isNotEmpty) {
      tips.add('Not yet covered: ${missing.join(', ')}. '
          'Say something concrete about each before adding length.');
    }
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
      coveredPoints: covered,
      tips: tips,
    );
  }
}
