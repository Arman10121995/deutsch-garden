# Vocabulary visuals

Every one of DeutschGarden's **10,000 vocabulary cards has a visual**, but the
visual has two deliberately different forms.

- **480 concrete A1–A2 nouns** have an original semantic SVG drawing in
  `assets/vocab/`. The filename is the stable vocabulary-card id.
- **16 high-frequency concrete actions** have original AI-assisted scene
  illustrations in `assets/vocab_generated/`. They were generated specifically
  for DeutschGarden from an original prompt, reviewed tile by tile and cropped
  locally; they do not copy or embed a third-party image.
- Every other card has a deterministic structural vector rendered by
  `lib/vocab_icon.dart`: a category pictogram, a part-of-speech badge and, for
  nouns, the article/gender colour.

All three tiers are offline and usable at any text scale. The fallback is not
a placeholder: for *obwohl*, *vermutlich* or *Verantwortung*, grammatical role
and category are reliable learning cues while a generic stock picture is not.

## Why semantic drawings stop at concrete words

A picture can make *der Apfel* or *die Straßenbahn* easier to remember. A
generic symbol beside *Gelegenheit*, *dennoch* or *bewirken* would suggest one
narrow interpretation and consume attention without teaching the word.

Every drawable A1/A2 noun therefore has one of two explicit outcomes:

- a 64×64 SVG in `assets/vocab/`;
- a written reason in `tool/vocab_icons_undrawable.tsv`.

The TSV records 216 intentional declines, including abstractions, duplicates
whose picture would be indistinguishable, unsafe subjects and categories that
could only be represented as stereotypes. It is a decision log, not an
unfinished-image queue. If manual CEFR re-levelling moves a newly concrete noun
into A1/A2, the coverage gate requires either a drawing or a recorded reason.

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

The 513 drawings in `assets/vocab/` were authored for DeutschGarden. They
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
