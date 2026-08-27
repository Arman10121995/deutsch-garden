import 'models.dart';
import 'radio_models.dart';

/// B1 Gartenradio scripts.
///
/// Subordinate clauses, Perfekt and Präteritum, opinion and consequence. The
/// English is stored but hidden by default from B1 upward, so the learner
/// meets German first. Original text written for this app.
const List<RadioEpisode> radioB1Episodes = <RadioEpisode>[
  RadioEpisode(
    id: 'rd-b1-03',
    level: CefrLevel.b1,
    genre: RadioGenre.news,
    title: 'Neues Radwegenetz',
    lines: <RadioLine>[
      RadioLine(
        german: 'Die Stadt baut in den kommenden zwei Jahren neue Radwege.',
        english:
            'The city is building new cycle paths over the next two years.',
      ),
      RadioLine(
        german: 'Insgesamt sollen vierzig Kilometer entstehen.',
        english: 'Forty kilometres are to be created in total.',
      ),
      RadioLine(
        german: 'Der Bürgermeister sagte, das Ziel sei weniger Autoverkehr.',
        english: 'The mayor said the aim was less car traffic.',
      ),
      RadioLine(
        german: 'Einige Geschäfte befürchten allerdings weniger Kundschaft.',
        english: 'Some shops, however, fear fewer customers.',
      ),
      RadioLine(
        german: 'Denn an mehreren Straßen fallen Parkplätze weg.',
        english: 'Because parking spaces will disappear on several streets.',
      ),
      RadioLine(
        german: 'Eine Studie aus einer Nachbarstadt zeigt ein anderes Bild.',
        english: 'A study from a neighbouring city shows a different picture.',
      ),
      RadioLine(
        german: 'Dort stieg der Umsatz, nachdem die Radwege fertig waren.',
        english: 'There turnover rose after the cycle paths were finished.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie viele Kilometer Radweg sollen entstehen?',
        options: <String>['Vierzehn', 'Vierzig', 'Vierhundert'],
        correctIndex: 1,
        explanation: 'Insgesamt sollen vierzig Kilometer entstehen.',
      ),
      ChoiceQuestion(
        prompt: 'Warum sind einige Geschäfte skeptisch?',
        options: <String>[
          'Weil Parkplätze wegfallen',
          'Weil die Mieten steigen',
          'Weil sie umziehen müssen',
        ],
        correctIndex: 0,
        explanation: 'An mehreren Straßen fallen Parkplätze weg.',
      ),
      ChoiceQuestion(
        prompt: 'Was zeigt die Studie aus der Nachbarstadt?',
        options: <String>[
          'Der Umsatz ist gestiegen.',
          'Der Umsatz ist gefallen.',
          'Nichts hat sich geändert.',
        ],
        correctIndex: 0,
        explanation: 'Dort stieg der Umsatz, nachdem die Radwege fertig waren.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-04',
    level: CefrLevel.b1,
    genre: RadioGenre.lecture,
    title: 'Kurz erklärt: Wie Zinsen wirken',
    lines: <RadioLine>[
      RadioLine(
        german: 'Wer Geld leiht, zahlt dafür in der Regel Zinsen.',
        english: 'Anyone who borrows money usually pays interest for it.',
      ),
      RadioLine(
        german: 'Der Zinssatz gibt an, wie teuer das geliehene Geld ist.',
        english:
            'The interest rate indicates how expensive the borrowed money is.',
      ),
      RadioLine(
        german: 'Steigen die Zinsen, werden Kredite für alle teurer.',
        english:
            'If interest rates rise, loans become more expensive for everyone.',
      ),
      RadioLine(
        german:
            'Deshalb bauen Firmen dann oft weniger und stellen weniger ein.',
        english:
            'That is why companies then often build less and hire fewer people.',
      ),
      RadioLine(
        german: 'Auf der anderen Seite lohnt sich Sparen wieder mehr.',
        english: 'On the other hand, saving becomes worthwhile again.',
      ),
      RadioLine(
        german: 'Zentralbanken nutzen den Zins deshalb als Werkzeug.',
        english: 'Central banks therefore use interest as a tool.',
      ),
      RadioLine(
        german: 'Sie versuchen damit, die Preise stabil zu halten.',
        english: 'With it they try to keep prices stable.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was passiert, wenn die Zinsen steigen?',
        options: <String>[
          'Kredite werden teurer.',
          'Kredite werden billiger.',
          'Nichts ändert sich.',
        ],
        correctIndex: 0,
        explanation: 'Steigen die Zinsen, werden Kredite für alle teurer.',
      ),
      ChoiceQuestion(
        prompt: 'Was tun Firmen dann oft?',
        options: <String>[
          'Sie bauen weniger und stellen weniger ein.',
          'Sie bauen mehr.',
          'Sie erhöhen die Löhne.',
        ],
        correctIndex: 0,
        explanation:
            'Deshalb bauen Firmen dann oft weniger und stellen weniger ein.',
      ),
      ChoiceQuestion(
        prompt: 'Wozu nutzen Zentralbanken den Zins?',
        options: <String>[
          'Um die Preise stabil zu halten',
          'Um Steuern zu senken',
          'Um Löhne festzulegen',
        ],
        correctIndex: 0,
        explanation: 'Sie versuchen damit, die Preise stabil zu halten.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-05',
    level: CefrLevel.b1,
    genre: RadioGenre.diary,
    title: 'Ein Jahr ohne Auto',
    lines: <RadioLine>[
      RadioLine(
        german: 'Vor einem Jahr habe ich mein Auto verkauft.',
        english: 'A year ago I sold my car.',
      ),
      RadioLine(
        german: 'Damals dachte ich, ich würde es schnell vermissen.',
        english: 'At the time I thought I would miss it quickly.',
      ),
      RadioLine(
        german: 'Tatsächlich war der Anfang wirklich anstrengend.',
        english: 'In fact the beginning really was exhausting.',
      ),
      RadioLine(
        german: 'Vor allem beim Einkaufen habe ich das Auto vermisst.',
        english: 'Above all I missed the car when shopping.',
      ),
      RadioLine(
        german: 'Nach ein paar Monaten hatte ich mich daran gewöhnt.',
        english: 'After a few months I had got used to it.',
      ),
      RadioLine(
        german: 'Heute fahre ich fast alles mit dem Rad und spare viel Geld.',
        english:
            'Today I do almost everything by bike and save a lot of money.',
      ),
      RadioLine(
        german: 'Nur im Winter frage ich mich manchmal, ob es richtig war.',
        english: 'Only in winter do I sometimes wonder whether it was right.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann hat die Person das Auto verkauft?',
        options: <String>[
          'Vor einem Monat',
          'Vor einem Jahr',
          'Vor zehn Jahren',
        ],
        correctIndex: 1,
        explanation: 'Vor einem Jahr habe ich mein Auto verkauft.',
      ),
      ChoiceQuestion(
        prompt: 'Wobei hat sie das Auto besonders vermisst?',
        options: <String>['Beim Einkaufen', 'Bei der Arbeit', 'Im Urlaub'],
        correctIndex: 0,
        explanation: 'Vor allem beim Einkaufen habe ich das Auto vermisst.',
      ),
      ChoiceQuestion(
        prompt: 'Wie steht sie heute dazu?',
        options: <String>[
          'Sie bereut es völlig.',
          'Sie ist zufrieden, zweifelt aber im Winter manchmal.',
          'Sie will sofort ein neues Auto kaufen.',
        ],
        correctIndex: 1,
        explanation:
            'Sie spart viel Geld, fragt sich aber im Winter manchmal, ob es '
            'richtig war.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-06',
    level: CefrLevel.b1,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Die Altstadt',
    lines: <RadioLine>[
      RadioLine(
        german: 'Sie betreten nun die Altstadt durch das südliche Tor.',
        english: 'You are now entering the old town through the southern gate.',
      ),
      RadioLine(
        german: 'Die engen Gassen stammen aus dem Mittelalter.',
        english: 'The narrow lanes date from the Middle Ages.',
      ),
      RadioLine(
        german: 'Damals lebten hier vor allem Handwerker und Händler.',
        english: 'At that time craftsmen and traders lived here above all.',
      ),
      RadioLine(
        german: 'Viele Häuser wurden nach einem Brand neu gebaut.',
        english: 'Many houses were rebuilt after a fire.',
      ),
      RadioLine(
        german: 'Deshalb wirken sie einheitlicher, als man erwarten würde.',
        english: 'That is why they look more uniform than one would expect.',
      ),
      RadioLine(
        german: 'Achten Sie auf die Zeichen über den Türen.',
        english: 'Look out for the signs above the doors.',
      ),
      RadioLine(
        german: 'Sie zeigen, welches Handwerk dort einmal ausgeübt wurde.',
        english: 'They show which trade was once practised there.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Aus welcher Zeit stammen die Gassen?',
        options: <String>[
          'Aus dem Mittelalter',
          'Aus dem letzten Jahrhundert',
          'Aus der Antike',
        ],
        correctIndex: 0,
        explanation: 'Die engen Gassen stammen aus dem Mittelalter.',
      ),
      ChoiceQuestion(
        prompt: 'Warum wirken die Häuser einheitlich?',
        options: <String>[
          'Sie wurden nach einem Brand neu gebaut.',
          'Sie wurden alle renoviert.',
          'Sie gehören einer Familie.',
        ],
        correctIndex: 0,
        explanation: 'Viele Häuser wurden nach einem Brand neu gebaut.',
      ),
      ChoiceQuestion(
        prompt: 'Was zeigen die Zeichen über den Türen?',
        options: <String>[
          'Das frühere Handwerk',
          'Den Namen der Familie',
          'Das Baujahr',
        ],
        correctIndex: 0,
        explanation: 'Sie zeigen, welches Handwerk dort einmal ausgeübt wurde.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-07',
    level: CefrLevel.b1,
    genre: RadioGenre.news,
    title: 'Weniger Papier in den Ämtern',
    lines: <RadioLine>[
      RadioLine(
        german: 'Ab dem nächsten Jahr sollen viele Anträge digital laufen.',
        english: 'From next year many applications are to run digitally.',
      ),
      RadioLine(
        german: 'Wer will, kann Formulare weiterhin auf Papier abgeben.',
        english: 'Anyone who wants to can still submit forms on paper.',
      ),
      RadioLine(
        german: 'Die Verwaltung erhofft sich kürzere Bearbeitungszeiten.',
        english: 'The administration hopes for shorter processing times.',
      ),
      RadioLine(
        german:
            'Kritiker weisen darauf hin, dass nicht alle einen Computer haben.',
        english: 'Critics point out that not everyone has a computer.',
      ),
      RadioLine(
        german: 'Deshalb bleiben die Schalter im Rathaus geöffnet.',
        english: 'For that reason the counters in the town hall stay open.',
      ),
      RadioLine(
        german: 'Zusätzlich soll es Beratung für ältere Menschen geben.',
        english: 'In addition there is to be advice for older people.',
      ),
      RadioLine(
        german: 'Ob der Plan aufgeht, wird sich erst im Sommer zeigen.',
        english: 'Whether the plan works will only become clear in summer.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was ändert sich ab dem nächsten Jahr?',
        options: <String>[
          'Viele Anträge laufen digital.',
          'Alle Ämter schließen.',
          'Formulare kosten Geld.',
        ],
        correctIndex: 0,
        explanation:
            'Ab dem nächsten Jahr sollen viele Anträge digital laufen.',
      ),
      ChoiceQuestion(
        prompt: 'Worauf weisen die Kritiker hin?',
        options: <String>[
          'Nicht alle haben einen Computer.',
          'Die Kosten sind zu hoch.',
          'Die Ämter sind zu klein.',
        ],
        correctIndex: 0,
        explanation:
            'Kritiker weisen darauf hin, dass nicht alle einen Computer haben.',
      ),
      ChoiceQuestion(
        prompt: 'Was bleibt trotzdem bestehen?',
        options: <String>[
          'Die Schalter im Rathaus',
          'Die alten Formulare',
          'Die Gebühren',
        ],
        correctIndex: 0,
        explanation: 'Deshalb bleiben die Schalter im Rathaus geöffnet.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-08',
    level: CefrLevel.b1,
    genre: RadioGenre.lecture,
    title: 'Kurz erklärt: Warum Sprachen sich ändern',
    lines: <RadioLine>[
      RadioLine(
        german: 'Keine lebende Sprache bleibt über Jahrhunderte gleich.',
        english: 'No living language stays the same over centuries.',
      ),
      RadioLine(
        german: 'Wörter verschwinden, andere kommen neu dazu.',
        english: 'Words disappear, others are newly added.',
      ),
      RadioLine(
        german: 'Oft kommen neue Wörter mit neuen Techniken in die Sprache.',
        english:
            'New words often enter the language along with new technologies.',
      ),
      RadioLine(
        german: 'Auch die Aussprache verändert sich langsam.',
        english: 'Pronunciation also changes slowly.',
      ),
      RadioLine(
        german: 'Manche Menschen ärgern sich über solche Veränderungen.',
        english: 'Some people are annoyed by such changes.',
      ),
      RadioLine(
        german: 'Sprachwissenschaftler sehen darin dagegen etwas Normales.',
        english: 'Linguists, by contrast, see something normal in it.',
      ),
      RadioLine(
        german:
            'Eine Sprache, die sich nicht mehr ändert, wird kaum noch gesprochen.',
        english: 'A language that no longer changes is barely spoken any more.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Womit kommen neue Wörter oft in die Sprache?',
        options: <String>[
          'Mit neuen Techniken',
          'Mit alten Büchern',
          'Mit Gesetzen',
        ],
        correctIndex: 0,
        explanation:
            'Oft kommen neue Wörter mit neuen Techniken in die Sprache.',
      ),
      ChoiceQuestion(
        prompt: 'Wie sehen Sprachwissenschaftler die Veränderungen?',
        options: <String>[
          'Als etwas Normales',
          'Als großes Problem',
          'Als Fehler der Jugend',
        ],
        correctIndex: 0,
        explanation: 'Sprachwissenschaftler sehen darin etwas Normales.',
      ),
      ChoiceQuestion(
        prompt: 'Was gilt für eine Sprache, die sich nicht mehr ändert?',
        options: <String>[
          'Sie wird kaum noch gesprochen.',
          'Sie ist besonders rein.',
          'Sie wird leichter zu lernen.',
        ],
        correctIndex: 0,
        explanation:
            'Eine Sprache, die sich nicht mehr ändert, wird kaum noch '
            'gesprochen.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-09',
    level: CefrLevel.b1,
    genre: RadioGenre.voicemail,
    title: 'Nachricht von der Werkstatt',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Tag, hier ist die Werkstatt Meyer.',
        english: 'Good afternoon, this is Meyer garage.',
      ),
      RadioLine(
        german: 'Wir haben Ihr Fahrrad angesehen, wie besprochen.',
        english: 'We have looked at your bicycle, as agreed.',
      ),
      RadioLine(
        german: 'Die Bremsen sind stärker abgenutzt, als wir dachten.',
        english: 'The brakes are more worn than we thought.',
      ),
      RadioLine(
        german: 'Wir müssten sie komplett austauschen.',
        english: 'We would have to replace them completely.',
      ),
      RadioLine(
        german: 'Das würde etwa achtzig Euro zusätzlich kosten.',
        english: 'That would cost about eighty euros extra.',
      ),
      RadioLine(
        german: 'Ohne die Reparatur können wir das Rad nicht freigeben.',
        english: 'Without the repair we cannot release the bike.',
      ),
      RadioLine(
        german: 'Melden Sie sich bitte, damit wir weitermachen können.',
        english: 'Please get in touch so that we can continue.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was ist das Problem am Fahrrad?',
        options: <String>[
          'Die Bremsen sind abgenutzt.',
          'Der Reifen ist kaputt.',
          'Die Kette fehlt.',
        ],
        correctIndex: 0,
        explanation: 'Die Bremsen sind stärker abgenutzt, als wir dachten.',
      ),
      ChoiceQuestion(
        prompt: 'Was kostet die Reparatur zusätzlich?',
        options: <String>['Etwa acht Euro', 'Etwa achtzig Euro', 'Nichts'],
        correctIndex: 1,
        explanation: 'Das würde etwa achtzig Euro zusätzlich kosten.',
      ),
      ChoiceQuestion(
        prompt: 'Was passiert ohne die Reparatur?',
        options: <String>[
          'Das Rad wird nicht freigegeben.',
          'Das Rad wird verkauft.',
          'Die Werkstatt repariert es kostenlos.',
        ],
        correctIndex: 0,
        explanation: 'Ohne die Reparatur können wir das Rad nicht freigeben.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-10',
    level: CefrLevel.b1,
    genre: RadioGenre.weather,
    title: 'Wetterlage der Woche',
    lines: <RadioLine>[
      RadioLine(
        german: 'Die kommende Woche bringt einen deutlichen Wechsel.',
        english: 'The coming week brings a clear change.',
      ),
      RadioLine(
        german: 'Zu Beginn bleibt es trocken und für die Jahreszeit zu mild.',
        english: 'At the start it stays dry and too mild for the season.',
      ),
      RadioLine(
        german: 'Ab Mittwoch zieht von Westen her Regen auf.',
        english: 'From Wednesday rain moves in from the west.',
      ),
      RadioLine(
        german: 'In den Nächten kann es örtlich neblig werden.',
        english: 'At night it can become foggy in places.',
      ),
      RadioLine(
        german: 'Am Freitag sinken die Temperaturen spürbar.',
        english: 'On Friday temperatures drop noticeably.',
      ),
      RadioLine(
        german: 'Über dem Wochenende ist noch nichts entschieden.',
        english: 'Nothing has been decided yet for the weekend.',
      ),
      RadioLine(
        german: 'Die Modelle widersprechen sich bislang deutlich.',
        english: 'The models clearly contradict each other so far.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie ist das Wetter zu Beginn der Woche?',
        options: <String>['Trocken und mild', 'Kalt und nass', 'Stürmisch'],
        correctIndex: 0,
        explanation:
            'Zu Beginn bleibt es trocken und für die Jahreszeit zu mild.',
      ),
      ChoiceQuestion(
        prompt: 'Ab wann regnet es?',
        options: <String>['Ab Montag', 'Ab Mittwoch', 'Ab Sonntag'],
        correctIndex: 1,
        explanation: 'Ab Mittwoch zieht von Westen her Regen auf.',
      ),
      ChoiceQuestion(
        prompt: 'Warum ist das Wochenende unsicher?',
        options: <String>[
          'Die Modelle widersprechen sich.',
          'Es fehlen Messstationen.',
          'Es ist zu weit entfernt.',
        ],
        correctIndex: 0,
        explanation: 'Die Modelle widersprechen sich bislang deutlich.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-11',
    level: CefrLevel.b1,
    genre: RadioGenre.recipe,
    title: 'Linsensuppe wie bei der Großmutter',
    lines: <RadioLine>[
      RadioLine(
        german: 'Dieses Rezept stammt angeblich von meiner Großmutter.',
        english: 'This recipe supposedly comes from my grandmother.',
      ),
      RadioLine(
        german: 'Weichen Sie die Linsen am besten über Nacht ein.',
        english: 'It is best to soak the lentils overnight.',
      ),
      RadioLine(
        german: 'Am nächsten Tag braten Sie Zwiebeln und Karotten an.',
        english: 'The next day fry onions and carrots.',
      ),
      RadioLine(
        german: 'Geben Sie die Linsen dazu und füllen Sie mit Brühe auf.',
        english: 'Add the lentils and top up with stock.',
      ),
      RadioLine(
        german: 'Alles muss etwa eine Stunde leise köcheln.',
        english: 'Everything has to simmer gently for about an hour.',
      ),
      RadioLine(
        german: 'Erst am Ende kommt ein Schuss Essig hinein.',
        english: 'Only at the end does a dash of vinegar go in.',
      ),
      RadioLine(
        german:
            'Das klingt seltsam, macht aber den entscheidenden Unterschied.',
        english: 'That sounds strange, but it makes the decisive difference.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was soll man über Nacht machen?',
        options: <String>[
          'Die Linsen einweichen',
          'Die Suppe kochen',
          'Die Zwiebeln schneiden',
        ],
        correctIndex: 0,
        explanation: 'Weichen Sie die Linsen am besten über Nacht ein.',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange köchelt die Suppe?',
        options: <String>['Zehn Minuten', 'Etwa eine Stunde', 'Drei Stunden'],
        correctIndex: 1,
        explanation: 'Alles muss etwa eine Stunde leise köcheln.',
      ),
      ChoiceQuestion(
        prompt: 'Was kommt erst am Ende hinein?',
        options: <String>['Ein Schuss Essig', 'Sahne', 'Mehl'],
        correctIndex: 0,
        explanation: 'Erst am Ende kommt ein Schuss Essig hinein.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-12',
    level: CefrLevel.b1,
    genre: RadioGenre.announcement,
    title: 'Hinweis im Schwimmbad',
    lines: <RadioLine>[
      RadioLine(
        german: 'Ein Hinweis an alle Gäste im Hallenbad.',
        english: 'A notice to all guests in the indoor pool.',
      ),
      RadioLine(
        german: 'Das große Becken wird ab siebzehn Uhr für einen Kurs genutzt.',
        english: 'The large pool will be used for a course from five.',
      ),
      RadioLine(
        german: 'Das kleine Becken bleibt wie gewohnt geöffnet.',
        english: 'The small pool stays open as usual.',
      ),
      RadioLine(
        german: 'Wer noch Bahnen schwimmen möchte, sollte das vorher tun.',
        english:
            'Anyone who still wants to swim lengths should do so beforehand.',
      ),
      RadioLine(
        german: 'Ab morgen gelten wieder die normalen Zeiten.',
        english: 'From tomorrow the normal times apply again.',
      ),
      RadioLine(
        german: 'Wir bitten um Ihr Verständnis für die Einschränkung.',
        english: 'We ask for your understanding regarding the restriction.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was passiert ab siebzehn Uhr?',
        options: <String>[
          'Das große Becken wird für einen Kurs genutzt.',
          'Das Bad schließt.',
          'Der Eintritt wird teurer.',
        ],
        correctIndex: 0,
        explanation:
            'Das große Becken wird ab siebzehn Uhr für einen Kurs genutzt.',
      ),
      ChoiceQuestion(
        prompt: 'Was bleibt geöffnet?',
        options: <String>['Das kleine Becken', 'Die Sauna', 'Nichts'],
        correctIndex: 0,
        explanation: 'Das kleine Becken bleibt wie gewohnt geöffnet.',
      ),
      ChoiceQuestion(
        prompt: 'Ab wann gelten die normalen Zeiten?',
        options: <String>['Ab morgen', 'Ab nächster Woche', 'Ab Montag'],
        correctIndex: 0,
        explanation: 'Ab morgen gelten wieder die normalen Zeiten.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-13',
    level: CefrLevel.b1,
    genre: RadioGenre.diary,
    title: 'Warum ich wieder lese',
    lines: <RadioLine>[
      RadioLine(
        german: 'Jahrelang habe ich kaum ein Buch zu Ende gelesen.',
        english: 'For years I hardly finished a book.',
      ),
      RadioLine(
        german: 'Abends war ich müde und griff lieber zum Telefon.',
        english:
            'In the evening I was tired and preferred to reach for my phone.',
      ),
      RadioLine(
        german: 'Im Januar habe ich mir etwas Einfaches vorgenommen.',
        english: 'In January I set myself something simple.',
      ),
      RadioLine(
        german: 'Zwanzig Seiten am Tag, egal welches Buch.',
        english: 'Twenty pages a day, no matter which book.',
      ),
      RadioLine(
        german: 'Anfangs fiel mir das schwerer, als ich zugeben wollte.',
        english: 'At first I found that harder than I wanted to admit.',
      ),
      RadioLine(
        german: 'Inzwischen lese ich fast automatisch nach dem Abendessen.',
        english: 'By now I read almost automatically after dinner.',
      ),
      RadioLine(
        german: 'Es waren nicht die Bücher, es war die feste Zeit.',
        english: 'It was not the books, it was the fixed time.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was hat die Person sich vorgenommen?',
        options: <String>[
          'Zwanzig Seiten am Tag',
          'Ein Buch pro Woche',
          'Kein Telefon mehr',
        ],
        correctIndex: 0,
        explanation: 'Zwanzig Seiten am Tag, egal welches Buch.',
      ),
      ChoiceQuestion(
        prompt: 'Wie war der Anfang?',
        options: <String>[
          'Schwerer als erwartet',
          'Sehr leicht',
          'Völlig unmöglich',
        ],
        correctIndex: 0,
        explanation: 'Anfangs fiel mir das schwerer, als ich zugeben wollte.',
      ),
      ChoiceQuestion(
        prompt: 'Was war laut Text entscheidend?',
        options: <String>[
          'Die feste Zeit',
          'Die richtigen Bücher',
          'Ein neues Telefon',
        ],
        correctIndex: 0,
        explanation: 'Es waren nicht die Bücher, es war die feste Zeit.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b1-14',
    level: CefrLevel.b1,
    genre: RadioGenre.news,
    title: 'Streit um den alten Baum',
    lines: <RadioLine>[
      RadioLine(
        german: 'Vor dem Rathaus steht eine über hundert Jahre alte Eiche.',
        english:
            'In front of the town hall stands an oak over a hundred years old.',
      ),
      RadioLine(
        german: 'Für den geplanten Anbau müsste sie gefällt werden.',
        english: 'For the planned extension it would have to be felled.',
      ),
      RadioLine(
        german:
            'Eine Bürgerinitiative hat inzwischen Unterschriften gesammelt.',
        english: 'A citizens initiative has meanwhile collected signatures.',
      ),
      RadioLine(
        german: 'Über zweitausend Menschen haben unterschrieben.',
        english: 'Over two thousand people have signed.',
      ),
      RadioLine(
        german: 'Die Stadt prüft nun, ob der Anbau kleiner ausfallen kann.',
        english:
            'The city is now examining whether the extension can be smaller.',
      ),
      RadioLine(
        german: 'Eine Entscheidung soll im Herbst fallen.',
        english: 'A decision is to be made in autumn.',
      ),
      RadioLine(
        german: 'Bis dahin bleibt der Baum, wo er ist.',
        english: 'Until then the tree stays where it is.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Warum soll die Eiche gefällt werden?',
        options: <String>[
          'Wegen eines geplanten Anbaus',
          'Weil sie krank ist',
          'Wegen eines Sturms',
        ],
        correctIndex: 0,
        explanation: 'Für den geplanten Anbau müsste sie gefällt werden.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viele Menschen haben unterschrieben?',
        options: <String>['Zweihundert', 'Über zweitausend', 'Zwanzigtausend'],
        correctIndex: 1,
        explanation: 'Über zweitausend Menschen haben unterschrieben.',
      ),
      ChoiceQuestion(
        prompt: 'Wann soll entschieden werden?',
        options: <String>['Im Sommer', 'Im Herbst', 'Im Winter'],
        correctIndex: 1,
        explanation: 'Eine Entscheidung soll im Herbst fallen.',
      ),
    ],
  ),
];
