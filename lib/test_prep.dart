import 'models.dart';
import 'dart:math';
import 'answer_shuffle.dart';

enum ExamModuleType { reading, listening, writing, speaking }

extension ExamModuleTypeX on ExamModuleType {
  String get label => switch (this) {
        ExamModuleType.reading => 'Reading',
        ExamModuleType.listening => 'Listening',
        ExamModuleType.writing => 'Writing',
        ExamModuleType.speaking => 'Speaking',
      };
  String get emoji => switch (this) {
        ExamModuleType.reading => '📖',
        ExamModuleType.listening => '🎧',
        ExamModuleType.writing => '✍️',
        ExamModuleType.speaking => '🗣️',
      };
}

class ExamProfile {
  const ExamProfile({
    required this.level,
    required this.readingMinutes,
    required this.listeningMinutes,
    required this.writingMinutes,
    required this.speakingMinutes,
    required this.readingFocus,
    required this.listeningFocus,
    required this.writingFocus,
    required this.speakingFocus,
  });

  final CefrLevel level;
  final int readingMinutes;
  final int listeningMinutes;
  final int writingMinutes;
  final int speakingMinutes;
  final String readingFocus;
  final String listeningFocus;
  final String writingFocus;
  final String speakingFocus;
}

/// Current Goethe-Zertifikat-style module timings used as a preparation
/// reference. Practice content in DeutschGarden is original and is not an
/// official Goethe sample exam.
const List<ExamProfile> examProfiles = <ExamProfile>[
  ExamProfile(level:CefrLevel.a1, readingMinutes:25, listeningMinutes:20, writingMinutes:20, speakingMinutes:15, readingFocus:'Short notes, signs, advertisements and simple messages.', listeningFocus:'Short everyday conversations, phone messages and announcements.', writingFocus:'Forms and a very short personal everyday text.', speakingFocus:'Introduce yourself, exchange simple information and make requests.'),
  ExamProfile(level:CefrLevel.a2, readingMinutes:30, listeningMinutes:30, writingMinutes:30, speakingMinutes:15, readingFocus:'Everyday messages, notices, short articles and practical information.', listeningFocus:'Routine conversations, announcements and short media extracts.', writingFocus:'Short connected everyday correspondence.', speakingFocus:'Personal information, planning and simple discussion with a partner.'),
  ExamProfile(level:CefrLevel.b1, readingMinutes:65, listeningMinutes:40, writingMinutes:60, speakingMinutes:15, readingFocus:'Emails, articles, notices and viewpoints on familiar topics.', listeningFocus:'Announcements, conversations, reports and presentations.', writingFocus:'Connected personal/formal text with reasons and opinions.', speakingFocus:'Presentation, joint planning and discussion.'),
  ExamProfile(level:CefrLevel.b2, readingMinutes:65, listeningMinutes:40, writingMinutes:75, speakingMinutes:15, readingFocus:'Forum posts, press texts, comments and regulations with viewpoints and detail.', listeningFocus:'Interviews, lectures, conversations and radio-style material.', writingFocus:'Argued forum contribution plus formal professional message.', speakingFocus:'Short presentation followed by discussion and exchange of arguments.'),
  ExamProfile(level:CefrLevel.c1, readingMinutes:65, listeningMinutes:40, writingMinutes:75, speakingMinutes:20, readingFocus:'Complex authentic-style texts requiring structure, attitude and inference.', listeningFocus:'Extended speech, interviews and lectures with implicit relations.', writingFocus:'Structured, register-appropriate argument and synthesis.', speakingFocus:'Extended presentation/discussion with flexible, precise response.'),
  ExamProfile(level:CefrLevel.c2, readingMinutes:80, listeningMinutes:35, writingMinutes:80, speakingMinutes:15, readingFocus:'Dense literary, journalistic and specialist material with nuance and inference.', listeningFocus:'Complex natural-speed speech requiring detailed and inferential comprehension.', writingFocus:'Sophisticated synthesis, argument and register control.', speakingFocus:'Highly fluent presentation and nuanced interaction on complex topics.'),
];

ExamProfile examProfileFor(CefrLevel level) =>
    examProfiles.firstWhere((profile) => profile.level == level);

class ExamObjectiveQuestion {
  const ExamObjectiveQuestion({
    required this.module,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.contextText = '',
    this.spokenText = '',
  });
  final ExamModuleType module;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String contextText;
  final String spokenText;

