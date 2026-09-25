# Visual review 4.15.0: adjectives and adverbs

33 original SVGs, the first drawings for the one word class no earlier sweep
had reached. The noun sweep (4.10) and the verb tranche (4.14.1–4.14.6) are
closed and say so in `docs/VISUAL_ROADMAP.md`. Before this batch, the deck's
`Description` category had 27 drawn cards and 1,146 with no picture of any
tier.

All 33 are project-authored paths and shapes on the shared 64×64 grid. They
contain no text, raster images or remote references. Each ID below had no
drawing, line icon, emoji or generated scene before this batch. Each sense was
checked against the live gloss and example.

## How the pool was read

The candidates were every undrawn A1–B2 card that is neither a noun nor a verb
(735 cards, most of them adverbs, particles and pronouns), plus the C1/C2
adjectives. A property was drawn only when it can be seen. Most of the
drawings come in families on one template, so that everything except the
property stays the same, the way the shape set already works:

- **colour-sample chips:** the same card with only the colour changed
- **hair:** one bust with different hair
- **vorne / mitten / hinten:** one queue at a door with a different person marked
- **sauber / schmutzig:** one T-shirt
- **bergauf / bergab:** one slope with the arrow reversed
- **nebeneinander / übereinander:** the same three blocks, in a row and in a stack

## The drawings

