# Content upgrade plan

Written after researching what Duolingo, Babbel, Busuu, Memrise, Pimsleur,
Glossika, Clozemaster, LingQ, Seedlang and the German-specific resources (DW,
Goethe-Institut, Easy German, Coffee Break) actually ship, and how durable
courses — Assimil, Teach Yourself, Colloquial, Netzwerk — sequence a syllabus.

The app now has 10,000 vocabulary cards, 207 grammar lessons, a 72-unit course
spine, a spaced audio course, 120 Gartenradio episodes, 60 stories / 200
chapters, 60 mini-story drills, 120 writing tasks and 60 role-plays. The
high-leverage corpus, course structure and authored practice-volume work are
complete; the remaining major gap is genuine acoustic feedback and
real-speaker listening.

## What the research changed about the approach

**Four things worth knowing before reading the plan.**

**1. Synthesised audio is not a compromise if you pick the right genres.**
Duolingo's DuoRadio went from 300 to over 15,000 podcast episodes across 25+
courses using generated scripts and TTS voiceover with, in their words, zero
human intervention after initiation — a 99% cost reduction and no voice actors.
The deliverable is plain text. But TTS is *a fine narrator and a poor actor*, so
the winning move is to author only genres that are read from a script in real
life — news bulletins, station announcements, voicemail, weather, audio guides,
recipes, lectures, audiobook narration — and to refuse to fake spontaneous
conversation, emotion or regional accent.

**2. The example-sentence corpus is now a practice engine.**
Every vocabulary card carries a contextual example sentence. Phase 0 removed
the obsolete core-deck exclusion: the runtime now exposes 9,211 sentence
exercises and 8,314 cloze items, plus twelve grammar-challenge collections.
The same corpus now powers sentence building, dictation, shadowing, cloze and
the spaced audio course rather than appearing once on a flashcard.

**3. Almost nothing German is reusable, but three things are.**
DW, Goethe-Institut, Easy German, Coffee Break, GermanPod101, Slow German,
Lingua.com and the Anki shared decks are all rights reserved. COERLL's Deutsch
im Blick is CC BY-NC-ND and the Leipzig Corpora is CC BY-NC — both incompatible
with MIT, which permits commercial use. The genuine exceptions are **Mozilla
Common Voice** (CC0, 1,389 validated hours of German from 20,466 speakers),
**LibriVox** (public domain), **Project Gutenberg** German texts, and the
**Tatoeba CC0 subset**. Since app size is no longer a constraint, Common Voice
is the one that matters: it is real human German, legally bundleable.

**4. Courses have a spine; apps mostly do not.**
Assimil, Teach Yourself, Colloquial, Netzwerk and Goethe all use the same three
parts: a fixed-size unit with a stated outcome, a periodic review unit folding
the previous block back in, and a checkpoint that gates progression. A
3,670-learner survival analysis found 43.16% of app learners gone within three
months, and Duolingo-specific work found the app gets *less* effective the more
advanced the learner — the opposite of what a course should do. DeutschGarden
has the material for a spine and does not have the spine.

## Now that app size is not a constraint

Three things become available that were previously ruled out.

**Bundled neural TTS.** `sherpa_onnx` (pub.dev, **Apache-2.0**, v1.13.6,
actively maintained) supports Android, iOS, macOS, Windows, Linux *and* web —
every target this app has. Piper German voices are available in eight varieties
(`thorsten`, `thorsten_emotional`, `eva_k`, `kerstin`, `ramona`, `karlsson`,
`pavoque`, `mls`), and the Thorsten dataset is **CC0** with the model repo under
MIT. That means:

- identical, good-quality German on every platform
- Linux stops shelling out to `espeak-ng`, which is the worst audio in the app
- multiple distinct voices, so dialogue and role-play have real turn-taking
- `thorsten_emotional` gives register variation for role-play

Per-voice licences differ — `thorsten` is confirmed CC0, the others must be
checked individually before bundling.

