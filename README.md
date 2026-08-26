# DeutschGarden 3.10

DeutschGarden is a fully offline Flutter application for structured German study from **A1 to C2**, running on **Android, Windows, macOS, iOS, Linux and the web from one codebase**. It combines adaptive spaced repetition, grammar, listening, reading, writing, a spoken conversation tutor, a graded-reader story mode, practice games, an adaptive placement assessment, and original CEFR/Goethe-style exam-preparation mini mocks.

## What is included

- A1 → A2 → B1 → B2 → C1 → C2 progression
- **A 72-unit course** that says what to do next: four teaching units then a review, twelve per level, each with a can-do outcome and a checkpoint that opens the next unit at 80% — see `docs/COURSE.md`
- Six learning tracks per level: Vocabulary, Grammar, Listening, Reading, Writing, Speaking
- **10,000 bundled vocabulary cards** across A1–C2
- **207 grammar lessons**
- **36 listening lessons** (6 per level)
- **36 reading lessons** (6 per level)
- **46 writing lessons**
- **18 speaking lessons** (3 per level)
- **36 adaptive placement items** (6 per CEFR band)
- **12 original exam-prep mini mocks** (2 per level)
- **23 spoken role-plays** with the AI tutor and **12 open speaking prompts**
- **21 graded stories / 56 chapters** with tap-a-word lookup and comprehension checks
- **53 narrated Gartenradio episodes** — news, weather, announcements, voicemail, recipes, audio guides and short lectures, with transcripts and comprehension questions
- **61 curated practice sentences** plus every core example sentence, feeding the sentence builder and dictation drills
- **27 achievements** and three rotating daily quests
- Adaptive SM-2 review with per-card ease, lapse tracking, learner-written mnemonics and a difficult-words queue
- **Lessons come back too**: grammar, listening, reading, writing and speaking lessons are scheduled by the same algorithm as vocabulary, so a lesson passed in week one resurfaces before it is forgotten rather than never again
- A mistake bank collecting every wrong answer across all skills
- **A bundled German voice** (Piper VITS, CC0) synthesised on device, so every platform sounds the same and Linux no longer falls back to espeak
- German TTS, on-device speech recognition, immersion mode, article drills, typed recall, XP, streaks, favorites, search, daily goals, theme settings and persistent offline progress
- Placement results can unlock a sensible starting band instead of forcing an experienced learner through A1

## Quick start (local)

```bash
git clone https://github.com/Arman10121995/deutsch-garden.git
cd deutsch-garden
make setup     # Windows: .\dev.ps1 setup
make run       # hot reload on this machine
make verify    # content check + analyze + tests, exactly what CI runs
```

Run `make` on its own to list every command. Full setup notes, including what
to install per OS, are in [`docs/LOCAL_DEVELOPMENT.md`](docs/LOCAL_DEVELOPMENT.md).

Development is local. CI runs the correctness gate on every push and builds
installable artifacts only when you ask — **Actions → CI → Run workflow**, or by
pushing a `v*` tag.

## Platforms

