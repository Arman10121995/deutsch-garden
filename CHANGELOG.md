# Changelog

## 3.22.0

### Added

- **The vocabulary icon set is finished.** Every A1 and A2 noun in the deck now
  either carries a drawn picture or a written reason it cannot: 478 icons and
  216 declines. There is no longer a queue.

  The 353 new icons cover the rest of the house (Treppe, Aufzug, Heizung,
  Steckdose, Waschmaschine, Wasserhahn), the kitchen and the table, family and
  people, animals, the days of the week, the compass, weather, travel, the
  office, and the long tail of A2 compounds — Baumhaus, Kinderwagen,
  Hundehütte, Stofftier, Straßenschild, Bergsteiger, Toastbrot.

  The days of the week are one calendar with a different column filled in, so
  *Montag*, *Freitag*, *Samstag* and *Sonntag* are told apart by position
  rather than by four unrelated drawings. The compass points do the same with
  one needle.

- **Two hundred and sixteen words are deliberately left blank**, each with its
  reason recorded in `tool/vocab_icons_undrawable.tsv`. They fall into a few
  honest groups: words for spans of time (*Verspätung*, *Frist*, *Wartezeit*),
  words for relations and judgements (*Besitz*, *Schande*, *Gegenteil*),
  words whose picture would be a word already drawn (*Klient* is *Kunde*,
  *Sporthalle* is *Turnhalle*, *Kuscheltier* is *Stofftier*), and words the
  app declines to illustrate at all — weapons, killing, self-harm, insults,
  and nationalities that could only be drawn as caricature.

  An icon that means nothing in particular costs the learner attention and
  returns nothing, so a blank space is the better answer.

### Changed

- `tool/vocab_icons.py` reports the set as complete rather than as a backlog.
  It keeps its state on disk — drawn is a file, declined is a line in the TSV —
  so it stays correct without anyone maintaining a list.

## 3.21.0

### Added

- **Sixty-five more vocabulary icons**, taking the set to 125: time, work, the
  body, weather, nature, travel, money, devices and the rooms of a house.

- **Fifteen words are deliberately left without one**, and the reason is
  recorded per word rather than left as a gap someone later tries to fill.
  *Bedeutung*, *Grammatik*, *Zukunft* and *Erfolg* have no picture. *Wort*,
  *Satz*, *Nachricht* and *Gespräch* would all end up as the same speech
  bubble, and four words sharing one icon teaches that they mean the same
  thing. *Aussprache* would become a mouth, which teaches *Mund*.

  An icon that means nothing in particular costs the learner attention and
  returns nothing, so a blank space is the better answer.

### Fixed

- Two drawings were a single path — *Hand* and *Zahn* — and the content gate
  rejected them for being too plain to read as a picture. They gained real
  detail rather than the rule being loosened: finger creases and an enamel
  highlight.

## 3.20.0

### Added

- **Twenty more vocabulary icons** — places and transport, taking the set to 60.

### Changed

- Icons are now drawn directly rather than through a subagent workflow. The
  pilot spent about **11,000 subagent tokens per icon**; writing the SVG
  in-line costs a few hundred, and the mechanical gate is identical either way.
  What is lost is the second opinion on whether a drawing reads as its word,
  which the pilot showed is worth having — but not at twenty-five times the
  price for shapes this simple. Anything genuinely ambiguous still gets a
  second look.

- **Sourcing icons from an MIT set was investigated and rejected on the
  numbers.** Tabler Icons is MIT, needs no attribution and has over 5,000
  glyphs, so it looked like the obvious shortcut. Matched against the 694
  target nouns it covers **116, or 17%**, and the matches are semantically
  loose in ways that would teach the wrong thing: *Mann* and *Frau* both
  resolve to the same generic `user` glyph, *Arzt* to a stethoscope and
  *Lehrer* to a school building. Bootstrap Icons has the same shape of problem
  at smaller scale, and Noto Emoji — which has genuinely good coverage of
  everyday objects — is OFL-1.1, a font licence that makes extracting single
  glyphs as app assets messier than drawing them.

