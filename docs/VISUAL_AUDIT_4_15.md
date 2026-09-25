# Visual audit 4.15.0: the Vibe Mistral batch

The 4.5 release (commit `0c92f8e`) added 486 vocabulary drawings in one
commit, with no author recorded. They came from the workflow described in
`tool/README_SVG_BATCHES.md`, which carries its own Windows paths and
"Completed in This Session" lists, and the maintainer identifies it as Vibe
Mistral's work. This document records the audit of that batch and what
replaced it.

## What the audit found

Every drawing in the library was rendered and read against its card, batch
by batch, using the provenance of the commit that added it. The rest of the
library holds up. The 486 from `0c92f8e` mostly do not.

- **Quality.** About 95% fail at card size:
  - specks a few pixels across;
  - one thin stick-arm template reused for dozens of unrelated words;
  - abstractions drawn as arbitrary shapes, such as a red hexagon for
    *Verantwortung* and a padlock for *Reise*.
- **A whole tier switched off.** The batch drew over every one of the 85
  Tabler line pictograms. `lib/vocab_icon.dart` ranks an authored drawing
  above a line icon, so the animated verb and adjective pictograms have not
  been visible since 4.5. Nothing failed; the tier was simply never shown.
- **Dead drawings.** 29 of those 85, and 5 more, sat on cards that also have
  a generated scene, which outranks both. None of the 90 could ever appear.

## What changed

| | Cards |
|---|---:|
| Removed, so that the higher or intended tier shows again | 90 |
| Redrawn from the thing itself: objects, scenes, spatial and time families | 132 |
| Redrawn as symbolic cues (see below) | 255 |
| Kept: Aufgabe, Projekt, Forschung, Fehler, Problem, schützen, begeistert, and the two 4.12 Codex redraws Nachteil and Meinung | 9 |
| **Total from the batch** | **486** |

`tool/validate_content.py` now fails when a card carries two picture tiers:
a drawing over a line pictogram, or a drawing under a generated scene.
Running it against the pre-4.15 assets reports 114 errors, so the gate is
known to catch the defect rather than assumed to.

## The 255 symbolic cues, and the decision behind them

These are the words the project's own documents call undrawable:

- conjunctions: *und*, *dass*, *obwohl*
- modal verbs: *können*, *müssen*
- discourse adverbs: *allerdings*, *einerseits*
- academic abstractions: *Prämisse*, *Kohärenz*, *Implikation*

The alternative to redrawing them was to remove the drawing and show the
structural word-class tile. The maintainer chose redrawing, as metaphors.

They are memory cues, not definitions. Most are drawn from the card's own
example sentence where one helps:

| Word | Example on the card | Cue |
|---|---|---|
| *obwohl* | *Obwohl die Sonne schien, war es kalt* | sunshine and a shivering figure |
| *trotzdem* | *todmüde … trotzdem nicht einschlafen* | lying awake in bed at night |
| *prüfen* | *Prüfen Sie bitte den Ölstand* | a dipstick under the bonnet |

The rest use widely understood conventions:

- the German mandatory-direction sign for *müssen*
- the green pedestrian light for *dürfen*
- a boomerang for *wieder*
- an iceberg for *Implikation*
- one word tile pointing to both a bench and a coin (*Bank*) for
  *Mehrdeutigkeit*

A weak cue here should be replaced, not defended.

## How they were drawn and reviewed

All 387 new drawings share a small component library written for this
release, so they read as one set. It is modelled on the Codex drawings of
4.12:

- figures with outlined heads and thick limbs, caught mid-action;
- outlined objects;
- red and orange motion marks.

Families keep everything but the meaning still:

| Family | Cards |
|---|---|
| Greetings | *Hallo*, *Tschüss*, *bitte*, *danke* |
| A week strip, filled in proportion | *oft*, *manchmal*, *selten*, *meistens*, *regelmäßig* |
| One floor, one cube, one ball | *neben*, *zwischen*, *hinter*, *vor* |
| Stepping stones | *zuerst*, *dann*, *zuletzt* |
| Question words, each with a badge | *wer*, *was*, *wo*, *wann*, *warum*, *wie*, *welche* |
| A domino row | *Ursache*, *Folge*, *verhindern* |
| Paired adjectives | *billig/teuer*, *bequem/unbequem*, *möglich/unmöglich*, *einfach/schwierig* |

Each drawing was rendered at 112px and at the 44px card size. Each was also
ranked against the whole library by `tool/svg_neighbours.py` and compared by
eye with its nearest matches. That review caught and fixed:

| Card | First drawn as | Problem |
|---|---|---|
| *langweilig* | a yawn | the same open mouth as *Angst* |
| *hauptsächlich* | a pie chart | read as *Hälfte* |
| *im Gegensatz dazu* | a sun and a moon | the same picture as *inzwischen* |
| *politisch* | a dome with a black-red-gold flag | tied a general adjective to one country, which is the flag question below |
| *optimieren* | a gauge | a fifth card on the same gauge template |

Not every weak first draft is listed. Small readability fixes (a hidden
ball, a blob of an arrow, figures whose arms merged into their bodies) were
made during the same passes.

## The rest of the library

The Claude batches hold up. They are the core nouns of 3.x, the noun sweep
of 4.10 and the adjectives of this release. The 12 Codex drawings of 4.10
and 4.12 set the standard used here.

The 250-verb tranche of 4.14.1–4.14.6 is readable but small-scale and plain
next to that standard. It is a candidate for the next pass, not part of this
one.

## Removed (90)

