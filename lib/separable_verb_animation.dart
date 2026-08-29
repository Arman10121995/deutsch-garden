/// A separable verb coming apart, which is the rule rather than a decoration.
///
/// `docs/VISUAL_ROADMAP.md` records that animation was deliberately *not*
/// spread across the deck: Mayer's coherence principle says extraneous motion
/// hurts learning, and a vocabulary list of wiggling tiles is plausibly worse
/// than a still one. This is the exception, and the reason it qualifies is
/// that here the motion *is* the content.
///
/// `aufstehen` is one word in the infinitive and two pieces in a main clause
/// — *Ich stehe um sieben auf* — with the prefix travelling to the end. A
/// learner who watches that happen has seen the rule. A learner who reads
/// "the prefix goes to the end of the clause" has read a sentence about the
/// rule, which is not the same thing and is why they keep forgetting it.
///
/// Only 341 cards get this. `wiederholen` is deliberately absent: it looks
/// separable and is not, and animating it would teach *Ich hole wieder*,
/// which is a different verb. See `tool/build_separable_verbs.py`.
library;

import 'package:flutter/material.dart';

import 'models.dart';
import 'separable_verbs.dart';

SeparableVerb? separableVerbFor(GermanWord word) => separableVerbs[word.id];

bool isSeparableVerb(GermanWord word) => separableVerbs.containsKey(word.id);

/// Shows the infinitive splitting into a main-clause sentence.
class SeparableVerbAnimation extends StatefulWidget {
  const SeparableVerbAnimation({super.key, required this.word});

  final GermanWord word;

  @override
  State<SeparableVerbAnimation> createState() => _SeparableVerbAnimationState();
}

class _SeparableVerbAnimationState extends State<SeparableVerbAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool motionOff = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (motionOff) {
      _controller?.dispose();
      _controller = null;
      return;
    }
    _controller ??= AnimationController(
      vsync: this,
      // Slow. The whole point is to be followed, and a prefix that darts
      // across in 300ms has been seen but not read.
      duration: const Duration(milliseconds: 3400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Hold the infinitive, move, then hold the split form.
  ///
  /// Both ends need dwell time: the two forms are what is being compared, and
  /// a loop that never rests on either shows only the transition.
  double _phase(double t) {
    const double hold = 0.28;
    if (t < hold) return 0;
    if (t > 1 - hold) return 1;
    return Curves.easeInOut.transform((t - hold) / (1 - 2 * hold));
  }

  @override
  Widget build(BuildContext context) {
    final SeparableVerb? verb = separableVerbFor(widget.word);
    if (verb == null) return const SizedBox.shrink();
    final ThemeData theme = Theme.of(context);

    return Semantics(
      // Announced as a fact, not as a sequence of moving fragments.
      label: '${widget.word.german} is a separable verb. In a main clause the '
          'prefix ${verb.prefix} moves to the end: '
          'ich ${_conjugated(verb.stem)} … ${verb.prefix}.',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.call_split_rounded,
                    size: 18, color: theme.colorScheme.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Separable verb',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _controller == null
                ? _frame(context, verb, 1)
                : AnimatedBuilder(
                    animation: _controller!,
                    builder: (BuildContext context, Widget? _) =>
                        _frame(context, verb, _phase(_controller!.value)),
                  ),
            const SizedBox(height: 6),
            Text(
              'In a main clause the prefix goes to the end. It comes back for '
              'the infinitive and after a modal verb: '
              '“Ich muss früh ${widget.word.german}.”',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  /// Present tense, first person. Enough to make the sentence real without
  /// pretending the app has a full conjugator.
  String _conjugated(String stem) {
    if (stem.endsWith('en')) return '${stem.substring(0, stem.length - 2)}e';
    if (stem.endsWith('n')) return '${stem.substring(0, stem.length - 1)}e';
    return stem;
  }

  Widget _frame(BuildContext context, SeparableVerb verb, double t) {
    final ThemeData theme = Theme.of(context);
    final Color prefixColour = theme.colorScheme.primary;

    // 0 -> the infinitive, prefix welded to the stem.
    // 1 -> the main clause, prefix at the end.
    final String stem = t < 0.5 ? verb.stem : _conjugated(verb.stem);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          // "Ich" fades in as the sentence forms: there is no subject in an
          // infinitive, and showing one from the start would be wrong.
          Opacity(
            opacity: t,
            child: Text('Ich ', style: _base(theme)),
          ),
          // The prefix sits before the stem at t=0 and after it at t=1.
          // Ordering by flex rather than by absolute position keeps it
          // correct at any text size, which a Stack with hard offsets would
          // not.
          if (t < 0.5)
            _prefix(verb.prefix, prefixColour, theme, 1 - t * 2),
          Text(stem, style: _base(theme)),
          Opacity(
            opacity: t,
            child: Text(' früh', style: _base(theme)),
          ),
          if (t >= 0.5)
            _prefix(verb.prefix, prefixColour, theme, (t - 0.5) * 2),
          Opacity(
            opacity: t,
            child: Text('.', style: _base(theme)),
          ),
        ],
      ),
    );
  }

  Widget _prefix(
    String prefix,
    Color colour,
    ThemeData theme,
    double settled,
  ) =>
      Opacity(
        // Never fully transparent: the prefix is the thing being tracked, and
        // one that vanishes mid-flight reads as a glitch rather than a move.
        opacity: 0.35 + 0.65 * settled.clamp(0.0, 1.0),
        child: Padding(
          padding: EdgeInsets.only(left: settled < 1 ? 2 : 4, right: 2),
          child: Text(
            prefix,
            style: _base(theme).copyWith(
              color: colour,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );

  TextStyle _base(ThemeData theme) =>
      theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700) ??
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
}
