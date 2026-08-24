# Changelog

## 3.6.0

### Added

- **Vocabulary grows from 912 to 10,000 cards** across A1-C2, in
  `lib/vocabulary_generated.dart` alongside the existing decks. Distribution is
  650 A1, 750 A2, 1200 B1, 1600 B2, 2600 C1 and 3200 C2.
- **Grammar grows from 96 to 207 lessons.**
- `tool/import_vocabulary.py`, which dedupes new cards against the whole deck,
  assigns ids, escapes for Dart and rejects structurally broken entries before
  they can reach the build.

### Fixed

- **Every placeholder example is gone.** 678 cards in the expansion deck
  carried the metalinguistic filler "Das Lernwort heute ist X" instead of the
  word in use; a card that never shows its word in a sentence teaches the word
  in isolation and nothing about how it behaves. All of them now have real
  contextual sentences with English translations, and the validator refuses to
  accept the placeholder pattern again.
- The German example check no longer reports correct cards as wrong. It now
  understands the three things that made it fire falsely: reflexive verbs
  listed as "sich erinnern an" but appearing as "erinnere mich an", separable
  verbs that split and take a ge- infix in the participle (nachweisen ->
  nachgewiesen, darstellen -> dargestellt), and strong verbs that change their
  stem vowel (entscheiden -> entschieden, ergeben -> ergibt). Lemmas shorter
  than four characters are skipped rather than guessed at, and a phrase made
  entirely of function words is matched literally.
- **The README count check had silently stopped working.** Its pattern required
  bare digits, so writing 10,000 rather than 10000 made it match nothing -- and
  a check that matches nothing reports success. It now accepts thousands
  separators, and a deliberately wrong number was used to confirm the gate
  fires again.

## 3.5.1

### Fixed

- **The release APK was signed with the Android debug key.** Flutter's
  generated Gradle config signs release builds with the debug keystore unless a
  release config exists, and nobody had added one -- the scaffolded `TODO` was
  still in place. Every APK this project ever shipped carried
  `CN=Android Debug`, which is exactly what makes Play Protect and third-party
  scanners tell a user the app is unsafe, and which can never be published to
  Play. Release builds are now signed with a real RSA-4096 key. The keystore
  lives outside the repository and is injected into CI from repository secrets;
  CI fails the build if the resulting APK is debug-signed.
- **The app requested the INTERNET permission.** It was added "because the
  platform recogniser may need it", which is not true: Android's
  `SpeechRecognizer` runs inside the system speech service, a separate process
  holding its own permissions, and this app only binds to it over IPC. The
  permission made the app's central claim -- no server, no analytics, works in
  aeroplane mode -- unenforceable and unverifiable, and a network permission on
  an offline education app is precisely what makes a scanner suspicious. It is
  gone: the only permission the app now requests is `RECORD_AUDIO`, and the
  promise is enforced by the operating system rather than asserted in a README.

### Added

- `android.hardware.microphone` declared as **not required**, so a device
  without a microphone can still install the app. Speaking practice has always
  accepted typed input as an equal path.
- `docs/SECURITY_WARNINGS.md`: what each platform warns about, which warnings
  this release removes, and which cannot be removed without a paid signing
  certificate.

## 3.5.0

### Added

- **Lesson review.** Grammar, listening, reading, writing and speaking lessons
  now enter the same SM-2 rotation vocabulary has always used. Until now all
  222 lessons were tracked with nothing but a completion flag: a lesson was
  finished once and never came back, which is exactly how case endings and
  verb governance quietly rot. `ActivityProgress` carries `dueAt`, `ease`,
  `intervalDays`, `reps`, `lapses` and `learningStep`; the score the learner
  earns is mapped to a grade (below the pass mark is a lapse, 95%+ is Easy),
  and a new **Practice -> Lesson review** screen lists what is due across every
  track. Existing profiles are migrated: lessons already passed are spread
  deterministically over the following fortnight rather than all falling due at
  once.
- `lib/lesson_registry.dart`, one flattened index of all 222 lessons, so an
  activity id can be resolved back to a title, level and skill.
- `lib/german_text.dart`: German-aware answer matching. Typed recall accepted
  only an exact string, so `Maedchen` and `Strasse` were marked wrong on any
  keyboard without umlauts. The ASCII convention (ae/oe/ue/ss) is now credited
  and the correct spelling shown alongside, in both directions.
