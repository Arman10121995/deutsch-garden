import 'models.dart';
import 'radio.dart';
import 'radio_a1.dart';
import 'radio_a2.dart';
import 'radio_b1.dart';
import 'radio_c.dart';

/// The Gartenradio script library.
///
/// Every episode is original text written for this app. Nothing here is
/// adapted from Deutsche Welle, Easy German, Goethe-Institut or any podcast:
/// all of those are all-rights-reserved, and reusing them would end the MIT
/// licence. See docs/UPGRADE_PLAN.md.
///
/// A1 and A2 episodes carry an English line beside every German line. From B1
/// the English is still stored but hidden by default, so the learner meets
/// German first and asks for the translation only when stuck.
const List<RadioEpisode> radioSeedEpisodes = <RadioEpisode>[
  // ---------------------------------------------------------------- A1 ----
  RadioEpisode(
    id: 'rd-a1-01',
    level: CefrLevel.a1,
    genre: RadioGenre.weather,
    title: 'Das Wetter heute',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Morgen. Hier ist das Wetter für heute.',
        english: 'Good morning. Here is the weather for today.',
      ),
      RadioLine(
        german: 'Im Norden regnet es am Vormittag.',
        english: 'In the north it rains in the morning.',
      ),
      RadioLine(
        german: 'Es ist kühl. Die Temperatur liegt bei zwölf Grad.',
        english: 'It is cool. The temperature is around twelve degrees.',
      ),
      RadioLine(
        german: 'Im Süden scheint die Sonne.',
        english: 'In the south the sun is shining.',
      ),
      RadioLine(
        german: 'Dort wird es warm, ungefähr zweiundzwanzig Grad.',
        english: 'There it gets warm, about twenty-two degrees.',
      ),
      RadioLine(
        german: 'Am Abend kommt Wind aus dem Westen.',
        english: 'In the evening wind comes from the west.',
      ),
      RadioLine(
        german: 'Nehmen Sie eine Jacke mit. Bis morgen!',
        english: 'Take a jacket with you. Until tomorrow!',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie ist das Wetter im Norden?',
        options: <String>['Es regnet.', 'Es schneit.', 'Die Sonne scheint.'],
        correctIndex: 0,
        explanation: 'Im Norden regnet es am Vormittag.',
      ),
      ChoiceQuestion(
        prompt: 'Wie warm wird es im Süden?',
        options: <String>['Zwölf Grad', 'Zweiundzwanzig Grad', 'Zwei Grad'],
        correctIndex: 1,
        explanation: 'Im Süden wird es ungefähr zweiundzwanzig Grad warm.',
      ),
      ChoiceQuestion(
        prompt: 'Woher kommt am Abend der Wind?',
        options: <String>['Aus dem Osten', 'Aus dem Norden', 'Aus dem Westen'],
        correctIndex: 2,
        explanation: 'Am Abend kommt Wind aus dem Westen.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-02',
    level: CefrLevel.a1,
    genre: RadioGenre.announcement,
    title: 'Durchsage am Bahnhof',
    lines: <RadioLine>[
      RadioLine(
        german: 'Achtung an Gleis drei.',
        english: 'Attention at platform three.',
      ),
      RadioLine(
        german: 'Der Zug nach München fährt um zehn Uhr zwanzig.',
        english: 'The train to Munich departs at ten twenty.',
      ),
      RadioLine(
        german: 'Der Zug hat heute zehn Minuten Verspätung.',
        english: 'The train is ten minutes late today.',
      ),
      RadioLine(
        german: 'Bitte steigen Sie vorne ein.',
        english: 'Please board at the front.',
      ),
      RadioLine(
        german: 'Die Fahrkarten kaufen Sie am Automat.',
        english: 'You buy the tickets at the machine.',
      ),
      RadioLine(
        german: 'Wir wünschen Ihnen eine gute Fahrt.',
        english: 'We wish you a good journey.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wohin fährt der Zug?',
        options: <String>['Nach Berlin', 'Nach München', 'Nach Hamburg'],
        correctIndex: 1,
        explanation: 'Der Zug nach München fährt um zehn Uhr zwanzig.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viel Verspätung hat der Zug?',
        options: <String>['Zehn Minuten', 'Zwanzig Minuten', 'Keine'],
        correctIndex: 0,
        explanation: 'Der Zug hat heute zehn Minuten Verspätung.',
      ),
      ChoiceQuestion(
        prompt: 'Wo kauft man die Fahrkarten?',
        options: <String>['Im Zug', 'Am Automat', 'Bei der Polizei'],
        correctIndex: 1,
        explanation: 'Die Fahrkarten kauft man am Automat.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-03',
    level: CefrLevel.a1,
    genre: RadioGenre.voicemail,
    title: 'Eine Nachricht von Anna',
    lines: <RadioLine>[
      RadioLine(
        german: 'Hallo Tom, hier ist Anna.',
        english: 'Hello Tom, this is Anna.',
      ),
      RadioLine(
        german: 'Ich rufe wegen morgen an.',
        english: 'I am calling about tomorrow.',
      ),
      RadioLine(
        german: 'Wir treffen uns um sieben Uhr im Restaurant.',
        english: 'We are meeting at seven at the restaurant.',
      ),
      RadioLine(
        german: 'Das Restaurant ist neben der Post.',
        english: 'The restaurant is next to the post office.',
      ),
      RadioLine(
        german: 'Bring bitte deine Schwester mit.',
        english: 'Please bring your sister.',
      ),
      RadioLine(
        german: 'Ruf mich heute Abend an. Tschüss!',
        english: 'Call me this evening. Bye!',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Um wie viel Uhr treffen sie sich?',
        options: <String>['Um sechs Uhr', 'Um sieben Uhr', 'Um acht Uhr'],
        correctIndex: 1,
        explanation: 'Sie treffen sich um sieben Uhr.',
      ),
      ChoiceQuestion(
        prompt: 'Wo ist das Restaurant?',
        options: <String>[
          'Neben der Post',
          'Neben dem Bahnhof',
          'Neben der Schule',
        ],
        correctIndex: 0,
        explanation: 'Das Restaurant ist neben der Post.',
      ),
      ChoiceQuestion(
        prompt: 'Wen soll Tom mitbringen?',
        options: <String>['Seinen Bruder', 'Seine Schwester', 'Seinen Hund'],
        correctIndex: 1,
        explanation: 'Anna sagt: Bring bitte deine Schwester mit.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- A2 ----
  RadioEpisode(
    id: 'rd-a2-01',
    level: CefrLevel.a2,
    genre: RadioGenre.recipe,
    title: 'Kartoffelsuppe für vier Personen',
    lines: <RadioLine>[
      RadioLine(
        german: 'Heute kochen wir eine einfache Kartoffelsuppe.',
        english: 'Today we are cooking a simple potato soup.',
      ),
      RadioLine(
        german: 'Sie brauchen ein Kilo Kartoffeln und zwei Karotten.',
        english: 'You need one kilo of potatoes and two carrots.',
      ),
      RadioLine(
        german: 'Schneiden Sie das Gemüse in kleine Stücke.',
        english: 'Cut the vegetables into small pieces.',
      ),
      RadioLine(
        german: 'Kochen Sie alles etwa zwanzig Minuten in Wasser.',
        english: 'Cook everything for about twenty minutes in water.',
      ),
      RadioLine(
        german: 'Dann geben Sie Salz, Pfeffer und etwas Sahne dazu.',
        english: 'Then add salt, pepper and a little cream.',
      ),
      RadioLine(
        german: 'Zum Schluss schmeckt frische Petersilie sehr gut.',
        english: 'Finally fresh parsley tastes very good.',
      ),
      RadioLine(
        german: 'Die Suppe passt besonders gut im Winter. Guten Appetit!',
        english: 'The soup suits winter particularly well. Enjoy your meal!',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie viele Kartoffeln braucht man?',
        options: <String>['Ein halbes Kilo', 'Ein Kilo', 'Zwei Kilo'],
        correctIndex: 1,
        explanation: 'Man braucht ein Kilo Kartoffeln.',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange kocht die Suppe?',
        options: <String>[
          'Etwa zehn Minuten',
          'Etwa zwanzig Minuten',
          'Etwa eine Stunde',
        ],
        correctIndex: 1,
        explanation: 'Alles kocht etwa zwanzig Minuten in Wasser.',
      ),
      ChoiceQuestion(
        prompt: 'Was kommt zum Schluss dazu?',
        options: <String>['Frische Petersilie', 'Zucker', 'Zitrone'],
        correctIndex: 0,
        explanation: 'Zum Schluss schmeckt frische Petersilie sehr gut.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-02',
    level: CefrLevel.a2,
    genre: RadioGenre.news,
    title: 'Nachrichten aus der Stadt',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Abend. Hier sind die Nachrichten aus der Stadt.',
        english: 'Good evening. Here is the news from the city.',
      ),
      RadioLine(
        german: 'Die neue Bibliothek am Marktplatz öffnet am Montag.',
        english: 'The new library on the market square opens on Monday.',
      ),
      RadioLine(
        german: 'Der Eintritt ist für alle Bürger kostenlos.',
        english: 'Admission is free for all citizens.',
      ),
      RadioLine(
        german: 'Die Straße vor dem Rathaus bleibt bis Freitag gesperrt.',
        english: 'The street in front of the town hall stays closed until Friday.',
      ),
      RadioLine(
        german: 'Die Busse fahren in dieser Woche eine andere Strecke.',
        english: 'The buses take a different route this week.',
      ),
      RadioLine(
        german: 'Am Wochenende gibt es im Park ein kleines Konzert.',
        english: 'At the weekend there is a small concert in the park.',
      ),
      RadioLine(
        german: 'Es beginnt um sechzehn Uhr und dauert zwei Stunden.',
        english: 'It begins at four in the afternoon and lasts two hours.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann öffnet die neue Bibliothek?',
        options: <String>['Am Montag', 'Am Freitag', 'Am Wochenende'],
        correctIndex: 0,
        explanation: 'Die neue Bibliothek öffnet am Montag.',
      ),
      ChoiceQuestion(
        prompt: 'Warum fahren die Busse anders?',
        options: <String>[
          'Die Straße vor dem Rathaus ist gesperrt.',
          'Es gibt zu wenige Fahrer.',
          'Das Wetter ist schlecht.',
        ],
        correctIndex: 0,
        explanation:
            'Die Straße vor dem Rathaus bleibt bis Freitag gesperrt, deshalb '
            'fahren die Busse eine andere Strecke.',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange dauert das Konzert?',
        options: <String>['Eine Stunde', 'Zwei Stunden', 'Den ganzen Tag'],
        correctIndex: 1,
        explanation: 'Es beginnt um sechzehn Uhr und dauert zwei Stunden.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- B1 ----
  RadioEpisode(
    id: 'rd-b1-01',
    level: CefrLevel.b1,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Der alte Hafen',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen am alten Hafen. Bleiben Sie hier einen Moment stehen.',
        english: 'Welcome to the old harbour. Stop here for a moment.',
      ),
      RadioLine(
        german:
            'Vor Ihnen sehen Sie die Lagerhäuser aus dem neunzehnten Jahrhundert.',
        english: 'In front of you are the warehouses from the nineteenth century.',
      ),
      RadioLine(
        german:
            'Damals kamen die Schiffe mit Kaffee, Gewürzen und Baumwolle an.',
        english: 'Back then the ships arrived with coffee, spices and cotton.',
      ),
      RadioLine(
        german:
            'Die Arbeit im Hafen war schwer und schlecht bezahlt.',
        english: 'Work in the harbour was hard and badly paid.',
      ),
      RadioLine(
        german:
            'Nach dem Krieg verlor der Hafen seine wirtschaftliche Bedeutung.',
        english: 'After the war the harbour lost its economic importance.',
      ),
      RadioLine(
        german:
            'Heute befinden sich in den Gebäuden Wohnungen, Cafés und ein Museum.',
        english: 'Today the buildings house flats, cafés and a museum.',
      ),
      RadioLine(
        german:
            'Gehen Sie nun bitte nach links zur nächsten Station.',
        english: 'Please now go left to the next stop.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was brachten die Schiffe früher in den Hafen?',
        options: <String>[
          'Kaffee, Gewürze und Baumwolle',
          'Autos und Maschinen',
          'Nur Fisch',
        ],
        correctIndex: 0,
        explanation:
            'Damals kamen die Schiffe mit Kaffee, Gewürzen und Baumwolle an.',
      ),
      ChoiceQuestion(
        prompt: 'Wann verlor der Hafen seine Bedeutung?',
        options: <String>[
          'Im neunzehnten Jahrhundert',
          'Nach dem Krieg',
          'Erst vor wenigen Jahren',
        ],
        correctIndex: 1,
        explanation:
            'Nach dem Krieg verlor der Hafen seine wirtschaftliche Bedeutung.',
      ),
      ChoiceQuestion(
        prompt: 'Was findet man heute in den Lagerhäusern?',
        options: <String>[
          'Wohnungen, Cafés und ein Museum',
          'Nur leere Räume',
          'Eine Fabrik',
        ],
        correctIndex: 0,
        explanation:
            'Heute befinden sich in den Gebäuden Wohnungen, Cafés und ein Museum.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-02',
    level: CefrLevel.b1,
    genre: RadioGenre.lecture,
    title: 'Kurz erklärt: Warum wir schlafen',
    lines: <RadioLine>[
      RadioLine(
        german: 'Wir verbringen etwa ein Drittel unseres Lebens im Schlaf.',
        english: 'We spend about a third of our lives asleep.',
      ),
      RadioLine(
        german:
            'Lange wusste die Forschung nicht genau, warum das nötig ist.',
        english: 'For a long time research did not know exactly why that is necessary.',
      ),
      RadioLine(
        german:
            'Heute geht man davon aus, dass das Gehirn im Schlaf aufräumt.',
        english: 'Today it is assumed that the brain tidies up during sleep.',
      ),
      RadioLine(
        german:
            'Erinnerungen werden sortiert und wichtige Informationen gespeichert.',
        english: 'Memories are sorted and important information is stored.',
      ),
      RadioLine(
        german:
            'Wer zu wenig schläft, kann sich schlechter konzentrieren.',
        english: 'People who sleep too little can concentrate less well.',
      ),
      RadioLine(
        german:
            'Auch das Immunsystem arbeitet dann nicht mehr richtig.',
        english: 'The immune system then also stops working properly.',
      ),
      RadioLine(
        german:
            'Erwachsene brauchen im Durchschnitt sieben bis acht Stunden.',
        english: 'Adults need seven to eight hours on average.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was macht das Gehirn nach heutiger Auffassung im Schlaf?',
        options: <String>[
          'Es ruht vollständig.',
          'Es sortiert Erinnerungen und speichert Informationen.',
          'Es arbeitet gar nicht.',
        ],
        correctIndex: 1,
        explanation:
            'Erinnerungen werden sortiert und wichtige Informationen gespeichert.',
      ),
      ChoiceQuestion(
        prompt: 'Welche Folge hat zu wenig Schlaf?',
        options: <String>[
          'Man kann sich schlechter konzentrieren.',
          'Man wird größer.',
          'Man braucht weniger Essen.',
        ],
        correctIndex: 0,
        explanation:
            'Wer zu wenig schläft, kann sich schlechter konzentrieren.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viel Schlaf brauchen Erwachsene im Durchschnitt?',
        options: <String>[
          'Vier bis fünf Stunden',
          'Sieben bis acht Stunden',
          'Zehn bis elf Stunden',
        ],
        correctIndex: 1,
        explanation:
            'Erwachsene brauchen im Durchschnitt sieben bis acht Stunden.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- B2 ----
  RadioEpisode(
    id: 'rd-b2-01',
    level: CefrLevel.b2,
    genre: RadioGenre.news,
    title: 'Wirtschaft am Morgen',
    lines: <RadioLine>[
      RadioLine(
        german:
            'Die Zahl der offenen Stellen ist im vergangenen Quartal erneut gesunken.',
        english:
            'The number of vacancies fell again in the past quarter.',
      ),
      RadioLine(
        german:
            'Besonders betroffen ist die Bauwirtschaft, die unter hohen Zinsen leidet.',
        english:
            'The construction industry is particularly affected, suffering under high interest rates.',
      ),
      RadioLine(
        german:
            'Wirtschaftsforscher warnen allerdings vor voreiligen Schlüssen.',
        english: 'Economists warn, however, against hasty conclusions.',
      ),
      RadioLine(
        german:
            'Ein einzelnes Quartal lasse noch keine Aussage über den Trend zu.',
        english: 'A single quarter does not yet permit a statement about the trend.',
      ),
      RadioLine(
        german:
            'Im Dienstleistungssektor werden weiterhin Fachkräfte gesucht.',
        english: 'In the service sector skilled workers are still being sought.',
      ),
      RadioLine(
        german:
            'Die Regierung will die Ausbildung mit zusätzlichen Mitteln fördern.',
        english: 'The government intends to support training with additional funds.',
      ),
      RadioLine(
        german:
            'Ob das ausreicht, ist unter Fachleuten umstritten.',
        english: 'Whether that is sufficient is disputed among experts.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Welche Branche ist besonders betroffen?',
        options: <String>[
          'Die Bauwirtschaft',
          'Die Landwirtschaft',
          'Der Tourismus',
        ],
        correctIndex: 0,
        explanation:
            'Besonders betroffen ist die Bauwirtschaft, die unter hohen Zinsen leidet.',
      ),
      ChoiceQuestion(
        prompt: 'Wovor warnen die Wirtschaftsforscher?',
        options: <String>[
          'Vor steigenden Preisen',
          'Vor voreiligen Schlüssen',
          'Vor einem Streik',
        ],
        correctIndex: 1,
        explanation:
            'Wirtschaftsforscher warnen vor voreiligen Schlüssen, weil ein '
            'einzelnes Quartal keine Aussage über den Trend zulässt.',
      ),
      ChoiceQuestion(
        prompt: 'Wie ist die Haltung der Fachleute zur Förderung?',
        options: <String>[
          'Sie sind sich einig, dass sie reicht.',
          'Sie halten sie für überflüssig.',
          'Sie sind sich uneinig, ob sie ausreicht.',
        ],
        correctIndex: 2,
        explanation: 'Ob das ausreicht, ist unter Fachleuten umstritten.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- C1 ----
  RadioEpisode(
    id: 'rd-c1-01',
    level: CefrLevel.c1,
    genre: RadioGenre.lecture,
    title: 'Über die Grenzen von Statistiken',
    lines: <RadioLine>[
      RadioLine(
        german:
            'Statistiken gelten als nüchtern, doch sie sind nie voraussetzungslos.',
        english:
            'Statistics are considered sober, yet they are never free of assumptions.',
      ),
      RadioLine(
        german:
            'Schon die Wahl der Kategorien entscheidet mit, was sichtbar wird.',
        english:
            'The choice of categories alone helps determine what becomes visible.',
      ),
      RadioLine(
        german:
            'Wer Armut ausschließlich am Einkommen misst, blendet Vermögen aus.',
        english:
            'Anyone measuring poverty solely by income leaves wealth out of view.',
      ),
      RadioLine(
        german:
            'Hinzu kommt, dass Durchschnittswerte Verteilungen verdecken können.',
        english:
            'In addition, average values can conceal distributions.',
      ),
      RadioLine(
        german:
            'Zwei Gesellschaften mit gleichem Durchschnitt können höchst ungleich sein.',
        english:
            'Two societies with the same average can be extremely unequal.',
      ),
      RadioLine(
        german:
            'Das spricht nicht gegen Statistiken, wohl aber gegen ihre naive Lektüre.',
        english:
            'That does not argue against statistics, but it does argue against reading them naively.',
      ),
      RadioLine(
        german:
            'Entscheidend bleibt die Frage, welche Frage überhaupt gestellt wurde.',
        english:
            'The decisive issue remains which question was asked in the first place.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was folgt laut Text aus der Wahl der Kategorien?',
        options: <String>[
          'Sie bestimmt mit, was sichtbar wird.',
          'Sie ist für das Ergebnis unerheblich.',
          'Sie betrifft nur die Darstellung.',
        ],
        correctIndex: 0,
        explanation:
            'Schon die Wahl der Kategorien entscheidet mit, was sichtbar wird.',
      ),
      ChoiceQuestion(
        prompt: 'Warum sind Durchschnittswerte problematisch?',
        options: <String>[
          'Sie sind schwer zu berechnen.',
          'Sie können Verteilungen verdecken.',
          'Sie sind immer falsch.',
        ],
        correctIndex: 1,
        explanation:
            'Durchschnittswerte können Verteilungen verdecken; zwei '
            'Gesellschaften mit gleichem Durchschnitt können ungleich sein.',
      ),
      ChoiceQuestion(
        prompt: 'Welche Haltung nimmt der Text zu Statistiken ein?',
        options: <String>[
          'Er lehnt sie grundsätzlich ab.',
          'Er hält sie für unfehlbar.',
          'Er verteidigt sie, warnt aber vor naiver Lektüre.',
        ],
        correctIndex: 2,
        explanation:
            'Das spricht nicht gegen Statistiken, wohl aber gegen ihre naive '
            'Lektüre.',
      ),
    ],
  ),
];


/// The whole library, assembled from the per-level script files.
///
/// Episodes live in one file per level so a batch of new scripts is a new file
/// rather than a rewrite of a growing one.
const List<RadioEpisode> radioEpisodes = <RadioEpisode>[
  ...radioSeedEpisodes,
  ...radioA1Episodes,
  ...radioA2Episodes,
  ...radioB1Episodes,
  ...radioCEpisodes,
];