## 3.19.0

### Added

- **Vocabulary icons**, for visual learners. The concrete A1–A2 nouns now carry
  a small drawing beside the word in the vocabulary list.

  These are **original flat SVG drawn for this app**, not sourced images, and
  that was a licensing decision before it was an aesthetic one. The obvious
  route — Wikidata concept images from Wikimedia Commons — turns out to return
  overwhelmingly **CC-BY-SA** files, and share-alike assets inside an MIT
  application are a compliance burden with no upside. It also mismatched
  *Apfel* to the wrong concept entirely and offered a museum penny-farthing for
  *Fahrrad*. A drawing has nobody to credit, costs about **1.2 KB** instead of
  20, and stays sharp at any size.

  Only concrete nouns get one, and that limit is deliberate rather than a gap
  to be filled later: *Verantwortung* cannot be drawn by anyone, and an icon
  that means nothing in particular is worse than none, because the learner
  spends attention on it and gets nothing back. Words without a drawing keep
  showing their mastery plant, which is the thing that changes as you learn.

  Two gates stand in front of the assets. The content validator refuses any
  icon that is off the shared 64×64 grid, exceeds 6 KB, embeds a raster, or
  reaches a remote URL — the last two would break the offline guarantee and the
  clean-provenance guarantee together. It also refuses the failure that would
  otherwise be silent: icons present on disk while `assets/vocab/` is undeclared
  in `pubspec.yaml`, which ships precisely nothing. That check caught itself in
  practice the moment the first icons landed.

### Changed

- `LICENSE` now names a copyright holder. It read `Copyright (c) 2026` with no
  name, which leaves it ambiguous who is granting the permission.

## 3.18.0

### Changed

- **One learning path replaces five competing starting points.** The shell is
  now Learn / Explore / Profile. Learn calculates due vocabulary, the oldest
  due lesson, the exact next course activity or checkpoint, mistake repair and
  one optional reinforcement directly from existing progress. Explore groups
  the skill libraries, speaking studio, stories, Gartenradio, audio course,
  specialist labs and tests without presenting them as rival curricula.

- **Teaching units now distinguish a 7–9-activity core from attached extra
  practice.** The previous course correctly assigned all content but exposed
  12–16 equal-looking rows per unit. Ordered grammar and vocabulary now
  alternate with a deterministic mix containing both receptive and productive
  work; remaining stories, broadcasts, writing and role-plays stay in the same
  unit under a collapsed optional section and do not block its checkpoint.
  Checkpoints draw only from the core.

- Course vocabulary opens a ten-word learning session directly instead of
  opening the level catalogue and asking the learner to choose Learn again.
  The full course map remains available from the current-unit card.

### Fixed

- Placement into a higher level now makes that level the automatic next unit;
  A1 remains browseable but no longer steals Continue from a learner placed at
  B1 or above.
- Passing a course level test now unlocks the next level consistently in Learn,
  Explore and every skill library, rather than only inside the course map.

### Compatibility

- No content, activity, unit or checkpoint id changed. Existing completions,
  checkpoint scores and placement results carry over without a profile
  migration.

## 3.17.0

### Added

- **The pronunciation lab now records you and scores the sound.** The engine
  landed in 3.15; this connects it to a microphone. Your recording is compared
  with the same sentence rendered by the bundled voice, which means it works
  for any sentence in the app without shipping a single audio file.

  **Linux gains spoken feedback for the first time.** `speech_to_text` has no
  Linux implementation, so speaking practice there has been typed-only since
  the app shipped. Recording works, so Linux now gets a pronunciation score
  without a transcript — the opposite trade from every other platform. It
  needs `pulseaudio-utils` and `ffmpeg`, which most desktops already have.

  The two paths stay separate rather than running together: putting
  `speech_to_text` and a recorder on one microphone at the same time is
  something platforms disagree about, so where a recogniser exists the text
  comparison is used, and where it does not the acoustic one is.

  The score is presented with its limits next to it, because the number looks
  more precise than it is. It hears rhythm and vowel shape rather than
  individual sounds, and the model it compares against is a synthesiser.

