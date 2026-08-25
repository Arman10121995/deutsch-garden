import 'models.dart';
import 'vocabulary.dart';

/// A sentence used by the word-bank builder and the dictation drill.
class PracticeSentence {
  const PracticeSentence({
    required this.id,
    required this.level,
    required this.german,
    required this.english,
    this.focus = '',
  });

  final String id;
  final CefrLevel level;
  final String german;
  final String english;

  /// The structure this sentence is meant to practise, shown after a correct
  /// answer so the drill teaches a rule rather than one string.
  final String focus;

  List<String> get tokens =>
      german.split(RegExp(r'\s+')).where((token) => token.isNotEmpty).toList();
}

/// Sentences written specifically to drill one structure each.
const List<PracticeSentence> curatedSentences = <PracticeSentence>[
  PracticeSentence(id: 'ps-a1-01', level: CefrLevel.a1, german: 'Ich komme aus Indien.', english: 'I come from India.', focus: 'aus + country'),
  PracticeSentence(id: 'ps-a1-02', level: CefrLevel.a1, german: 'Heute gehe ich ins Kino.', english: 'Today I am going to the cinema.', focus: 'Verb second after a fronted time phrase'),
  PracticeSentence(id: 'ps-a1-03', level: CefrLevel.a1, german: 'Wir haben keinen Zucker mehr.', english: 'We have no sugar left.', focus: 'kein- in the accusative'),
  PracticeSentence(id: 'ps-a1-04', level: CefrLevel.a1, german: 'Kannst du mir bitte helfen?', english: 'Can you help me, please?', focus: 'helfen + Dativ'),
  PracticeSentence(id: 'ps-a1-05', level: CefrLevel.a1, german: 'Der Bus fährt um sieben Uhr ab.', english: 'The bus leaves at seven.', focus: 'Separable verb: abfahren'),
  PracticeSentence(id: 'ps-a1-06', level: CefrLevel.a1, german: 'Meine Wohnung ist klein, aber sehr hell.', english: 'My flat is small but very bright.', focus: 'aber keeps normal word order'),
  PracticeSentence(id: 'ps-a1-07', level: CefrLevel.a1, german: 'Wo finde ich die Milch?', english: 'Where do I find the milk?', focus: 'W-question, verb in position two'),
  PracticeSentence(id: 'ps-a1-08', level: CefrLevel.a1, german: 'Ich möchte einen Kaffee, bitte.', english: 'I would like a coffee, please.', focus: 'möchten + Akkusativ'),
  PracticeSentence(id: 'ps-a2-01', level: CefrLevel.a2, german: 'Gestern bin ich mit dem Rad zur Arbeit gefahren.', english: 'Yesterday I rode my bike to work.', focus: 'Perfekt with sein for movement'),
  PracticeSentence(id: 'ps-a2-02', level: CefrLevel.a2, german: 'Ich habe den Schlüssel auf den Tisch gelegt.', english: 'I put the key on the table.', focus: 'Two-way preposition with movement: Akkusativ'),
  PracticeSentence(id: 'ps-a2-03', level: CefrLevel.a2, german: 'Der Schlüssel liegt auf dem Tisch.', english: 'The key is lying on the table.', focus: 'Two-way preposition with position: Dativ'),
  PracticeSentence(id: 'ps-a2-04', level: CefrLevel.a2, german: 'Ich konnte nicht kommen, weil ich krank war.', english: 'I could not come because I was ill.', focus: 'weil sends the verb to the end'),
  PracticeSentence(id: 'ps-a2-05', level: CefrLevel.a2, german: 'Wir freuen uns auf das Wochenende.', english: 'We are looking forward to the weekend.', focus: 'sich freuen auf + Akkusativ'),
  PracticeSentence(id: 'ps-a2-06', level: CefrLevel.a2, german: 'Dieses Buch ist interessanter als der Film.', english: 'This book is more interesting than the film.', focus: 'Comparative with als'),
  PracticeSentence(id: 'ps-a2-07', level: CefrLevel.a2, german: 'Ich habe vergessen, die Rechnung zu bezahlen.', english: 'I forgot to pay the bill.', focus: 'Infinitive clause with zu'),
  PracticeSentence(id: 'ps-a2-08', level: CefrLevel.a2, german: 'Seit drei Monaten wohne ich in Rostock.', english: 'I have been living in Rostock for three months.', focus: 'seit + Dativ with present tense'),
  PracticeSentence(id: 'ps-b1-01', level: CefrLevel.b1, german: 'Der Brief wurde gestern abgeschickt.', english: 'The letter was sent yesterday.', focus: 'Passive in the Präteritum'),
  PracticeSentence(id: 'ps-b1-02', level: CefrLevel.b1, german: 'Wenn ich mehr Zeit hätte, würde ich Klavier lernen.', english: 'If I had more time, I would learn piano.', focus: 'Konjunktiv II hypothetical'),
  PracticeSentence(id: 'ps-b1-03', level: CefrLevel.b1, german: 'Das ist der Kollege, dem ich das Dokument geschickt habe.', english: 'That is the colleague to whom I sent the document.', focus: 'Relative clause in the dative'),
  PracticeSentence(id: 'ps-b1-04', level: CefrLevel.b1, german: 'Obwohl es regnete, sind wir spazieren gegangen.', english: 'Although it was raining, we went for a walk.', focus: 'obwohl + verb-final, then inversion'),
  PracticeSentence(id: 'ps-b1-05', level: CefrLevel.b1, german: 'Ich habe mich um die Stelle beworben.', english: 'I applied for the position.', focus: 'sich bewerben um + Akkusativ'),
  PracticeSentence(id: 'ps-b1-06', level: CefrLevel.b1, german: 'Bevor ich einkaufe, schreibe ich immer eine Liste.', english: 'Before I go shopping, I always write a list.', focus: 'Temporal clause with bevor'),
  PracticeSentence(id: 'ps-b1-07', level: CefrLevel.b1, german: 'Nachdem er angekommen war, rief er sofort an.', english: 'After he had arrived, he called immediately.', focus: 'nachdem + Plusquamperfekt'),
  PracticeSentence(id: 'ps-b2-01', level: CefrLevel.b2, german: 'Die Ergebnisse müssen noch überprüft werden.', english: 'The results still have to be checked.', focus: 'Modal passive'),
  PracticeSentence(id: 'ps-b2-02', level: CefrLevel.b2, german: 'Einerseits spart das Zeit, andererseits steigen die Kosten.', english: 'On the one hand it saves time, on the other costs rise.', focus: 'Two-part connector, inversion in both halves'),
  PracticeSentence(id: 'ps-b2-03', level: CefrLevel.b2, german: 'Die im Bericht genannten Zahlen stammen aus dem Vorjahr.', english: 'The figures named in the report come from the previous year.', focus: 'Extended participial attribute'),
  PracticeSentence(id: 'ps-b2-04', level: CefrLevel.b2, german: 'Je genauer die Messung ist, desto zuverlässiger wird die Prognose.', english: 'The more precise the measurement, the more reliable the forecast.', focus: 'je … desto with verb-final then inversion'),
  PracticeSentence(id: 'ps-b2-05', level: CefrLevel.b2, german: 'Statt zu diskutieren, sollten wir die Daten prüfen.', english: 'Instead of discussing, we should check the data.', focus: 'statt … zu + infinitive'),
  PracticeSentence(id: 'ps-b2-06', level: CefrLevel.b2, german: 'Die Anlage lässt sich innerhalb einer Stunde umrüsten.', english: 'The plant can be converted within an hour.', focus: 'sich lassen as a passive alternative'),
  PracticeSentence(id: 'ps-c1-01', level: CefrLevel.c1, german: 'Er behauptete, er habe davon nichts gewusst.', english: 'He claimed he had known nothing about it.', focus: 'Reported speech with Konjunktiv I'),
  PracticeSentence(id: 'ps-c1-02', level: CefrLevel.c1, german: 'Die Prüfung der Unterlagen erfolgt durch die Fachabteilung.', english: 'The examination of the documents is carried out by the specialist department.', focus: 'Nominal style with erfolgen'),
  PracticeSentence(id: 'ps-c1-03', level: CefrLevel.c1, german: 'Hätte man früher reagiert, wäre der Schaden geringer ausgefallen.', english: 'Had one reacted earlier, the damage would have been smaller.', focus: 'Counterfactual past without wenn'),
  PracticeSentence(id: 'ps-c1-04', level: CefrLevel.c1, german: 'Wir nehmen Bezug auf Ihr Schreiben vom fünften Mai.', english: 'We refer to your letter of the fifth of May.', focus: 'Functional verb construction: Bezug nehmen auf'),
  PracticeSentence(id: 'ps-c1-05', level: CefrLevel.c1, german: 'Das Verfahren ist keineswegs so eindeutig, wie es zunächst scheint.', english: 'The procedure is by no means as unambiguous as it first appears.', focus: 'Negation scope with keineswegs'),
  PracticeSentence(id: 'ps-c2-01', level: CefrLevel.c2, german: 'Nicht die Methode ist umstritten, sondern deren Anwendung.', english: 'It is not the method that is contested, but its application.', focus: 'Marked information structure with nicht … sondern'),
  PracticeSentence(id: 'ps-c2-02', level: CefrLevel.c2, german: 'Man hätte den Vorgang längst dokumentieren müssen.', english: 'The process should long since have been documented.', focus: 'Ersatzinfinitiv with a modal in the Perfekt'),
  PracticeSentence(id: 'ps-c2-03', level: CefrLevel.c2, german: 'So plausibel die These auch klingt, empirisch ist sie kaum gestützt.', english: 'However plausible the thesis sounds, empirically it is barely supported.', focus: 'Concessive so … auch'),
  PracticeSentence(id: 'ps-c2-04', level: CefrLevel.c2, german: 'Es bedürfte einer erheblich breiteren Datengrundlage.', english: 'A considerably broader data basis would be required.', focus: 'bedürfen + Genitiv in Konjunktiv II'),
  PracticeSentence(id: 'ps-c2-05', level: CefrLevel.c2, german: 'Der Einwand mag berechtigt sein, entkräftet das Argument jedoch nicht.', english: 'The objection may be justified, but it does not refute the argument.', focus: 'Concessive mag … jedoch'),
  PracticeSentence(id: 'ps-a1-09', level: CefrLevel.a1, german: 'Ich lerne jeden Tag Deutsch.', english: 'I learn German every day.', focus: 'Frequency expression with jeden Tag'),
  PracticeSentence(id: 'ps-a1-10', level: CefrLevel.a1, german: 'Wie viel kostet die Fahrkarte?', english: 'How much does the ticket cost?', focus: 'Question phrase: Wie viel kostet'),
  PracticeSentence(id: 'ps-a2-09', level: CefrLevel.a2, german: 'Ich habe verschlafen, deshalb bin ich zu spät gekommen.', english: 'I overslept, that is why I arrived late.', focus: 'deshalb causes verb-second in sentence 2'),
  PracticeSentence(id: 'ps-a2-10', level: CefrLevel.a2, german: 'Wir wollen im Sommer nach Spanien reisen.', english: 'We want to travel to Spain in summer.', focus: 'Modal verb wollen + infinitive at end'),
  PracticeSentence(id: 'ps-b1-08', level: CefrLevel.b1, german: 'Je mehr man übt, desto leichter wird es.', english: 'The more one practices, the easier it gets.', focus: 'je … desto comparative structure'),
  PracticeSentence(id: 'ps-b1-09', level: CefrLevel.b1, german: 'Ich erinnere mich gerne an unsere Reise.', english: 'I fondly remember our trip.', focus: 'sich erinnern an + Akkusativ'),
  PracticeSentence(id: 'ps-b2-07', level: CefrLevel.b2, german: 'Anstatt zu warten, fangen wir sofort an.', english: 'Instead of waiting, we start immediately.', focus: 'anstatt zu + infinitive'),
  PracticeSentence(id: 'ps-b2-08', level: CefrLevel.b2, german: 'Die Aufgaben sind bis Freitag zu erledigen.', english: 'The tasks are to be completed by Friday.', focus: 'sein + zu + infinitive modal passive'),
  PracticeSentence(id: 'ps-c1-06', level: CefrLevel.c1, german: 'Ungeachtet der Einwände wurde der Beschluss gefasst.', english: 'Regardless of the objections, the resolution was passed.', focus: 'Genitive preposition: ungeachtet'),
  PracticeSentence(id: 'ps-c1-07', level: CefrLevel.c1, german: 'Es gilt, eine nachhaltige Lösung zu erarbeiten.', english: 'It is necessary to work out a sustainable solution.', focus: 'es gilt + zu + infinitive'),
  PracticeSentence(id: 'ps-c2-06', level: CefrLevel.c2, german: 'Das Argument entbehrt jeglicher wissenschaftlicher Grundlage.', english: 'The argument lacks any scientific foundation.', focus: 'entbehren + Genitiv'),
  PracticeSentence(id: 'ps-c2-07', level: CefrLevel.c2, german: 'Der Bericht lässt erhebliche Zweifel am Erreichen des Ziels aufkommen.', english: 'The report gives rise to substantial doubts about reaching the target.', focus: 'lassen + infinitive in formal prose'),
  PracticeSentence(id: 'ps-a1-11', level: CefrLevel.a1, german: 'Mein Name ist Maria und ich komme aus Deutschland.', english: 'My name is Maria and I come from Germany.', focus: 'Basic introduction structure'),
  PracticeSentence(id: 'ps-a1-12', level: CefrLevel.a1, german: 'Wir trinken am Nachmittag Kaffee und Tee.', english: 'We drink coffee and tea in the afternoon.', focus: 'Time expression am Nachmittag'),
  PracticeSentence(id: 'ps-a2-11', level: CefrLevel.a2, german: 'Wenn das Wetter schön ist, gehen wir im Park spazieren.', english: 'If the weather is nice, we go for a walk in the park.', focus: 'Conditional wenn clause + inversion'),
  PracticeSentence(id: 'ps-a2-12', level: CefrLevel.a2, german: 'Sie hat mir ein sehr interessantes Buch empfohlen.', english: 'She recommended a very interesting book to me.', focus: 'Dativ recipient + Akkusativ object'),
  PracticeSentence(id: 'ps-b1-10', level: CefrLevel.b1, german: 'Obwohl die Aufgabe schwierig schien, haben wir sie gelöst.', english: 'Although the task seemed difficult, we solved it.', focus: 'obwohl clause + main clause inversion'),
  PracticeSentence(id: 'ps-b1-11', level: CefrLevel.b1, german: 'Wir müssen uns gründlich auf das Vorstellungsgespräch vorbereiten.', english: 'We must prepare thoroughly for the job interview.', focus: 'sich vorbereiten auf + Akkusativ'),
  PracticeSentence(id: 'ps-b2-09', level: CefrLevel.b2, german: 'Je früher wir die Daten analysieren, desto eher können wir entscheiden.', english: 'The earlier we analyze the data, the sooner we can decide.', focus: 'je ... desto comparative construction'),
  PracticeSentence(id: 'ps-b2-10', level: CefrLevel.b2, german: 'Das Problem lässt sich nur durch enge Zusammenarbeit lösen.', english: 'The problem can only be solved through close cooperation.', focus: 'sich lassen passive alternative'),
  PracticeSentence(id: 'ps-c1-08', level: CefrLevel.c1, german: 'Angesichts der steigenden Nachfrage müssen die Kapazitäten erweitert werden.', english: 'In view of rising demand, capacities must be expanded.', focus: 'Genitive preposition: angesichts'),
  PracticeSentence(id: 'ps-c2-08', level: CefrLevel.c2, german: 'Unbeschadet bisheriger Vereinbarungen treten neue Richtlinien in Kraft.', english: 'Notwithstanding previous agreements, new guidelines take effect.', focus: 'High-register Genitive preposition: unbeschadet'),
];

