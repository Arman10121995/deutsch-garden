# DeutschGarden 3.19

DeutschGarden is a fully offline Flutter application for structured German study from **A1 to C2**, running on **Android, Windows, macOS, iOS, Linux and the web from one codebase**. It combines adaptive spaced repetition, grammar, listening, reading, writing, a spoken conversation tutor, a graded-reader story mode, practice games, an adaptive placement assessment, original CEFR/Goethe-style exam-preparation mini mocks, and official-question preparation for Leben in Deutschland and the Einbürgerungstest.

## What is included

- A1 → A2 → B1 → B2 → C1 → C2 progression
- **Drawn vocabulary icons** for the concrete A1–A2 nouns — original flat SVG, about 1.2 KB each, no third-party image licence anywhere in the bundle
- **One automatic Learn path** that combines due reviews, the exact next course activity, mistake repair and attached enrichment instead of asking the learner to choose among competing hubs
- **A 72-unit course**: four teaching units then a review, twelve per level, each with a can-do outcome, a balanced 7–9-activity core, optional attached practice and an 80% checkpoint — see `docs/COURSE.md`
- Six learning tracks per level: Vocabulary, Grammar, Listening, Reading, Writing, Speaking
- **10,000 bundled vocabulary cards** across A1–C2
- **207 grammar lessons**
- **36 listening lessons** (6 per level)
- **36 reading lessons** (6 per level)
- **120 writing lessons** — 46 standalone prompts plus 74 guided reader retellings with model answers
- **18 speaking lessons** (3 per level)
- **36 adaptive placement items** (6 per CEFR band)
- **12 original exam-prep mini mocks** (2 per level)
- **60 authored role-plays** with the AI tutor, plus **37 story interviews** that retell a reader you have just finished, and **12 open speaking prompts**
- **60 graded stories / 200 chapters** with tap-a-word lookup and comprehension checks
- **60 mini-story drills**, one derived from each story — listen, read, answer 15 circling/sequence questions, then retell aloud
- **120 narrated Gartenradio episodes**, every one a written script — 250–460-word news, weather, announcements, voicemail, recipes, audio guides and short lectures, with transcripts and six checkpoint blocks each
- **460 official civics questions** for Leben in Deutschland and the Einbürgerungstest: all 300 general questions plus 10 for each of the 16 Bundesländer, 100 bundled question images, immediate-feedback practice, persistent mistake review and timed 30+3 simulations with the distinct 15/33 and 17/33 thresholds
- **An audio course**: ten new sentences a day drilled Pimsleur-style — read the English, say the German into a silence, then hear it — with each day's batch replayed 1, 2, 4, 8, 16 and 32 days later. See `docs/AUDIO_COURSE.md`
- **9,211 practice sentences** — including **61 curated practice sentences** plus the validated deck-derived corpus — feeding sentence building, dictation, shadowing, cloze and the audio course
- **27 achievements** and three rotating daily quests
- Adaptive SM-2 review with per-card ease, lapse tracking, learner-written mnemonics and a difficult-words queue
- **Lessons come back too**: grammar, listening, reading, writing and speaking lessons are scheduled by the same algorithm as vocabulary, so a lesson passed in week one resurfaces before it is forgotten rather than never again
- A mistake bank collecting every wrong answer across all skills
- **A bundled German voice** (Piper VITS, CC0) synthesised off the UI isolate on native platforms, so Android, desktop and Apple builds sound the same and Linux no longer falls back to espeak
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
[latest release](https://github.com/Arman10121995/deutsch-garden/releases/latest).
The [`release/`](release/) folder documents why these 78–200 MB binaries are
attached to releases instead of being committed into every clone.

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
word, lesson, story, role-play, practice sentence, civics question and exam item
is a bundled Dart or JSON asset compiled into the binary — the app works
identically in aeroplane mode on day one.

German speech synthesis uses the bundled CC0 Thorsten neural voice on native
platforms, with the operating-system synthesiser as a fallback. Speech
recognition still uses the platform recogniser where available; Linux and web
fall back to typed input. `docs/PLATFORMS.md` is explicit about what each
platform can and cannot do.

Because there is no cloud sync, **Settings → Export / Import progress** moves a
complete profile between devices as plain text.

## The five tabs

| Tab | What it does |
| --- | --- |
| 🗺️ **Learn** | Automatically orders due review, the next core course activity, mistake repair and one optional reinforcement |
| 🧭 **Explore** | Skill libraries, speaking, stories, Gartenradio, audio course, specialist drills, CEFR exams and LiD/citizenship-test preparation |
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
  civics_test.dart          official LiD/citizenship catalogue + mock engine
  civics_test_screens.dart  Bundesland practice, timed mocks and review UI
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
  screens.dart              three-destination shell/profile/stats/settings
  learning_path*.dart       calculated Learn queue and its UI
  explore_screen.dart       grouped optional libraries, labs and tests
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
- `docs/LEARNING_PATH.md` — why Learn/Explore/Profile replaced five competing hubs and how the automatic session is calculated
- `docs/AUDIO_COURSE.md` — the audio course: the spacing curve, the anticipation gap, and why it stores one integer
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
