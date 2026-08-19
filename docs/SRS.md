# Spaced repetition

## What changed in 3.1

3.0 scheduled every card on one fixed ladder keyed to a 0–5 mastery counter:
0, 1, 2, 4, 8 and 16 days. That ladder cannot adapt. A word you find trivial and
a word you barely recall receive exactly the same interval, so you over-study the
easy half of the deck and under-study the hard half.

3.1 uses SM-2 (`lib/srs.dart`) with a per-card **ease factor**, so intervals
diverge according to measured difficulty.

## The algorithm

**Learning steps.** A new card is shown after 1 minute, then 10 minutes, then
graduates to a 1-day interval. `Easy` graduates it immediately to 4 days.

**Graduated cards.** On each review:

| Grade | Effect |
| --- | --- |
| Again | ease − 0.20, lapse recorded, card returns to relearning in 10 minutes |
| Hard | ease − 0.15, interval × 1.2 |
| Good | interval × ease |
| Easy | ease + 0.15, interval × ease × 1.3 |

Ease is clamped to [1.30, 3.20] and intervals are capped at 365 days, so no card
disappears for years.

**Interval previews.** Each of the four buttons shows the interval it will
produce before you press it, so the self-rating is an informed choice.

## Binary quiz modes

The multiple-choice, article and typing modes do not ask you to self-rate. They
map onto the same scheduler: correct → `Good`, incorrect → `Again`. Both paths
therefore share one schedule per card rather than maintaining two.

## Migration

Progress saved by 3.0 has no SM-2 state. `WordProgress.fromJson` seeds it from
the old ladder: `intervalDays` comes from the 0/1/2/4/8/16 table indexed by the
stored mastery, `reps` from the mastery counter, ease from the 2.5 default. A
learner upgrading keeps their schedule roughly where they left it instead of
having every card reset to new. This is covered by a test.

## Difficult words

A card that lapses four or more times is flagged as a leech. Leeches get their
own screen, because the fix for a card you keep forgetting is a better memory
hook, not another blind repetition — so the screen's primary action is writing
your own mnemonic.
