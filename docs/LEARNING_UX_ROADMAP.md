# Learning and usability roadmap

Written after 4.24.0 from two audits of the app as a learner. It lists every
open finding as a task that one agent or person can pick up and finish alone.
Read `AGENTS.md` first.

`ENGINEERING_PLAN.md` is the earlier engineering plan and has fully landed.
This file continues it with sections G to K, and the same script tracks both.

## How to work on this

```sh
python tool/plan_status.py          # every item and whether it has landed
python tool/plan_status.py next     # the next open item
```

- **One item per commit, on `main`.** Start the subject with the item id:
  `G5: choose speed-review options by word class`.
- **Check nobody else has it.** Run `git pull --rebase origin main`, then
  `git log --oneline --grep "^G5"`. If the item is there, take another.
- **An item has landed when its probe passes.** Each item names a phrase under
  **Proved by**. The item is done when a test in `test/` has that phrase in its
  description and passes, or when the stated code condition holds.
  `tool/plan_status.py` looks for exactly that, so do not reword the phrase.
- **Stay inside the item.** If you find something else, add it to this file as
  a new item in the same commit; do not fix it there.
- **Run the gate in `AGENTS.md` before pushing.**
- User-facing text goes through `lib/l10n/app_en.arb` and `app_de.arb`
  (informal *du* in German). Do not change card content, scoring or the
  scheduler unless the item says so.

### Seeing the screens

```sh
flutter test tool/audit/capture_screens.dart --update-goldens \
    --dart-define=SHOTS=/absolute/output/folder
```

writes about seventy PNGs in under a minute: every main screen at phone size
in the dark theme, plus samples in the light theme, in German, at 150% text
and at desktop width. Add an entry there when you change a screen. Emoji draw
as empty boxes in these images (no emoji font in the test engine), so they are
not evidence about emoji. For the real web build see
`docs/LOCAL_DEVELOPMENT.md`; it takes about ten minutes to build.

### Evidence

Each item says how it is known:

- **seen in app**: observed in the running web build at phone width.
- **seen in render**: observed in the captured images.
- **seen in code**: found in the source, and confirmed there.

## G. The answer loop

### G1 — Mark answers the same way everywhere

Evidence: seen in render and in code.

4.24 added `AnswerOptionButton` (tick on the right answer, cross on a wrong
pick) to the vocabulary session and the lesson quizzes only. The cloze drill
and the grammar challenges tint the right option green but leave its label
dimmed and add no mark; civics, driving, stories, radio and mini-stories draw
their own options, several with `Colors.green` / `Colors.red` alone.

Do one family per commit:

| Id | Screens | File |
| --- | --- | --- |
| G1a | Civics practice | `lib/civics_test_screens.dart` |
| G1b | Driving practice | `lib/driving_test_screens.dart` |
| G1c | Story and mini-story questions | `lib/story_screens.dart`, `lib/mini_story_screens.dart` |
| G1d | Radio checkpoints | `lib/radio_screens.dart` |
| G1e | Cloze, verb lab, grammar challenges, speed review | `lib/games.dart` |
| G1f | Exam mini mocks and course checkpoints | `lib/test_screens.dart`, `lib/course_screens.dart` |

A live mock or the placement test must still reveal nothing before it is
submitted.

**Proved by** `AnswerOptionButton` being used in each listed file, plus a
widget test per family asserting the `AnswerOptionState` of the right option
and of a wrong pick.

### G2 — Number keys and Enter in the same screens

Evidence: seen in code. Do after the matching G1 family.

Key handling exists only in the vocabulary session, the lesson quizzes and the
review flashcards. Use `answerDigitFor` and `isAdvanceKey` from
`lib/answer_option.dart`. Treat Enter or Space as "continue" only while the
handler's own node has the primary focus.

**Proved by** `answerDigitFor` being used in `lib/games.dart`,
`lib/civics_test_screens.dart` and `lib/driving_test_screens.dart`.

### G3 — Introduce a few new words before testing them

Evidence: seen in app.

A learn session shows one word and tests it at once, which is closer to
copying than recalling. Show two or three cards, then test them in a different
order. A card that is not the last of its group must not say "test me".

These tests pin the current order and need updating:
`test/practice_localisation_test.dart` (two),
`test/practice_usability_test.dart` (one), `test/learning_loop_test.dart`.

**Proved by** a test described as
`a new word is not tested straight after its card`.

