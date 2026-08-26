import 'models.dart';
import 'radio.dart';

/// A2 Gartenradio scripts.
///
/// Longer sentences than A1, past tense and modal verbs appear, and the
/// subject matter moves beyond the immediate household. English still runs
/// beside every line. Original text written for this app.
const List<RadioEpisode> radioA2Episodes = <RadioEpisode>[
  RadioEpisode(
    id: 'gr-a2-03',
    level: CefrLevel.a2,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Das Stadtmuseum',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen im Stadtmuseum. Sie stehen im ersten Raum.',
        english: 'Welcome to the city museum. You are standing in the first room.',
      ),
      RadioLine(
        german: 'Hier sehen Sie Bilder aus dem letzten Jahrhundert.',
        english: 'Here you see pictures from the last century.',
      ),
      RadioLine(
        german: 'Die Stadt war damals viel kleiner als heute.',
        english: 'The city was much smaller then than it is today.',
      ),
      RadioLine(
        german: 'Nur zehntausend Menschen haben hier gewohnt.',
        english: 'Only ten thousand people lived here.',
      ),
      RadioLine(
        german: 'Die meisten haben in der Fabrik am Fluss gearbeitet.',
        english: 'Most of them worked in the factory by the river.',
      ),
      RadioLine(
        german: 'Die Fabrik hat vor vierzig Jahren geschlossen.',
        english: 'The factory closed forty years ago.',
      ),
      RadioLine(
        german: 'Im nächsten Raum geht die Geschichte weiter.',
        english: 'The story continues in the next room.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie viele Menschen haben damals in der Stadt gewohnt?',
        options: <String>['Tausend', 'Zehntausend', 'Hunderttausend'],
        correctIndex: 1,
        explanation: 'Nur zehntausend Menschen haben hier gewohnt.',
      ),
      ChoiceQuestion(
        prompt: 'Wo haben die meisten Menschen gearbeitet?',
        options: <String>[
          'In der Fabrik am Fluss',
          'Im Museum',
          'Auf dem Markt',
        ],
        correctIndex: 0,
        explanation: 'Die meisten haben in der Fabrik am Fluss gearbeitet.',
      ),
      ChoiceQuestion(
        prompt: 'Wann hat die Fabrik geschlossen?',
        options: <String>[
          'Vor vier Jahren',
          'Vor vierzig Jahren',
          'Vor hundert Jahren',
        ],
        correctIndex: 1,
        explanation: 'Die Fabrik hat vor vierzig Jahren geschlossen.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'gr-a2-04',
    level: CefrLevel.a2,
    genre: RadioGenre.voicemail,
    title: 'Nachricht über eine Wohnung',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Tag, Frau Sander, hier ist das Immobilienbüro.',
        english: 'Hello Mrs Sander, this is the estate agency.',
      ),
      RadioLine(
        german: 'Wir haben eine Wohnung für Sie gefunden.',
        english: 'We have found a flat for you.',
      ),
      RadioLine(
        german: 'Sie hat drei Zimmer und liegt im zweiten Stock.',
        english: 'It has three rooms and is on the second floor.',
      ),
      RadioLine(
        german: 'Die Miete beträgt siebenhundert Euro im Monat.',
        english: 'The rent is seven hundred euros a month.',
      ),
      RadioLine(
        german: 'Leider gibt es keinen Balkon, aber einen großen Keller.',
        english: 'Unfortunately there is no balcony, but a large cellar.',
      ),
      RadioLine(
        german: 'Wenn Sie möchten, zeigen wir sie Ihnen am Mittwoch.',
        english: 'If you like, we can show it to you on Wednesday.',
      ),
      RadioLine(
        german: 'Bitte rufen Sie bis morgen zurück.',
        english: 'Please call back by tomorrow.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie viele Zimmer hat die Wohnung?',
        options: <String>['Zwei', 'Drei', 'Vier'],
        correctIndex: 1,
        explanation: 'Sie hat drei Zimmer und liegt im zweiten Stock.',
      ),
      ChoiceQuestion(
        prompt: 'Wie hoch ist die Miete?',
        options: <String>[
          'Siebenhundert Euro',
          'Siebenhundert Euro pro Woche',
          'Siebzig Euro',
        ],
        correctIndex: 0,
        explanation: 'Die Miete beträgt siebenhundert Euro im Monat.',
      ),
      ChoiceQuestion(
        prompt: 'Was hat die Wohnung nicht?',
        options: <String>['Einen Keller', 'Einen Balkon', 'Ein Bad'],
        correctIndex: 1,
        explanation: 'Leider gibt es keinen Balkon, aber einen großen Keller.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'gr-a2-05',
    level: CefrLevel.a2,
    genre: RadioGenre.diary,
    title: 'Mein erster Tag im Kurs',
    lines: <RadioLine>[
      RadioLine(
        german: 'Gestern hatte ich meinen ersten Tag im Deutschkurs.',
        english: 'Yesterday I had my first day in the German course.',
      ),
      RadioLine(
        german: 'Ich war ziemlich nervös, aber alle waren freundlich.',
        english: 'I was quite nervous, but everyone was friendly.',
      ),
      RadioLine(
        german: 'In meiner Gruppe sind zwölf Leute aus acht Ländern.',
        english: 'In my group there are twelve people from eight countries.',
      ),
      RadioLine(
        german: 'Wir haben uns vorgestellt und über unsere Hobbys gesprochen.',
        english: 'We introduced ourselves and talked about our hobbies.',
      ),
      RadioLine(
        german: 'Die Lehrerin spricht langsam, deshalb verstehe ich fast alles.',
        english: 'The teacher speaks slowly, so I understand almost everything.',
      ),
      RadioLine(
        german: 'Zu Hause muss ich jeden Tag eine halbe Stunde üben.',
        english: 'At home I have to practise for half an hour every day.',
      ),
      RadioLine(
        german: 'Ich freue mich schon auf morgen.',
        english: 'I am already looking forward to tomorrow.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie viele Leute sind in der Gruppe?',
        options: <String>['Acht', 'Zehn', 'Zwölf'],
        correctIndex: 2,
        explanation: 'In meiner Gruppe sind zwölf Leute aus acht Ländern.',
      ),
      ChoiceQuestion(
        prompt: 'Warum versteht die Person fast alles?',
        options: <String>[
          'Die Lehrerin spricht langsam.',
          'Alle sprechen Englisch.',
          'Der Kurs ist sehr leicht.',
        ],
        correctIndex: 0,
        explanation:
            'Die Lehrerin spricht langsam, deshalb verstehe ich fast alles.',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange soll sie zu Hause üben?',
        options: <String>[
          'Eine halbe Stunde am Tag',
          'Zwei Stunden am Tag',
          'Nur am Wochenende',
        ],
        correctIndex: 0,
        explanation: 'Zu Hause muss ich jeden Tag eine halbe Stunde üben.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'gr-a2-06',
    level: CefrLevel.a2,
    genre: RadioGenre.announcement,
    title: 'Durchsage am Flughafen',
    lines: <RadioLine>[
      RadioLine(
        german: 'Eine Information für die Passagiere nach Wien.',
        english: 'An announcement for passengers travelling to Vienna.',
      ),
      RadioLine(
        german: 'Der Flug startet heute später als geplant.',
        english: 'The flight is departing later than planned today.',
      ),
      RadioLine(
        german: 'Der Grund ist das schlechte Wetter in Österreich.',
        english: 'The reason is the bad weather in Austria.',
      ),
      RadioLine(
        german: 'Wir rechnen mit einer Verspätung von etwa einer Stunde.',
        english: 'We expect a delay of about one hour.',
      ),
      RadioLine(
        german: 'Bitte bleiben Sie in der Nähe von Ausgang zwölf.',
        english: 'Please stay near gate twelve.',
      ),
      RadioLine(
        german: 'Sie können im Wartebereich kostenlos Kaffee bekommen.',
        english: 'You can get free coffee in the waiting area.',
      ),
      RadioLine(
        german: 'Wir entschuldigen uns für die Unannehmlichkeiten.',
        english: 'We apologise for the inconvenience.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wohin geht der Flug?',
        options: <String>['Nach Wien', 'Nach Zürich', 'Nach Berlin'],
        correctIndex: 0,
        explanation: 'Eine Information für die Passagiere nach Wien.',
      ),
      ChoiceQuestion(
        prompt: 'Warum hat der Flug Verspätung?',
        options: <String>[
          'Wegen des schlechten Wetters',
          'Wegen eines Streiks',
          'Wegen eines technischen Problems',
        ],
        correctIndex: 0,
        explanation: 'Der Grund ist das schlechte Wetter in Österreich.',
      ),
      ChoiceQuestion(
        prompt: 'Was bekommen die Passagiere im Wartebereich?',
        options: <String>['Kostenlos Kaffee', 'Ein Hotelzimmer', 'Geld zurück'],
        correctIndex: 0,
        explanation: 'Sie können im Wartebereich kostenlos Kaffee bekommen.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'gr-a2-07',
    level: CefrLevel.a2,
    genre: RadioGenre.recipe,
    title: 'Apfelkuchen backen',
    lines: <RadioLine>[
      RadioLine(
        german: 'Heute backen wir einen einfachen Apfelkuchen.',
        english: 'Today we are baking a simple apple cake.',
      ),
      RadioLine(
        german: 'Sie brauchen vier Äpfel, Mehl, Zucker, Butter und drei Eier.',
        english: 'You need four apples, flour, sugar, butter and three eggs.',
      ),
      RadioLine(
        german: 'Zuerst schälen Sie die Äpfel und schneiden sie klein.',
        english: 'First peel the apples and cut them into small pieces.',
      ),
      RadioLine(
        german: 'Dann mischen Sie Mehl, Zucker, Butter und Eier zu einem Teig.',
        english: 'Then mix flour, sugar, butter and eggs into a dough.',
      ),
      RadioLine(
        german: 'Geben Sie die Äpfel dazu und rühren Sie alles gut um.',
        english: 'Add the apples and stir everything well.',
      ),
      RadioLine(
        german: 'Der Kuchen muss vierzig Minuten bei hundertachtzig Grad backen.',
        english: 'The cake has to bake for forty minutes at one hundred and eighty degrees.',
      ),
      RadioLine(
        german: 'Lassen Sie ihn abkühlen, bevor Sie ihn schneiden.',
        english: 'Let it cool down before you cut it.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie viele Äpfel braucht man?',
        options: <String>['Zwei', 'Drei', 'Vier'],
        correctIndex: 2,
        explanation: 'Sie brauchen vier Äpfel, Mehl, Zucker, Butter und drei Eier.',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange muss der Kuchen backen?',
        options: <String>['Zwanzig Minuten', 'Vierzig Minuten', 'Eine Stunde'],
        correctIndex: 1,
        explanation:
            'Der Kuchen muss vierzig Minuten bei hundertachtzig Grad backen.',
      ),
      ChoiceQuestion(
        prompt: 'Was soll man vor dem Schneiden tun?',
        options: <String>[
          'Den Kuchen abkühlen lassen',
          'Zucker darüber geben',
          'Ihn noch einmal backen',
        ],
        correctIndex: 0,
        explanation: 'Lassen Sie ihn abkühlen, bevor Sie ihn schneiden.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'gr-a2-08',
    level: CefrLevel.a2,
    genre: RadioGenre.news,
    title: 'Sport am Wochenende',
    lines: <RadioLine>[
      RadioLine(
        german: 'Und jetzt zum Sport hier in der Region.',
        english: 'And now to sport here in the region.',
      ),
      RadioLine(
        german: 'Am Samstag hat unsere Mannschaft zwei zu eins gewonnen.',
        english: 'On Saturday our team won two one.',
      ),
      RadioLine(
        german: 'Das Spiel war lange offen, das Tor fiel erst spät.',
        english: 'The game was open for a long time, the goal came only late.',
      ),
      RadioLine(
        german: 'Über viertausend Zuschauer waren im Stadion.',
        english: 'Over four thousand spectators were in the stadium.',
      ),
      RadioLine(
        german: 'Nächste Woche spielt die Mannschaft auswärts.',
        english: 'Next week the team plays away.',
      ),
      RadioLine(
        german: 'Am Sonntag beginnt außerdem der Stadtlauf.',
        english: 'On Sunday the city run also begins.',
      ),
      RadioLine(
        german: 'Wer mitlaufen will, kann sich noch heute anmelden.',
        english: 'Anyone who wants to take part can still register today.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie hat die Mannschaft gespielt?',
        options: <String>['Sie hat verloren.', 'Sie hat gewonnen.', 'Unentschieden'],
        correctIndex: 1,
        explanation: 'Am Samstag hat unsere Mannschaft zwei zu eins gewonnen.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viele Zuschauer waren im Stadion?',
        options: <String>['Vierhundert', 'Über viertausend', 'Vierzigtausend'],
        correctIndex: 1,
        explanation: 'Über viertausend Zuschauer waren im Stadion.',
      ),
      ChoiceQuestion(
        prompt: 'Was passiert am Sonntag?',
        options: <String>[
          'Der Stadtlauf beginnt.',
          'Die Mannschaft spielt zu Hause.',
          'Das Stadion schließt.',
        ],
        correctIndex: 0,
        explanation: 'Am Sonntag beginnt außerdem der Stadtlauf.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'gr-a2-09',
    level: CefrLevel.a2,
    genre: RadioGenre.lecture,
    title: 'Warum Pflanzen Wasser brauchen',
    lines: <RadioLine>[
      RadioLine(
        german: 'Jede Pflanze braucht Wasser, Licht und gute Erde.',
        english: 'Every plant needs water, light and good soil.',
      ),
      RadioLine(
        german: 'Das Wasser kommt durch die Wurzeln in die Pflanze.',
        english: 'The water enters the plant through the roots.',
      ),
      RadioLine(
        german: 'Von dort geht es nach oben in die Blätter.',
        english: 'From there it travels up into the leaves.',
      ),
      RadioLine(
        german: 'In den Blättern macht die Pflanze mit Licht ihre Nahrung.',
        english: 'In the leaves the plant makes its food using light.',
      ),
      RadioLine(
        german: 'Wenn eine Pflanze zu wenig Wasser bekommt, wird sie gelb.',
        english: 'If a plant gets too little water, it turns yellow.',
      ),
      RadioLine(
        german: 'Zu viel Wasser ist aber auch nicht gut.',
        english: 'But too much water is not good either.',
      ),
      RadioLine(
        german: 'Am besten gießt man regelmäßig und nicht zu viel.',
        english: 'It is best to water regularly and not too much.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie kommt das Wasser in die Pflanze?',
        options: <String>['Durch die Blätter', 'Durch die Wurzeln', 'Durch die Blüten'],
        correctIndex: 1,
        explanation: 'Das Wasser kommt durch die Wurzeln in die Pflanze.',
      ),
      ChoiceQuestion(
        prompt: 'Was passiert bei zu wenig Wasser?',
        options: <String>[
          'Die Pflanze wird gelb.',
          'Die Pflanze wächst schneller.',
          'Nichts passiert.',
        ],
        correctIndex: 0,
        explanation:
            'Wenn eine Pflanze zu wenig Wasser bekommt, wird sie gelb.',
      ),
      ChoiceQuestion(
        prompt: 'Was ist der beste Rat?',
        options: <String>[
          'Regelmäßig und nicht zu viel gießen',
          'Jeden Tag sehr viel gießen',
          'Gar nicht gießen',
        ],
        correctIndex: 0,
        explanation: 'Am besten gießt man regelmäßig und nicht zu viel.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'gr-a2-10',
    level: CefrLevel.a2,
    genre: RadioGenre.weather,
    title: 'Wetter und Verkehr',
    lines: <RadioLine>[
      RadioLine(
        german: 'Am Morgen liegt dichter Nebel über der Stadt.',
        english: 'In the morning there is thick fog over the city.',
      ),
      RadioLine(
        german: 'Man sieht oft nur fünfzig Meter weit.',
        english: 'Often you can see only fifty metres.',
      ),
      RadioLine(
        german: 'Fahren Sie deshalb bitte besonders vorsichtig.',
        english: 'Please drive particularly carefully for that reason.',
      ),
      RadioLine(
        german: 'Gegen Mittag löst sich der Nebel langsam auf.',
        english: 'Towards midday the fog slowly clears.',
      ),
      RadioLine(
        german: 'Am Nachmittag wird es mit vierzehn Grad recht mild.',
        english: 'In the afternoon it becomes quite mild at fourteen degrees.',
      ),
      RadioLine(
        german: 'Auf der Autobahn gibt es zwischen zwei Ausfahrten Stau.',
        english: 'On the motorway there is a jam between two exits.',
      ),
      RadioLine(
        german: 'Wer kann, sollte eine andere Strecke nehmen.',
        english: 'Anyone who can should take a different route.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie weit sieht man am Morgen?',
        options: <String>['Fünf Meter', 'Fünfzig Meter', 'Fünfhundert Meter'],
        correctIndex: 1,
        explanation: 'Man sieht oft nur fünfzig Meter weit.',
      ),
      ChoiceQuestion(
        prompt: 'Wann löst sich der Nebel auf?',
        options: <String>['Am Abend', 'Gegen Mittag', 'Gar nicht'],
        correctIndex: 1,
        explanation: 'Gegen Mittag löst sich der Nebel langsam auf.',
      ),
      ChoiceQuestion(
        prompt: 'Was ist auf der Autobahn los?',
        options: <String>['Es gibt Stau.', 'Sie ist gesperrt.', 'Es ist alles frei.'],
        correctIndex: 0,
        explanation:
            'Auf der Autobahn gibt es zwischen zwei Ausfahrten Stau.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'gr-a2-11',
    level: CefrLevel.a2,
    genre: RadioGenre.diary,
    title: 'Umzug in eine neue Stadt',
    lines: <RadioLine>[
      RadioLine(
        german: 'Vor drei Monaten bin ich in eine neue Stadt gezogen.',
        english: 'Three months ago I moved to a new city.',
      ),
      RadioLine(
        german: 'Am Anfang war alles fremd und ich kannte niemanden.',
        english: 'At the beginning everything was strange and I knew nobody.',
      ),
      RadioLine(
        german: 'Ich habe mich oft verlaufen, weil die Straßen anders sind.',
        english: 'I often got lost because the streets are different.',
      ),
      RadioLine(
        german: 'Dann habe ich im Sportverein neue Leute kennengelernt.',
        english: 'Then I met new people at the sports club.',
      ),
      RadioLine(
        german: 'Jetzt treffe ich mich jede Woche mit zwei Freunden.',
        english: 'Now I meet two friends every week.',
      ),
      RadioLine(
        german: 'Die Wohnung ist klein, aber der Blick ist schön.',
        english: 'The flat is small, but the view is lovely.',
      ),
      RadioLine(
        german: 'Ich glaube, ich bleibe hier noch lange.',
        english: 'I think I will stay here for a long time.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann ist die Person umgezogen?',
        options: <String>['Vor drei Wochen', 'Vor drei Monaten', 'Vor drei Jahren'],
        correctIndex: 1,
        explanation: 'Vor drei Monaten bin ich in eine neue Stadt gezogen.',
      ),
      ChoiceQuestion(
        prompt: 'Wo hat sie neue Leute kennengelernt?',
        options: <String>['Im Sportverein', 'Im Büro', 'Im Supermarkt'],
        correctIndex: 0,
        explanation: 'Dann habe ich im Sportverein neue Leute kennengelernt.',
      ),
      ChoiceQuestion(
        prompt: 'Wie findet sie die Wohnung?',
        options: <String>[
          'Klein, aber mit schönem Blick',
          'Groß und teuer',
          'Zu laut',
        ],
        correctIndex: 0,
        explanation: 'Die Wohnung ist klein, aber der Blick ist schön.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'gr-a2-12',
    level: CefrLevel.a2,
    genre: RadioGenre.announcement,
    title: 'Information in der Bibliothek',
    lines: <RadioLine>[
      RadioLine(
        german: 'Liebe Besucherinnen und Besucher, eine kurze Information.',
        english: 'Dear visitors, a short announcement.',
      ),
      RadioLine(
        german: 'Die Bibliothek schließt heute schon um achtzehn Uhr.',
        english: 'The library closes at six today.',
      ),
      RadioLine(
        german: 'Am Abend findet hier eine Lesung statt.',
        english: 'In the evening there is a reading here.',
      ),
      RadioLine(
        german: 'Der Eintritt kostet fünf Euro, für Studenten drei.',
        english: 'Admission costs five euros, three for students.',
      ),
      RadioLine(
        german: 'Bücher können Sie noch bis siebzehn Uhr dreißig abgeben.',
        english: 'You can return books until half past five.',
      ),
      RadioLine(
        german: 'Morgen sind wir wieder ab neun Uhr für Sie da.',
        english: 'Tomorrow we are here for you again from nine.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann schließt die Bibliothek heute?',
        options: <String>['Um sechzehn Uhr', 'Um achtzehn Uhr', 'Um zwanzig Uhr'],
        correctIndex: 1,
        explanation: 'Die Bibliothek schließt heute schon um achtzehn Uhr.',
      ),
      ChoiceQuestion(
        prompt: 'Was kostet der Eintritt für Studenten?',
        options: <String>['Drei Euro', 'Fünf Euro', 'Nichts'],
        correctIndex: 0,
        explanation: 'Der Eintritt kostet fünf Euro, für Studenten drei.',
      ),
      ChoiceQuestion(
        prompt: 'Bis wann kann man Bücher abgeben?',
        options: <String>[
          'Bis siebzehn Uhr dreißig',
          'Bis achtzehn Uhr',
          'Bis morgen',
        ],
        correctIndex: 0,
        explanation:
            'Bücher können Sie noch bis siebzehn Uhr dreißig abgeben.',
      ),
    ],
  ),
];