### Changed

- `docs/KNOWN_LIMITATIONS.md` items 6 and 7 rewritten to describe what the app
  now actually does, including the part that has not changed: there is still no
  transcript on Linux, and the 0–100 scale is still anchored on synthetic
  speech with no human recordings behind it.

- The recorder captures at 22.05 kHz to match the bundled voice, so the common
  path resamples nothing. Resampling costs about a fifth of the scoring range
  in interpolation artefacts, which is measured in `test/pronunciation_audio_test.dart`
  rather than assumed.

## 3.16.0

### Added

- **Thirty-seven more authored role-plays**, taking the written scenarios from
  23 to 60 — the target item 12 actually asked for. The 37 story interviews
  are now genuinely on top rather than making up the number, so the library
  holds 97 speaking exercises of two distinct kinds.

  The new scenarios run from a bakery counter and asking directions at A1,
  through calling in sick and negotiating over a second-hand bicycle at A2, to
  an ethics board weighing the reuse of data and a grant panel where you must
  argue for a proposal you only partly believe in at C1.

  Every step had to satisfy the app's own scoring rule: a turn passes when the
  learner's reply contains enough of its keywords, so a model answer that does
  not contain its own keywords is a turn the app would mark wrong while
  displaying it as correct. To catch that before the build rather than after,
  `ConversationEngine.evaluate` was ported into the content assembler and
  differential-tested against all 117 shipped dialogue steps — zero
  disagreements with the Dart implementation.

### Changed

- The role-play count is asserted as **60 authored plus 37 interviews** in both
  the test suite and the content gate, rather than as one total. Checking only
  the total is what let the authored figure sit at 23 while the headline read
  60.

## 3.15.0

### Added

- **An acoustic comparator for pronunciation scoring**, and the audio
  preparation it needs. Not yet wired to a microphone — this is the engine,
  tested against synthetic signals and against real German from the bundled
  voice, landing separately from the recording plumbing so that the part with
  no plugin dependencies can be verified on its own.

  The upgrade plan called for bundling an offline recogniser. That turned out
  not to be available: sherpa-onnx ships **no German ASR model at all**, and
  the multilingual models that handle German at usable accuracy are 460–610 MB
  — against an APK already at 195 MB, a repository history near 400 MB, and
  GitHub's hard refusal of any file over 100 MB. At the sizes that would fit,
  German word error rates run 20–35%, so the recogniser would misread one word
  in four and mark correct pronunciation wrong. That is worse than the text
  comparison it was meant to replace.

  The other road needs no model. The app already synthesises the target
  sentence, so a reference recording exists for free, for any sentence, on
  every platform. `lib/acoustic.dart` compares the two with MFCC features and
  dynamic time warping — warping because a learner speaking slowly is not
  making a pronunciation error, and a frame-by-frame comparison would punish
  them for the tempo alone.

  Measured with the bundled voice: a sentence against itself scores 0.0
  distance, the same sentence re-synthesised at 0.8 speed scores 12.4, and a
  different German sentence 30.7. The 0–100 mapping is anchored on exactly
  those two figures and on **no human recordings**, which is stated in the code
  rather than glossed — where a pass mark belongs among real learners is a
  question for data.

  Two things were found by building it rather than assumed:

  - Downsampling the 22.05 kHz reference to the conventional 16 kHz costs
    about 10 DTW distance in linear-interpolation artefacts — a fifth of the
    scoring range, docked from every learner before they spoke. Analysis now
    runs at the voice's own rate so the common path resamples nothing.
  - The MFCC frame sizes were 25 ms and 10 ms *at 16 kHz*. Used unchanged on
    22.05 kHz audio they would have analysed 18 ms frames and quietly compared
    two different things, so `Mfcc.forRate` derives them from the rate.

  Cepstral mean normalisation is not optional here and there is a test that
  says why: without it, a fixed channel offset between a phone microphone and
  a synthesised wav dominates the comparison, and the score would mostly
  measure which microphone was used.

