import 'package:flutter/foundation.dart';
import 'dart:math';
import 'models.dart';

enum AssessmentDomain { vocabulary, grammar, reading, listening }

extension AssessmentDomainX on AssessmentDomain {
  String get label => switch (this) {
        AssessmentDomain.vocabulary => 'Vocabulary',
        AssessmentDomain.grammar => 'Grammar',
        AssessmentDomain.reading => 'Reading',
        AssessmentDomain.listening => 'Listening',
      };

  String get emoji => switch (this) {
        AssessmentDomain.vocabulary => '🌱',
        AssessmentDomain.grammar => '🧩',
        AssessmentDomain.reading => '📖',
        AssessmentDomain.listening => '🎧',
      };
}

class PlacementQuestion {
  const PlacementQuestion({
    required this.id,
    required this.level,
    required this.domain,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.contextText = '',
    this.spokenText = '',
  });

  final String id;
  final CefrLevel level;
  final AssessmentDomain domain;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String contextText;
  final String spokenText;
}

/// A range the true ability plausibly lies in, given a finite sample.
@immutable
class ConfidenceInterval {
  const ConfidenceInterval(this.low, this.high);
  final double low;
  final double high;
  double get width => high - low;

  @override
  bool operator ==(Object other) =>
      other is ConfidenceInterval && other.low == low && other.high == high;

  @override
  int get hashCode => Object.hash(low, high);

  @override
  String toString() =>
      '${(low * 100).round()}-${(high * 100).round()}%';
}

/// Wilson score interval for a proportion.
///
/// Not the textbook normal approximation, which is wrong in exactly the
/// situation a placement test lives in: small samples and proportions near 0
/// or 1. Six out of six under the normal approximation gives an interval of
/// zero width -- a claim of certainty from six questions -- while Wilson
/// gives roughly 61-100%, which is the honest answer.
ConfidenceInterval wilsonInterval(int correct, int total,
    {double z = placementConfidenceZ}) {
  if (total <= 0) return const ConfidenceInterval(0, 1);
  final double n = total.toDouble();
  final double p = correct / n;
  final double z2 = z * z;
  final double denominator = 1 + z2 / n;
  final double centre = p + z2 / (2 * n);
  final double spread =
      z * sqrt(p * (1 - p) / n + z2 / (4 * n * n));
  final double low = (centre - spread) / denominator;
  final double high = (centre + spread) / denominator;
  return ConfidenceInterval(low.clamp(0.0, 1.0), high.clamp(0.0, 1.0));
}

/// What a band's answers support saying.
enum BandVerdict {
  /// The whole interval sits above the threshold.
  pass,

  /// The whole interval sits below it.
  fail,

  /// The threshold is inside the interval, so the sample cannot tell.
  unclear,
}

class PlacementBandResult {
  const PlacementBandResult({
    required this.level,
    required this.correct,
    required this.total,
  });
  final CefrLevel level;
  final int correct;
  final int total;
  double get ratio => total == 0 ? 0 : correct / total;

  ConfidenceInterval get interval => wilsonInterval(correct, total);

  /// Whether the answers actually distinguish this learner from the
  /// threshold, or merely fell on one side of it.
  ///
  /// Four out of six is 67% and passes on a bare comparison, but its interval
  /// runs from about 30% to 90%: it does not distinguish someone who has the
  /// level from someone who guessed two. That is the coin flip a band
  /// boundary used to be decided on.
  BandVerdict verdict({
    double threshold = placementThreshold,
    double z = placementConfidenceZ,
  }) {
    final ConfidenceInterval ci = wilsonInterval(correct, total, z: z);
    if (ci.low > threshold) return BandVerdict.pass;
    if (ci.high < threshold) return BandVerdict.fail;
    return BandVerdict.unclear;
  }
}

/// The share of a band a learner has to get right to be placed above it.
const double placementThreshold = 0.67;

