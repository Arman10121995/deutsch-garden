# Architecture

## Design goals

- offline-first
- no mandatory account/backend
- deterministic local curriculum
- persistent progress
- clear separation between content, state and UI
- no false certification claims

## Layers

### Models
`lib/models.dart` contains CEFR, skill, vocabulary, progress and lesson types.

### Curriculum/content
`vocabulary*.dart`, `curriculum.dart`, `grammar_expansion.dart`, `skill_expansion.dart`, `speaking_curriculum.dart`, `assessment.dart`, and `test_prep.dart` are the bundled content/instrument layer.

### State
`AppController` in `app_state.dart` handles SharedPreferences persistence, XP/streaks, SRS progress, activity scores, level unlocking and placement results.

### Services
`tts_service.dart` wraps German TTS. No cloud speech service is required.

### UI
`screens.dart`, `skill_screens.dart`, `study_session.dart` and `test_screens.dart` provide the application interface.

## SRS
Vocabulary mastery ranges 0–5. Correct answers increase mastery and schedule progressively longer intervals (1, 2, 4, 8, 16 days after initial acquisition); errors reduce mastery and reschedule quickly.

## Level mastery
Vocabulary progress now uses the entire bundled deck for the level instead of only the top few cards. Lesson-based skills average persisted best scores. Overall level progress averages all six skills.

## Data migration
Version 3 reads v3 state first and falls back to v2/v1 local-state keys, then rewrites current state.