| ID | German | Level | Now shows |
|---|---|---|---|
| x10081 | allein | A1 | animated line pictogram |
| x10063 | alt | A1 | animated line pictogram |
| x10029 | anfangen | A1 | animated line pictogram |
| x10150 | anrufen | A1 | animated line pictogram |
| x10015 | antworten | A1 | generated scene |
| x10010 | arbeiten | A1 | generated scene |
| x10030 | aufhören | A1 | animated line pictogram |
| x10028 | aufstehen | A1 | generated scene |
| x10105 | bestellen | A1 | animated line pictogram |
| x10120 | besuchen | A1 | animated line pictogram |
| x10022 | bezahlen | A1 | generated scene |
| x10128 | bringen | A1 | animated line pictogram |
| x10074 | durstig | A1 | animated line pictogram |
| x10142 | einkaufen | A1 | generated scene |
| x10024 | essen | A1 | generated scene |
| x10019 | fahren | A1 | generated scene |
| x10079 | falsch | A1 | animated line pictogram |
| x10076 | fertig | A1 | animated line pictogram |
| x10154 | finden | A1 | generated scene |
| x10014 | fragen | A1 | generated scene |
| x10045 | früh | A1 | animated line pictogram |
| x10018 | gehen | A1 | generated scene |
| x10055 | geradeaus | A1 | animated line pictogram |
| x10072 | gesund | A1 | generated scene |
| x10058 | groß | A1 | animated line pictogram |
| x10060 | gut | A1 | animated line pictogram |
| x10069 | heiß | A1 | animated line pictogram |
| x10124 | helfen | A1 | generated scene |
| x10041 | heute | A1 | animated line pictogram |
| x10051 | hier | A1 | animated line pictogram |
| x10073 | hungrig | A1 | animated line pictogram |
| x10047 | immer | A1 | animated line pictogram |
| x10043 | jetzt | A1 | animated line pictogram |
| x10068 | kalt | A1 | animated line pictogram |
| x10021 | kaufen | A1 | generated scene |
| x10059 | klein | A1 | animated line pictogram |
| x10026 | kochen | A1 | generated scene |
| x10023 | kosten | A1 | animated line pictogram |
| x10071 | krank | A1 | generated scene |
| x10011 | lernen | A1 | generated scene |
| x10053 | links | A1 | animated line pictogram |
| x10070 | müde | A1 | animated line pictogram |
| x10062 | neu | A1 | animated line pictogram |
| x10050 | nie | A1 | animated line pictogram |
| x10054 | rechts | A1 | animated line pictogram |
| x10078 | richtig | A1 | animated line pictogram |
| x10016 | sagen | A1 | animated line pictogram |
| x10027 | schlafen | A1 | generated scene |
| x10061 | schlecht | A1 | animated line pictogram |
| x10032 | schließen | A1 | generated scene |
| x10065 | schnell | A1 | animated line pictogram |
| x10064 | schön | A1 | animated line pictogram |
| x10012 | sprechen | A1 | generated scene |
| x10046 | spät | A1 | animated line pictogram |
| x10153 | suchen | A1 | generated scene |
| x10121 | treffen | A1 | generated scene |
| x10025 | trinken | A1 | generated scene |
| x10013 | verstehen | A1 | animated line pictogram |
| x10067 | warm | A1 | animated line pictogram |
| x10077 | wichtig | A1 | animated line pictogram |
| x10009 | wohnen | A1 | animated line pictogram |
| x10148 | zahlen | A1 | animated line pictogram |
| x10125 | zeigen | A1 | animated line pictogram |
| x10080 | zusammen | A1 | animated line pictogram |
| x10031 | öffnen | A1 | generated scene |
| x10132 | abfahren | A2 | animated line pictogram |
| x10102 | absagen | A2 | animated line pictogram |
| x10131 | ankommen | A2 | animated line pictogram |
| x10127 | bekommen | A2 | animated line pictogram |
| x10122 | einladen | A2 | animated line pictogram |
| x10107 | erklären | A2 | animated line pictogram |
| x10123 | feiern | A2 | generated scene |
| x10136 | fliegen | A2 | animated line pictogram |
| x10137 | mieten | A2 | animated line pictogram |
| x10115 | planen | A2 | animated line pictogram |
| x10140 | putzen | A2 | generated scene |
| x10135 | reisen | A2 | generated scene |
| x10139 | reparieren | A2 | animated line pictogram |
| x10104 | reservieren | A2 | animated line pictogram |
| x10126 | schicken | A2 | animated line pictogram |
| x10146 | sparen | A2 | animated line pictogram |
| x10151 | telefonieren | A2 | generated scene |
| x10133 | umsteigen | A2 | animated line pictogram |
| x10138 | umziehen | A2 | animated line pictogram |
| x10147 | verdienen | A2 | animated line pictogram |
| x10143 | verkaufen | A2 | animated line pictogram |
| x10117 | versuchen | A2 | animated line pictogram |
| x10152 | warten | A2 | generated scene |
| x10141 | waschen | A2 | generated scene |
| x10149 | überweisen | A2 | animated line pictogram |

## Redrawn from the thing itself (132)

