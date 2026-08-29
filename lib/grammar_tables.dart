/// Compact grammar reference tables used by lessons and the handbook.
library;

import 'package:flutter/material.dart';

import 'models.dart';
import 'sentence_audio.dart';

class GrammarReferenceTable {
  const GrammarReferenceTable({
    required this.id,
    required this.level,
    required this.title,
    required this.columns,
    required this.rows,
    required this.note,
    required this.keywords,
  });

  final String id;
  final CefrLevel level;
  final String title;
  final List<String> columns;
  final List<List<String>> rows;
  final String note;
  final List<String> keywords;
}

const List<GrammarReferenceTable>
grammarReferenceTables = <GrammarReferenceTable>[
  GrammarReferenceTable(
    id: 'table-a1-sein-haben',
    level: CefrLevel.a1,
    title: 'Present tense: sein and haben',
    columns: <String>['Person', 'sein', 'haben'],
    rows: <List<String>>[
      <String>['ich', 'bin', 'habe'],
      <String>['du', 'bist', 'hast'],
      <String>['er/sie/es', 'ist', 'hat'],
      <String>['wir', 'sind', 'haben'],
      <String>['ihr', 'seid', 'habt'],
      <String>['sie/Sie', 'sind', 'haben'],
    ],
    note:
        'These two verbs are irregular and should be learned as complete '
        'paradigms.',
    keywords: <String>['sein', 'haben', 'pronoun', 'present'],
  ),
  GrammarReferenceTable(
    id: 'table-a1-regular-present',
    level: CefrLevel.a1,
    title: 'Regular present tense: machen',
    columns: <String>['Person', 'Ending', 'machen'],
    rows: <List<String>>[
      <String>['ich', '-e', 'mache'],
      <String>['du', '-st', 'machst'],
      <String>['er/sie/es', '-t', 'macht'],
      <String>['wir', '-en', 'machen'],
      <String>['ihr', '-t', 'macht'],
      <String>['sie/Sie', '-en', 'machen'],
    ],
    note:
        'Remove -en from the infinitive to find the stem, then add the '
        'personal ending.',
    keywords: <String>['verb', 'conjug', 'present', 'position'],
  ),
  GrammarReferenceTable(
    id: 'table-a1-articles',
    level: CefrLevel.a1,
    title: 'Definite articles by case',
    columns: <String>['Case', 'Masculine', 'Feminine', 'Neuter', 'Plural'],
    rows: <List<String>>[
      <String>['Nominative', 'der', 'die', 'das', 'die'],
      <String>['Accusative', 'den', 'die', 'das', 'die'],
      <String>['Dative', 'dem', 'der', 'dem', 'den + -n'],
      <String>['Genitive', 'des + -(e)s', 'der', 'des + -(e)s', 'der'],
    ],
    note:
        'The masculine accusative is the first visible case change most '
        'learners meet: der becomes den.',
    keywords: <String>['article', 'case', 'nominative', 'accusative', 'dative'],
  ),
  GrammarReferenceTable(
    id: 'table-a1-modals',
    level: CefrLevel.a1,
    title: 'Modal verbs in the present',
    columns: <String>['Person', 'können', 'müssen', 'wollen'],
    rows: <List<String>>[
      <String>['ich', 'kann', 'muss', 'will'],
      <String>['du', 'kannst', 'musst', 'willst'],
      <String>['er/sie/es', 'kann', 'muss', 'will'],
      <String>['wir', 'können', 'müssen', 'wollen'],
      <String>['ihr', 'könnt', 'müsst', 'wollt'],
      <String>['sie/Sie', 'können', 'müssen', 'wollen'],
    ],
    note:
        'The modal is conjugated in position two; the second verb stays in '
        'the infinitive at the end.',
    keywords: <String>['modal', 'können', 'müssen', 'wollen'],
  ),
  GrammarReferenceTable(
    id: 'table-a2-pronouns',
    level: CefrLevel.a2,
    title: 'Personal pronouns by case',
    columns: <String>['Person', 'Nominative', 'Accusative', 'Dative'],
    rows: <List<String>>[
      <String>['1st singular', 'ich', 'mich', 'mir'],
      <String>['2nd singular', 'du', 'dich', 'dir'],
      <String>['3rd masculine', 'er', 'ihn', 'ihm'],
      <String>['3rd feminine', 'sie', 'sie', 'ihr'],
      <String>['3rd neuter', 'es', 'es', 'ihm'],
      <String>['1st plural', 'wir', 'uns', 'uns'],
      <String>['2nd plural', 'ihr', 'euch', 'euch'],
      <String>['3rd/formal', 'sie/Sie', 'sie/Sie', 'ihnen/Ihnen'],
    ],
    note:
        'Ask who performs the action, whom it affects, and to whom or for '
        'whom it happens.',
    keywords: <String>['pronoun', 'object', 'accusative', 'dative'],
  ),
  GrammarReferenceTable(
    id: 'table-a2-perfect',
    level: CefrLevel.a2,
    title: 'Perfect tense: auxiliary and participle',
    columns: <String>['Verb type', 'Auxiliary', 'Example'],
    rows: <List<String>>[
      <String>['Most verbs', 'haben', 'Ich habe gearbeitet.'],
      <String>['Movement A → B', 'sein', 'Wir sind gefahren.'],
      <String>['Change of state', 'sein', 'Er ist eingeschlafen.'],
      <String>['sein / bleiben', 'sein', 'Sie ist geblieben.'],
      <String>['-ieren verbs', 'haben, no ge-', 'Ich habe studiert.'],
      <String>['Separable verb', 'ge- inside', 'Sie hat angerufen.'],
    ],
    note:
        'The conjugated auxiliary occupies position two; the participle '
        'closes the sentence bracket.',
    keywords: <String>['perfekt', 'participle', 'haben or sein', 'past'],
  ),
  GrammarReferenceTable(
    id: 'table-a2-two-way',
    level: CefrLevel.a2,
    title: 'Two-way prepositions',
    columns: <String>['Question', 'Case', 'Example'],
    rows: <List<String>>[
      <String>['Wo? location', 'Dative', 'Das Bild hängt an der Wand.'],
      <String>['Wohin? destination', 'Accusative', 'Ich hänge es an die Wand.'],
    ],
    note:
        'The case follows meaning, not the verb alone: location uses dative '
        'and directed placement uses accusative.',
    keywords: <String>[
      'two-way',
      'wechsel',
      'where',
      'location',
      'preposition',
    ],
  ),
  GrammarReferenceTable(
    id: 'table-b1-adjective-endings',
    level: CefrLevel.b1,
    title: 'Adjective endings: the signal principle',
    columns: <String>['Determiner signal', 'Typical ending', 'Example'],
    rows: <List<String>>[
      <String>['Article shows case/gender', '-e / -en', 'mit dem neuen Zug'],
      <String>['ein-word partly shows it', 'mixed', 'ein neuer Zug'],
      <String>['No article shows it', 'strong', 'mit kaltem Wasser'],
      <String>['Plural after die/den', '-en', 'die neuen Züge'],
    ],
    note:
        'An adjective supplies the grammatical signal only when the word '
        'before it does not already supply it.',
    keywords: <String>['adjective', 'ending', 'declension', 'strong', 'weak'],
  ),
  GrammarReferenceTable(
    id: 'table-b1-relative',
    level: CefrLevel.b1,
    title: 'Relative pronouns',
    columns: <String>['Case', 'Masculine', 'Feminine', 'Neuter', 'Plural'],
    rows: <List<String>>[
      <String>['Nominative', 'der', 'die', 'das', 'die'],
      <String>['Accusative', 'den', 'die', 'das', 'die'],
      <String>['Dative', 'dem', 'der', 'dem', 'denen'],
      <String>['Genitive', 'dessen', 'deren', 'dessen', 'deren'],
    ],
    note:
        'Gender and number come from the antecedent; case comes from the '
        'relative pronoun’s job inside its own clause.',
    keywords: <String>['relative', 'antecedent', 'whose'],
  ),
  GrammarReferenceTable(
    id: 'table-b1-passive',
    level: CefrLevel.b1,
    title: 'Process passive with werden',
    columns: <String>['Tense', 'Form', 'Example'],
    rows: <List<String>>[
      <String>['Present', 'wird + participle', 'Das Haus wird gebaut.'],
      <String>['Preterite', 'wurde + participle', 'Das Haus wurde gebaut.'],
      <String>['Perfect', 'ist + participle + worden', 'Es ist gebaut worden.'],
      <String>[
        'With modal',
        'modal + participle + werden',
        'Es muss gebaut werden.',
      ],
    ],
    note:
        'Use werden for a process. sein + participle normally describes the '
        'resulting state.',
    keywords: <String>['passive', 'werden', 'worden'],
  ),
  GrammarReferenceTable(
    id: 'table-b2-konjunktiv-two',
    level: CefrLevel.b2,
    title: 'Konjunktiv II: unreal and polite language',
    columns: <String>['Function', 'Form', 'Example'],
    rows: <List<String>>[
      <String>[
        'Polite request',
        'würde + infinitive',
        'Würden Sie mir helfen?',
      ],
      <String>['Unreal condition', 'hätte/wäre', 'Wenn ich Zeit hätte …'],
      <String>['Advice', 'sollte', 'Du solltest früher gehen.'],
      <String>['Ability/wish', 'könnte', 'Ich könnte morgen kommen.'],
    ],
    note:
        'Common short forms such as wäre, hätte and könnte are preferred to '
        'würde + infinitive.',
    keywords: <String>['konjunktiv ii', 'unreal', 'polite', 'würde'],
  ),
  GrammarReferenceTable(
    id: 'table-b2-tense-overview',
    level: CefrLevel.b2,
    title: 'Tense and register overview',
    columns: <String>['Tense', 'Main use', 'Example'],
    rows: <List<String>>[
      <String>['Präsens', 'now / planned future', 'Morgen fahre ich.'],
      <String>['Perfekt', 'spoken past', 'Ich bin gefahren.'],
      <String>[
        'Präteritum',
        'written past / common auxiliaries',
        'Ich war dort.',
      ],
      <String>['Plusquamperfekt', 'earlier past', 'Ich war gefahren.'],
      <String>['Futur I', 'prediction / intention', 'Ich werde fahren.'],
      <String>[
        'Futur II',
        'completed future / assumption',
        'Er wird gefahren sein.',
      ],
    ],
    note:
        'German tense choice depends on register and viewpoint as well as '
        'calendar time.',
    keywords: <String>['tense', 'präteritum', 'plusquamperfekt', 'future'],
  ),
  GrammarReferenceTable(
    id: 'table-c1-indirect-speech',
    level: CefrLevel.c1,
    title: 'Konjunktiv I in reported speech',
    columns: <String>['Person', 'sein', 'haben', 'werden'],
    rows: <List<String>>[
      <String>['ich', 'sei', 'habe', 'werde'],
      <String>['du', 'seiest', 'habest', 'werdest'],
      <String>['er/sie/es', 'sei', 'habe', 'werde'],
      <String>['wir', 'seien', 'haben', 'werden'],
      <String>['ihr', 'seiet', 'habet', 'werdet'],
      <String>['sie/Sie', 'seien', 'haben', 'werden'],
    ],
    note:
        'When Konjunktiv I is identical to the indicative, formal German '
        'often substitutes a clear Konjunktiv II form.',
    keywords: <String>['konjunktiv i', 'reported', 'indirect speech'],
  ),
  GrammarReferenceTable(
    id: 'table-c2-register',
    level: CefrLevel.c2,
    title: 'Compact alternatives in formal register',
    columns: <String>['Expanded clause', 'Compact form', 'Example'],
    rows: <List<String>>[
      <String>[
        'weil es geprüft wurde',
        'nach Prüfung',
        'nach eingehender Prüfung',
      ],
      <String>[
        'obwohl er widersprach',
        'trotz seines Widerspruchs',
        'trotz Widerspruchs',
      ],
      <String>[
        'damit Kosten sinken',
        'zur Kostensenkung',
        'Maßnahmen zur Kostensenkung',
      ],
      <String>[
        'wenn man berücksichtigt',
        'unter Berücksichtigung',
        'unter Berücksichtigung der Lage',
      ],
    ],
    note:
        'Nominal style can make formal prose denser, but too much of it '
        'reduces clarity. Choose it deliberately, not automatically.',
    keywords: <String>['nominal', 'register', 'formal', 'compression'],
  ),
  GrammarReferenceTable(
    id: 'table-a1-indefinite-articles',
    level: CefrLevel.a1,
    title: 'Indefinite articles and kein',
    columns: <String>['Case', 'Masculine', 'Feminine', 'Neuter', 'Plural kein'],
    rows: <List<String>>[
      <String>['Nominative', 'ein', 'eine', 'ein', 'keine'],
      <String>['Accusative', 'einen', 'eine', 'ein', 'keine'],
      <String>['Dative', 'einem', 'einer', 'einem', 'keinen + -n'],
      <String>['Genitive', 'eines', 'einer', 'eines', 'keiner'],
    ],
    note:
        'Kein follows the ein-word endings. There is no positive indefinite '
        'article in the plural. The dative plural noun normally adds -n.',
    keywords: <String>['indefinite', 'ein', 'kein', 'article', 'negation'],
  ),
  GrammarReferenceTable(
    id: 'table-a1-word-order',
    level: CefrLevel.a1,
    title: 'Main-clause word order',
    columns: <String>['Purpose', 'Pattern', 'Example'],
    rows: <List<String>>[
      <String>[
        'Statement',
        'topic + finite verb + subject',
        'Heute lerne ich Deutsch.',
      ],
      <String>[
        'W-question',
        'W-word + finite verb + subject',
        'Wann kommst du?',
      ],
      <String>['Yes/no question', 'finite verb + subject', 'Kommst du heute?'],
      <String>[
        'Modal bracket',
        'modal + … + infinitive',
        'Ich kann heute kommen.',
      ],
      <String>['Separable verb', 'verb stem + … + prefix', 'Ich rufe dich an.'],
    ],
    note:
        'In a statement the finite verb stays in position two; position one '
        'may hold the subject, time, place or another single constituent.',
    keywords: <String>['word order', 'verb position', 'question', 'separable'],
  ),
  GrammarReferenceTable(
    id: 'table-a2-stem-changing-verbs',
    level: CefrLevel.a2,
    title: 'Present-tense stem changes',
    columns: <String>['Infinitive', 'du', 'er/sie/es', 'Example'],
    rows: <List<String>>[
      <String>['fahren', 'fährst', 'fährt', 'Er fährt mit dem Zug.'],
      <String>['laufen', 'läufst', 'läuft', 'Sie läuft jeden Morgen.'],
      <String>['lesen', 'liest', 'liest', 'Du liest die Zeitung.'],
      <String>['sprechen', 'sprichst', 'spricht', 'Er spricht sehr leise.'],
      <String>['nehmen', 'nimmst', 'nimmt', 'Sie nimmt den Bus.'],
    ],
    note:
        'The vowel change normally appears only with du and er/sie/es; the '
        'plural forms keep the infinitive stem.',
    keywords: <String>['stem change', 'strong verb', 'present', 'vowel'],
  ),
  GrammarReferenceTable(
    id: 'table-a2-preposition-cases',
    level: CefrLevel.a2,
    title: 'Prepositions grouped by case',
    columns: <String>['Case', 'Core prepositions', 'Example'],
    rows: <List<String>>[
      <String>[
        'Accusative',
        'durch, für, gegen, ohne, um',
        'Wir gehen durch den Park.',
      ],
      <String>[
        'Dative',
        'aus, außer, bei, mit, nach, seit, von, zu',
        'Ich fahre mit dem Bus.',
      ],
      <String>[
        'Genitive',
        'trotz, während, wegen, innerhalb',
        'Wegen des Regens bleiben wir hier.',
      ],
      <String>[
        'Two-way',
        'an, auf, hinter, in, neben, über, unter, vor, zwischen',
        'Das Buch liegt auf dem Tisch.',
      ],
    ],
    note:
        'Learn a preposition with its case as one item. Two-way prepositions '
        'use dative for location and accusative for a destination.',
    keywords: <String>[
      'preposition',
      'case',
      'accusative',
      'dative',
      'genitive',
    ],
  ),
  GrammarReferenceTable(
    id: 'table-a2-reflexive-pronouns',
    level: CefrLevel.a2,
    title: 'Reflexive pronouns',
    columns: <String>['Person', 'Accusative', 'Dative', 'Example'],
    rows: <List<String>>[
      <String>['ich', 'mich', 'mir', 'Ich wasche mich.'],
      <String>['du', 'dich', 'dir', 'Du kaufst dir ein Buch.'],
      <String>['er/sie/es', 'sich', 'sich', 'Sie freut sich.'],
      <String>['wir', 'uns', 'uns', 'Wir treffen uns.'],
      <String>['ihr', 'euch', 'euch', 'Ihr beeilt euch.'],
      <String>['sie/Sie', 'sich', 'sich', 'Sie setzen sich.'],
    ],
    note:
        'Use the dative form when the clause already has another accusative '
        'object: Ich wasche mir die Hände.',
    keywords: <String>['reflexive', 'pronoun', 'sich'],
  ),
  GrammarReferenceTable(
    id: 'table-b1-weak-adjective-endings',
    level: CefrLevel.b1,
    title: 'Adjective endings after der-words',
    columns: <String>['Case', 'Masculine', 'Feminine', 'Neuter', 'Plural'],
    rows: <List<String>>[
      <String>['Nominative', '-e', '-e', '-e', '-en'],
      <String>['Accusative', '-en', '-e', '-e', '-en'],
      <String>['Dative', '-en', '-en', '-en', '-en'],
      <String>['Genitive', '-en', '-en', '-en', '-en'],
    ],
    note:
        'After der/die/das and other der-words, the article already carries '
        'the grammatical signal. Only five cells use -e; all others use -en.',
    keywords: <String>['adjective ending', 'weak declension', 'der-word'],
  ),
  GrammarReferenceTable(
    id: 'table-b1-subordinate-connectors',
    level: CefrLevel.b1,
    title: 'Subordinate-clause connectors',
    columns: <String>['Relation', 'Connector', 'Example'],
    rows: <List<String>>[
      <String>['Reason', 'weil / da', 'Ich bleibe, weil ich krank bin.'],
      <String>['Concession', 'obwohl', 'Er kommt, obwohl er müde ist.'],
      <String>['Condition', 'wenn / falls', 'Ruf an, falls du Hilfe brauchst.'],
      <String>[
        'Purpose',
        'damit',
        'Ich spreche langsam, damit alle mich verstehen.',
      ],
      <String>['Result', 'sodass', 'Es schneite, sodass der Zug ausfiel.'],
    ],
    note:
        'A subordinating connector sends the finite verb to the end of its '
        'clause. The whole subordinate clause occupies one sentence position.',
    keywords: <String>['connector', 'subordinate', 'weil', 'obwohl', 'damit'],
  ),
  GrammarReferenceTable(
    id: 'table-b2-passive-contrast',
    level: CefrLevel.b2,
    title: 'Process passive and state passive',
    columns: <String>['Viewpoint', 'Form', 'Example'],
    rows: <List<String>>[
      <String>[
        'Active event',
        'subject + verb + object',
        'Die Firma öffnet die Tür.',
      ],
      <String>['Process', 'werden + participle', 'Die Tür wird geöffnet.'],
      <String>['Resulting state', 'sein + participle', 'Die Tür ist geöffnet.'],
      <String>['Past process', 'wurde + participle', 'Die Tür wurde geöffnet.'],
      <String>[
        'Perfect process',
        'ist + participle + worden',
        'Die Tür ist geöffnet worden.',
      ],
    ],
    note:
        'Werden presents an event or process. Sein presents the state that '
        'holds after an event.',
    keywords: <String>['passive', 'state passive', 'werden', 'sein'],
  ),
  GrammarReferenceTable(
    id: 'table-b2-verb-preposition-pairs',
    level: CefrLevel.b2,
    title: 'Common verb–preposition pairs',
    columns: <String>['Verb phrase', 'Case', 'Example'],
    rows: <List<String>>[
      <String>['warten auf', 'accusative', 'Wir warten auf den Zug.'],
      <String>[
        'sich erinnern an',
        'accusative',
        'Ich erinnere mich an den Tag.',
      ],
      <String>['teilnehmen an', 'dative', 'Sie nimmt an dem Kurs teil.'],
      <String>['abhängen von', 'dative', 'Das hängt vom Wetter ab.'],
      <String>[
        'sich beschäftigen mit',
        'dative',
        'Er beschäftigt sich mit Musik.',
      ],
    ],
    note:
        'Treat the verb, preposition and case as one lexical unit; the '
        'preposition is not freely interchangeable with its English gloss.',
    keywords: <String>['verb preposition', 'prepositional verb', 'rekti'],
  ),
  GrammarReferenceTable(
    id: 'table-c1-nominalisation',
    level: CefrLevel.c1,
    title: 'Clause and nominalisation alternatives',
    columns: <String>['Clause', 'Nominal phrase', 'Example'],
    rows: <List<String>>[
      <String>[
        'weil die Preise steigen',
        'wegen des Preisanstiegs',
        'Wegen des Preisanstiegs sank die Nachfrage.',
      ],
      <String>[
        'nachdem man geprüft hatte',
        'nach der Prüfung',
        'Nach der Prüfung wurde entschieden.',
      ],
      <String>[
        'damit man Kosten senkt',
        'zur Kostensenkung',
        'Zur Kostensenkung wurde der Plan geändert.',
      ],
      <String>[
        'obwohl er widersprach',
        'trotz seines Widerspruchs',
        'Trotz seines Widerspruchs galt der Beschluss.',
      ],
    ],
    note:
        'Nominalisation is useful in formal writing, but a verb-led clause '
        'is often clearer. Choose based on information density and register.',
    keywords: <String>['nominalisation', 'nominalization', 'academic', 'style'],
  ),
  GrammarReferenceTable(
    id: 'table-c1-discourse-connectors',
    level: CefrLevel.c1,
    title: 'Connectors for argument structure',
    columns: <String>['Relation', 'Connectors', 'Example'],
    rows: <List<String>>[
      <String>[
        'Addition',
        'zudem, darüber hinaus',
        'Zudem fehlen belastbare Daten.',
      ],
      <String>[
        'Contrast',
        'hingegen, demgegenüber',
        'Demgegenüber blieb die Nachfrage stabil.',
      ],
      <String>[
        'Consequence',
        'folglich, demnach',
        'Folglich muss die These revidiert werden.',
      ],
      <String>[
        'Concession',
        'gleichwohl, nichtsdestotrotz',
        'Gleichwohl ist Vorsicht geboten.',
      ],
      <String>[
        'Specification',
        'und zwar, genauer gesagt',
        'Die Frist endet bald, und zwar am Montag.',
      ],
    ],
    note:
        'Sentence adverbs occupy a position in the main clause; unlike '
        'subordinating conjunctions, they do not send the finite verb to the end.',
    keywords: <String>['discourse', 'connector', 'cohesion', 'argument'],
  ),
  GrammarReferenceTable(
    id: 'table-c2-stance-and-hedging',
    level: CefrLevel.c2,
    title: 'Calibrating claims in advanced prose',
    columns: <String>['Strength', 'Form', 'Example'],
    rows: <List<String>>[
      <String>[
        'Direct',
        'zeigt eindeutig',
        'Die Analyse zeigt eindeutig einen Trend.',
      ],
      <String>[
        'Supported',
        'deutet darauf hin',
        'Das Ergebnis deutet auf einen Trend hin.',
      ],
      <String>[
        'Cautious',
        'dürfte / könnte',
        'Der Effekt dürfte begrenzt sein.',
      ],
      <String>[
        'Attributed',
        'laut / zufolge',
        'Dem Bericht zufolge sinken die Werte.',
      ],
      <String>[
        'Qualified',
        'insofern … als',
        'Die Aussage stimmt insofern, als sie den Mittelwert betrifft.',
      ],
    ],
    note:
        'Advanced style does not mean making every claim weaker. Match the '
        'strength of the wording to the strength and source of the evidence.',
    keywords: <String>['hedging', 'stance', 'claim', 'register', 'evidence'],
  ),
];

