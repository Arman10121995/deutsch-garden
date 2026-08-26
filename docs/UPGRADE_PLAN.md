# Content upgrade plan

Written after researching what Duolingo, Babbel, Busuu, Memrise, Pimsleur,
Glossika, Clozemaster, LingQ, Seedlang and the German-specific resources (DW,
Goethe-Institut, Easy German, Coffee Break) actually ship, and how durable
courses — Assimil, Teach Yourself, Colloquial, Netzwerk — sequence a syllabus.

The app now has 10,000 vocabulary cards, 207 grammar lessons, a 72-unit course
spine, a spaced audio course, 53 Gartenradio episodes, 21 stories / 56 chapters,
46 writing tasks and 23 role-plays. The high-leverage corpus work and course
structure are complete; the remaining gap is sustained reading/listening
volume, production practice and genuine acoustic feedback.

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

**Status: engineering complete, content partial.** The bundled voice shipped in
3.9; scrubbing, atomic cached rendering and UI-isolate isolation are in 3.11.
There are 53 short episodes, so the 120 long-form episode target remains.

5. **Adopt `sherpa_onnx` with the CC0 Thorsten voice**, keeping the existing
   `flutter_tts` path as a fallback so nothing regresses if a platform
   misbehaves. Verify each additional voice's licence before bundling it.
6. **Gartenradio: 120 narrated episodes**, 250–400 words each, roughly 2–3
   minutes. Level split A1 30, A2 30, B1 25, B2 20, C1 10, C2 5. A1/A2 alternate
   a German line with a short English gloss; B1 and above are monolingual.
   Genres restricted to what is read aloud in real life: news bulletin, weather,
   station announcement, voicemail, recipe, museum audio guide, short lecture.
   Six inline checkpoints each — three listen-and-select, two comprehension
   MCQ, one five-pair matching — for **720 new items**.
7. **Playback controls**: 0.6x / 0.75x / 1.0x / 1.25x, replay-last-10-seconds,
   and a full transcript that reuses the existing tap-a-word lookup. The
   transcript is a first-class fallback, so on any platform where audio
   disappoints the feature degrades to a reading lesson rather than breaking.
8. **Pre-render with `synthesizeToFile`** where available, so an episode is a
   single concatenated file rather than a sequence of speak calls — that is what
   makes a scrubbable player possible.

**Exit criterion:** 120 episodes playable end to end on Android, Windows and
Linux, with Linux no longer using `espeak-ng`.

### Phase 2 — reading and stories (weeks)

9. **Graded readers to 60 stories / 200 chapters**, from 12 / 33 today. Level
   them by headword coverage against the actual deck, so a B1 story uses B1 and
   below. That check is mechanical and belongs in the validator.
10. **60 mini-stories in the LingQ shape**, which is the most authoring-efficient
    format found: one ~10-line text yields a retell, ~15 circling questions, a
    reading and a listening exercise. One authored text, four exercise types.
11. **Extensive reading target**: enough text that a learner can read at volume
    within one level, which is where the comprehension research points.

### Phase 3 — speaking, writing and the course spine (weeks)

12. **Role-plays from 16 to 60**, using distinct bundled voices per speaker.
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
15. **Writing tasks from 36 to 120**, with model answers.
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

### Phase 4 — acoustic pronunciation (weeks)

17. **Offline ASR via the same package**, replacing platform speech recognition.
18. **Forced-alignment pronunciation scoring**, retiring the text-based
    Needleman-Wunsch approximation and `KNOWN_LIMITATIONS` items 6, 7 and 9 with
    it.
19. **Common Voice CC0 listening discrimination** — real speakers, so learners
    hear German that is not synthesised.

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
| Bundled voices balloon the download | Size is accepted, but ship one voice as default and make the rest optional downloads if that changes |
| Per-voice licences are not all CC0 | Verify each before bundling; `thorsten` is confirmed, the other seven are not |
| Generated episode text is subtly wrong German | Same discipline as the deck: mechanical checks in the validator, plus reading a sample |
| Level assignment drifts again | The floor rule replaced the quota; keep it, and level stories by measured headword coverage rather than by hand |
| Scope is very large for one maintainer | Phase 0 alone is a large visible win and needs no new prose — do it first and reassess |
