import 'models.dart';
import 'radio.dart';

/// A2 Gartenradio scripts, second batch.
///
/// Original text written for this app. Episodes live in one file
/// per batch so a new set of scripts is a new file rather than a
/// rewrite of a growing one.
const List<RadioEpisode> radioA2MoreEpisodes = <RadioEpisode>[
  RadioEpisode(
    id: 'rd-a2-13',
    level: CefrLevel.a2,
    genre: RadioGenre.news,
    title: 'Neue Buslinie sieben',
    lines: <RadioLine>[
      RadioLine(
        german: 'Ab Montag fährt die neue Buslinie sieben zwischen Weidbach und dem Krankenhaus.',
        english: 'From Monday the new bus line seven runs between Weidbach and the hospital.',
      ),
      RadioLine(
        german: 'Der Bus fährt jeden Tag von sechs Uhr bis zweiundzwanzig Uhr.',
        english: 'The bus runs every day from six in the morning until ten at night.',
      ),
      RadioLine(
        german: 'Die Stadt sagt, dass viele Menschen diesen Weg brauchen.',
        english: 'The city says that many people need this route.',
      ),
      RadioLine(
        german: 'Eine Fahrt kostet zwei Euro achtzig.',
        english: 'A single trip costs two euros eighty.',
      ),
      RadioLine(
        german: 'Für Schüler ist die Fahrt billiger.',
        english: 'For pupils the trip is cheaper.',
      ),
      RadioLine(
        german: 'Am Anfang war die Planung schwierig, weil die Straße zu eng war.',
        english: 'At the start the planning was difficult because the street was too narrow.',
      ),
      RadioLine(
        german: 'Jetzt ist der Umbau fertig.',
        english: 'Now the building work is finished.',
      ),
      RadioLine(
        german: 'Mehr Informationen gibt es im Rathaus.',
        english: 'More information is available at the town hall.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was kostet eine Fahrt?',
        options: <String>[
          'zwei Euro fünfzig',
          'zwei Euro achtzig',
          'drei Euro zwanzig',
        ],
        correctIndex: 1,
        explanation: 'Im Text steht: Eine Fahrt kostet zwei Euro achtzig.',
      ),
      ChoiceQuestion(
        prompt: 'Ab wann fährt die Linie sieben?',
        options: <String>[
          'ab Samstag',
          'ab Mittwoch',
          'ab Montag',
        ],
        correctIndex: 2,
        explanation: 'Die Nachricht beginnt mit dem Satz, dass die Linie ab Montag fährt.',
      ),
      ChoiceQuestion(
        prompt: 'Wo bekommt man mehr Informationen?',
        options: <String>[
          'im Rathaus',
          'im Krankenhaus',
          'in der Schule',
        ],
        correctIndex: 0,
        explanation: 'Am Ende heißt es: Mehr Informationen gibt es im Rathaus.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-14',
    level: CefrLevel.a2,
    genre: RadioGenre.weather,
    title: 'Wetter am Dienstag',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Morgen, hier kommt der Wetterbericht für Dienstag.',
        english: 'Good morning, here is the weather report for Tuesday.',
      ),
      RadioLine(
        german: 'Am Vormittag ist es im Norden grau und kühl.',
        english: 'In the morning it is grey and cool in the north.',
      ),
      RadioLine(
        german: 'Im Süden scheint die Sonne schon früh.',
        english: 'In the south the sun shines early on.',
      ),
      RadioLine(
        german: 'Die Temperaturen steigen auf achtzehn Grad.',
        english: 'Temperatures climb to eighteen degrees.',
      ),
      RadioLine(
        german: 'Am Nachmittag regnet es in den Bergen.',
        english: 'In the afternoon it rains in the mountains.',
      ),
      RadioLine(
        german: 'Der Wind wird stärker als gestern.',
        english: 'The wind will be stronger than yesterday.',
      ),
      RadioLine(
        german: 'Nehmen Sie eine Jacke mit, wenn Sie am Abend spazieren gehen.',
        english: 'Take a jacket with you if you go for a walk in the evening.',
      ),
      RadioLine(
        german: 'In der Nacht kühlt es auf neun Grad ab.',
        english: 'Overnight it cools down to nine degrees.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie warm wird es am Tag?',
        options: <String>[
          'sechzehn Grad',
          'achtzehn Grad',
          'einundzwanzig Grad',
        ],
        correctIndex: 1,
        explanation: 'Der Bericht sagt: Die Temperaturen steigen auf achtzehn Grad.',
      ),
      ChoiceQuestion(
        prompt: 'Wo scheint am Morgen die Sonne?',
        options: <String>[
          'im Norden',
          'in den Bergen',
          'im Süden',
        ],
        correctIndex: 2,
        explanation: 'Im Text steht: Im Süden scheint die Sonne schon früh.',
      ),
      ChoiceQuestion(
        prompt: 'Wie kalt wird die Nacht?',
        options: <String>[
          'neun Grad',
          'vier Grad',
          'dreizehn Grad',
        ],
        correctIndex: 0,
        explanation: 'Am Ende heißt es, dass es in der Nacht auf neun Grad abkühlt.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-15',
    level: CefrLevel.a2,
    genre: RadioGenre.announcement,
    title: 'Durchsage im Gartenmarkt',
    lines: <RadioLine>[
      RadioLine(
        german: 'Liebe Kundinnen und Kunden, wir begrüßen Sie im Gartenmarkt Sonnenweg.',
        english: 'Dear customers, welcome to the Sonnenweg garden centre.',
      ),
      RadioLine(
        german: 'Heute bekommen Sie alle Kräuter zwanzig Prozent billiger.',
        english: 'Today all herbs are twenty percent cheaper.',
      ),
      RadioLine(
        german: 'Die Kräuter finden Sie hinten links neben Kasse zwei.',
        english: 'You will find the herbs at the back on the left, next to till two.',
      ),
      RadioLine(
        german: 'Unser Markt schließt heute schon um achtzehn Uhr.',
        english: 'Our shop closes early today, at six in the evening.',
      ),
      RadioLine(
        german: 'Bitte bringen Sie Ihre Pflanzen rechtzeitig zur Kasse.',
        english: 'Please bring your plants to the till in good time.',
      ),
      RadioLine(
        german: 'Am Samstag erklärt unsere Gärtnerin, wie man Tomaten richtig pflanzt.',
        english: 'On Saturday our gardener will explain how to plant tomatoes properly.',
      ),
      RadioLine(
        german: 'Der Kurs beginnt um elf Uhr und ist kostenlos.',
        english: 'The course starts at eleven and is free.',
      ),
      RadioLine(
        german: 'Wir wünschen Ihnen einen schönen Einkauf.',
        english: 'We wish you a pleasant shopping trip.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann schließt der Markt heute?',
        options: <String>[
          'um sechzehn Uhr',
          'um achtzehn Uhr',
          'um zwanzig Uhr',
        ],
        correctIndex: 1,
        explanation: 'In der Durchsage steht: Unser Markt schließt heute schon um achtzehn Uhr.',
      ),
      ChoiceQuestion(
        prompt: 'Was ist heute billiger?',
        options: <String>[
          'die Kräuter',
          'die Töpfe',
          'die Rosen',
        ],
        correctIndex: 0,
        explanation: 'Der Text sagt, dass alle Kräuter heute zwanzig Prozent billiger sind.',
      ),
      ChoiceQuestion(
        prompt: 'Wann beginnt der Kurs am Samstag?',
        options: <String>[
          'um neun Uhr',
          'um dreizehn Uhr',
          'um elf Uhr',
        ],
        correctIndex: 2,
        explanation: 'Im Text heißt es: Der Kurs beginnt um elf Uhr und ist kostenlos.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-16',
    level: CefrLevel.a2,
    genre: RadioGenre.voicemail,
    title: 'Nachricht aus dem Büro',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Tag, hier spricht Frau Kessler von der Firma Lindtal.',
        english: 'Hello, this is Ms Kessler from the Lindtal company.',
      ),
      RadioLine(
        german: 'Ich rufe wegen Ihres Termins am Donnerstag an.',
        english: 'I am calling about your appointment on Thursday.',
      ),
      RadioLine(
        german: 'Leider müssen wir die Besprechung auf Freitag verschieben.',
        english: 'Unfortunately we have to move the meeting to Friday.',
      ),
      RadioLine(
        german: 'Der neue Termin ist um halb zehn im kleinen Sitzungsraum.',
        english: 'The new time is half past nine in the small meeting room.',
      ),
      RadioLine(
        german: 'Bitte bringen Sie die Unterlagen für das Projekt mit.',
        english: 'Please bring the documents for the project with you.',
      ),
      RadioLine(
        german: 'Wenn Freitag nicht passt, rufen Sie mich bitte heute noch zurück.',
        english: 'If Friday does not work, please call me back today.',
      ),
      RadioLine(
        german: 'Meine Nummer ist null acht neun, vier drei drei zwei.',
        english: 'My number is zero eight nine, four three three two.',
      ),
      RadioLine(
        german: 'Vielen Dank und bis bald.',
        english: 'Many thanks and see you soon.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wer spricht auf der Nachricht?',
        options: <String>[
          'Frau Kessler',
          'Frau Lindtal',
          'Herr Kessler',
        ],
        correctIndex: 0,
        explanation: 'Die Nachricht beginnt mit: Hier spricht Frau Kessler von der Firma Lindtal.',
      ),
      ChoiceQuestion(
        prompt: 'Auf welchen Tag verschiebt Frau Kessler die Besprechung?',
        options: <String>[
          'auf Donnerstag',
          'auf Freitag',
          'auf Montag',
        ],
        correctIndex: 1,
        explanation: 'Im Text steht: Leider müssen wir die Besprechung auf Freitag verschieben.',
      ),
      ChoiceQuestion(
        prompt: 'Wann ist der neue Termin?',
        options: <String>[
          'um halb acht',
          'um halb elf',
          'um halb zehn',
        ],
        correctIndex: 2,
        explanation: 'Frau Kessler sagt, dass der neue Termin um halb zehn im kleinen Sitzungsraum ist.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-17',
    level: CefrLevel.a2,
    genre: RadioGenre.recipe,
    title: 'Gemüsepfanne mit Reis',
    lines: <RadioLine>[
      RadioLine(
        german: 'Für diese Gemüsepfanne brauchen Sie Reis, zwei Karotten und eine Zucchini.',
        english: 'For this vegetable pan you need rice, two carrots and one courgette.',
      ),
      RadioLine(
        german: 'Kochen Sie zuerst den Reis in Salzwasser.',
        english: 'First cook the rice in salted water.',
      ),
      RadioLine(
        german: 'Waschen Sie das Gemüse und schneiden Sie es klein.',
        english: 'Wash the vegetables and cut them into small pieces.',
      ),
      RadioLine(
        german: 'Geben Sie etwas Öl in die Pfanne.',
        english: 'Put a little oil in the frying pan.',
      ),
      RadioLine(
        german: 'Braten Sie die Karotten zuerst, weil sie länger brauchen.',
        english: 'Fry the carrots first, because they take longer.',
      ),
      RadioLine(
        german: 'Nach fünf Minuten kommt die Zucchini dazu.',
        english: 'After five minutes add the courgette.',
      ),
      RadioLine(
        german: 'Mischen Sie den Reis unter das Gemüse.',
        english: 'Stir the rice into the vegetables.',
      ),
      RadioLine(
        german: 'Das Essen ist in etwa zwanzig Minuten fertig.',
        english: 'The meal is ready in about twenty minutes.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was kocht man zuerst?',
        options: <String>[
          'das Gemüse',
          'den Reis',
          'die Zucchini',
        ],
        correctIndex: 1,
        explanation: 'Im Rezept steht: Kochen Sie zuerst den Reis in Salzwasser.',
      ),
      ChoiceQuestion(
        prompt: 'Warum brät man die Karotten zuerst?',
        options: <String>[
          'weil sie länger brauchen',
          'weil sie süßer sind',
          'weil sie kleiner sind',
        ],
        correctIndex: 0,
        explanation: 'Der Text sagt: Braten Sie die Karotten zuerst, weil sie länger brauchen.',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange dauert es, bis das Essen fertig ist?',
        options: <String>[
          'etwa zehn Minuten',
          'etwa dreißig Minuten',
          'etwa zwanzig Minuten',
        ],
        correctIndex: 2,
        explanation: 'Am Ende heißt es, dass das Essen in etwa zwanzig Minuten fertig ist.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-18',
    level: CefrLevel.a2,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Das Wasserrad in Lindbach',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen in der alten Mühle von Lindbach.',
        english: 'Welcome to the old mill in Lindbach.',
      ),
      RadioLine(
        german: 'Sie stehen jetzt im Erdgeschoss vor dem großen Wasserrad.',
        english: 'You are now on the ground floor in front of the big water wheel.',
      ),
      RadioLine(
        german: 'Das Rad ist über vier Meter hoch.',
        english: 'The wheel is more than four metres high.',
      ),
      RadioLine(
        german: 'Früher haben hier drei Familien gearbeitet und Mehl gemahlen.',
        english: 'Three families used to work here, grinding flour.',
      ),
      RadioLine(
        german: 'Die Mühle war bis 1974 in Betrieb.',
        english: 'The mill stayed in operation until 1974.',
      ),
      RadioLine(
        german: 'Im ersten Stock sehen Sie alte Werkzeuge und Fotos.',
        english: 'On the first floor you can see old tools and photographs.',
      ),
      RadioLine(
        german: 'Gehen Sie bitte langsam, weil die Treppe sehr schmal ist.',
        english: 'Please walk slowly, because the staircase is very narrow.',
      ),
      RadioLine(
        german: 'Der Rundgang dauert etwa zwanzig Minuten.',
        english: 'The tour takes about twenty minutes.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie hoch ist das Wasserrad?',
        options: <String>[
          'Über zwei Meter',
          'Über vier Meter',
          'Über sechs Meter',
        ],
        correctIndex: 1,
        explanation: 'Der Audioguide sagt, dass das Rad über vier Meter hoch ist.',
      ),
      ChoiceQuestion(
        prompt: 'Was sieht man im ersten Stock?',
        options: <String>[
          'Ein Café und einen Shop',
          'Säcke mit Mehl',
          'Alte Werkzeuge und Fotos',
        ],
        correctIndex: 2,
        explanation: 'Im ersten Stock sehen Sie alte Werkzeuge und Fotos.',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange dauert der Rundgang?',
        options: <String>[
          'Etwa zwanzig Minuten',
          'Etwa dreißig Minuten',
          'Etwa vierzig Minuten',
        ],
        correctIndex: 0,
        explanation: 'Der Rundgang dauert etwa zwanzig Minuten.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-19',
    level: CefrLevel.a2,
    genre: RadioGenre.lecture,
    title: 'Warum Brot aufgeht',
    lines: <RadioLine>[
      RadioLine(
        german: 'Heute erkläre ich kurz, warum Brot im Ofen aufgeht.',
        english: 'Today I will briefly explain why bread rises in the oven.',
      ),
      RadioLine(
        german: 'Im Teig sind Hefe, Mehl, Wasser und ein wenig Zucker.',
        english: 'The dough contains yeast, flour, water and a little sugar.',
      ),
      RadioLine(
        german: 'Die Hefe frisst den Zucker und macht kleine Gasblasen.',
        english: 'The yeast feeds on the sugar and produces small bubbles of gas.',
      ),
      RadioLine(
        german: 'Diese Blasen bleiben im Teig und drücken ihn nach oben.',
        english: 'These bubbles stay in the dough and push it upwards.',
      ),
      RadioLine(
        german: 'Wenn der Teig warm steht, arbeitet die Hefe schneller.',
        english: 'When the dough is kept somewhere warm, the yeast works faster.',
      ),
      RadioLine(
        german: 'Im Ofen wird das Gas heiß und der Teig wächst noch einmal.',
        english: 'In the oven the gas gets hot and the dough grows once more.',
      ),
      RadioLine(
        german: 'Danach wird die Kruste fest, und das Brot behält seine Form.',
        english: 'After that the crust hardens and the loaf keeps its shape.',
      ),
      RadioLine(
        german: 'Deshalb dauert gutes Brot mehrere Stunden.',
        english: 'That is why good bread takes several hours.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was macht die Hefe im Teig?',
        options: <String>[
          'Sie frisst den Zucker',
          'Sie trocknet das Mehl',
          'Sie kühlt das Wasser',
        ],
        correctIndex: 0,
        explanation: 'Die Hefe frisst den Zucker und macht kleine Gasblasen.',
      ),
      ChoiceQuestion(
        prompt: 'Wann arbeitet die Hefe schneller?',
        options: <String>[
          'Wenn der Teig kalt steht',
          'Wenn der Teig warm steht',
          'Wenn der Teig lange ruht',
        ],
        correctIndex: 1,
        explanation: 'Wenn der Teig warm steht, arbeitet die Hefe schneller.',
      ),
      ChoiceQuestion(
        prompt: 'Was passiert mit dem Teig im Ofen?',
        options: <String>[
          'Er wird kleiner',
          'Er bleibt gleich',
          'Er wächst noch einmal',
        ],
        correctIndex: 2,
        explanation: 'Im Ofen wird das Gas heiß und der Teig wächst noch einmal.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-20',
    level: CefrLevel.a2,
    genre: RadioGenre.diary,
    title: 'Abende im Chor',
    lines: <RadioLine>[
      RadioLine(
        german: 'Seit März singe ich jeden Mittwoch in einem kleinen Chor.',
        english: 'Since March I have been singing every Wednesday in a small choir.',
      ),
      RadioLine(
        german: 'Die Proben sind in der Schule neben dem Bahnhof.',
        english: 'The rehearsals take place in the school next to the station.',
      ),
      RadioLine(
        german: 'Am Anfang war ich sehr nervös, weil ich keine Noten lesen konnte.',
        english: 'At first I was very nervous, because I could not read music.',
      ),
      RadioLine(
        german: 'Unsere Leiterin Frau Kern hat mir sehr geholfen.',
        english: 'Our director, Ms Kern, gave me a lot of help.',
      ),
      RadioLine(
        german: 'Jetzt kenne ich schon zwölf Lieder auswendig.',
        english: 'By now I know twelve songs by heart.',
      ),
      RadioLine(
        german: 'Nach der Probe gehen wir oft noch in ein Lokal.',
        english: 'After rehearsal we often go on to a pub.',
      ),
      RadioLine(
        german: 'Im Dezember singen wir zum ersten Mal vor Publikum.',
        english: 'In December we will sing in front of an audience for the first time.',
      ),
      RadioLine(
        german: 'Ich freue mich darauf, aber ich schlafe davor bestimmt schlecht.',
        english: 'I am looking forward to it, though I am sure I will sleep badly the night before.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann sind die Proben?',
        options: <String>[
          'Jeden Montag',
          'Jeden Mittwoch',
          'Jeden Freitag',
        ],
        correctIndex: 1,
        explanation: 'Seit März singt sie jeden Mittwoch im Chor.',
      ),
      ChoiceQuestion(
        prompt: 'Warum war sie am Anfang nervös?',
        options: <String>[
          'Weil sie den Bus verpasst hat',
          'Weil sie den Chor nicht kannte',
          'Weil sie keine Noten lesen konnte',
        ],
        correctIndex: 2,
        explanation: 'Am Anfang war sie nervös, weil sie keine Noten lesen konnte.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viele Lieder kann sie auswendig?',
        options: <String>[
          'Zwölf',
          'Zwanzig',
          'Zwei',
        ],
        correctIndex: 0,
        explanation: 'Jetzt kennt sie schon zwölf Lieder auswendig.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-21',
    level: CefrLevel.a2,
    genre: RadioGenre.news,
    title: 'Buslinie 9 fährt länger',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Morgen, hier sind die Nachrichten aus Talheim.',
        english: 'Good morning, here is the news from Talheim.',
      ),
      RadioLine(
        german: 'Ab dem ersten Oktober fährt die Buslinie 9 bis zum Klinikum.',
        english: 'From the first of October, bus route 9 will run all the way to the hospital.',
      ),
      RadioLine(
        german: 'Die Strecke wird also um drei Kilometer länger.',
        english: 'The route will therefore be three kilometres longer.',
      ),
      RadioLine(
        german: 'Die Busse fahren montags bis freitags alle zwanzig Minuten.',
        english: 'From Monday to Friday the buses run every twenty minutes.',
      ),
      RadioLine(
        german: 'Am Wochenende bleibt der Takt bei einer Stunde.',
        english: 'At weekends the service stays hourly.',
      ),
      RadioLine(
        german: 'Die Stadt sagt, dass rund viertausend Menschen davon profitieren.',
        english: 'The city says around four thousand people will benefit from it.',
      ),
      RadioLine(
        german: 'Die neuen Fahrpläne liegen ab Montag im Rathaus aus.',
        english: 'The new timetables will be available at the town hall from Monday.',
      ),
      RadioLine(
        german: 'Mehr dazu hören Sie um zwölf Uhr.',
        english: 'You can hear more about this at twelve o\'clock.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Ab wann fährt die Linie 9 zum Klinikum?',
        options: <String>[
          'Ab dem ersten Oktober',
          'Ab dem ersten November',
          'Ab dem ersten Dezember',
        ],
        correctIndex: 0,
        explanation: 'Ab dem ersten Oktober fährt die Buslinie 9 bis zum Klinikum.',
      ),
      ChoiceQuestion(
        prompt: 'Wie oft fahren die Busse von Montag bis Freitag?',
        options: <String>[
          'Alle zehn Minuten',
          'Alle zwanzig Minuten',
          'Alle sechzig Minuten',
        ],
        correctIndex: 1,
        explanation: 'Montags bis freitags fahren die Busse alle zwanzig Minuten.',
      ),
      ChoiceQuestion(
        prompt: 'Wo bekommt man die neuen Fahrpläne?',
        options: <String>[
          'Im Klinikum',
          'Am Bahnhof',
          'Im Rathaus',
        ],
        correctIndex: 2,
        explanation: 'Die neuen Fahrpläne liegen ab Montag im Rathaus aus.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-22',
    level: CefrLevel.a2,
    genre: RadioGenre.announcement,
    title: 'Durchsage auf der Fähre',
    lines: <RadioLine>[
      RadioLine(
        german: 'Liebe Fahrgäste, willkommen an Bord der Fähre nach Seeburg.',
        english: 'Dear passengers, welcome aboard the ferry to Seeburg.',
      ),
      RadioLine(
        german: 'Die Fahrt dauert heute etwa vierzig Minuten.',
        english: 'Today the crossing takes about forty minutes.',
      ),
      RadioLine(
        german: 'Bitte bleiben Sie auf dem Oberdeck sitzen, wenn der Wind stärker wird.',
        english: 'Please stay seated on the upper deck if the wind picks up.',
      ),
      RadioLine(
        german: 'Im Salon auf dem Unterdeck gibt es warme Getränke und Kuchen.',
        english: 'Hot drinks and cake are available in the lounge on the lower deck.',
      ),
      RadioLine(
        german: 'Die Toiletten finden Sie hinten links.',
        english: 'The toilets are at the back on the left.',
      ),
      RadioLine(
        german: 'Wir kommen um 15.20 Uhr in Seeburg an.',
        english: 'We will arrive in Seeburg at twenty past three.',
      ),
      RadioLine(
        german: 'Bitte nehmen Sie Ihr Gepäck beim Aussteigen mit.',
        english: 'Please take your luggage with you when you get off.',
      ),
      RadioLine(
        german: 'Wir wünschen Ihnen eine gute Fahrt.',
        english: 'We wish you a pleasant journey.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie lange dauert die Fahrt?',
        options: <String>[
          'Etwa zwanzig Minuten',
          'Etwa vierzig Minuten',
          'Etwa sechzig Minuten',
        ],
        correctIndex: 1,
        explanation: 'Die Fahrt dauert heute etwa vierzig Minuten.',
      ),
      ChoiceQuestion(
        prompt: 'Wo gibt es warme Getränke?',
        options: <String>[
          'Im Salon auf dem Unterdeck',
          'Im Kiosk auf dem Oberdeck',
          'Am Steg in Seeburg',
        ],
        correctIndex: 0,
        explanation: 'Im Salon auf dem Unterdeck gibt es warme Getränke und Kuchen.',
      ),
      ChoiceQuestion(
        prompt: 'Wann kommt die Fähre in Seeburg an?',
        options: <String>[
          'Um 14.20 Uhr',
          'Um 14.50 Uhr',
          'Um 15.20 Uhr',
        ],
        correctIndex: 2,
        explanation: 'Die Durchsage sagt, dass die Fähre um 15.20 Uhr in Seeburg ankommt.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-23',
    level: CefrLevel.a2,
    genre: RadioGenre.recipe,
    title: 'Nudelsalat für den Ausflug',
    lines: <RadioLine>[
      RadioLine(
        german: 'Heute machen wir einen einfachen Nudelsalat für einen Ausflug.',
        english: 'Today we are making a simple pasta salad for a day trip.',
      ),
      RadioLine(
        german: 'Kochen Sie zuerst dreihundert Gramm Nudeln in Salzwasser.',
        english: 'First cook three hundred grams of pasta in salted water.',
      ),
      RadioLine(
        german: 'Waschen Sie zwei Tomaten und eine kleine Gurke.',
        english: 'Wash two tomatoes and one small cucumber.',
      ),
      RadioLine(
        german: 'Schneiden Sie das Gemüse in kleine Stücke.',
        english: 'Cut the vegetables into small pieces.',
      ),
      RadioLine(
        german: 'Mischen Sie danach Öl, Essig, Salz und Pfeffer.',
        english: 'After that, mix oil, vinegar, salt and pepper.',
      ),
      RadioLine(
        german: 'Geben Sie alles zusammen in eine große Schüssel.',
        english: 'Put everything together into a large bowl.',
      ),
      RadioLine(
        german: 'Der Salat schmeckt besser, wenn er eine Stunde im Kühlschrank steht.',
        english: 'The salad tastes better if it sits in the fridge for an hour.',
      ),
      RadioLine(
        german: 'Nehmen Sie ihn morgen früh mit, weil er kalt am besten schmeckt.',
        english: 'Take it along tomorrow morning, because it tastes best cold.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie lange soll der Salat im Kühlschrank stehen?',
        options: <String>[
          'Eine halbe Stunde',
          'Eine Stunde',
          'Zwei Stunden',
        ],
        correctIndex: 1,
        explanation: 'Im Text heißt es: Der Salat schmeckt besser, wenn er eine Stunde im Kühlschrank steht.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viele Nudeln braucht man?',
        options: <String>[
          'Zweihundert Gramm',
          'Fünfhundert Gramm',
          'Dreihundert Gramm',
        ],
        correctIndex: 2,
        explanation: 'Es heißt: Kochen Sie zuerst dreihundert Gramm Nudeln in Salzwasser.',
      ),
      ChoiceQuestion(
        prompt: 'Welches Gemüse kommt in den Salat?',
        options: <String>[
          'Tomaten und Gurke',
          'Karotten und Zwiebeln',
          'Paprika und Erbsen',
        ],
        correctIndex: 0,
        explanation: 'Der Text sagt: Waschen Sie zwei Tomaten und eine kleine Gurke.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-24',
    level: CefrLevel.a2,
    genre: RadioGenre.voicemail,
    title: 'Anruf vom Kursbüro',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Tag, hier spricht Frau Bergmann vom Kursbüro Wiesental.',
        english: 'Hello, this is Ms Bergmann from the Wiesental course office.',
      ),
      RadioLine(
        german: 'Ich rufe an, weil sich Ihr Kurs am Dienstag geändert hat.',
        english: 'I am calling because your Tuesday course has changed.',
      ),
      RadioLine(
        german: 'Der Unterricht beginnt jetzt um achtzehn Uhr statt um siebzehn Uhr.',
        english: 'The class now starts at six in the evening instead of five.',
      ),
      RadioLine(
        german: 'Wir treffen uns außerdem in Raum vier im ersten Stock.',
        english: 'We are also meeting in room four on the first floor.',
      ),
      RadioLine(
        german: 'Bitte bringen Sie das neue Buch und ein Wörterbuch mit.',
        english: 'Please bring the new book and a dictionary with you.',
      ),
      RadioLine(
        german: 'Die Rechnung für den Kurs kommt nächste Woche per Post.',
        english: 'The invoice for the course will arrive by mail next week.',
      ),
      RadioLine(
        german: 'Rufen Sie mich bitte zurück, wenn der neue Termin nicht passt.',
        english: 'Please call me back if the new time does not suit you.',
      ),
      RadioLine(
        german: 'Schönen Tag noch und bis Dienstag.',
        english: 'Have a nice day and see you on Tuesday.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann beginnt der Unterricht jetzt?',
        options: <String>[
          'Um sechzehn Uhr',
          'Um siebzehn Uhr',
          'Um achtzehn Uhr',
        ],
        correctIndex: 2,
        explanation: 'Frau Bergmann sagt: Der Unterricht beginnt jetzt um achtzehn Uhr statt um siebzehn Uhr.',
      ),
      ChoiceQuestion(
        prompt: 'Wo findet der Kurs statt?',
        options: <String>[
          'In Raum zwei im Erdgeschoss',
          'In Raum vier im ersten Stock',
          'In Raum vier im dritten Stock',
        ],
        correctIndex: 1,
        explanation: 'Im Text heißt es: Wir treffen uns außerdem in Raum vier im ersten Stock.',
      ),
      ChoiceQuestion(
        prompt: 'Was soll man mitbringen?',
        options: <String>[
          'Das neue Buch und ein Wörterbuch',
          'Ein Heft und einen Stift',
          'Die Rechnung und den Ausweis',
        ],
        correctIndex: 0,
        explanation: 'Sie sagt: Bitte bringen Sie das neue Buch und ein Wörterbuch mit.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-25',
    level: CefrLevel.a2,
    genre: RadioGenre.weather,
    title: 'Wetterbericht für morgen',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Abend, hier ist der Wetterbericht für morgen.',
        english: 'Good evening, here is the weather forecast for tomorrow.',
      ),
      RadioLine(
        german: 'Am Vormittag ist es im Norden bewölkt und ziemlich kühl.',
        english: 'In the morning it will be cloudy and rather cool in the north.',
      ),
      RadioLine(
        german: 'Im Süden scheint die Sonne, aber der Wind bleibt stark.',
        english: 'In the south the sun will shine, but the wind stays strong.',
      ),
      RadioLine(
        german: 'Die Temperaturen liegen zwischen zwölf und achtzehn Grad.',
        english: 'Temperatures will be between twelve and eighteen degrees.',
      ),
      RadioLine(
        german: 'Am Nachmittag regnet es in der Mitte des Landes.',
        english: 'In the afternoon it will rain in the centre of the country.',
      ),
      RadioLine(
        german: 'In den Bergen wird es kälter als im Tal.',
        english: 'In the mountains it will get colder than down in the valley.',
      ),
      RadioLine(
        german: 'Nehmen Sie einen Schirm mit, wenn Sie am Abend spazieren gehen.',
        english: 'Take an umbrella with you if you go for a walk in the evening.',
      ),
      RadioLine(
        german: 'Am Wochenende wird das Wetter wieder freundlicher.',
        english: 'At the weekend the weather will turn nicer again.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie ist das Wetter am Vormittag im Norden?',
        options: <String>[
          'Sonnig und warm',
          'Bewölkt und kühl',
          'Neblig und mild',
        ],
        correctIndex: 1,
        explanation: 'Im Bericht heißt es: Am Vormittag ist es im Norden bewölkt und ziemlich kühl.',
      ),
      ChoiceQuestion(
        prompt: 'Wie warm wird es morgen?',
        options: <String>[
          'Zwischen zwei und acht Grad',
          'Zwischen zwanzig und sechsundzwanzig Grad',
          'Zwischen zwölf und achtzehn Grad',
        ],
        correctIndex: 2,
        explanation: 'Der Text sagt: Die Temperaturen liegen zwischen zwölf und achtzehn Grad.',
      ),
      ChoiceQuestion(
        prompt: 'Wo regnet es am Nachmittag?',
        options: <String>[
          'In der Mitte des Landes',
          'An der Küste im Norden',
          'In den Bergen im Süden',
        ],
        correctIndex: 0,
        explanation: 'Es heißt: Am Nachmittag regnet es in der Mitte des Landes.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-26',
    level: CefrLevel.a2,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Die Mühle von Talheim',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen an der alten Mühle von Talheim.',
        english: 'Welcome to the old mill of Talheim.',
      ),
      RadioLine(
        german: 'Die Mühle steht seit über zweihundert Jahren am kleinen Fluss.',
        english: 'The mill has stood by the small river for more than two hundred years.',
      ),
      RadioLine(
        german: 'Früher haben die Bauern hier ihr Getreide zu Mehl gemahlen.',
        english: 'In the past, farmers ground their grain into flour here.',
      ),
      RadioLine(
        german: 'Vor Ihnen sehen Sie das große Rad aus Holz.',
        english: 'In front of you, you can see the large wooden wheel.',
      ),
      RadioLine(
        german: 'Es dreht sich nur noch am Sonntag für die Gäste.',
        english: 'It only turns on Sundays now, for the visitors.',
      ),
      RadioLine(
        german: 'Im Erdgeschoss gibt es eine kleine Ausstellung über die Arbeit der Müller.',
        english: 'On the ground floor there is a small exhibition about the millers\' work.',
      ),
      RadioLine(
        german: 'Gehen Sie danach nach oben, weil man von dort das Tal gut sieht.',
        english: 'Go upstairs afterwards, because from there you get a good view of the valley.',
      ),
      RadioLine(
        german: 'Der Rundgang dauert etwa zwanzig Minuten.',
        english: 'The tour takes about twenty minutes.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie alt ist die Mühle?',
        options: <String>[
          'Etwa hundert Jahre',
          'Über zweihundert Jahre',
          'Über dreihundert Jahre',
        ],
        correctIndex: 1,
        explanation: 'Im Audioguide heißt es: Die Mühle steht seit über zweihundert Jahren am kleinen Fluss.',
      ),
      ChoiceQuestion(
        prompt: 'Wann dreht sich das große Rad?',
        options: <String>[
          'Jeden Tag',
          'Am Samstag',
          'Am Sonntag',
        ],
        correctIndex: 2,
        explanation: 'Der Text sagt: Es dreht sich nur noch am Sonntag für die Gäste.',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange dauert der Rundgang?',
        options: <String>[
          'Etwa zwanzig Minuten',
          'Etwa zehn Minuten',
          'Etwa vierzig Minuten',
        ],
        correctIndex: 0,
        explanation: 'Am Ende heißt es: Der Rundgang dauert etwa zwanzig Minuten.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-27',
    level: CefrLevel.a2,
    genre: RadioGenre.lecture,
    title: 'Warum Straßen Löcher bekommen',
    lines: <RadioLine>[
      RadioLine(
        german: 'Heute erkläre ich kurz, warum Straßen im Winter oft Löcher bekommen.',
        english: 'Today I will briefly explain why roads often get holes in winter.',
      ),
      RadioLine(
        german: 'Nach dem Regen liegt Wasser in kleinen Rissen im Asphalt.',
        english: 'After the rain, water sits in small cracks in the asphalt.',
      ),
      RadioLine(
        german: 'In der Nacht wird es kalt, und das Wasser gefriert.',
        english: 'At night it gets cold, and the water freezes.',
      ),
      RadioLine(
        german: 'Eis braucht mehr Platz als Wasser.',
        english: 'Ice needs more room than water.',
      ),
      RadioLine(
        german: 'Deshalb wird der Riss jeden Tag ein bisschen größer.',
        english: 'That is why the crack gets a little bigger every day.',
      ),
      RadioLine(
        german: 'Dann fahren viele Autos darüber, und der Asphalt bricht.',
        english: 'Then a lot of cars drive over it, and the asphalt breaks.',
      ),
      RadioLine(
        german: 'Im Frühling reparieren die Arbeiter die Löcher mit warmem Asphalt.',
        english: 'In spring the workers repair the holes with warm asphalt.',
      ),
      RadioLine(
        german: 'Sie kommen oft im März, weil der Boden dann trocken ist.',
        english: 'They often come in March, because the ground is dry by then.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was passiert in der Nacht mit dem Wasser?',
        options: <String>[
          'Es gefriert.',
          'Es wird warm.',
          'Es verschwindet.',
        ],
        correctIndex: 0,
        explanation: 'Im Text heißt es: In der Nacht wird es kalt, und das Wasser gefriert.',
      ),
      ChoiceQuestion(
        prompt: 'Wann reparieren die Arbeiter die Löcher?',
        options: <String>[
          'Im Winter',
          'Im Frühling',
          'Im Sommer',
        ],
        correctIndex: 1,
        explanation: 'Der Text sagt: Im Frühling reparieren die Arbeiter die Löcher mit warmem Asphalt.',
      ),
      ChoiceQuestion(
        prompt: 'Warum kommen die Arbeiter oft im März?',
        options: <String>[
          'Weil dann viele Autos fahren.',
          'Weil der Asphalt kalt ist.',
          'Weil der Boden trocken ist.',
        ],
        correctIndex: 2,
        explanation: 'Sie kommen oft im März, weil der Boden dann trocken ist.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-28',
    level: CefrLevel.a2,
    genre: RadioGenre.diary,
    title: 'Meine erste Fahrstunde',
    lines: <RadioLine>[
      RadioLine(
        german: 'Heute hatte ich meine erste Fahrstunde.',
        english: 'Today I had my first driving lesson.',
      ),
      RadioLine(
        german: 'Der Fahrlehrer heißt Herr Brandner und war sehr ruhig.',
        english: 'The driving instructor is called Mr Brandner, and he was very calm.',
      ),
      RadioLine(
        german: 'Wir sind zuerst auf einen leeren Parkplatz gefahren.',
        english: 'First we drove to an empty car park.',
      ),
      RadioLine(
        german: 'Am Anfang war ich sehr nervös, weil alles neu war.',
        english: 'At the start I was very nervous, because everything was new.',
      ),
      RadioLine(
        german: 'Nach zwanzig Minuten habe ich mich langsam entspannt.',
        english: 'After twenty minutes I slowly relaxed.',
      ),
      RadioLine(
        german: 'Danach sind wir durch die kleinen Straßen im Ortsteil Weiden gefahren.',
        english: 'After that we drove through the small streets in the Weiden district.',
      ),
      RadioLine(
        german: 'Das Einparken war schwerer als das Fahren.',
        english: 'Parking was harder than driving.',
      ),
      RadioLine(
        german: 'Nächsten Dienstag um sechzehn Uhr habe ich die zweite Stunde.',
        english: 'Next Tuesday at four in the afternoon I have my second lesson.',
      ),
      RadioLine(
        german: 'Ich freue mich schon darauf.',
        english: 'I am already looking forward to it.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie heißt der Fahrlehrer?',
        options: <String>[
          'Herr Brandner',
          'Herr Weidner',
          'Herr Kastner',
        ],
        correctIndex: 0,
        explanation: 'Im Text steht: Der Fahrlehrer heißt Herr Brandner und war sehr ruhig.',
      ),
      ChoiceQuestion(
        prompt: 'Was war schwerer als das Fahren?',
        options: <String>[
          'Das Bremsen',
          'Das Einparken',
          'Das Warten',
        ],
        correctIndex: 1,
        explanation: 'Der Text sagt: Das Einparken war schwerer als das Fahren.',
      ),
      ChoiceQuestion(
        prompt: 'Wann ist die zweite Fahrstunde?',
        options: <String>[
          'Am Montag um sechzehn Uhr',
          'Am Dienstag um achtzehn Uhr',
          'Am Dienstag um sechzehn Uhr',
        ],
        correctIndex: 2,
        explanation: 'Nächsten Dienstag um sechzehn Uhr hat die Sprecherin die zweite Stunde.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-29',
    level: CefrLevel.a2,
    genre: RadioGenre.news,
    title: 'Neue Buslinie ab Montag',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Morgen, hier sind die Nachrichten aus Ellwitz.',
        english: 'Good morning, here is the news from Ellwitz.',
      ),
      RadioLine(
        german: 'Ab Montag fährt die neue Buslinie zwölf vom Bahnhof zum Krankenhaus.',
        english: 'From Monday the new bus line twelve runs from the station to the hospital.',
      ),
      RadioLine(
        german: 'Die Busse fahren werktags alle zwanzig Minuten.',
        english: 'On weekdays the buses run every twenty minutes.',
      ),
      RadioLine(
        german: 'Eine Einzelfahrt kostet zwei Euro achtzig.',
        english: 'A single ticket costs two euros eighty.',
      ),
      RadioLine(
        german: 'Die Stadt sagt, dass am ersten Tag alle Fahrten kostenlos sind.',
        english: 'The city says that all rides are free on the first day.',
      ),
      RadioLine(
        german: 'Die Stadtbibliothek bleibt diese Woche wegen Bauarbeiten geschlossen.',
        english: 'The town library stays closed this week because of building work.',
      ),
      RadioLine(
        german: 'Sie öffnet am Samstag wieder um neun Uhr.',
        english: 'It opens again on Saturday at nine.',
      ),
      RadioLine(
        german: 'Das Wetter bleibt heute trocken und wird etwas wärmer als gestern.',
        english: 'The weather stays dry today and turns a bit warmer than yesterday.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie viel kostet eine Einzelfahrt?',
        options: <String>[
          'Zwei Euro fünfzig',
          'Zwei Euro achtzig',
          'Drei Euro achtzig',
        ],
        correctIndex: 1,
        explanation: 'Im Text steht: Eine Einzelfahrt kostet zwei Euro achtzig.',
      ),
      ChoiceQuestion(
        prompt: 'Wann öffnet die Bibliothek wieder?',
        options: <String>[
          'Am Samstag',
          'Am Montag',
          'Am Freitag',
        ],
        correctIndex: 0,
        explanation: 'Die Bibliothek öffnet am Samstag wieder um neun Uhr.',
      ),
      ChoiceQuestion(
        prompt: 'Wohin fährt die neue Buslinie vom Bahnhof?',
        options: <String>[
          'Zum Rathaus',
          'Zur Bibliothek',
          'Zum Krankenhaus',
        ],
        correctIndex: 2,
        explanation: 'Die neue Buslinie zwölf fährt vom Bahnhof zum Krankenhaus.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a2-30',
    level: CefrLevel.a2,
    genre: RadioGenre.announcement,
    title: 'Durchsage im Tierpark',
    lines: <RadioLine>[
      RadioLine(
        german: 'Liebe Besucherinnen und Besucher, willkommen im Tierpark Hardenau.',
        english: 'Dear visitors, welcome to the Hardenau wildlife park.',
      ),
      RadioLine(
        german: 'Die Fütterung der Seehunde beginnt in zehn Minuten am großen Becken.',
        english: 'The seal feeding starts in ten minutes at the big pool.',
      ),
      RadioLine(
        german: 'Der Weg dorthin ist mit blauen Schildern markiert.',
        english: 'The way there is marked with blue signs.',
      ),
      RadioLine(
        german: 'Bitte geben Sie den Tieren kein eigenes Futter.',
        english: 'Please do not give the animals any food of your own.',
      ),
      RadioLine(
        german: 'Das Café am Teich schließt heute schon um sechzehn Uhr.',
        english: 'The cafe by the pond closes early today, at four in the afternoon.',
      ),
      RadioLine(
        german: 'Der Tierpark schließt um achtzehn Uhr.',
        english: 'The wildlife park closes at six in the evening.',
      ),
      RadioLine(
        german: 'Wenn Sie Hilfe brauchen, finden Sie uns am Eingang.',
        english: 'If you need help, you will find us at the entrance.',
      ),
      RadioLine(
        german: 'Wir wünschen Ihnen einen schönen Nachmittag.',
        english: 'We wish you a pleasant afternoon.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was beginnt in zehn Minuten?',
        options: <String>[
          'Die Führung durch das Haus',
          'Die Fütterung der Seehunde',
          'Die Reinigung der Wege',
        ],
        correctIndex: 1,
        explanation: 'Die Durchsage sagt: Die Fütterung der Seehunde beginnt in zehn Minuten.',
      ),
      ChoiceQuestion(
        prompt: 'Wann schließt das Café am Teich?',
        options: <String>[
          'Um sechzehn Uhr',
          'Um siebzehn Uhr',
          'Um achtzehn Uhr',
        ],
        correctIndex: 0,
        explanation: 'Das Café am Teich schließt heute schon um sechzehn Uhr.',
      ),
      ChoiceQuestion(
        prompt: 'Wo finden die Gäste Hilfe?',
        options: <String>[
          'Am großen Becken',
          'Im Café am Teich',
          'Am Eingang',
        ],
        correctIndex: 2,
        explanation: 'Wenn Sie Hilfe brauchen, finden Sie uns am Eingang.',
      ),
    ],
  ),
];