Download any of these from the
[latest release](https://github.com/Arman10121995/deutsch-garden/releases/latest);
a copy also lives in [`release/`](release/) in this repository.

| Target | Download |
| --- | --- |
| Android | `DeutschGarden.apk` |
| Windows | `DeutschGarden-windows-x64.zip` containing `DeutschGarden.exe` |
| Linux | `DeutschGarden-x86_64.AppImage`, or the `.tar.gz` bundle |
| macOS | `DeutschGarden-macos.zip` containing `DeutschGarden.app` |
| iOS | `DeutschGarden-ios-unsigned.ipa` — unsigned, sign it with your own identity |
| Web | `DeutschGarden-web.tar.gz` — a static PWA, serve it from any host |

Install steps per platform are in [`docs/PLATFORMS.md`](docs/PLATFORMS.md), and
what your OS will warn about is in
[`docs/SECURITY_WARNINGS.md`](docs/SECURITY_WARNINGS.md).

Every build comes from the same `lib/`. Build one locally with
`make build-android` / `build-linux` / `build-macos` (`.\dev.ps1 build-windows`
on Windows), or trigger the full matrix from **Actions → CI → Run workflow** and
download the artifacts. See [`docs/PLATFORMS.md`](docs/PLATFORMS.md).

## Everything is baked in

There is no server, no account, no first-run download and no analytics. On
Android this is enforced rather than promised: the app does not hold the
INTERNET permission, so it *cannot* reach a network even if it tried. The only
permission it requests is `RECORD_AUDIO`, and the microphone is optional. Every
word, lesson, story, role-play, practice sentence and exam item is a Dart
constant compiled into the binary — the app works identically in aeroplane
mode on day one.

The only things it borrows from the operating system are speech synthesis and
speech recognition, because a German voice plus an acoustic model is hundreds
of megabytes the OS already ships. On Linux, where neither speech plugin has an
implementation, the app drives `spd-say` / `espeak-ng` instead and falls back
to typed input for speaking practice. `docs/PLATFORMS.md` is explicit about
what each platform can and cannot do.

Because there is no cloud sync, **Settings → Export / Import progress** moves a
complete profile between devices as plain text.

## The five tabs

| Tab | What it does |
| --- | --- |
| 🌱 **Home** | Daily goal, daily quests, streak and the six skill tracks per level |
| 🗺️ **Course** | 72 sequenced units, A1 to C2, each with a can-do outcome and a checkpoint |
| 🗣️ **Speak** | Guided role-plays, open questions and the pronunciation lab |
| 🏋️ **Practice** | Review queue, lesson review, story library, Gartenradio, games and labs, mistake bank, tests and exam prep |
| 👤 **Profile** | Achievements, skill matrix, vocabulary library and settings |

## What the speaking tutor is, and is not

The tutor runs entirely on the device. Speech is transcribed by the platform
recogniser (Android `SpeechRecognizer` / iOS Speech); the *evaluation* is a
deterministic rule engine in `lib/conversation_engine.dart`.

It **is** able to tell you whether you addressed the turn, whether you produced
enough language, whether you used the structures the turn practises, and — in
the pronunciation lab — which specific words were dropped, added or mangled.

It is **not** a language model, and it is **not** an acoustic pronunciation
scorer. It cannot judge a single vowel, improvise outside the script, or certify
you at a CEFR level. Every screen that shows a score says what the score means.
See `docs/SPEAKING.md`.

## Vocabulary-size policy

There is **no official CEFR rule saying that A1, A2, B1, B2, C1 or C2 equals one fixed number of words**. CEFR is a proficiency framework. Language-specific Reference Level Descriptions may map forms, words and grammar to CEFR levels, and Goethe publishes exam-oriented word lists for some lower levels, but a universal word-count table would be misleading.

DeutschGarden therefore separates:

1. **Bundled training-card inventory** — 10,000 curated/original learner-facing cards in this release.
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
.\bootstrap.ps1 windows
flutter analyze
flutter test
flutter build apk --release
```

### Linux / macOS

```bash
chmod +x bootstrap.sh
./bootstrap.sh all
flutter analyze
flutter test
flutter build apk --release
```

APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Build using GitHub Actions

The repository contains `.github/workflows/ci.yml`, which validates the bundled content, runs `flutter analyze` and `flutter test`, and builds the release APK on every push and pull request. Download the `DeutschGarden-APK` artifact from a completed run, or start the workflow by hand from **Actions → CI → Run workflow**.

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

- `docs/PUBLISHING.md` — what each app store costs and demands, and which are free
- `docs/SECURITY_WARNINGS.md` — why your OS warns on install, and which warnings are fixable
- `docs/ROADMAP.md` — what is worth building next, and what deliberately is not
- `docs/COURSE.md` — the 72-unit course spine: sequencing, gating and what is hand-written
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