## 3.14.0

### Changed

- **Counts that mix authored and derived content now report both halves.**
  Three exercise formats are built on top of the 60 written stories, and that
  is a good way to get several kinds of practice out of one corpus — but it
  must not quietly inflate a headline number. A learner reading *120 writing
  tasks* expects 120 independent prompts; what exists is 46 of those plus 74
  guided retellings of chapters they have already read. Likewise *60
  role-plays* is 23 authored scenarios plus 37 story interviews.

  The validator, the validation report and the README now say so:

  | Reported as | Actually |
  | --- | --- |
  | 120 writing lessons | 46 authored + 74 guided story retellings |
  | 60 role-plays | 23 authored + 37 story interviews |
  | 60 mini-story drills | one derived from each story, by design |
  | 60 stories / 200 chapters | all written |
  | 120 Gartenradio episodes | all written |

  Splitting the number is the difference between describing a format and
  making a claim. The remaining authored role-plays and writing prompts stay
  on the upgrade plan rather than being marked done.

## 3.13.0

### Added

- **A complete extensive-reading and production tranche.** The graded library
  now contains 60 original stories / 200 chapters across A1–C2. Every reader
  also opens as a ten-line mini-story drill: listen without text, read, answer
  fifteen circling or sequence questions, then retell aloud from four prompts.
  The same content yields 74 guided writing retellings with model answers and
  37 scored story interviews, bringing the app to 120 writing tasks and 60
  role-plays without padding the counts with disconnected placeholder prose.

- Runtime tests pin the new targets, verify every generated question and id,
  run every role-play model answer through the real conversation evaluator,
  and require every writing model to satisfy its own offline rubric.

### Changed

- **All 120 Gartenradio episodes are now written scripts.** 3.12.0 reached 120
  by hand-writing 53 and generating the remaining 67 as vocabulary magazines,
  assembled from cards' example sentences. That was honest scaffolding rather
  than padding — every sentence carried a real level-matched headword in an
  already-validated context, and no card was reused within a level — but a
  written broadcast is the thing it stood in for. Those 67 slots now hold
  authored scripts: news bulletins, weather, announcements, voicemails,
  recipes, audio guides, diaries and short lectures, at the planned split of
  A1 30, A2 30, B1 25, B2 20, C1 10, C2 5.

  Each was checked for German correctness, level fit, and whether every
  question is actually answerable from its own transcript. Five had titles
  that collided with each other — the predictable result of writing them in
  parallel — and were retitled from their own content. A test now asserts that
  no generated magazine can reappear, since one only would if the written
  library had shrunk below its target.

### Fixed

- **Episode durations were over-stated by more than half.** `approximateSeconds`
  assumed 1.7 words per second. Measured against the bundled voice, dense C1
  prose runs at about 2.6 and simple A1 prose at about 3.3: a 64-word
  transcript that the app announced as 38 seconds actually renders 24.4
  seconds of audio. The constant is now the measured one, and the slower of
  the two figures, because over-stating a commitment is the kinder error.

- The content gate's transcript ceiling was 400 words, derived from that same
  wrong constant — 400 words is 154 seconds, not the three minutes it was
  meant to represent. It is now 460. The floor stays at 250 and is looser than
  the format claims: 77 of the 120 episodes sit between 250 and 310 words, so
  raising it to a true two minutes is a content job rather than a number to
  edit, and the test says so instead of pretending otherwise.

## 3.12.0

### Added