**Bundled offline ASR.** The same package does speech recognition. That fixes
three known limitations at once: no recogniser on Linux at all, Android
possibly routing audio to vendor servers, and pronunciation scoring being
text-based rather than acoustic. Forced alignment also makes genuine
per-phoneme scoring possible for the first time.

**Real human audio.** Mozilla Common Voice German is CC0. Bundling a curated
subset gives listening practice with actual speakers, accents and disfluencies —
the one thing TTS genuinely cannot produce.

## The plan

### Phase 0 — unlock what already exists (days)

Nothing new is authored. This is the highest ratio of value to effort in the
whole plan.

**Status: complete in 3.7.0.** The measured result is 9,211 practice sentences,
8,314 cloze items and 1,116 items across twelve grammar challenges.

1. **Remove the obsolete exclusion in `lib/sentence_bank.dart`.** Draw derived
   sentences from all four vocabulary files rather than `coreVocabulary` alone.
   Practice sentences go from 63 curated plus ~180 derived to **9,211**.
   Immediately feeds the existing sentence builder, dictation, shadowing lab and
   cloze drill — four screens get 50x the material with no new prose.
2. **Generate a cloze bank from the same corpus.** 8,314 sentences contain
   their headword verbatim and can be gapped mechanically. Ship as level
   collections mirroring the deck. Four modes: 4-way multiple choice, free text,
   listen-then-gap, and reverse production from a word bank.
3. **Distractor quality is the only real work.** Tag each headword with part of
   speech, plus gender/case/tense where relevant, and draw distractors from the
   same POS and level band so wrong answers are plausible rather than absurd.
4. **12 grammar challenge collections** of 100 items each, filtered from the
   same corpus by feature: nominative articles, accusative after prepositions,
   dative after prepositions, two-way prepositions, adjective endings, Perfekt
   with haben vs sein, separable verbs, reflexives, Konjunktiv II, passive,
   relative pronouns, Genitiv.

**Exit criterion:** practice sentence count over 9,000, cloze bank over 7,500,
all passing the content validator.

### Phase 1 — the audio layer (weeks)

**Status: complete.** The bundled voice shipped in 3.9; scrubbing, atomic cached
rendering and UI-isolate isolation are in 3.11. The 53 hand-authored seeds now
grow into 120 level-matched 250–400-word episodes with six checkpoint blocks
each, without reusing a vocabulary card within a level.

5. **Adopt `sherpa_onnx` with the CC0 Thorsten voice** — **done in 3.9.0.** Keeps the existing
   `flutter_tts` path as a fallback so nothing regresses if a platform
   misbehaves. Verify each additional voice's licence before bundling it.
6. **Gartenradio: 120 narrated episodes** — **done in 3.13.0.** 250–460 words each, roughly 2–3
   minutes at the bundled voice's measured pace. Level split A1 30, A2 30, B1 25, B2 20, C1 10, C2 5. A1/A2 alternate
   a German line with a short English gloss; B1 and above are monolingual.
   Genres restricted to what is read aloud in real life: news bulletin, weather,
   station announcement, voicemail, recipe, museum audio guide, short lecture.
   Six inline checkpoints each — three listen-and-select, two comprehension
   MCQ, one five-pair matching — for **720 new items**.

    Two corrections to the sketch above, recorded rather than quietly
    absorbed. The episodes are 250–460 German words, not 250–400: the old
    ceiling came from a pace constant of 1.7 words per second, and measuring
    the bundled voice showed it actually speaks dense prose at about 2.6, so
    400 words was 154 seconds rather than the three minutes it was meant to
    stand for. And 3.12.0 reached 120 by generating vocabulary magazines into
    the slots the hand-written scripts had not yet filled; 3.13.0 replaced all
    67 of those with written broadcasts, so the library is now entirely
    authored. The magazines were honest scaffolding, not padding — every
    sentence was a real level-matched headword in a validated context — but a
    written broadcast is what they stood in for.

