import 'dart:math';

/// Choose within the existing bank/test. Never redraw a mock or its answers.
/// Unseen questions come first, then unanswered ones, then review questions.
int preferredTestQuestion({
  required List<String> ids,
  required Set<String> seen,
  int? current,
  Set<String>? answered,
  Random? random,
}) {
  if (ids.isEmpty) return 0;
  final candidates = <int>[
    for (int i = 0; i < ids.length; i++)
      if (ids.length == 1 || i != current) i,
  ];
  final unseen = candidates.where((i) => !seen.contains(ids[i])).toList();
  final unanswered = candidates
      .where((i) => !(answered?.contains(ids[i]) ?? false))
      .toList();
  final pool = unseen.isNotEmpty
      ? unseen
      : unanswered.isNotEmpty
      ? unanswered
      : candidates;
  return random == null ? pool.first : pool[random.nextInt(pool.length)];
}
