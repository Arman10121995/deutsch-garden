# Visual review 4.12

This batch contains nine SVGs authored with GPT-5.6 Luna and visually reviewed.
They use project-authored paths and shapes; no external source or paid image tool was used. Every file
has a 64×64 viewBox and contains no text.

## Requested corrections

| ID / asset | Sense checked in live source | Source | Visual decision and limit |
|---|---|---|---|
| `135.svg` | Nachteil — disadvantage | `lib/vocabulary.dart:141` | Two equal routes point from matching start dots to matching goal dots; the lower route is stopped by a conspicuous block. This is a comparison metaphor, not a literal definition of every disadvantage. |
| `136.svg` | Meinung — opinion | `lib/vocabulary.dart:142` | A person has a speech/thought bubble containing a heart, a subjective preference symbol rather than a factual checkmark. The drawing cannot express a particular opinion or its reasons. |
| `x27536.svg` | Schachbrett — chessboard; example says it has 64 squares | `lib/vocabulary_generated.dart:7545` | Explicit 8×8 alternating squares. It identifies a chessboard but does not depict pieces or a playable position. |

## New drawable actions

The animal drawing for `x22481` (Maulwurf) was removed: this particular card
teaches the figurative "internal spy" sense. It now uses the structural cue;
the old SVG is recoverable in Git history. The exclusion is recorded in
`tool/vocab_icons_undrawable.tsv` to prevent reintroducing the mismatch.

These six exact generated vocabulary entries were checked against their live
English gloss and example. None had a pre-existing direct `assets/vocab/*.svg`
or a named `assets/vocab_generated/*.png` mapping in `lib/vocab_icon.dart`.

| ID / asset | German | Live gloss and example checked | Source | Visual limit |
|---|---|---|---|---|
| `x22667.svg` | falten | to fold — folding clothes | `lib/vocabulary_generated.dart:2676` | Rectangular cloth with one corner folded over and one curved motion arrow; does not specify a particular garment. |
| `x21576.svg` | kleben | to stick — sticking a stamp on an envelope | `lib/vocabulary_generated.dart:1585` | A hand presses a perforated rectangular stamp onto the envelope flap; does not cover every adhesive use. |
| `x21456.svg` | wiegen | to weigh — weighing luggage on scales | `lib/vocabulary_generated.dart:1465` | Suitcase sits on a broad platform above a round dial and needle; no unit or measurement result is implied. |
| `x21144.svg` | schieben | to push/shove — pushing desks to a wall | `lib/vocabulary_generated.dart:1153` | Leaning person makes hand contact with a wheeled crate; does not distinguish push from shove. |
| `x20285.svg` | schneiden | to cut/carve/slice — cutting into slices | `lib/vocabulary_generated.dart:294` | Diagonal knife cuts a loaf with two separated slices on a board; food is only the checked example. |
| `x20898.svg` | ziehen | to pull/drag — pulling someone by the hair | `lib/vocabulary_generated.dart:907` | Person leans back against a taut rope attached to a crate, with force arrow toward the person; it avoids depicting the harmful example literally. |

## Review and limits

The original three assets were rendered before editing. The changed working
set was then rendered with:

`python tool/render_svg_audit.py .preview/svg-4-12`

The labelled contact sheet was inspected visually at the renderer's 112px
preview and the icons remain readable when reduced toward 64px. This revision
was specifically checked for action visibility: knife edge and separated
slices, leaning body and taut rope, platform and dial, pressing hand and
perforated stamp, folded corner, and contacting pushing hand. The action icons
remain illustrative metaphors rather than complete literal scenes; the
per-entry limits above should remain attached to any later content review.

This visual review covers these nine drawings, not the entire illustration
library. See the 4.12.0 changelog for the accompanying speech and casting fixes.