7. **Playback controls** — **done in 3.11.0.** 0.6x / 0.75x / 1.0x / 1.25x, replay-last-10-seconds,
   and a full transcript that reuses the existing tap-a-word lookup. The
   transcript is a first-class fallback, so on any platform where audio
   disappoints the feature degrades to a reading lesson rather than breaking.
8. **Pre-render with `synthesizeToFile`** — **done in 3.11.0.** Where available, so an episode is a
   single concatenated file rather than a sequence of speak calls — that is what
   makes a scrubbable player possible.

**Exit criterion:** 120 episodes playable end to end on Android, Windows and
Linux, with Linux no longer using `espeak-ng`.

### Phase 2 — reading and stories (weeks)

**Status: complete in 3.13.0.** The reader library now contains 60 original
stories / 200 chapters. Every story also has a ten-line mini-story path with
listening, reading, fifteen circling or sequence questions and an oral retell.
Seventy-four chapter retellings feed the writing track, so the same prose is
used receptively and productively rather than counted twice without a new
exercise.

9. **Graded readers to 60 stories / 200 chapters** — **done in 3.14.0.** — **done in 3.13.0.** Level
   them by headword coverage against the actual deck, so a B1 story uses B1 and
   below. That check is mechanical and belongs in the validator.
10. **60 mini-stories in the LingQ shape** — **done in 3.14.0.** — **done in 3.13.0.** This is the most authoring-efficient
    format found: one ~10-line text yields a retell, ~15 circling questions, a
    reading and a listening exercise. One authored text, four exercise types.
11. **Extensive reading target** — **done in 3.13.0.** Enough text that a learner can read at volume
    within one level, which is where the comprehension research points.

### Phase 3 — speaking, writing and the course spine (weeks)

12. **Role-plays from 23 to 60** — **done in 3.16.0.** — **done in 3.13.0.** The 23 practical
    simulations remain intact; 37 reader interviews add structured oral
    retelling with level-appropriate discourse frames and model answers.
13. **Pimsleur-style anticipation drills** — **done in 3.11.0.** English,
    silence, German, German again. The gap scales with sentence length rather
    than being a fixed five seconds, which is far too long for a three-word
    sentence and far too short for a B2 one. The stage is named on screen
    throughout, because an unlabelled silence is indistinguishable from a
    frozen app and nobody uses a frozen app's silence to speak into.
14. **Glossika-style spaced sentence playlists** — **done in 3.11.0.** Ten
    new sentences a day plus the batches from 1, 2, 4, 8, 16 and 32 days ago,
    so a sentence is met six times over a month and then stops. The gaps went
    wider than the sketch above: N-1 to N-4 alone gives four exposures inside
    a week and none after it, which is the half of a spacing curve that does
    not do the work.

    Persisted state is one integer per level. Giving every sentence an SM-2
    record would have put thousands of entries in the profile and flooded the
    "lessons due" count with things that are not lessons. The cost is that
    this does not adapt to the individual sentence, which `docs/AUDIO_COURSE.md`
    states rather than hides.
15. **Writing tasks from 46 to 120** — **partly done in 3.14.0.** — **done in 3.13.0.** Seventy-four reader
    chapters become guided retellings, and every model answer passes the same
    transparent length and keyword rubric shown to the learner.
