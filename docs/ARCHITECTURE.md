# Architecture

## Design goals

- offline-first
- no mandatory account/backend
- deterministic local curriculum
- persistent progress
- clear separation between content, state and UI
- no false certification claims, and no capability claimed that the code does not have

## Layers

### Models
`lib/models.dart` contains CEFR, skill, vocabulary, progress, mistake and lesson
types.

### Curriculum and content
The Dart content tables are pure data with no Flutter dependency beyond
`models.dart`; the civics catalogue is a bundled JSON asset decoded through
Flutter's asset bundle:

| File | Contents |
| --- | --- |
| `vocabulary*.dart` | 10,000 cards across four source files |
| `curriculum.dart`, `grammar_expansion.dart`, `skill_expansion.dart`, `story_writing.dart` | 207 grammar, 36 listening, 36 reading and 120 writing lessons |
| `speaking_curriculum.dart` | 18 speaking rehearsal lessons |
| `assessment.dart`, `test_prep.dart` | placement instrument and exam mocks |
| `conversation*.dart` | 60 role-plays and 12 free-talk prompts |
| `stories*.dart`, `mini_story.dart` | 60 graded stories / 200 chapters and 60 four-mode mini-story drills |
| `radio*.dart` | 120 authored long-form Gartenradio episodes with 720 checkpoint blocks |
| `sentence_bank.dart`, `cloze_bank.dart` | 9,211 sentence exercises and 8,314 derived cloze items |
| `course.dart`, `learning_path.dart`, `audio_course.dart` | 72-unit course spine, calculated next-session queue and spaced sentence-audio course |
| `assets/civics/` | official 460-question LiD/citizenship catalogue and 100 images |
| `achievements.dart` | achievement catalogue and daily-quest pool |

### Engines
Pure logic, no Flutter imports, individually unit-tested:

| File | Responsibility |
| --- | --- |
| `srs.dart` | SM-2 scheduling |
| `pronunciation.dart` | text normalisation, edit distance, word alignment and transcript-based scoring |
| `conversation_engine.dart` | dialogue-turn and free-talk evaluation |
| `german_text.dart` | German-aware typed-answer matching and umlaut folding |
| `civics_test.dart` | catalogue decoding, Bundesland filtering, deterministic mock selection and dual-threshold scoring |

Keeping these free of Flutter is what makes them testable without a widget tree,
and it is why the dialogue tests were able to run every model answer through the
real evaluator and find three content bugs.

### State
`AppController` in `app_state.dart` owns SharedPreferences persistence, XP,
streaks, SRS state, activity scores, the mistake bank, daily counters, quests,
achievements, level unlocking, placement results and compact civics-test
progress. It is a single
`ChangeNotifier`; screens rebuild through `AnimatedBuilder`.

Achievements and quests are *computed from counters*, not stored as flags.
`metricValue(StatMetric)` derives every achievement's progress from real state,
so an achievement can never be out of sync with the thing it measures.

### Services
`tts_service.dart` routes German audio to the bundled CC0 Piper voice first and
to an operating-system synthesiser as a fallback. Native synthesis runs in a
worker isolate and writes a reusable WAV rather than blocking Flutter's UI.
`speech_service.dart` wraps platform speech recognition and degrades to typed
input, reporting why. Neither requires a cloud service run by this project,
although a mobile operating-system recogniser may itself use its vendor's
service unless an offline language pack is installed.

### UI
`screens.dart` (shell, stats, settings, profile, achievements),
`learning_path_screen.dart`, `explore_screen.dart`,
`vocabulary_library_screen.dart`, `skill_screens.dart`,
`course_screens.dart`, `audio_course_screens.dart`,
`radio_screens.dart`, `study_session.dart`, `test_screens.dart`,
`civics_test_screens.dart`,
`conversation_screens.dart`, `story_screens.dart`, `mini_story_screens.dart`
and `games.dart`.

## Navigation

Three destinations: **Learn**, **Explore**, **Profile**. Learn calculates due
review plus the exact next course action, then offers the recalculated next
step when an activity finishes; the course map stays secondary. Explore groups
the vocabulary and skill libraries, speaking, stories, Gartenradio, practice
labs, CEFR tests and LiD/citizenship preparation. Profile contains only
personal statistics, achievements and settings. See
`docs/LEARNING_PATH.md`.

## Spaced repetition

SM-2 with learning steps, per-card ease and lapse tracking. See `docs/SRS.md`.

## Level mastery

Vocabulary progress uses the entire bundled deck for the level. Lesson-based
skills average persisted best scores. Overall level progress averages all six
skills; role-plays and stories have their own progress readouts and do not
inflate the six-skill figure.

## Data migration

Version 4 reads the v4 key first and falls back to v3, v2 and v1, then rewrites
current state. `WordProgress.fromJson` seeds SM-2 fields from the pre-3.1 mastery
ladder so upgrading does not reset anyone's schedule. `ActivityProgress` gained
the same SM-2 fields in 3.5; lessons passed before then are staggered over a
fortnight rather than all falling due at once.

## Surviving a bad profile

The whole profile is one JSON string under one key, which makes a failed parse
an all-or-nothing event. Until 3.5 that event was handled by swallowing the
exception and then calling `_save()` anyway, so an unreadable profile was
overwritten with a blank one on the next frame — silently, and with no copy
kept. A learner would simply find themselves back at zero XP with no
explanation.

Three things now stand between a bad write and a lost year of reviews:

1. **Nothing is applied part-way.** `_tryApply` requires the decode to produce a
   map before a single field is touched, and every scalar is read through the
   coercion helpers in `lib/models.dart` rather than an `as` cast, so one
   wrong-typed value costs that field alone instead of throwing mid-rehydrate.
2. **The unreadable bytes are kept.** They move to
   `deutsch_garden_state_corrupt` instead of being overwritten, and Settings can
   hand them back as text.
3. **There is a snapshot to fall back to.** After every successful load the
   parsed state is written to `deutsch_garden_state_v4_snapshot` — by
   construction a blob that is known to load. A corrupt primary is restored from
   it automatically.

Whatever the outcome, `recoveryNotice` is set and the shell shows a banner. A
silent reset is the one failure mode that must never look like a fresh install.

Values loaded from disk are also bounded: `ease` to the scheduler's own
[1.3, 3.2], `intervalDays` to [0, 365]. A corrupt or hand-edited profile can no
longer produce a card that is due in the year 2400.

Covered by `test/state_recovery_test.dart`.

## Generated files

`tool/validate_content.py` derives every content count from the Dart sources
and bundled civics JSON and is the single source of truth for release metadata.
It also verifies all 460 civics questions, answer indices, state distribution
and image hashes. It generates
`CONTENT_MANIFEST.json`, `VALIDATION_REPORT.txt` and `lib/build_info.dart`
(`--write`), and fails the build when `pubspec.yaml`, `CHANGELOG.md` or
`README.md` disagree with the sources. Before 3.5 those numbers were maintained
by hand in five places and had drifted: pubspec said 3.2.1, the changelog said
3.4.1, the README said 881 cards, the manifest said 931.
