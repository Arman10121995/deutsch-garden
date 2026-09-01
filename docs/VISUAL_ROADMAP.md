# Vocabulary visuals: what is done, what was rejected, what is left

Written so the measurements survive. Everything below is a number taken from
the actual deck, not an estimate, and the rejected options are recorded with
their evidence so nobody has to re-discover why they were rejected.

## Where coverage stands

| Tier | Cards | Cost | Licence |
| --- | ---: | --- | --- |
| Authored SVG drawings | 513 | hand-drawn | own work, MIT |
| AI-assisted action scenes | 16 lemmas | generated and reviewed in 4.4 | own project assets, MIT |
| Tabler line pictograms | 85 | mapped by hand | MIT, attributed per file |
| Emoji (CLDR German names) | 240 | generated | none — a font glyph |
| Compound breakdowns | 1,780 | generated | none — internal cross-reference |
| Separable-verb animations | 341 | generated | none |
| Wechselpräposition diagrams | 9 | drawn in code | none |
| **Total with something beyond the generic tile** | **~2,916** | | |
| Deck | 10,000 | | |

Before this work: 598 of 10,000, or 6%. Now roughly 29%. Every tier added
since is generated: nothing was downloaded, licensed or attributed.

The remaining cards show the generated structural tile — category icon,
word class, gender colour. That is honest and it is not nothing, but it says
what kind of word it is rather than what it means.

## What was measured and rejected

These all looked good on paper. Each was killed by measuring precision rather
than coverage, because **a wrong picture on a vocabulary card teaches the wrong
thing and is worse than no picture at all.**

### English gloss → Tabler icon name — rejected

828 matches (8.8% of uncovered cards). Precision unusable. The route goes
through English, and English is where the ambiguity lives:

| Card | Means | Matched | Which is |
| --- | --- | --- | --- |
| `prüfen` | to check, examine | `tabler:check` | a tick mark |
| `kündigen` | to resign, cancel | `tabler:cancel` | an X |
| `im Gegensatz dazu` | in contrast | `tabler:contrast` | a brightness slider |
| `Fortschritt` | progress | `tabler:progress` | a UI progress bar |
| `relativieren` | to qualify | `tabler:perspective` | a 3D grid |

Most icon sets are largely UI chrome, and abstract vocabulary matches chrome
names. Restricting to concrete nouns with a chrome blocklist was tried
afterwards and also failed — see the rejections below.

### CLDR German keyword lists — rejected

1,205 matches (12.8%). Also poor. `Vorteil` (advantage) got 🉐, a Japanese
"bargain" ideograph; `Verhandlung` (negotiation) got 🈚, "free of charge";
`Sicherheit` and `Gefahr` got glyphs that do not render at all. Keyword lists
exist for *search*, where a loose match costs nothing.

### Royalty-free GIF libraries — rejected earlier, still rejected

Pixabay, Cliply, MotionElements, LottieFiles, GIPHY, Tenor. They permit use
while restricting redistribution, which a public MIT repository cannot honour.
Recorded in `docs/ASSET_POLICY.md`.

## What was accepted, and why

### Emoji from CLDR German canonical names — 240 cards

A canonical name is Unicode's own statement of what the character depicts, in
German. Matching German to German removes the translation step the false
friends came from. `Nase`→👃, `Leiter`→🪜, `Schaf`→🐑,
`Wissenschaftler`→👨‍🔬, `Nashorn`→🦏.

Zero cost: an emoji is a code point drawn by a font the device already has.
No asset, no bundle bytes, no licence, nothing to attribute.

Two filters that matter: notation is dropped (CLDR annotates `&` too, and
`und`→`&` illustrates nothing), and eight Unicode 16 code points are excluded
after checking by eye that they render as empty boxes on current fonts. That
cutoff is a judgement about font rollout, not a fact.

### Compound breakdowns — 1,780 cards

The highest-yield item, and the reason it beat buying more icons: it
*multiplies* the existing illustrations instead of adding to them.

- 1,780 cards are built from two words already in the deck
- 849 have a picture on at least one part
- 259 have a picture on **both** — a composed illustration for free

`Ohrring` = Ohr + Ring. `Tagebuch` = Tag + Buch. `Brieftasche` = Brief +
Tasche. `Krankenhaus` = krank + Haus.

Says "built from", never "means" — `Aufgabe` is *auf* + *Gabe* and a task is
not an up-gift. The Fugenelement is shown as its own chip because it belongs
to neither part.

## What is left

Ordered by value per unit of effort, with what is actually known about each.

### DONE since this was written

- **Wechselpräposition diagrams** — all nine, drawn in code, no assets. *wohin?* beside *wo?*,
  a box and a ball, moving for the accusative and still for the dative.
- **341 separable-verb animations** — the prefix travelling to the end of the clause. The one
  animation in the app that carries meaning rather than decoration.
