# DeutschGarden 4.2

DeutschGarden is a fully offline Flutter application for structured German study from **A1 to C2**, running on **Android, Windows, macOS, iOS, Linux and the web from one codebase**. It combines adaptive spaced repetition, grammar, listening, reading, writing, a spoken conversation tutor, a graded-reader story mode, practice games, an adaptive placement assessment, original CEFR/Goethe-style exam-preparation mini mocks, and official-question preparation for Leben in Deutschland and the Einbürgerungstest.

## What is included

- A1 → A2 → B1 → B2 → C1 → C2 progression
- **A visual and a word-class label on every vocabulary card.** The 480 concrete A1–A2 nouns use original semantic SVG drawings; all other cards use a consistent structural vector showing category and part of speech instead of a misleading invented picture. Nouns also show der/die/das colour and gender. See `docs/VOCAB_ICONS.md`
- **One automatic Learn path** that combines due reviews, the exact next course activity and mistake repair into an ordered guided session instead of asking the learner to choose among competing hubs
- **A 72-unit course**: four teaching units then a review, twelve per level, each with a can-do outcome, a balanced 7–9-activity core, an automatically integrated matching/sentence-building/dictation retrieval step, optional attached practice and an 80% checkpoint — see `docs/COURSE.md`
- Six learning tracks per level: Vocabulary, Grammar, Listening, Reading, Writing, Speaking
- **10,000 bundled vocabulary cards** across A1–C2
- **207 grammar lessons**
- **26 level-aware grammar reference tables** covering conjugation, articles, cases, adjective endings, word order, prepositions, passive, Konjunktiv, connectors and register; lesson and table examples can be spoken aloud
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
- A durable review-event history with one-tap misgrade undo, 30-day true-retention statistics and interval-bucket diagnostics
- Safe offline backup merge reconciles progress item by item and de-duplicates review history; deliberate full replacement remains available
- **Lessons come back too**: grammar, listening, reading, writing and speaking lessons are scheduled by the same algorithm as vocabulary, so a lesson passed in week one resurfaces before it is forgotten rather than never again
- A mistake bank collecting every wrong answer across all skills
- **A bundled German voice** (Piper VITS, CC0) synthesised off the UI isolate on native platforms, so Android, desktop and Apple builds sound the same and Linux no longer falls back to espeak
- German TTS, optional platform speech recognition, immersion mode, article drills, typed recall, XP, streaks, favorites, search, daily goals, theme settings and persistent offline progress
- An opt-in, private daily study reminder at the learner's chosen local time on Android, iOS and macOS
- English and German interface foundations plus optional Turkish meanings for 478 concrete nouns, with English fallback for the rest of the deck
- A word-class guide and a der/die/das guide that groups nouns, teaches productive ending clues and names common exceptions rather than presenting endings as absolute rules
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
| Android | `DeutschGarden.apk`, plus `DeutschGarden.aab` for Google Play |
| Windows | `DeutschGarden-windows-x64.zip` containing `DeutschGarden.exe`, or `DeutschGarden-windows-x64.msix` |
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
INTERNET permission, so it *cannot* reach a network even if it tried.

Since 4.1 there is exactly one exception, and it is on desktop only. Settings
offers a German speech model that writes down what you said in the speaking
lab. It downloads once, when asked for by name, and then works offline
forever. It is not bundled (105 MB against Play's 200 MB cap) and it is not
offered on Android or iOS, because keeping the INTERNET permission off the
phone builds is worth more than an optional extra on a platform that already
has a system recogniser. `tool/check_network_use.py` fails the build if a
second outbound call ever appears, or if that permission comes back. The
microphone permission is optional, and Android 13+ asks for notification
permission only if the learner explicitly enables a daily reminder. Every
word, lesson, story, role-play, practice sentence, civics question and exam item
is a bundled Dart or JSON asset compiled into the binary — the app works
identically in aeroplane mode on day one.

German speech synthesis uses the bundled CC0 Thorsten neural voice on native
platforms, with the operating-system synthesiser as a fallback. Speech
recognition uses the platform recogniser where available; on desktop the
optional downloaded model is preferred over it, because the platform one may
route audio to a vendor's servers and this app's promise is that it does not.
Linux, which has no platform recogniser at all, gets a transcript for the
first time with that model installed and typed input without it; web is typed
input only. `docs/PLATFORMS.md` is explicit about what each
platform can and cannot do.

Because there is no cloud sync, **Settings → Export / Import progress** moves a
complete profile between devices as plain text. Import defaults to a safe,
item-by-item merge and de-duplicates review events; full replacement is still
available as an explicit destructive choice.

## The three destinations

| Tab | What it does |
| --- | --- |
| 🗺️ **Learn** | Runs one guided session: due review, the next core course activity and mistake repair, recalculated after every completed step |
| 🧭 **Explore** | Vocabulary and skill libraries, speaking, stories, Gartenradio, audio course, specialist drills, CEFR exams and LiD/citizenship-test preparation |
| 👤 **Profile** | Personal progress, achievements and settings |

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

The repository contains `.github/workflows/ci.yml`. Every push and pull request validates the bundled content, runs `flutter analyze` and executes the full test suite. A manual workflow run or a `v*` release tag builds all six platform artifacts; ordinary pushes do not spend time producing 800 MB of binaries nobody requested.

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
  vocabulary_library_screen.dart  searchable 10,000-word reference library
  vocabulary_metadata.dart word-class and noun-ending metadata
  vocab_icon.dart           semantic SVGs and universal structural visuals
  gender_guide.dart         der/die/das groups, ending rules and exceptions
  grammar_tables.dart       level-aware conjugation and grammar references
  sentence_audio.dart       reusable example-sentence playback
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
- Native TTS uses the bundled CC0 German voice; web playback depends on the
  browser's installed German voice.

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
- `docs/VOCAB_ICONS.md` — semantic drawings, universal visual fallback and asset QA
- `docs/ADR-001-UNIVERSAL-VOCAB-VISUALS-AND-INTEGRATED-PRACTICE.md` — the visual and course-integration architecture decision
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
