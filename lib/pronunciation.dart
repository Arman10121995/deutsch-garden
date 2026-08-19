import 'dart:math';

/// Result for a single expected word after aligning it with what was heard.
class WordScore {
  const WordScore({
    required this.expected,
    required this.heard,
    required this.similarity,
  });

  final String expected;
  final String heard;
  final double similarity;

  bool get isMatch => similarity >= 0.82;
  bool get isClose => !isMatch && similarity >= 0.55;
  bool get isMissing => heard.isEmpty;
}

/// Aggregate outcome of comparing a spoken attempt with a target sentence.
class PronunciationResult {
  const PronunciationResult({
    required this.score,
    required this.words,
    required this.extraWords,
    required this.transcript,
  });

  final int score;
  final List<WordScore> words;
  final List<String> extraWords;
  final String transcript;

  List<WordScore> get problemWords =>
      words.where((word) => !word.isMatch).toList(growable: false);

  bool get isEmpty => transcript.trim().isEmpty;

  String get verdict {
    if (isEmpty) return 'Nothing was recognised.';
    if (score >= 92) return 'Excellent — that is close to native rhythm.';
    if (score >= 80) return 'Very good. A few sounds still drift.';
    if (score >= 65) return 'Understandable. Work on the highlighted words.';
    if (score >= 45) return 'Getting there. Slow down and repeat the model.';
    return 'Quite far from the target. Listen again, then repeat slowly.';
  }

  String get stars {
    final int filled = (score / 20).ceil().clamp(0, 5).toInt();
    return '${'★' * filled}${'☆' * (5 - filled)}';
  }
}

/// Offline speech comparison used by the speaking tutor.
///
/// This scores the *recognised text* against the target, which is what an
/// on-device ASR engine can honestly support. It is not an acoustic
/// pronunciation model: a phoneme-level score would need a dedicated
/// forced-alignment engine, which no offline Flutter plugin provides.
/// What it does catch reliably is dropped words, wrong words, wrong endings
/// and word order problems — which is most of what a learner needs.
class PronunciationScorer {
  const PronunciationScorer._();

  /// German-aware normalisation. Umlauts and ß are folded so that an engine
  /// transcribing "Schoen" instead of "schön" is not punished.
  static String normalize(String input) {
    final StringBuffer buffer = StringBuffer();
    for (final int rune in input.toLowerCase().runes) {
      final String char = String.fromCharCode(rune);
      switch (char) {
        case 'ä':
          buffer.write('ae');
          break;
        case 'ö':
          buffer.write('oe');
          break;
        case 'ü':
          buffer.write('ue');
          break;
        case 'ß':
          buffer.write('ss');
          break;
        default:
          if (RegExp(r'[a-z0-9 ]').hasMatch(char)) {
            buffer.write(char);
          } else if (RegExp(r'\s').hasMatch(char)) {
            buffer.write(' ');
          } else {
            buffer.write(' ');
          }
      }
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static List<String> tokenize(String input) {
    final String normalized = normalize(input);
    if (normalized.isEmpty) return const <String>[];
    return normalized.split(' ').where((token) => token.isNotEmpty).toList();
  }

  static int levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    List<int> previous = List<int>.generate(b.length + 1, (i) => i);
    List<int> current = List<int>.filled(b.length + 1, 0);
    for (int i = 0; i < a.length; i++) {
      current[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        final int cost = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
        current[j + 1] = min(
          min(current[j] + 1, previous[j + 1] + 1),
          previous[j] + cost,
        );
      }
      final List<int> swap = previous;
      previous = current;
      current = swap;
    }
    return previous[b.length];
  }

  static double similarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1;
    if (a.isEmpty || b.isEmpty) return 0;
    final int distance = levenshtein(a, b);
    final int longest = max(a.length, b.length);
    return (1 - distance / longest).clamp(0.0, 1.0).toDouble();
  }

  /// Aligns the heard tokens against the expected tokens with a
  /// Needleman-Wunsch style pass so that a single dropped word does not
  /// shift — and therefore fail — every following word.
  static PronunciationResult compare(String expected, String heard) {
    final List<String> target = tokenize(expected);
    final List<String> spoken = tokenize(heard);
    if (target.isEmpty) {
      return PronunciationResult(
        score: 0,
        words: const <WordScore>[],
        extraWords: spoken,
        transcript: heard,
      );
    }

    final int n = target.length;
    final int m = spoken.length;
    // cost[i][j] = best alignment cost for target[0..i) and spoken[0..j)
    final List<List<double>> cost = List<List<double>>.generate(
      n + 1,
      (_) => List<double>.filled(m + 1, 0),
    );
    for (int i = 0; i <= n; i++) {
      cost[i][0] = i.toDouble();
    }
    for (int j = 0; j <= m; j++) {
      cost[0][j] = j.toDouble();
    }
    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        final double substitution =
            cost[i - 1][j - 1] + (1 - similarity(target[i - 1], spoken[j - 1]));
        final double deletion = cost[i - 1][j] + 1;
        final double insertion = cost[i][j - 1] + 1;
        cost[i][j] = min(substitution, min(deletion, insertion));
      }
    }

    final List<WordScore> words = <WordScore>[];
    final List<String> extras = <String>[];
    int i = n;
    int j = m;
    while (i > 0 || j > 0) {
      if (i > 0 && j > 0) {
        final double sim = similarity(target[i - 1], spoken[j - 1]);
        if ((cost[i][j] - (cost[i - 1][j - 1] + (1 - sim))).abs() < 1e-9) {
          words.add(WordScore(
            expected: target[i - 1],
            heard: spoken[j - 1],
            similarity: sim,
          ));
          i--;
          j--;
          continue;
        }
      }
      if (i > 0 && (cost[i][j] - (cost[i - 1][j] + 1)).abs() < 1e-9) {
        words.add(WordScore(expected: target[i - 1], heard: '', similarity: 0));
        i--;
        continue;
      }
      if (j > 0) {
        extras.add(spoken[j - 1]);
        j--;
        continue;
      }
      break;
    }
    final List<WordScore> ordered = words.reversed.toList();
    final List<String> orderedExtras = extras.reversed.toList();

    final double matched = ordered.fold<double>(
      0,
      (total, word) => total + word.similarity,
    );
    // Extra words cost less than missing words: ASR engines routinely emit
    // filler tokens, and punishing them heavily makes the score feel unfair.
    final double penalty = orderedExtras.length * 0.35;
    final double raw = ((matched - penalty) / n).clamp(0.0, 1.0).toDouble();
    return PronunciationResult(
      score: (raw * 100).round(),
      words: ordered,
      extraWords: orderedExtras,
      transcript: heard,
    );
  }

  /// Keyword-coverage analysis for open-ended answers, where there is no
  /// single correct sentence to align against.
  static double keywordCoverage(String answer, List<String> keywords) {
    if (keywords.isEmpty) return 1;
    final String normalized = normalize(answer);
    if (normalized.isEmpty) return 0;
    int hits = 0;
    for (final String keyword in keywords) {
      final String needle = normalize(keyword);
      if (needle.isEmpty) continue;
      if (normalized.contains(needle)) {
        hits++;
        continue;
      }
      // Tolerate inflection: match on a stem of the keyword.
      final int stemLength = max(4, (needle.length * 0.7).round());
      if (needle.length > 4 &&
          normalized.contains(needle.substring(0, stemLength))) {
        hits++;
      }
    }
    return (hits / keywords.length).clamp(0.0, 1.0).toDouble();
  }

  static int wordCount(String text) => tokenize(text).length;
}