16. **The course spine** — **done in 3.10.0.** 72 units, twelve per level:
    four teaching units then a review, and a level test closing each level.
    Every unit states a first-person can-do outcome, names its grammar lessons
    in teaching order, takes a dealt share of the level's other material, and
    ends in a checkpoint that opens the next unit at 80%. See `docs/COURSE.md`.

    Two things went differently from the sketch above. The vocabulary target
    is 20 words per unit rather than a share of the whole deck: 1,080 words
    across the course, with spaced repetition covering the rest
    independently — claiming the course walks all 10,000 would have been
    false. And the closing review of each level covers the whole level rather
    than the trailing block, because a gate before moving up that tests one
    unit is not a level test.

    Nothing new is persisted. Unit state is derived from the activity progress
    the app already keeps, so a learner who did half of A1 before this existed
    opens the course and finds half of it ticked.

    **The learner-facing path was streamlined in 3.18.0.** Five competing
    destinations became Learn / Explore / Profile. Learn now calculates due
    review and the exact next core activity automatically. The course still
    assigns all content, but each teaching unit exposes a balanced 7–9-item
    core and keeps the rest as attached optional enrichment, so completeness
    no longer looks like a 16-row prerequisite list. See
    `docs/LEARNING_PATH.md`.

### Phase 4 — acoustic pronunciation (weeks)

    **What "partly" means for 12 and 15.** Both numbers are reached by
    deriving exercises from the 60 written stories rather than authoring them
    separately: role-plays are 23 authored scenarios plus 37 story interviews,
    and writing is 46 authored prompts plus 74 guided chapter retellings. That
    is a reasonable way to get several kinds of practice out of one corpus, and
    the mini-story drills in item 10 are exactly that by design. But a learner
    reading "60 role-plays" expects sixty distinct situations to speak into,
    not twenty-three plus a retelling exercise, so the counts are now reported
    split and the remaining authored scenarios stay on this list.


17. **Offline ASR via the same package** — **still not done, but the reason
    it was declined no longer holds.**

    The original finding said sherpa-onnx shipped no German ASR model and that
    anything handling German was 460–610 MB, against GitHub's hard refusal of
    any file over 100 MB. **Re-checked against the release assets in August
    2026, both halves of that are now false.** German-only models exist:

    | Model | Size |
    | --- | --- |
    | `sherpa-onnx-streaming-zipformer-de-kroko-2025-08-06` | **55 MB** |
    | `sherpa-onnx-nemo-stt_de_fastconformer_hybrid_large_pc-int8` | 100 MB |
    | `sherpa-onnx-nemo-fast-conformer-ctc-en-de-es-fr-14288-int8` | 98 MB |

    A 55 MB German model sits comfortably under the per-file limit and beside
    the two roughly 60 MB voices the app already bundles. Size is no longer the
    product objection, though the Android base-module store cap still matters.

    What has *not* been established is the second half of the original
    argument: that at sizes which fit, German word error rates run 20–35%, so
    the recogniser marks correct pronunciation wrong. That figure was measured
    against the models available then, not these. Nobody has run the Kroko
    zipformer against German learner speech, and a recogniser that fails
    learners with accents is worse than no recogniser at all — which is
    precisely the trap the first investigation avoided.

    So the item stays open with its blocker restated honestly: **it needs a
    word-error-rate measurement on real learner audio, and proving on each
    native target**, not another size survey. Item 18 remains the shipped
    answer in the meantime.
18. **Acoustic pronunciation scoring** — **done in 3.15.0 and 3.17.0**, though
    not by forced alignment. The app already synthesises the target sentence,
    so a reference recording exists for free on every platform; the learner's
    audio is compared against it with MFCC features and dynamic time warping.
    No model, no asset.

    What that buys is timing, rhythm, stress and vowel shape. What it does not
    buy is phoneme identity: it cannot say your /y/ came out as /u/, only that
    a stretch sounded unlike the reference, and the reference is a synthesiser
    rather than a native speaker. `KNOWN_LIMITATIONS` item 6 is narrowed
    accordingly rather than deleted, and item 9 stands unchanged.

    Item 7 does change: Linux had no speaking feedback at all, because
    `speech_to_text` has no Linux implementation. Recording works there, so
    Linux now scores pronunciation without a transcript.

    The 0–100 scale is anchored on two measured figures — the same sentence
    re-synthesised at 0.8 speed scores 12.4, a different German sentence 30.7 —
    and on no human recordings, so where a pass mark belongs among real
    learners remains open.