- **A complete offline Leben-in-Deutschland and citizenship-test centre.** It
  ships the official catalogue at Stand 07.05.2025: all 300 general questions,
  ten questions for every one of the sixteen Bundesländer, and 100 question
  images. Selecting a state produces the relevant 310-question practice bank
  with immediate feedback, persistent correct-question progress and a mistake
  queue that clears when the learner answers correctly later.

  The mock engine reproduces the official selection shape — 30 general plus
  three questions from the selected state — with four choices, backward and
  forward navigation, a 60-minute countdown, unanswered-question handling and
  a complete missed-answer review. Results keep the two legal outcomes
  separate: 15/33 for the LiD orientation-course result and 17/33 for proof of
  citizenship knowledge. Passing one is never presented as passing the other.

  Everything is bundled; the feature performs no network request. It is
  explicitly labelled as independent practice rather than an official BAMF
  certificate.

- **A reproducible civics-catalogue import.** The importer checks all 460
  answer keys against two independent extractions, requires the exact 300+160
  distribution, decodes every image and refuses an unreviewed catalogue-date
  change. The normal offline validator then checks ids, state/scope pairs,
  answer bounds, the complete image inventory and every image SHA-256. It
  caught a real line-order corruption in one upstream extraction of question
  171 before any data reached the app.

- **The full 120-episode Gartenradio library.** Fifty-three hand-written seed
  broadcasts are expanded to 250–400 German words, and 67 thematic long-form
  episodes fill the planned A1 30 / A2 30 / B1 25 / B2 20 / C1 10 / C2 5
  distribution. Level-matched vocabulary cards are not reused within a level.
  Every episode now carries three replay-based listen-and-select questions, two
  comprehension questions and one five-pair matching block: 720 checkpoint
  blocks in total.

### Changed

- The tests and exam-preparation hub now leads to both CEFR-oriented original
  practice and the official-question German civics track.
- Profile backups now include the selected Bundesland, civics mistake/mastery
  state and the last mock result without adding civics questions to the lesson
  SRS queue.
- Release metadata derives the runtime Gartenradio target rather than counting
  only source constructor literals, and includes the official-question and
  image inventories.

## 3.11.0

### Added

- **An audio course.** Two ideas older than the app, both scheduling rather
  than content — the sentence bank already held 9,211 German sentences with
  translations, and this authors none.

  **What you hear today** is Glossika's shape: ten new sentences, plus the
  batches from 1, 2, 4, 8, 16 and 32 days ago. A sentence met on day one comes
  back on days 2, 3, 5, 9, 17 and 33, then never again — six exposures over a
  month, front-loaded. The plan had sketched N-1 to N-4, which gives four
  exposures inside one week and none after it; that is the half of a spacing
  curve that does not do the work.

  **How each sentence is drilled** is Pimsleur's: the English appears, then a
  silence long enough to say the German out loud, then the German is spoken,
  then spoken again a little slower to imitate. Producing the sentence in the
  gap and being corrected a beat later is the exercise; hearing it and
  agreeing that it sounds right is not.

  The gap scales with the sentence — roughly 600 ms a word, floored at 2.5
  seconds and capped at 9. A fixed five seconds is absurd for *Ich bin müde*
  and far too short for a B2 sentence with the verb at the end. The stage is
  named on screen the whole way through, because an unlabelled silence is
  indistinguishable from a frozen app, and nobody speaks into a silence they
  think is a crash.

  Persisted state is **one integer per level**: how many days are done. Giving
  every sentence its own SM-2 record would have worked and would have put
  several thousand entries into the profile, flooded the practice hub's
  "lessons due" count with things that are not lessons, and made today's
  session depend on the exact minute of every past answer. The cost of the
  simpler choice is that this does not adapt to the individual sentence, which
  `docs/AUDIO_COURSE.md` says outright rather than glossing.

  Reached from **Practice → Audio course**.

