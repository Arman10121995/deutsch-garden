/// Shows a German compound as the words it is built from.
///
/// This is the highest-yield visual in the app per unit of effort, and it cost
/// nothing to make. 1,780 cards — 18% of the deck — are built from two words
/// the learner already has cards for, and 259 of those have a picture on both
/// parts, so the compound gets a composed illustration without anyone drawing
/// anything. `Ohrring` is an ear and a ring. `Tagebuch` is a day and a book.
///
/// It multiplies the 838 existing illustrations rather than adding to them,
/// which is why it beat every attempt to buy more pictures: measured, the
/// cheap icon-matching routes gave `prüfen` a tick mark and `im Gegensatz
/// dazu` a brightness slider, and a wrong picture teaches worse than none.
///
/// **Built from, never means.** Plenty of compounds are not compositional:
/// `Aufgabe` is *auf* + *Gabe* and a task is not an up-gift. Saying "built
/// from" keeps the claim to the one that is always true — how the word is
/// assembled — which is a real memory hook even where the meaning does not
/// follow. The handful whose split actively misleads are excluded in
/// `tool/vocab_compounds_excluded.tsv` with a reason each.
library;

import 'package:flutter/material.dart';

import 'models.dart';
import 'vocab_compounds.dart';
import 'vocab_icon.dart';
import 'vocabulary.dart';

/// Card lookup by id, built once.
///
/// Ten thousand cards scanned linearly for every part of every compound would
/// be twenty thousand scans on a screen that also has to stay smooth.
final Map<String, GermanWord> _byId = <String, GermanWord>{
  for (final GermanWord word in vocabulary) word.id: word,
};

/// The parts of [word], or null when it is not a known compound.
({GermanWord modifier, GermanWord head, String link})? compoundParts(
  GermanWord word,
) {
  final VocabCompound? parts = vocabCompounds[word.id];
  if (parts == null) return null;
  final GermanWord? modifier = _byId[parts.modifierId];
  final GermanWord? head = _byId[parts.headId];
  if (modifier == null || head == null) return null;
  return (modifier: modifier, head: head, link: parts.link);
}

/// Whether this card has a breakdown worth showing.
bool hasCompoundBreakdown(GermanWord word) => compoundParts(word) != null;

class CompoundBreakdown extends StatelessWidget {
  const CompoundBreakdown({
    super.key,
    required this.word,
    this.compact = false,
  });

  final GermanWord word;

  /// Drops the English glosses and shrinks the tiles, for the study card
  /// where space is short and the learner is mid-answer.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ({GermanWord modifier, GermanWord head, String link})? parts =
        compoundParts(word);
    if (parts == null) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    final double tile = compact ? 34 : 44;

    return Semantics(
      // One label for the whole thing. Read part by part, a screen reader
      // would announce two unrelated words and a stray letter.
      label: '${word.german} is built from '
          '${parts.modifier.german} and ${parts.head.german}'
          '${parts.link.isEmpty ? '' : ', joined with ${parts.link}'}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Built from',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 6),
            // Wraps rather than overflows: two long German parts plus a
            // joiner do not fit a narrow phone on one line.
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _part(context, parts.modifier, tile),
                _joiner(context, '+'),
                if (parts.link.isNotEmpty) ...<Widget>[
                  // The Fugenelement belongs to neither part. A learner who
                  // thinks the -s- in Rechtsanwalt is part of Recht will
                  // spell it wrong, so it is shown as the seam it is.
                  _linkChip(context, parts.link),
                  _joiner(context, '+'),
                ],
                _part(context, parts.head, tile),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _joiner(BuildContext context, String text) => Text(
        text,
        style: TextStyle(
          fontSize: compact ? 14 : 16,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.outline,
        ),
      );

  Widget _linkChip(BuildContext context, String link) {
    final ThemeData theme = Theme.of(context);
    return Tooltip(
      message: 'A linking letter. It belongs to neither part.',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '-$link-',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _part(BuildContext context, GermanWord part, double tile) {
    final ThemeData theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 110 : 150),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Only where the part actually has art. An empty box under one
          // half and a picture under the other reads as a loading failure.
          if (hasAnyVocabImage(part)) VocabIcon(word: part, size: tile),
          Text(
            part.displayGerman,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (!compact)
            Text(
              part.english,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
        ],
      ),
    );
  }
}
