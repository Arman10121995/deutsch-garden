import 'writing_extra.dart';
import 'models.dart';
import 'grammar_expansion.dart';
import 'speaking_curriculum.dart';
import 'skill_expansion.dart';

ChoiceQuestion _q(
  String prompt,
  List<String> options,
  int correctIndex,
  String explanation,
) =>
    ChoiceQuestion(
      prompt: prompt,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
    );

final List<GrammarLesson> grammarLessons = <GrammarLesson>[
  GrammarLesson(
    id: 'gr-a1-01',
    level: CefrLevel.a1,
    title: 'Present tense & verb position',
    explanation: 'In a normal German main clause, the conjugated verb is in position 2. Regular verbs take endings such as -e, -st, -t and -en.',
    examples: const <String>['Ich lerne Deutsch.', 'Heute lerne ich Deutsch.', 'Wir wohnen in Rostock.'],
    questions: <ChoiceQuestion>[
      _q('Choose the correct sentence.', const ['Ich Deutsch lerne.', 'Ich lerne Deutsch.', 'Ich Deutsch lernen.'], 1, 'The conjugated verb “lerne” occupies position 2.'),
      _q('Du ___ in Berlin.', const ['wohne', 'wohnst', 'wohnt'], 1, 'For “du”, a regular verb normally ends in -st.'),
      _q('Heute ___ wir zu Hause.', const ['arbeiten', 'wir arbeiten', 'arbeitet'], 0, 'When “Heute” is first, the verb stays in position 2: Heute arbeiten wir …'),
    ],
  ),
  GrammarLesson(
    id: 'gr-a1-02',
    level: CefrLevel.a1,
    title: 'Articles & basic cases',
    explanation: 'Use der/die/das in the nominative. With a masculine direct object, der changes to den and ein changes to einen.',
    examples: const <String>['Der Mann kommt.', 'Ich sehe den Mann.', 'Ich kaufe einen Apfel.'],
    questions: <ChoiceQuestion>[
      _q('Ich sehe ___ Hund.', const ['der', 'den', 'dem'], 1, '“Hund” is masculine and a direct object, so accusative “den” is required.'),
      _q('___ Lampe ist neu.', const ['Die', 'Den', 'Der'], 0, '“Lampe” is feminine nominative: die Lampe.'),
      _q('Sie kauft ___ Computer.', const ['ein', 'einen', 'einem'], 1, 'A masculine accusative noun takes “einen”.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-a1-03',
    level: CefrLevel.a1,
    title: 'Questions & negation',
    explanation: 'Yes/no questions start with the verb. W-questions start with a question word. “nicht” negates verbs/adjectives; “kein” negates nouns without a definite article.',
    examples: const <String>['Kommst du morgen?', 'Wo wohnst du?', 'Ich habe kein Auto.', 'Das ist nicht teuer.'],
    questions: <ChoiceQuestion>[
      _q('Which is a correct yes/no question?', const ['Du kommst morgen?', 'Kommst du morgen?', 'Morgen du kommst?'], 1, 'Yes/no questions normally begin with the conjugated verb.'),
      _q('Ich habe ___ Fahrrad.', const ['nicht', 'kein', 'keine'], 1, '“Fahrrad” is neuter; use “kein Fahrrad”.'),
      _q('Das Essen ist ___ gut.', const ['kein', 'nicht', 'keinen'], 1, 'Adjectives are negated with “nicht”.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-a1-04',
    level: CefrLevel.a1,
    title: 'Modal verbs',
    explanation: 'With modal verbs such as können, müssen and wollen, the modal is conjugated in position 2 and the main verb goes to the end as an infinitive.',
    examples: const <String>['Ich kann schwimmen.', 'Wir müssen arbeiten.', 'Er will heute kochen.'],
    questions: <ChoiceQuestion>[
      _q('Ich ___ heute lernen.', const ['muss', 'müssen', 'musst'], 0, '“Ich” takes “muss”. The infinitive “lernen” stays at the end.'),
      _q('Wir können morgen ___.', const ['kommen', 'kommen wir', 'kommt'], 0, 'After the modal “können”, use the infinitive “kommen”.'),
      _q('Choose the correct sentence.', const ['Er will kaufen Brot.', 'Er will Brot kaufen.', 'Er Brot will kaufen.'], 1, 'The infinitive goes to the end.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-a2-01',
    level: CefrLevel.a2,
    title: 'Perfect tense (Perfekt)',
    explanation: 'Spoken past German often uses haben/sein + past participle. Movement and change-of-state verbs often use sein.',
    examples: const <String>['Ich habe gearbeitet.', 'Wir sind gefahren.', 'Sie hat das Buch gelesen.'],
    questions: <ChoiceQuestion>[
      _q('Wir ___ nach Hamburg gefahren.', const ['haben', 'sind', 'werden'], 1, '“fahren” as movement normally forms Perfekt with “sein”.'),
      _q('Ich habe gestern viel ___.', const ['arbeiten', 'gearbeitet', 'arbeitete'], 1, 'Perfekt requires the past participle “gearbeitet”.'),
      _q('Sie ___ einen Film gesehen.', const ['hat', 'ist', 'war'], 0, '“sehen” forms Perfekt with “haben”.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-a2-02',
    level: CefrLevel.a2,
    title: 'Dative case',
    explanation: 'The dative often marks an indirect object and follows prepositions such as mit, nach, aus, zu, von and bei. Masculine/neuter “der/das” becomes “dem”; feminine “die” becomes “der”.',
    examples: const <String>['Ich helfe dem Mann.', 'Sie fährt mit der Bahn.', 'Wir sprechen mit einem Kollegen.'],
    questions: <ChoiceQuestion>[
      _q('Ich fahre mit ___ Bus.', const ['der', 'den', 'dem'], 2, '“mit” always takes dative; Bus is masculine → dem Bus.'),
      _q('Er hilft ___ Frau.', const ['die', 'der', 'den'], 1, '“helfen” takes dative; feminine dative is “der”.'),
      _q('Wir sprechen mit ___ Kindern.', const ['den', 'die', 'der'], 0, 'Plural dative uses “den” and often adds -n to the noun.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-a2-03',
    level: CefrLevel.a2,
    title: 'Subordinate clauses: weil & dass',
    explanation: 'After subordinating conjunctions such as weil and dass, the conjugated verb moves to the end of the clause.',
    examples: const <String>['Ich bleibe zu Hause, weil ich krank bin.', 'Ich glaube, dass er heute kommt.'],
    questions: <ChoiceQuestion>[
      _q('Ich komme später, weil ich noch ___.', const ['arbeite', 'ich arbeite', 'arbeiten ich'], 0, 'In the subordinate clause, “arbeite” is at the end.'),
      _q('Ich weiß, dass sie in Berlin ___.', const ['wohnt', 'sie wohnt', 'wohnen'], 0, 'With “dass”, the conjugated verb goes to the clause end.'),
      _q('Choose the correct sentence.', const ['Weil ich bin müde, schlafe ich.', 'Weil ich müde bin, schlafe ich.', 'Weil bin ich müde, schlafe ich.'], 1, 'The verb “bin” belongs at the end of the weil-clause.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-a2-04',
    level: CefrLevel.a2,
    title: 'Comparatives & adjective basics',
    explanation: 'Comparatives usually add -er and superlatives use am …-sten/-esten. Common irregular forms include gut → besser and viel → mehr.',
    examples: const <String>['Berlin ist größer als Rostock.', 'Heute ist es wärmer.', 'Das ist am besten.'],
    questions: <ChoiceQuestion>[
      _q('Mein Zimmer ist ___ als deins.', const ['groß', 'größer', 'am größten'], 1, 'A comparison with “als” normally uses the comparative.'),
      _q('“gut” → comparative?', const ['guter', 'besser', 'mehr gut'], 1, '“gut” has the irregular comparative “besser”.'),
      _q('Heute ist der ___ Tag der Woche.', const ['wärmste', 'wärmer', 'warm'], 0, 'With a definite article, the superlative adjective takes an ending: der wärmste Tag.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-b1-01',
    level: CefrLevel.b1,
    title: 'Präteritum of sein, haben & modal verbs',
    explanation: 'In narration and formal writing, common verbs often use Präteritum: war, hatte, konnte, musste, wollte, durfte, sollte.',
    examples: const <String>['Früher war ich Student.', 'Ich musste lange warten.', 'Wir konnten nicht kommen.'],
    questions: <ChoiceQuestion>[
      _q('Gestern ___ ich keine Zeit.', const ['hatte', 'habe', 'gehabt'], 0, 'The Präteritum of “haben” for ich is “hatte”.'),
      _q('Wir ___ nicht teilnehmen.', const ['konnten', 'können', 'gekonnt'], 0, 'The Präteritum plural of “können” is “konnten”.'),
      _q('Als Kind ___ er sehr ruhig.', const ['war', 'ist gewesen', 'wäre'], 0, 'Narration commonly uses “war”.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-b1-02',
    level: CefrLevel.b1,
    title: 'Relative clauses',
    explanation: 'Relative pronouns agree in gender/number with the noun they refer to, but their case depends on their role inside the relative clause. The verb goes to the end.',
    examples: const <String>['Das ist der Mann, der hier arbeitet.', 'Das ist der Mann, den ich kenne.', 'Die Frau, mit der ich spreche, ist Ärztin.'],
    questions: <ChoiceQuestion>[
      _q('Das ist der Kollege, ___ mir hilft.', const ['der', 'den', 'dem'], 0, 'The pronoun is the subject of “hilft”, so nominative “der”.'),
      _q('Das ist der Film, ___ ich gesehen habe.', const ['der', 'den', 'dem'], 1, 'The film is the direct object of “gesehen” → accusative “den”.'),
      _q('Die Firma, bei ___ ich arbeite, ist groß.', const ['die', 'der', 'den'], 1, '“bei” takes dative; feminine dative relative pronoun is “der”.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-b1-03',
    level: CefrLevel.b1,
    title: 'Two-way prepositions',
    explanation: 'Prepositions such as in, an, auf, unter, über, vor, hinter, neben and zwischen take accusative for direction/change of location and dative for a static location.',
    examples: const <String>['Ich stelle die Tasse auf den Tisch.', 'Die Tasse steht auf dem Tisch.'],
    questions: <ChoiceQuestion>[
      _q('Ich gehe in ___ Küche.', const ['die', 'der', 'den'], 0, 'Movement toward a destination → accusative: in die Küche.'),
      _q('Ich bin in ___ Küche.', const ['die', 'der', 'den'], 1, 'Static location → dative: in der Küche.'),
      _q('Er hängt das Bild an ___ Wand.', const ['die', 'der', 'dem'], 0, 'Change of position/direction → accusative: an die Wand.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-b1-04',
    level: CefrLevel.b1,
    title: 'Konjunktiv II for politeness',
    explanation: 'würde + infinitive and forms such as hätte, wäre and könnte make requests, wishes and hypothetical statements more polite or less direct.',
    examples: const <String>['Könnten Sie mir helfen?', 'Ich hätte gern einen Kaffee.', 'Ich würde gern mehr reisen.'],
    questions: <ChoiceQuestion>[
      _q('Choose the most polite request.', const ['Hilf mir.', 'Könnten Sie mir helfen?', 'Du hilfst mir.'], 1, 'Konjunktiv II makes the request appropriately polite.'),
      _q('Ich ___ gern einen Termin.', const ['hätte', 'habe', 'hatte'], 0, '“Ich hätte gern …” is a standard polite formula.'),
      _q('Wenn ich mehr Zeit hätte, ___ ich mehr lesen.', const ['würde', 'werde', 'wurde'], 0, 'Hypothetical statements often use würde + infinitive.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-b2-01',
    level: CefrLevel.b2,
    title: 'Passive voice',
    explanation: 'The process passive is formed with werden + past participle. The state passive uses sein + past participle.',
    examples: const <String>['Die Maschine wird repariert.', 'Die Tür wurde geöffnet.', 'Die Tür ist geöffnet.'],
    questions: <ChoiceQuestion>[
      _q('The report is being written.', const ['Der Bericht wird geschrieben.', 'Der Bericht ist schreiben.', 'Der Bericht wurde schreiben.'], 0, 'Present process passive: wird + Partizip II.'),
      _q('Die Straße ___ gestern gesperrt.', const ['wurde', 'wird', 'hat'], 0, 'Past process passive uses wurde/wurden + Partizip II.'),
      _q('“Die Tür ist geschlossen” describes …', const ['a completed state', 'an ongoing action only', 'future time'], 0, 'sein + participle is the state passive.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-b2-02',
    level: CefrLevel.b2,
    title: 'Adjective declension',
    explanation: 'Adjective endings depend on case, gender and what information the article already provides. After a definite article many common forms use -e or -en; without an article the adjective carries more case/gender information.',
    examples: const <String>['der neue Computer', 'mit einem neuen Computer', 'frisches Brot', 'guter Kaffee'],
    questions: <ChoiceQuestion>[
      _q('mit einem ___ Kollegen', const ['netter', 'netten', 'nette'], 1, 'Dative masculine after “einem” uses -en.'),
      _q('___ Wasser ist wichtig.', const ['Frisches', 'Frische', 'Frischer'], 0, 'Neuter nominative without an article: frisches Wasser.'),
      _q('die ___ Aufgabe', const ['schwierige', 'schwierigen', 'schwieriger'], 0, 'Feminine nominative after definite article uses -e.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-b2-03',
    level: CefrLevel.b2,
    title: 'Complex connectors',
    explanation: 'Connectors express cause, contrast, consequence and concession. “obwohl” sends the verb to the end; “trotzdem” is an adverb and is followed by verb-second order.',
    examples: const <String>['Obwohl es regnet, gehen wir spazieren.', 'Es regnet. Trotzdem gehen wir spazieren.', 'Da die Zeit knapp ist, beginnen wir sofort.'],
    questions: <ChoiceQuestion>[
      _q('___ er müde war, arbeitete er weiter.', const ['Obwohl', 'Trotzdem', 'Deshalb'], 0, '“Obwohl” introduces a concessive subordinate clause.'),
      _q('Es war spät. ___ blieb sie noch.', const ['Trotzdem', 'Obwohl', 'Weil'], 0, '“Trotzdem” links two main-clause ideas and triggers inversion if placed first.'),
      _q('Da die Daten fehlen, ___ wir nicht entscheiden.', const ['können', 'wir können', 'könnt'], 0, 'After the subordinate clause, the main clause starts with the verb: können wir …'),
    ],
  ),
  GrammarLesson(
    id: 'gr-b2-04',
    level: CefrLevel.b2,
    title: 'Hypothetical past',
    explanation: 'Past counterfactuals use hätte/wäre + past participle, often with a modal infinitive construction.',
    examples: const <String>['Wenn ich das gewusst hätte, wäre ich früher gekommen.', 'Ich hätte mehr lernen sollen.'],
    questions: <ChoiceQuestion>[
      _q('Wenn wir früher losgefahren wären, ___ wir den Zug erreicht.', const ['hätten', 'haben', 'würden'], 0, 'Past result uses “hätten … erreicht”.'),
      _q('Ich ___ dir geholfen, wenn ich Zeit gehabt hätte.', const ['hätte', 'hatte', 'würde'], 0, 'Past counterfactual: hätte + Partizip II.'),
      _q('“Du hättest früher kommen sollen” means …', const ['You should have come earlier.', 'You will come earlier.', 'You had to come earlier.'], 0, 'It expresses a past recommendation/criticism.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-c1-01',
    level: CefrLevel.c1,
    title: 'Konjunktiv I & reported speech',
    explanation: 'Formal indirect speech often uses Konjunktiv I to mark information as reported rather than directly asserted. If the form is identical to indicative, Konjunktiv II may be used for clarity.',
    examples: const <String>['Er sagt, er sei krank.', 'Die Ministerin erklärte, die Lage habe sich verbessert.', 'Sie sagten, sie hätten nichts gewusst.'],
    questions: <ChoiceQuestion>[
      _q('Formal reported speech: Er sagt: “Ich bin müde.”', const ['Er sagt, er sei müde.', 'Er sagt, er ist müde.', 'Er sagt, er wäre müde gewesen.'], 0, 'Konjunktiv I “sei” marks reported speech.'),
      _q('Sie erklärt, sie ___ keine Zeit.', const ['habe', 'hat', 'hätte gehabt'], 0, 'Konjunktiv I of “haben” is “habe”.'),
      _q('Why use Konjunktiv I in news reports?', const ['To distance the writer from the claim', 'To form commands', 'To express future certainty'], 0, 'It signals that the statement is attributed to another source.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-c1-02',
    level: CefrLevel.c1,
    title: 'Participial attributes',
    explanation: 'German can compress relative clauses into participial attributes. Present participles express an active/ongoing relation; past participles often express a completed/passive relation.',
    examples: const <String>['die steigenden Kosten', 'die gestern veröffentlichten Zahlen', 'eine schnell wachsende Branche'],
    questions: <ChoiceQuestion>[
      _q('“die Zahlen, die gestern veröffentlicht wurden” →', const ['die gestern veröffentlichten Zahlen', 'die gestern veröffentlichende Zahlen', 'die veröffentlichen Zahlen gestern'], 0, 'A past participial attribute compactly expresses the passive relative clause.'),
      _q('“eine Firma, die schnell wächst” →', const ['eine schnell wachsende Firma', 'eine schnell gewachsene Firma', 'eine wachsen schnelle Firma'], 0, 'Present participle “wachsend” expresses an ongoing active process.'),
      _q('Participial attributes are especially common in …', const ['formal written German', 'only children’s speech', 'yes/no questions'], 0, 'They are a hallmark of compact written and technical style.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-c1-03',
    level: CefrLevel.c1,
    title: 'Nominal style & functional verb phrases',
    explanation: 'Formal German frequently uses nouns and fixed verb-noun combinations such as “eine Entscheidung treffen”, “in Betracht ziehen” and “zur Verfügung stehen”.',
    examples: const <String>['Wir treffen eine Entscheidung.', 'Diese Option kommt nicht in Betracht.', 'Die Daten stehen zur Verfügung.'],
    questions: <ChoiceQuestion>[
      _q('Which sounds most formal?', const ['Wir entscheiden bald.', 'Wir werden zeitnah eine Entscheidung treffen.', 'Wir machen bald Entscheidung.'], 1, 'The noun phrase “eine Entscheidung treffen” is typical formal style.'),
      _q('“in Betracht ziehen” means …', const ['to consider', 'to reject immediately', 'to publish'], 0, 'It is a common formal functional verb phrase meaning “consider”.'),
      _q('“zur Verfügung stehen” means …', const ['to be available', 'to disappear', 'to object'], 0, 'It indicates availability.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-c1-04',
    level: CefrLevel.c1,
    title: 'Advanced subordinate relations',
    explanation: 'Conjunctions such as sofern, indem, während, wohingegen and zumal express condition, means, contrast and additional justification with precision.',
    examples: const <String>['Sofern keine Einwände bestehen, beginnen wir.', 'Er löste das Problem, indem er den Algorithmus änderte.', 'Die Nachfrage stieg, wohingegen das Angebot sank.'],
    questions: <ChoiceQuestion>[
      _q('“provided that” is best expressed by …', const ['sofern', 'indem', 'zumal'], 0, '“sofern” introduces a condition.'),
      _q('Er verbesserte die Leistung, ___ er den Code optimierte.', const ['indem', 'obwohl', 'sofern'], 0, '“indem” expresses the means by which something is achieved.'),
      _q('Which connector expresses a strong contrast?', const ['wohingegen', 'sodass', 'zumal'], 0, '“wohingegen” contrasts two facts or developments.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-c2-01',
    level: CefrLevel.c2,
    title: 'Modal particles & pragmatic nuance',
    explanation: 'Particles such as doch, ja, eben, halt, wohl and mal change tone, shared assumptions and speaker attitude. Their force depends heavily on context and intonation.',
    examples: const <String>['Komm doch rein!', 'Das ist ja interessant.', 'Das ist eben so.', 'Er wird wohl später kommen.'],
    questions: <ChoiceQuestion>[
      _q('“Er wird wohl später kommen” most likely conveys …', const ['a probable assumption', 'a direct command', 'past certainty'], 0, '“wohl” often marks an inference or probability.'),
      _q('“Komm doch rein!” makes the invitation sound …', const ['encouraging/insistent', 'legally binding', 'strictly past tense'], 0, '“doch” can warmly encourage someone to act.'),
      _q('“Das ist eben so.” often conveys …', const ['acceptance of an unchangeable fact', 'a question', 'a future plan'], 0, '“eben” can signal resignation or matter-of-fact acceptance.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-c2-02',
    level: CefrLevel.c2,
    title: 'Information structure & marked word order',
    explanation: 'Advanced German manipulates the prefield, middle field and right bracket to manage topic, focus, contrast and processing weight while preserving grammatical constraints.',
    examples: const <String>['Gerade diesen Punkt hat niemand erwähnt.', 'Was die Finanzierung betrifft, bestehen weiterhin Zweifel.', 'Gelesen habe ich das Buch noch nicht.'],
    questions: <ChoiceQuestion>[
      _q('“Gelesen habe ich das Buch noch nicht” foregrounds …', const ['the action “gelesen” for contrast/focus', 'the subject only', 'a grammatical error'], 0, 'Fronting the participle gives it marked discourse focus.'),
      _q('“Was X betrifft, …” is mainly used to …', const ['set a topic frame', 'form a passive', 'mark a quotation'], 0, 'It explicitly establishes the topic under discussion.'),
      _q('Marked word order is acceptable when …', const ['it respects clause structure and serves discourse needs', 'verbs can occur anywhere freely', 'articles are omitted'], 0, 'German permits flexible ordering inside structural constraints.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-c2-03',
    level: CefrLevel.c2,
    title: 'Register, idiom & collocation',
    explanation: 'C2 competence includes selecting idiomatic collocations and shifting register. Semantically possible combinations may still sound non-native if the collocation is unusual.',
    examples: const <String>['eine Entscheidung treffen', 'Kritik üben', 'eine Frist einhalten', 'zur Kenntnis nehmen'],
    questions: <ChoiceQuestion>[
      _q('Choose the idiomatic collocation.', const ['Kritik üben', 'Kritik machen', 'Kritik bauen'], 0, '“Kritik üben” is the conventional collocation.'),
      _q('Formal equivalent of “merken” in an official context?', const ['zur Kenntnis nehmen', 'draufkommen', 'checken'], 0, '“zur Kenntnis nehmen” fits formal administrative register.'),
      _q('“eine Frist einhalten” means …', const ['meet a deadline', 'extend a deadline automatically', 'ignore a deadline'], 0, 'The collocation means to comply with a deadline.'),
    ],
  ),
  GrammarLesson(
    id: 'gr-c2-04',
    level: CefrLevel.c2,
    title: 'Dense academic syntax',
    explanation: 'Academic German can combine nominalization, passive voice, embedded clauses and prepositional attributes. Mastery means understanding and producing density without sacrificing clarity.',
    examples: const <String>['Unter Berücksichtigung der bislang veröffentlichten Ergebnisse lässt sich die Annahme nur eingeschränkt bestätigen.', 'Die aus der Untersuchung abzuleitenden Konsequenzen bedürfen weiterer Prüfung.'],
    questions: <ChoiceQuestion>[
      _q('“unter Berücksichtigung von” means …', const ['taking into account', 'in spite of forgetting', 'without examining'], 0, 'It is a formal prepositional phrase meaning “taking into account”.'),
      _q('“die abzuleitenden Konsequenzen” roughly means …', const ['the consequences to be derived', 'the consequences already forgotten', 'the impossible consequences'], 0, 'zu + present participial adjective can express something that is to/can be done.'),
      _q('Best principle for dense academic German?', const ['Use complexity only when it improves precision and cohesion', 'Maximize sentence length at all costs', 'Avoid verbs entirely'], 0, 'Advanced style balances density with readability.'),
    ],
  ),
];

final List<ListeningLesson> listeningLessons = <ListeningLesson>[
  ListeningLesson(id: 'li-a1-01', level: CefrLevel.a1, title: 'At the bakery', transcript: 'Guten Morgen. Ich hätte gern zwei Brötchen und ein Croissant, bitte. Möchten Sie noch etwas? Nein, danke. Das macht vier Euro zwanzig.', translation: 'Good morning. I would like two bread rolls and a croissant, please. Would you like anything else? No, thank you. That is €4.20.', questions: <ChoiceQuestion>[
    _q('What does the customer order?', const ['Two rolls and a croissant', 'Two coffees', 'A cake'], 0, 'The customer says “zwei Brötchen und ein Croissant”.'),
    _q('How much does it cost?', const ['€4.20', '€2.40', '€14.20'], 0, 'The seller says “vier Euro zwanzig”.'),
  ]),
  ListeningLesson(id: 'li-a1-02', level: CefrLevel.a1, title: 'Meeting a colleague', transcript: 'Hallo, ich heiße Lena. Ich arbeite seit Montag hier. Schön, dich kennenzulernen. Ich bin Amir und arbeite im Labor im zweiten Stock.', translation: 'Hello, my name is Lena. I have worked here since Monday. Nice to meet you. I am Amir and work in the laboratory on the second floor.', questions: <ChoiceQuestion>[
    _q('Where does Amir work?', const ['In the laboratory', 'In a restaurant', 'At a school'], 0, 'He says “ich arbeite im Labor”.'),
    _q('When did Lena start?', const ['Monday', 'Friday', 'Yesterday evening'], 0, 'She says “seit Montag”.'),
  ]),
  ListeningLesson(id: 'li-a1-03', level: CefrLevel.a1, title: 'A train announcement', transcript: 'Achtung am Gleis drei. Der Zug nach Berlin fährt heute zehn Minuten später ab. Die neue Abfahrtszeit ist neun Uhr vierzig.', translation: 'Attention on platform three. The train to Berlin departs ten minutes late today. The new departure time is 9:40.', questions: <ChoiceQuestion>[
    _q('Which platform?', const ['3', '10', '9'], 0, '“Gleis drei”.'),
    _q('What is the new departure time?', const ['09:40', '09:30', '10:40'], 0, 'The announcement says “neun Uhr vierzig”.'),
  ]),
  ListeningLesson(id: 'li-a2-01', level: CefrLevel.a2, title: 'Doctor appointment', transcript: 'Praxis Dr. Weber, guten Tag. Guten Tag, ich brauche einen Termin, weil ich seit drei Tagen Halsschmerzen habe. Wir hätten morgen um halb elf noch einen Termin frei.', translation: 'Dr Weber’s practice, hello. Hello, I need an appointment because I have had a sore throat for three days. We still have an appointment available tomorrow at 10:30.', questions: <ChoiceQuestion>[
    _q('Why does the caller need an appointment?', const ['Sore throat', 'Back pain', 'A vaccination only'], 0, 'The caller mentions “Halsschmerzen”.'),
    _q('When is the available appointment?', const ['Tomorrow at 10:30', 'Today at 11:30', 'Tomorrow at 9:00'], 0, '“morgen um halb elf” means 10:30.'),
  ]),
  ListeningLesson(id: 'li-a2-02', level: CefrLevel.a2, title: 'Weekend plans', transcript: 'Am Samstag möchte ich zuerst einkaufen. Danach treffe ich meine Schwester im Café. Wenn das Wetter gut ist, gehen wir am Nachmittag im Park spazieren.', translation: 'On Saturday I first want to go shopping. Afterwards I meet my sister in the café. If the weather is good, we will walk in the park in the afternoon.', questions: <ChoiceQuestion>[
    _q('What happens first?', const ['Shopping', 'A walk', 'Meeting in the park'], 0, '“zuerst einkaufen”.'),
    _q('What depends on the weather?', const ['The walk in the park', 'Shopping', 'The café meeting'], 0, 'The walk happens “wenn das Wetter gut ist”.'),
  ]),
  ListeningLesson(id: 'li-a2-03', level: CefrLevel.a2, title: 'Apartment message', transcript: 'Hallo Frau Klein, hier ist Jonas aus Wohnung vier. Unsere Heizung funktioniert seit gestern nicht mehr. Könnten Sie bitte jemanden schicken? Am Abend bin ich ab achtzehn Uhr zu Hause.', translation: 'Hello Ms Klein, this is Jonas from apartment four. Our heating has not worked since yesterday. Could you please send someone? I am at home from 6 p.m. in the evening.', questions: <ChoiceQuestion>[
    _q('What is broken?', const ['The heating', 'The window', 'The elevator'], 0, '“Unsere Heizung funktioniert … nicht mehr.”'),
    _q('When is Jonas at home?', const ['From 18:00', 'Before 08:00', 'Only at noon'], 0, 'He says “ab achtzehn Uhr”.'),
  ]),
  ListeningLesson(id: 'li-b1-01', level: CefrLevel.b1, title: 'Changing jobs', transcript: 'Nach fünf Jahren in derselben Firma habe ich beschlossen, die Stelle zu wechseln. Die Arbeit war sicher, aber ich hatte kaum Möglichkeiten, mich weiterzuentwickeln. Ab nächsten Monat beginne ich bei einem kleineren Unternehmen, wo ich mehr Verantwortung übernehmen kann.', translation: 'After five years in the same company I decided to change jobs. The job was secure, but I had hardly any opportunities to develop. From next month I will start at a smaller company where I can take on more responsibility.', questions: <ChoiceQuestion>[
    _q('Why is the speaker changing jobs?', const ['For development and more responsibility', 'Because the old company closed', 'To work fewer days only'], 0, 'The speaker mentions limited development and more responsibility in the new role.'),
    _q('When does the new job begin?', const ['Next month', 'Next year', 'Tomorrow'], 0, '“Ab nächsten Monat”.'),
  ]),
  ListeningLesson(id: 'li-b1-02', level: CefrLevel.b1, title: 'Radio weather report', transcript: 'Am Vormittag bleibt es im Norden überwiegend trocken. Gegen Nachmittag ziehen jedoch dichte Wolken auf, und an der Küste muss mit kräftigem Regen gerechnet werden. Die Temperaturen erreichen höchstens sechzehn Grad.', translation: 'In the morning it remains mostly dry in the north. Toward the afternoon, however, dense clouds arrive, and heavy rain is expected on the coast. Temperatures reach at most 16°C.', questions: <ChoiceQuestion>[
    _q('What is expected on the coast?', const ['Heavy rain', 'Snow', 'Strong sunshine all day'], 0, '“kräftiger Regen” is expected.'),
    _q('What is the maximum temperature?', const ['16°C', '26°C', '6°C'], 0, '“höchstens sechzehn Grad”.'),
  ]),
  ListeningLesson(id: 'li-b1-03', level: CefrLevel.b1, title: 'Course feedback', transcript: 'Der Sprachkurs hat mir insgesamt gut gefallen. Besonders hilfreich waren die kleinen Gesprächsgruppen. Allerdings hätte ich mir mehr schriftliche Übungen gewünscht, weil ich beim Schreiben noch viele Fehler mache.', translation: 'Overall I liked the language course. The small conversation groups were particularly helpful. However, I would have liked more written exercises because I still make many mistakes when writing.', questions: <ChoiceQuestion>[
    _q('What was especially helpful?', const ['Small conversation groups', 'Long lectures', 'Homework-free weeks'], 0, 'The speaker praises the “kleinen Gesprächsgruppen”.'),
    _q('What did the speaker want more of?', const ['Writing exercises', 'Exams', 'Videos'], 0, '“mehr schriftliche Übungen”.'),
  ]),
  ListeningLesson(id: 'li-b2-01', level: CefrLevel.b2, title: 'Remote work debate', transcript: 'Viele Beschäftigte schätzen die Flexibilität des Homeoffice. Gleichzeitig berichten Führungskräfte, dass spontane Abstimmungen schwieriger geworden sind. Entscheidend scheint daher weniger die Frage zu sein, ob man im Büro oder zu Hause arbeitet, sondern wie Teams ihre Zusammenarbeit organisieren.', translation: 'Many employees value the flexibility of working from home. At the same time, managers report that spontaneous coordination has become more difficult. The decisive question therefore seems to be less whether one works in the office or at home, but how teams organize their cooperation.', questions: <ChoiceQuestion>[
    _q('What is presented as the key issue?', const ['How teams organize collaboration', 'Banning remote work', 'Office rent'], 0, 'The final sentence identifies organization of teamwork as decisive.'),
    _q('What difficulty do managers mention?', const ['Spontaneous coordination', 'Higher salaries', 'Too many holidays'], 0, 'They report that spontaneous coordination is harder.'),
  ]),
  ListeningLesson(id: 'li-b2-02', level: CefrLevel.b2, title: 'Research presentation', transcript: 'Unsere Untersuchung zeigt einen deutlichen Zusammenhang zwischen regelmäßiger Bewegung und subjektivem Wohlbefinden. Allerdings lässt sich daraus noch keine eindeutige Kausalität ableiten, da weitere Faktoren wie Schlaf und Einkommen ebenfalls eine Rolle spielen.', translation: 'Our study shows a clear association between regular exercise and subjective well-being. However, no clear causality can yet be derived because other factors such as sleep and income also play a role.', questions: <ChoiceQuestion>[
    _q('What limitation is emphasized?', const ['Correlation does not prove clear causality', 'There were no participants', 'Exercise had no association'], 0, 'The speaker explicitly says causality cannot yet be clearly inferred.'),
    _q('Which additional factor is mentioned?', const ['Sleep', 'Eye color', 'Nationality'], 0, 'Sleep and income are mentioned.'),
  ]),
  ListeningLesson(id: 'li-b2-03', level: CefrLevel.b2, title: 'Customer complaint', transcript: 'Ich habe das Gerät vor drei Wochen bestellt, aber es ist bereits zweimal ausgefallen. Der Kundendienst war freundlich, konnte das Problem jedoch nicht dauerhaft beheben. Deshalb möchte ich entweder ein Ersatzgerät oder eine vollständige Rückerstattung.', translation: 'I ordered the device three weeks ago, but it has already failed twice. Customer service was friendly but could not fix the problem permanently. Therefore I want either a replacement device or a full refund.', questions: <ChoiceQuestion>[
    _q('What does the customer want?', const ['Replacement or full refund', 'A discount coupon only', 'A new manual'], 0, 'The customer explicitly asks for a replacement or refund.'),
    _q('How was customer service described?', const ['Friendly but ineffective long-term', 'Rude and unavailable', 'Perfectly successful'], 0, 'Friendly, but the problem was not permanently solved.'),
  ]),
  ListeningLesson(id: 'li-c1-01', level: CefrLevel.c1, title: 'Energy policy interview', transcript: 'Die Energiewende wird häufig auf den Ausbau erneuerbarer Quellen reduziert. Tatsächlich hängt ihr Erfolg jedoch ebenso von leistungsfähigen Netzen, Speicherkapazitäten und einer flexibleren Nachfrage ab. Werden diese Bereiche vernachlässigt, können selbst hohe Erzeugungskapazitäten zu Engpässen führen.', translation: 'The energy transition is often reduced to expanding renewable sources. In fact, its success also depends on capable grids, storage capacity and more flexible demand. If these areas are neglected, even high generation capacity can lead to bottlenecks.', questions: <ChoiceQuestion>[
    _q('What is the speaker’s main argument?', const ['The transition requires more than renewable generation', 'Renewables are unnecessary', 'Storage is the only issue'], 0, 'The argument is explicitly multi-factor.'),
    _q('What may happen if supporting systems are neglected?', const ['Bottlenecks', 'Automatic price stability', 'Unlimited storage'], 0, 'The speaker warns of “Engpässe”.'),
  ]),
  ListeningLesson(id: 'li-c1-02', level: CefrLevel.c1, title: 'Workplace mediation', transcript: 'Beide Seiten schildern den Konflikt unterschiedlich. Während das Team mangelnde Transparenz kritisiert, verweist die Leitung auf den hohen Zeitdruck. Eine tragfähige Lösung setzt voraus, dass nicht nur Positionen ausgetauscht, sondern die dahinterliegenden Interessen geklärt werden.', translation: 'Both sides describe the conflict differently. While the team criticizes a lack of transparency, management points to high time pressure. A sustainable solution requires not only exchanging positions but clarifying the underlying interests.', questions: <ChoiceQuestion>[
    _q('What is required for a sustainable solution?', const ['Clarifying underlying interests', 'Ignoring the team', 'Only increasing time pressure'], 0, 'The last sentence states this directly.'),
    _q('What does management cite?', const ['High time pressure', 'Lack of salary', 'Technical failure'], 0, '“die Leitung … verweist auf den hohen Zeitdruck”.'),
  ]),
  ListeningLesson(id: 'li-c1-03', level: CefrLevel.c1, title: 'Academic lecture excerpt', transcript: 'Bei der Interpretation statistischer Modelle ist zu beachten, dass Signifikanz und praktische Relevanz nicht gleichzusetzen sind. Ein Effekt kann statistisch hochsignifikant und zugleich so klein sein, dass er für reale Entscheidungen kaum Bedeutung besitzt.', translation: 'When interpreting statistical models, note that significance and practical relevance are not the same. An effect can be highly statistically significant yet so small that it has little importance for real decisions.', questions: <ChoiceQuestion>[
    _q('What distinction is emphasized?', const ['Statistical significance vs practical relevance', 'Mean vs median only', 'Qualitative vs quantitative data'], 0, 'That is the central contrast.'),
    _q('Can a highly significant effect be practically unimportant?', const ['Yes', 'No', 'Only in grammar studies'], 0, 'The lecturer explicitly says it can.'),
  ]),
  ListeningLesson(id: 'li-c2-01', level: CefrLevel.c2, title: 'Cultural commentary', transcript: 'Die Debatte krankt weniger an einem Mangel an Argumenten als an der Neigung, komplexe Zugehörigkeiten in eindeutige Kategorien zu pressen. Gerade dort, wo Biografien widersprüchlich und Mehrfachidentitäten alltäglich sind, erweist sich diese Eindeutigkeit als analytisch bequem, aber empirisch fragwürdig.', translation: 'The debate suffers less from a lack of arguments than from the tendency to force complex affiliations into unambiguous categories. Precisely where biographies are contradictory and multiple identities are commonplace, such unambiguity proves analytically convenient but empirically questionable.', questions: <ChoiceQuestion>[
    _q('What is the main criticism?', const ['Oversimplifying complex identities', 'A total lack of arguments', 'Too much empirical nuance'], 0, 'The speaker criticizes forcing complexity into clear-cut categories.'),
    _q('How is “Eindeutigkeit” characterized?', const ['Convenient analytically, questionable empirically', 'Necessary and always accurate', 'Completely irrelevant'], 0, 'This contrast appears in the final clause.'),
  ]),
  ListeningLesson(id: 'li-c2-02', level: CefrLevel.c2, title: 'Legal-policy analysis', transcript: 'Dass eine Regelung formal zulässig ist, besagt noch wenig über ihre Zweckmäßigkeit. Zu prüfen wäre vielmehr, ob der mit ihr verbundene Eingriff in einem angemessenen Verhältnis zu dem verfolgten Ziel steht und ob mildere, gleichermaßen wirksame Mittel zur Verfügung stehen.', translation: 'The fact that a regulation is formally permissible says little about its expediency. Rather, one must examine whether the associated intervention is proportionate to the objective pursued and whether milder, equally effective means are available.', questions: <ChoiceQuestion>[
    _q('Which principle is central?', const ['Proportionality', 'Chronological order', 'Majority voting only'], 0, 'The passage asks whether the intervention is proportionate to the goal.'),
    _q('What alternative should also be considered?', const ['Milder equally effective means', 'Stricter measures only', 'No alternatives'], 0, 'The final phrase mentions milder, equally effective means.'),
  ]),
  ListeningLesson(id: 'li-c2-03', level: CefrLevel.c2, title: 'Scientific critique', transcript: 'Die Studie ist methodisch sorgfältig, doch ihre weitreichenden Schlussfolgerungen werden durch das Design nur teilweise gedeckt. Insbesondere bleibt offen, inwieweit sich die unter kontrollierten Bedingungen beobachteten Effekte auf heterogene Alltagssituationen übertragen lassen.', translation: 'The study is methodologically careful, but its far-reaching conclusions are only partly supported by the design. In particular, it remains unclear to what extent the effects observed under controlled conditions can be transferred to heterogeneous everyday situations.', questions: <ChoiceQuestion>[
    _q('What concern is raised?', const ['External validity/generalizability', 'Spelling mistakes', 'No methods were used'], 0, 'The critique concerns transfer from controlled conditions to everyday situations.'),
    _q('Is the study described as methodologically careless?', const ['No', 'Yes', 'Not mentioned'], 0, 'It is explicitly called methodologically careful.'),
  ]),
];

final List<ReadingLesson> readingLessons = <ReadingLesson>[
  ReadingLesson(id: 're-a1-01', level: CefrLevel.a1, title: 'A simple email', passage: 'Hallo Mia, ich bin am Samstag in Hamburg. Mein Zug kommt um 11 Uhr an. Wollen wir um 12 Uhr im Café am Bahnhof essen? Liebe Grüße, Tom', questions: <ChoiceQuestion>[
    _q('When does Tom arrive?', const ['11:00', '12:00', 'Saturday evening'], 0, 'His train arrives at 11.'),
    _q('Where does he suggest meeting?', const ['Café at the station', 'Airport', 'Office'], 0, 'He suggests the café at the station.'),
  ]),
  ReadingLesson(id: 're-a1-02', level: CefrLevel.a1, title: 'Opening hours', passage: 'Stadtbibliothek: Montag bis Freitag 10–19 Uhr. Samstag 10–14 Uhr. Sonntag geschlossen. Anmeldung mit Personalausweis kostenlos.', questions: <ChoiceQuestion>[
    _q('Is the library open on Sunday?', const ['No', 'Yes, until 14:00', 'Only in the evening'], 0, '“Sonntag geschlossen”.'),
    _q('What is needed for free registration?', const ['ID card', 'Credit card', 'Train ticket'], 0, '“mit Personalausweis kostenlos”.'),
  ]),
  ReadingLesson(id: 're-a1-03', level: CefrLevel.a1, title: 'Apartment ad', passage: 'Kleine Wohnung im Zentrum, 45 m², zwei Zimmer, Küche und Bad. Warmmiete 650 Euro. Bushaltestelle direkt vor dem Haus. Frei ab 1. September.', questions: <ChoiceQuestion>[
    _q('How many rooms?', const ['2', '1', '4'], 0, '“zwei Zimmer”.'),
    _q('When is it available?', const ['1 September', 'Immediately', '1 October'], 0, '“Frei ab 1. September”.'),
  ]),
  ReadingLesson(id: 're-a2-01', level: CefrLevel.a2, title: 'Gym notice', passage: 'Wegen Renovierungsarbeiten bleibt der Fitnessraum am kommenden Montag geschlossen. Kurse im großen Saal finden wie geplant statt. Mitglieder können an diesem Tag außerdem kostenlos das Partnerstudio in der Hafenstraße nutzen.', questions: <ChoiceQuestion>[
    _q('What is closed?', const ['The fitness room', 'All courses', 'The partner studio'], 0, 'Only the fitness room is closed.'),
    _q('What can members use for free?', const ['Partner studio', 'Swimming pool', 'Sauna'], 0, 'The partner studio is free that day.'),
  ]),
  ReadingLesson(id: 're-a2-02', level: CefrLevel.a2, title: 'Delivery message', passage: 'Ihre Bestellung konnte heute nicht zugestellt werden, da niemand zu Hause war. Das Paket liegt ab morgen 10 Uhr in der Filiale am Markt. Bitte bringen Sie einen Ausweis und diese Benachrichtigung mit.', questions: <ChoiceQuestion>[
    _q('Why was delivery unsuccessful?', const ['Nobody was home', 'Wrong address', 'The package was damaged'], 0, 'The message says nobody was at home.'),
    _q('What should the customer bring?', const ['ID and notification', 'Cash only', 'A photo'], 0, 'Both are required.'),
  ]),
  ReadingLesson(id: 're-a2-03', level: CefrLevel.a2, title: 'Course description', passage: 'Der Kurs richtet sich an Lernende mit Grundkenntnissen. Wir üben vor allem Gespräche aus Alltag und Beruf. Ein Lehrbuch ist nicht nötig; alle Materialien werden digital bereitgestellt.', questions: <ChoiceQuestion>[
    _q('Who is the course for?', const ['Learners with basic knowledge', 'Complete experts only', 'Children only'], 0, 'It is for learners with “Grundkenntnissen”.'),
    _q('Is a textbook required?', const ['No', 'Yes', 'Only two textbooks'], 0, 'The text says it is not necessary.'),
  ]),
  ReadingLesson(id: 're-b1-01', level: CefrLevel.b1, title: 'Local news', passage: 'Die Stadt plant, den Verkehr im Zentrum zu reduzieren. Ab dem kommenden Jahr sollen mehrere Straßen nur noch für Busse, Fahrräder und Lieferverkehr geöffnet sein. Geschäftsleute befürchten weniger Kundschaft, während Umweltverbände die Pläne begrüßen.', questions: <ChoiceQuestion>[
    _q('What is the city trying to reduce?', const ['Traffic in the center', 'Bus services', 'Business opening hours'], 0, 'The first sentence says this explicitly.'),
    _q('Who welcomes the plan?', const ['Environmental groups', 'All business owners', 'Delivery drivers only'], 0, '“Umweltverbände … begrüßen” the plans.'),
  ]),
  ReadingLesson(id: 're-b1-02', level: CefrLevel.b1, title: 'Volunteer project', passage: 'Ein Nachbarschaftsverein sucht Freiwillige, die ältere Menschen beim Umgang mit Smartphones unterstützen. Vorkenntnisse als Lehrkraft sind nicht erforderlich. Wichtig sind Geduld, Zuverlässigkeit und etwa zwei Stunden Zeit pro Woche.', questions: <ChoiceQuestion>[
    _q('What do volunteers help with?', const ['Smartphone use', 'House construction', 'Driving lessons'], 0, 'They help older people use smartphones.'),
    _q('Is teaching experience required?', const ['No', 'Yes', 'Only university teachers'], 0, 'It explicitly says it is not required.'),
  ]),
  ReadingLesson(id: 're-b1-03', level: CefrLevel.b1, title: 'Travel blog', passage: 'Wir wollten ursprünglich mit dem Auto in die Berge fahren. Wegen des starken Schneefalls entschieden wir uns jedoch kurzfristig für den Zug. Das war eine gute Entscheidung: Wir kamen zwar etwas später an, mussten uns aber nicht um glatte Straßen kümmern.', questions: <ChoiceQuestion>[
    _q('Why did they take the train?', const ['Heavy snow', 'The car was sold', 'Train tickets were free'], 0, 'Snow caused the change of plan.'),
    _q('What disadvantage did the train have?', const ['They arrived a little later', 'It was dangerous', 'They got lost'], 0, '“Wir kamen zwar etwas später an”.'),
  ]),
  ReadingLesson(id: 're-b2-01', level: CefrLevel.b2, title: 'Four-day workweek', passage: 'Pilotprojekte zur Vier-Tage-Woche liefern bislang kein einheitliches Bild. Einige Unternehmen berichten von höherer Zufriedenheit bei stabiler Produktivität, andere verzeichnen zusätzlichen Koordinationsaufwand. Entscheidend dürfte sein, ob Arbeitsprozesse tatsächlich neu organisiert werden oder lediglich dieselbe Arbeitsmenge in weniger Tage gepresst wird.', questions: <ChoiceQuestion>[
    _q('What conclusion does the text support?', const ['Results depend on how work is reorganized', 'The four-day week always fails', 'Productivity always doubles'], 0, 'The text emphasizes implementation rather than a universal outcome.'),
    _q('What problem do some companies report?', const ['Extra coordination effort', 'No employees', 'No technology'], 0, '“zusätzlicher Koordinationsaufwand”.'),
  ]),
  ReadingLesson(id: 're-b2-02', level: CefrLevel.b2, title: 'Digital privacy', passage: 'Viele Apps sammeln Daten, die für ihre Kernfunktion nicht zwingend erforderlich sind. Nutzerinnen und Nutzer stimmen dem oft zu, ohne die Konsequenzen vollständig zu überblicken. Transparente Einstellungen helfen, lösen das Problem aber nur teilweise, solange Geschäftsmodelle stark auf datenbasierter Werbung beruhen.', questions: <ChoiceQuestion>[
    _q('Why are settings only a partial solution?', const ['Business models still rely heavily on data-driven advertising', 'Users cannot read', 'Apps have no settings'], 0, 'The final clause explains the structural limitation.'),
    _q('What kind of data collection is criticized?', const ['Data not strictly needed for core functionality', 'Only login data', 'No data at all'], 0, 'The first sentence states this.'),
  ]),
  ReadingLesson(id: 're-b2-03', level: CefrLevel.b2, title: 'University policy', passage: 'Die Hochschule möchte Prüfungen stärker kompetenzorientiert gestalten. Statt ausschließlich Faktenwissen abzufragen, sollen Studierende häufiger reale Problemstellungen analysieren. Kritiker warnen jedoch davor, Grundlagenwissen zu unterschätzen, da komplexe Anwendungen ohne solide Fachkenntnisse kaum möglich seien.', questions: <ChoiceQuestion>[
    _q('What change is proposed?', const ['More real-world problem analysis', 'No examinations', 'Only memorization'], 0, 'The proposal emphasizes competence-oriented tasks.'),
    _q('What do critics warn against?', const ['Undervaluing foundational knowledge', 'Using real problems', 'Studying too much'], 0, 'They argue applications still require strong fundamentals.'),
  ]),
  ReadingLesson(id: 're-c1-01', level: CefrLevel.c1, title: 'AI in recruitment', passage: 'Automatisierte Auswahlverfahren versprechen, Bewerbungen schneller und konsistenter zu bewerten. Doch Konsistenz ist nicht mit Fairness gleichzusetzen. Werden historische Personaldaten als Trainingsgrundlage verwendet, können bestehende Verzerrungen reproduziert werden. Eine verantwortungsvolle Nutzung setzt daher transparente Kriterien, regelmäßige Audits und menschliche Eingriffsmöglichkeiten voraus.', questions: <ChoiceQuestion>[
    _q('What is the central warning?', const ['Consistent decisions can still reproduce bias', 'Automation is always fair', 'Historical data is never used'], 0, 'The text explicitly distinguishes consistency from fairness.'),
    _q('Which safeguard is recommended?', const ['Regular audits', 'Removing all humans', 'Keeping criteria secret'], 0, 'Audits are one of the listed safeguards.'),
  ]),
  ReadingLesson(id: 're-c1-02', level: CefrLevel.c1, title: 'Urban climate adaptation', passage: 'Städte reagieren auf zunehmende Hitzewellen mit mehr Grünflächen, verschatteten Plätzen und entsiegelten Böden. Solche Maßnahmen verbessern nicht nur das Mikroklima, sondern können zugleich Aufenthaltsqualität und Biodiversität erhöhen. Konflikte entstehen dort, wo begrenzter Raum zwischen Verkehr, Wohnen und Klimaanpassung neu verteilt werden muss.', questions: <ChoiceQuestion>[
    _q('Why can conflicts arise?', const ['Urban space must be redistributed among competing uses', 'Green areas have no benefits', 'Heatwaves are decreasing'], 0, 'The final sentence describes competing spatial demands.'),
    _q('Name one co-benefit of adaptation.', const ['Biodiversity', 'More sealed surfaces', 'Higher heat exposure'], 0, 'Biodiversity and quality of public space are mentioned.'),
  ]),
  ReadingLesson(id: 're-c1-03', level: CefrLevel.c1, title: 'Scientific uncertainty', passage: 'Wissenschaftliche Unsicherheit wird in öffentlichen Debatten häufig als Schwäche missverstanden. Tatsächlich ist die Angabe von Unsicherheiten ein wesentliches Qualitätsmerkmal seriöser Forschung. Sie zeigt, welche Schlussfolgerungen durch Daten gut gestützt sind und wo weitere Untersuchungen notwendig bleiben.', questions: <ChoiceQuestion>[
    _q('How does the text frame uncertainty?', const ['As a quality feature when transparently reported', 'As proof of bad science', 'As something to hide'], 0, 'Transparent uncertainty is described as essential to serious research.'),
    _q('What does uncertainty reporting help show?', const ['Where evidence is strong and where research is still needed', 'Only who funded a study', 'Whether grammar is correct'], 0, 'That distinction is explicitly stated.'),
  ]),
  ReadingLesson(id: 're-c2-01', level: CefrLevel.c2, title: 'Institutional trust', passage: 'Vertrauen in Institutionen ist weder bloß eine Frage individueller Einstellung noch ein automatisch verfügbares gesellschaftliches Kapital. Es entsteht in wiederholten Erfahrungen mit Verfahren, deren Ergebnisse nicht immer den eigenen Präferenzen entsprechen müssen, die aber als nachvollziehbar, korrigierbar und grundsätzlich fair gelten. Gerade deshalb kann übermäßige Personalisierung institutioneller Entscheidungen Vertrauen kurzfristig mobilisieren und langfristig zugleich untergraben.', questions: <ChoiceQuestion>[
    _q('According to the text, what sustains institutional trust?', const ['Repeated experience of understandable, correctable and fair procedures', 'Always getting one’s preferred result', 'Personal charisma alone'], 0, 'The passage grounds trust in procedural experience.'),
    _q('What paradox is noted about personalization?', const ['It may mobilize trust short-term but erode it long-term', 'It always increases trust', 'It has no effect'], 0, 'The final sentence states this tension.'),
  ]),
  ReadingLesson(id: 're-c2-02', level: CefrLevel.c2, title: 'Limits of metrics', passage: 'Kennzahlen schaffen Vergleichbarkeit, doch gerade ihre scheinbare Eindeutigkeit verführt dazu, das Messbare mit dem Relevanten gleichzusetzen. Sobald Akteure ihr Verhalten an einer Kennzahl ausrichten, verändert die Messung zudem den Gegenstand, den sie abzubilden vorgibt. Gute Steuerung verlangt deshalb nicht weniger, sondern reflektierter eingesetzte Indikatoren.', questions: <ChoiceQuestion>[
    _q('What is the author’s position?', const ['Metrics are useful but must be used reflectively', 'Metrics should be abolished', 'Only measurable things matter'], 0, 'The conclusion calls for more reflective use, not abandonment.'),
    _q('How can measurement change its object?', const ['People adapt behavior to the metric', 'Numbers physically alter objects', 'It cannot'], 0, 'The text notes behavioral adaptation to indicators.'),
  ]),
  ReadingLesson(id: 're-c2-03', level: CefrLevel.c2, title: 'Language and precision', passage: 'Präzision ist nicht mit terminologischer Dichte zu verwechseln. Ein Text kann voller Fachbegriffe sein und dennoch unklar bleiben, wenn Beziehungen zwischen Aussagen implizit oder logisch unstimmig sind. Umgekehrt kann eine vergleichsweise einfache Formulierung hochpräzise sein, sofern sie die entscheidenden Unterscheidungen sichtbar macht.', questions: <ChoiceQuestion>[
    _q('What distinction is central?', const ['Precision vs terminological density', 'Grammar vs spelling', 'Speech vs writing'], 0, 'The opening sentence makes this distinction.'),
    _q('When can simple wording be highly precise?', const ['When it makes decisive distinctions explicit', 'Never', 'Only in fiction'], 0, 'The final sentence gives this condition.'),
  ]),
];

final List<WritingLesson> writingLessons = <WritingLesson>[
  WritingLesson(id: 'wr-a1-01', level: CefrLevel.a1, title: 'Introduce yourself', prompt: 'Write a short self-introduction in German.', guidance: const ['Name and where you live', 'Work/study', 'One hobby', 'Use simple present tense'], minWords: 30, keywords: const ['ich', 'wohne', 'arbeite', 'gern'], example: 'Hallo! Ich heiße Sara und wohne in Rostock. Ich arbeite in einem Labor. In meiner Freizeit lese ich gern und gehe spazieren. Ich lerne Deutsch, weil ich hier lebe.'),
  WritingLesson(id: 'wr-a1-02', level: CefrLevel.a1, title: 'Daily routine', prompt: 'Describe a normal weekday.', guidance: const ['Morning', 'Work or study', 'Evening', 'Use time expressions'], minWords: 35, keywords: const ['morgens', 'dann', 'abends', 'ich'], example: 'Morgens stehe ich um sieben Uhr auf. Dann frühstücke ich und fahre zur Arbeit. Am Nachmittag komme ich nach Hause. Abends koche ich und lese ein Buch.'),
  WritingLesson(id: 'wr-a1-03', level: CefrLevel.a1, title: 'A simple message', prompt: 'Write a message to a friend and suggest meeting this weekend.', guidance: const ['Greeting', 'Suggest a day/time', 'Suggest a place', 'Ask if it works'], minWords: 30, keywords: const ['samstag', 'treffen', 'uhr', 'kannst'], example: 'Hallo Tom, hast du am Samstag Zeit? Wir können uns um 15 Uhr im Café am Bahnhof treffen. Danach können wir spazieren gehen. Kannst du kommen? Liebe Grüße!'),
  WritingLesson(id: 'wr-a2-01', level: CefrLevel.a2, title: 'Describe a past weekend', prompt: 'Write about what you did last weekend.', guidance: const ['Use Perfekt', 'Mention at least three activities', 'Add your opinion'], minWords: 60, keywords: const ['habe', 'bin', 'war', 'wochenende'], example: 'Am Wochenende bin ich nach Berlin gefahren. Dort habe ich einen Freund besucht. Wir haben zusammen gegessen und später ein Museum besucht. Das Wetter war kalt, aber die Reise hat mir sehr gut gefallen.'),
  WritingLesson(id: 'wr-a2-02', level: CefrLevel.a2, title: 'Request by email', prompt: 'Write a polite email asking for an appointment.', guidance: const ['Formal greeting', 'Reason for appointment', 'Possible times', 'Polite closing'], minWords: 60, keywords: const ['termin', 'könnten', 'bitte', 'mit freundlichen'], example: 'Sehr geehrte Frau Weber, ich möchte gern einen Termin vereinbaren, weil ich eine Frage zu meinem Vertrag habe. Könnten Sie mir bitte einen Termin am Dienstag oder Mittwoch anbieten? Mit freundlichen Grüßen, …'),
  WritingLesson(id: 'wr-a2-03', level: CefrLevel.a2, title: 'Compare two options', prompt: 'Compare living in a city with living in a village.', guidance: const ['Use comparative forms', 'Give one advantage and disadvantage of each', 'State your preference'], minWords: 70, keywords: const ['als', 'aber', 'vorteil', 'lieber'], example: 'In der Stadt gibt es mehr Geschäfte und bessere Busverbindungen als im Dorf. Dafür ist es oft lauter. Im Dorf ist es ruhiger, aber man braucht häufiger ein Auto. Ich wohne lieber in der Stadt.'),
  WritingLesson(id: 'wr-b1-01', level: CefrLevel.b1, title: 'Opinion paragraph', prompt: 'Should employees be allowed to work from home? Give your opinion.', guidance: const ['Introduce the topic', 'Give two arguments', 'Mention a counterargument', 'Conclude clearly'], minWords: 100, keywords: const ['meiner meinung', 'einerseits', 'andererseits', 'deshalb'], example: 'Meiner Meinung nach sollte Homeoffice möglich sein, wenn die Tätigkeit dafür geeignet ist. Einerseits spart es Pendelzeit und ermöglicht konzentriertes Arbeiten. Andererseits kann der direkte Austausch fehlen. Deshalb halte ich ein flexibles Hybridmodell für sinnvoll.'),
  WritingLesson(id: 'wr-b1-02', level: CefrLevel.b1, title: 'Formal complaint', prompt: 'Write a complaint about a product that stopped working.', guidance: const ['State when you bought it', 'Describe the problem', 'Explain what you already tried', 'Request a solution'], minWords: 100, keywords: const ['gekauft', 'problem', 'leider', 'ersatz'], example: 'Sehr geehrte Damen und Herren, vor drei Wochen habe ich bei Ihnen einen Kopfhörer gekauft. Leider funktioniert die linke Seite seit gestern nicht mehr. Ich habe das Gerät bereits zurückgesetzt, ohne Erfolg. Ich bitte daher um Ersatz oder Rückerstattung.'),
  WritingLesson(id: 'wr-b1-03', level: CefrLevel.b1, title: 'Tell a story', prompt: 'Write about a situation where a plan changed unexpectedly.', guidance: const ['Set the scene', 'Use past tense', 'Explain what changed', 'Describe the result'], minWords: 120, keywords: const ['zuerst', 'plötzlich', 'deshalb', 'am ende'], example: 'Zuerst wollten wir mit dem Auto ans Meer fahren. Plötzlich begann es stark zu schneien. Deshalb entschieden wir uns für den Zug. Am Ende kamen wir später an als geplant, hatten aber trotzdem einen schönen Tag.'),
  WritingLesson(id: 'wr-b2-01', level: CefrLevel.b2, title: 'Balanced argument', prompt: 'Discuss advantages and disadvantages of a four-day workweek.', guidance: const ['Neutral introduction', 'Develop both sides', 'Use complex connectors', 'Give a reasoned conclusion'], minWords: 170, keywords: const ['einerseits', 'andererseits', 'obwohl', 'insgesamt'], example: 'Die Vier-Tage-Woche wird zunehmend diskutiert. Einerseits kann eine kürzere Arbeitswoche Motivation und Erholung verbessern. Andererseits besteht die Gefahr, dass dieselbe Arbeitsmenge lediglich verdichtet wird. Obwohl erste Pilotprojekte positive Ergebnisse zeigen, hängt der Erfolg stark von der Arbeitsorganisation ab. Insgesamt erscheint ein differenzierter Ansatz sinnvoll.'),
  WritingLesson(id: 'wr-b2-02', level: CefrLevel.b2, title: 'Report recommendation', prompt: 'Write a short recommendation to improve public transport in a city.', guidance: const ['Define the problem', 'Present two measures', 'Discuss feasibility', 'Recommend priorities'], minWords: 170, keywords: const ['maßnahme', 'zudem', 'allerdings', 'empfehlen'], example: 'Um den öffentlichen Verkehr attraktiver zu machen, sollten Taktung und Zuverlässigkeit verbessert werden. Eine zentrale Maßnahme wäre ein dichterer Takt zu Stoßzeiten. Zudem könnten digitale Echtzeitinformationen ausgebaut werden. Allerdings verursachen zusätzliche Fahrten höhere Kosten. Daher empfehle ich, zunächst stark ausgelastete Linien zu priorisieren.'),
  WritingLesson(id: 'wr-b2-03', level: CefrLevel.b2, title: 'Academic-style summary', prompt: 'Summarize a fictional study showing a correlation between sleep and performance without claiming causality.', guidance: const ['State the finding', 'Mention the limitation', 'Avoid causal overclaiming', 'Use formal language'], minWords: 160, keywords: const ['zusammenhang', 'jedoch', 'kausal', 'untersuchung'], example: 'Die Untersuchung zeigt einen positiven Zusammenhang zwischen Schlafdauer und Testleistung. Personen mit längerer Schlafdauer erzielten im Durchschnitt höhere Werte. Aus diesem Zusammenhang lässt sich jedoch keine eindeutige kausale Wirkung ableiten, da mögliche Störfaktoren nicht vollständig kontrolliert wurden.'),
  WritingLesson(id: 'wr-c1-01', level: CefrLevel.c1, title: 'Position paper', prompt: 'Write a nuanced position on the use of AI systems in hiring.', guidance: const ['Define benefits and risks', 'Distinguish consistency from fairness', 'Propose safeguards', 'Use formal connectors'], minWords: 230, keywords: const ['einerseits', 'fairness', 'transparenz', 'prüfung'], example: 'Automatisierte Auswahlverfahren können Prozesse beschleunigen und Entscheidungen konsistenter machen. Konsistenz ist jedoch nicht mit Fairness gleichzusetzen. Werden verzerrte historische Daten verwendet, können bestehende Benachteiligungen reproduziert werden. Eine verantwortungsvolle Einführung setzt daher transparente Kriterien, regelmäßige Prüfungen und wirksame menschliche Kontrollmöglichkeiten voraus.'),
  WritingLesson(id: 'wr-c1-02', level: CefrLevel.c1, title: 'Research discussion', prompt: 'Discuss why statistical significance should not be confused with practical relevance.', guidance: const ['Define both concepts', 'Give an example', 'Explain implications for decisions', 'Maintain academic register'], minWords: 230, keywords: const ['signifikanz', 'relevanz', 'effekt', 'entscheidung'], example: 'Statistische Signifikanz beschreibt, vereinfacht gesagt, wie gut ein beobachteter Effekt mit einer Nullhypothese vereinbar ist; sie sagt jedoch nichts darüber aus, ob der Effekt praktisch bedeutsam ist. Bei sehr großen Stichproben können selbst minimale Unterschiede signifikant werden. Für Entscheidungen sollten deshalb zusätzlich Effektgröße, Unsicherheit und Anwendungskontext berücksichtigt werden.'),
  WritingLesson(id: 'wr-c1-03', level: CefrLevel.c1, title: 'Policy memo', prompt: 'Recommend two measures for urban heat adaptation and discuss trade-offs.', guidance: const ['Executive-style opening', 'Two concrete measures', 'Trade-offs and constraints', 'Prioritized recommendation'], minWords: 240, keywords: const ['hitzewelle', 'maßnahme', 'zielkonflikt', 'priorität'], example: 'Angesichts häufigerer Hitzewellen sollten Städte kurzfristig Verschattung und langfristig die Entsiegelung stark belasteter Flächen priorisieren. Beide Maßnahmen verbessern das Mikroklima, konkurrieren jedoch mit Verkehrs- und Nutzungsansprüchen. Bei knappen Flächen empfiehlt sich daher eine Priorisierung besonders vulnerabler Quartiere.'),
  WritingLesson(id: 'wr-c2-01', level: CefrLevel.c2, title: 'Critical essay', prompt: 'Critically examine the claim that “what can be measured is what matters.”', guidance: const ['Interrogate the premise', 'Use conceptual distinctions', 'Address a counterposition', 'Conclude without oversimplifying'], minWords: 320, keywords: const ['messbar', 'relevanz', 'indikator', 'dennoch'], example: 'Die Gleichsetzung des Messbaren mit dem Relevanten verwechselt epistemische Zugänglichkeit mit normativer Bedeutung. Kennzahlen sind unverzichtbar, weil sie Vergleichbarkeit schaffen; dennoch bilden sie nur jene Aspekte ab, die operationalisiert wurden. Sobald Entscheidungen ausschließlich an Indikatoren ausgerichtet werden, droht zudem eine Anpassung des Verhaltens an die Messgröße. Eine reflektierte Steuerung benötigt daher quantitative Kennzahlen, qualitative Urteile und eine explizite Diskussion der zugrunde liegenden Ziele.'),
  WritingLesson(id: 'wr-c2-02', level: CefrLevel.c2, title: 'Register transformation', prompt: 'Write a formal administrative response that rejects a request while remaining respectful and precise.', guidance: const ['Acknowledge the request', 'State the legal/organizational reason', 'Avoid unnecessarily harsh language', 'Offer a viable next step'], minWords: 260, keywords: const ['antrag', 'leider', 'grundlage', 'möglichkeit'], example: 'Vielen Dank für Ihren Antrag und die ergänzenden Unterlagen. Nach Prüfung der derzeit maßgeblichen Voraussetzungen kann dem Antrag in der vorliegenden Form leider nicht entsprochen werden, da die erforderliche Grundlage für eine Ausnahmeentscheidung nicht gegeben ist. Unberührt davon bleibt die Möglichkeit, einen aktualisierten Antrag einzureichen, sofern die fehlenden Nachweise nachgereicht werden können.'),
  WritingLesson(id: 'wr-c2-03', level: CefrLevel.c2, title: 'Synthesis & critique', prompt: 'Synthesize two hypothetical studies that reach different conclusions about remote work and explain how both could be valid.', guidance: const ['Compare designs and populations', 'Discuss measurement choices', 'Reconcile apparently conflicting findings', 'Identify what further evidence is needed'], minWords: 340, keywords: const ['studie', 'stichprobe', 'methodisch', 'widerspruch'], example: 'Dass zwei Studien zu unterschiedlichen Ergebnissen gelangen, stellt nicht zwangsläufig einen echten Widerspruch dar. Unterscheiden sich Stichproben, Tätigkeitsprofile oder die Operationalisierung von Produktivität, können beide Befunde innerhalb ihres jeweiligen Geltungsbereichs plausibel sein. Methodisch wäre daher zunächst zu prüfen, ob tatsächlich dieselbe Frage untersucht wurde. Weiterführende Evidenz sollte vergleichbare Messgrößen, längere Beobachtungszeiträume und heterogene Berufsgruppen einbeziehen.'),
];

Iterable<GrammarLesson> grammarFor(CefrLevel level) sync* {
  yield* grammarLessons.where((lesson) => lesson.level == level);
  yield* supplementalGrammarLessons.where((lesson) => lesson.level == level);
}
Iterable<ListeningLesson> listeningFor(CefrLevel level) sync* {
  yield* listeningLessons.where((lesson) => lesson.level == level);
  yield* supplementalListeningLessons.where((lesson) => lesson.level == level);
}
Iterable<ReadingLesson> readingFor(CefrLevel level) sync* {
  yield* readingLessons.where((lesson) => lesson.level == level);
  yield* supplementalReadingLessons.where((lesson) => lesson.level == level);
}
Iterable<WritingLesson> writingFor(CefrLevel level) sync* {
  yield* writingLessons.where((lesson) => lesson.level == level);
  yield* supplementalWritingLessons.where((lesson) => lesson.level == level);
  yield* extraWritingLessons.where((lesson) => lesson.level == level);
}
Iterable<SpeakingLesson> speakingFor(CefrLevel level) =>
    speakingLessons.where((lesson) => lesson.level == level);
