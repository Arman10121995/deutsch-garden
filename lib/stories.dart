import 'models.dart';
import 'stories_expansion.dart';
import 'stories_extra.dart';
import 'stories_ensemble.dart';
import 'tts_service.dart';

/// One sentence of a story, with its translation kept alongside so the reader
/// can switch between German-only immersion and a parallel bilingual view.
class StoryLine {
  const StoryLine(this.german, this.english, {this.voice});

  final String german;
  final String english;

  /// Who says this line, when the author knows.
  ///
  /// Null means "work it out from the punctuation", which is what every story
  /// written before 4.9 relies on: narration in the narrator's voice, and
  /// quoted speech alternating between two characters. That guess is right
  /// for an exchange between two people and wrong for anything else, so a
  /// scene with three or more speakers says who is talking instead of hoping.
  final GermanVoiceRole? voice;
}

/// A glossed item the reader can tap inside the text.
class StoryGloss {
  const StoryGloss(this.german, this.english, [this.note = '']);

  final String german;
  final String english;

  /// Optional grammar or usage note.
  final String note;
}

class StoryChapter {
  const StoryChapter({
    required this.id,
    required this.title,
    required this.titleEnglish,
    required this.lines,
    required this.glossary,
    required this.questions,
  });

  final String id;
  final String title;
  final String titleEnglish;
  final List<StoryLine> lines;
  final List<StoryGloss> glossary;
  final List<ChoiceQuestion> questions;

  int get wordCount => lines.fold<int>(
    0,
    (total, line) => total + line.german.split(RegExp(r'\s+')).length,
  );
}

class Story {
  const Story({
    required this.id,
    required this.level,
    required this.emoji,
    required this.title,
    required this.titleEnglish,
    required this.blurb,
    required this.chapters,
  });

  final String id;
  final CefrLevel level;
  final String emoji;
  final String title;
  final String titleEnglish;
  final String blurb;
  final List<StoryChapter> chapters;

  int get wordCount =>
      chapters.fold<int>(0, (total, chapter) => total + chapter.wordCount);

  /// Rough reading time, using the ~130 wpm a learner reads a graded text at.
  int get minutes => (wordCount / 130).ceil().clamp(1, 60).toInt();
}