19. **Common Voice CC0 listening discrimination** — **investigated and not
    shipped.** Public-domain German audio with real voices is easy to get:
    LibriVox recordings are Public Domain Mark 1.0 and Internet Archive serves
    them with a working query API. What is not available is anything to *do*
    with them.

    - The short items — under two minutes, ~600 KB at 64 kbps, and genuinely
      multi-reader, which is the variety this item wanted — are 19th-century
      poetry. Archaic register, wrong for A1 to B1.
    - The prose collections (`Sammlung kurzer deutscher Prosa`) are 5 to 35
      minutes and 2 to 16 MB per piece, too long to bundle.
    - **No transcripts ship with any of it**, and there is no German recogniser
      to generate them (see item 17), so no comprehension questions and no
      minimal-pair drills are possible. A minimal-pair drill needs word-indexed
      audio; a literary reading is not.
    - There is no ffmpeg in the build environment to cut long recordings into
      short clips.

    So the deliverable version was: a few one-minute archaic poems, no
    transcript, no questions. That would be the only content in the app without
    either, breaking a consistency everything else keeps, in exchange for 8 MB
    and a register no learner below B2 can use. Not worth shipping to tick the
    box.

    What would unblock it: a transcribed short-form German corpus under a CC0
    or public-domain licence. Common Voice is exactly that, and its download
    sits behind an account and terms form — one manual download would make this
    item straightforward.


### Phase 5 — German civic integration (complete in 3.12.0)

20. **Leben in Deutschland and Einbürgerungstest preparation** — **done in 3.12.0.** The complete
    official catalogue is bundled offline: 300 general questions, ten for each
    of the 16 Bundesländer, and 100 question images. Learners choose their state,
    practise the relevant 310-question bank with immediate feedback, retain a
    local mistake queue, and sit timed 33-question simulations drawn as 30
    general plus three state questions.
21. **Keep the two legal outcomes distinct** — **done in 3.12.0.** Results show the LiD threshold at
    15/33 and the citizenship-knowledge threshold at 17/33. A 15 or 16 is never
    presented as a citizenship pass.
22. **Make legal-study content reproducible** — **done in 3.12.0.** A source importer cross-checks
    every answer key between two independent official-catalogue extractions.
    The content gate then checks all ids, answer indices, state counts, image
    files and SHA-256 hashes. See `docs/CIVICS_TEST.md`.

## What not to do

- **Do not scrape or adapt DW, Goethe, Easy German or Anki shared decks.** All
  rights reserved. This is the most tempting shortcut in the whole project and
  it would end the MIT licence.
- **Do not use COERLL or Leipzig Corpora** despite their open appearance —
  CC BY-NC-ND and CC BY-NC both forbid the commercial use MIT permits.
- **Do not fake spontaneous conversation with TTS.** Author scripted genres.
  A synthetic voice performing an argument in a café is worse than no audio.
- **Do not add more gamification.** Streaks, XP, quests and achievements are
  already there; the retention research does not support more of them, and the
  missing piece is a course spine, not another counter.
- **Do not chase raw counts again.** 10,000 cards taught nothing extra while
  678 of them had placeholder examples. Content only counts once it is usable.

## Risks

| Risk | Mitigation |
| --- | --- |
| Bundled voices balloon the download | The user explicitly accepts the size; keep the two role voices bundled so conversations work fully offline from first launch |
| Per-voice licences are not all CC0 | Bundle only verified voices: Thorsten and Kerstin both carry their upstream CC0 model cards |
| Generated episode text is subtly wrong German | Same discipline as the deck: mechanical checks in the validator, plus reading a sample |
| Level assignment drifts again | The floor rule replaced the quota; keep it, and level stories by measured headword coverage rather than by hand |
| Scope is very large for one maintainer | Phase 0 alone is a large visible win and needs no new prose — do it first and reassess |