| ID / asset | German | Level | Live gloss — *example* | Source | Visual and its limit |
|---|---|---|---|---|---|
| [x23503.svg](../assets/vocab/x23503.svg) | grau | A2 | grey, gray — *Ihre grauen Haare machen sie älter als sie ist.* | `lib/vocabulary_generated.dart:3512` | Colour-sample chip in the palette grey, on the shared chip template. Names the colour, not any grey object. |
| [x22565.svg](../assets/vocab/x22565.svg) | braun | B2 | brown — *Ich hatte braunes Haar, bevor ich eine Glatze bekam.* | `lib/vocabulary_generated.dart:2574` | Colour-sample chip in the palette brown. |
| [x24673.svg](../assets/vocab/x24673.svg) | violett | B1 | violet; purple; lilac (color/colour) — *Das violette Hemd gefällt mir.* | `lib/vocabulary_generated.dart:4682` | Colour-sample chip in violet. Violett spans violet to lilac; one swatch cannot cover the whole range. |
| [x22554.svg](../assets/vocab/x22554.svg) | silbern | B2 | silver-colored — *Nickel ist ein hartes, hell silbernes Metall.* | `lib/vocabulary_generated.dart:2563` | Chip with a silver gradient and two shine streaks, the same template as golden. It shows the metallic colour, not the metal Silber. |
| [x20627.svg](../assets/vocab/x20627.svg) | golden | A2 | golden; gold (made of gold) — *Ich gab ihm eine goldene Uhr.* | `lib/vocabulary_generated.dart:636` | Chip with a gold gradient and shine streaks. Shows the colour and gleam; "made of gold" is only implied. |
| [x26967.svg](../assets/vocab/x26967.svg) | orangefarben | C2 | orange-coloured — *Gehen Sie durch die orangefarbene Tür!* | `lib/vocabulary_generated.dart:6976` | Colour-sample chip in orange, kept visibly redder than the golden chip. |
| [x28256.svg](../assets/vocab/x28256.svg) | hellblau | C2 | light blue — *Er trug eine hellblaue Krawatte.* | `lib/vocabulary_generated.dart:8265` | Colour-sample chip in the palette light blue. |
| [x28140.svg](../assets/vocab/x28140.svg) | dunkelblau | C2 | dark blue — *Sie trug einen dunkelblauen Schal.* | `lib/vocabulary_generated.dart:8149` | Colour-sample chip in navy. Sits next to hellblau on the same template so the pair differs in lightness only. |
| [x23563.svg](../assets/vocab/x23563.svg) | farbig | C1 | colored — *Dein farbiges Hemd fällt wirklich auf.* | `lib/vocabulary_generated.dart:3572` | Chip striped red, orange, yellow, green and blue: coloured as opposed to schwarzweiß. farbenfroh is declined as the same chip. |
| [x27247.svg](../assets/vocab/x27247.svg) | schwarzweiß | C2 | black-and-white — *Ich habe einen schwarzweißen Hund.* | `lib/vocabulary_generated.dart:7256` | Chip split into a black half and a white half. |
| [x20816.svg](../assets/vocab/x20816.svg) | blond | A2 | blond; fair; unlike English, not commonly used of anything other than hair (except beer, see hereunder) — *Er hat blaue Augen und blondes Haar.* | `lib/vocabulary_generated.dart:825` | Bust with short straight blond hair and blue eyes, both taken from the example (blaue Augen, blondes Haar). Only blond hair is shown, although the word can describe other things. |
| [x27522.svg](../assets/vocab/x27522.svg) | lockig | C2 | having curly hair — *Ich habe lockige Haare.* | `lib/vocabulary_generated.dart:7531` | Bust with a full head of brown curls. |
| [x23494.svg](../assets/vocab/x23494.svg) | kahl | B2 | bald, hairless — *Ich habe eine kahle Stelle am Kopf.* | `lib/vocabulary_generated.dart:3503` | Bald crown with a shine highlight and a grey fringe of hair above the ears. The example is a bald patch; the drawing shows a fully bald head. |
| [x20331.svg](../assets/vocab/x20331.svg) | vorne | A1 | at the front — *Ich sitze immer vorne.* | `lib/vocabulary_generated.dart:340` | Three people queue towards a door, marked by a floor arrow. The one nearest the door is coloured and flagged; the other two are grey. |
| [x21097.svg](../assets/vocab/x21097.svg) | mitten | B1 | In the middle. — *Ich war mitten beim Abendessen, als das Telefon klingelte.* | `lib/vocabulary_generated.dart:1106` | The same queue with the middle person marked. The example is temporal (mitten beim Abendessen); the drawing shows the spatial sense. |
| [x20199.svg](../assets/vocab/x20199.svg) | hinten | A1 | behind; in the back — *Jemand packte mich von hinten.* | `lib/vocabulary_generated.dart:208` | The same queue with the last person marked. The example (von hinten) is about direction, not a place in a line. |
| [x10827.svg](../assets/vocab/x10827.svg) | sauber | A1 | clean — *Die Küche ist jetzt wieder sauber.* | `lib/vocabulary_extra.dart:503` | Blue T-shirt with sparkles. Same garment as schmutzig so only the property changes. The examples mention a kitchen and glasses; a glass was tried first and dropped with the schmutzig version. |
| [x10828.svg](../assets/vocab/x10828.svg) | schmutzig | A1 | dirty — *Die Gläser sind noch schmutzig.* | `lib/vocabulary_extra.dart:508` | The same T-shirt with mud stains, drips and spatter. A smeared drinking glass was tried first; at 44px it read as iced coffee. |
| [x25792.svg](../assets/vocab/x25792.svg) | bergauf | C1 | uphill — *Das ist eine Straße, die bergauf geht.* | `lib/vocabulary_generated.dart:5801` | Green slope rising to the right, a walker leaning into it, and an arrow up the slope. |
| [x24070.svg](../assets/vocab/x24070.svg) | bergab | C1 | downhill — *Als ich älter wurde, ging es mit meiner Gesundheit bergab.* | `lib/vocabulary_generated.dart:4079` | Green slope falling to the right, a walker, and an arrow down the slope. Literal sense only; the example uses the figurative one (health going downhill). |
| [x23822.svg](../assets/vocab/x23822.svg) | nebeneinander | C1 | next to each other — *Das alte Ehepaar saß nebeneinander.* | `lib/vocabulary_generated.dart:3831` | Three toy blocks side by side on a floor line. They are the same blocks as übereinander. |
| [x25478.svg](../assets/vocab/x25478.svg) | übereinander | C1 | one above the other — *Er schlug seine Beine übereinander.* | `lib/vocabulary_generated.dart:5487` | The same three blocks stacked. The example (Beine übereinander) is crossed legs; the drawing shows the general "one above the other". |
| [x20428.svg](../assets/vocab/x20428.svg) | traurig | A1 | sadly — *Es stimmt mich traurig, das zu hören.* | `lib/vocabulary_generated.dart:437` | Crying face in the Wut/Angst style: sad brows, closed eyes, a tear on each cheek. The first version was a plain frown, which is what Entschuldigung already shows. |
| [x21905.svg](../assets/vocab/x21905.svg) | frech | B1 | naughty — *Es gibt ein paar freche Jungen in meiner Nachbarschaft.* | `lib/vocabulary_generated.dart:1914` | Winking face with its tongue out, the cheeky-child gesture from the example (freche Jungen). |
| [x21286.svg](../assets/vocab/x21286.svg) | lecker | B1 | well, with pleasure (usually referring to eating and drinking) — *Ich fand nicht, dass es besonders lecker war.* | `lib/vocabulary_generated.dart:1295` | Face with closed happy eyes, licking its upper lip. Only food is shown, though the gloss also covers drink. |
| [x22805.svg](../assets/vocab/x22805.svg) | krumm | B2 | crooked — *Ich habe krumme Zähne.* | `lib/vocabulary_generated.dart:2814` | A nail bent over sideways in a plank, with its flat head at the end. The example is crooked teeth; the nail is the general case. |
| [x22146.svg](../assets/vocab/x22146.svg) | fehlend | B2 | missing — *Wo ist der fehlende Dollar?* | `lib/vocabulary_generated.dart:2155` | Egg carton with five eggs and one empty cup outlined with a dashed egg shape. It shows an absence in a set, not the missing thing itself. |
| [x26001.svg](../assets/vocab/x26001.svg) | zerrissen | C2 | torn, ripped (up) — *Die Wahrheit hat ein schönes Angesicht, aber zerrissene Kleider.* | `lib/vocabulary_generated.dart:6010` | A page torn in two along a jagged line, both halves apart. The example is torn clothes; paper stays readable at card size. |
| [x28862.svg](../assets/vocab/x28862.svg) | vierblättrig | C2 | four-leaved — *Hast du schon mal einen vierblättrigen Klee gefunden?* | `lib/vocabulary_generated.dart:8871` | Clover with four heart-shaped leaves and a stem, matching the example (vierblättriger Klee). The count of leaves is the whole content. |
| [x22039.svg](../assets/vocab/x22039.svg) | außerirdisch | B2 | extraterrestrial — *Ich habe gehört, man hätte ein außerirdisches Artefakt auf dem Mond gefunden.* | `lib/vocabulary_generated.dart:2048` | Green alien head with large dark eyes and antennae: the conventional figure, not a claim about real life beyond Earth. |
| [x28345.svg](../assets/vocab/x28345.svg) | hochhackig | C2 | high-heeled — *Ich mag keine hochhackigen Schuhe.* | `lib/vocabulary_generated.dart:8354` | Red pump with a stiletto heel, from the side. It is a different silhouette from the brown shoe on Schuh. |
| [x28219.svg](../assets/vocab/x28219.svg) | schlammig | C2 | muddy, miry, boggy — *Auf dem Boden waren schlammige Fußspuren.* | `lib/vocabulary_generated.dart:8228` | Yellow rubber boot caked with mud from the sole up, standing in a mud puddle. The example is muddy footprints; a footprint would have been the picture for Fußspur. |
| [x25363.svg](../assets/vocab/x25363.svg) | ungerade | C1 | odd (not divisible by two) — *Eins ist die kleinste ungerade Zahl.* | `lib/vocabulary_generated.dart:5372` | Four dots grouped in two pairs and a fifth, red dot left over. This is how parity is taught with counters; it does not show a numeral. |

