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
ladder so upgrading does not reset anyone's schedule.
