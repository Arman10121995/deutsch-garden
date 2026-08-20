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
Pure data with no Flutter dependency beyond `models.dart`:

| File | Contents |
| --- | --- |
| `vocabulary.dart`, `vocabulary_expansion.dart` | 881 cards |
| `curriculum.dart`, `grammar_expansion.dart`, `skill_expansion.dart` | grammar, listening, reading, writing |
| `speaking_curriculum.dart` | speaking rehearsal lessons |
| `assessment.dart`, `test_prep.dart` | placement instrument and exam mocks |
| `conversation.dart` | 16 role-plays and 12 free-talk prompts |
| `stories.dart` | 12 graded stories / 33 chapters |
| `sentence_bank.dart` | curated practice sentences, plus derivation from the core deck |
| `achievements.dart` | achievement catalogue and daily-quest pool |

### Engines
Pure logic, no Flutter imports, individually unit-tested:

| File | Responsibility |
| --- | --- |
| `srs.dart` | SM-2 scheduling |
| `pronunciation.dart` | text normalisation, Levenshtein, word alignment, scoring |
| `conversation_engine.dart` | dialogue-turn and free-talk evaluation |

Keeping these free of Flutter is what makes them testable without a widget tree,
and it is why the dialogue tests were able to run every model answer through the
real evaluator and find three content bugs.

### State
`AppController` in `app_state.dart` owns SharedPreferences persistence, XP,
streaks, SRS state, activity scores, the mistake bank, daily counters, quests,
achievements, level unlocking and placement results. It is a single
`ChangeNotifier`; screens rebuild through `AnimatedBuilder`.

Achievements and quests are *computed from counters*, not stored as flags.
`metricValue(StatMetric)` derives every achievement's progress from real state,
so an achievement can never be out of sync with the thing it measures.

### Services
`tts_service.dart` wraps German TTS. `speech_service.dart` wraps on-device
speech recognition and degrades to typed input, reporting why. Neither requires
a cloud service run by this project.

### UI
`screens.dart` (shell, home, word list, stats, settings, profile, achievements),
`skill_screens.dart`, `study_session.dart`, `test_screens.dart`,
`conversation_screens.dart`, `story_screens.dart` and `games.dart`.

## Navigation

Five destinations: **Learn**, **Speak**, **Stories**, **Practice**, **Profile**.
Tests and exam prep live under Practice; statistics, the vocabulary library and
settings live under Profile.

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

`tool/validate_content.py` derives every content count from the Dart sources and
is the single source of truth for release metadata. It generates
`CONTENT_MANIFEST.json`, `VALIDATION_REPORT.txt` and `lib/build_info.dart`
(`--write`), and fails the build when `pubspec.yaml`, `CHANGELOG.md` or
`README.md` disagree with the sources. Before 3.5 those numbers were maintained
by hand in five places and had drifted: pubspec said 3.2.1, the changelog said
3.4.1, the README said 881 cards, the manifest said 931.