## Review

1. **Two sizes.** Every drawing was rendered at 112px and at the 44px card
   size (`python tool/render_svg_audit.py <dir>`), then revised until it read
   at 44px:
   - the first blond hair read as a headband, the second as a hard hat;
   - the first bent nail read as a pipe until its head became a flat cap;
   - the empty egg cup read as a red egg until the dashes turned white on a
     dark hollow.
2. **Nearest neighbours.** Each drawing was also ranked against all 1,594
   existing drawings, in silhouette and in colour, and compared by eye with
   its three nearest (`python tool/svg_neighbours.py`, new in this release).
   That found one real collision: `traurig` was first drawn as a plain
   frowning yellow face, which is `Entschuldigung`, so it now cries on both
   cheeks. Other near neighbours were checked and are distinct: `Perücke`
   (a wig on a stand) beside `lockig`, `Bergsteiger` and `bergsteigen` beside
   the slopes, `Schuh` beside `hochhackig`, `Hemd` beside the T-shirt pair.
   The close scores inside the chip, queue and face families are intended.
3. **Cards declined during the read.** 19 cards were declined, each with its
   reason in `tool/vocab_icons_undrawable.tsv`. The three angry adjectives are
   the face `Wut` already wears. `heiter` is how `Wetter` is drawn.
   `innen`/`außen` are `drinnen`/`draußen`. `östlich` is Osten's compass.
   `hell`/`dunkel` and `leise`/`still` follow the recorded decisions for
   `Dunkelheit` and `Ruhe`. `unterirdisch` was drawn and read as `Höhle`.
   The other seven:
   - `dreckig`, `vorn` and `farbenfroh` would duplicate cards drawn here;
   - `dunkelhaarig` is the dark hair `Kopf` and `Frau` already have;
   - `kariert` reads as `Schachbrett` or `Tischdecke`;
   - `gemütlich` is a mood;
   - the example on `kitzlig` teaches the figurative sense.

## Not drawn, and left open

- **Nationality adjectives, and why.** 25 of them (`italienisch`,
  `schwedisch`, `kanadisch`, …) could each carry a flag, and the deck has no
  country nouns that the flags would collide with. A flag is not a
  caricature. But the project already records nationalities as a class it
  declines to illustrate (`x20529`, `x20834`), so drawing them is a policy
  decision for the maintainer, not something to slip into a drawing batch.
- **Nouns that take the same picture.** `bärtig` is not drawn because a
  bearded face is the picture the noun `Bart` would need. `hochhackig` and
  `kahl` have now taken the pictures that the undrawn nouns `Stöckelschuh`
  and `Glatze` would have needed. If those nouns are ever drawn, the
  adjective and the noun will share one picture.

This review covers these 33 drawings, not the whole library. The limits in
the table belong with any later content review of these cards.