const List<Story> _a1Stories = <Story>[
  Story(
    id: 'st-a1-01',
    level: CefrLevel.a1,
    emoji: '🚋',
    title: 'Der erste Tag in Rostock',
    titleEnglish: 'The first day in Rostock',
    blurb: 'Amir arrives in a new city with one suitcase and no German.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-a1-01-c1',
        title: 'Der Zug kommt an',
        titleEnglish: 'The train arrives',
        lines: <StoryLine>[
          StoryLine(
            'Der Zug hält. Amir steigt aus.',
            'The train stops. Amir gets off.',
          ),
          StoryLine(
            'Er hat einen Koffer und eine Tasche.',
            'He has a suitcase and a bag.',
          ),
          StoryLine(
            'Der Bahnhof ist groß und laut.',
            'The station is big and loud.',
          ),
          StoryLine('Amir sucht den Ausgang.', 'Amir looks for the exit.'),
          StoryLine(
            '„Entschuldigung, wo ist der Ausgang?“, fragt er.',
            '"Excuse me, where is the exit?" he asks.',
          ),
          StoryLine(
            'Eine Frau zeigt nach links. „Dort, geradeaus.“',
            'A woman points to the left. "There, straight ahead."',
          ),
          StoryLine(
            '„Danke schön!“, sagt Amir und lächelt.',
            '"Thank you!" says Amir and smiles.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('aussteigen', 'to get off', 'Separable: Er steigt aus.'),
          StoryGloss('der Koffer', 'suitcase'),
          StoryGloss('der Ausgang', 'exit'),
          StoryGloss('geradeaus', 'straight ahead'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was hat Amir dabei?',
            options: <String>[
              'Einen Koffer und eine Tasche',
              'Ein Fahrrad',
              'Einen Hund',
            ],
            correctIndex: 0,
            explanation: '„Er hat einen Koffer und eine Tasche.“',
          ),
          ChoiceQuestion(
            prompt: 'Was sucht Amir?',
            options: <String>['Den Ausgang', 'Ein Hotel', 'Seinen Freund'],
            correctIndex: 0,
            explanation: '„Amir sucht den Ausgang.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a1-01-c2',
        title: 'Die Wohnung',
        titleEnglish: 'The flat',
        lines: <StoryLine>[
          StoryLine(
            'Die Wohnung ist klein, aber hell.',
            'The flat is small but bright.',
          ),
          StoryLine(
            'Es gibt ein Zimmer, eine Küche und ein Bad.',
            'There is one room, a kitchen and a bathroom.',
          ),
          StoryLine(
            'Der Vermieter heißt Herr Krause.',
            'The landlord is called Mr Krause.',
          ),
          StoryLine(
            '„Hier ist der Schlüssel“, sagt er.',
            '"Here is the key," he says.',
          ),
          StoryLine(
            'Amir öffnet das Fenster. Draußen regnet es.',
            'Amir opens the window. Outside it is raining.',
          ),
          StoryLine(
            'Er stellt den Koffer auf den Boden und setzt sich.',
            'He puts the suitcase on the floor and sits down.',
          ),
          StoryLine(
            'Zum ersten Mal ist es ruhig.',
            'For the first time it is quiet.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('hell', 'bright'),
          StoryGloss('der Vermieter', 'landlord'),
          StoryGloss('der Schlüssel', 'key'),
          StoryGloss('ruhig', 'quiet'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wie ist die Wohnung?',
            options: <String>[
              'Klein und hell',
              'Groß und dunkel',
              'Alt und kalt',
            ],
            correctIndex: 0,
            explanation: '„Die Wohnung ist klein, aber hell.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie ist das Wetter?',
            options: <String>['Es regnet', 'Es schneit', 'Die Sonne scheint'],
            correctIndex: 0,
            explanation: '„Draußen regnet es.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a1-01-c3',
        title: 'Der Nachbar',
        titleEnglish: 'The neighbour',
        lines: <StoryLine>[
          StoryLine(
            'Am Abend klopft jemand an die Tür.',
            'In the evening someone knocks on the door.',
          ),
          StoryLine(
            'Ein Mann steht davor. Er ist alt und freundlich.',
            'A man is standing there. He is old and friendly.',
          ),
          StoryLine(
            '„Guten Abend! Ich bin Ihr Nachbar, Bernd.“',
            '"Good evening! I am your neighbour, Bernd."',
          ),
          StoryLine(
            '„Ich heiße Amir. Ich komme aus Syrien.“',
            '"My name is Amir. I come from Syria."',
          ),
          StoryLine(
            '„Willkommen! Trinken Sie Kaffee?“',
            '"Welcome! Do you drink coffee?"',
          ),
          StoryLine(
            'Amir lacht. „Ja, sehr gern.“',
            'Amir laughs. "Yes, very gladly."',
          ),
          StoryLine(
            'Sie trinken zusammen Kaffee und sprechen langsam Deutsch.',
            'They drink coffee together and speak German slowly.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('klopfen', 'to knock'),
          StoryGloss('der Nachbar', 'neighbour'),
          StoryGloss('willkommen', 'welcome'),
          StoryGloss('langsam', 'slowly'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wer steht vor der Tür?',
            options: <String>[
              'Der Nachbar',
              'Der Vermieter',
              'Eine Frau vom Bahnhof',
            ],
            correctIndex: 0,
            explanation: '„Ich bin Ihr Nachbar, Bernd.“',
          ),
          ChoiceQuestion(
            prompt: 'Was machen sie zusammen?',
            options: <String>[
              'Sie trinken Kaffee',
              'Sie kochen',
              'Sie gehen spazieren',
            ],
            correctIndex: 0,
            explanation: '„Sie trinken zusammen Kaffee.“',
          ),
        ],
      ),
    ],
  ),
  Story(
    id: 'st-a1-02',
    level: CefrLevel.a1,
    emoji: '🚲',
    title: 'Das verlorene Fahrrad',
    titleEnglish: 'The lost bicycle',
    blurb:
        'Lena parks her bike outside the library. It is not there afterwards.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-a1-02-c1',
        title: 'Vor der Bibliothek',
        titleEnglish: 'Outside the library',
        lines: <StoryLine>[
          StoryLine(
            'Lena fährt jeden Tag mit dem Fahrrad.',
            'Lena rides her bicycle every day.',
          ),
          StoryLine(
            'Heute geht sie in die Bibliothek.',
            'Today she is going to the library.',
          ),
          StoryLine(
            'Sie stellt das Fahrrad vor die Tür.',
            'She puts the bicycle in front of the door.',
          ),
          StoryLine('Sie lernt zwei Stunden.', 'She studies for two hours.'),
          StoryLine('Dann geht sie nach draußen.', 'Then she goes outside.'),
          StoryLine('Das Fahrrad ist weg!', 'The bicycle is gone!'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('das Fahrrad', 'bicycle'),
          StoryGloss('die Bibliothek', 'library'),
          StoryGloss('weg', 'gone'),
          StoryGloss('draußen', 'outside'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wohin geht Lena?',
            options: <String>[
              'In die Bibliothek',
              'In den Supermarkt',
              'Zur Arbeit',
            ],
            correctIndex: 0,
            explanation: '„Heute geht sie in die Bibliothek.“',
          ),
          ChoiceQuestion(
            prompt: 'Was ist das Problem?',
            options: <String>[
              'Das Fahrrad ist weg',
              'Die Bibliothek ist zu',
              'Es regnet',
            ],
            correctIndex: 0,
            explanation: '„Das Fahrrad ist weg!“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a1-02-c2',
        title: 'Bei der Polizei',
        titleEnglish: 'At the police station',
        lines: <StoryLine>[
          StoryLine('Lena geht zur Polizei.', 'Lena goes to the police.'),
          StoryLine(
            '„Mein Fahrrad ist weg“, sagt sie.',
            '"My bicycle is gone," she says.',
          ),
          StoryLine(
            '„Welche Farbe hat das Fahrrad?“, fragt der Polizist.',
            '"What colour is the bicycle?" asks the police officer.',
          ),
          StoryLine(
            '„Es ist grün und ziemlich alt.“',
            '"It is green and quite old."',
          ),
          StoryLine(
            '„Haben Sie die Nummer?“',
            '"Do you have the serial number?"',
          ),
          StoryLine(
            'Lena sucht in ihrer Tasche und findet ein Papier.',
            'Lena searches in her bag and finds a piece of paper.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('die Polizei', 'police'),
          StoryGloss('die Farbe', 'colour'),
          StoryGloss('ziemlich', 'quite / rather'),
          StoryGloss('finden', 'to find'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Welche Farbe hat das Fahrrad?',
            options: <String>['Grün', 'Rot', 'Blau'],
            correctIndex: 0,
            explanation: '„Es ist grün und ziemlich alt.“',
          ),
          ChoiceQuestion(
            prompt: 'Was findet Lena in der Tasche?',
            options: <String>['Ein Papier', 'Einen Schlüssel', 'Ihr Handy'],
            correctIndex: 0,
            explanation: '„… findet ein Papier.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a1-02-c3',
        title: 'Eine gute Nachricht',
        titleEnglish: 'Good news',
        lines: <StoryLine>[
          StoryLine(
            'Drei Tage später klingelt das Telefon.',
            'Three days later the phone rings.',
          ),
          StoryLine(
            '„Wir haben Ihr Fahrrad gefunden.“',
            '"We have found your bicycle."',
          ),
          StoryLine('Lena ist sehr glücklich.', 'Lena is very happy.'),
          StoryLine(
            'Das Fahrrad steht am Hafen.',
            'The bicycle is at the harbour.',
          ),
          StoryLine(
            'Es ist schmutzig, aber es funktioniert.',
            'It is dirty, but it works.',
          ),
          StoryLine(
            'Jetzt kauft Lena immer ein gutes Schloss.',
            'Now Lena always buys a good lock.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('klingeln', 'to ring'),
          StoryGloss('glücklich', 'happy'),
          StoryGloss('schmutzig', 'dirty'),
          StoryGloss('das Schloss', 'lock'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wo steht das Fahrrad?',
            options: <String>[
              'Am Hafen',
              'Vor der Bibliothek',
              'Bei der Polizei',
            ],
            correctIndex: 0,
            explanation: '„Das Fahrrad steht am Hafen.“',
          ),
          ChoiceQuestion(
            prompt: 'Was macht Lena jetzt immer?',
            options: <String>[
              'Sie kauft ein gutes Schloss',
              'Sie fährt Bus',
              'Sie geht zu Fuß',
            ],
            correctIndex: 0,
            explanation: '„Jetzt kauft Lena immer ein gutes Schloss.“',
          ),
        ],
      ),
    ],
  ),
];

const List<Story> _a2Stories = <Story>[
  Story(
    id: 'st-a2-01',
    level: CefrLevel.a2,
    emoji: '🌊',
    title: 'Ein Wochenende an der Ostsee',
    titleEnglish: 'A weekend on the Baltic Sea',
    blurb: 'Two friends plan a cheap weekend trip. Nothing goes as planned.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-a2-01-c1',
        title: 'Die Planung',
        titleEnglish: 'The planning',
        lines: <StoryLine>[
          StoryLine(
            'Jonas und Meret wollten schon lange ans Meer fahren.',
            'Jonas and Meret had wanted to go to the sea for a long time.',
          ),
          StoryLine(
            'Am Freitagabend haben sie endlich alles gebucht.',
            'On Friday evening they finally booked everything.',
          ),
          StoryLine(
            'Das Hotel war billig, weil es weit vom Strand entfernt lag.',
            'The hotel was cheap because it was far from the beach.',
          ),
          StoryLine(
            '„Das ist kein Problem“, sagte Jonas, „wir nehmen den Bus.“',
            '"That is no problem," said Jonas, "we will take the bus."',
          ),
          StoryLine(
            'Meret hat trotzdem ihre Wanderschuhe eingepackt.',
            'Meret packed her hiking boots anyway.',
          ),
          StoryLine(
            'Später war sie sehr froh darüber.',
            'Later she was very glad about that.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('buchen', 'to book'),
          StoryGloss('entfernt', 'away / distant'),
          StoryGloss('einpacken', 'to pack', 'Separable: sie packt ein.'),
          StoryGloss('froh', 'glad'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Warum war das Hotel billig?',
            options: <String>[
              'Es lag weit vom Strand entfernt',
              'Es war alt',
              'Es war Winter',
            ],
            correctIndex: 0,
            explanation: '„… weil es weit vom Strand entfernt lag.“',
          ),
          ChoiceQuestion(
            prompt: 'Was hat Meret eingepackt?',
            options: <String>[
              'Wanderschuhe',
              'Einen Regenschirm',
              'Ein Fahrrad',
            ],
            correctIndex: 0,
            explanation: '„… hat ihre Wanderschuhe eingepackt.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a2-01-c2',
        title: 'Kein Bus',
        titleEnglish: 'No bus',
        lines: <StoryLine>[
          StoryLine(
            'Am Samstagmorgen standen sie an der Haltestelle.',
            'On Saturday morning they stood at the bus stop.',
          ),
          StoryLine(
            'Auf dem Schild stand: „Kein Verkehr am Wochenende.“',
            'The sign said: "No service at weekends."',
          ),
          StoryLine(
            'Jonas hat geseufzt, aber Meret hat gelacht.',
            'Jonas sighed, but Meret laughed.',
          ),
          StoryLine(
            '„Zum Glück habe ich die Schuhe dabei. Wir laufen.“',
            '"Luckily I have the boots with me. We will walk."',
          ),
          StoryLine(
            'Der Weg war acht Kilometer lang und ging durch einen Wald.',
            'The path was eight kilometres long and went through a forest.',
          ),
          StoryLine(
            'Nach zwei Stunden haben sie das Meer gesehen.',
            'After two hours they saw the sea.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('die Haltestelle', 'bus stop'),
          StoryGloss('das Schild', 'sign'),
          StoryGloss('seufzen', 'to sigh'),
          StoryGloss('zum Glück', 'luckily'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Warum kam kein Bus?',
            options: <String>[
              'Am Wochenende fuhr keiner',
              'Der Bus hatte Verspätung',
              'Sie waren zu spät',
            ],
            correctIndex: 0,
            explanation: '„Kein Verkehr am Wochenende.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie lang war der Weg?',
            options: <String>[
              'Acht Kilometer',
              'Zwei Kilometer',
              'Zwanzig Kilometer',
            ],
            correctIndex: 0,
            explanation: '„Der Weg war acht Kilometer lang.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a2-01-c3',
        title: 'Der beste Fehler',
        titleEnglish: 'The best mistake',
        lines: <StoryLine>[
          StoryLine(
            'Der Strand war fast leer, weil es kühl war.',
            'The beach was almost empty because it was cool.',
          ),
          StoryLine(
            'Sie haben sich in den Sand gesetzt und Brote gegessen.',
            'They sat down in the sand and ate sandwiches.',
          ),
          StoryLine(
            'Ein Fischer hat ihnen gezeigt, wo man Bernstein findet.',
            'A fisherman showed them where you can find amber.',
          ),
          StoryLine(
            'Meret hat ein kleines Stück gefunden und eingesteckt.',
            'Meret found a small piece and pocketed it.',
          ),
          StoryLine(
            '„Ohne den kaputten Busplan wären wir nie hier gewesen“, sagte Jonas.',
            '"Without the broken bus timetable we would never have been here," said Jonas.',
          ),
          StoryLine(
            'Am Abend taten ihnen die Füße weh, aber niemand hat sich beschwert.',
            'In the evening their feet hurt, but nobody complained.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('leer', 'empty'),
          StoryGloss('der Bernstein', 'amber'),
          StoryGloss('einstecken', 'to pocket'),
          StoryGloss(
            'sich beschweren',
            'to complain',
            'Reflexive: er beschwert sich.',
          ),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Warum war der Strand leer?',
            options: <String>[
              'Es war kühl',
              'Es war Nacht',
              'Der Strand war gesperrt',
            ],
            correctIndex: 0,
            explanation: '„… weil es kühl war.“',
          ),
          ChoiceQuestion(
            prompt: 'Was hat Meret gefunden?',
            options: <String>[
              'Ein Stück Bernstein',
              'Eine Muschel',
              'Einen Schlüssel',
            ],
            correctIndex: 0,
            explanation: '„Meret hat ein kleines Stück gefunden.“',
          ),
        ],
      ),
    ],
  ),
  Story(
    id: 'st-a2-02',
    level: CefrLevel.a2,
    emoji: '🍲',
    title: 'Die neue Nachbarin',
    titleEnglish: 'The new neighbour',
    blurb: 'A quiet stairwell, a burnt pot, and an unexpected friendship.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-a2-02-c1',
        title: 'Rauch im Treppenhaus',
        titleEnglish: 'Smoke in the stairwell',
        lines: <StoryLine>[
          StoryLine(
            'Herr Tanaka wohnt seit zwölf Jahren im dritten Stock.',
            'Mr Tanaka has lived on the third floor for twelve years.',
          ),
          StoryLine(
            'Er kennt fast niemanden im Haus.',
            'He knows almost nobody in the building.',
          ),
          StoryLine(
            'An einem Dienstag hat es plötzlich nach Rauch gerochen.',
            'On a Tuesday it suddenly smelled of smoke.',
          ),
          StoryLine(
            'Er ist nach unten gelaufen und hat an einer Tür geklopft.',
            'He ran downstairs and knocked on a door.',
          ),
          StoryLine(
            'Eine junge Frau hat geöffnet. Hinter ihr war die Küche voller Rauch.',
            'A young woman opened. Behind her the kitchen was full of smoke.',
          ),
          StoryLine(
            '„Der Topf!“, hat sie gerufen. „Ich habe ihn vergessen!“',
            '"The pot!" she shouted. "I forgot it!"',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('der Rauch', 'smoke'),
          StoryGloss('riechen', 'to smell', 'Past: es roch / es hat gerochen.'),
          StoryGloss('der Topf', 'pot'),
          StoryGloss('vergessen', 'to forget'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wie lange wohnt Herr Tanaka im Haus?',
            options: <String>[
              'Seit zwölf Jahren',
              'Seit zwei Monaten',
              'Seit einem Jahr',
            ],
            correctIndex: 0,
            explanation: '„… seit zwölf Jahren im dritten Stock.“',
          ),
          ChoiceQuestion(
            prompt: 'Was war das Problem?',
            options: <String>[
              'Ein vergessener Topf',
              'Ein Feuer im Keller',
              'Ein kaputter Ofen',
            ],
            correctIndex: 0,
            explanation: '„Der Topf! Ich habe ihn vergessen!“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a2-02-c2',
        title: 'Zwei Teller',
        titleEnglish: 'Two plates',
        lines: <StoryLine>[
          StoryLine(
            'Zusammen haben sie die Fenster geöffnet.',
            'Together they opened the windows.',
          ),
          StoryLine(
            'Die Frau heißt Ayla und ist vor einer Woche eingezogen.',
            'The woman is called Ayla and moved in a week ago.',
          ),
          StoryLine(
            '„Ich wollte kochen und habe telefoniert“, hat sie erklärt.',
            '"I wanted to cook and I was on the phone," she explained.',
          ),
          StoryLine(
            'Herr Tanaka hat gelächelt und gesagt: „Das kenne ich.“',
            'Mr Tanaka smiled and said: "I know that feeling."',
          ),
          StoryLine(
            'Er hat sie zum Essen eingeladen, weil ihr Essen verbrannt war.',
            'He invited her to eat because her food was burnt.',
          ),
          StoryLine(
            'Zum ersten Mal seit langem hat er zwei Teller auf den Tisch gestellt.',
            'For the first time in ages he put two plates on the table.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('einziehen', 'to move in'),
          StoryGloss('erklären', 'to explain'),
          StoryGloss('einladen', 'to invite'),
          StoryGloss('verbrannt', 'burnt'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wann ist Ayla eingezogen?',
            options: <String>[
              'Vor einer Woche',
              'Vor einem Jahr',
              'Am selben Tag',
            ],
            correctIndex: 0,
            explanation: '„… ist vor einer Woche eingezogen.“',
          ),
          ChoiceQuestion(
            prompt: 'Warum lädt er sie ein?',
            options: <String>[
              'Ihr Essen war verbrannt',
              'Sie hat Geburtstag',
              'Sie hat gefragt',
            ],
            correctIndex: 0,
            explanation: '„… weil ihr Essen verbrannt war.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a2-02-c3',
        title: 'Dienstags',
        titleEnglish: 'On Tuesdays',
        lines: <StoryLine>[
          StoryLine(
            'Seitdem kochen sie jeden Dienstag zusammen.',
            'Since then they cook together every Tuesday.',
          ),
          StoryLine(
            'Ayla bringt Gemüse mit, Herr Tanaka macht die Suppe.',
            'Ayla brings vegetables, Mr Tanaka makes the soup.',
          ),
          StoryLine(
            'Manchmal kommt auch die alte Dame aus dem ersten Stock.',
            'Sometimes the old lady from the first floor comes too.',
          ),
          StoryLine(
            'Das Treppenhaus ist nicht mehr so still wie früher.',
            'The stairwell is not as quiet as it used to be.',
          ),
          StoryLine(
            'Herr Tanaka sagt, der Rauch war das Beste, was passiert ist.',
            'Mr Tanaka says the smoke was the best thing that happened.',
          ),
          StoryLine(
            'Ayla lacht jedes Mal, wenn er das erzählt.',
            'Ayla laughs every time he tells that.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('seitdem', 'since then'),
          StoryGloss('das Gemüse', 'vegetables'),
          StoryGloss('still', 'quiet / silent'),
          StoryGloss('erzählen', 'to tell'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was passiert jeden Dienstag?',
            options: <String>[
              'Sie kochen zusammen',
              'Sie gehen einkaufen',
              'Sie putzen das Treppenhaus',
            ],
            correctIndex: 0,
            explanation: '„Seitdem kochen sie jeden Dienstag zusammen.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie ist das Treppenhaus jetzt?',
            options: <String>[
              'Weniger still als früher',
              'Genauso still',
              'Immer leer',
            ],
            correctIndex: 0,
            explanation:
                '„Das Treppenhaus ist nicht mehr so still wie früher.“',
          ),
        ],
      ),
    ],
  ),
];

const List<Story> _b1Stories = <Story>[
  Story(
    id: 'st-b1-01',
    level: CefrLevel.b1,
    emoji: '📄',
    title: 'Der Praktikumsplatz',
    titleEnglish: 'The internship',
    blurb:
        'Nour needs one internship to finish her degree. There are 200 applicants.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-b1-01-c1',
        title: 'Die Absage',
        titleEnglish: 'The rejection',
        lines: <StoryLine>[
          StoryLine(
            'Die E-Mail kam an einem Montagmorgen, als Nour gerade Kaffee kochte.',
            'The email arrived on a Monday morning, just as Nour was making coffee.',
          ),
          StoryLine(
            '„Leider müssen wir Ihnen mitteilen, dass wir uns für eine andere Bewerberin entschieden haben.“',
            '"Unfortunately we must inform you that we have decided in favour of another candidate."',
          ),
          StoryLine(
            'Es war die siebte Absage in vier Wochen.',
            'It was the seventh rejection in four weeks.',
          ),
          StoryLine(
            'Ohne Praktikum konnte sie ihr Studium nicht abschließen.',
            'Without an internship she could not finish her degree.',
          ),
          StoryLine(
            'Sie setzte sich hin und las ihre Bewerbung noch einmal durch.',
            'She sat down and read her application through again.',
          ),
          StoryLine(
            'Zum ersten Mal fiel ihr auf, dass sie in jedem Anschreiben dasselbe geschrieben hatte.',
            'For the first time she noticed that she had written the same thing in every cover letter.',
          ),
          StoryLine(
            'Vielleicht lag das Problem nicht nur an den Firmen.',
            'Perhaps the problem was not only with the companies.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('die Absage', 'rejection'),
          StoryGloss('mitteilen', 'to inform'),
          StoryGloss('abschließen', 'to complete / finish'),
          StoryGloss('das Anschreiben', 'cover letter'),
          StoryGloss(
            'auffallen',
            'to notice / stand out',
            'Dative: es fiel ihr auf.',
          ),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wie viele Absagen hatte Nour bekommen?',
            options: <String>['Sieben', 'Vier', 'Zwei'],
            correctIndex: 0,
            explanation: '„Es war die siebte Absage in vier Wochen.“',
          ),
          ChoiceQuestion(
            prompt: 'Was erkennt sie am Ende des Kapitels?',
            options: <String>[
              'Ihre Anschreiben waren alle gleich',
              'Die Firmen sind unfair',
              'Sie hat sich zu spät beworben',
            ],
            correctIndex: 0,
            explanation:
                '„… dass sie in jedem Anschreiben dasselbe geschrieben hatte.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-b1-01-c2',
        title: 'Ein anderer Versuch',
        titleEnglish: 'A different attempt',
        lines: <StoryLine>[
          StoryLine(
            'Statt wieder zwanzig Bewerbungen zu verschicken, wählte sie drei Firmen aus.',
            'Instead of sending twenty applications again, she selected three companies.',
          ),
          StoryLine(
            'Über jede las sie so viel, dass sie deren Projekte hätte erklären können.',
            'She read so much about each that she could have explained their projects.',
          ),
          StoryLine(
            'In ihrem Anschreiben nannte sie ein konkretes Problem, an dem die Firma arbeitete.',
            'In her cover letter she named a concrete problem the company was working on.',
          ),
          StoryLine(
            'Dann schrieb sie, was sie im Studium dazu gemacht hatte.',
            'Then she wrote what she had done on that in her studies.',
          ),
          StoryLine(
            'Es fühlte sich riskanter an, weil sie viel mehr Zeit in weniger Bewerbungen steckte.',
            'It felt riskier, because she put much more time into fewer applications.',
          ),
          StoryLine(
            'Aber diesmal antwortete eine Firma bereits nach zwei Tagen.',
            'But this time a company replied after only two days.',
          ),
          StoryLine(
            'Sie wurde zu einem Gespräch eingeladen.',
            'She was invited to an interview.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('auswählen', 'to select'),
          StoryGloss('nennen', 'to name / mention'),
          StoryGloss('riskant', 'risky'),
          StoryGloss('stecken in', 'to put into'),
          StoryGloss('einladen zu', 'to invite to'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was hat Nour anders gemacht?',
            options: <String>[
              'Weniger, aber gründlichere Bewerbungen',
              'Noch mehr Bewerbungen',
              'Sie hat angerufen statt geschrieben',
            ],
            correctIndex: 0,
            explanation:
                '„Statt wieder zwanzig Bewerbungen zu verschicken, wählte sie drei Firmen aus.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie schnell kam die Antwort?',
            options: <String>[
              'Nach zwei Tagen',
              'Nach zwei Wochen',
              'Gar nicht',
            ],
            correctIndex: 0,
            explanation: '„… antwortete eine Firma bereits nach zwei Tagen.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-b1-01-c3',
        title: 'Die Frage am Ende',
        titleEnglish: 'The question at the end',
        lines: <StoryLine>[
          StoryLine(
            'Das Gespräch lief besser, als sie erwartet hatte.',
            'The interview went better than she had expected.',
          ),
          StoryLine(
            'Am Ende fragte der Abteilungsleiter: „Haben Sie noch Fragen an uns?“',
            'At the end the department head asked: "Do you have any questions for us?"',
          ),
          StoryLine(
            'Früher hätte Nour höflich verneint.',
            'In the past Nour would have politely said no.',
          ),
          StoryLine(
            'Diesmal fragte sie, warum die letzte Praktikantin nicht übernommen worden war.',
            'This time she asked why the last intern had not been kept on.',
          ),
          StoryLine(
            'Einen Moment lang war es still im Raum.',
            'For a moment the room was silent.',
          ),
          StoryLine(
            'Dann lachte er und sagte: „Das fragt sonst nie jemand.“',
            'Then he laughed and said: "Nobody else ever asks that."',
          ),
          StoryLine(
            'Zwei Tage später hatte sie den Platz.',
            'Two days later she had the position.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('erwarten', 'to expect'),
          StoryGloss('verneinen', 'to say no / deny'),
          StoryGloss('übernehmen', 'to take on / keep on'),
          StoryGloss('still', 'silent'),
          StoryGloss('der Abteilungsleiter', 'head of department'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was fragte Nour am Ende?',
            options: <String>[
              'Warum die letzte Praktikantin nicht blieb',
              'Wie hoch das Gehalt ist',
              'Ob sie früher gehen darf',
            ],
            correctIndex: 0,
            explanation:
                '„… warum die letzte Praktikantin nicht übernommen worden war.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie reagierte der Abteilungsleiter?',
            options: <String>[
              'Er lachte und war beeindruckt',
              'Er war beleidigt',
              'Er antwortete nicht',
            ],
            correctIndex: 0,
            explanation:
                '„Dann lachte er und sagte: ‚Das fragt sonst nie jemand.‘“',
          ),
        ],
      ),
    ],
  ),
  Story(
    id: 'st-b1-02',
    level: CefrLevel.b1,
    emoji: '💬',
    title: 'Das Missverständnis',
    titleEnglish: 'The misunderstanding',
    blurb: 'One short email splits a team in two. Someone has to fix it.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-b1-02-c1',
        title: 'Vier Zeilen',
        titleEnglish: 'Four lines',
        lines: <StoryLine>[
          StoryLine(
            'Die E-Mail war vier Zeilen lang und hatte kein einziges freundliches Wort.',
            'The email was four lines long and did not contain a single friendly word.',
          ),
          StoryLine(
            '„Bitte bis Freitag korrigieren. So ist das nicht verwendbar.“',
            '"Please correct by Friday. It is not usable like this."',
          ),
          StoryLine(
            'Kerem las sie dreimal und wurde jedes Mal wütender.',
            'Kerem read it three times and got angrier each time.',
          ),
          StoryLine(
            'Er hatte drei Wochen an dem Bericht gearbeitet.',
            'He had worked on the report for three weeks.',
          ),
          StoryLine(
            'Am liebsten hätte er sofort geantwortet.',
            'He would have liked to reply immediately.',
          ),
          StoryLine(
            'Stattdessen schloss er den Laptop und ging spazieren.',
            'Instead he closed the laptop and went for a walk.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('die Zeile', 'line'),
          StoryGloss('verwendbar', 'usable'),
          StoryGloss('wütend', 'angry'),
          StoryGloss('stattdessen', 'instead'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Warum war Kerem wütend?',
            options: <String>[
              'Die E-Mail war knapp und unfreundlich',
              'Er hatte den Bericht vergessen',
              'Er wurde nicht bezahlt',
            ],
            correctIndex: 0,
            explanation: 'Die E-Mail „hatte kein einziges freundliches Wort“.',
          ),
          ChoiceQuestion(
            prompt: 'Was machte er statt zu antworten?',
            options: <String>[
              'Er ging spazieren',
              'Er rief den Chef an',
              'Er löschte den Bericht',
            ],
            correctIndex: 0,
            explanation:
                '„Stattdessen schloss er den Laptop und ging spazieren.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-b1-02-c2',
        title: 'Die andere Seite',
        titleEnglish: 'The other side',
        lines: <StoryLine>[
          StoryLine(
            'Am nächsten Tag traf er Sabine, die die E-Mail geschrieben hatte, in der Küche.',
            'The next day he met Sabine, who had written the email, in the kitchen.',
          ),
          StoryLine(
            'Er wollte gerade etwas Scharfes sagen, aber sie sah müde aus.',
            'He was about to say something sharp, but she looked tired.',
          ),
          StoryLine(
            '„Entschuldige die kurze Mail“, sagte sie von selbst.',
            '"Sorry about the short email," she said of her own accord.',
          ),
          StoryLine(
            '„Ich habe sie zwischen zwei Terminen im Zug geschrieben.“',
            '"I wrote it on the train between two meetings."',
          ),
          StoryLine(
            'Dann erklärte sie, was genau der Kunde verlangt hatte.',
            'Then she explained exactly what the client had demanded.',
          ),
          StoryLine(
            'Plötzlich war klar: Es ging gar nicht um die Qualität seiner Arbeit.',
            'Suddenly it was clear: it was not about the quality of his work at all.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('scharf', 'sharp'),
          StoryGloss('von selbst', 'of one\'s own accord'),
          StoryGloss('verlangen', 'to demand'),
          StoryGloss('es geht um', 'it is about'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Warum war die E-Mail so kurz?',
            options: <String>[
              'Sabine schrieb sie im Zug zwischen Terminen',
              'Sie war wütend',
              'Sie hatte keine Zeit für ihn',
            ],
            correctIndex: 0,
            explanation:
                '„Ich habe sie zwischen zwei Terminen im Zug geschrieben.“',
          ),
          ChoiceQuestion(
            prompt: 'Worum ging es wirklich?',
            options: <String>[
              'Um die Anforderungen des Kunden',
              'Um Kerems Fehler',
              'Um das Gehalt',
            ],
            correctIndex: 0,
            explanation: '„Es ging gar nicht um die Qualität seiner Arbeit.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-b1-02-c3',
        title: 'Eine neue Regel',
        titleEnglish: 'A new rule',
        lines: <StoryLine>[
          StoryLine(
            'In der nächsten Teamsitzung schlug Kerem etwas vor.',
            'In the next team meeting Kerem proposed something.',
          ),
          StoryLine(
            '„Wenn eine Mail Kritik enthält, schreiben wir dazu, warum.“',
            '"If an email contains criticism, we write down why."',
          ),
          StoryLine(
            'Einige fanden das übertrieben, andere waren sofort einverstanden.',
            'Some found that excessive, others agreed immediately.',
          ),
          StoryLine(
            'Sabine sagte, sie hätte sich selbst gewünscht, dass jemand das früher vorgeschlagen hätte.',
            'Sabine said she herself would have wished that someone had proposed it earlier.',
          ),
          StoryLine(
            'Seitdem sind die Mails im Team etwas länger geworden.',
            'Since then the emails in the team have become a little longer.',
          ),
          StoryLine(
            'Streit gibt es trotzdem — aber selten wegen vier Zeilen.',
            'There are still arguments — but rarely because of four lines.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('vorschlagen', 'to propose'),
          StoryGloss('enthalten', 'to contain'),
          StoryGloss('übertrieben', 'excessive'),
          StoryGloss('der Streit', 'argument / dispute'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was schlug Kerem vor?',
            options: <String>[
              'Kritik immer zu begründen',
              'Keine E-Mails mehr zu schreiben',
              'Nur noch zu telefonieren',
            ],
            correctIndex: 0,
            explanation:
                '„Wenn eine Mail Kritik enthält, schreiben wir dazu, warum.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie reagierte das Team?',
            options: <String>[
              'Geteilt: manche dafür, manche dagegen',
              'Alle waren begeistert',
              'Alle lehnten ab',
            ],
            correctIndex: 0,
            explanation:
                '„Einige fanden das übertrieben, andere waren sofort einverstanden.“',
          ),
        ],
      ),
    ],
  ),
];

const List<Story> _b2Stories = <Story>[
  Story(
    id: 'st-b2-01',
    level: CefrLevel.b2,
    emoji: '⚙️',
    title: 'Ein Fehler in der Anlage',
    titleEnglish: 'A fault in the plant',
    blurb: 'A young engineer sees a number nobody else finds worrying.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-b2-01-c1',
        title: 'Die Abweichung',
        titleEnglish: 'The deviation',
        lines: <StoryLine>[
          StoryLine(
            'Die Abweichung betrug lediglich zwei Prozent und lag damit innerhalb der Toleranz.',
            'The deviation was merely two percent and therefore lay within tolerance.',
          ),
          StoryLine(
            'Trotzdem tauchte sie inzwischen in jeder zweiten Schicht auf.',
            'Nevertheless it now appeared in every second shift.',
          ),
          StoryLine(
            'Milena verglich die Kurven der letzten drei Monate und stellte fest, dass der Trend eindeutig war.',
            'Milena compared the curves of the last three months and found that the trend was unambiguous.',
          ),
          StoryLine(
            'Was einzeln unauffällig wirkte, ergab in der Reihe ein Muster.',
            'What looked inconspicuous individually formed a pattern in sequence.',
          ),
          StoryLine(
            'Ihr Vorgesetzter winkte ab: „Solange wir in der Spezifikation liegen, ist das kein Thema.“',
            'Her supervisor waved it away: "As long as we are within specification, it is not an issue."',
          ),
          StoryLine(
            'Formal hatte er recht, und genau das machte die Sache schwierig.',
            'Formally he was right, and that was exactly what made the matter difficult.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('die Abweichung', 'deviation'),
          StoryGloss('auftauchen', 'to appear / show up'),
          StoryGloss('unauffällig', 'inconspicuous'),
          StoryGloss('abwinken', 'to wave away / dismiss'),
          StoryGloss('die Spezifikation', 'specification'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Warum war die Abweichung offiziell kein Problem?',
            options: <String>[
              'Sie lag innerhalb der Toleranz',
              'Sie trat nur einmal auf',
              'Niemand hatte sie gemessen',
            ],
            correctIndex: 0,
            explanation: '„… lag damit innerhalb der Toleranz.“',
          ),
          ChoiceQuestion(
            prompt: 'Was war das eigentlich Beunruhigende?',
            options: <String>[
              'Der wiederkehrende Trend',
              'Die Höhe der Abweichung',
              'Der Ausfall einer Pumpe',
            ],
            correctIndex: 0,
            explanation:
                '„Was einzeln unauffällig wirkte, ergab in der Reihe ein Muster.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-b2-01-c2',
        title: 'Ein Bericht ohne Auftrag',
        titleEnglish: 'A report nobody asked for',
        lines: <StoryLine>[
          StoryLine(
            'Milena schrieb den Bericht an einem Wochenende, ohne dass jemand sie darum gebeten hätte.',
            'Milena wrote the report over a weekend without anyone having asked her to.',
          ),
          StoryLine(
            'Sie verzichtete bewusst auf jede Dramatisierung und beschränkte sich auf die Daten.',
            'She deliberately avoided any dramatisation and confined herself to the data.',
          ),
          StoryLine(
            'Statt eine Ursache zu behaupten, listete sie drei mögliche Erklärungen auf.',
            'Instead of asserting a cause, she listed three possible explanations.',
          ),
          StoryLine(
            'Für jede Erklärung schlug sie einen Test vor, der wenig kostete.',
            'For each explanation she proposed a test that cost little.',
          ),
          StoryLine(
            'Dann schickte sie das Dokument an ihren Vorgesetzten — und in Kopie an niemanden sonst.',
            'Then she sent the document to her supervisor — with a copy to nobody else.',
          ),
          StoryLine(
            'Diese Zurückhaltung sollte sich später als entscheidend erweisen.',
            'This restraint would later prove decisive.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('verzichten auf', 'to do without'),
          StoryGloss('sich beschränken auf', 'to confine oneself to'),
          StoryGloss('behaupten', 'to assert'),
          StoryGloss('die Zurückhaltung', 'restraint'),
          StoryGloss('sich erweisen als', 'to prove to be'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wie war der Bericht aufgebaut?',
            options: <String>[
              'Daten, drei Hypothesen, günstige Tests',
              'Eine klare Schuldzuweisung',
              'Eine Warnung an die Geschäftsführung',
            ],
            correctIndex: 0,
            explanation:
                '„… listete sie drei mögliche Erklärungen auf … schlug sie einen Test vor.“',
          ),
          ChoiceQuestion(
            prompt: 'Was tat sie bewusst nicht?',
            options: <String>[
              'Andere in Kopie setzen',
              'Die Daten prüfen',
              'Ihren Vorgesetzten informieren',
            ],
            correctIndex: 0,
            explanation: '„… und in Kopie an niemanden sonst.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-b2-01-c3',
        title: 'Der stille Umbau',
        titleEnglish: 'The quiet rebuild',
        lines: <StoryLine>[
          StoryLine(
            'Ihr Vorgesetzter meldete sich erst nach elf Tagen, dafür mit einem Termin.',
            'Her supervisor got back to her only after eleven days, but with a meeting.',
          ),
          StoryLine(
            'Der zweite Test bestätigte eine der drei Hypothesen: ein Ventil schloss zunehmend träge.',
            'The second test confirmed one of the three hypotheses: a valve was closing increasingly sluggishly.',
          ),
          StoryLine(
            'Bis zum Ausfall hätte es vermutlich noch Monate gedauert, aber der Ausfall wäre teuer geworden.',
            'It would probably have taken months until failure, but the failure would have been expensive.',
          ),
          StoryLine(
            'In der Auswertung erwähnte niemand, dass Milena den Hinweis gegeben hatte.',
            'In the evaluation nobody mentioned that Milena had given the tip.',
          ),
          StoryLine(
            'Ihr Vorgesetzter jedoch fragte sie ab da bei jeder Unregelmäßigkeit als Erste.',
            'Her supervisor, however, from then on asked her first at every irregularity.',
          ),
          StoryLine(
            'Manche Anerkennung steht nicht im Protokoll.',
            'Some recognition does not appear in the minutes.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('bestätigen', 'to confirm'),
          StoryGloss('träge', 'sluggish'),
          StoryGloss('der Ausfall', 'failure / outage'),
          StoryGloss('die Unregelmäßigkeit', 'irregularity'),
          StoryGloss('die Anerkennung', 'recognition'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was war die Ursache?',
            options: <String>[
              'Ein zunehmend träges Ventil',
              'Ein Messfehler',
              'Eine defekte Pumpe',
            ],
            correctIndex: 0,
            explanation: '„… ein Ventil schloss zunehmend träge.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie endet die Geschichte für Milena?',
            options: <String>[
              'Ohne offizielle, aber mit faktischer Anerkennung',
              'Mit einer Beförderung',
              'Mit einer Abmahnung',
            ],
            correctIndex: 0,
            explanation: '„Manche Anerkennung steht nicht im Protokoll.“',
          ),
        ],
      ),
    ],
  ),
];

const List<Story> _b2ExtraStories = <Story>[
  Story(
    id: 'st-b2-02',
    level: CefrLevel.b2,
    emoji: '🎻',
    title: 'Die Entscheidung',
    titleEnglish: 'The decision',
    blurb:
        'At thirty-eight, Tobias gives up a secure job for an uncertain one.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-b2-02-c1',
        title: 'Der sichere Weg',
        titleEnglish: 'The safe path',
        lines: <StoryLine>[
          StoryLine(
            'Von außen betrachtet gab es keinen einzigen Grund zu kündigen.',
            'Viewed from outside there was not a single reason to resign.',
          ),
          StoryLine(
            'Unbefristeter Vertrag, verlässliches Gehalt, ein Team, das ihn schätzte.',
            'Permanent contract, reliable salary, a team that valued him.',
          ),
          StoryLine(
            'Und dennoch stellte Tobias seit zwei Jahren morgens dieselbe Frage.',
            'And yet for two years Tobias had been asking himself the same question every morning.',
          ),
          StoryLine(
            'Nicht, ob die Arbeit schlecht war — sondern ob sie noch zu ihm gehörte.',
            'Not whether the work was bad — but whether it still belonged to him.',
          ),
          StoryLine(
            'Freunde rieten ihm, dankbar zu sein, und sie hatten nicht unrecht.',
            'Friends advised him to be grateful, and they were not wrong.',
          ),
          StoryLine(
            'Dankbarkeit und Zufriedenheit sind allerdings nicht dasselbe.',
            'Gratitude and contentment are, however, not the same thing.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('kündigen', 'to resign / give notice'),
          StoryGloss('unbefristet', 'permanent (contract)'),
          StoryGloss('schätzen', 'to value'),
          StoryGloss('die Zufriedenheit', 'contentment'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was war Tobias\' eigentliches Problem?',
            options: <String>[
              'Die Arbeit passte nicht mehr zu ihm',
              'Das Gehalt war zu niedrig',
              'Konflikte im Team',
            ],
            correctIndex: 0,
            explanation: '„… sondern ob sie noch zu ihm gehörte.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie bewertet der Text den Rat der Freunde?',
            options: <String>[
              'Nachvollziehbar, aber unzureichend',
              'Vollkommen falsch',
              'Böswillig',
            ],
            correctIndex: 0,
            explanation:
                '„… und sie hatten nicht unrecht. Dankbarkeit und Zufriedenheit sind allerdings nicht dasselbe.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-b2-02-c2',
        title: 'Zwölf Monate',
        titleEnglish: 'Twelve months',
        lines: <StoryLine>[
          StoryLine(
            'Statt spontan zu kündigen, gab er sich ein Jahr und ein Budget.',
            'Instead of resigning spontaneously, he gave himself a year and a budget.',
          ),
          StoryLine(
            'Abends unterrichtete er Musik, zunächst zwei Schüler, später neun.',
            'In the evenings he taught music, at first two pupils, later nine.',
          ),
          StoryLine(
            'Erst als der Nebenverdienst die Miete deckte, sprach er mit seiner Chefin.',
            'Only when the side income covered the rent did he speak to his boss.',
          ),
          StoryLine(
            'Sie reagierte gelassener, als er befürchtet hatte, und bot ihm eine Teilzeitstelle an.',
            'She reacted more calmly than he had feared and offered him a part-time position.',
          ),
          StoryLine(
            'Damit war das Risiko halbiert, ohne dass die Entscheidung verwässert wurde.',
            'That halved the risk without watering down the decision.',
          ),
          StoryLine(
            'Rückblickend war nicht der Mut entscheidend, sondern die Vorbereitung.',
            'In retrospect it was not the courage that mattered, but the preparation.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('der Nebenverdienst', 'side income'),
          StoryGloss('decken', 'to cover'),
          StoryGloss('gelassen', 'calm / composed'),
          StoryGloss('verwässern', 'to water down'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wann sprach er mit seiner Chefin?',
            options: <String>[
              'Als der Nebenverdienst die Miete deckte',
              'Sofort',
              'Nach der Kündigung',
            ],
            correctIndex: 0,
            explanation: '„Erst als der Nebenverdienst die Miete deckte …“',
          ),
          ChoiceQuestion(
            prompt: 'Was war laut Text entscheidend?',
            options: <String>['Die Vorbereitung', 'Der Mut', 'Das Glück'],
            correctIndex: 0,
            explanation:
                '„… nicht der Mut entscheidend, sondern die Vorbereitung.“',
          ),
        ],
      ),
    ],
  ),
];

const List<Story> _c1Stories = <Story>[
  Story(
    id: 'st-c1-01',
    level: CefrLevel.c1,
    emoji: '🔬',
    title: 'Der Zwischenbericht',
    titleEnglish: 'The interim report',
    blurb:
        'A promising result does not survive a second look. The deadline does not care.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-c1-01-c1',
        title: 'Ein zu schönes Ergebnis',
        titleEnglish: 'A result too good to be true',
        lines: <StoryLine>[
          StoryLine(
            'Der Effekt war so deutlich, dass Hanna ihn zunächst für einen Fehler hielt.',
            'The effect was so clear that Hanna initially took it for an error.',
          ),
          StoryLine(
            'Drei Wochen vor Abgabe des Zwischenberichts hätte sie ihn schlicht berichten können.',
            'Three weeks before the interim report was due she could simply have reported it.',
          ),
          StoryLine(
            'Niemand hätte nachgefragt, zumal die Förderlinie auf genau solche Befunde ausgerichtet war.',
            'Nobody would have asked, especially as the funding line was geared precisely to such findings.',
          ),
          StoryLine(
            'Gerade das machte sie misstrauisch: Ergebnisse, die perfekt in die Erwartung passen, verdienen die härteste Prüfung.',
            'Precisely that made her suspicious: results that fit expectations perfectly deserve the hardest scrutiny.',
          ),
          StoryLine(
            'Sie zog die Rohdaten heran und rekonstruierte die Auswertung von Grund auf.',
            'She pulled up the raw data and reconstructed the analysis from scratch.',
          ),
          StoryLine(
            'Nach elf Stunden fand sie den Punkt, an dem eine Filterbedingung zweimal angewendet worden war.',
            'After eleven hours she found the point at which a filter condition had been applied twice.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('die Abgabe', 'submission / deadline'),
          StoryGloss('zumal', 'especially as'),
          StoryGloss('ausgerichtet auf', 'geared towards'),
          StoryGloss('misstrauisch', 'suspicious'),
          StoryGloss('heranziehen', 'to consult / draw on'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Warum wurde Hanna misstrauisch?',
            options: <String>[
              'Das Ergebnis passte zu perfekt in die Erwartung',
              'Die Daten waren unvollständig',
              'Ein Kollege hatte gewarnt',
            ],
            correctIndex: 0,
            explanation:
                '„Ergebnisse, die perfekt in die Erwartung passen, verdienen die härteste Prüfung.“',
          ),
          ChoiceQuestion(
            prompt: 'Worin bestand der Fehler?',
            options: <String>[
              'Eine Filterbedingung wurde doppelt angewendet',
              'Die Stichprobe war zu klein',
              'Ein Messgerät war defekt',
            ],
            correctIndex: 0,
            explanation:
                '„… an dem eine Filterbedingung zweimal angewendet worden war.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-c1-01-c2',
        title: 'Was man nicht schreiben muss',
        titleEnglish: 'What one is not obliged to write',
        lines: <StoryLine>[
          StoryLine(
            'Der bereinigte Effekt war noch vorhanden, aber unspektakulär.',
            'The corrected effect was still present, but unspectacular.',
          ),
          StoryLine(
            'Ihr Projektleiter schlug vor, die ursprüngliche Auswertung „als explorative Variante“ zusätzlich aufzuführen.',
            'Her project leader suggested additionally listing the original analysis "as an exploratory variant".',
          ),
          StoryLine(
            'Formal wäre das nicht falsch gewesen; irreführend wäre es allemal gewesen.',
            'Formally that would not have been wrong; misleading it would certainly have been.',
          ),
          StoryLine(
            'Hanna argumentierte nicht moralisch, sondern methodisch, was die Diskussion sofort veränderte.',
            'Hanna argued not morally but methodologically, which changed the discussion immediately.',
          ),
          StoryLine(
            'Eine Variante, deren Fehler man kenne, sei keine Variante, sondern ein Fehler.',
            'A variant whose error one knows is not a variant, she said, but an error.',
          ),
          StoryLine(
            'Nach zwanzig Minuten strich er den Absatz selbst.',
            'After twenty minutes he deleted the paragraph himself.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('bereinigt', 'corrected / adjusted'),
          StoryGloss('aufführen', 'to list'),
          StoryGloss('irreführend', 'misleading'),
          StoryGloss('allemal', 'certainly / in any case'),
          StoryGloss('streichen', 'to delete / strike out'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wie argumentierte Hanna?',
            options: <String>[
              'Methodisch statt moralisch',
              'Emotional',
              'Mit Verweis auf Vorschriften',
            ],
            correctIndex: 0,
            explanation: '„… nicht moralisch, sondern methodisch.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie endete die Diskussion?',
            options: <String>[
              'Der Projektleiter strich den Absatz selbst',
              'Sie eskalierte zur Leitung',
              'Hanna gab nach',
            ],
            correctIndex: 0,
            explanation: '„Nach zwanzig Minuten strich er den Absatz selbst.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-c1-01-c3',
        title: 'Die Fußnote',
        titleEnglish: 'The footnote',
        lines: <StoryLine>[
          StoryLine(
            'Der Bericht ging pünktlich raus, mit einem unauffälligen Ergebnis und einer sehr auffälligen Fußnote.',
            'The report went out on time, with an inconspicuous result and a very conspicuous footnote.',
          ),
          StoryLine(
            'Darin war der ursprüngliche Fehler offen beschrieben, einschließlich der Korrektur.',
            'In it the original error was openly described, including the correction.',
          ),
          StoryLine(
            'Zwei Gutachter kritisierten den schwachen Effekt, ein dritter hob ausdrücklich die Transparenz hervor.',
            'Two reviewers criticised the weak effect, a third explicitly highlighted the transparency.',
          ),
          StoryLine(
            'Im Folgejahr wurde das Projekt verlängert, allerdings mit einem geänderten Design.',
            'The following year the project was extended, though with a modified design.',
          ),
          StoryLine(
            'Hanna wurde später gefragt, ob sich die elf Stunden gelohnt hätten.',
            'Hanna was later asked whether the eleven hours had been worth it.',
          ),
          StoryLine(
            'Ihre Antwort war unspektakulär: Man wisse nie, welche Arbeit einen Schaden verhindert habe.',
            'Her answer was unspectacular: one never knows which piece of work prevented a damage.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('der Gutachter', 'reviewer / assessor'),
          StoryGloss('hervorheben', 'to highlight'),
          StoryGloss('verlängern', 'to extend'),
          StoryGloss('sich lohnen', 'to be worth it'),
          StoryGloss('der Schaden', 'damage'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was enthielt die Fußnote?',
            options: <String>[
              'Die offene Beschreibung des Fehlers',
              'Eine Danksagung',
              'Die Rohdaten',
            ],
            correctIndex: 0,
            explanation:
                '„Darin war der ursprüngliche Fehler offen beschrieben.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie fielen die Gutachten aus?',
            options: <String>[
              'Uneinheitlich',
              'Einstimmig positiv',
              'Einstimmig negativ',
            ],
            correctIndex: 0,
            explanation:
                'Zwei kritisierten, ein dritter hob die Transparenz hervor.',
          ),
        ],
      ),
    ],
  ),
  Story(
    id: 'st-c1-02',
    level: CefrLevel.c1,
    emoji: '🏚️',
    title: 'Die Rückkehr',
    titleEnglish: 'The return',
    blurb:
        'After nineteen years abroad, a village looks smaller than memory allowed.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-c1-02-c1',
        title: 'Kleiner als erinnert',
        titleEnglish: 'Smaller than remembered',
        lines: <StoryLine>[
          StoryLine(
            'Nichts war so verändert, wie er befürchtet hatte, und gerade das irritierte ihn.',
            'Nothing had changed as much as he had feared, and precisely that unsettled him.',
          ),
          StoryLine(
            'Die Straße, die in seiner Erinnerung eine Allee gewesen war, maß knapp vierzig Meter.',
            'The street which in his memory had been an avenue measured barely forty metres.',
          ),
          StoryLine(
            'Erinnerung, dachte Ilja, ist offenbar weniger ein Archiv als eine fortlaufende Übersetzung.',
            'Memory, Ilja thought, is apparently less an archive than an ongoing translation.',
          ),
          StoryLine(
            'Im Laden erkannte ihn niemand, obwohl er hier vier Jahre lang jeden Tag eingekauft hatte.',
            'In the shop nobody recognised him, although he had shopped here every day for four years.',
          ),
          StoryLine(
            'Erst als er den Nachnamen seiner Mutter nannte, veränderte sich das Gesicht der Verkäuferin.',
            'Only when he mentioned his mother\'s surname did the shop assistant\'s face change.',
          ),
          StoryLine(
            '„Ach, Sie sind der Junge, der weggegangen ist“, sagte sie, ohne dass ein Vorwurf darin lag.',
            '"Ah, you are the boy who left," she said, without any reproach in it.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('irritieren', 'to unsettle / confuse'),
          StoryGloss('die Allee', 'avenue'),
          StoryGloss('fortlaufend', 'ongoing'),
          StoryGloss('der Vorwurf', 'reproach'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was irritierte Ilja?',
            options: <String>[
              'Dass sich so wenig verändert hatte',
              'Der Verfall des Dorfes',
              'Die feindliche Stimmung',
            ],
            correctIndex: 0,
            explanation:
                '„Nichts war so verändert, wie er befürchtet hatte, und gerade das irritierte ihn.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie beschreibt der Text Erinnerung?',
            options: <String>[
              'Als fortlaufende Übersetzung',
              'Als verlässliches Archiv',
              'Als Illusion',
            ],
            correctIndex: 0,
            explanation:
                '„… weniger ein Archiv als eine fortlaufende Übersetzung.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-c1-02-c2',
        title: 'Das Haus',
        titleEnglish: 'The house',
        lines: <StoryLine>[
          StoryLine(
            'Das Elternhaus stand leer, seit seine Mutter ins Heim gezogen war.',
            'The family home had stood empty since his mother moved into a care home.',
          ),
          StoryLine(
            'Verkaufen wäre vernünftig gewesen; halten war es nicht, aber es war ehrlicher.',
            'Selling would have been sensible; keeping it was not, but it was more honest.',
          ),
          StoryLine(
            'In der Küche fand er eine Liste, auf der seine Mutter Wörter notiert hatte, die sie zu vergessen begann.',
            'In the kitchen he found a list on which his mother had noted words she was beginning to forget.',
          ),
          StoryLine(
            'Sie war alphabetisch geordnet, was ihn mehr erschütterte als die Wörter selbst.',
            'It was ordered alphabetically, which shook him more than the words themselves.',
          ),
          StoryLine(
            'Er beschloss, ein Jahr zu bleiben, ohne sich zu erklären, warum.',
            'He decided to stay for a year, without explaining to himself why.',
          ),
          StoryLine(
            'Manche Entscheidungen begründet man erst rückblickend, und einige nie.',
            'Some decisions one justifies only in retrospect, and some never.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('das Elternhaus', 'family home'),
          StoryGloss('vernünftig', 'sensible'),
          StoryGloss('erschüttern', 'to shake / shock'),
          StoryGloss('rückblickend', 'in retrospect'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was fand er in der Küche?',
            options: <String>[
              'Eine Wortliste seiner Mutter',
              'Alte Fotos',
              'Einen Brief',
            ],
            correctIndex: 0,
            explanation:
                '„… eine Liste, auf der seine Mutter Wörter notiert hatte.“',
          ),
          ChoiceQuestion(
            prompt: 'Was erschütterte ihn besonders?',
            options: <String>[
              'Die alphabetische Ordnung',
              'Die Zahl der Wörter',
              'Die Handschrift',
            ],
            correctIndex: 0,
            explanation:
                '„Sie war alphabetisch geordnet, was ihn mehr erschütterte als die Wörter selbst.“',
          ),
        ],
      ),
    ],
  ),
];

const List<Story> _c2Stories = <Story>[
  Story(
    id: 'st-c2-01',
    level: CefrLevel.c2,
    emoji: '⚖️',
    title: 'Das Gutachten',
    titleEnglish: 'The expert opinion',
    blurb:
        'An expert is asked for certainty she does not have, by people who need it.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-c2-01-c1',
        title: 'Die Frage hinter der Frage',
        titleEnglish: 'The question behind the question',
        lines: <StoryLine>[
          StoryLine(
            'Was von ihr verlangt wurde, war nicht eigentlich ein Gutachten, sondern eine Entlastung.',
            'What was demanded of her was not really an expert opinion, but an exoneration.',
          ),
          StoryLine(
            'Der Auftrag war so formuliert, dass jede vorsichtige Antwort bereits als Zustimmung gelesen werden konnte.',
            'The commission was worded so that any cautious answer could already be read as consent.',
          ),
          StoryLine(
            'Hätte sie lediglich die gestellte Frage beantwortet, wäre ihr sachlich nichts vorzuwerfen gewesen.',
            'Had she merely answered the question posed, nothing could have been held against her substantively.',
          ),
          StoryLine(
            'Genau darin bestand die Konstruktion: Man wollte eine korrekte Antwort auf eine schief gestellte Frage.',
            'That was precisely the construction: they wanted a correct answer to a crookedly posed question.',
          ),
          StoryLine(
            'Sie beschloss daher, das Gutachten mit einer Umformulierung der Fragestellung zu eröffnen.',
            'She therefore decided to open the opinion by reformulating the question.',
          ),
          StoryLine(
            'Nichts an diesem Verfahren war unüblich; unüblich war lediglich, es sichtbar zu machen.',
            'Nothing about this procedure was unusual; what was unusual was only making it visible.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('die Entlastung', 'exoneration'),
          StoryGloss('vorwerfen', 'to reproach / hold against'),
          StoryGloss('schief', 'skewed / crooked'),
          StoryGloss('die Fragestellung', 'formulation of the question'),
          StoryGloss('unüblich', 'unusual'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was war der eigentliche Zweck des Auftrags?',
            options: <String>[
              'Eine Entlastung zu erhalten',
              'Eine offene Untersuchung',
              'Eine Kostenschätzung',
            ],
            correctIndex: 0,
            explanation:
                '„… nicht eigentlich ein Gutachten, sondern eine Entlastung.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie reagierte sie darauf?',
            options: <String>[
              'Sie formulierte die Fragestellung um',
              'Sie lehnte den Auftrag ab',
              'Sie antwortete wörtlich',
            ],
            correctIndex: 0,
            explanation:
                '„… das Gutachten mit einer Umformulierung der Fragestellung zu eröffnen.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-c2-01-c2',
        title: 'Unsicherheit als Ergebnis',
        titleEnglish: 'Uncertainty as a finding',
        lines: <StoryLine>[
          StoryLine(
            'Der Kern ihres Befundes ließ sich in einem Satz zusammenfassen, den niemand hören wollte.',
            'The core of her finding could be summarised in one sentence that nobody wanted to hear.',
          ),
          StoryLine(
            'Die verfügbare Datenlage erlaubte schlicht keine Aussage in der geforderten Schärfe.',
            'The available data simply permitted no statement with the required precision.',
          ),
          StoryLine(
            'Dass Unsicherheit selbst ein Ergebnis ist, gilt fachlich als selbstverständlich und praktisch als Zumutung.',
            'That uncertainty is itself a finding counts as self-evident professionally and as an imposition practically.',
          ),
          StoryLine(
            'In der Anhörung wurde sie dreimal gebeten, sich „festzulegen“, und dreimal erläuterte sie, weshalb das unseriös wäre.',
            'At the hearing she was asked three times to "commit", and three times she explained why that would be unprofessional.',
          ),
          StoryLine(
            'Ein Ausschussmitglied warf ihr vor, sich hinter Methodik zu verstecken.',
            'A committee member accused her of hiding behind methodology.',
          ),
          StoryLine(
            'Sie erwiderte, hinter Methodik verstecke sich niemand; man stehe darin, sichtbar für alle.',
            'She replied that nobody hides behind methodology; one stands in it, visible to everyone.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('der Befund', 'finding'),
          StoryGloss('die Datenlage', 'state of the data'),
          StoryGloss('die Zumutung', 'imposition / unreasonable demand'),
          StoryGloss('sich festlegen', 'to commit oneself'),
          StoryGloss('erwidern', 'to reply / retort'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was war ihr zentraler Befund?',
            options: <String>[
              'Die Datenlage erlaubte keine scharfe Aussage',
              'Der Vorwurf war unbegründet',
              'Der Schaden war gering',
            ],
            correctIndex: 0,
            explanation:
                '„… erlaubte schlicht keine Aussage in der geforderten Schärfe.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie kontert sie den Vorwurf, sie verstecke sich?',
            options: <String>[
              'Man stehe in der Methodik, sichtbar für alle',
              'Sie ignoriert ihn',
              'Sie entschuldigt sich',
            ],
            correctIndex: 0,
            explanation:
                '„… hinter Methodik verstecke sich niemand; man stehe darin.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-c2-01-c3',
        title: 'Nachher',
        titleEnglish: 'Afterwards',
        lines: <StoryLine>[
          StoryLine(
            'Zitiert wurde am Ende nur der eine Satz, der sich am leichtesten missverstehen ließ.',
            'In the end only the one sentence that was easiest to misunderstand was quoted.',
          ),
          StoryLine(
            'Dagegen ließ sich wenig unternehmen, und sie unternahm bewusst wenig.',
            'Little could be done about that, and she deliberately did little.',
          ),
          StoryLine(
            'Wer jede Verkürzung korrigiert, wird zum Kommentator seiner eigenen Arbeit.',
            'Whoever corrects every abbreviation becomes a commentator on their own work.',
          ),
          StoryLine(
            'Zwei Jahre später wurde das Verfahren geändert — mit einer Begründung, die ihrem Gutachten auffällig ähnelte.',
            'Two years later the procedure was changed — with a justification that resembled her opinion strikingly.',
          ),
          StoryLine(
            'Ihr Name kam darin nicht vor, ihre Argumentation jedoch nahezu wörtlich.',
            'Her name did not appear in it, her argument, however, almost verbatim.',
          ),
          StoryLine(
            'Sie hat das nie als Kränkung verstanden, sondern als das übliche Verfahren, in dem Sätze überleben und Namen nicht.',
            'She never understood this as an insult, but as the usual procedure in which sentences survive and names do not.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('die Verkürzung', 'abbreviation / oversimplification'),
          StoryGloss('unternehmen', 'to undertake / do about'),
          StoryGloss('ähneln', 'to resemble'),
          StoryGloss('die Kränkung', 'insult / slight'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Warum korrigierte sie die Verkürzungen nicht?',
            options: <String>[
              'Sonst würde sie zur Kommentatorin ihrer eigenen Arbeit',
              'Sie hatte keine Zeit',
              'Es war ihr verboten',
            ],
            correctIndex: 0,
            explanation:
                '„Wer jede Verkürzung korrigiert, wird zum Kommentator seiner eigenen Arbeit.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie deutet sie das spätere Verfahren?',
            options: <String>[
              'Als übliches Überleben von Argumenten ohne Namen',
              'Als Diebstahl',
              'Als Zufall',
            ],
            correctIndex: 0,
            explanation: '„… in dem Sätze überleben und Namen nicht.“',
          ),
        ],
      ),
    ],
  ),
  Story(
    id: 'st-c2-02',
    level: CefrLevel.c2,
    emoji: '📚',
    title: 'Die Archivarin',
    titleEnglish: 'The archivist',
    blurb:
        'A collection is complete. Completeness turns out to be the problem.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-c2-02-c1',
        title: 'Die Lücke',
        titleEnglish: 'The gap',
        lines: <StoryLine>[
          StoryLine(
            'Vollständigkeit gilt in Archiven als Ideal, obwohl sie streng genommen nie erreichbar ist.',
            'Completeness is regarded as an ideal in archives, although strictly speaking it is never attainable.',
          ),
          StoryLine(
            'Was aufbewahrt wurde, verdankt sich stets einer Reihe von Entscheidungen, die selbst selten dokumentiert sind.',
            'What was preserved is always owed to a series of decisions that are themselves rarely documented.',
          ),
          StoryLine(
            'Insofern ist ein Archiv weniger ein Abbild der Vergangenheit als ein Protokoll ihrer Bewertung.',
            'In that respect an archive is less an image of the past than a record of its evaluation.',
          ),
          StoryLine(
            'Frau Selter hatte diesen Satz zwanzig Jahre lang gesagt, ehe er ihr selbst unangenehm wurde.',
            'Ms Selter had said this sentence for twenty years before it became uncomfortable to her herself.',
          ),
          StoryLine(
            'Unangenehm wurde er, als sie in Kiste 41 einen Ordner fand, der laut Findbuch nicht existierte.',
            'It became uncomfortable when she found a folder in box 41 that, according to the finding aid, did not exist.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('die Vollständigkeit', 'completeness'),
          StoryGloss('aufbewahren', 'to preserve / keep'),
          StoryGloss('sich verdanken', 'to be owed to'),
          StoryGloss('das Findbuch', 'finding aid / archive index'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wie charakterisiert der Text ein Archiv?',
            options: <String>[
              'Als Protokoll der Bewertung von Vergangenheit',
              'Als objektives Abbild',
              'Als zufällige Sammlung',
            ],
            correctIndex: 0,
            explanation:
                '„… weniger ein Abbild der Vergangenheit als ein Protokoll ihrer Bewertung.“',
          ),
          ChoiceQuestion(
            prompt: 'Was fand Frau Selter?',
            options: <String>[
              'Einen im Findbuch nicht verzeichneten Ordner',
              'Eine leere Kiste',
              'Eine Fälschung',
            ],
            correctIndex: 0,
            explanation:
                '„… einen Ordner fand, der laut Findbuch nicht existierte.“',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-c2-02-c2',
        title: 'Verzeichnen oder nicht',
        titleEnglish: 'To record or not',
        lines: <StoryLine>[
          StoryLine(
            'Der Ordner enthielt nichts Skandalöses, sondern etwas weit Unbequemeres: Belanglosigkeiten.',
            'The folder contained nothing scandalous, but something far more inconvenient: trivialities.',
          ),
          StoryLine(
            'Er dokumentierte, wie beiläufig damals über Aufnahme und Ausschluss entschieden worden war.',
            'It documented how casually decisions on inclusion and exclusion had been made back then.',
          ),
          StoryLine(
            'Hätte sie ihn stillschweigend eingeordnet, wäre der Bestand formal korrekt und faktisch geschönt gewesen.',
            'Had she filed it silently, the holdings would have been formally correct and factually embellished.',
          ),
          StoryLine(
            'Sie entschied sich, den Fund samt Kommentar zu verzeichnen, und rechnete mit Widerspruch.',
            'She decided to record the find together with a commentary, and reckoned with objection.',
          ),
          StoryLine(
            'Der Widerspruch kam, allerdings leiser und höflicher, als sie erwartet hatte.',
            'The objection came, though quieter and more polite than she had expected.',
          ),
          StoryLine(
            'Am Ende überlebte der Kommentar, weil niemand eine Begründung für seine Streichung formulieren mochte.',
            'In the end the commentary survived because nobody cared to formulate a justification for deleting it.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('die Belanglosigkeit', 'triviality'),
          StoryGloss('beiläufig', 'casually / in passing'),
          StoryGloss('stillschweigend', 'tacitly'),
          StoryGloss('geschönt', 'embellished / whitewashed'),
          StoryGloss('verzeichnen', 'to record / catalogue'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Warum war der Inhalt unbequem?',
            options: <String>[
              'Er zeigte, wie beiläufig entschieden wurde',
              'Er enthielt einen Skandal',
              'Er war unleserlich',
            ],
            correctIndex: 0,
            explanation:
                '„… wie beiläufig damals über Aufnahme und Ausschluss entschieden worden war.“',
          ),
          ChoiceQuestion(
            prompt: 'Warum überlebte der Kommentar?',
            options: <String>[
              'Niemand wollte eine Streichung begründen',
              'Die Leitung unterstützte ihn',
              'Er wurde übersehen',
            ],
            correctIndex: 0,
            explanation:
                '„… weil niemand eine Begründung für seine Streichung formulieren mochte.“',
          ),
        ],
      ),
    ],
  ),
];

final List<Story> stories = <Story>[
  ..._a1Stories,
  ..._a2Stories,
  ..._b1Stories,
  ..._b2Stories,
  ..._b2ExtraStories,
  ..._c1Stories,
  ..._c2Stories,
  ...extraStories,
  // Written as scenes rather than narration. See lib/stories_ensemble.dart.
  ...ensembleStories,
  ...expandedStories,
];

/// Every chapter in every bundled story.
///
/// Derived rather than written down: the completionist achievement targets
/// this, and a hardcoded number silently stops meaning "all of them" the
/// moment a story is added.
int get totalStoryChapters =>
    stories.fold<int>(0, (int total, Story s) => total + s.chapters.length);

List<Story> storiesFor(CefrLevel level) =>
    stories.where((story) => story.level == level).toList(growable: false);

Story? storyById(String id) {
  for (final Story story in stories) {
    if (story.id == id) return story;
  }
  return null;
}

/// Every chapter across every story, used for progress accounting.
List<StoryChapter> get allStoryChapters =>
    stories.expand((story) => story.chapters).toList(growable: false);
