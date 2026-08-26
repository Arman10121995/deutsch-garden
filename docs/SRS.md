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

## Lessons are scheduled too (3.5)

Until 3.5 the scheduler covered vocabulary and nothing else. `ActivityProgress`
carried only `bestScore`, `attempts`, `completed` and `draft` — a completion
flag. The original 222 lessons (96 grammar, 36 listening, 36 reading, 36
writing, 18 speaking) were therefore finished once and never seen again, while the
vocabulary cards were rehearsed indefinitely. That is the wrong way round for
German: adjective endings, case governance after prepositions and verbs, and
Konjunktiv II decay at least as fast as lexis, and they were the part of the
app with no review at all.

`ActivityProgress` now carries the same SM-2 state as `WordProgress` and goes
through the same `Sm2Scheduler`. There is no separate Again/Hard/Good/Easy
prompt on a lesson, so the grade is derived from the score just earned:

The registry now contains 343 reviewable lessons: 207 grammar, 36 listening,
36 reading, 46 writing and 18 speaking. Its tests assert the composition rather
than freezing that total, so adding useful material does not train maintainers
to edit a magic number.

| Score | Grade |
| --- | --- |
| below the pass mark (default 70) | Again — a lapse, exactly like forgetting a card |
| pass to pass + 14 | Hard |
| pass + 15 to 94 | Good |
| 95 and above | Easy |

Only a *passed* lesson enters the rotation; an unfinished one belongs in the
learning path, not the review queue. **Practice → Lesson review** lists what is
due across all five tracks, oldest first, with how overdue each one is.

It is deliberately a list rather than an auto-advancing session. A grammar
explanation, a listening comprehension and a 340-word writing task are not
interchangeable units the way flashcards are, and queuing them as though they
were would make review feel like a chore.

### Migrating an existing profile

Lessons passed before 3.5 have no due date and decode to the epoch, which would
make every one of them due simultaneously — a learner upgrading with 150 passed
lessons would open the app to 150 overdue items. `_staggerUnscheduledActivities`
spreads them deterministically over the following fortnight on first load. It is
deterministic so that two devices restoring the same backup agree. Covered by
`test/lesson_review_test.dart`.

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
