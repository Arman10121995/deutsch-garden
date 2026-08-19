import 'models.dart';

class _GrammarSpec {
  const _GrammarSpec(this.id, this.level, this.title, this.rule, this.correct, this.wrong);
  final String id;
  final CefrLevel level;
  final String title;
  final String rule;
  final String correct;
  final String wrong;
}

GrammarLesson _build(_GrammarSpec s) => GrammarLesson(
      id: s.id,
      level: s.level,
      title: s.title,
      explanation: s.rule,
      examples: <String>[s.correct],
      questions: <ChoiceQuestion>[
        ChoiceQuestion(
          prompt: 'Which sentence is the better example of this rule?',
          options: <String>[s.correct, s.wrong],
          correctIndex: 0,
          explanation: s.rule,
        ),
        ChoiceQuestion(
          prompt: 'Which statement is correct?',
          options: <String>[s.rule, 'The opposite rule applies in standard German.'],
          correctIndex: 0,
          explanation: s.rule,
        ),
      ],
    );

final List<GrammarLesson> supplementalGrammarLessons =
    _specs.map(_build).toList(growable: false);

const List<_GrammarSpec> _specs = <_GrammarSpec>[
  // A1 — sentence building, forms and high-frequency structures.
  _GrammarSpec('gr-a1-x01', CefrLevel.a1, 'Personal pronouns', 'Use ich, du, er/sie/es, wir, ihr and sie/Sie as subject pronouns; the verb agrees with the subject.', 'Wir lernen Deutsch.', 'Wir lernt Deutsch.'),
  _GrammarSpec('gr-a1-x02', CefrLevel.a1, 'sein and haben', 'The very frequent verbs sein and haben are irregular and must be learned by person.', 'Du bist müde und hast Hunger.', 'Du seid müde und habe Hunger.'),
  _GrammarSpec('gr-a1-x03', CefrLevel.a1, 'Definite and indefinite articles', 'Nouns have grammatical gender; in the nominative use der/die/das and ein/eine/ein.', 'Das Kind hat eine Frage.', 'Der Kind hat ein Frage.'),
  _GrammarSpec('gr-a1-x04', CefrLevel.a1, 'Possessive determiners', 'mein, dein, sein, ihr, unser and euer take article-like endings and agree with the noun.', 'Das ist meine Tasche.', 'Das ist mein Tasche.'),
  _GrammarSpec('gr-a1-x05', CefrLevel.a1, 'Accusative objects', 'For a masculine direct object, der becomes den and ein becomes einen; feminine and neuter forms often stay unchanged.', 'Ich kaufe einen Kaffee.', 'Ich kaufe ein Kaffee.'),
  _GrammarSpec('gr-a1-x06', CefrLevel.a1, 'Separable verbs', 'In a main clause, the conjugated verb stem stays in position 2 and a separable prefix goes to the end.', 'Der Zug fährt um acht Uhr ab.', 'Der Zug abfährt um acht Uhr.'),
  _GrammarSpec('gr-a1-x07', CefrLevel.a1, 'Imperative', 'Use imperative forms for simple requests and instructions; common forms include Komm!, Kommt! and Kommen Sie!.', 'Kommen Sie bitte herein!', 'Sie kommen bitte herein!'),
  _GrammarSpec('gr-a1-x08', CefrLevel.a1, 'kein versus nicht', 'Use kein with an indefinite/no-article noun and nicht to negate verbs, adjectives or more specific sentence elements.', 'Ich habe kein Auto, aber das ist nicht schlimm.', 'Ich habe nicht Auto, aber das ist kein schlimm.'),
  _GrammarSpec('gr-a1-x09', CefrLevel.a1, 'Coordinating conjunctions', 'und, aber, oder and denn connect main clauses without sending the conjugated verb to the end.', 'Ich koche, aber mein Bruder bestellt Pizza.', 'Ich koche, aber mein Bruder Pizza bestellt.'),
  _GrammarSpec('gr-a1-x10', CefrLevel.a1, 'Time–manner–place basics', 'A neutral German ordering often puts time before manner and place, while the conjugated verb remains in position 2.', 'Ich fahre morgen mit dem Bus nach Berlin.', 'Ich morgen nach Berlin mit dem Bus fahre.'),
  _GrammarSpec('gr-a1-x11', CefrLevel.a1, 'Dative with common phrases', 'Some frequent prepositions such as mit, nach, aus, zu and bei require the dative case.', 'Ich fahre mit dem Bus.', 'Ich fahre mit den Bus.'),
  _GrammarSpec('gr-a1-x12', CefrLevel.a1, 'Basic Perfekt', 'A common spoken past form uses haben or sein plus a past participle at the end.', 'Ich habe gestern gearbeitet.', 'Ich habe gestern arbeiten.'),

  // A2 — routine narration and clause linking.
  _GrammarSpec('gr-a2-x01', CefrLevel.a2, 'Perfekt: haben or sein', 'Most verbs form Perfekt with haben; movement/change-of-state intransitives commonly use sein.', 'Wir sind nach Hause gegangen.', 'Wir haben nach Hause gegangen.'),
  _GrammarSpec('gr-a2-x02', CefrLevel.a2, 'Past participles', 'Regular verbs often form ge-…-t, many irregular verbs ge-…-en; inseparable prefixes and -ieren usually omit ge-.', 'Sie hat telefoniert und danach gegessen.', 'Sie hat getelefoniert und danach geesst.'),
  _GrammarSpec('gr-a2-x03', CefrLevel.a2, 'Dative objects', 'Many verbs and indirect-object structures use the dative; masculine/neuter der/das become dem and plural often takes den + -n.', 'Ich gebe dem Mann den Schlüssel.', 'Ich gebe den Mann der Schlüssel.'),
  _GrammarSpec('gr-a2-x04', CefrLevel.a2, 'Two-way prepositions', 'With an, auf, hinter, in, neben, über, unter, vor, zwischen, use accusative for destination/change of location and dative for static location.', 'Ich stelle die Tasse auf den Tisch; sie steht auf dem Tisch.', 'Ich stelle die Tasse auf dem Tisch; sie steht auf den Tisch.'),
  _GrammarSpec('gr-a2-x05', CefrLevel.a2, 'Subordinate clauses', 'With weil, dass, wenn, obwohl and similar subordinators, the finite verb normally goes to the end of the subordinate clause.', 'Ich bleibe zu Hause, weil ich krank bin.', 'Ich bleibe zu Hause, weil ich bin krank.'),
  _GrammarSpec('gr-a2-x06', CefrLevel.a2, 'Reflexive verbs', 'Reflexive verbs use a reflexive pronoun that agrees with the subject; accusative forms include mich, dich, sich, uns, euch.', 'Ich interessiere mich für Technik.', 'Ich interessiere mir für Technik.'),
  _GrammarSpec('gr-a2-x07', CefrLevel.a2, 'Comparative and superlative', 'Comparatives commonly use -er + als; superlatives often use am …-sten or an inflected adjective.', 'Der Zug ist schneller als der Bus.', 'Der Zug ist mehr schnell wie der Bus.'),
  _GrammarSpec('gr-a2-x08', CefrLevel.a2, 'Präteritum of sein, haben and modals', 'war, hatte and modal-verb Präteritum forms are common even in everyday spoken German.', 'Früher musste ich jeden Samstag arbeiten.', 'Früher gemusst ich jeden Samstag arbeiten.'),
  _GrammarSpec('gr-a2-x09', CefrLevel.a2, 'Adjective endings: common patterns', 'Adjectives before nouns take endings that reflect article type, case, gender and number.', 'Ich trinke einen heißen Tee.', 'Ich trinke einen heiß Tee.'),
  _GrammarSpec('gr-a2-x10', CefrLevel.a2, 'Relative clauses: introduction', 'Relative clauses add information about a noun; the relative pronoun reflects gender/number and its case inside the relative clause.', 'Das ist der Mann, der hier arbeitet.', 'Das ist der Mann, er hier arbeitet.'),
  _GrammarSpec('gr-a2-x11', CefrLevel.a2, 'Infinitive with zu', 'Many verbs and expressions are followed by zu + infinitive; separable verbs place zu between prefix and stem.', 'Ich versuche, früher aufzustehen.', 'Ich versuche, früher zu aufstehen.'),
  _GrammarSpec('gr-a2-x12', CefrLevel.a2, 'Indirect questions', 'Indirect questions use a question word or ob and subordinate-clause word order with the finite verb at the end.', 'Kannst du mir sagen, wann der Zug kommt?', 'Kannst du mir sagen, wann kommt der Zug?'),

  // B1 — independent, connected discourse.
  _GrammarSpec('gr-b1-x01', CefrLevel.b1, 'Adjective declension system', 'Strong, weak and mixed adjective endings distribute case/gender information according to the determiner before the adjective.', 'Wir wohnen in einem alten Haus.', 'Wir wohnen in einem alte Haus.'),
  _GrammarSpec('gr-b1-x02', CefrLevel.b1, 'Genitive and possession', 'The genitive can mark possession and occurs after some prepositions; masculine/neuter nouns often add -(e)s.', 'Wegen des schlechten Wetters bleiben wir zu Hause.', 'Wegen dem schlechte Wetter bleiben wir zu Hause.'),
  _GrammarSpec('gr-b1-x03', CefrLevel.b1, 'Relative clauses across cases', 'Choose the relative pronoun by gender/number of the antecedent and by the role it has inside the relative clause.', 'Die Kollegin, mit der ich arbeite, kommt aus Wien.', 'Die Kollegin, mit die ich arbeite, kommt aus Wien.'),
  _GrammarSpec('gr-b1-x04', CefrLevel.b1, 'Passive voice', 'The process passive uses werden + past participle; tense is carried by werden.', 'Die Straße wird morgen gesperrt.', 'Die Straße ist morgen sperren.'),
  _GrammarSpec('gr-b1-x05', CefrLevel.b1, 'Konjunktiv II: polite and hypothetical', 'würde + infinitive and forms such as hätte, wäre, könnte express politeness, wishes and unreal/hypothetical situations.', 'Wenn ich mehr Zeit hätte, würde ich öfter reisen.', 'Wenn ich mehr Zeit habe, würde ich öfter reiste.'),
  _GrammarSpec('gr-b1-x06', CefrLevel.b1, 'um…zu, ohne…zu, statt…zu', 'Use these infinitive clauses when the understood subject is normally the same as in the main clause.', 'Er spart Geld, um ein Fahrrad zu kaufen.', 'Er spart Geld, um er ein Fahrrad kauft.'),
  _GrammarSpec('gr-b1-x07', CefrLevel.b1, 'Temporal connectors', 'als usually refers to a single past event; wenn to repeated/present/future conditions; während, bevor, nachdem and seitdem express time relations.', 'Als ich klein war, wohnte ich in Delhi.', 'Wenn ich klein war einmal, wohnte ich in Delhi.'),
  _GrammarSpec('gr-b1-x08', CefrLevel.b1, 'Plusquamperfekt', 'Use hatte/war + past participle to mark an event completed before another past reference point.', 'Nachdem wir gegessen hatten, gingen wir spazieren.', 'Nachdem wir gegessen haben, gingen wir gestern vorher spazieren.'),
  _GrammarSpec('gr-b1-x09', CefrLevel.b1, 'Pronoun order', 'In many neutral patterns, unstressed pronouns occur early; when both objects are pronouns, accusative often precedes dative.', 'Ich gebe es dir morgen.', 'Ich gebe dir morgen es.'),
  _GrammarSpec('gr-b1-x10', CefrLevel.b1, 'Verb-preposition combinations', 'Many verbs govern a fixed preposition and case, which should be learned as a unit.', 'Wir warten auf den Bus.', 'Wir warten für den Bus.'),
  _GrammarSpec('gr-b1-x11', CefrLevel.b1, 'da-/wo- compounds', 'For things/ideas, German frequently uses darauf, damit, worauf, womit and related forms instead of preposition + pronoun.', 'Worauf wartest du? – Ich warte darauf.', 'Auf was wartest du? – Ich warte auf es.'),
  _GrammarSpec('gr-b1-x12', CefrLevel.b1, 'Connector word order', 'Subordinators send the verb to the end; conjunctive adverbs such as deshalb occupy a position and trigger verb-second inversion.', 'Es regnet; deshalb bleiben wir zu Hause.', 'Es regnet; deshalb wir bleiben zu Hause.'),

  // B2 — complex syntax and register control.
  _GrammarSpec('gr-b2-x01', CefrLevel.b2, 'Passive with modal verbs', 'With a modal, the lexical participle and werden infinitive form the final verbal bracket.', 'Die Daten müssen sorgfältig geprüft werden.', 'Die Daten müssen sorgfältig werden geprüft.'),
  _GrammarSpec('gr-b2-x02', CefrLevel.b2, 'State passive', 'sein + past participle often describes the resulting state, while werden + participle focuses on the process.', 'Die Tür ist geschlossen; sie wurde um acht Uhr geschlossen.', 'Die Tür wird geschlossen seit gestern als Zustand.'),
  _GrammarSpec('gr-b2-x03', CefrLevel.b2, 'Passive alternatives', 'man, sich lassen + infinitive and sein + zu + infinitive can replace passive constructions depending on meaning/register.', 'Das Problem lässt sich lösen.', 'Das Problem lässt lösen sich.'),
  _GrammarSpec('gr-b2-x04', CefrLevel.b2, 'Konjunktiv I: reported speech', 'Formal reported speech often uses Konjunktiv I to distance the reporter from the proposition.', 'Die Ministerin sagte, die Lage sei stabil.', 'Die Ministerin sagte, die Lage ist stabil sei.'),
  _GrammarSpec('gr-b2-x05', CefrLevel.b2, 'Nominalisation', 'Formal texts often express actions as nouns, frequently with prepositional or genitive complements.', 'Nach der Einführung des Systems sank die Fehlerzahl.', 'Nach das System einführen sank die Fehlerzahl.'),
  _GrammarSpec('gr-b2-x06', CefrLevel.b2, 'Participial attributes', 'Present and past participles can function as attributive adjectives and take adjective endings.', 'Die gestern veröffentlichten Ergebnisse sind überraschend.', 'Die gestern veröffentlichte Ergebnisse sind überraschend.'),
  _GrammarSpec('gr-b2-x07', CefrLevel.b2, 'Extended adjective phrases', 'German can place substantial modifiers before a noun; the whole attribute ends with the adjective/participle agreeing with the noun.', 'Die für morgen geplante Sitzung fällt aus.', 'Die geplante für morgen Sitzung fällt aus.'),
  _GrammarSpec('gr-b2-x08', CefrLevel.b2, 'Concessive and adversative linking', 'obwohl, obgleich, selbst wenn, zwar…aber, dennoch and hingegen express different forms of contrast/concession.', 'Obwohl die Kosten stiegen, wurde das Projekt fortgesetzt.', 'Obwohl die Kosten stiegen, das Projekt wurde fortgesetzt.'),
  _GrammarSpec('gr-b2-x09', CefrLevel.b2, 'Conditional alternatives', 'Conditions can be expressed with wenn/falls/sofern and sometimes without a conjunction through verb-first structure.', 'Sollten Fragen auftreten, melden Sie sich bitte.', 'Sollten auftreten Fragen, Sie melden sich bitte.'),
  _GrammarSpec('gr-b2-x10', CefrLevel.b2, 'N-declension', 'Many masculine nouns such as Student, Kunde and Mensch take -(e)n in most non-nominative singular forms.', 'Ich spreche mit einem Studenten.', 'Ich spreche mit einem Student.'),
  _GrammarSpec('gr-b2-x11', CefrLevel.b2, 'Advanced infinitive clauses', 'zu-infinitive clauses can have complex complements; with brauchen in negated contexts, zu + infinitive is common.', 'Du brauchst das Formular nicht sofort auszufüllen.', 'Du brauchst nicht das Formular sofort ausfüllen zu.'),
  _GrammarSpec('gr-b2-x12', CefrLevel.b2, 'Information structure', 'The prefield can foreground time, object or other information, but a German declarative main clause keeps the finite verb in position 2.', 'Diesen Vorschlag halte ich für sinnvoll.', 'Diesen Vorschlag ich halte für sinnvoll.'),

  // C1 — advanced syntax, compression and discourse stance.
  _GrammarSpec('gr-c1-x01', CefrLevel.c1, 'Reported speech: tense and distance', 'Konjunktiv I is preferred where distinct; Konjunktiv II or würde-forms can avoid ambiguity or add greater distance.', 'Der Bericht besagt, die Nachfrage habe deutlich zugenommen.', 'Der Bericht besagt, die Nachfrage hat deutlich zugenommen habe.'),
  _GrammarSpec('gr-c1-x02', CefrLevel.c1, 'Functional verb constructions', 'Formal German frequently combines a semantically light verb with a noun, e.g. in Betracht ziehen or zur Verfügung stellen.', 'Wir ziehen mehrere Alternativen in Betracht.', 'Wir ziehen in mehrere Alternativen Betracht.'),
  _GrammarSpec('gr-c1-x03', CefrLevel.c1, 'Nominal style and verbal reformulation', 'Advanced control includes switching between dense nominal style and clearer verbal clauses according to genre.', 'Nach Abschluss der Prüfung werden die Ergebnisse veröffentlicht.', 'Nach abschließen die Prüfung werden die Ergebnisse veröffentlicht.'),
  _GrammarSpec('gr-c1-x04', CefrLevel.c1, 'Complex participial attributes', 'Long participial attributes compress relative-clause information and require accurate adjective endings.', 'Die von mehreren Instituten gemeinsam erhobenen Daten wurden ausgewertet.', 'Die von mehreren Instituten gemeinsam erhobene Daten wurden ausgewertet.'),
  _GrammarSpec('gr-c1-x05', CefrLevel.c1, 'Modal passive meanings', 'sein + zu + infinitive, sich lassen and modal passive structures differ subtly in necessity, possibility and style.', 'Die Ergebnisse sind mit Vorsicht zu interpretieren.', 'Die Ergebnisse sind mit Vorsicht interpretieren.'),
  _GrammarSpec('gr-c1-x06', CefrLevel.c1, 'Advanced genitive/prepositional style', 'Formal registers use complex prepositions such as hinsichtlich, angesichts, infolge and ungeachtet, often with genitive complements.', 'Angesichts der neuen Befunde ist eine Neubewertung nötig.', 'Angesichts die neuen Befunde ist eine Neubewertung nötig.'),
  _GrammarSpec('gr-c1-x07', CefrLevel.c1, 'Correlative connectors', 'Pairs such as je…desto, einerseits…andererseits, weder…noch and nicht nur…sondern auch organize complex relations.', 'Je früher wir beginnen, desto eher sind wir fertig.', 'Je früher wir beginnen, desto wir sind eher fertig.'),
  _GrammarSpec('gr-c1-x08', CefrLevel.c1, 'Modal particles and stance', 'Particles such as doch, wohl, ja, eben and halt can encode assumptions, shared knowledge and speaker stance; meaning is context-sensitive.', 'Das dürfte wohl die sinnvollste Lösung sein.', 'Das dürfte die wohl sinnvollste sein Lösung.'),
  _GrammarSpec('gr-c1-x09', CefrLevel.c1, 'Scope of negation', 'Positioning nicht can change which constituent is negated; advanced writing should make contrast and scope unambiguous.', 'Nicht alle Teilnehmenden stimmten dem Vorschlag zu.', 'Alle nicht Teilnehmenden stimmten dem Vorschlag zu.'),
  _GrammarSpec('gr-c1-x10', CefrLevel.c1, 'Complex comparison', 'als ob/als wenn + Konjunktiv can express unreal comparison; je…desto expresses proportional change.', 'Er spricht, als hätte er alles selbst erlebt.', 'Er spricht, als hat er alles selbst erlebt.'),
  _GrammarSpec('gr-c1-x11', CefrLevel.c1, 'Cohesive reference', 'Pronominal adverbs, demonstratives and lexical reference chains help connect arguments without unnecessary repetition.', 'Die Finanzierung bleibt unsicher. Davon hängt jedoch der Zeitplan ab.', 'Die Finanzierung bleibt unsicher. Von es hängt jedoch der Zeitplan ab.'),
  _GrammarSpec('gr-c1-x12', CefrLevel.c1, 'Register-sensitive word order', 'German permits flexible middle-field ordering, but choices signal information structure, weight and register rather than being arbitrary.', 'Den Antrag hat die Kommission nach langer Beratung schließlich abgelehnt.', 'Den Antrag die Kommission hat schließlich abgelehnt.'),

  // C2 — stylistic mastery and nuanced reformulation.
  _GrammarSpec('gr-c2-x01', CefrLevel.c2, 'Marked prefield and emphasis', 'Experienced writers deliberately front constituents for contrast or thematic progression while preserving the verb-second constraint.', 'Gerade diese Annahme halte ich für problematisch.', 'Gerade diese Annahme ich halte für problematisch.'),
  _GrammarSpec('gr-c2-x02', CefrLevel.c2, 'Ellipsis and controlled omission', 'Ellipsis may omit recoverable material for economy or style, but only when reference remains clear.', 'Je früher, desto besser.', 'Je früher, desto besser ist es früher desto.'),
  _GrammarSpec('gr-c2-x03', CefrLevel.c2, 'Evidential and epistemic modality', 'scheinen, offenbar, wohl, dürfte and reported-speech forms allow fine calibration of certainty and source of information.', 'Die Maßnahme dürfte kaum ausreichen.', 'Die Maßnahme wird sicher vielleicht ausreichen dürfte.'),
  _GrammarSpec('gr-c2-x04', CefrLevel.c2, 'Counterfactual past', 'Past counterfactuals use hätte/wäre + past participle, with modal infinitive clusters requiring special word order.', 'Hätte man früher reagiert, wäre der Schaden geringer ausgefallen.', 'Hatte man früher reagiert, würde der Schaden geringer ausgefallen.'),
  _GrammarSpec('gr-c2-x05', CefrLevel.c2, 'Complex infinitive clusters', 'With modal verbs in perfect subordinate clauses, German uses an Ersatzinfinitiv and special placement of the finite auxiliary.', '…, weil er früher hätte gehen müssen.', '…, weil er früher gehen gemusst hätte.'),
  _GrammarSpec('gr-c2-x06', CefrLevel.c2, 'Rhetorical nominalisation', 'Nominalisation can create abstraction and cohesion, but mastery includes avoiding needless bureaucratic density.', 'Die schrittweise Umsetzung erleichtert die Evaluation.', 'Das schrittweise umsetzen erleichtert die Evaluation.'),
  _GrammarSpec('gr-c2-x07', CefrLevel.c2, 'Perspective in reported discourse', 'Pronouns, tense, modality and deixis must remain coherent when shifting between narrator and reported speaker perspectives.', 'Sie erklärte, sie habe damals nicht wissen können, welche Folgen dies haben würde.', 'Sie erklärte, ich habe damals nicht wissen können, welche Folgen gestern hat.'),
  _GrammarSpec('gr-c2-x08', CefrLevel.c2, 'Pragmatic mitigation', 'Advanced formal German softens claims with modal verbs, subjunctive forms, particles and cautious lexical choices where appropriate.', 'Es ließe sich einwenden, dass die Datenbasis zu schmal ist.', 'Es ist absolut falsch, vielleicht könnte man sagen.'),
  _GrammarSpec('gr-c2-x09', CefrLevel.c2, 'Idiomatic prepositional patterns', 'Near-native control requires selecting conventional preposition-case combinations and fixed phraseology rather than translating literally.', 'Der Befund steht im Einklang mit früheren Studien.', 'Der Befund steht in Einklang zu früheren Studien.'),
  _GrammarSpec('gr-c2-x10', CefrLevel.c2, 'Cleft-like and focusing structures', 'German can focus information through constructions such as was…betrifft, gerade/ausgerechnet, es ist…der/die or fronting.', 'Was die Kosten betrifft, besteht noch Klärungsbedarf.', 'Was betrifft die Kosten, besteht noch Klärungsbedarf.'),
  _GrammarSpec('gr-c2-x11', CefrLevel.c2, 'Ambiguity control', 'At C2, grammar choices should prevent unintended attachment, reference and scope ambiguity, especially in dense sentences.', 'Die Studie, die 2025 veröffentlicht wurde, bestätigt den Befund.', 'Die Studie bestätigt den Befund, die 2025 veröffentlicht wurde.'),
  _GrammarSpec('gr-c2-x12', CefrLevel.c2, 'Style transformation', 'Mastery includes reformulating the same proposition between conversational, neutral, academic and administrative registers without changing its core meaning.', 'Die Untersuchung legt nahe, dass weitere Daten erforderlich sind.', 'Die Untersuchung sagt so, dass man halt mehr Daten braucht, akademisch.'),
];
