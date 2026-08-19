# DeutschGarden 3.0

DeutschGarden is an offline-first Flutter application for structured German study from **A1 to C2**. It combines vocabulary spaced repetition, grammar, listening, reading, writing, speaking rehearsal, an adaptive placement assessment, and original CEFR/Goethe-style exam-preparation mini mocks.

## What is included

- A1 → A2 → B1 → B2 → C1 → C2 progression
- Six learning tracks per level: Vocabulary, Grammar, Listening, Reading, Writing, Speaking
- **881 bundled vocabulary cards** across A1–C2
- **96 grammar lessons** (16 per level)
- **36 listening lessons** (6 per level)
- **36 reading lessons** (6 per level)
- **36 writing lessons** (6 per level)
- **18 speaking lessons** (3 per level)
- **36 adaptive placement items** (6 per CEFR band)
- **12 original exam-prep mini mocks** (2 per level)
- German TTS, SRS scheduling, article drills, typed recall, XP, streaks, favorites, search, daily goals, theme settings and persistent offline progress
- Placement results can unlock a sensible starting band instead of forcing an experienced learner through A1

## Vocabulary-size policy

There is **no official CEFR rule saying that A1, A2, B1, B2, C1 or C2 equals one fixed number of words**. CEFR is a proficiency framework. Language-specific Reference Level Descriptions may map forms, words and grammar to CEFR levels, and Goethe publishes exam-oriented word lists for some lower levels, but a universal word-count table would be misleading.

DeutschGarden therefore separates:

1. **Bundled training-card inventory** — 881 curated/original learner-facing cards in this release.
2. **Lexical breadth targets** — internal cumulative planning targets used in curriculum documentation, not claimed as official CEFR thresholds.
3. **Demonstrated proficiency** — measured through vocabulary plus grammar, reading, listening, writing and speaking performance rather than word count alone.

See `docs/VOCABULARY_POLICY.md` and `docs/CURRICULUM.md`.

## Build locally

### Requirements

- Current stable Flutter SDK compatible with Dart 3.9+
- Android SDK / Android build tools
- Java supported by your Flutter/Android toolchain

### Windows

```powershell
.\bootstrap_android.ps1
flutter analyze
flutter test
flutter build apk --release
```

### Linux / macOS

```bash
chmod +x bootstrap_android.sh
./bootstrap_android.sh
flutter analyze
flutter test
flutter build apk --release
```

APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Build using GitHub Actions

The repository contains `.github/workflows/android-apk.yml`. Push the project to a GitHub repository, open **Actions → Build Android APK → Run workflow**, and download the `DeutschGarden-APK` artifact.

## Project structure

```text
lib/
  app.dart                  Material app and theme
  app_state.dart            persisted learning state / progression
  assessment.dart           A1–C2 placement-test instrument data
  curriculum.dart           core grammar/listening/reading/writing
  curriculum_meta.dart      documented curriculum breadth targets
  grammar_expansion.dart    comprehensive grammar coverage additions
  skill_expansion.dart      additional listening/reading/writing content
  speaking_curriculum.dart  speaking rehearsal curriculum
  test_prep.dart            exam profiles and original mini mocks
  test_screens.dart         placement + test-prep UI
  study_session.dart        vocabulary quiz/SRS session engine
  vocabulary.dart           core vocabulary
  vocabulary_expansion.dart expanded vocabulary bank
  models.dart               domain models
  screens.dart              main navigation/home/stats/settings
  skill_screens.dart        six skill interfaces
  tts_service.dart          German TTS wrapper

docs/                       architecture, curriculum, QA, release docs
instrument/                 placement/exam assessment blueprints
test/                       Flutter unit/content tests
tool/                       manifest patching + content validators
.github/workflows/           reproducible Android CI build
```

## Important assessment limits

- Placement is a **diagnostic study-placement instrument**, not an official CEFR certificate.
- Exam tasks are **original DeutschGarden practice tasks**, not copied Goethe exam papers.
- Offline writing scoring checks transparent task-completion features; it is not a human examiner.
- Offline speaking is guided rehearsal/self-assessment; this version does not claim automatic pronunciation certification.
- TTS quality depends on the German voice installed on the device.

## Documentation map

- `docs/CURRICULUM.md` — A1–C2 scope and skill coverage
- `docs/GRAMMAR_COVERAGE.md` — grammar syllabus by level
- `docs/VOCABULARY_POLICY.md` — vocabulary targets and limitations
- `docs/ASSESSMENT.md` — placement algorithm and interpretation
- `docs/TEST_PREP.md` — exam-preparation design and module timing references
- `docs/ARCHITECTURE.md` — code architecture and storage model
- `docs/CONTENT_QA.md` — validation rules
- `docs/BUILD_AND_RELEASE.md` — Android build/release instructions
- `docs/PRIVACY.md` — local-data behavior
- `docs/SOURCES.md` — external reference sources and attribution policy
- `instrument/PLACEMENT_BLUEPRINT.md` — assessment instrument blueprint
- `instrument/EXAM_BLUEPRINTS.md` — mini-mock blueprint

## License

Source code and original DeutschGarden content in this package are distributed under the MIT License in `LICENSE`. External sources listed in `docs/SOURCES.md` are used as **reference frameworks only**; their copyrighted test materials and proprietary content are not bundled.