- **Placement retake notice** — shown once, dismissible, never repeated.
- **16 high-frequency action scenes** — walking, running, jumping, swimming,
  sleeping, cooking, reading, writing, drinking, opening, closing, sitting,
  standing, carrying, throwing and laughing. Generated as one coherent original
  sheet, visually reviewed, then cropped and mapped by German lemma so duplicate
  stable card ids share the same honest scene.

### REJECTED after measuring — do not retry without new information

#### Tabler restricted to concrete nouns — 16 candidates, ~2/3 precision

This was listed below as "the most promising untested idea". It was tested and it fails.

Restricting to concrete-noun categories with a UI-chrome blocklist yields **16 candidates**,
of which roughly a third are wrong:

| Card | Means | Matched Tabler's | Which is |
| --- | --- | --- | --- |
| `Kranich` | crane (the bird) | `crane` | a construction crane |
| `Regie` | direction (of a film) | `direction` | an arrow |
| `Spielfigur` | a board-game piece | `man` | a person |
| `Platz` | space, room | `space` | a spacebar |

The count is low for a structural reason worth remembering: **the A1/A2 concrete nouns, where
generic icon sets are strongest, are already hand-drawn.** What remains uncovered is abstract
vocabulary or nouns too specific for a general set. Building a pipeline, a gate and a review
pass for ~10 usable icons is not worth it.

#### Three-part compounds — 81 candidates, majority actively wrong

Recursive splitting **shreds atomic morphemes**, and it does so on very common words:

| Word | Split as | Should be |
| --- | --- | --- |
| `wiedersehen` | wie + der + sehen | wieder + sehen |
| `niederschlagen` | nie + der + schlagen | nieder + schlagen |
| `Mittagessen` | mit + tag + essen | Mittag + essen |

Teaching a learner that *wieder* is *wie* + *der* is worse than teaching them nothing. The
risk flagged when this was proposed — "each extra seam multiplies the chance of a spurious
one" — is exactly what happened. The two-part splitter stays as it is.

#### Bound-morpheme suffixes — already covered

`-ung`/`-heit`/`-keit` gender rules already exist as `GermanWord.genderEndingComment` and the
`GenderGuideScreen`. Nothing to add.

### STILL LIVE

#### 1. Improve the generic tile

7,382 cards still show it. It carries category, word class and gender colour.
It could carry more at no cost — word-family links, prefix and suffix
highlighting, frequency. **This is now the largest lever left**, because it
reaches every remaining card at once rather than a few hundred, and it needs
no external anything.

#### 2. A German-side semantic image source, if one exists

Every rejection above failed the same way: the route to the image ran through
an English gloss, and English is where the ambiguity lives. The one route that
worked — CLDR German canonical names — worked because it matched German to
German.

So the open question is narrow and specific: **does a permissively-licensed
image corpus exist that carries German labels, or unambiguous concept IDs
reachable from German without English in the path?** Candidates never checked:
OpenMoji's annotation system, ARASAAC (multilingual AAC pictograms — but check
the non-commercial clause very carefully), Wikidata's German labels plus P18
images, Open German WordNet's synset IDs, Mulberry and other AAC sets.

Note what is *not* the question: whether more icon sets exist. They do, and it
does not help. The bottleneck was never availability.

#### 3. Compound coverage is capped by the lexicon

Only 1,780 of 7,253 long words decompose, because both parts must already be
cards. A supplementary lexicon of non-card stems would raise it. Bounded,
mechanical, and much safer than recursive splitting proved to be.

## On animation, settled

The motion question is now answered rather than open. Two things are animated
and nothing else is:

- **341 separable verbs** — the prefix travelling to the end of the clause.
- **9 Wechselpräpositionen** — motion for the accusative, stillness for the
  dative.

Both qualify on the same test: the motion *is* the content. A wiggling
vocabulary tile is not, and Mayer's coherence principle says it costs
attention rather than earning it. The bar for animating anything else is that
it must pass that test.

Everything animated honours `MediaQuery.disableAnimations`.

## Rules that hold this together

- `tool/check_vocab_emoji.py` — stale entry, overlap with a drawing, notation
- `tool/check_vocab_compounds.py` — part that is not a card, self-reference
- `tool/check_separable_verbs.py` — an inseparable prefix, a non-verb, a
  capitalised prefix, or an entry readmitted after being excluded by hand.
  That last one exists because no rule over prefixes can catch `wiederholen`:
  *wieder* really is separable in *wiedersehen*, so only the hand-written
  exclusions file can tell them apart, and its whole value is that entries
  stay out.
- `tool/check_line_icons.py` — attribution on every third-party icon
- `tool/check_store_size.py` — the 200 MB Play cap

Each was proved by reintroducing the fault and watching the build fail.