### G4 — Keep the session progress bar from stepping back

Evidence: seen in app.

A missed word appends a second try, so the bar's total grows and the bar moves
backwards.

**Proved by** a test described as `session progress never steps back`.

### G5 — Speed review offers random wrong options

Evidence: seen in render and in code.

*die Miete* was offered beside "to fall in love", "clean" and "monster".
`SpeedReviewScreen` in `lib/games.dart` still draws from the whole level,
which is the fault 4.24 removed from the vocabulary session.

**Proved by** `pickDistractors` being used in `lib/games.dart`.

### G6 — Cloze options are ruled out by the article in the sentence

Evidence: seen in render and in code. Two of two samples showed it.

"Der ___ ist weit entfernt." offered Flughafen, Badewanne, Dusche and
Toilette. Only one is masculine, so the gap is filled by gender without
reading the sentence. `lib/cloze_bank.dart` picks wrong options by word class
and level but not by gender. When the gap is a noun, prefer wrong options of
the same gender; fall back when there are too few.

**Proved by** a test described as `cloze options share the answer's gender`.

### G7 — A vocabulary mistake does not say which word it was

Evidence: seen in render and in code.

The mistake bank lists a missed vocabulary question as "What does this mean?",
the wrong pick and the right meaning. The German word is not shown, because
`lib/study_session.dart` stores the generic prompt. Store or resolve the word
(the entry id is `vocab-<card id>`) and show it. Entries already saved must
still display.

**Proved by** a test described as `a vocabulary mistake names its word`.

## H. Content clarity

### H1 — Short meanings as answer options

Evidence: seen in app. Measure before changing anything.

Some cards carry dictionary-style glosses: "wild animal; any animal that is
not domesticated, living under natural conditions". As an option this is hard
to scan and stands out. First count glosses over about 40 characters per
level and record the figure here. Then derive a short option label (first
sense, parenthetical removed) while the card keeps the full text. Two cards
must not share a short label inside one question.

**Proved by** a test described as `option labels stay short`.

### H2 — Word class as data instead of inference

