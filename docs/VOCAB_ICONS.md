# Vocabulary illustrations

DeutschGarden ships **478 original SVG drawings** in `assets/vocab/`. They are
not generated at runtime and they do not require a network connection. Each
filename is the stable vocabulary-card id, for example `assets/vocab/001.svg`.

## Why only some words have a drawing

The illustrated set is deliberately limited to concrete A1 and A2 nouns. A
picture can make *der Apfel* or *die Straßenbahn* easier to remember. A generic
symbol beside *Verantwortung*, *Gelegenheit* or *Bedeutung* would consume
attention while teaching no reliable meaning.

Every drawable A1/A2 noun has one of two explicit outcomes:

- a 64×64 SVG in `assets/vocab/`;
- a written reason in `tool/vocab_icons_undrawable.tsv`.

The TSV currently records 216 intentional declines, including abstractions,
duplicates whose picture would be indistinguishable from another word, unsafe
subjects and categories that could only be represented as stereotypes. It is
a decision log, not an unfinished-image queue.

## Where the drawings appear

When a word has an illustration, the same asset is reused in:

- the new-word flashcard in the guided course;
- the per-level vocabulary catalogue;
- the all-level searchable vocabulary library under Explore;
- the revealed side of an SM-2 review card, so the image does not give away
  the answer before recall;
- difficult-word repair and the der/die/das trainer.

Abstract words continue to show the mastery plant where that communicates more
useful information than an empty image frame.

## Runtime loading

Flutter bundles all 478 files through the `assets/vocab/` entry in
`pubspec.yaml`. At startup, `lib/vocab_icon.dart` reads Flutter's supported
`AssetManifest` API. That API selects `AssetManifest.bin` on native targets and
`AssetManifest.bin.json` on web. The index is loaded before the first app frame,
so a vocabulary list cannot render once without icons and then remain stale.

Version 3.22 had both source and packaged SVG files, but attempted to read the
obsolete `AssetManifest.json` filename and silently treated the failed read as
an empty icon set. The files were present in every release; discovery and UI
integration were the missing pieces.

## Provenance and quality gates

The drawings were authored for DeutschGarden. They do not embed raster images,
fonts, scripts or remote URLs and add no third-party asset licence to the MIT
application. The validator and tests require:

- a real vocabulary id for every filename;
- the shared `viewBox="0 0 64 64"` grid;
- a maximum encoded size of 6 KiB;
- no embedded image and no network reference;
- a declared Flutter asset directory;
- successful discovery through the real binary asset manifest.