/// Every card's example sentence doubles as practice material.
///
/// This used to draw on the hand-written core deck alone, because the
/// expansion deck's examples were the metalinguistic placeholder "Das Lernwort
/// heute ist …" and would have drilled nothing. 3.6.0 replaced all 678 of
/// those with real contextual sentences, so the exclusion no longer had a
/// reason to exist — and dropping it turns 63 curated sentences into over nine
/// thousand, feeding the sentence builder, dictation, shadowing and cloze
/// drills without a word of new prose.
///
/// The 4-to-11 word window is kept: shorter sentences carry too little context
/// to drill, longer ones are unwieldy to rebuild from a word bank.
List<PracticeSentence> _derivedSentences(CefrLevel level) {
  final List<PracticeSentence> result = <PracticeSentence>[];
  for (final GermanWord word in vocabulary) {
    if (word.level.toUpperCase() != level.label) continue;
    final int words = word.exampleGerman.split(RegExp(r'\s+')).length;
    if (words < 4 || words > 11) continue;
    result.add(
      PracticeSentence(
        id: 'ps-x-${word.id}',
        level: level,
        german: word.exampleGerman,
        english: word.exampleEnglish,
        focus: 'Uses „${word.german}“',
      ),
    );
  }
  return result;
}

List<PracticeSentence> sentencesFor(CefrLevel level) => <PracticeSentence>[
      ...curatedSentences.where((sentence) => sentence.level == level),
      ..._derivedSentences(level),
    ];
