# Visual audit 4.15.0: the Vibe Mistral batch and the 4.14 verbs

The 4.5 release (commit `0c92f8e`) added 486 vocabulary drawings in one
commit, with no author recorded. They came from the workflow described in
`tool/README_SVG_BATCHES.md`, which carries its own Windows paths and
"Completed in This Session" lists, and the maintainer identifies it as Vibe
Mistral's work. This document records the audit of that batch and what
replaced it. It also covers the 250 verbs of 4.14.1–4.14.6, which were
redrawn in the same release (see [The 4.14 verb tranche](#the-414-verb-tranche-250-redrawn)).

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

The 250-verb tranche of 4.14.1–4.14.6 was readable, but small-scale and
plain next to that standard. It is redrawn in this release too.

## The 4.14 verb tranche (250 redrawn)

The 4.14 verbs drew each verb as a small symbol: a flag for *beginnen*, a
megaphone for *rufen*, an umbrella shape for *beten*, a green blob for
*stinken*. Next to the Codex verbs (*ziehen*, *schieben*, *schneiden*,
*kleben*, *falten*) they had no outlines, used a fraction of the tile, and
rarely showed anyone doing anything. All 250 are redrawn in the Codex
manner:

- a person in the Codex proportions (outlined round head, thick blue body,
  skin-coloured arms) doing the action, or the hands doing it in close-up;
- props outlined in the same dark grey, at a size that reads at 44px;
- a red arrow or motion marks for the movement, and a dashed line for a path
  or a gaze.

Paired verbs share a scene, so the difference is the only thing that
changes:

- *einsteigen* and *aussteigen*: the bus door, with the arrow going in or out;
- *reinkommen* and *rauskommen*;
- *heimfahren* and *heimgehen*;
- *leihen* and *zurückgeben*: *leihen* has a dashed arrow for the book coming
  back, and *zurückgeben* shows it going back over the counter.

Every drawing was ranked against the library with `tool/svg_neighbours.py`,
and each verb was compared by eye with the noun card for the same object.
Nine first drafts were changed because of a collision:

| Verb | First drawn as | Collided with | Now |
|---|---|---|---|
| *rechnen* | a calculator | *Taschenrechner* | a dot sum on paper, with the pencil |
| *starten* | a rocket lifting off | *Rakete* | the start lights turn green and a car pulls away |
| *schweben* | a hot-air balloon | *Heißluftballon* | a feather drifting on the air |
| *segeln* | a sailing boat | *Boot* | a sailor at the tiller, with wind in the sail |
| *heiraten* | two rings | *Ring* | the couple, with the rings above them |
| *trennen* | two jigsaw pieces | *Puzzle* | a mixed pile sorted into two sides |
| *bremsen* | a bicycle with skid lines | *Fahrrad* | the rider braking, with the tyre skidding |
| *beruhigen* | an adult with a child | *begleiten* | a crying baby rocked until it settles |
| *bergsteigen* | a climber on a peak | *gemeinsam*, whose cue was a roped pair on a mountain | unchanged; *gemeinsam* is now two people carrying one load |

The emotion verbs *lächeln*, *weinen*, *schweigen*, *schämen* and
*verlieben* use the bust from the Codex *Meinung*, so their outlines match on
purpose. Each has its own shirt colour and a face cue that reads at 44px:
the smile, the tears, the finger on the lips, the hands over the face, or
the heart eyes.

The 44px pass also changed first drafts that did not read:

- *beten* sat instead of kneeling;
- the hand in *anfassen* looked like a leaf;
- the broken vase in *zugeben* was too small to see;
- the two figures in *flüstern* merged;
- the shoe in *binden* read as a hat;
- the librarian in *zurückgeben* stood on the counter;
- *vertrauen* read as a push;
- the balloon in *enttäuschen* read as a frying pan;
- the heads in *zögern* and *angeln* were cropped.

The full list is in [Verb tranche redrawn (250)](#verb-tranche-redrawn-250).

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
| [x10305](../assets/vocab/x10305.svg) | gemeinsam | A2 | joint / together | two people carry one load |
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

## Verb tranche redrawn (250)

| Asset | German | Level | Gloss | Drawing |
|---|---|---|---|---|
| [x10395](../assets/vocab/x10395.svg) | beobachten | B1 | to observe | figure with binoculars watching a bird on a branch |
| [x10821](../assets/vocab/x10821.svg) | aufräumen | A1 | to tidy up | a hand drops a toy into a box that already holds the rest |
| [x10823](../assets/vocab/x10823.svg) | staubsaugen | A1 | to vacuum | figure pushes the vacuum wand, dust ahead of the nozzle |
| [x10825](../assets/vocab/x10825.svg) | lüften | A1 | to air a room | both casements thrown open, fresh air flowing through |
| [x10831](../assets/vocab/x10831.svg) | abholen | A2 | to pick up | a car pulls up for the figure waiting with a suitcase |
| [x10832](../assets/vocab/x10832.svg) | einsteigen | A2 | to board | figure steps up into the bus door |
| [x10833](../assets/vocab/x10833.svg) | aussteigen | A2 | to get off | figure steps down out of the bus door onto the pavement |
| [x10834](../assets/vocab/x10834.svg) | buchen | A2 | to book | a laptop showing a bed and a confirming green check |
| [x10835](../assets/vocab/x10835.svg) | packen | A2 | to pack | a shirt going into an open suitcase |
| [x10845](../assets/vocab/x10845.svg) | besichtigen | A2 | to view, tour | a tourist photographs a castle tower |
| [x10846](../assets/vocab/x10846.svg) | übernachten | A2 | to stay overnight | asleep in a strange bed, suitcase beside it, night outside |
| [x10858](../assets/vocab/x10858.svg) | leiten | A2 | to lead, manage | the leader with a flag in front, a group following |
| [x10864](../assets/vocab/x10864.svg) | leihen | A2 | to lend | one hand passes a book, the dashed arrow says it comes back |
| [x10870](../assets/vocab/x10870.svg) | aussuchen | A2 | to pick out | three shirts on a rail; a hand lifts out the middle one |
| [x10871](../assets/vocab/x10871.svg) | anprobieren | A2 | to try on | trying on a jacket in front of the mirror, tag still on |
| [x10930](../assets/vocab/x10930.svg) | verringern | B1 | to reduce | the amount shrinks bar by bar |
| [x10933](../assets/vocab/x10933.svg) | verzichten | B1 | to do without | hand held up to say no to the cake |
| [x20083](../assets/vocab/x20083.svg) | setzen | A1 | to sit down | lowering onto a chair |
| [x20086](../assets/vocab/x20086.svg) | entschuldigen | A1 | to apologize, make an apology | a bow toward the other person, a plaster in the bubble |
| [x20107](../assets/vocab/x20107.svg) | kümmern | A1 | to take care, to look after | tucking a child into bed |
| [x20110](../assets/vocab/x20110.svg) | legen | A1 | to lie down | laying a book down flat on the table |
| [x20129](../assets/vocab/x20129.svg) | freuen | A1 | to look forward to | jumping for joy at the marked day on the calendar |
| [x20131](../assets/vocab/x20131.svg) | bitten | A1 | to ask, to beg, to plead, to bid, to request | open hands held out in a plea to the other person |
| [x20132](../assets/vocab/x20132.svg) | heiraten | A1 | to marry | the couple, rings above them |
| [x20133](../assets/vocab/x20133.svg) | fällen | A1 | to cut down, to chop down, to fell | an axe bites into the trunk and the tree starts to go |
| [x20141](../assets/vocab/x20141.svg) | wiedersehen | A1 | to see again, to meet again | arms wide, meeting again, the loop arrow says "again" |
| [x20147](../assets/vocab/x20147.svg) | beginnen | A1 | to start, to begin | a runner crouched at the start line, the start flag up |
| [x20155](../assets/vocab/x20155.svg) | verstecken | A1 | to hide | someone hides behind a bush, only eyes and shoes showing |
| [x20156](../assets/vocab/x20156.svg) | verletzen | A1 | to hurt | a sharp word lands, the other person's heart cracks |
| [x20160](../assets/vocab/x20160.svg) | vorstellen | A1 | to introduce oneself | hand on chest, a name tag, a bubble with "me" |
| [x20170](../assets/vocab/x20170.svg) | ehren | A1 | to honor | on the winners' block, a medal round the neck |
| [x20182](../assets/vocab/x20182.svg) | beeilen | A1 | to hurry, to hasten, to rush | running for it with a briefcase, the clock is against you |
| [x20190](../assets/vocab/x20190.svg) | beschützen | A1 | to protect, to guard, to defend | holding the umbrella over a child in the rain |
| [x20193](../assets/vocab/x20193.svg) | erwischen | A1 | to catch | a hand in the cookie jar, caught in the torch beam |
| [x20195](../assets/vocab/x20195.svg) | kennenlernen | A1 | to meet | a first handshake, both saying hello |
| [x20207](../assets/vocab/x20207.svg) | bellen | A1 | to bark: | a dog barking, the sound going out ahead of it |
| [x20209](../assets/vocab/x20209.svg) | verlieben | A1 | to fall in love | heart-eyes, hearts rising |
| [x20214](../assets/vocab/x20214.svg) | zurückkommen | A1 | to return | out and back again to the front door |
| [x20252](../assets/vocab/x20252.svg) | trennen | A1 | to separate, sever, part, disunite, uncouple, se | sorting the mixed pile into two sides |
| [x20261](../assets/vocab/x20261.svg) | drücken | A1 | to press, to push | a finger pushes the big button down |
| [x20264](../assets/vocab/x20264.svg) | entspannen | A1 | to relax | lying in a hammock, sun out, eyes shut |
| [x20284](../assets/vocab/x20284.svg) | schmecken | A1 | to enjoy | a spoonful, eyes shut, it tastes good |
| [x20293](../assets/vocab/x20293.svg) | danken | A1 | to thank | flowers handed over, a heart in reply |
| [x20301](../assets/vocab/x20301.svg) | erscheinen | A1 | to appear | the curtain opens and someone appears, with a sparkle |
| [x20306](../assets/vocab/x20306.svg) | mitkommen | A1 | to come with, to join and come along with | "come along", and the second person follows |
| [x20308](../assets/vocab/x20308.svg) | entkommen | A1 | to escape | out through the open cell door and away |
| [x20311](../assets/vocab/x20311.svg) | unterhalten | A1 | to converse | a conversation over coffee, turns in the bubbles |
| [x20318](../assets/vocab/x20318.svg) | streiten | A1 | to argue | two people shouting across each other |
| [x20320](../assets/vocab/x20320.svg) | reinkommen | A1 | to come in | through the open door, the arrow points inside |
| [x20322](../assets/vocab/x20322.svg) | decken | A1 | to lay or set | laying the table, plate, glass, knife, fork going down |
| [x20324](../assets/vocab/x20324.svg) | hingehen | A1 | to go | walking the path to a pin on the map |
| [x20326](../assets/vocab/x20326.svg) | rauskommen | A1 | to come out | out of the door, the arrow leads away from it |
| [x20328](../assets/vocab/x20328.svg) | wiederholen | A1 | to repeat | the same line said again and again, in a loop |
| [x20329](../assets/vocab/x20329.svg) | befreien | A1 | to free | the cage door opens and the bird flies out |
| [x20341](../assets/vocab/x20341.svg) | denken | A2 | to think | hand on chin, a gear turning in the thought bubble |
| [x20354](../assets/vocab/x20354.svg) | fallen | A2 | to fall | the apple drops from the branch |
| [x20364](../assets/vocab/x20364.svg) | rufen | A1 | to call, to request the presence of | hands cupped round the mouth, the call reaches someone far off |
| [x20376](../assets/vocab/x20376.svg) | ändern | A2 | to change, to alter | one shape turned into another |
| [x20380](../assets/vocab/x20380.svg) | singen | A2 | to sing | open mouth, notes pouring out |
| [x20382](../assets/vocab/x20382.svg) | hängen | A2 | to hang, to execute by hanging | a picture going up on its nail |
| [x20389](../assets/vocab/x20389.svg) | bauen | A2 | to build, to construct | a builder in a hard hat laying a brick on the wall |
| [x20391](../assets/vocab/x20391.svg) | lügen | A2 | to tell a lie | the nose grows with the fib |
| [x20393](../assets/vocab/x20393.svg) | erreichen | A2 | to reach | the call goes through, a tick at the other end |
| [x20397](../assets/vocab/x20397.svg) | stören | A2 | to disturb, to interfere, to bother | trying to read while the noise comes in from the side |
| [x20404](../assets/vocab/x20404.svg) | weinen | A2 | to weep, cry | tears streaming, mouth open |
| [x20406](../assets/vocab/x20406.svg) | merken | A2 | to memorize, remember, learn | the note goes into the head and stays |
| [x20407](../assets/vocab/x20407.svg) | beenden | A2 | to finish, to complete, to | the bar reaches the end, flag down, tick |
| [x20409](../assets/vocab/x20409.svg) | wählen | A2 | to vote | the marked ballot goes into the box |
| [x20410](../assets/vocab/x20410.svg) | teilen | A2 | to split, to share | a bar of chocolate broken, one half each |
| [x20417](../assets/vocab/x20417.svg) | träumen | A2 | to dream | asleep, a boat sailing through the dream |
| [x20422](../assets/vocab/x20422.svg) | aufpassen | A2 | to look after, to take care of | watching over a little one playing |
| [x20429](../assets/vocab/x20429.svg) | ausgehen | A2 | to go out | dressed up, out the door into the night |
| [x20430](../assets/vocab/x20430.svg) | probieren | A2 | to try | a taste from the spoon, not sure yet |
| [x20431](../assets/vocab/x20431.svg) | schenken | A2 | to give as a present, to gift | a wrapped present handed over, with love |
| [x20437](../assets/vocab/x20437.svg) | kontrollieren | A2 | to control | going down the list with a magnifier |
| [x20440](../assets/vocab/x20440.svg) | klappen | A2 | to work out, to succeed, to function correctly,  | thumbs up, it worked |
| [x20445](../assets/vocab/x20445.svg) | liefern | A2 | to deliver | the parcel carried to the door |
| [x20452](../assets/vocab/x20452.svg) | reiten | A2 | to ride | a rider on a horse |
| [x20453](../assets/vocab/x20453.svg) | erschrecken | A2 | to frighten | "boo!" from behind the wall, the other one jumps |
| [x20456](../assets/vocab/x20456.svg) | wechseln | A2 | to change, to exchange | a note changed into coins and back |
| [x20461](../assets/vocab/x20461.svg) | beten | A2 | to pray | kneeling, hands folded, a candle burning |
| [x20468](../assets/vocab/x20468.svg) | verwandeln | A2 | to turn, to change, to transform | a caterpillar becomes a butterfly |
| [x20471](../assets/vocab/x20471.svg) | sammeln | A1 | to collect money | coins dropped into the collecting tin |
| [x20477](../assets/vocab/x20477.svg) | abschließen | A2 | to lock | the key turns in the door lock |
| [x20484](../assets/vocab/x20484.svg) | verteidigen | A2 | to defend | a shield up against incoming arrows |
| [x20485](../assets/vocab/x20485.svg) | raten | A2 | to advise | good advice, a light bulb passed from one to the other |
| [x20487](../assets/vocab/x20487.svg) | aufmachen | A2 | to open | the lid comes off the jar |
| [x20493](../assets/vocab/x20493.svg) | anfassen | A2 | to touch | a hand strokes the cat |
| [x20507](../assets/vocab/x20507.svg) | schämen | A2 | to be ashamed or | face hidden in the hands, red cheeks |
| [x20510](../assets/vocab/x20510.svg) | besiegen | A2 | to defeat | arm-wrestling, one arm pressed down to the table |
| [x20517](../assets/vocab/x20517.svg) | zugeben | A2 | to admit, confess | the vase is broken, a hand goes up: it was me |
| [x20519](../assets/vocab/x20519.svg) | stoßen | A2 | to bump | bumping into the lamp post, stars |
| [x20522](../assets/vocab/x20522.svg) | übersetzen | A2 | to translate, to interpret | one language in, the other out |
| [x20526](../assets/vocab/x20526.svg) | pfeifen | A2 | to whistle | a whistle in the mouth, the shrill sound |
| [x20546](../assets/vocab/x20546.svg) | zusehen | A2 | to watch | seated, watching the juggler |
| [x20551](../assets/vocab/x20551.svg) | wecken | A2 | to wake, to wake up | the alarm clock rings beside the sleeper |
| [x20552](../assets/vocab/x20552.svg) | rühren | A2 | to stir | the spoon going round in the pot |
| [x20553](../assets/vocab/x20553.svg) | kehren | A2 | to turn | a U-turn at the end of the road |
| [x20567](../assets/vocab/x20567.svg) | ignorieren | A2 | to ignore | one talks and waves, the other turns away, nose up |
| [x20576](../assets/vocab/x20576.svg) | trainieren | A2 | to train, to coach | working out with the dumbbell |
| [x20593](../assets/vocab/x20593.svg) | aufbauen | A2 | to set up, to put up, to pitch | pitching the tent, one peg at a time |
| [x20594](../assets/vocab/x20594.svg) | malen | A2 | to paint | at the easel with brush and palette |
| [x20596](../assets/vocab/x20596.svg) | verabschieden | A2 | to say goodbye | waving goodbye as the other leaves with the suitcase |
| [x20597](../assets/vocab/x20597.svg) | drohen | A2 | to threaten | a raised fist, the other one cowers |
| [x20601](../assets/vocab/x20601.svg) | streichen | A2 | to paint | the roller gives the wall its new colour |
| [x20612](../assets/vocab/x20612.svg) | verrücken | A2 | to shift, to move by pushing | shoving the wardrobe along the floor |
| [x20619](../assets/vocab/x20619.svg) | rechnen | A2 | to count on, expect | a sum on paper, two dots and three make five |
| [x20621](../assets/vocab/x20621.svg) | zielen | A2 | to aim at a physical target | aiming the bow, the dotted line to the bull's eye |
| [x20633](../assets/vocab/x20633.svg) | rollen | A2 | to roll | a ball rolling down the slope |
| [x20637](../assets/vocab/x20637.svg) | räumen | A2 | to clear an area of debris, snow, mines, or othe | shovelling the snow off the path |
| [x20639](../assets/vocab/x20639.svg) | ausgeben | A2 | to buy a drink, to get a drink | this round is on me |
| [x20645](../assets/vocab/x20645.svg) | nähern | A2 | to approach, to come near | coming closer step by step |
| [x20653](../assets/vocab/x20653.svg) | lehren | A2 | to teach | at the board, pointing, a pupil listening |
| [x20657](../assets/vocab/x20657.svg) | flüstern | A2 | to whisper | a hand cupped, a secret in the ear |
| [x20659](../assets/vocab/x20659.svg) | füllen | A2 | to fill | the bucket fills up under the tap |
| [x20664](../assets/vocab/x20664.svg) | sperren | A2 | to block, lock | the barrier is down, the road closed |
| [x20668](../assets/vocab/x20668.svg) | wegnehmen | A2 | to take away from, to remove from | a big hand takes the toy away |
| [x20673](../assets/vocab/x20673.svg) | explodieren | A2 | to explode | a big bang, bits flying |
| [x20683](../assets/vocab/x20683.svg) | aktivieren | A2 | to activate, to enable | the switch flipped on |
| [x20686](../assets/vocab/x20686.svg) | vorbeikommen | A2 | to come over | dropping by, a cake for the friend at the door |
| [x20687](../assets/vocab/x20687.svg) | einschlafen | A2 | to fall asleep | nodding off in the armchair, the book slipping |
| [x20688](../assets/vocab/x20688.svg) | loslassen | A2 | to let loose, let go | the hand opens and the balloon floats away |
| [x20695](../assets/vocab/x20695.svg) | ausschalten | A2 | to turn off, to switch off, to power down, to di | the switch flicked down, the lamp goes dark |
| [x20697](../assets/vocab/x20697.svg) | filmen | A2 | to film, to shoot | the camera on its tripod, recording |
| [x20700](../assets/vocab/x20700.svg) | ersetzen | A2 | to replace | the dead bulb out, the new one in |
| [x20704](../assets/vocab/x20704.svg) | eröffnen | A2 | to open | the ribbon is cut at the new shop door |
| [x20709](../assets/vocab/x20709.svg) | weitergehen | A2 | to proceed, progress, continue | on past the signpost, the way continues |
| [x20718](../assets/vocab/x20718.svg) | überwachen | A2 | to control, to monitor, to supervise | the camera on the wall watches the doorway |
| [x20737](../assets/vocab/x20737.svg) | wundern | A2 | to be surprised | scratching the head, surprise and a question |
| [x20739](../assets/vocab/x20739.svg) | herstellen | A2 | to produce, manufacture | boxes rolling out of the machine on the belt |
| [x20740](../assets/vocab/x20740.svg) | strecken | A2 | to stretch | arms right up, up on the toes |
| [x20746](../assets/vocab/x20746.svg) | locken | A2 | to lure, to entice, to tempt | the cheese draws the mouse along |
| [x20748](../assets/vocab/x20748.svg) | befragen | A2 | to question, to interview, to interrogate | a microphone held out for the answer |
| [x20761](../assets/vocab/x20761.svg) | blasen | A2 | to blow | blowing the dandelion seeds away |
| [x20772](../assets/vocab/x20772.svg) | brüllen | A2 | to shout, roar | mouth wide open, the noise going everywhere |
| [x20775](../assets/vocab/x20775.svg) | bewundern | A2 | to admire, to highly respect | hand on heart before the painting |
| [x20787](../assets/vocab/x20787.svg) | binden | A2 | to tie, to fasten a string etc. | two hands tying the laces into a bow |
| [x20809](../assets/vocab/x20809.svg) | bewachen | A2 | to guard, to watch over | the guard stands by the treasure chest |
| [x20813](../assets/vocab/x20813.svg) | zerbrechen | A2 | to break into pieces, to shatter, to snap | the plate hits the floor and shatters |
| [x20827](../assets/vocab/x20827.svg) | zurückgeben | A1 | to give back, return | the borrowed book goes back over the counter |
| [x20844](../assets/vocab/x20844.svg) | weglaufen | A2 | to run away | running off, the dog barking behind |
| [x20852](../assets/vocab/x20852.svg) | zeichnen | A2 | to draw, to sketch | the pencil sketching a house |
| [x20863](../assets/vocab/x20863.svg) | lehnen | A2 | to lean something | the ladder propped against the wall |
| [x20868](../assets/vocab/x20868.svg) | ausführen | A2 | to take | taking the dog for a walk |
| [x20896](../assets/vocab/x20896.svg) | verschwinden | B1 | to leave, to go away | gone in a puff, only a dashed outline left |
| [x20900](../assets/vocab/x20900.svg) | retten | B1 | to save, to rescue | the lifebuoy thrown to someone in the water |
| [x20921](../assets/vocab/x20921.svg) | vertrauen | B1 | to trust, to place confidence in | falling back stiff as a board, sure to be caught |
| [x20924](../assets/vocab/x20924.svg) | fangen | B1 | to catch | the ball flies in and the hands catch it |
| [x20925](../assets/vocab/x20925.svg) | funktionieren | B1 | to work, work out | the gears mesh and turn, it works |
| [x20928](../assets/vocab/x20928.svg) | schießen | B1 | to shoot | the ball shot into the net |
| [x20936](../assets/vocab/x20936.svg) | brechen | B1 | to become broken | two hands snap the stick |
| [x20949](../assets/vocab/x20949.svg) | drehen | B1 | to turn | hands turn the wheel |
| [x20951](../assets/vocab/x20951.svg) | stehlen | B1 | to steal | a gloved hand lifts the wallet from the back pocket |
| [x20953](../assets/vocab/x20953.svg) | treten | B1 | to kick | the kick, the ball away |
| [x20960](../assets/vocab/x20960.svg) | beruhigen | B1 | to calm down, to quiet | rocking the crying baby until it settles |
| [x20965](../assets/vocab/x20965.svg) | melden | B1 | to put one’s hand up | hand up in class |
| [x20974](../assets/vocab/x20974.svg) | steigen | A2 | to ascend, to climb, to rise | step by step up the stairs |
| [x20981](../assets/vocab/x20981.svg) | zählen | B1 | to count | one, two, three - fingers and apples |
| [x20986](../assets/vocab/x20986.svg) | rennen | B1 | to run | a sprinter down the track |
| [x20993](../assets/vocab/x20993.svg) | hassen | B1 | to hate | a black heart under a thundercloud |
| [x20998](../assets/vocab/x20998.svg) | verhaften | B1 | to imprison, to put into confinement after judic | led away in handcuffs by the police officer |
| [x21005](../assets/vocab/x21005.svg) | überraschen | B1 | to surprise | the box opens and the confetti flies |
| [x21012](../assets/vocab/x21012.svg) | aufgeben | B1 | to give up | sitting down, the white flag up |
| [x21017](../assets/vocab/x21017.svg) | landen | B1 | to land | the plane comes down on the runway |
| [x21032](../assets/vocab/x21032.svg) | klingeln | A1 | to ring | a finger on the doorbell, it rings |
| [x21039](../assets/vocab/x21039.svg) | entdecken | B1 | to discover, to spot, to learn for the first tim | a magnifier finds the footprint |
| [x21041](../assets/vocab/x21041.svg) | lächeln | B1 | to smile | a wide smile |
| [x21044](../assets/vocab/x21044.svg) | vermissen | B1 | to miss | looking at the photo, someone missing |
| [x21046](../assets/vocab/x21046.svg) | klopfen | A1 | to knock, to rap | knuckles knocking on the door |
| [x21049](../assets/vocab/x21049.svg) | hinterlassen | B1 | to leave, to leave behind | a note left on the table, footprints out of the door |
| [x21059](../assets/vocab/x21059.svg) | verbinden | B1 | to join, to combine, to connect, to interlink | the plug goes into the socket |
| [x21064](../assets/vocab/x21064.svg) | genießen | B1 | to enjoy | stretched out in the deckchair, sun and a cold drink |
| [x21071](../assets/vocab/x21071.svg) | begleiten | B1 | to accompany | hand in hand, going along together |
| [x21072](../assets/vocab/x21072.svg) | brennen | B1 | to be lit, to be on | logs ablaze, sparks and smoke going up |
| [x21077](../assets/vocab/x21077.svg) | aufwachen | B1 | to awake, to wake up | sitting up in bed, arms stretched, the sun in the window |
| [x21080](../assets/vocab/x21080.svg) | heben | B1 | to lift | lifting the heavy box, knees bent |
| [x21084](../assets/vocab/x21084.svg) | enttäuschen | B1 | to disappoint | the present is unwrapped and there is nothing in it |
| [x21085](../assets/vocab/x21085.svg) | wachsen | B1 | to grow | from seed to sprout to plant |
| [x21086](../assets/vocab/x21086.svg) | fressen | B1 | to eat | the dog wolfs down its bowl |
| [x21088](../assets/vocab/x21088.svg) | verbieten | B1 | to forbid, prohibit | a hand up, not the cookie jar |
| [x21090](../assets/vocab/x21090.svg) | greifen | B1 | to grab | a quick hand snatches the ball |
| [x21091](../assets/vocab/x21091.svg) | küssen | B1 | to kiss | a kiss and a heart |
| [x21098](../assets/vocab/x21098.svg) | schweigen | B1 | to be silent | finger to the lips, mouth shut |
| [x21107](../assets/vocab/x21107.svg) | stoppen | B1 | to stop | the stop sign and the flat hand |
| [x21110](../assets/vocab/x21110.svg) | starten | B1 | to start something | the lights go green and off it goes |
| [x21130](../assets/vocab/x21130.svg) | tauchen | B1 | to dive | the diver among the bubbles |
| [x21146](../assets/vocab/x21146.svg) | einstellen | B1 | to hire | the handshake over the desk, contract signed |
| [x21148](../assets/vocab/x21148.svg) | grüßen | A2 | to greet | the hat lifted in greeting |
| [x21156](../assets/vocab/x21156.svg) | stürzen | B1 | to fall down, to drop, to tumble | tripping on the stone and going down |
| [x21159](../assets/vocab/x21159.svg) | ausziehen | B1 | to take off | the jumper pulled up over the head |
| [x21171](../assets/vocab/x21171.svg) | gründen | B1 | to found, to establish | the first stone laid, the flag planted, the rest to come |
| [x21182](../assets/vocab/x21182.svg) | löschen | B1 | to quench | the extinguisher puts the fire out |
| [x21187](../assets/vocab/x21187.svg) | stinken | B1 | to stink | the old sock, stink lines and a fly |
| [x21196](../assets/vocab/x21196.svg) | wetten | B1 | to bet | shaking on the bet, the stake between them |
| [x21208](../assets/vocab/x21208.svg) | testen | B1 | to test | a drop from the pipette, the flask bubbles |
| [x21215](../assets/vocab/x21215.svg) | entfernen | B1 | to remove | one block lifted out, an empty gap left |
| [x21216](../assets/vocab/x21216.svg) | unterbrechen | B1 | to interrupt | halfway through a sentence, the other one cuts in |
| [x21239](../assets/vocab/x21239.svg) | tauschen | B1 | to trade, to exchange, to swap, to barter | an apple for a ball, both change hands |
| [x21243](../assets/vocab/x21243.svg) | verteilen | B1 | to spread | butter spread thin on the bread |
| [x21246](../assets/vocab/x21246.svg) | beißen | B1 | to bite | the jaws close on the sandwich |
| [x21265](../assets/vocab/x21265.svg) | bedienen | B1 | to help oneself | helping yourself at the buffet with the tongs |
| [x21270](../assets/vocab/x21270.svg) | mischen | A2 | to shuffle | the cards riffled from hand to hand |
| [x21274](../assets/vocab/x21274.svg) | füttern | B1 | to feed | crumbs thrown to the ducks |
| [x21296](../assets/vocab/x21296.svg) | aufheben | B1 | to pick up | bending down to pick up the coin |
| [x21298](../assets/vocab/x21298.svg) | fließen | B1 | to flow | the river flows between its banks |
| [x21308](../assets/vocab/x21308.svg) | überreden | B1 | to talk over, to talk into, to persuade | talked round, from no to yes |
| [x21316](../assets/vocab/x21316.svg) | umarmen | B1 | to embrace, to hug | a big hug |
| [x21318](../assets/vocab/x21318.svg) | übertreiben | B1 | to exaggerate | "this big!" - the real fish was tiny |
| [x21350](../assets/vocab/x21350.svg) | einnehmen | B1 | to take, to have | the pill with a glass of water |
| [x21387](../assets/vocab/x21387.svg) | bemühen | B1 | to make an effort | pushing the boulder up the hill, sweating |
| [x21394](../assets/vocab/x21394.svg) | hinlegen | B1 | to lie down | lying down on the sofa |
| [x21398](../assets/vocab/x21398.svg) | knacken | B1 | to crack | the nutcracker cracks the walnut |
| [x21405](../assets/vocab/x21405.svg) | zweifeln | B1 | to doubt, to be doubtful | hand on the chin, one eyebrow up, questions |
| [x21406](../assets/vocab/x21406.svg) | auflegen | B1 | to hang up | the receiver put back down, call over |
| [x21415](../assets/vocab/x21415.svg) | anschließen | B1 | to join | joining the group, one more |
| [x21418](../assets/vocab/x21418.svg) | servieren | B1 | to serve | the waiter brings the covered dish |
| [x21425](../assets/vocab/x21425.svg) | läuten | B1 | to ring, toll | the bell swings in its tower |
| [x21431](../assets/vocab/x21431.svg) | klettern | B1 | to climb | up the climbing wall, hand over hand |
| [x21436](../assets/vocab/x21436.svg) | sinken | B1 | to sink | the boat goes down, bubbles rising |
| [x21454](../assets/vocab/x21454.svg) | zittern | B1 | to shiver, to tremble, to vibrate | arms wrapped round, shaking with cold |
| [x21460](../assets/vocab/x21460.svg) | überstehen | B1 | to endure, to overcome, to survive, to pull thro | bent by the storm, still standing, the sun comes out |
| [x21468](../assets/vocab/x21468.svg) | wegwerfen | B1 | to throw away, to discard | the crumpled paper flies into the bin |
| [x21475](../assets/vocab/x21475.svg) | spenden | B1 | to donate, to give as charity | a coin dropped into the donation box |
| [x21476](../assets/vocab/x21476.svg) | schlucken | B1 | to swallow | the gulp going down the throat |
| [x21487](../assets/vocab/x21487.svg) | weigern | B1 | to refuse | arms crossed, head shaking, no |
| [x21510](../assets/vocab/x21510.svg) | verabreden | B1 | to make an appointment | the same day marked, the time agreed |
| [x21516](../assets/vocab/x21516.svg) | korrigieren | B1 | to correct | the red pen marks the mistake and the fix |
| [x21533](../assets/vocab/x21533.svg) | langweilen | B1 | to be bored, to feel bored | head on the hand, the clock crawling |
| [x21539](../assets/vocab/x21539.svg) | übertragen | B1 | to broadcast, televise | the mast sends it out to the television |
| [x21540](../assets/vocab/x21540.svg) | zögern | B1 | to hesitate, to pause before doing something | the end of the diving board, one foot forward, not yet |
| [x21566](../assets/vocab/x21566.svg) | angeln | B1 | to fish | on the jetty with the rod, the line in the water |
| [x21680](../assets/vocab/x21680.svg) | rasieren | B1 | to shave | the razor through the shaving foam |
| [x21784](../assets/vocab/x21784.svg) | verwechseln | B1 | to mix up | two keys that look the same, which is which? |
| [x21798](../assets/vocab/x21798.svg) | schweben | B1 | to hover, soar, float, drift | a feather drifts on the air |
| [x21836](../assets/vocab/x21836.svg) | ausfallen | A2 | to fail, malfunction, to go off | the screen goes dead, a spark from the plug |
| [x21877](../assets/vocab/x21877.svg) | bremsen | A2 | to brake, slow down, decelerate | the rider squeezes the brake, the tyre skids |
| [x21896](../assets/vocab/x21896.svg) | segeln | B1 | to sail | at the tiller, the sail filled by the wind |
| [x21917](../assets/vocab/x21917.svg) | schwitzen | B1 | to sweat | the sun beats down, the sweat pours |
| [x21944](../assets/vocab/x21944.svg) | rutschen | B2 | to slip, to slide | slipping on the banana skin |
| [x22505](../assets/vocab/x22505.svg) | einfrieren | B1 | to freeze | into the freezer, frost on everything |
| [x23340](../assets/vocab/x23340.svg) | kürzen | A2 | to shorten | snipped shorter at the dashed line |
| [x23451](../assets/vocab/x23451.svg) | heimfahren | A2 | to drive home | driving home, the light on at the house |
| [x23546](../assets/vocab/x23546.svg) | heimgehen | A2 | to go home | walking home on the path at dusk |
| [x23612](../assets/vocab/x23612.svg) | verdauen | B1 | to digest | the meal works its way through the stomach |
| [x23776](../assets/vocab/x23776.svg) | auffangen | B1 | to catch | caught just before it hits the floor |
| [x24315](../assets/vocab/x24315.svg) | einschenken | B1 | to pour | the bottle tipped, the glass filling |
| [x26536](../assets/vocab/x26536.svg) | begießen | B1 | to water | the watering can over the flowers |
| [x27012](../assets/vocab/x27012.svg) | bergsteigen | B1 | to mountaineer | roped up, the ice axe, the summit flag |
| [x27468](../assets/vocab/x27468.svg) | gärtnern | B1 | to garden | kneeling in the bed, planting with the trowel |
| [x28115](../assets/vocab/x28115.svg) | jäten | B1 | to weed | the weed pulled out, roots and all |