List<GrammarReferenceTable> tablesForLesson(GrammarLesson lesson) {
  final String haystack = '${lesson.title} ${lesson.explanation}'.toLowerCase();
  return grammarReferenceTables
      .where(
        (GrammarReferenceTable table) =>
            table.level == lesson.level &&
            table.keywords.any((String keyword) => haystack.contains(keyword)),
      )
      .toList(growable: false);
}

class GrammarTableCard extends StatelessWidget {
  const GrammarTableCard({
    super.key,
    required this.table,
    this.ttsEnabled = true,
  });

  final GrammarReferenceTable table;
  final bool ttsEnabled;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              table.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: table.columns.length * 138.0,
                child: Table(
                  border: TableBorder.all(color: scheme.outlineVariant),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[
                    TableRow(
                      decoration: BoxDecoration(color: scheme.primaryContainer),
                      children: <Widget>[
                        for (final String column in table.columns)
                          Padding(
                            padding: const EdgeInsets.all(9),
                            child: Text(
                              column,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    for (final List<String> row in table.rows)
                      TableRow(
                        children: <Widget>[
                          for (int index = 0; index < row.length; index++)
                            Padding(
                              padding: const EdgeInsets.all(9),
                              child:
                                  table.columns[index].toLowerCase().contains(
                                    'example',
                                  )
                                  ? Row(
                                      children: <Widget>[
                                        Expanded(child: Text(row[index])),
                                        SentenceAudioButton(
                                          text: row[index],
                                          enabled: ttsEnabled,
                                        ),
                                      ],
                                    )
                                  : Text(row[index]),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(table.note, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class GrammarTablesScreen extends StatefulWidget {
  const GrammarTablesScreen({
    super.key,
    this.initialLevel = CefrLevel.a1,
    this.ttsEnabled = true,
  });

  final CefrLevel initialLevel;
  final bool ttsEnabled;

  @override
  State<GrammarTablesScreen> createState() => _GrammarTablesScreenState();
}

class _GrammarTablesScreenState extends State<GrammarTablesScreen> {
  late CefrLevel _level;

  @override
  void initState() {
    super.initState();
    _level = widget.initialLevel;
  }

  @override
  Widget build(BuildContext context) {
    final List<GrammarReferenceTable> tables = grammarReferenceTables
        .where((GrammarReferenceTable table) => table.level == _level)
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Grammar tables')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<CefrLevel>(
              segments: <ButtonSegment<CefrLevel>>[
                for (final CefrLevel level in CefrLevel.values)
                  ButtonSegment<CefrLevel>(
                    value: level,
                    label: Text(level.label),
                  ),
              ],
              selected: <CefrLevel>{_level},
              onSelectionChanged: (Set<CefrLevel> value) =>
                  setState(() => _level = value.single),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${_level.label} reference',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Use tables to notice a pattern, then return to examples and '
            'retrieval practice. A table is a map, not the journey.',
          ),
          const SizedBox(height: 14),
          for (final GrammarReferenceTable table in tables) ...<Widget>[
            GrammarTableCard(table: table, ttsEnabled: widget.ttsEnabled),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
