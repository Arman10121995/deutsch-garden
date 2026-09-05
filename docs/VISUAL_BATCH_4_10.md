# Visual batch 4.10 review

Six original SVGs authored with GPT-5.6 Luna, each with explicit 64×64 dimensions and a matching viewBox. Visual review prompted one revision to improve the initial silhouettes. IDs and senses below were rechecked in the live vocabulary source before revision.

| ID / asset | German | Live English sense | Source | Revised visual / semantic limit |
|---|---|---|---|---|
| [x21271.svg](../assets/vocab/x21271.svg) | die Hütte | hut, cabin, shack, cottage (small house, typically built of light materials rather than stone) | `lib/vocabulary_generated.dart:1280` | Steep A-frame roof above upright wooden plank walls; solid door, glazed window, chimney and foundation establish a dwelling. |
| [x22454.svg](../assets/vocab/x22454.svg) | die Olive | olive (fruit) | `lib/vocabulary_generated.dart:2463` | Oblong green olive with a red pimento in the exposed end and a natural green leaf; one familiar prepared form of the fruit. |
| [x22914.svg](../assets/vocab/x22914.svg) | der Snack | snack (a light meal) | `lib/vocabulary_generated.dart:2923` | Open, crinkled bag with two visible golden crisps and a sealed bottom; crisps are one example of a snack, not the whole category. |
| [x25665.svg](../assets/vocab/x25665.svg) | die Aubergine | aubergine, eggplant (plant, vegetable, herb) | `lib/vocabulary_generated.dart:5674` | Elongated, curved purple body with a bulbous end, green star calyx and short curved stem; depicts the vegetable. |
| [x25999.svg](../assets/vocab/x25999.svg) | die Avocado | avocado (fruit; tree) | `lib/vocabulary_generated.dart:6008` | Pear-shaped cut half, green skin/rim, pale yellow flesh and large brown pit; depicts the fruit, not the tree. |
| [x28407.svg](../assets/vocab/x28407.svg) | das Hammelfleisch | The meat of a wether (castrated ram) used as food, a type of mutton | `lib/vocabulary_generated.dart:8416` | Red chop with a pale rib bone and fat edge on a plate, without gore. Identifies meat/chop; species and animal age cannot be established from this shape alone. |

The six IDs had no direct SVG before this batch. Hütte, Olive, Aubergine and Avocado already have emoji fallbacks. Retaining six follows the original instruction to prefer useful drawings over a numeric target; the category/sense limits above remain for the main reviewer.

Verification: completed one SVG revision pass, then ran `python tool/render_svg_audit.py .preview/svg-4-10` once successfully. Inspected the labelled 112px audit and in-memory reductions at 64px and 44px; no additional preview files were created for those reductions. The door/window and wooden walls, red pimento and green leaf, exposed crisps and flexible bag, purple curved body and green calyx, avocado pit and flesh, and chop/bone/plate remain legible at small size. This is an author visual review, not a learner recognition test; the semantic limits in the table remain.

The rendered audit is a local review artifact under `.preview/svg-4-10/`,
not a release asset; it can be regenerated with the command above.

## Illustrated action scenes

One OpenAI-generated sheet was reviewed and cropped into four bundled scenes.
The source, prompt and export instructions are in `tool/visual_sources/README.md`.

| Card | German | Intended action | Example checked |
|---|---|---|---|
| x10822 | spülen | wash dishes at a sink | Nach dem Essen spüle ich das Geschirr. |
| x10824 | bügeln | iron a shirt | Meine Mutter bügelt die Hemden. |
| x21887 | nähen | sew fabric with needle and thread | Sie fragte mich, ob ich nähen könne. |
| x21462 | pflanzen | plant a seedling in soil | Frühling ist die Jahreszeit, um Bäume zu pflanzen. |

These mappings use exact German lemmas, not category-wide guesses. The new
scenes and SVGs are project assets under MIT; all are available offline.