- Launcher icons for all five platforms, generated from `assets/icon/`. Every
  build previously shipped Flutter's default icon, which is a store rejection
  on its own.
- `test/state_recovery_test.dart`, `test/lesson_review_test.dart` and
  `test/german_text_test.dart`. The suite goes from 64 tests to 102.

### Fixed

- **A profile that failed to parse was silently replaced with a blank one.**
  `load()` caught the decode error and then called `_save()` unconditionally,
  overwriting a learner's entire history on the very next frame, with no
  warning and no backup. Unreadable data is now quarantined rather than
  discarded, the last blob known to parse is kept as a snapshot and restored
  automatically, and the app says what happened instead of looking like a
  fresh install.
- **`applyJson` could part-apply and persist the result.** Every scalar was
  read with an `as` cast, so one wrong-typed value threw half-way through
  rehydrating and left the profile partly overwritten. All fields now coerce
  independently through shared helpers in `lib/models.dart`.
- Scheduler state loaded from disk is bounded: an out-of-range `ease` or
  `intervalDays` from a corrupt or hand-edited profile can no longer produce
  absurd intervals for the life of a card.
- **The test suite did not compile.** `test/assessment_test.dart` was missing
  its `app_state.dart` import and its SharedPreferences setup, and
  `test/dictation_test.dart` imported `curriculum.dart` for `sentencesFor`,
  which lives in `sentence_bank.dart`. `flutter analyze` reported two errors
  and `flutter test` could not run, so the CI gate was red.
- 183 German quotations were closed with an ASCII `"` instead of `“`, and one
  was nested without switching to single quotes. `tool/validate_content.py`
  now fails the build on both.
- The vocabulary bank built every card in the level eagerly on each keystroke
  of the search field. Up to 212 widgets per frame; now lazy.

### Changed

- `tool/validate_content.py` is the single source of truth for release
  metadata. It derives every count from the Dart sources, regenerates
  `CONTENT_MANIFEST.json` and `VALIDATION_REPORT.txt` with `--write`, and fails
  the build when `pubspec.yaml`, `CHANGELOG.md` or `README.md` disagree with
  the sources or with each other. They already had: pubspec said 3.2.1, the
  changelog said 3.4.1, the README said 881 cards and the manifest said 931.
- Every icon-only button carries a tooltip, and the mastery emoji carries a
  spoken label, so a screen reader announces progress rather than "seedling".

## 3.4.1

### Added

- **Vocabulary Deck Expansion**: Expanded bundled vocabulary count to **931 Lexical Units** across A1–C2 (*ausgezeichnet*, *pünktlich*, *selbstverständlich*, *nachvollziehbar*, *maßgeblich*, *wegweisend*, *schwerwiegend*, *unumgänglich*, etc.).
- **Curated Practice Sentences Expansion**: Added 10 new authentic practice sentences to `curatedSentences` (total **61 sentences**) for Cloze drills, Shadowing, and Dictation.

## 3.4.0

### Added

- **Vocabulary Deck Expansion**: Expanded bundled vocabulary count to **901 Lexical Units** across A1–C2 (*Nachhaltigkeit*, *Eigenverantwortung*, *Spitzenforschung*, *Zusammenhang*, *Verflechtung*, *Widersprüchlichkeit*, etc.).
- **Curated Practice Sentences Expansion**: Added 12 new authentic practice sentences to `curatedSentences` (total **51 sentences**) for Cloze drills, Shadowing, and Dictation.

## 3.3.3

### Added