| Asset | German | Level | Gloss | Picture |
|---|---|---|---|---|
| [x10176](../assets/vocab/x10176.svg) | billig | A1 | cheap | a shopping bag and one coin |
| [x10003](../assets/vocab/x10003.svg) | bitte | A1 | please | two hands pressed together |
| [x10004](../assets/vocab/x10004.svg) | danke | A1 | thanks | hand on heart, eyes closed, small hearts |
| [x10186](../assets/vocab/x10186.svg) | dann | A1 | then | the same stones, the middle one marked |
| [x10052](../assets/vocab/x10052.svg) | dort | A1 | there | pointing across to a pinned house in the distance |
| [x10199](../assets/vocab/x10199.svg) | draußen | A1 | outside | the person outside the house, by a tree |
| [x10222](../assets/vocab/x10222.svg) | einfach | A1 | simple | a simple maze with one clear path |
| [125](../assets/vocab/125.svg) | Entscheidung | A1 | decision | fork in the road |
| [x10006](../assets/vocab/x10006.svg) | Entschuldigung | A1 | excuse me / sorry | hand behind the head, sheepish, a sweat drop |
| [x10042](../assets/vocab/x10042.svg) | gestern | A1 | yesterday | three calendar pages, the one before today marked |
| [x10217](../assets/vocab/x10217.svg) | gleich | A1 | same / immediately | the same height |
| [x10001](../assets/vocab/x10001.svg) | Hallo | A1 | hello | a figure waving, smiling |
| [x10007](../assets/vocab/x10007.svg) | heißen | A1 | to be called | a name badge on the chest and in a speech bubble |
| [x10129](../assets/vocab/x10129.svg) | holen | A1 | to fetch | go and fetch from a shelf |
| [x10171](../assets/vocab/x10171.svg) | husten | A1 | to cough | coughing into the elbow |
| [x10224](../assets/vocab/x10224.svg) | interessant | A1 | interesting | person leaning to a framed picture, hand on chin, sparkles |
| [x10008](../assets/vocab/x10008.svg) | kommen | A1 | to come | a host beckons a guest towards the door |
| [x10066](../assets/vocab/x10066.svg) | langsam | A1 | slow | the snail |
| [x10049](../assets/vocab/x10049.svg) | manchmal | A1 | sometimes | a week strip with three days filled |
| [x10096](../assets/vocab/x10096.svg) | mehr | A1 | more | two jars, the second fuller, an up arrow |
| [x10192](../assets/vocab/x10192.svg) | meistens | A1 | mostly | a week strip with six of seven days filled |
| [x10056](../assets/vocab/x10056.svg) | nah | A1 | near | a person right beside the house, a short arrow |
| [x10205](../assets/vocab/x10205.svg) | neben | A1 | next to | a ball next to a cube |
| [x10228](../assets/vocab/x10228.svg) | nervös | A1 | nervous | wide eyes, clenched teeth, sweat drops |
| [x10048](../assets/vocab/x10048.svg) | oft | A1 | often | a week strip with five of seven days filled |
| [x10184](../assets/vocab/x10184.svg) | plötzlich | A1 | suddenly | a jack-in-the-box springing up |
| [096](../assets/vocab/096.svg) | Reise | A1 | trip / journey | map with route and suitcase |
| [x10229](../assets/vocab/x10229.svg) | ruhig | A1 | calm / quiet | meditating figure |
| [103](../assets/vocab/103.svg) | Satz | A1 | sentence | a row of word tiles ending in a full stop |
| [x10223](../assets/vocab/x10223.svg) | schwierig | A1 | difficult | a tangled maze |
| [x10177](../assets/vocab/x10177.svg) | teuer | A1 | expensive | the same bag and a tall stack of coins |
| [x10002](../assets/vocab/x10002.svg) | Tschüss | A1 | bye | a figure walking out of a door, waving back |
| [x10202](../assets/vocab/x10202.svg) | unten | A1 | downstairs / below | the same house, the person downstairs |
| [x10118](../assets/vocab/x10118.svg) | vergessen | A1 | to forget | thought bubble with a dashed missing key |
| [x10094](../assets/vocab/x10094.svg) | viel | A1 | much / a lot | a jar full of marbles |
| [x10090](../assets/vocab/x10090.svg) | wann | A1 | when | a clock, time unknown |
| [x10091](../assets/vocab/x10091.svg) | warum | A1 | why | palms up, a shrug |
| [x10088](../assets/vocab/x10088.svg) | was | A1 | what | a closed box, contents unknown |
| [x10057](../assets/vocab/x10057.svg) | weit | A1 | far | the house small on the horizon, a long arrow |
| [x10093](../assets/vocab/x10093.svg) | welche | A1 | which | three choices, one to pick |
| [x10095](../assets/vocab/x10095.svg) | wenig | A1 | little / few | the same jar with two marbles |
| [x10087](../assets/vocab/x10087.svg) | wer | A1 | who | a person, identity unknown |
| [x10092](../assets/vocab/x10092.svg) | wie | A1 | how | a mechanism, method unknown |
| [x10089](../assets/vocab/x10089.svg) | wo | A1 | where | a place, location unknown |
| [102](../assets/vocab/102.svg) | Wort | A1 | word | one word tile in a speech bubble |
| [x10185](../assets/vocab/x10185.svg) | zuerst | A1 | first | stepping stones across a stream, the first one marked |
| [x10204](../assets/vocab/x10204.svg) | zwischen | A1 | between | a ball between two cubes |
| [x10216](../assets/vocab/x10216.svg) | anders | A2 | different / otherwise | the odd one out |
| [106](../assets/vocab/106.svg) | Aussprache | A2 | pronunciation | open mouth with sound |
| [105](../assets/vocab/105.svg) | Bedeutung | A2 | meaning | a word tile pointing to a picture of a tree |
| [x10178](../assets/vocab/x10178.svg) | bequem | A2 | comfortable | relaxing in an armchair, feet up |
| [x10160](../assets/vocab/x10160.svg) | bestehen | A2 | to pass / consist | exam paper with a big tick |
| [x10200](../assets/vocab/x10200.svg) | drinnen | A2 | inside | the person inside the house |
| [x10106](../assets/vocab/x10106.svg) | empfehlen | A2 | to recommend | showing a book with a star |
| [x10119](../assets/vocab/x10119.svg) | erinnern | A2 | to remember | string tied round a finger |
| [x10109](../assets/vocab/x10109.svg) | erzählen | A2 | to tell / narrate | storyteller with a story bubble |
| [x10180](../assets/vocab/x10180.svg) | freundlich | A2 | friendly | smiling, offering a flower |
| [x10203](../assets/vocab/x10203.svg) | gegenüber | A2 | opposite | two houses facing across a street |
| [x10156](../assets/vocab/x10156.svg) | gewinnen | A2 | to win | top of the podium |
| [104](../assets/vocab/104.svg) | Grammatik | A2 | grammar | word tiles in the article colours, joined in a sentence tree |
| [x10206](../assets/vocab/x10206.svg) | hinter | A2 | behind | a ball peeking out behind a cube |
| [x10113](../assets/vocab/x10113.svg) | hoffen | A2 | to hope | crossed fingers |
| [x10163](../assets/vocab/x10163.svg) | kündigen | A2 | to resign / cancel | leaving with a box of belongings |
| [x10225](../assets/vocab/x10225.svg) | langweilig | A2 | boring | half-lidded eyes, flat mouth, chin propped on a hand |
| [x10219](../assets/vocab/x10219.svg) | möglich | A2 | possible | a round peg over a round hole, a green tick |
| [x10201](../assets/vocab/x10201.svg) | oben | A2 | upstairs / above | a two-storey house, the person upstairs |
| [x10182](../assets/vocab/x10182.svg) | pünktlich | A2 | punctual | a clock at twelve with a green tick |
| [x10336](../assets/vocab/x10336.svg) | regelmäßig | A2 | regularly | a week strip with every other day filled |
| [084](../assets/vocab/084.svg) | Schmerz | A2 | pain | headache |
| [x10193](../assets/vocab/x10193.svg) | selten | A2 | rarely | a week strip with one day filled |
| [x10169](../assets/vocab/x10169.svg) | sich ausruhen | A2 | to rest | deck chair |
| [x10168](../assets/vocab/x10168.svg) | sich beeilen | A2 | to hurry | running late |
| [x10162](../assets/vocab/x10162.svg) | sich bewerben | A2 | to apply | handing a CV across a desk |
| [x10165](../assets/vocab/x10165.svg) | sich freuen | A2 | to be pleased / look forward | jumping for joy |
| [x10144](../assets/vocab/x10144.svg) | umtauschen | A2 | to exchange | two shirts swapped |
| [x10179](../assets/vocab/x10179.svg) | unbequem | A2 | uncomfortable | perched on a hard stool, grimacing |
| [x10181](../assets/vocab/x10181.svg) | unfreundlich | A2 | unfriendly | arms crossed, scowling, a grey cloud |
| [x10220](../assets/vocab/x10220.svg) | unmöglich | A2 | impossible | a square peg over a round hole, a red cross |
| [x10263](../assets/vocab/x10263.svg) | unterschreiben | A2 | to sign | signing on the line |
| [x10257](../assets/vocab/x10257.svg) | unterstützen | A2 | to support | a leg-up over a wall |
| [x10172](../assets/vocab/x10172.svg) | untersuchen | A2 | to examine | doctor listening to a patient |
| [x10198](../assets/vocab/x10198.svg) | unterwegs | A2 | on the way | a car on the road between a house and a pin |
| [x10227](../assets/vocab/x10227.svg) | unzufrieden | A2 | dissatisfied | a sour face with a red cross badge |
| [x10101](../assets/vocab/x10101.svg) | vereinbaren | A2 | to arrange | a circled date above a handshake |
| [x10155](../assets/vocab/x10155.svg) | verlieren | A2 | to lose | wallet slipping out of a pocket |
| [x10134](../assets/vocab/x10134.svg) | verpassen | A2 | to miss | running after the leaving bus |
| [x10103](../assets/vocab/x10103.svg) | verschieben | A2 | to postpone | calendar event moved later |
| [x10207](../assets/vocab/x10207.svg) | vor | A2 | in front of / before | a ball in front of a cube |
| [x10170](../assets/vocab/x10170.svg) | weh tun | A2 | to hurt | holding a hurt knee |
| [x10226](../assets/vocab/x10226.svg) | zufrieden | A2 | satisfied | a content face with a green tick badge |
| [x10188](../assets/vocab/x10188.svg) | zuletzt | A2 | last / finally | the same stones, the last one marked |
| [x10271](../assets/vocab/x10271.svg) | übernehmen | A2 | to take over | relay baton handover |
| [x10230](../assets/vocab/x10230.svg) | überrascht | A2 | surprised | person with hands up, gift popping |
| [108](../assets/vocab/108.svg) | Übung | A2 | exercise / practice | worksheet with repeated rows |
| [x10245](../assets/vocab/x10245.svg) | ablehnen | B1 | to reject | a raised palm refuses an offer |
| [x10262](../assets/vocab/x10262.svg) | ausfüllen | B1 | to fill in | ticking boxes on a form |
| [x10346](../assets/vocab/x10346.svg) | besorgt | B1 | worried | a storm in the thought bubble |
| [x10264](../assets/vocab/x10264.svg) | bestätigen | B1 | to confirm | a stamp with a tick |
| [x10277](../assets/vocab/x10277.svg) | bewerten | B1 | to evaluate | star rating |
| [x10240](../assets/vocab/x10240.svg) | diskutieren | B1 | to discuss | two people, overlapping bubbles |
| [x10344](../assets/vocab/x10344.svg) | enttäuscht | B1 | disappointed | looking down at a deflated balloon |
| [128](../assets/vocab/128.svg) | Entwicklung | B1 | development | seed, sprout, plant |
| [x10254](../assets/vocab/x10254.svg) | erhöhen | B1 | to increase | rising bars with a green up arrow |
| [153](../assets/vocab/153.svg) | Folge | B1 | consequence | the last domino of the row falls |
| [143](../assets/vocab/143.svg) | Fortschritt | B1 | progress | climbing rising steps to a flag |
| [x10297](../assets/vocab/x10297.svg) | nachhaltig | B1 | sustainable | a leaf inside a cycle |
| [x10267](../assets/vocab/x10267.svg) | organisieren | B1 | to organize | a board of notes in columns |
| [x10276](../assets/vocab/x10276.svg) | recherchieren | B1 | to research | searching on a laptop |
| [x10255](../assets/vocab/x10255.svg) | senken | B1 | to lower | falling bars with a red down arrow |
| [x10260](../assets/vocab/x10260.svg) | sich beschweren | B1 | to complain | angry at the counter |
| [x10274](../assets/vocab/x10274.svg) | sich konzentrieren | B1 | to concentrate | eyes fixed on one page |
| [x10347](../assets/vocab/x10347.svg) | stolz | B1 | proud | chest out, hands on hips |
| [x10256](../assets/vocab/x10256.svg) | teilnehmen | B1 | to participate | one more person joins the group, a plus |
| [133](../assets/vocab/133.svg) | Umgebung | B1 | environment / surroundings | a house and what surrounds it |
| [x10238](../assets/vocab/x10238.svg) | vergleichen | B1 | to compare | two fruits side by side |
| [x10249](../assets/vocab/x10249.svg) | verhindern | B1 | to prevent | a hand stops the dominoes, the rest stand |
| [x10247](../assets/vocab/x10247.svg) | vermeiden | B1 | to avoid | walking round a puddle |
| [141](../assets/vocab/141.svg) | Versicherung | B1 | insurance | umbrella over a house |
| [x10251](../assets/vocab/x10251.svg) | verändern | B1 | to change | a square becomes a circle |
| [x10350](../assets/vocab/x10350.svg) | vorsichtig | B1 | careful | tiptoeing with a stack of plates |
| [134](../assets/vocab/134.svg) | Vorteil | B1 | advantage | the Codex Nachteil lanes, with the top lane ahead |
| [x10289](../assets/vocab/x10289.svg) | warnen | B1 | to warn | holding up a warning sign |
| [x10237](../assets/vocab/x10237.svg) | widersprechen | B1 | to contradict | a reply bubble in red with a cross |
| [x10239](../assets/vocab/x10239.svg) | zusammenfassen | B1 | to summarize | long text through a funnel into a short note |
| [x10236](../assets/vocab/x10236.svg) | zustimmen | B1 | to agree | a reply bubble in green with a tick |
| [144](../assets/vocab/144.svg) | Auswirkung | B2 | impact / effect | a stone makes ripples |
| [x10373](../assets/vocab/x10373.svg) | beitragen zu | B2 | to contribute to | many hands, one jar |
| [145](../assets/vocab/145.svg) | Herausforderung | B2 | challenge | clearing a high hurdle |
| [x10387](../assets/vocab/x10387.svg) | priorisieren | B2 | to prioritize | flag the item and move it to the top |
| [152](../assets/vocab/152.svg) | Ursache | B2 | cause | a finger tips the first domino |
| [159](../assets/vocab/159.svg) | Vereinbarung | B2 | agreement | a signed agreement |
| [190](../assets/vocab/190.svg) | Wechselwirkung | C2 | interaction | two gears turning each other |