  /// The same question with its options permuted. See
  /// `lib/answer_shuffle.dart`. All 48 exam-prep items were authored
  /// answer-first, which made the mock exams easier than the real ones in the
  /// one way a mock must never be.
  ExamObjectiveQuestion shuffled(Random random) {
    final ShuffledChoices s = shuffleChoices(options, correctIndex, random);
    return ExamObjectiveQuestion(
      module: module,
      prompt: prompt,
      options: s.options,
      correctIndex: s.correctIndex,
      explanation: explanation,
      contextText: contextText,
      spokenText: spokenText,
    );
  }
}

class ExamPracticeSet {
  const ExamPracticeSet({
    required this.id,
    required this.level,
    required this.title,
    required this.objectiveQuestions,
    required this.writingPrompt,
    required this.writingChecklist,
    required this.speakingPrompt,
    required this.speakingChecklist,
  });
  final String id;
  final CefrLevel level;
  final String title;
  final List<ExamObjectiveQuestion> objectiveQuestions;
  final String writingPrompt;
  final List<String> writingChecklist;
  final String speakingPrompt;
  final List<String> speakingChecklist;
}

const List<String> generalExamStrategies = <String>[
  'Read the task instruction before the text or audio and identify exactly what evidence is required.',
  'Separate main idea, explicit detail, inference and speaker attitude; exam distractors often mix these.',
  'Do not spend disproportionate time on one item. Mark uncertainty, move on, and return if time remains.',
  'For writing, allocate time to planning, drafting and a final grammar/register check.',
  'For speaking, answer the task first, then support it with reasons, examples and a clear conclusion.',
  'Practise under the target module time as well as untimed; accuracy and time management are separate skills.',
];