- **Dictation Variable TTS Speed Controls**: Added `0.75x Slow`, `1.0x Normal`, and `1.25x Fast` speech speed selectors to `DictationScreen`.
- **Dictation Unit Test Suite**: Added [`test/dictation_test.dart`](file:///c:/deutsch-garden/test/dictation_test.dart) verifying dictation practice sentences and fuzzy pronunciation alignment scoring.

## 3.3.2

### Added

- **Vocabulary Bank Real-Time Search & Article Filtering**: Search cards by German or English and filter by noun article (`All`, `der`, `die`, `das`) in `VocabularyLevelScreen`.
- **Story Reader Unit Test Suite**: Added [`test/story_reader_test.dart`](file:///c:/deutsch-garden/test/story_reader_test.dart) verifying story glossaries, chapter word counts, and comprehension question integrity.

## 3.3.1

### Added

- **Searchable Global Grammar Handbook** (`GrammarHandbookScreen`): Search all 96 grammar lessons across A1–C2 by keyword (e.g. *passive*, *weil*, *subjunctive*, *modal*) with CEFR level filters and direct access from the Grammar List header.
- **Grammar Handbook Unit Test Suite**: Added [`test/grammar_handbook_test.dart`](file:///c:/deutsch-garden/test/grammar_handbook_test.dart) verifying complete lesson availability, explanation strings, and choice question bounds.

## 3.3.0

### Added

- **Four New Interactive Learning Labs** in the Practice Hub (`Üben`):
  - 🎯 **Der/Die/Das Article & Gender Trainer** (`ArticleTrainerScreen`): Rapid noun gender practice with color-coded article badges and grammatical suffix rules (*-ung, -heit, -chen, -lein, -ismus*).
  - ⚙️ **Verb Conjugation & Tense Lab** (`VerbLabScreen`): Interactive conjugation drills across tenses (*Präsens*, *Präteritum*, *Perfekt*, *Konjunktiv II*, *Futur I*) for regular, strong, and modal German verbs.
  - 🧩 **Cloze Fill-in-the-Blank Drill** (`ClozeDrillScreen`): Sentence completion practice in authentic context.
  - 🎧 **TTS Shadowing & Speed Control Lab** (`ShadowLabScreen`): Speech shadowing trainer with 0.75x / 1.0x / 1.25x playback speeds and real-time pronunciation scoring.
- **New Unit Test Suite**: [`test/verb_and_article_test.dart`](file:///c:/deutsch-garden/test/verb_and_article_test.dart) verifying noun gender specs, verb conjugation items, and practice sentence bank tokens.

## 3.2.2

### Added

- **Mistake Bank Search & Source Filtering**: Real-time prompt/answer search bar and source category chips (`Vocabulary`, `Grammar`, `Listening`, `Reading`, `Dictation`, `Story`) in `MistakeBankScreen`.
- **Inline Mnemonic Editor**: Flashcards during study sessions and reviews allow adding/editing personal memory hooks directly on the card.
- **ChoiceQuestion Structural Integrity Validation**: Extended `tool/validate_content.py` to check `ChoiceQuestion` option bounds and `correctIndex` safety across all curriculum, story, and assessment files.
- **Unit Test Expansion**: Added `test/games_test.dart` and expanded `test/assessment_test.dart` for placement score level unlocks and mistake queue operations.

## 3.2.1

### Added

- `Makefile` and `dev.ps1` giving one-command local workflows on every OS:
  `setup`, `verify`, `run`, `devices`, `build-*`, `report`, `clean`
- `docs/LOCAL_DEVELOPMENT.md` — toolchain install per OS, the edit/run/test
  loop, where content lives, and what to run before committing

### Changed

- CI no longer builds artifacts on every push. Pushes and pull requests run the
  correctness gate only (~1 runner-minute); the five-platform matrix runs on
  **workflow_dispatch** or a `v*` tag.

  Measured from a real run, a full matrix costs ~103 billable minutes once the
  repository is private — macOS bills at 10x wall-clock and Windows at 2x — so
  building on every push across five branches would have consumed about a
  quarter of the 2,000-minute monthly allowance per round. On-demand builds
  cost about five minutes a month instead. Public repositories are unmetered,
  where this changes nothing but noise.

## 3.2.0

### Added

- Windows, macOS, iOS and Linux builds alongside Android, all from the same
  `lib/`; CI produces a downloadable artifact for each on every push
- `lib/platform_support.dart`, a single place that answers what the current
  platform can actually do, so the UI never offers a control that cannot work
- Linux speech synthesis through the synthesiser the distribution already has
  (`spd-say`, then `espeak-ng`, then `espeak`), selected by conditional import
  so the web build still compiles without `dart:io`
- responsive shell: at 900 px and wider the bottom bar becomes a navigation
  rail and content is capped at a readable line length
- full keyboard control of the review queue on desktop — space reveals, 1-4
  grade, space repeats "Good"
- **Settings → Export / Import progress**: the whole profile as portable text,
  for moving between platforms without an account or a server. The importer
  validates before applying and shows what the backup contains
- a "This build" card in Settings stating the platform and exactly which speech
  capabilities it has
- `tool/patch_platforms.py`, which patches every generated native wrapper
- `docs/PLATFORMS.md`

### Fixed

- **iOS and macOS builds would have been terminated by the OS on first
  microphone use**: `flutter create` writes no `NSMicrophoneUsageDescription`
  or `NSSpeechRecognitionUsageDescription`, and both are mandatory. The patcher
  now adds them
- **the macOS sandbox silently denied the microphone**: the
  `com.apple.security.device.audio-input` entitlement was missing from both
  entitlement files
- Linux previously had no working audio at all: `flutter_tts` has no Linux
  implementation, so every call threw `MissingPluginException` behind a button
  that looked functional
- `speech_to_text` was called on platforms it does not implement; the service
  now decides once, up front, and explains itself instead of failing per press

### Changed

- `bootstrap_android.sh` / `.ps1` replaced by `bootstrap.sh` / `bootstrap.ps1`,
  which take a platform argument
- CI split into one shared verify job plus a five-way build matrix, so a
  content typo cannot burn build minutes on five runners
- state loading refactored so `load()` and the backup importer share one
  decoder rather than maintaining two that can drift

## 3.1.0

### Added

- AI speaking tutor: 16 guided role-plays across A1–C2, each with a goal, per-turn
  tasks, hints, tappable starter phrases, coaching notes and a model answer
- microphone input through on-device speech recognition (`speech_to_text`), with
  typed input as an equal fallback wherever no recogniser is available
- 12 open-ended "free talk" prompts scored on length and level-appropriate
  connector use
- pronunciation lab: hear a model sentence, repeat it, receive a word-by-word
  score from a Needleman–Wunsch alignment of the recognised text
- story mode: 12 graded stories / 33 chapters with parallel translation,
  adjustable type size, chapter read-aloud, tap-a-word lookup that files words
  into the review deck, per-chapter glossaries and comprehension checks
- practice games: match pairs, sentence builder from a word bank, dictation with
  a word-level diff, and a 60-second speed round
- mistake bank collecting wrong answers from vocabulary, grammar, listening,
  reading, stories and dictation
- difficult-words ("leech") screen and learner-written mnemonics on any card
- 27 achievements and three deterministic, daily-rotating quests
- immersion mode that hides English by default across the new screens
- curated practice-sentence bank (39 sentences) targeting one structure each

### Changed

- replaced the fixed 0/1/2/4/8/16-day interval ladder with SM-2: per-card ease,
  learning steps, lapse tracking, and Again/Hard/Good/Easy buttons that show the
  interval each one will produce
- restructured the shell into Learn / Speak / Stories / Practice / Profile; the
  tests and exam section moved into Practice, statistics and settings into Profile
- content validator now checks the new content and strips strings and comments
  before its delimiter check, so regular expressions no longer trip it
- content manifest is now counted from source rather than hard-coded

### Fixed

- Android manifest patcher replaced Flutter's own `<queries>` block, silently
  dropping the engine's `ACTION_PROCESS_TEXT` entry; it now merges into it and
  adds `RECORD_AUDIO`, `INTERNET` and the speech-recognition query
- CI was nested one directory below the repository root, where GitHub never
  reads workflow files, and it ran `flutter test` against the counter-app widget
  test that `flutter create` scaffolds — which cannot compile against this
  project. The workflow now sits at `.github/workflows/ci.yml`, removes that
  file, and validates content before building
- three dialogue steps demanded keywords or a length their own model answers
  could not satisfy; a step's minimum length is now derived from its model
  answer, so the app can never reject the sentence it presents as correct
- progress written by 3.0 is migrated into the new scheduler rather than reset

## 3.0.0

- added adaptive A1–C2 placement assessment
- added persistent placement result and placement-based level unlocking
- added dedicated Tests bottom-navigation destination
- added current exam-profile reference metadata and 12 original mini mocks
- added writing and speaking tasks to exam prep
- expanded vocabulary from 203 to 881 bundled cards
- expanded grammar from 24 to 96 lessons
- expanded listening from 18 to 36 lessons
- expanded reading from 18 to 36 lessons
- expanded writing from 18 to 36 lessons
- added 18 speaking lessons and sixth skill progress track
- changed vocabulary level progress to measure the full bundled deck
- fixed article quizzes for article-less lexical units
- added assessment/curriculum/build/privacy/QA documentation and instrument blueprints