- **A real player for Gartenradio episodes.** The bundled voice synthesises an
  episode to one audio file, which is a thing that can be scrubbed, so the
  player now has a position bar, ten-second skips in both directions, and
  pause that is actually pause rather than stop. Changing speed re-synthesises
  and resumes at the matching point instead of starting the episode again.

  These controls appear **only** where the bundled voice is running. An OS
  speech engine is handed a string and speaks it; there is no position to
  report and nowhere to seek to. Showing a progress bar there would repeat the
  exact mistake the speed chips used to make — visible controls wired to
  nothing — so on the web, and anywhere the voice fails to load, the transport
  degrades to play and stop and the transcript remains the fallback.

### Changed

- **Neural synthesis no longer blocks Flutter's UI isolate.** sherpa-onnx's
  `generate` call is synchronous native work. A sentence took roughly 650 ms
  and a connected radio script took seconds; calling it from an `async`
  method did not make it asynchronous, so the progress spinner, scrolling and
  every input froze until the WAV existed. A persistent worker isolate now
  owns the model and receives synthesis requests over ports, paying the model
  load cost once while leaving the interface responsive.

  Rendered files now have deterministic 63-bit cache names rather than Dart's
  runtime `String.hashCode`, are checked for a RIFF/WAVE header before reuse,
  and are written to a temporary file before an atomic rename. Concurrent
  requests for the same utterance share one future, worker crashes complete
  pending calls instead of hanging them, and every request has a three-minute
  upper bound. If a neural utterance still fails, backend selection is rerun so
  Linux reaches its local command-line fallback instead of being forced down a
  `flutter_tts` path that Linux does not implement.

  A real Windows integration test packages the native libraries and 61 MB
  model, proves a heartbeat continues during fresh synthesis, validates the
  resulting WAV and requires the repeat to return from cache in under 500 ms.

- The architecture, platform, story, vocabulary, SRS and limitations documents
  now describe the 10,000-card / 207-grammar / 21-story application rather than
  the old 881-card release.

### Fixed

- **Gartenradio episodes shared activity ids with grammar lessons.** Episodes
  shipped as `gr-a1-04`, `gr-c1-01` and so on — the grammar lessons' own
  namespace — and **21 of the 53 collided with a real lesson**. They share one
  progress map, so the two shared a completion flag, a best score and a review
  schedule: passing a grammar lesson silently marked a radio episode complete,
  and vice versa. It had been that way for three releases, and nothing looked
  wrong, because both screens worked and both wrote a score to the same key.

  Episodes moved to `rd-`. Progress recorded under an id no grammar lesson ever
  claimed moves across intact. For the 21 ambiguous ids there is no way to know
  which screen wrote the record, and the choice is to leave it with the grammar
  lesson rather than duplicate it — fabricating a radio completion would mark
  content done that may never have been opened, and that inflates level unlocks
  and achievements on data already known to be unreliable.

  The content validator now reserves a prefix per content type and fails in
  both directions: an id claimed twice, and a file minting ids outside its own
  namespace. The gate was checked by restoring the bug and watching it fail.

  This also silently corrupted the course spine added in 3.10: unit checkpoints
  looked up their questions by lesson id, and for those 21 ids the radio
  episode's comprehension questions won. A grammar checkpoint at every level
  was testing listening.

## 3.10.0

### Added

- **A course.** The app held several hundred lessons, ten thousand vocabulary
  cards, sixty podcast episodes and thirty stories, and no answer to the one
  question a learner actually asks: what should I do next. Opening it meant
  picking a level, picking a skill, picking a lesson, and inventing a study
  plan before any studying could start.

  There are now 72 units, twelve per level: four teaching units, then a review
  that folds them back together, repeating, with a level test closing each
  level. Each teaching unit states what it lets you do in the first person —
  "I can say what I did yesterday in the Perfekt", not "the Perfekt" — names
  four grammar lessons in the order they should be met, carries a dealt share
  of the level's listening, reading, writing, speaking, story, role-play and
  Gartenradio material, and ends in a ten-question checkpoint. Passing at 80%
  opens the next unit.

  Two escape hatches, because gating without them is hostile to anyone who
  does not start at zero. The placement test opens the level it places you in.
  And a checkpoint can be sat cold — the gate is the score, not the tick list.

  None of the content is new. What is new is the order, and the order is
  hand-written: the catalogue's ids were never a teaching sequence, and
  renumbering them was not available because lesson ids live in saved
  profiles. `docs/COURSE.md` says which parts are a judgement and which are
  dealt out by code.

  **Nothing new is stored.** Unit state is derived from the activity progress
  the app already keeps, so a learner who worked through half the A1 lessons
  before this release opens the course and finds half of it already ticked.
  There is no migration because there is nothing to migrate.

