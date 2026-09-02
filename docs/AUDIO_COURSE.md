# The audio course

Two ideas that predate this app by decades, both of them scheduling rather
than content. The sentence bank already holds 9,211 German sentences with
translations; the audio course authors nothing new.

## What you hear today

Glossika's shape. Each day introduces ten new sentences and replays the
batches from **1, 2, 4, 8, 16 and 32 days ago** — each gap twice the last.

A sentence met on day 1 comes back on days 2, 3, 5, 9, 17 and 33, and then
never again. Six exposures over a month, front-loaded. That is the shape every
spacing curve that works has, and it is asserted directly in
`test/audio_course_test.dart` rather than left as a claim.

Ten new per day, because a full day is ten new plus up to sixty replayed, and
fifty-odd sentences at roughly eight seconds each is about seven minutes. That
is a session someone does on a commute. Twenty new would double it, and
doubling it is how audio courses become the thing you stop doing.

## How each sentence is drilled

Pimsleur's shape, in four stages:

| Stage | What happens | Why |
| --- | --- | --- |
| **Read it** | The English appears. Nothing is spoken. | A beat to take it in. |
| **Say it, out loud** | Silence. | This is the exercise. |
| **Listen** | The German is spoken and revealed. | The correction, a beat after the attempt. |
| **Once more** | The German again, at 0.85× | A model to imitate rather than produce. |

The gap scales with the sentence: about 600 ms a word, floored at 2.5 seconds
and capped at 9. A fixed five-second gap is absurdly long for *Ich bin müde*
and far too short for a B2 sentence with a verb bracket at the end.

The stage is named on screen throughout. Without that, the silence is
indistinguishable from the app having frozen, and a learner who thinks it has
frozen will not use the gap for what it is for.

Nothing autoplays. The learner presses Play when they are somewhere they can
speak out loud.

## Listen-through player

The day overview also offers a full long-form transport player for the same
playlist. It supports play, pause, stop, replay ten seconds, forward ten
seconds, timeline scrubbing and 0.6× / 0.75× / 1.0× / 1.25× speed. This mode
is for receptive listening; **Start today** opens the anticipation drill above,
where the intentional silence is the speaking exercise. On a system-TTS
fallback the transcript remains available and the app labels scrubbing as
unavailable rather than pretending that the control works.

## What is stored: one integer per level

The obvious implementation gives every sentence an SM-2 record and asks the
scheduler what is due. That would work. It would also put several thousand
entries into the profile, flood the practice hub's "lessons due" count with
things that are not lessons, and make today's session depend on the exact
minute of every past answer.

A fixed day schedule needs one number per level: how many days are done. The
spacing is then a pure function of the day index, so the same day always
produces the same playlist, two devices restoring one backup agree, and the
whole thing is testable without a clock.

**The trade is real and worth naming.** This does not adapt to the individual
sentence: one you find hard returns on the same schedule as one you find easy.
Per-item adaptation already exists for vocabulary, where the unit of
difficulty is a word. Here the unit is a sentence heard in sequence, and
Glossika's own answer to that problem is repetition volume rather than
per-item scheduling. If it turns out to matter, the fix is to add a
difficulty nudge, not to rebuild this as an SRS.

Replaying an earlier day is allowed — re-listening is a reasonable thing to
want — and the counter is guarded so it neither advances nor rewinds when you
do.

## Where it lives

| File | What it holds |
| --- | --- |
| `lib/audio_course.dart` | The day arithmetic, the gap curve, `playlistFor()` |
| `lib/audio_course_screens.dart` | The day card, listen-through transport player and drill player |
| `test/audio_course_test.dart` | The spacing curve, batch arithmetic, edge days |
| `test/audio_course_screens_test.dart` | Concealment during the gap, pausing, the day counter |

Reached from **Practice → Audio course**.
