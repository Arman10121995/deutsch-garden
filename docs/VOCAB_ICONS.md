# Vocabulary visuals

Every one of DeutschGarden's **10,000 vocabulary cards has a visual**, but the
visual has two deliberately different forms.

- **1,245 cards across every CEFR band and major word class** have an original,
  reviewed semantic SVG cue in `assets/vocab/`. The filename is the stable
  vocabulary-card id. Concrete nouns are literal; actions and properties use
  a clearly labelled scene or symbol rather than pretending an abstraction is
  a physical object.
- **52 high-frequency concrete actions and states** have original AI-assisted scene
  illustrations in `assets/vocab_generated/`. They were generated specifically
  for DeutschGarden from an original prompt, reviewed tile by tile and cropped
  locally; they do not copy or embed a third-party image.
- Every other card has a deterministic structural vector rendered by
  `lib/vocab_icon.dart`: a category pictogram, a part-of-speech badge and, for
  nouns, the article/gender colour.

All three tiers are offline and usable at any text scale. The fallback is not
a placeholder: for *obwohl*, *vermutlich* or *Verantwortung*, grammatical role
and category are reliable learning cues while a generic stock picture is not.

## Literal pictures and symbolic memory cues

A picture can make *der Apfel* or *die Straßenbahn* easier to remember. A
symbol can also help recall *schnell*, *bezahlen* or *sich vorbereiten*, but it
must not masquerade as the definition. DeutschGarden therefore keeps the
German word, translation and explicit word-class label beside every cue.

Every reviewed card therefore has one of three explicit outcomes:

- a unique 64×64 semantic SVG in `assets/vocab/`;
- a reviewed pictogram, emoji or generated action scene;
- the universal structural visual, with an optional written reason in
  `tool/vocab_icons_undrawable.tsv` when a semantic picture would mislead.

The TSV records intentional declines, including abstractions, duplicates
whose picture would be indistinguishable, unsafe subjects and categories that
could only be represented as stereotypes. It is a decision log, not an
unfinished-image queue. If manual CEFR re-levelling moves a newly concrete noun
into the reviewed queue, the maintainer either adds a distinct cue or records
why the structural visual is more honest.

## Grammatical information in the visual

`lib/vocabulary_metadata.dart` classifies every card as noun, verb, adjective,
adjective/adverb, adverb, pronoun, preposition, conjunction, number or
expression. That class is visible as a labelled badge rather than colour alone.

Noun visuals also use the app's article colours and can show **der**, **die** or
**das**. Exercise screens can set `revealGrammar: false`; the article trainer
does this before recall so the visual never leaks the answer, then reveals the
gender cue and any productive ending rule afterwards.

## Where visuals appear

The same visual system is reused in:

- new-word study in the guided course;
- per-level vocabulary catalogues and the all-level searchable library;
- the revealed side of an SM-2 review card;
- difficult-word repair;
- the der/die/das trainer.

The library also exposes word-class filtering and links to both the word-class
guide and the noun-gender/ending guide.

## Runtime loading

Flutter bundles the authored files through the `assets/vocab/` and
`assets/vocab_generated/` entries in `pubspec.yaml`. Card ids occur in more
than one shape (`001.svg` and
`x10743.svg` are both valid), so the loader treats the entire filename as the
id.

At startup, `lib/vocab_icon.dart` reads Flutter's supported `AssetManifest`
API. It selects `AssetManifest.bin` on native targets and
`AssetManifest.bin.json` on web, and completes before the first app frame.

Version 3.22 had two stacked discovery defects: it requested the removed
`AssetManifest.json`, then used a digits-only filename pattern that rejected
the `x...` ids. Both were fixed in 3.23 and are guarded by a test that loads the
real generated manifest and requires every shipped file to be discoverable.

## Provenance and quality gates

The 1,245 drawings in `assets/vocab/` and 52 generated scenes were authored for
DeutschGarden. They
embed no raster images, fonts, scripts or remote URLs.

The 85 files in `assets/vocab_line/` are **not** ours: they are Tabler Icons,
MIT licensed, used for verbs and adjectives. Drawing "to arrive" as a scene
invents a story the word does not tell, so a pictogram is the honest form for
those — and redrawing a pictogram vocabulary that already exists under a
compatible licence would be work for its own sake.

That means the bundle does carry one third-party asset licence, which it did
not before. The notice ships in `assets/vocab_line/LICENSE-tabler.txt`, each
file keeps an attribution comment, only the outer `<svg>` element is rewritten
to put them on the shared 64×64 grid, and `tool/check_line_icons.py` fails the
build if any of that stops being true.

- a real vocabulary id for every filename;
- the shared `viewBox="0 0 64 64"` grid;
- a maximum encoded size of 6 KiB;
- no exact duplicate drawing assigned to two different words;
- a maintained floor of 1,100 semantic SVGs so a batch cannot disappear;
- no embedded image and no network reference;
- a declared Flutter asset directory;
- successful discovery of every shipped file;
- a visual and a non-ambiguous word-class label for every card;
- no gender answer leakage in unrevealed article exercises.

## Motion

A verb is not a thing. A still pictogram of a plane says *plane*; the same
pictogram travelling says *to fly*. That gap is why animated stock footage
looked worth buying — and it is also why we did not buy any.

Royalty-free GIF libraries (Pixabay, LottieFiles, Cliply, MotionElements) all
permit *use* while restricting *redistribution*, which a public MIT repository
cannot honour: see `docs/ASSET_POLICY.md`. At the time, the App Bundle also sat
at 181 MB against Google Play's then-current 200 MB ceiling, so a few hundred
megabytes of animation would have cost the ability to publish. Google raised
the base-module ceiling to 500 MB in July 2026; the licensing objection and the
benefit of lightweight authored motion remain unchanged.

So the motion is authored instead. `lib/moving_pictogram.dart` animates the
assets already bundled — a travel, rock, pulse, rise, fade or spin, chosen per
word in `tool/vocab_line_icons.tsv` and generated into `lib/vocab_motion.dart`.
It adds no bytes, needs no network, and carries no licence.

The movements are small on purpose: this sits beside a word the learner is
reading, and anything larger competes with the text. `MediaQuery.disableAnimations`
is honoured, because someone who asked their device to stop animating things
asked this app too.
