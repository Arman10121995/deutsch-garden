# Vocabulary visuals: what is done, what was rejected, what is left

Written so the measurements survive. Everything below is a number taken from
the actual deck, not an estimate, and the rejected options are recorded with
their evidence so nobody has to re-discover why they were rejected.

## Where coverage stands

| Tier | Cards | Cost | Licence |
| --- | ---: | --- | --- |
| Authored SVG drawings | 513 | hand-drawn | own work, MIT |
| Tabler line pictograms | 85 | mapped by hand | MIT, attributed per file |
| Emoji (CLDR German names) | 240 | generated | none — a font glyph |
| Compound breakdowns | 1,780 | generated | none — internal cross-reference |
| **Total with something beyond the generic tile** | **2,618** | | |
| Deck | 10,000 | | |

Before this work: 598 of 10,000, or 6%. Now 26%.

The remaining 7,382 cards show the generated structural tile — category icon,
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
names. Restricting to concrete nouns with a chrome blocklist was *not* tried
and is the one live thread here — see below.

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

### 1. Tabler pictograms restricted to concrete nouns — untested, most promising

The gloss-matching route was rejected on precision, but it was never tried
**restricted to concrete nouns with a UI-chrome blocklist**. The failures
above are all abstract words and verbs matching chrome names. Concrete nouns
(`Hammer`, `Kirche`, `Straßenbahn`) are exactly where an icon set is strong.

Unknown: the hit rate and precision on that subset. Worth one afternoon to
measure before deciding. If precision holds above ~90% on a hand-checked
sample, this could be worth several hundred cards at zero licence cost —
Tabler is MIT and the fetch/normalise/attribute pipeline already exists.

### 2. Three-part compounds

The splitter handles two parts only. `Lebensversicherung` (life insurance) is
Leben + s + Versicherung, which works, but genuinely three-part compounds fall
out. German has many. Recursive splitting is a small change to
`tool/build_vocab_compounds.py`; the risk is that each extra split multiplies
the chance of a spurious seam, so it needs a precision check on a sample.

### 3. Compound coverage is capped by the lexicon

Only 1,780 of 7,253 long words decompose, because both parts must already be
cards. Adding common bound morphemes and non-card stems (`-ung`, `-heit`,
`-keit`, `Ver-`, `Ge-`) as a supplementary lexicon would raise it. This is
authoring work but bounded and mechanical.

### 4. Animation — deliberately not expanded, and this needs a decision first

The motion table covers 85 pictograms. Expanding it was considered and **not
done**, because the evidence cuts both ways: dual-coding supports animation
for processes, but Mayer's coherence principle says extraneous animation
*hurts* learning. A vocabulary list of simultaneously wiggling tiles is
plausibly worse than a still one.

The cases where motion is genuinely informative and worth the work:

- **Verbs of motion and separable verbs.** `aufstehen`, `mitnehmen` —
  a prefix flying off and returning is the actual grammar, not decoration.
  The compound table now identifies these mechanically.
- **Wechselpräpositionen.** `auf`/`unter`/`neben`/`zwischen` plus the
  accusative/dative distinction is pure geometry — a ball and a box, moving or
  resting. This could be **generated entirely in code with no assets at all**,
  which is the first rule of the asset policy satisfied perfectly. Probably
  the single best remaining visual idea in the app.

Both need the coherence-principle question settled first: animate few things
well, rather than everything.

### 5. Improve the generic tile itself

7,382 cards still show it. It carries category, word class and gender. It
could carry more at zero cost — word family links, prefix/suffix highlighting,
frequency. Helps every remaining card at once.

### 6. The research that did not happen

A 13-agent survey of permissively-licensed icon and emoji corpora, with
adversarial licence review, was launched and **died with every agent hitting a
session limit**. None of the findings above came from it. Specifically
unexamined: OpenMoji, Twemoji, Fluent Emoji, Noto Emoji SVGs, OpenClipart,
Wikimedia Commons PD categories, and whether any of them beat what is here.
Worth re-running when there is budget.

## Rules that hold this together

- `tool/check_vocab_emoji.py` — stale entry, overlap with a drawing, notation
- `tool/check_vocab_compounds.py` — part that is not a card, self-reference
- `tool/check_line_icons.py` — attribution on every third-party icon
- `tool/check_store_size.py` — the 200 MB Play cap

Each was proved by reintroducing the fault and watching the build fail.