### Changed

- **Stories moved from the bottom bar into the practice hub**, next to
  Gartenradio, so the course could have a tab. They are both libraries to
  browse rather than paths to follow, and every story is also a step inside a
  course unit, so nothing became harder to reach.
- The Learn tab is now Home. Its contents are unchanged.

### Fixed

- `StoryLibraryScreen` had no `Scaffold` of its own — it was only ever used as
  a tab body. Pushing it as a route, which the practice hub now does, left its
  level chips without a Material ancestor and threw on every build. Caught by
  the test that asserts stories are still one tap from the bar.

## 3.9.0

### Added

- **A bundled German voice.** The app now ships a Piper VITS model (Thorsten,
  CC0) run on device through sherpa-onnx (Apache-2.0), instead of depending on
  whatever the operating system provides. Linux stops falling back to espeak,
  which was by a wide margin the worst audio in the app and had no better
  system option behind it, and every platform now hears the same voice, so a
  listening exercise no longer sounds different depending on which German
  voices a device happens to have installed.

  The OS synthesiser remains in place as a fallback: if the model fails to load
  for any reason the app uses it instead, so no platform regresses. The web
  build keeps using the browser synthesiser, because `dart:io` and real file
  paths do not exist there.

  This costs size, and the number is worth stating plainly: the APK goes from
  62 MB to 192 MB. About 72 MB is the sherpa-onnx native libraries across four
  Android ABIs and 61 MB is the voice itself. `espeak-ng-data` was trimmed from
  18 MB to 733 KB by keeping only what German phonemisation needs, and the
  trimmed set was verified to synthesise correctly before being adopted rather
  than assumed to work.

  Measured on a desktop CPU: three seconds to stage and load on first launch,
  done in the background after the first frame rather than on the first tap,
  and roughly 650 ms to synthesise a sentence.

### Changed

- `docs/PLATFORMS.md` explains what the bundled voice is, why it is worth its
  size, and what it still cannot do. `docs/KNOWN_LIMITATIONS.md` items 3 and 7
  are updated: synthesis on Linux is fixed, recognition on Linux is not.

## 3.8.0

### Added

- **Gartenradio**: 53 narrated listening episodes across A1 to C2, with a
  player, a full transcript, comprehension questions and playback at 0.6x,
  0.75x, 1.0x or 1.25x. Genres are restricted to what is genuinely read from a
  script in life -- news, weather, station and airport announcements,
  voicemail, recipes, audio guides and short lectures -- because synthesised
  German is a convincing narrator and an unconvincing actor. A1 and A2 show the
  English beside every line; from B1 it is hidden until asked for. The
  transcript is a first-class part of the screen, so on Linux, where synthesis
  still falls back to espeak, an episode degrades into a reading lesson rather
  than breaking.
- **Nine more graded readers**: stories go from 12 to 21 and chapters from 33
  to 56, levelled by the language they use rather than by subject.
- **Seven more role-plays**, taking the total from 16 to 23, including a salary
  conversation and raising an objection in a meeting -- turns that practise
  pragmatics rather than vocabulary.
- `docs/UPGRADE_PLAN.md`, written after researching what Duolingo, Babbel,
  Busuu, Pimsleur, Glossika, Clozemaster, LingQ and the German-specific
  resources actually ship, and what of it an offline MIT app can reach.

