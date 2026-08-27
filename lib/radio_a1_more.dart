import 'models.dart';
import 'radio.dart';

/// A1 Gartenradio scripts, second batch.
///
/// Original text written for this app. Episodes live in one file
/// per batch so a new set of scripts is a new file rather than a
/// rewrite of a growing one.
const List<RadioEpisode> radioA1MoreEpisodes = <RadioEpisode>[
  RadioEpisode(
    id: 'rd-a1-18',
    level: CefrLevel.a1,
    genre: RadioGenre.news,
    title: 'Meldungen am Mittag',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Tag, hier sind die Nachrichten aus Lindenau.',
        english: 'Good afternoon, here is the news from Lindenau.',
      ),
      RadioLine(
        german: 'Der neue Spielplatz im Stadtpark ist ab Montag offen.',
        english: 'The new playground in the town park opens from Monday.',
      ),
      RadioLine(
        german: 'Die Stadt zahlt vierzigtausend Euro für die Geräte.',
        english: 'The town is paying forty thousand euros for the equipment.',
      ),
      RadioLine(
        german: 'Der Bus 7 fährt am Dienstag nicht.',
        english: 'Bus 7 does not run on Tuesday.',
      ),
      RadioLine(
        german: 'Die Bibliothek öffnet jetzt auch am Samstag.',
        english: 'The library is now open on Saturdays as well.',
      ),
      RadioLine(
        german: 'Sie können dort Bücher und Filme leihen.',
        english: 'You can borrow books and films there.',
      ),
      RadioLine(
        german: 'Der Wochenmarkt beginnt am Freitag um 8 Uhr.',
        english: 'The weekly market starts at 8 in the morning on Friday.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann ist der neue Spielplatz offen?',
        options: <String>[
          'Ab Freitag',
          'Ab Montag',
          'Ab Dienstag',
        ],
        correctIndex: 1,
        explanation: 'Im Text heißt es: Der neue Spielplatz im Stadtpark ist ab Montag offen.',
      ),
      ChoiceQuestion(
        prompt: 'Was zahlt die Stadt für die Geräte?',
        options: <String>[
          'Viertausend Euro',
          'Vierzehntausend Euro',
          'Vierzigtausend Euro',
        ],
        correctIndex: 2,
        explanation: 'Die Stadt zahlt vierzigtausend Euro für die Geräte.',
      ),
      ChoiceQuestion(
        prompt: 'Wann beginnt der Wochenmarkt am Freitag?',
        options: <String>[
          'Um 8 Uhr',
          'Um 9 Uhr',
          'Um 10 Uhr',
        ],
        correctIndex: 0,
        explanation: 'Der Wochenmarkt beginnt am Freitag um 8 Uhr.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-19',
    level: CefrLevel.a1,
    genre: RadioGenre.recipe,
    title: 'Rührei für zwei Personen',
    lines: <RadioLine>[
      RadioLine(
        german: 'Heute koche ich Rührei für zwei Personen.',
        english: 'Today I am making scrambled eggs for two people.',
      ),
      RadioLine(
        german: 'Sie brauchen vier Eier, etwas Milch, Salz und Butter.',
        english: 'You need four eggs, a little milk, salt and butter.',
      ),
      RadioLine(
        german: 'Zuerst kommen die Eier und die Milch in eine Schüssel.',
        english: 'First the eggs and the milk go into a bowl.',
      ),
      RadioLine(
        german: 'Dann kommt die Butter in die Pfanne.',
        english: 'Then the butter goes into the pan.',
      ),
      RadioLine(
        german: 'Das Ei braucht drei Minuten in der Pfanne.',
        english: 'The egg needs three minutes in the pan.',
      ),
      RadioLine(
        german: 'Zum Schluss kommen Salz und frischer Schnittlauch dazu.',
        english: 'Finally, salt and fresh chives go on top.',
      ),
      RadioLine(
        german: 'Ein Frühstück für zwei kostet so nur drei Euro.',
        english: 'That way a breakfast for two costs only three euros.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie viele Eier brauchen Sie?',
        options: <String>[
          'Zwei Eier',
          'Drei Eier',
          'Vier Eier',
        ],
        correctIndex: 2,
        explanation: 'Im Text steht: Sie brauchen vier Eier, etwas Milch, Salz und Butter.',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange braucht das Ei in der Pfanne?',
        options: <String>[
          'Drei Minuten',
          'Fünf Minuten',
          'Zehn Minuten',
        ],
        correctIndex: 0,
        explanation: 'Das Ei braucht drei Minuten in der Pfanne.',
      ),
      ChoiceQuestion(
        prompt: 'Was kostet das Frühstück für zwei Personen?',
        options: <String>[
          'Zwei Euro',
          'Drei Euro',
          'Vier Euro',
        ],
        correctIndex: 1,
        explanation: 'Ein Frühstück für zwei kostet nur drei Euro.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-20',
    level: CefrLevel.a1,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Die alte Mühle',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen an der alten Mühle von Bergthal.',
        english: 'Welcome to the old mill in Bergthal.',
      ),
      RadioLine(
        german: 'Das Haus ist zweihundert Jahre alt.',
        english: 'The building is two hundred years old.',
      ),
      RadioLine(
        german: 'Hier macht der Müller aus Korn Mehl.',
        english: 'Here the miller turns grain into flour.',
      ),
      RadioLine(
        german: 'Das Rad im Wasser ist fünf Meter hoch.',
        english: 'The wheel in the water is five metres high.',
      ),
      RadioLine(
        german: 'Links sehen Sie die alte Küche.',
        english: 'On your left you can see the old kitchen.',
      ),
      RadioLine(
        german: 'Der Eintritt kostet drei Euro für Kinder.',
        english: 'Admission costs three euros for children.',
      ),
      RadioLine(
        german: 'Die Mühle ist bis 17 Uhr offen.',
        english: 'The mill is open until five in the afternoon.',
      ),
      RadioLine(
        german: 'Sie können im Hof Brot und Kuchen kaufen.',
        english: 'You can buy bread and cake in the courtyard.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie alt ist das Haus?',
        options: <String>[
          'Hundert Jahre',
          'Zweihundert Jahre',
          'Dreihundert Jahre',
        ],
        correctIndex: 1,
        explanation: 'Im Text heißt es: Das Haus ist zweihundert Jahre alt.',
      ),
      ChoiceQuestion(
        prompt: 'Wie hoch ist das Rad im Wasser?',
        options: <String>[
          'Drei Meter',
          'Vier Meter',
          'Fünf Meter',
        ],
        correctIndex: 2,
        explanation: 'Das Rad im Wasser ist fünf Meter hoch.',
      ),
      ChoiceQuestion(
        prompt: 'Was kostet der Eintritt für Kinder?',
        options: <String>[
          'Drei Euro',
          'Fünf Euro',
          'Sieben Euro',
        ],
        correctIndex: 0,
        explanation: 'Der Eintritt kostet drei Euro für Kinder.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-21',
    level: CefrLevel.a1,
    genre: RadioGenre.weather,
    title: 'Wetter für Donnerstag',
    lines: <RadioLine>[
      RadioLine(
        german: 'Hier ist der Wetterbericht für Donnerstag.',
        english: 'Here is the weather report for Thursday.',
      ),
      RadioLine(
        german: 'Am Morgen ist es kalt, denn es gibt viel Nebel.',
        english: 'In the morning it is cold, because there is a lot of fog.',
      ),
      RadioLine(
        german: 'In Weiherbach sind es nur vier Grad.',
        english: 'In Weiherbach it is only four degrees.',
      ),
      RadioLine(
        german: 'Am Mittag scheint die Sonne.',
        english: 'At midday the sun shines.',
      ),
      RadioLine(
        german: 'Im Süden gibt es am Nachmittag Regen.',
        english: 'In the south there is rain in the afternoon.',
      ),
      RadioLine(
        german: 'Der Wind kommt aus Westen und ist stark.',
        english: 'The wind comes from the west and is strong.',
      ),
      RadioLine(
        german: 'Am Abend sind es zwölf Grad.',
        english: 'In the evening it is twelve degrees.',
      ),
      RadioLine(
        german: 'Sie können am Abend gut spazieren gehen.',
        english: 'In the evening you can go for a nice walk.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie warm ist es am Morgen in Weiherbach?',
        options: <String>[
          'Zwei Grad',
          'Vier Grad',
          'Zwölf Grad',
        ],
        correctIndex: 1,
        explanation: 'Im Bericht heißt es: In Weiherbach sind es nur vier Grad.',
      ),
      ChoiceQuestion(
        prompt: 'Wo gibt es am Nachmittag Regen?',
        options: <String>[
          'Im Norden',
          'Im Osten',
          'Im Süden',
        ],
        correctIndex: 2,
        explanation: 'Im Süden gibt es am Nachmittag Regen.',
      ),
      ChoiceQuestion(
        prompt: 'Woher kommt der Wind?',
        options: <String>[
          'Aus Westen',
          'Aus Osten',
          'Aus Norden',
        ],
        correctIndex: 0,
        explanation: 'Der Wind kommt aus Westen und ist stark.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-22',
    level: CefrLevel.a1,
    genre: RadioGenre.announcement,
    title: 'Durchsage in der Straßenbahn',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen in der Linie 4 nach Rosenfeld.',
        english: 'Welcome aboard line 4 to Rosenfeld.',
      ),
      RadioLine(
        german: 'Die nächste Haltestelle ist Kirchplatz.',
        english: 'The next stop is Kirchplatz.',
      ),
      RadioLine(
        german: 'Dort können Sie in den Bus 12 umsteigen.',
        english: 'There you can change to bus 12.',
      ),
      RadioLine(
        german: 'Die Fahrkarte kostet zwei Euro fünfzig.',
        english: 'A ticket costs two euros fifty.',
      ),
      RadioLine(
        german: 'Sie müssen die Fahrkarte vorne im Wagen kaufen.',
        english: 'You have to buy your ticket at the front of the carriage.',
      ),
      RadioLine(
        german: 'Bitte nehmen Sie Ihre Taschen vom Sitz.',
        english: 'Please take your bags off the seat.',
      ),
      RadioLine(
        german: 'Die letzte Bahn fährt heute um 23 Uhr.',
        english: 'The last tram today leaves at eleven in the evening.',
      ),
      RadioLine(
        german: 'Wir wünschen Ihnen eine gute Fahrt.',
        english: 'We wish you a pleasant journey.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie heißt die nächste Haltestelle?',
        options: <String>[
          'Rosenfeld',
          'Kirchplatz',
          'Stadtpark',
        ],
        correctIndex: 1,
        explanation: 'In der Durchsage heißt es: Die nächste Haltestelle ist Kirchplatz.',
      ),
      ChoiceQuestion(
        prompt: 'Was kostet die Fahrkarte?',
        options: <String>[
          'Ein Euro fünfzig',
          'Drei Euro fünfzig',
          'Zwei Euro fünfzig',
        ],
        correctIndex: 2,
        explanation: 'Die Fahrkarte kostet zwei Euro fünfzig.',
      ),
      ChoiceQuestion(
        prompt: 'Wann fährt heute die letzte Bahn?',
        options: <String>[
          'Um 23 Uhr',
          'Um 22 Uhr',
          'Um 21 Uhr',
        ],
        correctIndex: 0,
        explanation: 'Die letzte Bahn fährt heute um 23 Uhr.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-23',
    level: CefrLevel.a1,
    genre: RadioGenre.voicemail,
    title: 'Ein Paket für Jonas',
    lines: <RadioLine>[
      RadioLine(
        german: 'Hallo Jonas, hier spricht Frau Reimann aus dem dritten Stock.',
        english: 'Hello Jonas, this is Mrs Reimann from the third floor.',
      ),
      RadioLine(
        german: 'Dein Paket liegt heute bei mir in der Küche.',
        english: 'Your parcel is here in my kitchen today.',
      ),
      RadioLine(
        german: 'Ich bin bis achtzehn Uhr zu Hause.',
        english: 'I am at home until six in the evening.',
      ),
      RadioLine(
        german: 'Du kannst es am Abend holen.',
        english: 'You can pick it up in the evening.',
      ),
      RadioLine(
        german: 'Der Karton ist klein, aber er ist schwer.',
        english: 'The box is small, but it is heavy.',
      ),
      RadioLine(
        german: 'Bitte klingle zweimal, denn meine Klingel ist leise.',
        english: 'Please ring twice, because my doorbell is quiet.',
      ),
      RadioLine(
        german: 'Bis später und schönen Tag.',
        english: 'See you later and have a nice day.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Bis wann ist Frau Reimann zu Hause?',
        options: <String>[
          'Bis sechzehn Uhr',
          'Bis achtzehn Uhr',
          'Bis zwanzig Uhr',
        ],
        correctIndex: 1,
        explanation: 'Sie sagt: Ich bin bis achtzehn Uhr zu Hause.',
      ),
      ChoiceQuestion(
        prompt: 'Wie ist der Karton?',
        options: <String>[
          'Groß und leicht',
          'Groß und schwer',
          'Klein und schwer',
        ],
        correctIndex: 2,
        explanation: 'Im Text: Der Karton ist klein, aber er ist schwer.',
      ),
      ChoiceQuestion(
        prompt: 'Wo liegt das Paket?',
        options: <String>[
          'In der Küche',
          'Im Bad',
          'Im Flur',
        ],
        correctIndex: 0,
        explanation: 'Sie sagt: Dein Paket liegt heute bei mir in der Küche.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-24',
    level: CefrLevel.a1,
    genre: RadioGenre.diary,
    title: 'Abend im Schrebergarten',
    lines: <RadioLine>[
      RadioLine(
        german: 'Heute ist Dienstag, und der Tag ist warm.',
        english: 'Today is Tuesday, and the day is warm.',
      ),
      RadioLine(
        german: 'Am Nachmittag fahre ich mit dem Rad in den Garten.',
        english: 'In the afternoon I cycle out to the allotment.',
      ),
      RadioLine(
        german: 'Der Weg dauert zwanzig Minuten.',
        english: 'The ride takes twenty minutes.',
      ),
      RadioLine(
        german: 'Ich gieße die Tomaten, denn die Erde ist trocken.',
        english: 'I water the tomatoes, because the soil is dry.',
      ),
      RadioLine(
        german: 'Es gibt schon zwei rote Tomaten.',
        english: 'There are already two red tomatoes.',
      ),
      RadioLine(
        german: 'Meine Nachbarin bringt mir Kaffee und wir sitzen auf der Bank.',
        english: 'My neighbour brings me coffee and we sit on the bench.',
      ),
      RadioLine(
        german: 'Um sieben Uhr fahre ich wieder nach Hause.',
        english: 'At seven o\'clock I ride home again.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie lange dauert der Weg mit dem Rad?',
        options: <String>[
          'Zehn Minuten',
          'Fünfzehn Minuten',
          'Zwanzig Minuten',
        ],
        correctIndex: 2,
        explanation: 'Im Text: Der Weg dauert zwanzig Minuten.',
      ),
      ChoiceQuestion(
        prompt: 'Warum brauchen die Tomaten Wasser?',
        options: <String>[
          'Die Erde ist trocken',
          'Die Tomaten sind klein',
          'Der Garten ist neu',
        ],
        correctIndex: 0,
        explanation: 'Im Text: Ich gieße die Tomaten, denn die Erde ist trocken.',
      ),
      ChoiceQuestion(
        prompt: 'Wann geht es zurück nach Hause?',
        options: <String>[
          'Um sechs Uhr',
          'Um sieben Uhr',
          'Um acht Uhr',
        ],
        correctIndex: 1,
        explanation: 'Im Text: Um sieben Uhr fahre ich wieder nach Hause.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-25',
    level: CefrLevel.a1,
    genre: RadioGenre.recipe,
    title: 'Schneller Gurkensalat',
    lines: <RadioLine>[
      RadioLine(
        german: 'Für zwei Personen brauchst du eine Gurke und einen Becher Joghurt.',
        english: 'For two people you need one cucumber and a tub of yoghurt.',
      ),
      RadioLine(
        german: 'Wasche die Gurke und schneide sie in dünne Scheiben.',
        english: 'Wash the cucumber and cut it into thin slices.',
      ),
      RadioLine(
        german: 'Gib den Joghurt in eine Schüssel.',
        english: 'Put the yoghurt into a bowl.',
      ),
      RadioLine(
        german: 'Dazu kommen Salz, Pfeffer und ein Löffel Öl.',
        english: 'Add salt, pepper and a spoonful of oil.',
      ),
      RadioLine(
        german: 'Rühre alles gut um.',
        english: 'Stir everything well.',
      ),
      RadioLine(
        german: 'Der Salat muss zehn Minuten in den Kühlschrank.',
        english: 'The salad has to go into the fridge for ten minutes.',
      ),
      RadioLine(
        german: 'Eine Gurke kostet auf dem Markt etwa achtzig Cent.',
        english: 'A cucumber costs about eighty cents at the market.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie lange bleibt der Salat im Kühlschrank?',
        options: <String>[
          'Fünf Minuten',
          'Zehn Minuten',
          'Zwanzig Minuten',
        ],
        correctIndex: 1,
        explanation: 'Im Text: Der Salat muss zehn Minuten in den Kühlschrank.',
      ),
      ChoiceQuestion(
        prompt: 'Was kostet eine Gurke auf dem Markt?',
        options: <String>[
          'Etwa sechzig Cent',
          'Etwa einen Euro',
          'Etwa achtzig Cent',
        ],
        correctIndex: 2,
        explanation: 'Im Text: Eine Gurke kostet auf dem Markt etwa achtzig Cent.',
      ),
      ChoiceQuestion(
        prompt: 'Für wie viele Personen ist der Salat?',
        options: <String>[
          'Für zwei Personen',
          'Für drei Personen',
          'Für vier Personen',
        ],
        correctIndex: 0,
        explanation: 'Im Text: Für zwei Personen brauchst du eine Gurke und einen Becher Joghurt.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-26',
    level: CefrLevel.a1,
    genre: RadioGenre.news,
    title: 'Neue Buslinie in Talheim',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Morgen, hier sind die Nachrichten aus Talheim.',
        english: 'Good morning, here is the news from Talheim.',
      ),
      RadioLine(
        german: 'Ab Montag fährt die neue Buslinie sieben zum Krankenhaus.',
        english: 'From Monday the new bus line seven runs to the hospital.',
      ),
      RadioLine(
        german: 'Der Bus fährt jeden Tag von sechs bis zweiundzwanzig Uhr.',
        english: 'The bus runs every day from six in the morning until ten at night.',
      ),
      RadioLine(
        german: 'Eine Fahrt kostet zwei Euro vierzig.',
        english: 'A single ride costs two euros forty.',
      ),
      RadioLine(
        german: 'Die Bibliothek am Marktplatz öffnet jetzt auch am Samstag.',
        english: 'The library on the market square is now open on Saturdays too.',
      ),
      RadioLine(
        german: 'Das Wetter bleibt heute trocken, aber es ist kühl.',
        english: 'The weather stays dry today, but it is cool.',
      ),
      RadioLine(
        german: 'Am Abend gibt es Wind aus dem Norden.',
        english: 'In the evening there will be wind from the north.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was kostet eine Fahrt?',
        options: <String>[
          'Zwei Euro',
          'Zwei Euro vierzig',
          'Vier Euro zwanzig',
        ],
        correctIndex: 1,
        explanation: 'Im Text: Eine Fahrt kostet zwei Euro vierzig.',
      ),
      ChoiceQuestion(
        prompt: 'Wohin fährt die neue Buslinie sieben?',
        options: <String>[
          'Zum Bahnhof',
          'Zur Schule',
          'Zum Krankenhaus',
        ],
        correctIndex: 2,
        explanation: 'Im Text: Ab Montag fährt die neue Buslinie sieben zum Krankenhaus.',
      ),
      ChoiceQuestion(
        prompt: 'Wie ist das Wetter heute?',
        options: <String>[
          'Trocken und kühl',
          'Warm und sonnig',
          'Nass und kalt',
        ],
        correctIndex: 0,
        explanation: 'Im Text: Das Wetter bleibt heute trocken, aber es ist kühl.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-27',
    level: CefrLevel.a1,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Der Schlossgarten',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen im Schlossgarten von Talberg.',
        english: 'Welcome to the palace garden in Talberg.',
      ),
      RadioLine(
        german: 'Der Garten ist sehr alt.',
        english: 'The garden is very old.',
      ),
      RadioLine(
        german: 'Hier gibt es über hundert Rosen.',
        english: 'There are more than a hundred roses here.',
      ),
      RadioLine(
        german: 'Links sehen Sie einen kleinen See.',
        english: 'On your left you can see a small lake.',
      ),
      RadioLine(
        german: 'Der Weg zum See dauert fünf Minuten.',
        english: 'The walk to the lake takes five minutes.',
      ),
      RadioLine(
        german: 'Im Café am Tor kostet ein Kaffee zwei Euro.',
        english: 'At the café by the gate, a coffee costs two euros.',
      ),
      RadioLine(
        german: 'Der Garten schließt um sechs Uhr.',
        english: 'The garden closes at six.',
      ),
      RadioLine(
        german: 'Bitte gehen Sie jetzt weiter zur Station drei.',
        english: 'Please move on now to stop number three.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie viele Rosen gibt es im Garten?',
        options: <String>[
          'Über hundert',
          'Über zwanzig',
          'Über fünfhundert',
        ],
        correctIndex: 0,
        explanation: 'Der Text sagt: Hier gibt es über hundert Rosen.',
      ),
      ChoiceQuestion(
        prompt: 'Was kostet ein Kaffee im Café?',
        options: <String>[
          'Vier Euro',
          'Drei Euro',
          'Zwei Euro',
        ],
        correctIndex: 2,
        explanation: 'Im Café am Tor kostet ein Kaffee zwei Euro.',
      ),
      ChoiceQuestion(
        prompt: 'Wann schließt der Garten?',
        options: <String>[
          'Um fünf Uhr',
          'Um sechs Uhr',
          'Um sieben Uhr',
        ],
        correctIndex: 1,
        explanation: 'Der Text sagt: Der Garten schließt um sechs Uhr.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-28',
    level: CefrLevel.a1,
    genre: RadioGenre.announcement,
    title: 'Durchsage im Parkhaus',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Abend, hier spricht das Parkhaus Lindenplatz.',
        english: 'Good evening, this is the Lindenplatz car park speaking.',
      ),
      RadioLine(
        german: 'Das Parkhaus schließt heute um zweiundzwanzig Uhr.',
        english: 'The car park closes today at ten in the evening.',
      ),
      RadioLine(
        german: 'Eine Stunde kostet einen Euro fünfzig.',
        english: 'One hour costs one euro fifty.',
      ),
      RadioLine(
        german: 'Sie können an der Kasse in Ebene eins bezahlen.',
        english: 'You can pay at the pay station on level one.',
      ),
      RadioLine(
        german: 'Die Kasse nimmt Karten, aber sie nimmt kein Bargeld.',
        english: 'The machine takes cards, but it does not take cash.',
      ),
      RadioLine(
        german: 'Der Aufzug ist heute leider kaputt.',
        english: 'Unfortunately, the lift is out of order today.',
      ),
      RadioLine(
        german: 'Bitte nehmen Sie die Treppe.',
        english: 'Please use the stairs.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann schließt das Parkhaus?',
        options: <String>[
          'Um zwanzig Uhr',
          'Um einundzwanzig Uhr',
          'Um zweiundzwanzig Uhr',
        ],
        correctIndex: 2,
        explanation: 'Die Durchsage sagt: Das Parkhaus schließt heute um zweiundzwanzig Uhr.',
      ),
      ChoiceQuestion(
        prompt: 'Was kostet eine Stunde?',
        options: <String>[
          'Einen Euro fünfzig',
          'Zwei Euro',
          'Drei Euro fünfzig',
        ],
        correctIndex: 0,
        explanation: 'Im Text steht: Eine Stunde kostet einen Euro fünfzig.',
      ),
      ChoiceQuestion(
        prompt: 'Was ist heute kaputt?',
        options: <String>[
          'Die Kasse',
          'Der Aufzug',
          'Die Treppe',
        ],
        correctIndex: 1,
        explanation: 'Die Durchsage sagt: Der Aufzug ist heute leider kaputt.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-29',
    level: CefrLevel.a1,
    genre: RadioGenre.weather,
    title: 'Wetter im Frühling',
    lines: <RadioLine>[
      RadioLine(
        german: 'Hier ist der Wetterbericht für Mittwoch.',
        english: 'Here is the weather report for Wednesday.',
      ),
      RadioLine(
        german: 'Am Morgen ist es kühl und neblig.',
        english: 'In the morning it is cool and foggy.',
      ),
      RadioLine(
        german: 'In Grünstett sind es nur sechs Grad.',
        english: 'In Grünstett it is only six degrees.',
      ),
      RadioLine(
        german: 'Am Mittag kommt die Sonne, und es wird warm.',
        english: 'At midday the sun comes out and it turns warm.',
      ),
      RadioLine(
        german: 'Am Nachmittag haben wir siebzehn Grad.',
        english: 'In the afternoon we will have seventeen degrees.',
      ),
      RadioLine(
        german: 'Im Süden regnet es am Abend.',
        english: 'In the south it rains in the evening.',
      ),
      RadioLine(
        german: 'Bitte nehmen Sie am Abend einen Schirm mit.',
        english: 'Please take an umbrella with you in the evening.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie warm ist es am Nachmittag?',
        options: <String>[
          'Sechs Grad',
          'Siebzehn Grad',
          'Zwanzig Grad',
        ],
        correctIndex: 1,
        explanation: 'Der Bericht sagt: Am Nachmittag haben wir siebzehn Grad.',
      ),
      ChoiceQuestion(
        prompt: 'Wie ist das Wetter am Morgen?',
        options: <String>[
          'Kühl und neblig',
          'Sonnig und warm',
          'Windig und nass',
        ],
        correctIndex: 0,
        explanation: 'Im Text steht: Am Morgen ist es kühl und neblig.',
      ),
      ChoiceQuestion(
        prompt: 'Wo regnet es am Abend?',
        options: <String>[
          'Im Norden',
          'Im Osten',
          'Im Süden',
        ],
        correctIndex: 2,
        explanation: 'Der Bericht sagt: Im Süden regnet es am Abend.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-30',
    level: CefrLevel.a1,
    genre: RadioGenre.diary,
    title: 'Unsere neue Katze',
    lines: <RadioLine>[
      RadioLine(
        german: 'Heute schreibe ich über unsere neue Katze.',
        english: 'Today I am writing about our new cat.',
      ),
      RadioLine(
        german: 'Wir haben seit gestern eine Katze.',
        english: 'We have had a cat since yesterday.',
      ),
      RadioLine(
        german: 'Sie heißt Mira und ist zwei Jahre alt.',
        english: 'Her name is Mira and she is two years old.',
      ),
      RadioLine(
        german: 'Am Morgen sitzt sie immer am Fenster.',
        english: 'In the morning she always sits by the window.',
      ),
      RadioLine(
        german: 'Sie frisst gern Fisch, aber sie mag kein Fleisch.',
        english: 'She likes eating fish, but she does not like meat.',
      ),
      RadioLine(
        german: 'Mein Bruder möchte mit ihr spielen.',
        english: 'My brother wants to play with her.',
      ),
      RadioLine(
        german: 'Aber Mira schläft den ganzen Nachmittag.',
        english: 'But Mira sleeps all afternoon.',
      ),
      RadioLine(
        german: 'Ich finde sie schön, denn sie hat grüne Augen.',
        english: 'I think she is beautiful, because she has green eyes.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie alt ist die Katze?',
        options: <String>[
          'Ein Jahr',
          'Zwei Jahre',
          'Drei Jahre',
        ],
        correctIndex: 1,
        explanation: 'Im Text steht: Sie heißt Mira und ist zwei Jahre alt.',
      ),
      ChoiceQuestion(
        prompt: 'Was frisst Mira gern?',
        options: <String>[
          'Fleisch',
          'Brot',
          'Fisch',
        ],
        correctIndex: 2,
        explanation: 'Der Text sagt: Sie frisst gern Fisch, aber sie mag kein Fleisch.',
      ),
      ChoiceQuestion(
        prompt: 'Wer möchte mit der Katze spielen?',
        options: <String>[
          'Der Bruder',
          'Die Mutter',
          'Die Schwester',
        ],
        correctIndex: 0,
        explanation: 'Im Text steht: Mein Bruder möchte mit ihr spielen.',
      ),
    ],
  ),
];
