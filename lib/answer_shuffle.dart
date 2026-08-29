/// Moves the right answer around, because it was never moving.
///
/// Every authored multiple-choice item in this app was written with the
/// correct option first and the distractors after it, which is the natural way
/// to write one and a catastrophic way to ship one. Measured across the whole
/// deck before this existed: **386 items answered at position 1, 119 at
/// position 2, 73 at position 3, and not one single item at position 4.**
/// The placement test was worse than that -- all sixty of its questions
/// answered first.
///
/// So a learner who always tapped the top option scored 67% on the deck and
/// 100% on placement. That is not a cosmetic bug. Placement decides which
/// level someone starts at, and a test that can be passed without reading it
/// hands a beginner a C1 course. Everywhere else it is quieter and just as
/// bad: an exercise that can be answered by position teaches position.
///
/// The fix is here rather than in the content for three reasons. Rewriting
/// 578 authored literals is a huge diff that gets one wrong; it fixes only the
/// items that exist today and not the next one written; and a fixed
/// permutation is still a fixed permutation -- a learner who sees the same
/// item twice would see the answer in the same place. Shuffling at
/// presentation fixes all of it at once, including content nobody has written
/// yet.
library;

import 'dart:math';

/// A permuted option list and where the answer went.
class ShuffledChoices {
  const ShuffledChoices({required this.options, required this.correctIndex});

  final List<String> options;
  final int correctIndex;
}

/// Permutes [options] uniformly and reports the answer's new index.
///
/// Two things this deliberately does *not* do:
///
/// * It does not refuse to return the original order. A shuffle that
///   guaranteed movement would mean the answer is never where it was
///   authored, and since almost every item is authored answer-first, that
///   would simply replace "always first" with "never first" -- an
///   exploitable rule either way. A uniform shuffle lands on the identity
///   permutation sometimes, and that is correct.
///
/// * It does not find the answer again by value. Options can repeat --
///   article drills offer der/die/das, grammar items repeat a word between
///   choices -- and `indexOf` on a shuffled list returns the first match,
///   which silently marks a different option correct. The permutation is
///   tracked by index for that reason.
ShuffledChoices shuffleChoices(
  List<String> options,
  int correctIndex,
  Random random,
) {
  // A question with nothing to permute, or one whose answer index is not a
  // real position, is returned untouched. Civics questions parsed from JSON
  // use -1 for "not answerable", and inventing an answer for one of those
  // would be worse than leaving it alone.
  if (options.length < 2 || correctIndex < 0 || correctIndex >= options.length) {
    return ShuffledChoices(
      options: List<String>.unmodifiable(options),
      correctIndex: correctIndex,
    );
  }

  final List<int> order = List<int>.generate(options.length, (int i) => i);
  order.shuffle(random);

  return ShuffledChoices(
    options: List<String>.unmodifiable(
      <String>[for (final int from in order) options[from]],
    ),
    correctIndex: order.indexOf(correctIndex),
  );
}

/// A [Random] whose sequence is fixed by [seed].
///
/// Positions have to be stable while a question is on screen: a widget can
/// rebuild for any reason -- a keyboard opening, a theme change, a parent
/// animating -- and options that jump underneath a finger about to tap are
/// their own kind of wrong answer. Screens seed from the question's identity
/// and the attempt, so the order is fixed for as long as the question is being
/// answered and different the next time it comes round.
Random seededFor(Object identity, int attempt) =>
    Random(Object.hash(identity, attempt));
