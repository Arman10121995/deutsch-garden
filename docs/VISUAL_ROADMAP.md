# Vocabulary visuals: what is done, what was rejected, what is left

Written so the measurements survive. Everything below is a number taken from
the actual deck, not an estimate, and the rejected options are recorded with
their evidence so nobody has to re-discover why they were rejected.

## Where coverage stands

| Tier | Cards | Cost | Licence |
| --- | ---: | --- | --- |
| Authored SVG drawings | 1,537 | project-authored; targeted visual reviews | own work, MIT |
| AI-assisted action/state scenes | 52 lemmas | generated and reviewed in 4.4–4.10 | own project assets, MIT |
| Tabler line pictograms | 85 (hidden under drawings from 4.5, visible again from 4.15.0) | mapped by hand | MIT, attributed per file |
| Emoji (CLDR German names) | 235 | generated | none — a font glyph |
| Compound breakdowns | 1,780 | generated | none — internal cross-reference |
| Separable-verb animations | 341 | generated | none |
| Wechselpräposition diagrams | 9 | drawn in code | none |
| **Direct semantic SVG coverage** | **15.37% of the deck** | | |
| Deck | 10,000 | | |

Before this work: 598 of 10,000, or 6%. Direct authored SVG coverage is now
1,537 cards, and compound, emoji, line-icon and motion tiers extend useful cues
further. Tier overlap is intentional, so their rows must not be summed into a
misleading coverage percentage. Nothing in the new authored tranche was
downloaded or copied.

**Verb tranche, 4.14.1 (60 cards).** The noun sweep below is exhaustive and
closed; verbs never had an equivalent pass. Checked the missing-verb pool
(2,559 cards) against `generatedVocabIllustrations` in `lib/vocab_icon.dart` —
the 52-lemma action/state scene map, which takes priority over an authored SVG
and would make one unreachable — before drawing anything, to avoid drawing
into an already-covered lemma (`sehen`, `geben`, `spielen`, `laufen`, etc. are
already scenes, not gaps). The 60 drawn are concrete, unambiguous, level A1–B1
verbs with a single clear visual metaphor: motion verbs (`einsteigen`,
`aussteigen`, `fallen`, `steigen`, `sinken`), social verbs (`heiraten`,
`umarmen`, `küssen`, `grüßen`, `danken`), household/travel verbs (`aufräumen`,
`staubsaugen`, `packen`, `buchen`, `übernachten`), and similar. Deliberately
excluded: modal and copula verbs (`werden`, `sollen`, `mögen`, `scheinen`) and
abstract academic verbs (`operationalisieren`, `kontextualisieren`), which
dominate the remaining backlog and fail the same test that closed the noun
sweep — no honest single picture exists for them. Also excluded on tone:
violent or dark-themed verbs present in the deck (`töten`, `ermorden`,
`foltern`, `verhungern`) got no picture rather than a sanitised one.

**Verb tranche, 4.14.2 (56 cards).** Same process, next slice of the A2-B1
pool: `wählen`, `teilen`, `probieren`, `abschließen`, `wecken`, `räumen`,
`lehren`, `verabschieden`, `landen`, `verbinden`, `stoppen`, `tauchen`,
`ausziehen`, `löschen`, and 42 more. Regenerating
`lib/vocab_emoji.dart` after drawing is now a standing step, not a
post-failure fix — see 4.14.1's CI failure in the changelog.

**Verb tranche, 4.14.3 (45 cards).** `entschuldigen`, `verstecken`,
`vorstellen`, `zurückkommen`, `reinkommen`/`rauskommen`, `befreien`,
`retten`, `klettern`, `zittern`, `gründen`, `spenden`, `schlucken`,
`testen`, `korrigieren`, `servieren`, `vermissen`, `entdecken`,
`vertrauen`, `verteidigen`, `beobachten`, and 25 more. No emoji overlap
this round — the standing regeneration step ran clean.

**Verb tranche, 4.14.4 (45 cards).** `kümmern`, `beginnen`, `ehren`,
`beschützen`, `kennenlernen`, `verwandeln`, `mischen`, `rennen`,
`überraschen`, `aufgeben`, `starten`, `stürzen`, `entfernen`, `beißen`,
`einnehmen`, `zweifeln`, `anschließen`, `weigern`, and 27 more. The
concrete A1-B2 pool is visibly thinning after four tranches (206 verbs
drawn total) — most of what remains in the missing-verb backlog is modal,
copula, or abstract-academic, the same wall the noun sweep hit.

**Verb tranche, 4.14.5 (26 cards, 232 total).** Smaller batch on purpose —
the concrete pool is thin enough now that padding to a round number would
mean drawing words that don't have an honest single picture. The
browser-grid review caught a real collision before it shipped: `verletzen`
first came out as a red-circle-with-X, identical in silhouette to the
existing `Fehler` card; redrawn as a cracked heart. `wiederholen`,
`erreichen`, `sperren`, `einstellen`, `bedienen`, `überwachen`,
`überreden`, and 19 more shipped clean.