Optional and editorial. Wrong options depend on `wordClassFor`, which guesses
from the article and the English gloss (`KNOWN_LIMITATIONS.md` #24). A
reviewed per-card tag would remove the guess. Weeks of work; do not start it
unless the maintainer asks. Not tracked by the script.

## I. Navigation, wording and first run

### I1 — Explore opens as four closed drawers

Evidence: seen in app and in render (phone and desktop).

Four collapsed sections and an empty screen below. Open the libraries section
by default. Four tests tap the "A1 libraries" header to open it and would then
close it: `test/app_smoke_test.dart` (three places),
`test/settings_civic_usability_test.dart` (one).

**Proved by** a test described as `Explore shows the libraries without a tap`.

### I2 — Onboarding is five pages of text

Evidence: seen in app.

One icon and two paragraphs per page, most of the screen blank. Shorten it and
use the original illustrations in `lib/learning_visuals.dart`. Keep Skip and
the placement-test offer.

**Proved by** a test described as `onboarding has at most three pages`.

### I3 — Scheduler numbers on the review card

Evidence: seen in app.

The review flashcard shows "Ease 2.3 · interval 0d · lapses 1". Say when the
card returns in plain words, or move the numbers behind an info button.

**Proved by** a test described as `the review card hides scheduler numbers`.

### I4 — Today's goal is shown twice on Learn

Evidence: seen in app.

4.24 added a goal bar under the title; the "Today's progress" card at the
bottom repeats the figure. Keep the daily quests in that card and drop the
duplicate.

**Proved by** a test described as `Learn states the daily goal once`.

### I5 — Three rows of controls above every civics and driving question

Evidence: seen in render.

"New to you", "Read question aloud" and "Random question" are stacked on
separate rows, so on a phone the question starts halfway down the screen.
Put them on one row (icon buttons with tooltips, or a badge plus two icons).
Shared code: `lib/test_question_tools.dart`.

**Proved by** a test described as `question tools fit on one row`.

### I6 — Radio shows the transcript before the learner has listened

Evidence: seen in render and in code.

The radio library says "Listen first, read the transcript afterwards", and
listening lessons hide the transcript behind "Reveal transcript". A radio
episode shows the whole transcript at once, with English visible by default at
A1 and A2 (`_showEnglish` in `lib/radio_screens.dart`). Hide the transcript
until the learner asks for it or has listened once. With audio switched off
there is nothing to listen to, so show it then.

**Proved by** a test described as `a radio transcript starts hidden`.

### I7 — Project wording on learner screens

Evidence: seen in render.

The vocabulary level page reads "787 bundled training cards" and "Internal
cumulative breadth target by A1: ~650 lexical units (planning target, not an
official CEFR word count)". That is a note to maintainers. Say how many words
the level has and how many the learner knows; keep the caveat in
`docs/VOCABULARY_POLICY.md`.

**Proved by** a test described as `the vocabulary page speaks to the learner`.

### I8 — Hint and Skip sit in different places

Evidence: seen in render. Small.

They are above the options in the article trainer, verb lab, cloze drill and
grammar challenges, and below them in the vocabulary session and lesson
quizzes. Put them below everywhere, so the question and its options stay
together.

**Proved by** a test described as `hint and skip follow the options`.

### I9 — Match pairs starts without a word of instruction

Evidence: seen in render. Small.

Twelve buttons and a timer. Add one line saying what to tap.

**Proved by** a test described as `match pairs says what to do`.

## J. Visual robustness

### J1 — Emoji used as icons

Evidence: seen in app (web build).

Explore items, the test hub, the review grade buttons, the Profile summary,
the statistics tiles, the lesson headers and the navigation rail logo use
emoji as icons. In the web build they were empty boxes until a font arrived.
4.24 replaced only the two on the Learn header. Use icons from the bundled
font; keep emoji for decoration that can be absent. One screen per commit.

**Proved by** `lib/explore_screen.dart` no longer passing `emoji:` to its
items. Other screens follow the same pattern.

### J2 — One colour definition for right and wrong

Evidence: seen in code. Mostly falls out of G1; not tracked separately.

Replace remaining `Colors.green` / `Colors.red` feedback with
`answerCorrectColor` and the scheme's error colour.

### J3 — One interface string outside the translation gate

Evidence: seen in code.

`lib/separable_verb_animation.dart` has a literal `Text('…')` and is not in
the `MIGRATED` list of `tool/check_l10n.py`. Decide whether it is interface
text or German content; migrate it or record why not.

**Proved by** the file being named in `tool/check_l10n.py`.

### J4 — "about 1 minutes"

Evidence: seen in render and in code.

`audioDaySummary` and `orderedSteps` in `lib/l10n/app_en.arb` end in
"about {minutes} minutes" with no plural form. Fix both locales.

**Proved by** `audioDaySummary` using a `plural` form in `app_en.arb`.

### J5 — Opened screens stretch across a desktop window

Evidence: seen in render at 1280 px.

The three tabs are capped at 1100 px, but any screen opened from them is not:
the new-word card, its button, the story reader and Settings span the full
window. Cap pushed screens at a readable width too, in one place rather than
per screen.

**Proved by** a test described as `an opened screen keeps a readable width`.

## K. Not audited yet

These are tasks. Finish one by adding its findings to sections G to J with the
same fields, in one commit, without fixing anything.

| Id | What | Why it was not covered |
| --- | --- | --- |
| K1 | Audio: voices, pacing, the long-form player, dialogue turns | Sound was off in every check |
| K2 | Microphone: speaking lessons, role-plays, pronunciation lab, shadowing | No microphone in the test engine |
| K3 | Second and later states: answered civics and driving questions, result pages, a finished mock, a full role-play | Only first states were captured |
| K4 | Content above A1: stories, radio, grammar and options at B1 to C2 | Only A1 was walked |
| K5 | Screen reader and 200% text | Tests cover 150% text at 320 px only |
| K6 | Native Android and Windows builds on a real device | Only the web build was run |
| K7 | Backup, restore, identity and reset flows | Not opened |

Audited with nothing to report: the light theme on seven screens, the German
interface on four screens including 150% text, and the wide layout of the
three tabs.

## Suggested order

1. G5, G7 and J4: small, self-contained, each a visible defect.
2. G1 by family, then G2 for the same family.
3. G6 and G3: the two that most change how much an answer teaches.
4. I6, I5, I7, I3, I1: clarity on screens learners see every day.
5. J5 and J1, then H1, I2 and the small ones (I4, I8, I9, G4, J3).

`plan_status.py next` simply prints the first open item in list order; use
the order above when choosing. The K audits can run at any time, by any agent.