/// The operating point for placement decisions: 80% confidence.
///
/// Chosen against measurement, not convention. At the conventional 95%
/// (z = 1.96) a ten-item band can only ever settle on a clean sweep: 9/10
/// still spans the threshold, so a rule that waits for 95% would never
/// terminate at any bank size worth authoring, and the test would ask every
/// question of every learner to no purpose.
///
/// 80% settles 6/6, 9/10 and 10/10 at the top and 3/10 or worse at the
/// bottom, which is the behaviour wanted: obvious cases stop early,
/// borderline ones get the extra four items. It is also the right register
/// for the decision -- a placement recommendation is low-stakes and the
/// learner can change it in Profile, so demanding the certainty of a
/// clinical trial would cost them time and buy nothing.
const double placementConfidenceZ = 1.2816;

/// Six questions per CEFR band. The assessment is intentionally an app-level
/// diagnostic, not a certified CEFR examination. Each band samples vocabulary,
/// grammar, reading and listening.
const List<PlacementQuestion> placementQuestions = <PlacementQuestion>[
  // A1
  PlacementQuestion(id:'pl-a1-01', level:CefrLevel.a1, domain:AssessmentDomain.vocabulary, prompt:'What does “der Bahnhof” mean?', options:<String>['train station','hospital','supermarket','school'], correctIndex:0, explanation:'“der Bahnhof” means train station.'),
  PlacementQuestion(id:'pl-a1-02', level:CefrLevel.a1, domain:AssessmentDomain.vocabulary, prompt:'Choose the German word for “today”.', options:<String>['heute','gestern','morgen','später'], correctIndex:0, explanation:'“heute” means today.'),
  PlacementQuestion(id:'pl-a1-03', level:CefrLevel.a1, domain:AssessmentDomain.grammar, prompt:'Choose the correct sentence.', options:<String>['Ich lerne Deutsch.','Ich Deutsch lerne.','Ich lernen Deutsch.','Lerne ich Deutsch jeden Tag.'], correctIndex:0, explanation:'In a normal statement the finite verb is in position 2.'),
  PlacementQuestion(id:'pl-a1-04', level:CefrLevel.a1, domain:AssessmentDomain.grammar, prompt:'Ich sehe ___ Mann.', options:<String>['den','der','dem','des'], correctIndex:0, explanation:'Masculine accusative uses “den”.'),
  PlacementQuestion(id:'pl-a1-05', level:CefrLevel.a1, domain:AssessmentDomain.reading, contextText:'Mara arbeitet heute bis 16 Uhr. Danach kauft sie im Supermarkt ein.', prompt:'What does Mara do after work?', options:<String>['She goes shopping.','She goes to school.','She sleeps.','She travels.'], correctIndex:0, explanation:'“Danach kauft sie im Supermarkt ein.”'),
  PlacementQuestion(id:'pl-a1-06', level:CefrLevel.a1, domain:AssessmentDomain.listening, spokenText:'Der Bus kommt um zehn Uhr.', prompt:'When does the bus arrive?', options:<String>['10:00','9:00','11:00','12:00'], correctIndex:0, explanation:'The audio says “um zehn Uhr”.'),

  // A2
  PlacementQuestion(id:'pl-a2-01', level:CefrLevel.a2, domain:AssessmentDomain.vocabulary, prompt:'What does “verschieben” mean in an appointment context?', options:<String>['to postpone','to confirm','to pay','to repair'], correctIndex:0, explanation:'“einen Termin verschieben” = to postpone/reschedule an appointment.'),
  PlacementQuestion(id:'pl-a2-02', level:CefrLevel.a2, domain:AssessmentDomain.vocabulary, prompt:'Which expression means “to be interested in”?', options:<String>['sich interessieren für','sich kümmern um','warten auf','bestehen aus'], correctIndex:0, explanation:'“sich interessieren für” means to be interested in.'),
  PlacementQuestion(id:'pl-a2-03', level:CefrLevel.a2, domain:AssessmentDomain.grammar, prompt:'Choose the correct subordinate clause.', options:<String>['…, weil ich heute arbeiten muss.','…, weil ich muss heute arbeiten.','…, weil muss ich heute arbeiten.','…, weil heute ich muss arbeiten.'], correctIndex:0, explanation:'The finite modal verb goes to the end in the subordinate clause.'),
  PlacementQuestion(id:'pl-a2-04', level:CefrLevel.a2, domain:AssessmentDomain.grammar, prompt:'Ich stelle die Tasche ___ Tisch.', options:<String>['auf den','auf dem','bei den','mit dem'], correctIndex:0, explanation:'Destination/change of location with “auf” takes accusative.'),
  PlacementQuestion(id:'pl-a2-05', level:CefrLevel.a2, domain:AssessmentDomain.reading, contextText:'Die Praxis bleibt am Mittwochvormittag geschlossen. Patienten mit einem Termin werden gebeten, telefonisch einen neuen Termin zu vereinbaren.', prompt:'What should patients with an appointment do?', options:<String>['Call to arrange a new appointment.','Come earlier on Wednesday.','Go directly to hospital.','Send money in advance.'], correctIndex:0, explanation:'The notice asks them to arrange a new appointment by phone.'),
  PlacementQuestion(id:'pl-a2-06', level:CefrLevel.a2, domain:AssessmentDomain.listening, spokenText:'Wegen einer technischen Störung fährt der Zug heute nur bis Schwerin. Dort müssen alle Fahrgäste umsteigen.', prompt:'What must passengers do in Schwerin?', options:<String>['Change trains.','Buy a new ticket.','Leave the station.','Wait until tomorrow.'], correctIndex:0, explanation:'The announcement says “müssen … umsteigen”.'),

  // B1
  PlacementQuestion(id:'pl-b1-01', level:CefrLevel.b1, domain:AssessmentDomain.vocabulary, prompt:'What is the best meaning of “zuverlässig”?', options:<String>['reliable','temporary','expensive','careless'], correctIndex:0, explanation:'“zuverlässig” means reliable/dependable.'),
  PlacementQuestion(id:'pl-b1-02', level:CefrLevel.b1, domain:AssessmentDomain.vocabulary, prompt:'“etwas begründen” means …', options:<String>['to give reasons for something','to cancel something','to translate something','to hide something'], correctIndex:0, explanation:'“begründen” is to justify or give reasons.'),
  PlacementQuestion(id:'pl-b1-03', level:CefrLevel.b1, domain:AssessmentDomain.grammar, prompt:'Choose the correct hypothetical sentence.', options:<String>['Wenn ich mehr Zeit hätte, würde ich öfter lesen.','Wenn ich mehr Zeit habe, würde ich öfter las.','Wenn hätte ich mehr Zeit, ich würde öfter lesen.','Wenn ich hätte mehr Zeit, lese ich würde öfter.'], correctIndex:0, explanation:'Konjunktiv II uses “hätte” and “würde + infinitive” here.'),
  PlacementQuestion(id:'pl-b1-04', level:CefrLevel.b1, domain:AssessmentDomain.grammar, prompt:'Choose the correct relative clause.', options:<String>['Die Kollegin, mit der ich arbeite, ist heute krank.','Die Kollegin, mit die ich arbeite, ist heute krank.','Die Kollegin, ich arbeite mit ihr, ist heute krank.','Die Kollegin, der mit ich arbeite, ist heute krank.'], correctIndex:0, explanation:'“mit” requires dative; feminine relative pronoun is “der”.'),
  PlacementQuestion(id:'pl-b1-05', level:CefrLevel.b1, domain:AssessmentDomain.reading, contextText:'Viele Beschäftigte wünschen sich flexible Arbeitszeiten. Eine interne Befragung zeigt jedoch, dass Flexibilität allein die Zufriedenheit nicht garantiert: Ebenso wichtig sind planbare Absprachen und eine faire Verteilung der Aufgaben.', prompt:'What is the main point?', options:<String>['Flexibility helps, but predictability and fairness also matter.','Flexible hours always reduce satisfaction.','Employees prefer fixed hours only.','Task distribution has no effect.'], correctIndex:0, explanation:'The text explicitly balances flexibility with planning and fairness.'),
  PlacementQuestion(id:'pl-b1-06', level:CefrLevel.b1, domain:AssessmentDomain.listening, spokenText:'Die Veranstaltung beginnt zwar um achtzehn Uhr, der Einlass ist aber bereits ab siebzehn Uhr dreißig möglich. Wegen der begrenzten Plätze empfehlen wir, frühzeitig zu kommen.', prompt:'Why should visitors come early?', options:<String>['Places are limited.','The event starts at 17:30.','Tickets are cheaper then.','Public transport stops at 18:00.'], correctIndex:0, explanation:'The announcement mentions limited places.'),

  // B2
  PlacementQuestion(id:'pl-b2-01', level:CefrLevel.b2, domain:AssessmentDomain.vocabulary, prompt:'What does “berücksichtigen” mean?', options:<String>['to take into account','to reject categorically','to summarize briefly','to publish'], correctIndex:0, explanation:'“berücksichtigen” = take into account / consider.'),
  PlacementQuestion(id:'pl-b2-02', level:CefrLevel.b2, domain:AssessmentDomain.vocabulary, prompt:'Which expression most closely means “to engage critically with a topic”?', options:<String>['sich mit etwas auseinandersetzen','etwas außer Acht lassen','auf etwas verzichten','etwas verschieben'], correctIndex:0, explanation:'“sich auseinandersetzen mit” means to engage/deal with something in depth.'),
  PlacementQuestion(id:'pl-b2-03', level:CefrLevel.b2, domain:AssessmentDomain.grammar, prompt:'Choose the correct passive with a modal verb.', options:<String>['Die Daten müssen überprüft werden.','Die Daten müssen werden überprüft.','Die Daten werden müssen überprüft.','Die Daten müssen überprüften werden.'], correctIndex:0, explanation:'Modal + participle + werden infinitive is the standard pattern.'),
  PlacementQuestion(id:'pl-b2-04', level:CefrLevel.b2, domain:AssessmentDomain.grammar, prompt:'Which sentence uses formal reported speech?', options:<String>['Er erklärte, die Lage sei stabil.','Er erklärte, die Lage ist sei stabil.','Er erklärte, sei die Lage stabil ist.','Er erklärte, dass sei stabil die Lage.'], correctIndex:0, explanation:'Konjunktiv I “sei” is a classic reported-speech form.'),
  PlacementQuestion(id:'pl-b2-05', level:CefrLevel.b2, domain:AssessmentDomain.reading, contextText:'Die Einführung einer Vier-Tage-Woche wird häufig als Produktivitätsmaßnahme dargestellt. Ergebnisse aus Pilotprojekten sind jedoch nur bedingt vergleichbar, weil Arbeitszeitmodelle, Branchen und Messgrößen stark variieren. Eine pauschale Bewertung wäre daher voreilig.', prompt:'Why is a general conclusion difficult?', options:<String>['The pilot projects differ substantially in design and measurement.','No pilot projects exist.','Productivity cannot be measured at all.','All sectors use the same model.'], correctIndex:0, explanation:'The passage emphasizes heterogeneity across models, sectors and measures.'),
  PlacementQuestion(id:'pl-b2-06', level:CefrLevel.b2, domain:AssessmentDomain.listening, spokenText:'Die Referentin weist darauf hin, dass die sinkende Fehlerquote nicht allein auf die neue Software zurückgeführt werden könne. Gleichzeitig seien die Schulungen intensiviert und mehrere Arbeitsabläufe vereinfacht worden.', prompt:'What is the speaker warning against?', options:<String>['Attributing the improvement only to the software.','Training staff more intensively.','Simplifying workflows.','Measuring the error rate.'], correctIndex:0, explanation:'Several changes occurred, so single-cause attribution is not justified.'),

  // C1
  PlacementQuestion(id:'pl-c1-01', level:CefrLevel.c1, domain:AssessmentDomain.vocabulary, prompt:'What does “relativieren” usually mean in academic discussion?', options:<String>['to qualify or put a claim into perspective','to prove beyond doubt','to repeat word for word','to hide a source'], correctIndex:0, explanation:'It means limiting/qualifying a claim or putting it in perspective.'),
  PlacementQuestion(id:'pl-c1-02', level:CefrLevel.c1, domain:AssessmentDomain.vocabulary, prompt:'Which expression means “to call something into question”?', options:<String>['etwas in Frage stellen','etwas zur Verfügung stellen','etwas in Anspruch nehmen','etwas zum Ausdruck bringen'], correctIndex:0, explanation:'“in Frage stellen” means to question/challenge.'),
  PlacementQuestion(id:'pl-c1-03', level:CefrLevel.c1, domain:AssessmentDomain.grammar, prompt:'Choose the best formal reported-speech form.', options:<String>['Die Autorin betont, die Ergebnisse hätten nur begrenzte Aussagekraft.','Die Autorin betont, die Ergebnisse haben hätten nur begrenzte Aussagekraft.','Die Autorin betont, hätten die Ergebnisse nur begrenzte Aussagekraft sind.','Die Autorin betont, dass die Ergebnisse hätten nur begrenzte Aussagekraft.'], correctIndex:0, explanation:'Konjunktiv II can be used in reported speech when appropriate, with coherent clause structure.'),
  PlacementQuestion(id:'pl-c1-04', level:CefrLevel.c1, domain:AssessmentDomain.grammar, prompt:'Choose the grammatically well-formed extended attribute.', options:<String>['die von mehreren Instituten gemeinsam erhobenen Daten','die von mehreren Instituten gemeinsam erhobene Daten','die Daten von mehreren Instituten gemeinsam erhobenen','die gemeinsam mehreren Instituten von erhobenen Daten'], correctIndex:0, explanation:'The participial attribute precedes the noun and takes the plural adjective ending.'),
  PlacementQuestion(id:'pl-c1-05', level:CefrLevel.c1, domain:AssessmentDomain.reading, contextText:'Dass ein Modell auf historischen Daten eine hohe Prognosegüte erreicht, belegt noch nicht seine Eignung für zukünftige Entscheidungen. Ändern sich institutionelle Rahmenbedingungen oder das Verhalten der Betroffenen, können stabile statistische Zusammenhänge ihre Aussagekraft verlieren.', prompt:'Which inference is supported?', options:<String>['Historical predictive success may not transfer when conditions change.','A high past score guarantees future validity.','Institutional change never affects models.','Statistical relationships are always causal.'], correctIndex:0, explanation:'The text explicitly questions transfer under changing conditions.'),
  PlacementQuestion(id:'pl-c1-06', level:CefrLevel.c1, domain:AssessmentDomain.listening, spokenText:'Die Studie findet zwar einen statistisch signifikanten Zusammenhang, doch die Effektgröße ist gering und das Design erlaubt keine belastbare Aussage über Kausalität. Für praktische Empfehlungen reicht der Befund daher allein nicht aus.', prompt:'Why is the finding insufficient for practical recommendations?', options:<String>['The effect is small and causality is not established.','The finding is not statistically significant.','The study contains no data.','The speaker rejects all quantitative research.'], correctIndex:0, explanation:'Both the small effect and lack of causal identification limit the conclusion.'),

  // C2
  PlacementQuestion(id:'pl-c2-01', level:CefrLevel.c2, domain:AssessmentDomain.vocabulary, prompt:'In an argument, “eine Prämisse konzedieren” most nearly means …', options:<String>['to concede a premise','to falsify all evidence','to avoid a conclusion','to quote a premise verbatim'], correctIndex:0, explanation:'“konzedieren” means concede/grant.'),
  PlacementQuestion(id:'pl-c2-02', level:CefrLevel.c2, domain:AssessmentDomain.vocabulary, prompt:'“Die Erklärung greift zu kurz” means …', options:<String>['the explanation is overly reductive or insufficient','the explanation is too long','the explanation is grammatically impossible','the explanation is completely proven'], correctIndex:0, explanation:'“zu kurz greifen” means to fall short / be insufficiently nuanced.'),
  PlacementQuestion(id:'pl-c2-03', level:CefrLevel.c2, domain:AssessmentDomain.grammar, prompt:'Choose the idiomatic counterfactual past sentence.', options:<String>['Hätte man früher reagiert, wäre der Schaden geringer ausgefallen.','Hatte man früher reagiert, würde der Schaden geringer ausgefallen.','Würde man früher reagiert haben, war der Schaden geringer.','Hätte früher man reagieren, wäre ausgefallen geringer der Schaden.'], correctIndex:0, explanation:'Past counterfactuals use hätte/wäre + participial constructions.'),
  PlacementQuestion(id:'pl-c2-04', level:CefrLevel.c2, domain:AssessmentDomain.grammar, prompt:'Choose the correct modal-perfect subordinate clause.', options:<String>['…, weil er früher hätte gehen müssen.','…, weil er früher gehen gemusst hätte.','…, weil hätte er früher gehen müssen.','…, weil er hätte gemusst früher gehen.'], correctIndex:0, explanation:'The Ersatzinfinitiv cluster with a modal verb has this characteristic order.'),
  PlacementQuestion(id:'pl-c2-05', level:CefrLevel.c2, domain:AssessmentDomain.reading, contextText:'Die Forderung nach “technologischer Neutralität” wirkt auf den ersten Blick unparteiisch. Sie kann jedoch politische Vorentscheidungen verdecken, wenn bereits die Definition dessen, was als funktional gleichwertig gilt, bestimmte Infrastrukturen privilegiert. Neutralität wäre dann weniger Ausgangspunkt als Ergebnis einer umstrittenen Klassifikation.', prompt:'What is the author’s central qualification?', options:<String>['Claims of neutrality can conceal prior value-laden classifications.','Technology can never be compared functionally.','Neutrality is always impossible by definition.','Infrastructure choices have no political dimension.'], correctIndex:0, explanation:'The passage argues that apparently neutral criteria may already encode contested choices.'),
  PlacementQuestion(id:'pl-c2-06', level:CefrLevel.c2, domain:AssessmentDomain.listening, spokenText:'Der Einwand ist insofern berechtigt, als die Untersuchung ihre Stichprobe sehr eng definiert. Daraus folgt jedoch nicht, dass der gesamte Befund hinfällig wäre; vielmehr ist sein Geltungsbereich präziser zu bestimmen, als es die Autoren selbst tun.', prompt:'What stance does the speaker take?', options:<String>['The criticism limits the scope of the finding but does not invalidate it entirely.','The study is completely worthless.','The sample is broader than the authors claim.','The criticism is entirely irrelevant.'], correctIndex:0, explanation:'The speaker accepts a limitation but rejects total invalidation.'),
  // Reserve items. A band is only carried past six when six could not settle
  // it -- see BandVerdict -- so most learners never see these.
  // A1
  PlacementQuestion(id:'pl-a1-07', level:CefrLevel.a1, domain:AssessmentDomain.vocabulary, prompt:'What does „die Wohnung“ mean?', options:<String>['flat, apartment','kitchen','garden','street'], correctIndex:0, explanation:'„die Wohnung“ is a flat or apartment.'),
  PlacementQuestion(id:'pl-a1-08', level:CefrLevel.a1, domain:AssessmentDomain.grammar, prompt:'Wir ___ am Wochenende nach Berlin.', options:<String>['fahren','fährt','fahrt','fahre'], correctIndex:0, explanation:'„wir“ takes the plural form „fahren“.'),
  PlacementQuestion(id:'pl-a1-09', level:CefrLevel.a1, domain:AssessmentDomain.vocabulary, prompt:'Which word means „cheap“?', options:<String>['billig','teuer','schnell','laut'], correctIndex:0, explanation:'„billig“ is cheap; „teuer“ is expensive.'),
  PlacementQuestion(id:'pl-a1-10', level:CefrLevel.a1, domain:AssessmentDomain.listening, spokenText:'Das Brot kostet zwei Euro fünfzig.', prompt:'How much does the bread cost?', options:<String>['2.50 euros','2.15 euros','12.50 euros','5.20 euros'], correctIndex:0, explanation:'„zwei Euro fünfzig“ is 2.50.'),

  // A2
  PlacementQuestion(id:'pl-a2-07', level:CefrLevel.a2, domain:AssessmentDomain.grammar, prompt:'Gestern ___ ich ins Kino gegangen.', options:<String>['bin','habe','war','werde'], correctIndex:0, explanation:'Verbs of motion form the perfect with „sein“.'),
  PlacementQuestion(id:'pl-a2-08', level:CefrLevel.a2, domain:AssessmentDomain.vocabulary, prompt:'What does „sich bewerben“ mean?', options:<String>['to apply for a job','to complain','to move house','to recover'], correctIndex:0, explanation:'„sich um eine Stelle bewerben“ is to apply for a position.'),
  PlacementQuestion(id:'pl-a2-09', level:CefrLevel.a2, domain:AssessmentDomain.grammar, prompt:'Mein Bruder ist ___ als ich.', options:<String>['größer','groß','am größten','mehr groß'], correctIndex:0, explanation:'A comparison with „als“ needs the comparative „größer“.'),
  PlacementQuestion(id:'pl-a2-10', level:CefrLevel.a2, domain:AssessmentDomain.reading, contextText:'Liebe Nachbarn, am Samstag wird das Treppenhaus gestrichen. Bitte stellen Sie keine Schuhe oder Pflanzen in den Flur.', prompt:'What are neighbours asked to do?', options:<String>['Keep the hallway clear.','Paint their own doors.','Stay at home on Saturday.','Water the plants.'], correctIndex:0, explanation:'The notice asks that nothing be left in the hallway.'),

  // B1
  PlacementQuestion(id:'pl-b1-07', level:CefrLevel.b1, domain:AssessmentDomain.grammar, prompt:'Das Formular ___ vom Amt geprüft.', options:<String>['wird','ist','hat','wurde haben'], correctIndex:0, explanation:'Present passive is „werden“ plus the participle.'),
  PlacementQuestion(id:'pl-b1-08', level:CefrLevel.b1, domain:AssessmentDomain.vocabulary, prompt:'What does „die Voraussetzung“ mean?', options:<String>['prerequisite, requirement','consequence','suggestion','exception'], correctIndex:0, explanation:'„Voraussetzung“ is a precondition or requirement.'),
  PlacementQuestion(id:'pl-b1-09', level:CefrLevel.b1, domain:AssessmentDomain.grammar, prompt:'Wegen ___ Wetters bleiben wir zu Hause.', options:<String>['des schlechten','dem schlechten','das schlechte','der schlechte'], correctIndex:0, explanation:'„wegen“ takes the genitive: „des schlechten Wetters“.'),
  PlacementQuestion(id:'pl-b1-10', level:CefrLevel.b1, domain:AssessmentDomain.listening, spokenText:'Der Kurs fällt diese Woche aus. Wer bereits bezahlt hat, bekommt das Geld zurück oder kann einen späteren Termin wählen.', prompt:'What can people who already paid do?', options:<String>['Get a refund or take a later date.','Only get a refund.','Nothing, the money is lost.','Attend a different course for free.'], correctIndex:0, explanation:'Both options are offered: a refund or a later date.'),

  // B2
  PlacementQuestion(id:'pl-b2-07', level:CefrLevel.b2, domain:AssessmentDomain.grammar, prompt:'Wenn ich das gewusst hätte, ___ ich anders entschieden.', options:<String>['hätte','würde','wäre','hätte gehabt'], correctIndex:0, explanation:'Past Konjunktiv II with „entscheiden“ uses „hätte … entschieden“.'),
  PlacementQuestion(id:'pl-b2-08', level:CefrLevel.b2, domain:AssessmentDomain.vocabulary, prompt:'What does „nachvollziehen“ mean?', options:<String>['to follow, to understand the reasoning','to repeat exactly','to postpone','to contradict'], correctIndex:0, explanation:'„etwas nachvollziehen“ is to comprehend how something came about.'),
  PlacementQuestion(id:'pl-b2-09', level:CefrLevel.b2, domain:AssessmentDomain.grammar, prompt:'Choose the sentence with a correct extended attribute.', options:<String>['Die vom Team vorgeschlagene Lösung überzeugte.','Die vorgeschlagene vom Team Lösung überzeugte.','Die Lösung vorgeschlagene vom Team überzeugte.','Die vom Team vorschlagen Lösung überzeugte.'], correctIndex:0, explanation:'The participle phrase sits between article and noun.'),
  PlacementQuestion(id:'pl-b2-10', level:CefrLevel.b2, domain:AssessmentDomain.reading, contextText:'Der Bericht räumt ein, dass die Datenlage lückenhaft ist. Er hält dennoch an seiner Empfehlung fest, verweist aber ausdrücklich auf den Bedarf an weiteren Erhebungen.', prompt:'How does the report treat its own evidence?', options:<String>['It admits gaps but keeps the recommendation.','It withdraws the recommendation.','It claims the data are complete.','It refuses to make any recommendation.'], correctIndex:0, explanation:'A concession followed by holding the line.'),

  // C1
  PlacementQuestion(id:'pl-c1-07', level:CefrLevel.c1, domain:AssessmentDomain.vocabulary, prompt:'What does „beharrlich“ mean?', options:<String>['persistent','careless','temporary','reluctant'], correctIndex:0, explanation:'„beharrlich“ describes someone who keeps at something.'),
  PlacementQuestion(id:'pl-c1-08', level:CefrLevel.c1, domain:AssessmentDomain.grammar, prompt:'Choose the idiomatic light-verb construction.', options:<String>['Die Beratung wurde in Anspruch genommen.','Die Beratung wurde in Anspruch gemacht.','Die Beratung wurde auf Anspruch genommen.','Die Beratung nahm in Anspruch.'], correctIndex:0, explanation:'„etwas in Anspruch nehmen“ is the fixed collocation.'),
  PlacementQuestion(id:'pl-c1-09', level:CefrLevel.c1, domain:AssessmentDomain.grammar, prompt:'Which sentence uses Konjunktiv I correctly in reported speech?', options:<String>['Sie sagte, sie habe den Termin verschoben.','Sie sagte, sie hat den Termin verschoben sei.','Sie sagte, habe sie den Termin verschoben.','Sie sagte, sie hätte verschoben den Termin.'], correctIndex:0, explanation:'Konjunktiv I „habe“ marks reported speech in formal registers.'),
  PlacementQuestion(id:'pl-c1-10', level:CefrLevel.c1, domain:AssessmentDomain.reading, contextText:'Die Kritik trifft weniger das Verfahren selbst als die Art seiner Vermittlung: Was fachlich vertretbar sein mag, wurde öffentlich so knapp begründet, dass es als willkürlich erschien.', prompt:'What exactly is being criticised?', options:<String>['How the decision was explained, more than the decision itself.','The decision itself, not its explanation.','That no decision was taken.','That the explanation was too long.'], correctIndex:0, explanation:'„weniger das Verfahren selbst als die Art seiner Vermittlung“.'),

  // C2
  PlacementQuestion(id:'pl-c2-07', level:CefrLevel.c2, domain:AssessmentDomain.vocabulary, prompt:'What does „die Gepflogenheit“ mean?', options:<String>['an established custom or practice','a formal complaint','a maintenance contract','a careful measurement'], correctIndex:0, explanation:'„Gepflogenheit“ is a customary practice of a group or institution.'),
  PlacementQuestion(id:'pl-c2-08', level:CefrLevel.c2, domain:AssessmentDomain.vocabulary, prompt:'„Etwas in Abrede stellen“ means …', options:<String>['to deny it','to put it on the agenda','to negotiate it','to summarise it'], correctIndex:0, explanation:'„in Abrede stellen“ is a formal way of denying something.'),
  PlacementQuestion(id:'pl-c2-09', level:CefrLevel.c2, domain:AssessmentDomain.grammar, prompt:'Choose the sentence where „sollte“ expresses a hypothetical condition.', options:<String>['Sollte sich der Verdacht bestätigen, wird das Verfahren eingestellt.','Er sollte gestern den Bericht abgeben.','Man sollte höflich bleiben.','Sie sollte die Stelle bekommen, hieß es.'], correctIndex:0, explanation:'Verb-first „Sollte …“ is a conditional without „wenn“.'),
  PlacementQuestion(id:'pl-c2-10', level:CefrLevel.c2, domain:AssessmentDomain.reading, contextText:'Dass der Befund unstrittig sei, lässt sich kaum behaupten; strittig ist allerdings nicht seine Substanz, sondern die Reichweite der daraus abgeleiteten Forderungen.', prompt:'What is contested, according to the sentence?', options:<String>['How far the demands drawn from the finding reach.','Whether the finding exists at all.','The wording of the finding.','Who published the finding.'], correctIndex:0, explanation:'„nicht seine Substanz, sondern die Reichweite“.'),
];

List<PlacementQuestion> placementQuestionsFor(CefrLevel level) =>
    placementQuestions.where((q) => q.level == level).toList(growable: false);
