# The streamlined learning path

**Status:** Accepted
**Date:** 2026-08-28

## The problem found in the audit

DeutschGarden had solved content breadth before it solved choice. The shell
offered five destinations — Home, Course, Speak, Practice and Profile — while
Home and Course both tried to answer “what should I do next?”. Speak duplicated
role-plays already assigned to course units, and Practice mixed scheduled
reviews, optional games, long-form libraries and official tests in one scroll.

The unit model had the same problem one level down. A teaching unit exposed
between **12 and 16 equal-looking activities**. It was technically complete:
all lessons, stories, writing, role-plays and Gartenradio episodes were dealt
into the course automatically. Pedagogically it looked like a catalogue, not a
lesson sequence.

Three concrete inconsistencies made this worse:

- the vocabulary step opened a catalogue and required a second choice before
  learning began;
- placement into B1 opened B1 but the generic Continue algorithm still chose
  the unfinished A1 unit first;
- passing the A1 course level test opened A2 inside the course map but did not
  unlock A2 in the rest of the app.

## Decision

### One path, one library, one profile

The top level now has three destinations:

| Destination | Job |
| --- | --- |
| **Learn** | Runs the next useful actions as one guided session |
| **Explore** | Holds vocabulary and skill libraries, specialist drills and tests |
| **Profile** | Holds personal progress, achievements and settings |

Speaking is not a separate path. It appears automatically in course units and
remains browseable under Explore. The course map is not a competing tab; it is
a secondary view reached from Learn.

### A calculated session rather than another stored checklist

Learn builds a short required queue each time it renders:

1. due vocabulary retrieval, in a focused batch of at most 20;
2. the oldest due lesson, opened directly;
3. the exact next core activity in the current unit — including its automatic
   matching, sentence-building or dictation retrieval step — or its checkpoint;
4. targeted mistake repair when the bank is non-empty;
5. optional enrichment is calculated separately and labelled as optional.

Only the first required action is a decision. The rest appear as a collapsed
session preview rather than individually tappable alternatives. When an
activity is completed, Learn recalculates from the existing progress maps and
offers the new next step in the same guided session. Backing out, failing a
gate, or reaching a deliberate batch cap ends the session instead of reopening
the same route in a loop. No parallel “plan state” can disagree with real
progress and no profile migration is needed.

Scheduled vocabulary and lesson review no longer appear again in Explore: if
they are due, Learn includes them automatically. Mistake repair and difficult
words remain available under Explore as deliberate diagnostic tools. The
searchable vocabulary library moved from Profile to Explore, where learning
content belongs.

### Core versus enrichment

Every piece of content remains assigned to one unit. The assignment now has an
explicit distinction:

- **Core path:** all ordered grammar, the cumulative vocabulary target and
  enough supporting work to include both reception and production. A teaching
  unit has **7–9 core activities**.
- **Extra practice:** the other stories, broadcasts, writing tasks and
  role-plays attached to the same topic/level. These are visible in one
  collapsed section and never block a checkpoint.

Supporting work is selected deterministically. Each core takes a receptive
activity (listening, reading, story or radio) and a productive activity
(writing, speaking or role-play) whenever the unit has both, then adds distinct
types until its support allowance is full. Vocabulary comes first and grammar
alternates with application instead of appearing as four consecutive rules.

Every unit also receives one finite retrieval exercise, rotating between
matching, sentence building and dictation. It is completed and scheduled like
the rest of that unit, then Learn advances automatically. The specialist labs
remain in Explore for voluntary overlearning; they are not a second required
path.

Checkpoints draw only from the core. Testing an optional activity would make it
mandatory under another name.

## What remains separate, and why

- **Placement and CEFR mocks** measure a level; they are not teaching steps.
- **Leben in Deutschland / Einbürgerungstest** is an official civic-knowledge
  goal with Bundesland selection and legal thresholds, not a CEFR language
  unit.
- **Practice labs** are deliberate overlearning tools. They can be chosen when
  a learner wants extra repetition without obscuring the required sequence.
- **Profile/settings** are account-local controls, not learning content.

Everything else is either scheduled directly by Learn or attached to a unit.

## Compatibility

No activity, lesson, story, checkpoint or unit id changed. Existing completions
still count, and old optional completions remain visible. The only state change
is interpretive: optional attached content no longer delays checkpoint
readiness. Existing checkpoint scores and placement results keep their meaning.

## Enforced invariants

Tests now require:

- exactly three learner-facing top-level destinations;
- every teaching unit to retain all attached content but expose only 7–9 core
  activities;
- each core to contain receptive and productive application;
- every unit to contain exactly one uniquely identified retrieval exercise;
- optional enrichment not to affect readiness;
- placement to make the placed level the next level;
- a passed level test to unlock the next level everywhere;
- due review to precede new material in the calculated session;
- optional enrichment never to become the primary required action;
- finishing a core to replace its next action with the checkpoint.
