# The course spine

## What problem this solves

The app held several hundred lessons, ten thousand vocabulary cards, sixty
podcast episodes, thirty stories and no answer to the only question a learner
actually asks: *what should I do next?* Opening it meant choosing a level,
choosing a skill, choosing a lesson, and inventing a study plan before any
studying could begin.

That is a sequencing problem, not a content problem. The upgrade plan named it
as the single change most likely to affect whether anyone is still using the
app in month three, and this is that change. Nothing here is new material.

## The shape

**Seventy-two units. Twelve per level. Four teaching units, then a review,
repeating, and the level closes on a level test.**

```
A1:  1  2  3  4  [R]  6  7  8  9  [R]  11  [LEVEL TEST]
A2:  1  2  3  4  [R]  6  7  8  9  [R]  11  [LEVEL TEST]
...
```

A **teaching unit** carries:

- a can-do outcome in the first person — "I can say what I did yesterday in
  the Perfekt", not "the Perfekt";
- four grammar lessons, named explicitly and in the order they should be met;
- a compact required mix of listening, reading, writing, speaking, story,
  role-play and Gartenradio material;
- the rest of the automatically assigned material as optional enrichment;
- a cumulative vocabulary target;
- one finite retrieval-practice step — matching, sentence building or
  dictation — selected deterministically for that unit;
- a checkpoint of ten questions drawn from the unit itself.

A **review unit** folds the previous four units' grammar back together, with
fourteen questions that prefer a *different* drill from each lesson, so a
learner who has just passed four checkpoints is not answering the same items
from memory.

The **level test** at the end of each level covers every teaching unit of that
level, not just the trailing block. It is the last gate before the next level,
so testing one unit there would not have been a level test in any meaningful
sense.

## Core path and attached enrichment

The first implementation treated every automatically assigned resource as an
equal prerequisite. Once the libraries grew, that produced 12–16 rows in one
teaching unit. Complete coverage had become learner-facing overload.

A teaching unit now exposes **7–9 core activities**: its ordered grammar, its
cumulative vocabulary target and a deterministic support mix containing both
receptive and productive practice whenever available. Vocabulary comes first;
grammar then alternates with application instead of appearing as a block of
four rules.

The support mix includes exactly one integrated retrieval exercise. Its mode
rotates across matching, sentence building and dictation, and its activity id
contains the unit id. Completing A1 matching can therefore never mark a later
unit's matching step complete. These are finite course activities, not endless
game sessions: after the batch is scored the learner returns to the same
guided path and Learn calculates the next required action.

Every other dealt story, broadcast, writing task and role-play remains attached
under **Extra practice**. It is tracked normally but does not hold the
checkpoint hostage. The checkpoint draws only from the core. This distinction
changes no ids and preserves every existing completion.

The Learn screen sits above the map and calculates the next useful action:
spaced review, the exact next core step or checkpoint, mistake repair, then one
optional reinforcement. See `LEARNING_PATH.md`.

## Gating

A unit opens when the previous unit's checkpoint is passed at **80%**.

Eighty rather than a bare pass: the checkpoint is the only thing between a
learner and material they are not ready for, and a gate at 60% is not a gate.
Not higher, because someone who understood the unit and misread one question
out of ten should not be held back.

Two escape hatches, because gating without them is hostile to the many people
who do not start at zero:

- **The placement test opens the level it places you in.** Testing into B1
  opens B1 unit 1 directly. It opens the *first* unit of that level, not the
  whole level — the sequence still has to be walked, just not from A1.
- **A checkpoint can be sat cold.** Nothing requires the steps to be ticked
  first. The gate is the score, not the tick list; the UI simply does not push
  someone into a test they have not prepared for.

A missed checkpoint question goes into the mistake book like any other, so the
thing that blocked progress is also the thing offered for review.

## What is hand-written and what is not

**Hand-written:** which grammar lesson belongs in which unit, in what order,
and what the unit lets you do. That is a teaching judgement, and it lives as a
data table in `lib/course.dart`.

This is the substance of the file. The catalogue's own ids are not a teaching
order — `gr-a1-01` is verb position, which needs personal pronouns and `sein`
first, and those live at `gr-a1-x01` and `gr-a1-x02`. Renumbering the
catalogue was the obvious alternative and it is not available: lesson ids are
written into every saved profile, so renumbering would silently discard
people's progress.

**Not hand-written:** which listening lesson lands in unit three. Supporting
material is dealt out card-style from the lesson registry, interleaved by kind
so a unit gets a listening lesson and a story rather than three listening
lessons.

One consequence worth knowing: adding a listening lesson to the catalogue puts
it into a unit automatically and deterministically decides whether it is core
or enrichment; adding a *grammar* lesson does not. It has to be placed, and the
test suite fails until it is. That asymmetry is deliberate — placing a grammar
point is a decision, and defaulting it would quietly undo the ordering this
file exists to state.

## Nothing new is stored

A unit's state is derived from the activity progress the app already keeps.
Every lesson, story chapter, role-play and radio episode already records
itself through `recordActivity`, so the spine is a view over that rather than
a second copy of it. The only new key in a profile is one checkpoint result
per unit, which is an ordinary activity record.

The practical effect: a learner who worked through half the A1 lessons before
this existed opens the course and finds half of it already ticked. There is no
migration, because there is nothing to migrate.

`courseStatus()` is a pure function of the activity map, the per-level word
counts and the placement level, which is why the gating rules are testable
without building a widget.

## Vocabulary

Twenty new words per teaching unit, counted cumulatively against the level.
That is 1,080 words across the course, out of ten thousand in the deck.

This is deliberate and worth being plain about: **the course does not claim to
walk the whole vocabulary.** Ordered grammar, three or four supporting core
activities and twenty new words is already substantial. Spaced
repetition runs across all ten thousand cards independently, and the
vocabulary library remains open. The course sequences; it is not the only door
to the content.

## Where it lives

| File | What it holds |
| --- | --- |
| `lib/course.dart` | The unit table, integrated retrieval steps, checkpoints, and `courseStatus()` |
| `lib/course_screens.dart` | Course map, unit screen, checkpoint runner |
| `lib/learning_path.dart` | Pure automatic-session selection over existing progress |
| `lib/learning_path_screen.dart` | Default Learn destination and direct routing |
| `test/course_test.dart` | Spine invariants: coverage, ordering, checkpoint sanity, gating |
| `test/course_screens_test.dart` | The checkpoint end to end, pass and fail |
| `test/learning_path_test.dart` | Review priority, direct continuation and placement behavior |

The spine invariants are enforced by tests rather than by review. Notably,
`every grammar lesson is placed exactly once` checks both directions: a unit
naming a lesson that does not exist fails, and a lesson that exists but no
unit teaches fails too.