## Redrawn as symbolic cues (255)

| Asset | German | Level | Gloss | Cue |
|---|---|---|---|---|
| [x10083](../assets/vocab/x10083.svg) | aber | A1 | but | sunshine, but a rain cloud on the other side |
| [x10097](../assets/vocab/x10097.svg) | alles | A1 | everything | an overflowing box |
| [x10082](../assets/vocab/x10082.svg) | auch | A1 | also | me too |
| [x10318](../assets/vocab/x10318.svg) | besonders | A1 | especially | the gold star among grey ones |
| [x10020](../assets/vocab/x10020.svg) | bleiben | A1 | to stay | stay on the spot |
| [x10033](../assets/vocab/x10033.svg) | brauchen | A1 | to need | the fuel gauge is on empty |
| [x10187](../assets/vocab/x10187.svg) | danach | A1 | after that | first a meal, after that bed |
| [x10212](../assets/vocab/x10212.svg) | dass | A1 | that | a statement inside a statement |
| [x10040](../assets/vocab/x10040.svg) | dürfen | A1 | may / to be allowed | the pedestrian light is green |
| [x10075](../assets/vocab/x10075.svg) | frei | A1 | free | a day off at the beach |
| [x10005](../assets/vocab/x10005.svg) | gern | A1 | gladly | happily carrying a box, heart above |
| [x10034](../assets/vocab/x10034.svg) | haben | A1 | to have | holding one's own box, with a tick |
| [x10099](../assets/vocab/x10099.svg) | jemand | A1 | someone | a silhouette behind the window |
| [x10036](../assets/vocab/x10036.svg) | können | A1 | can / to be able | lifting the barbell easily |
| [x10196](../assets/vocab/x10196.svg) | leider | A1 | unfortunately | regret over a broken plate |
| [x10017](../assets/vocab/x10017.svg) | machen | A1 | to do / make | hammering a birdhouse together |
| [x10111](../assets/vocab/x10111.svg) | meinen | A1 | to mean / think | pointing to oneself, one option ticked in the bubble |
| [x10130](../assets/vocab/x10130.svg) | mitnehmen | A1 | to take along | leaving the house with an umbrella taken from the stand |
| [x10039](../assets/vocab/x10039.svg) | möchten | A1 | would like | politely picturing a coffee and cake |
| [x10037](../assets/vocab/x10037.svg) | müssen | A1 | must / to have to | the blue mandatory-direction sign |
| [x10195](../assets/vocab/x10195.svg) | natürlich | A1 | of course / naturally | a confident nod |
| [x10098](../assets/vocab/x10098.svg) | nichts | A1 | nothing | two empty palms |
| [x10100](../assets/vocab/x10100.svg) | niemand | A1 | nobody | nobody in the car |
| [x10190](../assets/vocab/x10190.svg) | noch | A1 | still / yet | a running hourglass with dots |
| [x10084](../assets/vocab/x10084.svg) | oder | A1 | or | a tossed coin |
| [x10189](../assets/vocab/x10189.svg) | schon | A1 | already | the hourglass |
| [x10035](../assets/vocab/x10035.svg) | sein | A1 | to be | pointing to oneself, glowing |
| [x10209](../assets/vocab/x10209.svg) | seit | A1 | since | a span on a timeline |
| [x10044](../assets/vocab/x10044.svg) | später | A1 | later | the clock hand moves on |
| [x10085](../assets/vocab/x10085.svg) | und | A1 | and | salt and pepper |
| [x10183](../assets/vocab/x10183.svg) | ungefähr | A1 | approximately | close to the centre, not on it |
| [x10194](../assets/vocab/x10194.svg) | vielleicht | A1 | perhaps | pulling daisy petals |
| [x10086](../assets/vocab/x10086.svg) | weil | A1 | because | watered, therefore growing |
| [x10213](../assets/vocab/x10213.svg) | wenn | A1 | if / when | if it rains, the umbrella opens |
| [x10191](../assets/vocab/x10191.svg) | wieder | A1 | again | the boomerang comes back |
| [x10038](../assets/vocab/x10038.svg) | wollen | A1 | to want | reaching up for a star |
| [x10114](../assets/vocab/x10114.svg) | wünschen | A1 | to wish | looking up at a shooting star |
| [x10161](../assets/vocab/x10161.svg) | arbeiten an | A2 | to work on | a document with a progress bar and a pencil |
| [x10320](../assets/vocab/x10320.svg) | außerdem | A2 | besides / moreover | and one more on the list |
| [x10110](../assets/vocab/x10110.svg) | berichten | A2 | to report | a reporter with a microphone and a camera |
| [x10233](../assets/vocab/x10233.svg) | beruflich | A2 | professional / work-related | suit, briefcase, plane |
| [x10108](../assets/vocab/x10108.svg) | beschreiben | A2 | to describe | hands showing a size, a bubble with a house |
| [x10174](../assets/vocab/x10174.svg) | besser | A2 | better | a rain cloud turning into sunshine |
| [x10210](../assets/vocab/x10210.svg) | bis | A2 | until | a span on a timeline ending at a red flag |
| [x10324](../assets/vocab/x10324.svg) | damit | A2 | so that / with it | switching on the lamp in order to read |
| [x10214](../assets/vocab/x10214.svg) | deshalb | A2 | therefore | yawning, therefore bed |
| [x10197](../assets/vocab/x10197.svg) | eigentlich | A2 | actually | the big box is actually light |
| [x10116](../assets/vocab/x10116.svg) | entscheiden | A2 | to decide | a lever switching between two lamps |
| [129](../assets/vocab/129.svg) | Erklärung | A2 | explanation | pointing at a diagram on the board |
| [x10334](../assets/vocab/x10334.svg) | früher | A2 | formerly | the old photo |
| [x10305](../assets/vocab/x10305.svg) | gemeinsam | A2 | joint / together | roped together up the mountain |
| [x10112](../assets/vocab/x10112.svg) | glauben | A2 | to believe | a listener with a ticked thought while the other speaks |
| [x10232](../assets/vocab/x10232.svg) | ledig | A2 | single | alone on the bench |
| [x10221](../assets/vocab/x10221.svg) | nötig | A2 | necessary | the things you cannot leave without |
| [x10211](../assets/vocab/x10211.svg) | obwohl | A2 | although | the sun is out, and she is freezing |
| [x10145](../assets/vocab/x10145.svg) | passen | A2 | to fit / suit | a sweater fitting into the suitcase, a tick |
| [x10234](../assets/vocab/x10234.svg) | privat | A2 | private | do not disturb |
| [x10159](../assets/vocab/x10159.svg) | prüfen | A2 | to check / examine | checking the dipstick under the car bonnet |
| [x10175](../assets/vocab/x10175.svg) | schlimmer | A2 | worse | a cloud turning into a storm cloud |
| [x10166](../assets/vocab/x10166.svg) | sich fühlen | A2 | to feel | a mood scale of three faces, the happy one marked |
| [x10164](../assets/vocab/x10164.svg) | sich interessieren | A2 | to be interested | a thought bubble with a telescope and a heart |
| [x10167](../assets/vocab/x10167.svg) | sich treffen | A2 | to meet up | two people meeting at a pin, a clock |
| [x10158](../assets/vocab/x10158.svg) | studieren | A2 | to study | a student in a mortarboard at a desk with books |
| [x10215](../assets/vocab/x10215.svg) | trotzdem | A2 | nevertheless | exhausted, and still wide awake |
| [x10231](../assets/vocab/x10231.svg) | verheiratet | A2 | married | a couple with rings |
| [x10173](../assets/vocab/x10173.svg) | verschreiben | A2 | to prescribe | a prescription pad and a pill bottle |
| [x10208](../assets/vocab/x10208.svg) | während | A2 | during / while | reading while listening to music |
| [x10218](../assets/vocab/x10218.svg) | ähnlich | A2 | similar | two bikes, nearly the same |
| [x10157](../assets/vocab/x10157.svg) | üben | A2 | to practise | hands on a piano with notes |
| [x10280](../assets/vocab/x10280.svg) | abhängen von | B1 | to depend on | the plant needs sun and water |
| [x10246](../assets/vocab/x10246.svg) | akzeptieren | B1 | to accept | receiving what is offered |
| [x10321](../assets/vocab/x10321.svg) | allerdings | B1 | however | good, but the price |
| [x10338](../assets/vocab/x10338.svg) | allmählich | B1 | gradually | little by little |
| [x10330](../assets/vocab/x10330.svg) | andererseits | B1 | on the other hand | two hands, the right one marked |
| [x10342](../assets/vocab/x10342.svg) | angenehm | B1 | pleasant | a contented face in mild sunshine and a breeze |
| [x10313](../assets/vocab/x10313.svg) | arbeitslos | B1 | unemployed | the empty desk and the job search |
| [x10261](../assets/vocab/x10261.svg) | beantragen | B1 | to apply for / request | handing in the form at the counter |
| [x10292](../assets/vocab/x10292.svg) | beeinflussen | B1 | to influence | pulling the strings |
| [x10235](../assets/vocab/x10235.svg) | begründen | B1 | to justify | the claim stands on its reasons |
| [x10294](../assets/vocab/x10294.svg) | behandeln | B1 | to treat / deal with | bandaging the arm |
| [x10241](../assets/vocab/x10241.svg) | behaupten | B1 | to claim | through a megaphone |
| [x10290](../assets/vocab/x10290.svg) | beraten | B1 | to advise | the adviser shows the options |
| [x10281](../assets/vocab/x10281.svg) | bestehen aus | B1 | to consist of | the sandwich, taken apart into its layers |
| [x10243](../assets/vocab/x10243.svg) | betonen | B1 | to emphasize | underlined twice |
| [x10278](../assets/vocab/x10278.svg) | beurteilen | B1 | to assess | the judges' scores |
| [142](../assets/vocab/142.svg) | Bewerbung | B1 | application | the CV going into the envelope |
| [131](../assets/vocab/131.svg) | Beziehung | B1 | relationship | two people, one link |
| [x10332](../assets/vocab/x10332.svg) | bisher | B1 | so far | the way up to now |
| [x10323](../assets/vocab/x10323.svg) | dadurch | B1 | thereby | turning the key opens the door |
| [x10322](../assets/vocab/x10322.svg) | daher | B1 | therefore | the sun, and so the ice melts |
| [x10269](../assets/vocab/x10269.svg) | durchführen | B1 | to carry out | running the experiment |
| [x10329](../assets/vocab/x10329.svg) | einerseits | B1 | on the one hand | on the one hand, on the other |
| [x10250](../assets/vocab/x10250.svg) | entwickeln | B1 | to develop | sketching the rocket |
| [x10287](../assets/vocab/x10287.svg) | erfahren | B1 | to find out / experience | the letter with the news |
| [124](../assets/vocab/124.svg) | Erfahrung | B1 | experience | a long road walked, with stars collected on the way |
| [x10311](../assets/vocab/x10311.svg) | erfolgreich | B1 | successful | taking off |
| [x10270](../assets/vocab/x10270.svg) | erledigen | B1 | to complete / deal with | every item crossed off |
| [x10248](../assets/vocab/x10248.svg) | ermöglichen | B1 | to enable | the ramp beside the steps |
| [x10242](../assets/vocab/x10242.svg) | erwähnen | B1 | to mention | a small thing mentioned in passing |
| [x10309](../assets/vocab/x10309.svg) | geeignet | B1 | suitable | the right boot for the mountain |
| [x10282](../assets/vocab/x10282.svg) | gehören zu | B1 | to belong to | joining the matching set |
| [132](../assets/vocab/132.svg) | Gewohnheit | B1 | habit | the same book every day |
| [x10319](../assets/vocab/x10319.svg) | hauptsächlich | B1 | mainly | a grid of dots, mostly one colour |
| [x10337](../assets/vocab/x10337.svg) | häufig | B1 | frequently | storm after storm |
| [x10328](../assets/vocab/x10328.svg) | im Gegensatz dazu | B1 | in contrast | an unclear study against a clear one |
| [x10304](../assets/vocab/x10304.svg) | international | B1 | international | planes between countries |
| [x10331](../assets/vocab/x10331.svg) | inzwischen | B1 | meanwhile | while waiting, night has fallen |
| [x10302](../assets/vocab/x10302.svg) | kulturell | B1 | cultural | masks, music and a brush |
| [x10333](../assets/vocab/x10333.svg) | künftig | B1 | in future | the road to the future |
| [x10288](../assets/vocab/x10288.svg) | mitteilen | B1 | to inform / communicate | telling someone the news |
| [x10349](../assets/vocab/x10349.svg) | mutig | B1 | brave | stepping off the high board |
| [126](../assets/vocab/126.svg) | Möglichkeit | B1 | possibility | three doors, one opening onto light |
| [x10308](../assets/vocab/x10308.svg) | notwendig | B1 | necessary | the plant needs water now |
| [x10316](../assets/vocab/x10316.svg) | offensichtlich | B1 | obvious / obviously | under the spotlight |
| [x10348](../assets/vocab/x10348.svg) | peinlich | B1 | embarrassing | the facepalm |
| [x10300](../assets/vocab/x10300.svg) | politisch | B1 | political | the parliament with its dome |
| [x10335](../assets/vocab/x10335.svg) | rechtzeitig | B1 | in time | through the doors just in time |
| [x10253](../assets/vocab/x10253.svg) | reduzieren | B1 | to reduce | cutting the stack down |
| [x10303](../assets/vocab/x10303.svg) | regional | B1 | regional | one region of the map |
| [x10293](../assets/vocab/x10293.svg) | respektieren | B1 | to respect | bowing to each other |
| [x10339](../assets/vocab/x10339.svg) | schließlich | B1 | finally | breaking the tape at last |
| [x10312](../assets/vocab/x10312.svg) | selbstständig | B1 | independent / self-employed | your own shop, your own key |
| [x10258](../assets/vocab/x10258.svg) | sich engagieren | B1 | to get involved | volunteering, picking up litter |
| [x10283](../assets/vocab/x10283.svg) | sich entscheiden für | B1 | to decide for | taking one card out of three |
| [x10279](../assets/vocab/x10279.svg) | sich erinnern an | B1 | to remember | the photo brings it back |
| [x10284](../assets/vocab/x10284.svg) | sich gewöhnen an | B1 | to get used to | day by day, it gets easier |
| [x10286](../assets/vocab/x10286.svg) | sich informieren über | B1 | to inform oneself about | reading the forecast before the trip |
| [x10259](../assets/vocab/x10259.svg) | sich kümmern | B1 | to take care | fixing the leak straight away |
| [x10285](../assets/vocab/x10285.svg) | sich verlassen auf | B1 | to rely on | the trust fall |
| [x10275](../assets/vocab/x10275.svg) | sich vorbereiten | B1 | to prepare oneself | studying for the circled date |
| [x10299](../assets/vocab/x10299.svg) | sozial | B1 | social | everyone in the circle |
| [x10325](../assets/vocab/x10325.svg) | stattdessen | B1 | instead | the bike instead of the bus |
| [x10317](../assets/vocab/x10317.svg) | tatsächlich | B1 | actually / indeed | the real thing, confirmed under the lens |
| [137](../assets/vocab/137.svg) | Teilnahme | B1 | participation | the participant's badge |
| [x10296](../assets/vocab/x10296.svg) | umweltfreundlich | B1 | environmentally friendly | an electric car with a leaf |
| [x10343](../assets/vocab/x10343.svg) | unangenehm | B1 | unpleasant | holding the nose against a smell |
| [x10340](../assets/vocab/x10340.svg) | ungewöhnlich | B1 | unusual | a cactus in the snow |
| [130](../assets/vocab/130.svg) | Unterschied | B1 | difference | spot the difference |
| [x10306](../assets/vocab/x10306.svg) | unterschiedlich | B1 | different | dressed differently |
| [139](../assets/vocab/139.svg) | Unterstützung | B1 | support | a plant tied to its stake |
| [x10315](../assets/vocab/x10315.svg) | unwahrscheinlich | B1 | unlikely | the likelihood dial low, a red cross |
| [140](../assets/vocab/140.svg) | Veranstaltung | B1 | event | the event tent with bunting |
| [x10273](../assets/vocab/x10273.svg) | verantworten | B1 | to be responsible for | the captain at the wheel |
| [x10310](../assets/vocab/x10310.svg) | verantwortlich | B1 | responsible | owning up to the spill |
| [127](../assets/vocab/127.svg) | Verantwortung | B1 | responsibility | holding others in your hands |
| [x10252](../assets/vocab/x10252.svg) | verbessern | B1 | to improve | from a cross to a tick |
| [x10307](../assets/vocab/x10307.svg) | verfügbar | B1 | available | in stock on the shelf |
| [x10265](../assets/vocab/x10265.svg) | verlängern | B1 | to extend | the stay, extended |
| [x10266](../assets/vocab/x10266.svg) | versichern | B1 | to insure / assure | I promise you |
| [x10272](../assets/vocab/x10272.svg) | vertreten | B1 | to represent | stepping into someone's place |
| [138](../assets/vocab/138.svg) | Voraussetzung | B1 | requirement / prerequisite | the key comes first |
| [x10268](../assets/vocab/x10268.svg) | vorbereiten | B1 | to prepare | chopping before cooking |
| [x10244](../assets/vocab/x10244.svg) | vorschlagen | B1 | to suggest | offering an idea |
| [x10314](../assets/vocab/x10314.svg) | wahrscheinlich | B1 | probably / likely | the likelihood dial |
| [x10301](../assets/vocab/x10301.svg) | wirtschaftlich | B1 | economic | industry, money and growth |
| [x10326](../assets/vocab/x10326.svg) | währenddessen | B1 | meanwhile | meanwhile, two things at once |
| [x10327](../assets/vocab/x10327.svg) | zum Beispiel | B1 | for example | one taken out of the basket |
| [x10351](../assets/vocab/x10351.svg) | zuverlässig | B1 | reliable | the parcel arrives, whatever the weather |
| [x10298](../assets/vocab/x10298.svg) | öffentlich | B1 | public | speaking in front of the crowd |
| [x10291](../assets/vocab/x10291.svg) | überzeugen | B1 | to convince | changing someone's mind |
| [x10341](../assets/vocab/x10341.svg) | üblich | B1 | usual | a bell curve with its middle marked |
| [x10352](../assets/vocab/x10352.svg) | analysieren | B2 | to analyse | a slice pulled out and examined |
| [150](../assets/vocab/150.svg) | Anforderung | B2 | requirement | the bar set high |
| [x10362](../assets/vocab/x10362.svg) | argumentieren | B2 | to argue | building the case point by point |
| [155](../assets/vocab/155.svg) | Behauptung | B2 | claim | standing on a box, claiming |
| [156](../assets/vocab/156.svg) | Beleg | B2 | evidence / proof | sealed in an evidence bag |
| [x10357](../assets/vocab/x10357.svg) | belegen | B2 | to substantiate | the evidence clipped to the claim |
| [x10360](../assets/vocab/x10360.svg) | berücksichtigen | B2 | to take into account | keeping one more point in mind |
| [160](../assets/vocab/160.svg) | Beschwerde | B2 | complaint | the complaint letter with an angry stamp |
| [x10371](../assets/vocab/x10371.svg) | bewirken | B2 | to bring about | the lever moves the rock |
| [x10368](../assets/vocab/x10368.svg) | darstellen | B2 | to present / depict | playing the king on stage |
| [x10386](../assets/vocab/x10386.svg) | delegieren | B2 | to delegate | handing out the tasks |
| [x10359](../assets/vocab/x10359.svg) | differenzieren | B2 | to differentiate | telling two similar leaves apart |
| [x10354](../assets/vocab/x10354.svg) | einschätzen | B2 | to assess / estimate | guessing how many are in the jar |
| [165](../assets/vocab/165.svg) | Einschätzung | B2 | assessment | judging on a slider |
| [x10392](../assets/vocab/x10392.svg) | erfassen | B2 | to capture / record | scanning it into the record |
| [x10393](../assets/vocab/x10393.svg) | erheben | B2 | to collect / raise | collecting from everyone into the bag |
| [x10363](../assets/vocab/x10363.svg) | erörtern | B2 | to discuss in depth | talking it through around the table |
| [x10389](../assets/vocab/x10389.svg) | festlegen | B2 | to determine | pinning the time down |
| [x10390](../assets/vocab/x10390.svg) | feststellen | B2 | to determine / establish | counting heads on the clipboard |
| [x10364](../assets/vocab/x10364.svg) | formulieren | B2 | to formulate | crossing out and finding the better word |
| [147](../assets/vocab/147.svg) | Fähigkeit | B2 | ability / skill | juggling |
| [x10382](../assets/vocab/x10382.svg) | gewährleisten | B2 | to ensure | the safety net |
| [x10361](../assets/vocab/x10361.svg) | hinterfragen | B2 | to question critically | looking hard at what was said |
| [x10353](../assets/vocab/x10353.svg) | interpretieren | B2 | to interpret | the same cloud, two readings |
| [148](../assets/vocab/148.svg) | Kenntnis | B2 | knowledge / proficiency | a book inside the head |
| [x10369](../assets/vocab/x10369.svg) | kennzeichnen | B2 | to characterize | labelling the boxes |
| [x10385](../assets/vocab/x10385.svg) | koordinieren | B2 | to coordinate | the conductor |
| [161](../assets/vocab/161.svg) | Leistung | B2 | performance / achievement | the needle at full power |
| [146](../assets/vocab/146.svg) | Maßnahme | B2 | measure / action | the toolbox |
| [x10356](../assets/vocab/x10356.svg) | nachweisen | B2 | to demonstrate / prove | the test comes back positive |
| [x10384](../assets/vocab/x10384.svg) | optimieren | B2 | to optimize | fine-tuning every slider |
| [x10365](../assets/vocab/x10365.svg) | präzisieren | B2 | to specify | bringing it into focus |
| [158](../assets/vocab/158.svg) | Rückmeldung | B2 | feedback | the feedback card |
| [157](../assets/vocab/157.svg) | Rücksicht | B2 | consideration | holding the door for someone |
| [x10355](../assets/vocab/x10355.svg) | schlussfolgern | B2 | to conclude | following the clues to the answer |
| [x10379](../assets/vocab/x10379.svg) | sich auseinandersetzen mit | B2 | to engage critically with | pushing against the big question |
| [x10376](../assets/vocab/x10376.svg) | sich auswirken auf | B2 | to affect | warmer, and the ice shrinks |
| [x10378](../assets/vocab/x10378.svg) | sich befassen mit | B2 | to deal with | untangling the knot |
| [x10377](../assets/vocab/x10377.svg) | sich beziehen auf | B2 | to refer to | see the note |
| [x10380](../assets/vocab/x10380.svg) | sich eignen für | B2 | to be suitable for | the right book for a beginner |
| [x10375](../assets/vocab/x10375.svg) | sich ergeben aus | B2 | to result from | two and two make four |
| [x10381](../assets/vocab/x10381.svg) | sich unterscheiden von | B2 | to differ from | stripes versus dots |
| [174](../assets/vocab/174.svg) | Stellungnahme | B2 | statement / opinion | a statement at the microphones |
| [x10383](../assets/vocab/x10383.svg) | umsetzen | B2 | to implement | from idea to finished thing |
| [x10366](../assets/vocab/x10366.svg) | verdeutlichen | B2 | to clarify | shining a light on the diagram |
| [x10388](../assets/vocab/x10388.svg) | verhandeln | B2 | to negotiate | haggling over the price |
| [x10367](../assets/vocab/x10367.svg) | vermitteln | B2 | to convey | the go-between |
| [x10372](../assets/vocab/x10372.svg) | verursachen | B2 | to cause | the ball that broke the window |
| [151](../assets/vocab/151.svg) | Veränderung | B2 | change | a leaf changes colour |
| [x10370](../assets/vocab/x10370.svg) | voraussetzen | B2 | to presuppose | book one before book two |
| [x10358](../assets/vocab/x10358.svg) | widerlegen | B2 | to refute | the data knocks out the claim |
| [163](../assets/vocab/163.svg) | Widerspruch | B2 | contradiction / objection | two arrows collide |
| [x10374](../assets/vocab/x10374.svg) | zurückzuführen sein auf | B2 | to be attributable to | the river goes back to its spring |
| [149](../assets/vocab/149.svg) | Zusammenarbeit | B2 | collaboration | rowing together |
| [154](../assets/vocab/154.svg) | Zusammenhang | B2 | connection / correlation | connected points |
| [162](../assets/vocab/162.svg) | Zustimmung | B2 | approval / consent | hands up, all agreed |
| [x10391](../assets/vocab/x10391.svg) | überprüfen | B2 | to verify / review | checking item by item |
| [166](../assets/vocab/166.svg) | Abwägung | C1 | weighing / balancing | weighing in two hands |
| [183](../assets/vocab/183.svg) | Angemessenheit | C1 | appropriateness | the size that is just right |
| [173](../assets/vocab/173.svg) | Auseinandersetzung | C1 | debate / engagement | a debate at two lecterns |
| [178](../assets/vocab/178.svg) | Aussagekraft | C1 | informative value / validity | a study with a strong signal |
| [180](../assets/vocab/180.svg) | Folgerung | C1 | inference / conclusion | two facts lead to a conclusion |
| [169](../assets/vocab/169.svg) | Glaubwürdigkeit | C1 | credibility | a sealed certificate |
| [179](../assets/vocab/179.svg) | Herangehensweise | C1 | approach | several ways to approach the same goal |
| [168](../assets/vocab/168.svg) | Nachhaltigkeit | C1 | sustainability | wind, sun and a green leaf |
| [181](../assets/vocab/181.svg) | Priorität | C1 | priority | the top sheet comes first |
| [176](../assets/vocab/176.svg) | Rahmenbedingung | C1 | framework condition | the frame that conditions growth |
| [175](../assets/vocab/175.svg) | Sachverhalt | C1 | facts / circumstances | the case file of facts |
| [172](../assets/vocab/172.svg) | Tragweite | C1 | scope / significance | how far it reaches |
| [171](../assets/vocab/171.svg) | Umsetzbarkeit | C1 | feasibility | from blueprint to building |
| [182](../assets/vocab/182.svg) | Verbindlichkeit | C1 | binding nature / commitment | the pinky promise |
| [164](../assets/vocab/164.svg) | Vorgehensweise | C1 | approach / procedure | a procedure as a flowchart |
| [167](../assets/vocab/167.svg) | Wahrnehmung | C1 | perception | what the eye takes in |
| [177](../assets/vocab/177.svg) | Zielsetzung | C1 | objective | drawing the target on the pad |
| [170](../assets/vocab/170.svg) | Zuverlässigkeit | C1 | reliability | the machine that keeps running, shielded |
| [198](../assets/vocab/198.svg) | Auslegung | C2 | interpretation | two readings of the same text |
| [195](../assets/vocab/195.svg) | Belastbarkeit | C2 | robustness | the beam holds the weight |
| [193](../assets/vocab/193.svg) | Differenzierung | C2 | differentiation / nuance | sorting the mixture |
| [191](../assets/vocab/191.svg) | Diskrepanz | C2 | discrepancy | the gap between claim and reality |
| [202](../assets/vocab/202.svg) | Evidenz | C2 | evidence | the data, examined |
| [186](../assets/vocab/186.svg) | Implikation | C2 | implication | the iceberg under the surface |
| [192](../assets/vocab/192.svg) | Kohärenz | C2 | coherence | tiles that follow on from each other |
| [200](../assets/vocab/200.svg) | Legitimität | C2 | legitimacy | the wax seal on the charter |
| [184](../assets/vocab/184.svg) | Mehrdeutigkeit | C2 | ambiguity | one word, two meanings (Bank) |
| [185](../assets/vocab/185.svg) | Nuance | C2 | nuance | a small step on a fine scale |
| [188](../assets/vocab/188.svg) | Plausibilität | C2 | plausibility | the links hold together |
| [187](../assets/vocab/187.svg) | Prämisse | C2 | premise | the tower rests on one base block |
| [201](../assets/vocab/201.svg) | Stringenz | C2 | rigor / consistency | every point on one straight line |
| [194](../assets/vocab/194.svg) | Trennschärfe | C2 | discriminatory precision | a sharp line between two groups |
| [197](../assets/vocab/197.svg) | Unwägbarkeit | C2 | uncertainty / imponderable | the road disappears into fog |
| [189](../assets/vocab/189.svg) | Verhältnismäßigkeit | C2 | proportionality | no sledgehammer for a nut |
| [199](../assets/vocab/199.svg) | Zuschreibung | C2 | attribution | a label hung on a person |
| [203](../assets/vocab/203.svg) | Zweckmäßigkeit | C2 | expediency / suitability | the right tool for the screw |
| [196](../assets/vocab/196.svg) | Übertragbarkeit | C2 | transferability / generalizability | the same part fits elsewhere |