const List<ExamPracticeSet> examPracticeSets = <ExamPracticeSet>[
  ExamPracticeSet(id:'mock-a1-1', level:CefrLevel.a1, title:'A1 Mini Mock 1', objectiveQuestions:<ExamObjectiveQuestion>[
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Bäckerei am Markt: Sonntag geschlossen. Samstag 7–13 Uhr geöffnet.', prompt:'When can you shop there on Saturday?', options:<String>['7:00–13:00','Only Sunday','After 18:00','Never'], correctIndex:0, explanation:'The notice states Saturday 7–13.'),
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Hallo Amir, ich komme heute 20 Minuten später. Warte bitte vor dem Kino. – Lena', prompt:'Where should Amir wait?', options:<String>['In front of the cinema','At the station','At home','In a café'], correctIndex:0, explanation:'“vor dem Kino” means in front of the cinema.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Achtung: Der Bus Nummer fünf fährt heute nicht vom Hauptbahnhof, sondern vom Rathaus.', prompt:'Where does bus 5 leave from today?', options:<String>['Town hall','Central station','Airport','Hospital'], correctIndex:0, explanation:'The announcement changes the departure point to the town hall.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Hallo, hier ist Anna. Unser Treffen ist nicht um sechs, sondern um halb sieben.', prompt:'What time is the meeting?', options:<String>['18:30','18:00','17:30','19:00'], correctIndex:0, explanation:'“halb sieben” is 18:30.'),
  ], writingPrompt:'Write a short message to a friend: you cannot meet today, give a reason, and suggest a new day/time.', writingChecklist:<String>['Greeting','Reason','New day/time','Closing'], speakingPrompt:'Introduce yourself and ask another learner two simple personal questions.', speakingChecklist:<String>['Name/origin','Home or work/study','Two understandable questions','Polite reaction']),
  ExamPracticeSet(id:'mock-a1-2', level:CefrLevel.a1, title:'A1 Mini Mock 2', objectiveQuestions:<ExamObjectiveQuestion>[
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Praxis Dr. Klein: Heute ab 14 Uhr geschlossen.', prompt:'Which statement is true?', options:<String>['The practice closes at 14:00 today.','It opens at 14:00.','It is open all evening.','It closes tomorrow only.'], correctIndex:0, explanation:'The notice says it is closed from 14:00 today.'),
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Zimmer frei ab 1. Oktober, 420 Euro warm, Küche gemeinsam.', prompt:'What is being offered?', options:<String>['A room','A job','A bicycle','A course'], correctIndex:0, explanation:'“Zimmer frei” is a room-for-rent notice.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Bitte vergessen Sie nicht: Der Deutschkurs beginnt morgen in Raum zwölf.', prompt:'What should learners remember?', options:<String>['The course is in room 12.','The course is cancelled.','The course starts next week.','The course is online.'], correctIndex:0, explanation:'The message specifies room 12.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Ich hätte gern einen Tee und ein Käsebrötchen, bitte.', prompt:'What does the customer order?', options:<String>['Tea and a cheese roll','Coffee and cake','Water and soup','Juice and salad'], correctIndex:0, explanation:'Both items are stated directly.'),
  ], writingPrompt:'Fill an imaginary course registration: name, city, languages, profession, then write two sentences about why you learn German.', writingChecklist:<String>['All requested personal data','Two complete sentences','Reason for learning','Readable spelling'], speakingPrompt:'Ask for information about a language course: start date, price and lesson time.', speakingChecklist:<String>['Three relevant questions','Question word or verb-first form','Understandable numbers/time','Polite closing']),

  ExamPracticeSet(id:'mock-a2-1', level:CefrLevel.a2, title:'A2 Mini Mock 1', objectiveQuestions:<ExamObjectiveQuestion>[
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Wegen Bauarbeiten bleibt das Schwimmbad bis einschließlich Freitag geschlossen. Ab Samstag gelten wieder die normalen Öffnungszeiten.', prompt:'When does normal operation resume?', options:<String>['Saturday','Friday morning','Monday','Immediately'], correctIndex:0, explanation:'It reopens with normal hours from Saturday.'),
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Ihre Bestellung wurde versendet. Falls Sie am Liefertag nicht zu Hause sind, können Sie in der App einen Ablageort wählen.', prompt:'What can the customer do if absent?', options:<String>['Choose a delivery location in the app','Cancel the order automatically','Collect it before shipping','Change the product price'], correctIndex:0, explanation:'The text explicitly offers an “Ablageort”.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Der Termin am Dienstag muss leider ausfallen. Ich könnte Ihnen Mittwoch um zehn oder Donnerstag um vierzehn Uhr anbieten.', prompt:'What is the purpose of the message?', options:<String>['To reschedule an appointment','To cancel a train','To order lunch','To apply for a job'], correctIndex:0, explanation:'Two replacement appointment times are offered.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Nehmen Sie die U-Bahn bis Stadtmitte und steigen Sie dort in die Linie drei Richtung Hafen um.', prompt:'What should the listener do at Stadtmitte?', options:<String>['Change to line 3','Leave the city','Take a taxi','Walk to the airport'], correctIndex:0, explanation:'The instruction says to change to line 3.'),
  ], writingPrompt:'Write an email to your landlord about a broken heater. Describe the problem, say since when it exists, and request an appointment.', writingChecklist:<String>['Clear subject/problem','Time reference','Request','Polite opening/closing'], speakingPrompt:'Plan a birthday activity with a partner. Discuss place, time, transport and cost.', speakingChecklist:<String>['Make suggestions','React to alternatives','Give simple reasons','Reach an agreement']),
  ExamPracticeSet(id:'mock-a2-2', level:CefrLevel.a2, title:'A2 Mini Mock 2', objectiveQuestions:<ExamObjectiveQuestion>[
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Der Kurs findet ab nächster Woche donnerstags statt statt mittwochs. Die Uhrzeit 18:30 Uhr bleibt unverändert.', prompt:'What changes?', options:<String>['The weekday','The time','The teacher','The price'], correctIndex:0, explanation:'Only the weekday changes.'),
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Rückgabe innerhalb von 30 Tagen möglich. Reduzierte Ware ist vom Umtausch ausgeschlossen.', prompt:'Which item cannot be exchanged?', options:<String>['Discounted goods','All full-price goods','Anything within 30 days','Only shoes'], correctIndex:0, explanation:'Reduced goods are excluded.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Heute bleibt es zunächst trocken. Am Nachmittag ziehen von Westen Schauer auf, am Abend wird es wieder freundlicher.', prompt:'When is rain most likely?', options:<String>['In the afternoon','Early morning','Late evening only','Not at all'], correctIndex:0, explanation:'Showers arrive in the afternoon.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Bitte bringen Sie zur Anmeldung Ihren Ausweis und ein aktuelles Foto mit. Das Formular erhalten Sie vor Ort.', prompt:'What must the person bring?', options:<String>['ID and a recent photo','A completed form only','A laptop','Cash only'], correctIndex:0, explanation:'The two required items are stated.'),
  ], writingPrompt:'Reply to an invitation. Thank the person, say whether you can come, ask one practical question and offer to bring something.', writingChecklist:<String>['Thank-you','Accept/decline clearly','One question','Offer/help'], speakingPrompt:'Describe a recent trip or weekend and answer follow-up questions about what went well and what did not.', speakingChecklist:<String>['Past tense','Sequence','Positive/negative detail','Follow-up response']),

  ExamPracticeSet(id:'mock-b1-1', level:CefrLevel.b1, title:'B1 Mini Mock 1', objectiveQuestions:<ExamObjectiveQuestion>[
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Das Unternehmen testet Gleitzeit ohne feste Kernarbeitszeit. Mitarbeitende begrüßen die Freiheit, einige Teams berichten jedoch von Schwierigkeiten, gemeinsame Termine zu finden. Nach drei Monaten soll geprüft werden, welche Regeln ergänzt werden müssen.', prompt:'What is the company doing?', options:<String>['Testing a flexible model and evaluating needed rules','Abolishing all meetings permanently','Returning immediately to fixed hours','Reducing salaries'], correctIndex:0, explanation:'It is a trial followed by evaluation.'),
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Die Stadtbibliothek verleiht seit Kurzem auch Werkzeuge. Ziel ist nicht, Baumärkte zu ersetzen, sondern selten benötigte Geräte gemeinsam nutzbar zu machen.', prompt:'What is the stated goal?', options:<String>['Share rarely needed tools','Compete directly with hardware stores','Sell used equipment','Train professional builders'], correctIndex:0, explanation:'The text explicitly distinguishes sharing from replacing shops.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Wir hatten mit mehr Teilnehmenden gerechnet. Trotzdem war der Workshop erfolgreich, weil die kleinere Gruppe intensiver diskutieren und praktische Übungen ausführlicher ausprobieren konnte.', prompt:'Why was the workshop still successful?', options:<String>['The smaller group allowed more intensive work','More people came than expected','The practical section was cancelled','It became much shorter'], correctIndex:0, explanation:'The smaller group enabled deeper discussion and practice.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Die Strecke ist nach dem Sturm wieder frei. Es kann aber noch zu Verspätungen kommen, weil einige Züge und Personal nicht an ihren geplanten Standorten sind.', prompt:'Why may delays continue?', options:<String>['Resources are still out of position','The tracks remain fully closed','Tickets are invalid','Another storm is certain'], correctIndex:0, explanation:'Trains and personnel are not yet where planned.'),
  ], writingPrompt:'Write a structured email to your course provider explaining why the timetable is difficult for you and proposing a realistic alternative.', writingChecklist:<String>['Situation','Reason','Concrete proposal','Polite request/conclusion'], speakingPrompt:'Give a short presentation: Is online learning better than classroom learning? Then answer two imagined objections.', speakingChecklist:<String>['Introduction','At least two arguments','Example','Response to objections','Conclusion']),
  ExamPracticeSet(id:'mock-b1-2', level:CefrLevel.b1, title:'B1 Mini Mock 2', objectiveQuestions:<ExamObjectiveQuestion>[
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Ein Verein vermittelt Patenschaften zwischen neuen und langjährigen Einwohnern. Es geht nicht um professionelle Beratung, sondern um gemeinsame Freizeitaktivitäten und praktische Orientierung im Alltag.', prompt:'What is NOT the purpose of the program?', options:<String>['Professional counselling','Everyday orientation','Social contact','Shared activities'], correctIndex:0, explanation:'The text explicitly says it is not professional counselling.'),
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Die Kantine führt ein Mehrwegsystem ein. Wer eine Box mitnimmt, zahlt Pfand und kann sie später an mehreren Standorten zurückgeben.', prompt:'How does the system work?', options:<String>['A deposit is paid and the box can be returned','The box must be bought permanently','Only employees can return it once','Food may not leave the canteen'], correctIndex:0, explanation:'The deposit-return mechanism is described.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Ich würde die Wohnung gern nehmen. Bevor ich zusage, müsste ich aber wissen, ob die Nebenkosten bereits in der angegebenen Miete enthalten sind.', prompt:'What information does the speaker need?', options:<String>['Whether additional costs are included','Whether the flat exists','The address of the station','The landlord’s profession'], correctIndex:0, explanation:'They ask about “Nebenkosten”.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Die Prüfung wurde nicht leichter. Die höhere Bestehensquote lässt sich vermutlich dadurch erklären, dass wir deutlich mehr Übungstermine angeboten haben.', prompt:'What explanation is proposed?', options:<String>['More practice opportunities','An easier exam','Fewer candidates','Lower passing criteria'], correctIndex:0, explanation:'The speaker attributes the improvement to more practice sessions.'),
  ], writingPrompt:'Write an opinion text on whether public transport in city centres should be cheaper. Give reasons, an example and a conclusion.', writingChecklist:<String>['Position','Two reasons','Example','Counterpoint or limitation','Conclusion'], speakingPrompt:'Plan a volunteer event with a partner: objective, location, tasks, publicity and fallback plan.', speakingChecklist:<String>['Collaborative language','Task division','Practical detail','Agreement/fallback']),

  ExamPracticeSet(id:'mock-b2-1', level:CefrLevel.b2, title:'B2 Mini Mock 1', objectiveQuestions:<ExamObjectiveQuestion>[
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Unternehmen werben häufig mit individueller Flexibilität. Wird sie jedoch ausschließlich auf Beschäftigte verlagert, kann daraus paradoxerweise mehr Unsicherheit entstehen: Wer ständig selbst koordinieren muss, trägt auch das Risiko schlecht abgestimmter Prozesse.', prompt:'What paradox is described?', options:<String>['Individual flexibility can transfer coordination risk to employees','Flexibility always eliminates uncertainty','Coordination becomes unnecessary','Employees lose all autonomy'], correctIndex:0, explanation:'The text says flexibility can increase uncertainty when coordination responsibility is shifted.'),
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Die Studie zeigt eine Korrelation zwischen Bildschirmzeit und Schlafproblemen. Da sie jedoch auf Selbstauskünften beruht und mögliche Drittvariablen nur teilweise kontrolliert, lassen sich daraus keine eindeutigen Kausalaussagen ableiten.', prompt:'What limitation is central?', options:<String>['Correlation does not establish causation in this design','The study found no relationship','Sleep cannot be measured','The sample contains no participants'], correctIndex:0, explanation:'Self-report and confounding limit causal conclusions.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Wir sollten die Verzögerung nicht allein dem Lieferanten zuschreiben. Unsere Spezifikation wurde zweimal geändert, und die endgültige Freigabe kam später als vereinbart.', prompt:'What is the speaker arguing?', options:<String>['Responsibility for the delay is shared','Only the supplier is responsible','Specifications never changed','The release came early'], correctIndex:0, explanation:'Internal changes also contributed.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Die Maßnahme senkt den Energieverbrauch pro Gerät. Wenn dadurch aber deutlich mehr Geräte genutzt werden, kann ein Teil der Einsparung durch diesen Rebound-Effekt wieder verloren gehen.', prompt:'What is a rebound effect here?', options:<String>['Efficiency gains are partly offset by increased use','Devices become technically worse','Energy prices always fall','The measure has no effect per device'], correctIndex:0, explanation:'Higher total use can offset per-device savings.'),
  ], writingPrompt:'Write a forum-style argument: Should employers be allowed to require several office days per week? Discuss advantages, disadvantages and conditions.', writingChecklist:<String>['Clear thesis','Balanced arguments','Specific example','Cohesive connectors','Qualified conclusion'], speakingPrompt:'Give a short presentation on whether AI tools improve education, then debate one major risk with a partner.', speakingChecklist:<String>['Structured presentation','Evidence/example','Counterargument','Interactive response','Conclusion']),
  ExamPracticeSet(id:'mock-b2-2', level:CefrLevel.b2, title:'B2 Mini Mock 2', objectiveQuestions:<ExamObjectiveQuestion>[
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Ein verpflichtendes Transparenzregister kann Interessenkonflikte sichtbar machen. Seine Wirkung hängt jedoch davon ab, wie vollständig Angaben geprüft werden und ob Verstöße spürbare Folgen haben.', prompt:'What condition is emphasized?', options:<String>['Verification and consequences determine effectiveness','Publishing any register guarantees success','Conflicts disappear automatically','Voluntary data is always complete'], correctIndex:0, explanation:'Transparency alone is insufficient without verification and enforcement.'),
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Die Autorin kritisiert nicht die Digitalisierung an sich, sondern die Annahme, jeder analoge Prozess müsse unverändert digital abgebildet werden. Gerade die Umstellung biete die Chance, unnötige Schritte zu streichen.', prompt:'What does the author favour?', options:<String>['Redesigning processes during digitalisation','Keeping every old step unchanged','Rejecting all digital tools','Adding more bureaucracy'], correctIndex:0, explanation:'Digitalisation is framed as an opportunity to redesign.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Die neue Regelung ist kurzfristig teurer, könnte aber Wartungskosten senken und Ausfälle vermeiden. Entscheidend ist deshalb nicht nur der Anschaffungspreis, sondern die Betrachtung über den gesamten Lebenszyklus.', prompt:'What comparison is recommended?', options:<String>['Total lifecycle cost','Purchase price only','Staff salaries only','Competitor advertising'], correctIndex:0, explanation:'The speaker recommends lifecycle costing.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Es gibt Hinweise auf einen Effekt, doch die Konfidenzintervalle sind breit. Ich würde daher von einer Tendenz sprechen und nicht von einem gesicherten Befund.', prompt:'How does the speaker characterize the evidence?', options:<String>['Suggestive but uncertain','Definitively proven','Completely absent','Fraudulent'], correctIndex:0, explanation:'Broad intervals motivate cautious wording.'),
  ], writingPrompt:'Write a formal message to management proposing a change to an inefficient workplace process. Describe the problem, impact, proposal and expected benefit.', writingChecklist:<String>['Professional register','Problem evidence','Feasible proposal','Benefit/trade-off','Clear request'], speakingPrompt:'Compare two policies for reducing urban emissions and negotiate which should be prioritized.', speakingChecklist:<String>['Comparison criteria','Trade-offs','Concessions','Negotiated decision','Precise language']),

  ExamPracticeSet(id:'mock-c1-1', level:CefrLevel.c1, title:'C1 Mini Mock 1', objectiveQuestions:<ExamObjectiveQuestion>[
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Die Debatte um algorithmische Fairness leidet mitunter darunter, dass “Fairness” behandelt wird, als bezeichne der Begriff ein einziges messbares Ziel. Tatsächlich können unterschiedliche Fairnesskriterien mathematisch unvereinbar sein. Eine technische Optimierung verschiebt dann einen normativen Konflikt, löst ihn aber nicht.', prompt:'What is the author’s central claim?', options:<String>['Technical optimization cannot by itself resolve competing normative definitions of fairness','Fairness has one universally measurable definition','Mathematical criteria never conflict','Algorithms remove political choices'], correctIndex:0, explanation:'The text distinguishes technical optimization from normative choice.'),
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Die hohe interne Validität des Experiments ist unbestritten. Fraglich bleibt seine externe Validität, da die Versuchssituation zentrale Bedingungen realer Arbeitsplätze bewusst ausblendet.', prompt:'What is questioned?', options:<String>['Generalizability to real workplaces','Whether the experiment was controlled','Whether data was collected','Whether internal validity exists'], correctIndex:0, explanation:'External validity concerns transfer/generalization.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Der Rückgang ist zeitlich mit der Reform zusammengefallen. Das ist ein wichtiges Indiz, aber noch kein Wirkungsnachweis: Parallel wurden Förderprogramme ausgeweitet und die Konjunktur hat sich erholt.', prompt:'Why is causal attribution difficult?', options:<String>['Other changes occurred at the same time','The reform happened later than the decline','No outcome was measured','Time order is irrelevant'], correctIndex:0, explanation:'Concurrent factors provide alternative explanations.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Die These klingt plausibel, setzt aber stillschweigend voraus, dass alle Beteiligten über dieselben Informationen und Handlungsmöglichkeiten verfügen. Gerade diese Voraussetzung ist empirisch fragwürdig.', prompt:'What does the speaker challenge?', options:<String>['An implicit assumption of equal information and options','The grammar of the thesis','The existence of any participants','The use of empirical research'], correctIndex:0, explanation:'The criticism targets the hidden assumption.'),
  ], writingPrompt:'Write an analytical essay on whether predictive AI should be used in public-sector decisions. Distinguish efficiency, accountability, bias and appeal rights.', writingChecklist:<String>['Conceptual framing','Structured argument','Counterposition','Evidence/inference distinction','Register and cohesion','Qualified conclusion'], speakingPrompt:'Present a five-minute position on the limits of data-driven decision making, then respond to a strong pro-data objection.', speakingChecklist:<String>['Nuanced thesis','Conceptual distinctions','Example','Fair representation of objection','Precise response']),
  ExamPracticeSet(id:'mock-c1-2', level:CefrLevel.c1, title:'C1 Mini Mock 2', objectiveQuestions:<ExamObjectiveQuestion>[
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Produktivität wird in Wissensarbeit häufig über leicht verfügbare Stellvertreter gemessen: Zahl der Tickets, Nachrichten oder bearbeiteten Dokumente. Solche Kennzahlen sind bequem, können aber Verhalten auf messbare Aktivität statt auf tatsächlichen Nutzen ausrichten.', prompt:'What risk is identified?', options:<String>['Metrics can incentivize measurable activity rather than real value','Knowledge work cannot be measured in any way','More tickets always mean less work','Documents have no value'], correctIndex:0, explanation:'Proxy metrics can distort incentives.'),
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Ein scheinbar neutraler Standard kann bestehende Ungleichheiten stabilisieren, wenn er aus historischen Praktiken abgeleitet wurde. Seine Gleichbehandlung in der Anwendung sagt daher noch wenig über die Gleichheit seiner Wirkungen aus.', prompt:'What distinction is made?', options:<String>['Equal application can still produce unequal effects','Neutral standards always create equality','Historical practices are irrelevant','Effects and procedures are identical'], correctIndex:0, explanation:'Procedural sameness and outcome equality are distinguished.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Die Ergebnisse sind robust gegenüber mehreren alternativen Spezifikationen. Dennoch würde ich sie nicht verallgemeinern, weil die Stichprobe ausschließlich aus großen Unternehmen einer einzigen Branche besteht.', prompt:'What remains limited?', options:<String>['Generalizability','Robustness within the sample','Number of model specifications','Existence of results'], correctIndex:0, explanation:'The narrow sample limits external validity.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Der Vorschlag adressiert ein reales Problem, setzt aber am Symptom an. Solange die zugrunde liegenden Anreize unverändert bleiben, ist zu erwarten, dass ähnliche Fehlentwicklungen an anderer Stelle auftreten.', prompt:'What is the main criticism?', options:<String>['The proposal treats symptoms rather than underlying incentives','The problem is imaginary','Incentives have already changed','No side effects are possible'], correctIndex:0, explanation:'The speaker distinguishes symptom treatment from root cause.'),
  ], writingPrompt:'Synthesize two conflicting hypothetical studies on remote work and explain how design, measurement and population could reconcile their conclusions.', writingChecklist:<String>['Accurate synthesis','Method comparison','No false contradiction','Limits','Research recommendation'], speakingPrompt:'Chair a discussion on mandatory AI disclosure in university work and produce a balanced closing summary.', speakingChecklist:<String>['Neutral framing','Turn management','Reformulation','Conflict mediation','Balanced synthesis']),

  ExamPracticeSet(id:'mock-c2-1', level:CefrLevel.c2, title:'C2 Mini Mock 1', objectiveQuestions:<ExamObjectiveQuestion>[
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Wer von Regulierung “der Technik” spricht, unterschlägt leicht, dass nicht Artefakte als solche reguliert werden, sondern Praktiken, Verantwortungszuschreibungen und Risikoverteilungen. Die begriffliche Verkürzung ist politisch folgenreich, weil sie bestimmte Handlungsoptionen bereits sprachlich aus dem Blick rückt.', prompt:'What is the critique of the phrase “regulation of technology”?', options:<String>['It can obscure the social practices and allocations actually being regulated','Technology cannot be regulated legally','Artifacts have no social effects','Political language is always meaningless'], correctIndex:0, explanation:'The author argues that the shorthand hides the real regulatory objects and options.'),
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Dass eine Theorie nahezu jeden beobachteten Ausgang nachträglich erklären kann, erhöht nicht zwingend ihre Erklärungskraft. Ohne riskante Vorhersagen droht Anpassungsfähigkeit in Unwiderlegbarkeit umzuschlagen.', prompt:'Which epistemic concern is raised?', options:<String>['A theory that explains everything after the fact may be insufficiently falsifiable','Flexible theories are always superior','Prediction is irrelevant to explanation','Observation should be avoided'], correctIndex:0, explanation:'The passage warns that unrestricted post-hoc fit can undermine falsifiability.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Ich bestreite nicht, dass die Kennzahl nützlich ist. Problematisch wird es erst, wenn aus ihrer Messbarkeit eine ontologische Vorrangstellung abgeleitet wird, als wäre nur real, was sich in eben dieser Kennzahl abbilden lässt.', prompt:'What does the speaker object to?', options:<String>['Treating what is measurable by one metric as uniquely real or important','Using any metrics at all','Collecting quantitative data carefully','Comparing several indicators'], correctIndex:0, explanation:'The objection is to reifying the metric, not to measurement itself.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Der Konsens ist bemerkenswert, aber nicht zwingend ein Beleg für die Stärke des Arguments. Er könnte ebenso daraus resultieren, dass bestimmte Gegenpositionen im Auswahlprozess gar nicht erst repräsentiert waren.', prompt:'What alternative explanation for consensus is offered?', options:<String>['Selection may have excluded dissenting positions','The argument is mathematically proven','Everyone independently reached the same view','No selection process occurred'], correctIndex:0, explanation:'Selection bias could create apparent consensus.'),
  ], writingPrompt:'Write a synthesis and critique of the proposition: “A neutral metric makes a neutral decision.” Address measurement, value choice, institutional context and accountability.', writingChecklist:<String>['Conceptual precision','Multiple perspectives','Subtle qualification','Cohesion','Register control','Independent conclusion'], speakingPrompt:'Defend a policy you only partly agree with, then switch sides and articulate the strongest objection without caricature.', speakingChecklist:<String>['Rhetorical control','Calibrated stance','Steelman opposition','Register flexibility','Conditional conclusion']),
  ExamPracticeSet(id:'mock-c2-2', level:CefrLevel.c2, title:'C2 Mini Mock 2', objectiveQuestions:<ExamObjectiveQuestion>[
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Die Forderung nach Evidenzbasierung ist sinnvoll, solange “Evidenz” nicht als selbstinterpretierende Größe missverstanden wird. Welche Befunde entscheidungsrelevant sind, hängt von Zielsetzungen, Unsicherheitstoleranz und der Verteilung möglicher Schäden ab.', prompt:'What qualification is made?', options:<String>['Evidence still requires interpretation in light of goals and risk distribution','Evidence automatically determines policy','Uncertainty should never affect decisions','All findings have equal relevance'], correctIndex:0, explanation:'Evidence does not eliminate normative and decision-theoretic judgement.'),
    ExamObjectiveQuestion(module:ExamModuleType.reading, contextText:'Die Pointe des Essays liegt weniger in seiner expliziten These als in der wiederholten Verschiebung der Perspektive: Was zunächst als individuelles Versagen erscheint, wird schrittweise als institutionell erzeugtes Dilemma lesbar.', prompt:'Where does the essay’s main effect lie?', options:<String>['In reframing an individual problem as an institutional dilemma','In stating one thesis repeatedly','In avoiding any perspective shift','In proving personal blame'], correctIndex:0, explanation:'The key is the progressive reframing.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Die Gegenposition überzeugt dort, wo sie vor unbeabsichtigten Nebenfolgen warnt. Sie überschätzt jedoch die Symmetrie der Risiken: Nicht zu handeln ist hier keineswegs neutral, sondern hat seinerseits absehbare Kosten.', prompt:'How does the speaker evaluate the opposing view?', options:<String>['Partly valid, but it underestimates the costs of inaction','Entirely false and irrelevant','Completely correct without qualification','Concerned only with grammar'], correctIndex:0, explanation:'The speaker concedes one point while challenging risk symmetry.'),
    ExamObjectiveQuestion(module:ExamModuleType.listening, spokenText:'Man kann den Begriff enger definieren und gewinnt dadurch analytische Trennschärfe. Zugleich verliert man Phänomene, die im Alltagsgebrauch gerade zum Bedeutungsfeld gehören. Die sinnvollere Definition hängt also vom Erkenntnisinteresse ab.', prompt:'What determines the preferable definition?', options:<String>['The analytical purpose','The longest possible wording','Everyday usage alone','A fixed universal rule'], correctIndex:0, explanation:'The speaker ties definition choice to research purpose.'),
  ], writingPrompt:'Write an editorial-style response to a complex policy dispute. Represent two serious positions, identify a hidden premise shared by both, and propose a reframed question.', writingChecklist:<String>['Fair synthesis','Hidden premise','Rhetorical control','Reframing','Nuanced conclusion'], speakingPrompt:'Give a spontaneous-style synthesis of economic, ethical and technical perspectives on automation, then answer three imagined follow-up challenges.', speakingChecklist:<String>['Integration rather than listing','Nuance','Idiomatic transitions','Fast reformulation','Precise answers']),
];

List<ExamPracticeSet> examSetsFor(CefrLevel level) =>
    examPracticeSets.where((set) => set.level == level).toList(growable: false);