### Fixed

- **The speed controls did nothing.** The dictation screen and the shadowing
  lab both kept a `_speed` field that the chips set and highlighted, but
  nothing ever read it: `speakGerman` took no rate, so audio always played at
  the default pace. The 0.75x and 1.25x options advertised in 3.3.0 and 3.3.3
  have never worked. `speakGerman` now takes a rate multiplier, applied through
  flutter_tts on the plugin path and through `spd-say -r` and `espeak-ng -s` on
  Linux, and both screens pass their setting.
- The completionist achievement targeted 33 story chapters, a number that was
  correct only while 33 happened to be all of them. It now derives from the
  story library. Its `ach-story-33` id is deliberately unchanged, because ids
  are written into saved profiles and renaming one would re-fire its
  notification for every existing learner.
- The content validator was reading one file per content type, so a new batch
  of radio scripts, a whole collection of stories and seven role-plays were all
  invisible to it. It now globs each family, which immediately surfaced a real
  duplicate scenario id.

## 3.7.0

Phase 0 of `docs/UPGRADE_PLAN.md` ("unlock what already exists") is complete.
Nothing in this release was newly authored; it draws entirely on the 10,000
example sentences 3.6.0 already shipped.

### Added

- **The sentence bank draws on the whole vocabulary deck, not just the core
  203 cards.** `lib/sentence_bank.dart` excluded the expansion deck because its
  examples used to be the metalinguistic placeholder "Das Lernwort heute ist
  X"; 3.6.0 replaced every one of those, so the exclusion had nothing left to
  guard against. Practice sentences go from 63 curated (plus ~180 derived) to
  **over 9,000**, feeding the sentence builder, dictation and shadowing lab
  with fifty times the material and not one new line of prose.
- **A cloze (gap-fill) bank derived from the same corpus.** `lib/cloze_bank.dart`
  blanks the headword out of each card's own example sentence and offers three
  wrong answers of the same part of speech and level, so a noun gap is never
  answered by eliminating "und" and "ist". **Over 7,000 items** across every
  level, wired into a new Cloze Drill game in the Practice tab.
- **Twelve grammar challenge collections**, `lib/grammar_challenge.dart`: the
  same corpus, scanned for one grammatical confusion at a time instead of one
  vocabulary word — nominative articles, accusative and dative after
  prepositions, two-way prepositions, adjective endings, Perfekt with haben
  vs. sein, separable verbs, reflexives, Konjunktiv II, the passive, relative
  pronouns and the Genitiv. Nine collections reach the 100-item target;
  accusative-after-prepositions (91) and passive (93) fall just short because
  their triggers are less frequent in the corpus, and Genitiv (32) is
  genuinely rare — a formal-register construction in a general-purpose
  sentence bank. None of the three were padded to round numbers: per the
  plan's own rule, "content only counts once it is usable," and a distractor
  invented to hit a target is not usable. **1,116 items in total**, reachable
  from a new "Grammar challenges" tile in the Practice tab, one collection at
  a time.
- `test/cloze_bank_test.dart` and `test/grammar_challenge_test.dart` check
  every gap actually removes the answer and nothing else, that distractors
  never repeat the answer or each other, and that the option shuffle is
  deterministic. The suite goes from 111 tests to 117.

### Changed

- **62% of the 3.6.0 vocabulary expansion had landed at C1 or C2**, which
  stranded ordinary words behind five levels of progression an A2 learner
  could not reach — "der Hausschlüssel" among them. `tool/relevel_a1_b1.py`
  moves the clear everyday-vocabulary cases down to A2 or B1; the deliberately
  hard cases (der Hochstapler, das Mauerblümchen) are left where they were
  because they genuinely are advanced. The level distribution is now A1 650,
  A2 860, B1 1452, B2 1667, C1 2424, C2 2947 — same 10,000 cards, better
  sorted.

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
