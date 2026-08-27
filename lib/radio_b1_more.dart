import 'models.dart';
import 'radio.dart';

/// B1 Gartenradio scripts, second batch.
///
/// Original text written for this app. Episodes live in one file
/// per batch so a new set of scripts is a new file rather than a
/// rewrite of a growing one.
const List<RadioEpisode> radioB1MoreEpisodes = <RadioEpisode>[
  RadioEpisode(
    id: 'rd-b1-15',
    level: CefrLevel.b1,
    genre: RadioGenre.news,
    title: 'Nachtbus für den Landkreis',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Abend, hier sind die Nachrichten aus dem Landkreis Bergfelde.',
        english: 'Good evening, here is the news from the district of Bergfelde.',
      ),
      RadioLine(
        german: 'Ab dem ersten Oktober fährt ein Nachtbus, der die Dörfer im Norden mit dem Bahnhof verbindet.',
        english: 'From the first of October a night bus will run, connecting the villages in the north with the railway station.',
      ),
      RadioLine(
        german: 'Die Linie soll freitags und samstags bis halb drei unterwegs sein.',
        english: 'The route is meant to operate on Fridays and Saturdays until half past two.',
      ),
      RadioLine(
        german: 'Der Verkehrsbetrieb hatte den Versuch schon vor drei Jahren geplant, doch damals fehlte das Geld.',
        english: 'The transport company had already planned the trial three years ago, but back then the money was missing.',
      ),
      RadioLine(
        german: 'Eine Fahrt kostet zwei Euro achtzig, für Jugendliche die Hälfte.',
        english: 'A single trip costs two euros eighty, half that for young people.',
      ),
      RadioLine(
        german: 'Nach Ansicht der Kreisverwaltung würden vor allem Pendler und Gäste der Gaststätten profitieren.',
        english: 'In the district administration\'s view, commuters and pub customers would benefit most.',
      ),
      RadioLine(
        german: 'Kritiker meinen, ohne feste Anschlüsse an die Bahn bleibt das Angebot wenig nützlich.',
        english: 'Critics say that without reliable rail connections the service will not be much use.',
      ),
      RadioLine(
        german: 'Der Landkreis will nach einem Jahr prüfen, ob sich die Linie lohnt.',
        english: 'After a year the district intends to check whether the route is worthwhile.',
      ),
      RadioLine(
        german: 'Mehr dazu am Ende der Sendung.',
        english: 'More on that at the end of the programme.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'An welchen Tagen fährt der Nachtbus?',
        options: <String>[
          'freitags und samstags',
          'montags und dienstags',
          'sonntags und mittwochs',
        ],
        correctIndex: 0,
        explanation: 'Im Text heißt es, die Linie soll freitags und samstags bis halb drei unterwegs sein.',
      ),
      ChoiceQuestion(
        prompt: 'Was kostet eine einzelne Fahrt?',
        options: <String>[
          'zwei Euro dreißig',
          'zwei Euro achtzig',
          'drei Euro fünfzig',
        ],
        correctIndex: 1,
        explanation: 'Eine Fahrt kostet zwei Euro achtzig, für Jugendliche die Hälfte.',
      ),
      ChoiceQuestion(
        prompt: 'Warum kam der Nachtbus nicht schon früher?',
        options: <String>[
          'Die Straßen waren gesperrt.',
          'Es fehlten Fahrerinnen und Fahrer.',
          'Damals fehlte das Geld.',
        ],
        correctIndex: 2,
        explanation: 'Der Verkehrsbetrieb hatte den Versuch schon vor drei Jahren geplant, doch damals fehlte das Geld.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-16',
    level: CefrLevel.b1,
    genre: RadioGenre.lecture,
    title: 'Warum Städte wärmer sind',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen zur kurzen Reihe über Alltagsphysik.',
        english: 'Welcome to the short series on everyday physics.',
      ),
      RadioLine(
        german: 'Heute geht es um die Frage, warum eine Stadt im Sommer wärmer ist als das Umland.',
        english: 'Today we look at why a city is warmer in summer than the surrounding countryside.',
      ),
      RadioLine(
        german: 'Asphalt und Beton speichern die Wärme des Tages und geben sie erst nachts wieder ab.',
        english: 'Asphalt and concrete store the heat of the day and only release it again at night.',
      ),
      RadioLine(
        german: 'Auf einer Wiese, die Wasser verdunstet, kühlt der Boden dagegen schneller ab.',
        english: 'On a meadow, where water evaporates, the ground cools down faster instead.',
      ),
      RadioLine(
        german: 'Dazu kommt die Abwärme von Autos, Gebäuden und Geräten.',
        english: 'On top of that there is the waste heat from cars, buildings and appliances.',
      ),
      RadioLine(
        german: 'Messungen in mittelgroßen Städten zeigen nachts oft drei Grad Unterschied.',
        english: 'Measurements in medium-sized towns often show a difference of three degrees at night.',
      ),
      RadioLine(
        german: 'Wer diesen Effekt verringern möchte, müsste vor allem Bäume pflanzen und Dächer begrünen.',
        english: 'Anyone wanting to reduce this effect would above all have to plant trees and green the roofs.',
      ),
      RadioLine(
        german: 'Um den Unterschied zu spüren, genügt ein Spaziergang vom Marktplatz zum Fluss.',
        english: 'To feel the difference, a walk from the market square down to the river is enough.',
      ),
      RadioLine(
        german: 'In der nächsten Folge sprechen wir über den Wind zwischen den Häusern.',
        english: 'In the next episode we will talk about the wind between the buildings.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Warum kühlt der Boden auf einer Wiese schneller ab?',
        options: <String>[
          'Weil dort mehr Wind weht.',
          'Weil die Wiese Wasser verdunstet.',
          'Weil die Wiese höher liegt.',
        ],
        correctIndex: 1,
        explanation: 'Auf einer Wiese, die Wasser verdunstet, kühlt der Boden schneller ab.',
      ),
      ChoiceQuestion(
        prompt: 'Wie groß ist der Unterschied nachts oft?',
        options: <String>[
          'etwa ein Grad',
          'etwa sechs Grad',
          'etwa drei Grad',
        ],
        correctIndex: 2,
        explanation: 'Messungen in mittelgroßen Städten zeigen nachts oft drei Grad Unterschied.',
      ),
      ChoiceQuestion(
        prompt: 'Was müsste man laut Vortrag vor allem tun?',
        options: <String>[
          'Bäume pflanzen und Dächer begrünen',
          'Straßen mit hellem Asphalt erneuern',
          'Fenster tagsüber schließen und nachts lüften',
        ],
        correctIndex: 0,
        explanation: 'Wer den Effekt verringern möchte, müsste vor allem Bäume pflanzen und Dächer begrünen.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-17',
    level: CefrLevel.b1,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Der Wasserturm',
    lines: <RadioLine>[
      RadioLine(
        german: 'Sie stehen jetzt vor dem alten Wasserturm, dem Wahrzeichen des Viertels.',
        english: 'You are now standing in front of the old water tower, the landmark of this district.',
      ),
      RadioLine(
        german: 'Der Turm entstand 1903, weil der Wasserdruck in den oberen Stockwerken zu gering war.',
        english: 'The tower was built in 1903 because the water pressure on the upper floors was too low.',
      ),
      RadioLine(
        german: 'Bevor er in Betrieb ging, hatten viele Familien ihr Wasser noch am Brunnen geholt.',
        english: 'Before it went into operation, many families had still been fetching their water from the well.',
      ),
      RadioLine(
        german: 'Oben im Turm fasste der Behälter fast dreihundert Kubikmeter Wasser.',
        english: 'Up in the tower the tank held almost three hundred cubic metres of water.',
      ),
      RadioLine(
        german: 'Wenn Sie nach links schauen, sehen Sie die schmale Tür, durch die früher die Arbeiter stiegen.',
        english: 'If you look to the left, you will see the narrow door the workers used to climb through.',
      ),
      RadioLine(
        german: 'Seit 1978 ist der Turm ohne Funktion.',
        english: 'Since 1978 the tower has had no function.',
      ),
      RadioLine(
        german: 'Heute befindet sich im Erdgeschoss ein kleines Café, das ein Verein betreibt.',
        english: 'Today there is a small café on the ground floor, run by an association.',
      ),
      RadioLine(
        german: 'Wer möchte, kann im Sommer sogar die Aussichtsplattform besuchen.',
        english: 'In summer, anyone who likes can even visit the viewing platform.',
      ),
      RadioLine(
        german: 'Bitte gehen Sie nun weiter zur Station sieben im Hof.',
        english: 'Please continue now to station seven in the courtyard.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Warum wurde der Turm gebaut?',
        options: <String>[
          'Die Stadt brauchte einen Aussichtspunkt.',
          'Das Wasser im Fluss war zu warm.',
          'Der Wasserdruck oben war zu gering.',
        ],
        correctIndex: 2,
        explanation: 'Der Turm entstand 1903, weil der Wasserdruck in den oberen Stockwerken zu gering war.',
      ),
      ChoiceQuestion(
        prompt: 'Wo holten viele Familien vorher ihr Wasser?',
        options: <String>[
          'am Brunnen',
          'am Fluss',
          'im Keller',
        ],
        correctIndex: 0,
        explanation: 'Bevor der Turm in Betrieb ging, hatten viele Familien ihr Wasser noch am Brunnen geholt.',
      ),
      ChoiceQuestion(
        prompt: 'Was gibt es heute im Erdgeschoss?',
        options: <String>[
          'eine Werkstatt',
          'ein kleines Café',
          'ein Vereinsbüro',
        ],
        correctIndex: 1,
        explanation: 'Heute befindet sich im Erdgeschoss ein kleines Café, das ein Verein betreibt.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-18',
    level: CefrLevel.b1,
    genre: RadioGenre.voicemail,
    title: 'Nachricht vom Gartenverein',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Tag, hier spricht Martina Weidlich vom Kleingartenverein Sonnenhang.',
        english: 'Hello, this is Martina Weidlich from the Sonnenhang allotment association.',
      ),
      RadioLine(
        german: 'Ich rufe an, weil sich der Termin für die Frühjahrsversammlung verschoben hat.',
        english: 'I am calling because the date of the spring meeting has been moved.',
      ),
      RadioLine(
        german: 'Wir treffen uns jetzt am Samstag, dem vierzehnten März, um zehn Uhr im Vereinshaus.',
        english: 'We are now meeting on Saturday the fourteenth of March at ten o\'clock in the clubhouse.',
      ),
      RadioLine(
        german: 'Der Vorstand hatte zuerst den Freitagabend vorgesehen, doch der Raum war schon vergeben.',
        english: 'The committee had first planned for Friday evening, but the room had already been taken.',
      ),
      RadioLine(
        german: 'Auf der Tagesordnung steht auch der Beitrag, der um vier Euro im Jahr steigen soll.',
        english: 'The agenda also includes the membership fee, which is to rise by four euros a year.',
      ),
      RadioLine(
        german: 'Es wäre schön, wenn Sie Ihre Gartennummer vorher bei mir bestätigen könnten.',
        english: 'It would be nice if you could confirm your plot number with me beforehand.',
      ),
      RadioLine(
        german: 'Bringen Sie bitte auch Ihren Schlüssel mit, um das neue Schloss zu testen.',
        english: 'Please also bring your key so that you can test the new lock.',
      ),
      RadioLine(
        german: 'Falls Sie nicht kommen können, genügt eine kurze Mail an den Verein.',
        english: 'If you cannot come, a short email to the association is enough.',
      ),
      RadioLine(
        german: 'Vielen Dank und bis bald.',
        english: 'Many thanks and see you soon.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann findet die Versammlung jetzt statt?',
        options: <String>[
          'am Freitagabend',
          'am Samstagvormittag',
          'am Sonntagnachmittag',
        ],
        correctIndex: 1,
        explanation: 'Man trifft sich am Samstag, dem vierzehnten März, um zehn Uhr im Vereinshaus.',
      ),
      ChoiceQuestion(
        prompt: 'Wie stark soll der Beitrag steigen?',
        options: <String>[
          'um vier Euro im Jahr',
          'um zehn Euro im Jahr',
          'um zwei Euro im Jahr',
        ],
        correctIndex: 0,
        explanation: 'Auf der Tagesordnung steht der Beitrag, der um vier Euro im Jahr steigen soll.',
      ),
      ChoiceQuestion(
        prompt: 'Was sollen die Mitglieder mitbringen?',
        options: <String>[
          'einen Gartenplan',
          'ein Formular',
          'ihren Schlüssel',
        ],
        correctIndex: 2,
        explanation: 'Alle sollen ihren Schlüssel mitbringen, um das neue Schloss zu testen.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-19',
    level: CefrLevel.b1,
    genre: RadioGenre.recipe,
    title: 'Ofengemüse für zwei',
    lines: <RadioLine>[
      RadioLine(
        german: 'Für dieses Ofengemüse brauchen Sie Karotten, Zucchini, eine rote Zwiebel und zwei Kartoffeln.',
        english: 'For these roasted vegetables you need carrots, courgettes, a red onion and two potatoes.',
      ),
      RadioLine(
        german: 'Heizen Sie den Backofen auf zweihundert Grad vor.',
        english: 'Preheat the oven to two hundred degrees.',
      ),
      RadioLine(
        german: 'Waschen Sie das Gemüse und schneiden Sie es in Stücke, die etwa gleich groß sind.',
        english: 'Wash the vegetables and cut them into pieces of roughly the same size.',
      ),
      RadioLine(
        german: 'Legen Sie alles auf ein Blech, das Sie vorher mit Papier ausgelegt haben.',
        english: 'Put everything on a baking tray that you have lined with paper beforehand.',
      ),
      RadioLine(
        german: 'Danach kommen zwei Löffel Öl, Salz, Pfeffer und etwas Rosmarin darüber.',
        english: 'After that, add two spoonfuls of oil, salt, pepper and a little rosemary on top.',
      ),
      RadioLine(
        german: 'Schieben Sie das Blech in die Mitte des Ofens und warten Sie fünfundzwanzig Minuten.',
        english: 'Slide the tray into the middle of the oven and wait twenty-five minutes.',
      ),
      RadioLine(
        german: 'Wenden Sie das Gemüse einmal, damit es von beiden Seiten braun wird.',
        english: 'Turn the vegetables once so that they brown on both sides.',
      ),
      RadioLine(
        german: 'Wer es kräftiger mag, könnte am Ende etwas Knoblauch hinzufügen.',
        english: 'Anyone who likes a stronger taste could add a little garlic at the end.',
      ),
      RadioLine(
        german: 'Dazu passt ein Quark mit frischen Kräutern, den Sie schnell anrühren.',
        english: 'It goes well with a quark dip with fresh herbs, which you can stir together quickly.',
      ),
      RadioLine(
        german: 'Guten Appetit.',
        english: 'Enjoy your meal.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Auf welche Temperatur wird der Ofen vorgeheizt?',
        options: <String>[
          'auf hundertachtzig Grad',
          'auf zweihundertzwanzig Grad',
          'auf zweihundert Grad',
        ],
        correctIndex: 2,
        explanation: 'Im Rezept heißt es, man soll den Backofen auf zweihundert Grad vorheizen.',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange bleibt das Blech im Ofen?',
        options: <String>[
          'fünfzehn Minuten',
          'fünfundzwanzig Minuten',
          'vierzig Minuten',
        ],
        correctIndex: 1,
        explanation: 'Man schiebt das Blech in die Mitte des Ofens und wartet fünfundzwanzig Minuten.',
      ),
      ChoiceQuestion(
        prompt: 'Was passt laut Rezept dazu?',
        options: <String>[
          'Quark mit frischen Kräutern',
          'Reis mit gebratenen Zwiebeln',
          'Brot mit gesalzener Butter',
        ],
        correctIndex: 0,
        explanation: 'Dazu passt ein Quark mit frischen Kräutern, den man schnell anrührt.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-20',
    level: CefrLevel.b1,
    genre: RadioGenre.weather,
    title: 'Föhn im Süden',
    lines: <RadioLine>[
      RadioLine(
        german: 'Und nun die Vorhersage für den Alpenrand und das Vorland.',
        english: 'And now the forecast for the edge of the Alps and the foothills.',
      ),
      RadioLine(
        german: 'Am Vormittag sorgt Föhn für klare Sicht und ungewöhnlich milde Luft.',
        english: 'In the morning a föhn wind brings clear views and unusually mild air.',
      ),
      RadioLine(
        german: 'In den Tälern, die nach Süden offen liegen, steigen die Werte auf achtzehn Grad.',
        english: 'In the valleys that open towards the south, temperatures climb to eighteen degrees.',
      ),
      RadioLine(
        german: 'Weiter nördlich bleibt es mit elf Grad deutlich kühler.',
        english: 'Further north it stays clearly cooler at eleven degrees.',
      ),
      RadioLine(
        german: 'Am Nachmittag zieht von Westen eine Front auf, die den Wind dreht.',
        english: 'In the afternoon a front moves in from the west and turns the wind around.',
      ),
      RadioLine(
        german: 'Wer eine Bergtour plant, sollte deshalb vor drei Uhr wieder im Tal sein.',
        english: 'Anyone planning a mountain hike should therefore be back in the valley before three o\'clock.',
      ),
      RadioLine(
        german: 'In der Nacht fällt Regen, oberhalb von tausendfünfhundert Metern auch Schnee.',
        english: 'During the night there will be rain, and above fifteen hundred metres snow as well.',
      ),
      RadioLine(
        german: 'Am Freitag wäre nach heutigem Stand wieder Sonne möglich, doch die Modelle sind uneinig.',
        english: 'As things stand today, sunshine would be possible again on Friday, but the models disagree.',
      ),
      RadioLine(
        german: 'Die nächste Vorhersage hören Sie um achtzehn Uhr.',
        english: 'You can hear the next forecast at six in the evening.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie warm wird es in den nach Süden offenen Tälern?',
        options: <String>[
          'achtzehn Grad',
          'elf Grad',
          'vierzehn Grad',
        ],
        correctIndex: 0,
        explanation: 'In den Tälern, die nach Süden offen liegen, steigen die Werte auf achtzehn Grad.',
      ),
      ChoiceQuestion(
        prompt: 'Wann sollte man von einer Bergtour zurück sein?',
        options: <String>[
          'vor fünf Uhr',
          'vor sechs Uhr',
          'vor drei Uhr',
        ],
        correctIndex: 2,
        explanation: 'Wer eine Bergtour plant, sollte vor drei Uhr wieder im Tal sein.',
      ),
      ChoiceQuestion(
        prompt: 'Ab welcher Höhe fällt in der Nacht Schnee?',
        options: <String>[
          'ab tausend Metern',
          'ab tausendfünfhundert Metern',
          'ab zweitausend Metern',
        ],
        correctIndex: 1,
        explanation: 'In der Nacht fällt Regen, oberhalb von tausendfünfhundert Metern auch Schnee.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-21',
    level: CefrLevel.b1,
    genre: RadioGenre.diary,
    title: 'Der erste Sommer im Garten',
    lines: <RadioLine>[
      RadioLine(
        german: 'Heute Abend sitze ich auf der Bank, die mein Nachbar im Mai repariert hat.',
        english: 'This evening I am sitting on the bench that my neighbour repaired back in May.',
      ),
      RadioLine(
        german: 'Im März hatte ich den kleinen Garten übernommen, weil ich mehr Zeit draußen wollte.',
        english: 'I had taken over the little garden in March because I wanted more time outdoors.',
      ),
      RadioLine(
        german: 'Vorher hatte ich nie etwas angebaut, und ehrlich gesagt war ich ziemlich unsicher.',
        english: 'I had never grown anything before, and honestly I was rather unsure of myself.',
      ),
      RadioLine(
        german: 'Die Tomaten sind klein geblieben, aber die Bohnen wachsen besser, als ich gehofft hatte.',
        english: 'The tomatoes have stayed small, but the beans are growing better than I had hoped.',
      ),
      RadioLine(
        german: 'Wenn ich noch einmal anfangen würde, würde ich weniger pflanzen und mehr beobachten.',
        english: 'If I were to start over, I would plant less and watch more.',
      ),
      RadioLine(
        german: 'Mein Nachbar sagt, dass Geduld im Garten wichtiger ist als teures Werkzeug.',
        english: 'My neighbour says that patience matters more in a garden than expensive tools.',
      ),
      RadioLine(
        german: 'Ich glaube, er hat recht, denn meine Eile hat den Pflanzen nie geholfen.',
        english: 'I think he is right, because rushing has never helped my plants.',
      ),
      RadioLine(
        german: 'Am Wochenende gehe ich wieder hin, um die Wege zu mähen.',
        english: 'At the weekend I am going back to mow the paths.',
      ),
      RadioLine(
        german: 'Der Garten kostet mich Zeit, aber er gibt mir abends eine ruhige Stunde zurück.',
        english: 'The garden costs me time, but in the evenings it gives me back a quiet hour.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann hat die Sprecherin den Garten übernommen?',
        options: <String>[
          'Im Mai',
          'Im März',
          'Im Juni',
        ],
        correctIndex: 1,
        explanation: 'Sie sagt, dass sie den kleinen Garten im März übernommen hatte; im Mai wurde nur die Bank repariert.',
      ),
      ChoiceQuestion(
        prompt: 'Was wächst besser, als die Sprecherin gehofft hatte?',
        options: <String>[
          'Die Bohnen',
          'Die Tomaten',
          'Die Kräuter',
        ],
        correctIndex: 0,
        explanation: 'Im Text heißt es, die Tomaten seien klein geblieben, aber die Bohnen wachsen besser als erhofft.',
      ),
      ChoiceQuestion(
        prompt: 'Was würde die Sprecherin bei einem Neuanfang anders machen?',
        options: <String>[
          'Sie würde teureres Werkzeug kaufen',
          'Sie würde mehr Beete anlegen',
          'Sie würde weniger pflanzen',
        ],
        correctIndex: 2,
        explanation: 'Sie sagt, dass sie bei einem Neuanfang weniger pflanzen und mehr beobachten würde.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-22',
    level: CefrLevel.b1,
    genre: RadioGenre.announcement,
    title: 'Probealarm im Bürohaus',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Morgen, hier spricht die Haustechnik mit einer wichtigen Information für alle Mitarbeitenden.',
        english: 'Good morning, this is building services with an important message for all staff.',
      ),
      RadioLine(
        german: 'Am Donnerstag um zehn Uhr findet in unserem Gebäude ein Probealarm statt.',
        english: 'On Thursday at ten there will be a practice alarm in our building.',
      ),
      RadioLine(
        german: 'Wenn das Signal ertönt, verlassen Sie bitte die Büros und nehmen Sie die Treppe.',
        english: 'When the signal sounds, please leave the offices and take the stairs.',
      ),
      RadioLine(
        german: 'Die Aufzüge, die im Notfall gesperrt werden, dürfen während der Übung nicht benutzt werden.',
        english: 'The lifts, which are locked in an emergency, must not be used during the drill.',
      ),
      RadioLine(
        german: 'Der Sammelpunkt liegt auf dem Parkplatz hinter dem Haus, neben der grünen Schranke.',
        english: 'The assembly point is on the car park behind the building, next to the green barrier.',
      ),
      RadioLine(
        german: 'Wir hatten die Übung im letzten Jahr verschoben, deshalb bitten wir heute um Ihre Mitarbeit.',
        english: 'We postponed the drill last year, so today we are asking for your cooperation.',
      ),
      RadioLine(
        german: 'Kolleginnen und Kollegen im Homeoffice müssen an diesem Tag nichts unternehmen.',
        english: 'Colleagues working from home do not need to do anything on that day.',
      ),
      RadioLine(
        german: 'Die Übung dauert etwa zwanzig Minuten, danach können Sie wieder an Ihre Arbeitsplätze zurückkehren.',
        english: 'The drill lasts about twenty minutes, after which you can return to your desks.',
      ),
      RadioLine(
        german: 'Bei Fragen wenden Sie sich bitte an das Sekretariat im ersten Stock.',
        english: 'If you have questions, please contact the office on the first floor.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann findet der Probealarm statt?',
        options: <String>[
          'Am Mittwoch um zehn Uhr',
          'Am Donnerstag um zehn Uhr',
          'Am Donnerstag um zwölf Uhr',
        ],
        correctIndex: 1,
        explanation: 'Die Durchsage nennt Donnerstag um zehn Uhr als Termin für den Probealarm.',
      ),
      ChoiceQuestion(
        prompt: 'Wo liegt der Sammelpunkt?',
        options: <String>[
          'Auf dem Parkplatz hinter dem Haus',
          'Auf dem Platz vor dem Haupteingang',
          'Im Hof neben der Kantine',
        ],
        correctIndex: 0,
        explanation: 'Der Sammelpunkt liegt auf dem Parkplatz hinter dem Haus, neben der grünen Schranke.',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange dauert die Übung?',
        options: <String>[
          'Etwa zehn Minuten',
          'Etwa dreißig Minuten',
          'Etwa zwanzig Minuten',
        ],
        correctIndex: 2,
        explanation: 'Es wird gesagt, dass die Übung etwa zwanzig Minuten dauert.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-23',
    level: CefrLevel.b1,
    genre: RadioGenre.lecture,
    title: 'Kurz erklärt: Warum Brot hart wird',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen zu einer kurzen Folge über eine Frage aus der Küche.',
        english: 'Welcome to a short episode about a question from the kitchen.',
      ),
      RadioLine(
        german: 'Viele glauben, dass Brot nur deshalb hart wird, weil es austrocknet.',
        english: 'Many people believe that bread only goes hard because it dries out.',
      ),
      RadioLine(
        german: 'Das stimmt nur zum Teil, denn auch die Stärke im Brot verändert sich.',
        english: 'That is only partly true, because the starch in the bread changes as well.',
      ),
      RadioLine(
        german: 'Nach dem Backen ist die Stärke ungeordnet und bindet viel Wasser.',
        english: 'After baking, the starch is disordered and binds a lot of water.',
      ),
      RadioLine(
        german: 'Mit der Zeit ordnet sie sich neu, und das Wasser wandert aus der weichen Krume.',
        english: 'Over time it rearranges itself, and the water moves out of the soft crumb.',
      ),
      RadioLine(
        german: 'Deshalb wird ein Brot, das man in den Kühlschrank legt, schneller hart.',
        english: 'That is why bread you put in the fridge goes stale faster.',
      ),
      RadioLine(
        german: 'Bei niedrigen Temperaturen läuft dieser Vorgang nämlich besonders schnell ab.',
        english: 'At low temperatures this process actually runs particularly quickly.',
      ),
      RadioLine(
        german: 'Wer Brot länger aufbewahren möchte, sollte es einfrieren, denn im Gefrierfach stoppt der Vorgang fast ganz.',
        english: 'Anyone who wants to keep bread longer should freeze it, because in the freezer the process almost stops completely.',
      ),
      RadioLine(
        german: 'Im Ofen wird altes Brot wieder weicher, weil die Stärke erneut Wasser aufnimmt.',
        english: 'In the oven old bread turns soft again, because the starch takes up water once more.',
      ),
      RadioLine(
        german: 'So erklärt die Wissenschaft, warum Brot vom Vortag anders schmeckt.',
        english: 'That is how science explains why bread from the day before tastes different.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was verändert sich im Brot außer dem Austrocknen?',
        options: <String>[
          'Die Stärke ordnet sich neu',
          'Das Salz löst sich auf',
          'Die Hefe arbeitet weiter',
        ],
        correctIndex: 0,
        explanation: 'Der Vortrag sagt, dass sich die Stärke im Brot verändert und sich mit der Zeit neu ordnet.',
      ),
      ChoiceQuestion(
        prompt: 'Warum wird Brot im Kühlschrank schneller hart?',
        options: <String>[
          'Weil dort die Luft trockener ist',
          'Weil der Vorgang bei niedrigen Temperaturen schneller abläuft',
          'Weil das Brot dort Gerüche aufnimmt',
        ],
        correctIndex: 1,
        explanation: 'Bei niedrigen Temperaturen läuft dieser Vorgang besonders schnell ab.',
      ),
      ChoiceQuestion(
        prompt: 'Was empfiehlt der Vortrag für eine längere Aufbewahrung?',
        options: <String>[
          'Das Brot in Papier wickeln',
          'Das Brot in Scheiben schneiden',
          'Das Brot einfrieren',
        ],
        correctIndex: 2,
        explanation: 'Wer Brot länger aufbewahren möchte, sollte es einfrieren, denn im Gefrierfach stoppt der Vorgang fast ganz.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-24',
    level: CefrLevel.b1,
    genre: RadioGenre.news,
    title: 'Meldungen aus dem Landkreis',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Abend, hier sind die Meldungen aus dem Landkreis Auental.',
        english: 'Good evening, here is the news from the district of Auental.',
      ),
      RadioLine(
        german: 'Ab dem ersten Oktober fährt eine neue Nachtbuslinie zwischen Auental und Riedbach.',
        english: 'From the first of October a new night bus line will run between Auental and Riedbach.',
      ),
      RadioLine(
        german: 'Der Bus soll freitags und samstags jede Stunde verkehren, zunächst für ein Jahr.',
        english: 'The bus is to run every hour on Fridays and Saturdays, initially for one year.',
      ),
      RadioLine(
        german: 'Der Landkreis hatte den Versuch bereits im Frühjahr angekündigt, konnte aber keine Fahrer finden.',
        english: 'The district had already announced the trial in spring but could not find any drivers.',
      ),
      RadioLine(
        german: 'Nach Angaben der Verkehrsgesellschaft kostet das Angebot rund vierhunderttausend Euro.',
        english: 'According to the transport company, the service costs around four hundred thousand euros.',
      ),
      RadioLine(
        german: 'In Riedbach beginnt am Montag die Sanierung des Schulschwimmbads, das seit zwei Jahren geschlossen ist.',
        english: 'In Riedbach the refurbishment of the school pool, closed for two years, begins on Monday.',
      ),
      RadioLine(
        german: 'Die Klassen weichen bis zum Sommer in das Hallenbad der Nachbargemeinde aus.',
        english: 'Until the summer the classes will move to the indoor pool in the neighbouring village.',
      ),
      RadioLine(
        german: 'Eltern kritisieren die langen Fahrzeiten, halten die Lösung aber für besser als gar keinen Unterricht.',
        english: 'Parents criticise the long journey times but consider the solution better than no lessons at all.',
      ),
      RadioLine(
        german: 'Zum Schluss noch das Wetter für morgen mit Wolken und höchstens siebzehn Grad.',
        english: 'Finally the weather for tomorrow, with cloud and a high of seventeen degrees.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann startet die neue Nachtbuslinie?',
        options: <String>[
          'Am ersten September',
          'Am ersten November',
          'Am ersten Oktober',
        ],
        correctIndex: 2,
        explanation: 'Ab dem ersten Oktober fährt die neue Nachtbuslinie zwischen Auental und Riedbach.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viel kostet das Busangebot nach Angaben der Verkehrsgesellschaft?',
        options: <String>[
          'Rund vierhunderttausend Euro',
          'Rund vierzigtausend Euro',
          'Rund vier Millionen Euro',
        ],
        correctIndex: 0,
        explanation: 'Nach Angaben der Verkehrsgesellschaft kostet das Angebot rund vierhunderttausend Euro.',
      ),
      ChoiceQuestion(
        prompt: 'Warum begann der Versuch nicht schon im Frühjahr?',
        options: <String>[
          'Es fehlte das Geld',
          'Es fehlten Fahrer',
          'Es fehlten Busse',
        ],
        correctIndex: 1,
        explanation: 'Der Landkreis hatte den Versuch im Frühjahr angekündigt, konnte aber keine Fahrer finden.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-25',
    level: CefrLevel.b1,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Die Mühle von 1786',
    lines: <RadioLine>[
      RadioLine(
        german: 'Sie stehen jetzt vor dem großen Wasserrad der alten Mühle.',
        english: 'You are now standing in front of the large water wheel of the old mill.',
      ),
      RadioLine(
        german: 'Die Mühle wurde 1786 gebaut und war bis in die sechziger Jahre in Betrieb.',
        english: 'The mill was built in 1786 and remained in operation until the sixties.',
      ),
      RadioLine(
        german: 'Das Rad, das Sie hier sehen, ist eine Nachbildung aus dem Jahr 1998.',
        english: 'The wheel you can see here is a replica from 1998.',
      ),
      RadioLine(
        german: 'Das Original baute man ab, nachdem ein Hochwasser die Achse beschädigt hatte.',
        english: 'The original was taken down after a flood had damaged the axle.',
      ),
      RadioLine(
        german: 'Wenn Sie nach links treten, erkennen Sie den Kanal zum Wasserrad.',
        english: 'If you step to the left, you can make out the channel leading to the water wheel.',
      ),
      RadioLine(
        german: 'Der Müller musste die Schleuse jeden Morgen öffnen, um die Steine in Bewegung zu setzen.',
        english: 'Every morning the miller had to open the sluice in order to set the stones turning.',
      ),
      RadioLine(
        german: 'Im Obergeschoss lagerte das Getreide, das die Bauern aus den Dörfern brachten.',
        english: 'The grain that the farmers brought in from the villages was stored on the upper floor.',
      ),
      RadioLine(
        german: 'Ein Sack Mehl wog fünfzig Kilo und wurde mit dem Karren ins Dorf gebracht.',
        english: 'A sack of flour weighed fifty kilos and was taken to the village by cart.',
      ),
      RadioLine(
        german: 'Bitte gehen Sie nun die Treppe hinauf und wählen Sie die Nummer fünf.',
        english: 'Please now go up the stairs and select number five.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Aus welchem Jahr stammt das Rad, das die Besucher sehen?',
        options: <String>[
          'Aus dem Jahr 1786',
          'Aus dem Jahr 1998',
          'Aus den sechziger Jahren',
        ],
        correctIndex: 1,
        explanation: 'Das Rad, das man heute sieht, ist eine Nachbildung aus dem Jahr 1998.',
      ),
      ChoiceQuestion(
        prompt: 'Warum wurde das Original abgebaut?',
        options: <String>[
          'Ein Hochwasser hatte die Achse beschädigt',
          'Ein Brand hatte das Dach zerstört',
          'Der Kanal war zu schmal geworden',
        ],
        correctIndex: 0,
        explanation: 'Man baute das Original ab, nachdem ein Hochwasser die Achse beschädigt hatte.',
      ),
      ChoiceQuestion(
        prompt: 'Wie schwer war ein Sack Mehl?',
        options: <String>[
          'Fünfzehn Kilo',
          'Hundert Kilo',
          'Fünfzig Kilo',
        ],
        correctIndex: 2,
        explanation: 'Ein Sack Mehl wog fünfzig Kilo und wurde mit dem Karren ins Dorf gebracht.',
      ),
    ],
  ),
];