**Verb tranche, 4.14.6 (18 cards, 250 total) — closing this tranche.**
`rasieren`, `gärtnern`, `jäten`, `rutschen`, `schweben`, `verwechseln`,
`auffangen`, `einfrieren`, `verdauen`, `einschenken`, `begießen`, and 7
more. This is the last batch: the pool of concrete, single-metaphor,
undrawn verbs is exhausted at the same bar the noun sweep used. What
remains in the missing-verb backlog — checked by hand while sourcing this
batch — is modal (`werden`, `sollen`, `mögen`), copula/stative
(`gehören`, `scheinen`, `bedeuten`), or abstract-academic
(`einschränken`, `bewältigen`, `verschärfen`, `nachvollziehen`). Every one
of those was already excluded from 4.14.1 onward for the same reason: no
honest single picture exists. A future tranche would have to re-examine
words already judged undrawable, which is exactly the failure mode this
whole exercise exists to avoid.

**Total across the six-release verb tranche: 250 cards**, taking authored
SVG coverage from 1,344 to 1,594 (13.44% → 15.94% of the deck). Every
batch was checked against `generatedVocabIllustrations` before drawing,
regenerated `lib/vocab_emoji.dart` after drawing (a CI failure in 4.14.1
made this a standing step rather than an afterthought), and was reviewed
in a rendered browser grid before shipping — that review caught one real
collision (4.14.5's `verletzen`) before it reached a commit.

**Adjective tranche, 4.15.0 (33 cards).** Adjectives and adverbs are the
one word class no sweep had reached: before this batch the `Description`
category had 27 drawn cards against 1,146 with no picture of any tier. The
pool was the 735 undrawn A1–B2 cards that are neither nouns nor verbs, plus
the C1/C2 adjectives. Only cards whose property can be seen were drawn, mostly
as families that keep everything except the property the same:

- ten colour-sample chips
- three hair busts
- one queue, with the front, middle or back person marked
- one T-shirt, clean or dirty
- one slope, uphill or downhill
- one set of blocks, in a row or in a stack
- three faces

Eight single objects complete the batch: `krumm`, `fehlend`, `zerrissen`,
`vierblättrig`, `außerirdisch`, `hochhackig`, `schlammig`, `ungerade`. Every
drawing was ranked against the whole existing set by pixel distance
(`tool/svg_neighbours.py`, new) as well as reviewed in the rendered grid. That
caught `traurig` drawn as the same plain frown as `Entschuldigung` before it
shipped.

19 cards were declined, with reasons in `tool/vocab_icons_undrawable.tsv`;
most of them collide with a card already drawn (`wütend` is `Wut`, `heiter` is
`Wetter`, `innen` is `drinnen`).

One question is left open on purpose. 25 nationality adjectives could carry
flags, and the deck has no country nouns for them to collide with. But
nationalities are a class the project already declines, so drawing them is a
maintainer decision, not a batch decision. Per-card senses and limits are in
`docs/VISUAL_REVIEW_4_15_ADJECTIVES.md`.

**The Vibe Mistral audit, 4.15.0.** The 486 drawings of the 4.5 import were
audited against their cards, and most failed at card size. The audit also
found something more serious: they had been drawn over all 85 line
pictograms, which an authored drawing outranks, so the animated tier had not
been visible since 4.5.

- 90 drawings that could never be shown are removed, so the pictograms and
  generated scenes show again. The validator now refuses a card with two
  picture tiers.
- 387 are redrawn to the standard of the 4.12 Codex drawings: 132 from the
  thing itself and 255 as symbolic cues.
- 9 are kept.

The 255 symbolic cues change a position this document took earlier. For
conjunctions, modal verbs and academic abstractions it argued that the
structural tile beats any picture. The maintainer chose best-effort
metaphors instead, drawn from each card's example sentence where possible.
They are cues, not definitions, and a weak one should be replaced. Details
and a per-card list are in `docs/VISUAL_AUDIT_4_15.md`.

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

### Emoji from CLDR German canonical names — 235 cards

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
- **52 high-frequency action/state scenes** — walking, running, jumping, swimming,
  sleeping, cooking, reading, writing, drinking, opening, closing, sitting,
  standing, carrying, throwing, laughing, buying, paying, asking, answering,
  helping, waiting, searching, finding, travelling, telephoning, learning,
  working, celebrating, meeting, sick and healthy. Generated as coherent
  original sheets, visually reviewed, then cropped and mapped by German lemma
  so duplicate stable card ids share the same honest scene.

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

### The whole undrawn pool has now been swept, and the result is recorded

Every undrawn noun card has been read against the already-drawn list. The
first pass covered 2,124 rows before it ran out; the second covered the
remaining 2,121.

| | First half | Second half |
| --- | ---: | ---: |
| Rows read | 2,124 | 2,121 |
| Judged drawable | 65 | 129 |
| Drawn (4.10.1-4.10.6) | 63 | 128 |
| Declined with a reason | 2 | 3 |
| Carried forward | 0 | **0** |

**The backlog is empty.** Every candidate the sweep judged drawable has now
been drawn or declined with a reason. That is the end of this tier's easy
yield, and it is worth being blunt about what it means: 194 candidates came
out of 4,245 undrawn noun cards, 191 shipped, 11 were declined, and there is
no queue behind them. Any further tranche has to re-examine words the sweep
already judged undrawable, which is precisely how a wrong picture gets on a
card.

**The shape set is complete.** Quadrat and Dreieck shipped in 4.10.2 with a
tick-mark idiom saying "this card is about the shape itself"; Rechteck, Kugel
and Winkel now use the same idiom, so the five read as one family rather than
as a box, a ball and two triangles.

**What the two halves together show.** Roughly 4.6% of undrawn noun cards can
carry an honest picture. The rest are not failures of drawing: they are
abstractions (*Zuversicht*, *Wechselkurs*), agent nouns (*Buchhalter*,
*Optimist*), states (*Muedigkeit*), or nouns whose picture already exists on a
neighbouring card. That number is the honest ceiling for this tier, and it is
why "improve the generic tile" below is the larger lever.

**The kills are mostly collisions, not undrawable words.** Sparschwein beside
Schwein, Osterhase beside Hase, Rettungsweste beside Weste, Armbanduhr beside
Uhr and Wecker, Besteck beside Loeffel and Gabel, Hefter beside Tacker,
Blumenkohl beside Kohlkopf, Oboe beside Klarinette. At 1,339 drawings the
binding question is no longer "can this word be drawn" but "is there room left
beside what is already there", so the drawn-word list is an input to the
triage rather than a check afterwards.

**Nine words are declined outright** across 4.10.1-4.10.3, each with what the
attempts actually looked like: Netz, Blitz, Frost, Damm, Ebbe, Strauss,
Zahnpasta, Dudelsack and Trillerpfeife. Recording the shape of the failure is
the point -- "a bagpipe cannot be drawn" would be false, whereas "a round bag
with pipes radiating off it is a body with legs" is a fact the next attempt
can use.

**One drawing rule was learned the expensive way** and now applies to every
pale object: its outline must be a *wider dark stroke underneath*, never a
thin dark line on top. A thin line on top draws a thin line, which is how a
ribbon of toothpaste disappeared completely on a white card. Same failure as
the white daisy and the gull in flight.

### STILL LIVE

#### 1. Improve the generic tile — started, and the first finding was a defect

Most cards still rely on it: 8,402 of 10,000 have no picture of any tier. It
carries a category pictogram, a word-class label and the gender colour.

The first thing measuring it found was not a missing feature but a broken one.
`_categoryIcon` matched category names the deck does not use, so **only 9.7%
of those cards reached a category branch and 90.3% silently fell back to the
word-class icon.** 2,413 cards — 29% of the uncovered deck — wore one
identical tile, and only 61 distinct tiles existed across all 8,402. Nothing
failed; the symptom was invisible without counting. Fixed in 4.11.0, coverage
now 62.5%, pinned by `tool/check_category_icons.py`.

`General` is 37.5% and stays on the fallback deliberately: it is the deck's
record that a card has no topic.

**What is still open here.** The tile now varies more, but it still says what
kind of word this is rather than which word. Measured signals that could be
added, with their real coverage of the uncovered deck:

| Signal | Cards | Share | Note |
| --- | ---: | ---: | --- |
| Plural class (`-en`, `¨-e`, `-s` …) | 3,141 | 37.4% | exact from `german` + `plural`; the plural *text* is already shown on the study and library screens, so this would only pay as a *class* marker that groups nouns |
| Gender-predicting suffix | 1,088 | 12.9% | `-ung`/`-heit`/`-keit` etc.; `genderEndingComment` already states the rule in three screens |
| Separable prefix | 341 | 4.1% | already animated |
| CEFR level | 8,402 | 100% | six values, always present |

Note what that table says: every high-coverage signal is **already shown as
text somewhere on the screens where the big tile appears**. That is the honest
constraint on this item, and it is why the next step is not "add another chip"
but deciding whether the 44px list tile should carry something the row's text
does not already carry.

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
- `tool/check_store_size.py` — Play's 500 MB base-module rejection limit and
  separate 200 MB mobile-data notice threshold

Each was proved by reintroducing the fault and watching the build fail.
