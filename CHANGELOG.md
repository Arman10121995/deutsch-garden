# Changelog

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
- CI lived in `deutsch_garden/.github/`, where GitHub never reads it, and ran
  `flutter test` against the counter-app widget test that `flutter create`
  scaffolds — which cannot compile against this project. CI now sits at the
  repository root, removes that file, and validates content before building
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
