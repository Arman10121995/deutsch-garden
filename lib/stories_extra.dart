import 'models.dart';
import 'stories.dart';

/// A second collection of graded readers, two per level.
///
/// Original stories written for this app. They follow the same shape as the
/// first collection — parallel translation, a tappable glossary and
/// comprehension questions per chapter — and are levelled by the language they
/// use rather than by subject: an A1 story stays in the present tense with
/// short main clauses, and only by B1 do subordinate clauses and the Perfekt
/// carry the narration.
const List<Story> extraStories = <Story>[
  // ---------------------------------------------------------------- A1 ----
  Story(
    id: 'st-a1-03',
    level: CefrLevel.a1,
    emoji: '🐕',
    title: 'Ein Hund im Hausflur',
    titleEnglish: 'A dog in the hallway',
    blurb: 'A small dog is sitting in the hallway and nobody knows whose it is.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-a1-03-c1',
        title: 'Wer bist du?',
        titleEnglish: 'Who are you?',
        lines: <StoryLine>[
          StoryLine('Nina kommt nach Hause.', 'Nina comes home.'),
          StoryLine('Im Hausflur sitzt ein kleiner Hund.', 'A small dog is sitting in the hallway.'),
          StoryLine('Der Hund ist braun und sehr dünn.', 'The dog is brown and very thin.'),
          StoryLine('Er hat kein Halsband.', 'It has no collar.'),
          StoryLine('„Wem gehörst du?“, fragt Nina.', '"Who do you belong to?" Nina asks.'),
          StoryLine('Der Hund sagt natürlich nichts.', 'The dog of course says nothing.'),
          StoryLine('Er wedelt nur mit dem Schwanz.', 'It only wags its tail.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('der Hausflur', 'hallway'),
          StoryGloss('dünn', 'thin'),
          StoryGloss('das Halsband', 'collar'),
          StoryGloss('wedeln', 'to wag'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wo sitzt der Hund?',
            options: <String>['Im Hausflur', 'Im Garten', 'Auf der Straße'],
            correctIndex: 0,
            explanation: 'Im Hausflur sitzt ein kleiner Hund.',
          ),
          ChoiceQuestion(
            prompt: 'Was hat der Hund nicht?',
            options: <String>['Ein Halsband', 'Einen Schwanz', 'Vier Beine'],
            correctIndex: 0,
            explanation: 'Er hat kein Halsband.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a1-03-c2',
        title: 'Milch und Brot',
        titleEnglish: 'Milk and bread',
        lines: <StoryLine>[
          StoryLine('Nina geht in ihre Wohnung.', 'Nina goes into her flat.'),
          StoryLine('Sie holt Milch und ein Stück Brot.', 'She fetches milk and a piece of bread.'),
          StoryLine('Der Hund trinkt und frisst schnell.', 'The dog drinks and eats quickly.'),
          StoryLine('Dann legt er sich vor ihre Tür.', 'Then it lies down in front of her door.'),
          StoryLine('Nina lacht. „Du bleibst also hier.“', 'Nina laughs. "So you are staying here."'),
          StoryLine('Sie fragt die Nachbarn nach dem Hund.', 'She asks the neighbours about the dog.'),
          StoryLine('Aber niemand kennt ihn.', 'But nobody knows it.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('holen', 'to fetch'),
          StoryGloss('fressen', 'to eat', 'Used for animals; Menschen essen.'),
          StoryGloss('sich legen', 'to lie down'),
          StoryGloss('der Nachbar', 'neighbour'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was bringt Nina dem Hund?',
            options: <String>['Milch und Brot', 'Fleisch', 'Wasser'],
            correctIndex: 0,
            explanation: 'Sie holt Milch und ein Stück Brot.',
          ),
          ChoiceQuestion(
            prompt: 'Was sagen die Nachbarn?',
            options: <String>[
              'Niemand kennt den Hund.',
              'Der Hund gehört Herrn Klein.',
              'Der Hund ist krank.',
            ],
            correctIndex: 0,
            explanation: 'Aber niemand kennt ihn.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a1-03-c3',
        title: 'Ein Zettel an der Tür',
        titleEnglish: 'A note on the door',
        lines: <StoryLine>[
          StoryLine('Nina schreibt einen Zettel.', 'Nina writes a note.'),
          StoryLine('„Hund gefunden. Bitte klingeln. Wohnung vier.“', '"Dog found. Please ring. Flat four."'),
          StoryLine('Am Abend klingelt es.', 'In the evening the bell rings.'),
          StoryLine('Vor der Tür steht ein alter Mann.', 'An old man is standing at the door.'),
          StoryLine('„Das ist Rocky“, sagt er leise.', '"That is Rocky," he says quietly.'),
          StoryLine('Der Hund läuft sofort zu ihm.', 'The dog immediately runs to him.'),
          StoryLine('Nina freut sich und ist ein bisschen traurig.', 'Nina is happy and a little sad.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('der Zettel', 'note'),
          StoryGloss('klingeln', 'to ring the bell'),
          StoryGloss('leise', 'quietly'),
          StoryGloss('traurig', 'sad'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was macht Nina?',
            options: <String>[
              'Sie schreibt einen Zettel.',
              'Sie ruft die Polizei.',
              'Sie geht zum Arzt.',
            ],
            correctIndex: 0,
            explanation: 'Nina schreibt einen Zettel.',
          ),
          ChoiceQuestion(
            prompt: 'Wie heißt der Hund?',
            options: <String>['Rocky', 'Bruno', 'Max'],
            correctIndex: 0,
            explanation: '„Das ist Rocky“, sagt er leise.',
          ),
          ChoiceQuestion(
            prompt: 'Wie fühlt sich Nina am Ende?',
            options: <String>[
              'Froh und ein bisschen traurig',
              'Sehr wütend',
              'Ganz gleichgültig',
            ],
            correctIndex: 0,
            explanation: 'Nina freut sich und ist ein bisschen traurig.',
          ),
        ],
      ),
    ],
  ),
  Story(
    id: 'st-a1-04',
    level: CefrLevel.a1,
    emoji: '🔑',
    title: 'Der falsche Schlüssel',
    titleEnglish: 'The wrong key',
    blurb: 'Jonas cannot open his door, and the reason is simpler than he thinks.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-a1-04-c1',
        title: 'Die Tür geht nicht auf',
        titleEnglish: 'The door will not open',
        lines: <StoryLine>[
          StoryLine('Jonas steht vor seiner Wohnung.', 'Jonas is standing in front of his flat.'),
          StoryLine('Er nimmt den Schlüssel aus der Tasche.', 'He takes the key out of his pocket.'),
          StoryLine('Der Schlüssel passt nicht.', 'The key does not fit.'),
          StoryLine('Jonas probiert es noch einmal.', 'Jonas tries again.'),
          StoryLine('Die Tür bleibt zu.', 'The door stays shut.'),
          StoryLine('Er wird langsam nervös.', 'He slowly gets nervous.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('passen', 'to fit'),
          StoryGloss('probieren', 'to try'),
          StoryGloss('nervös', 'nervous'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was ist das Problem?',
            options: <String>[
              'Der Schlüssel passt nicht.',
              'Jonas hat keinen Schlüssel.',
              'Die Tür ist offen.',
            ],
            correctIndex: 0,
            explanation: 'Der Schlüssel passt nicht.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a1-04-c2',
        title: 'Ein Anruf',
        titleEnglish: 'A phone call',
        lines: <StoryLine>[
          StoryLine('Jonas ruft seine Freundin an.', 'Jonas calls his girlfriend.'),
          StoryLine('„Ich komme nicht in die Wohnung“, sagt er.', '"I cannot get into the flat," he says.'),
          StoryLine('„Welche Wohnung denn?“, fragt sie.', '"Which flat?" she asks.'),
          StoryLine('„Nummer zwölf, natürlich.“', '"Number twelve, of course."'),
          StoryLine('Sie lacht laut.', 'She laughs loudly.'),
          StoryLine('„Wir wohnen jetzt in Nummer einundzwanzig.“', '"We live in number twenty-one now."'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('anrufen', 'to call', 'Separable: Er ruft sie an.'),
          StoryGloss('welche', 'which'),
          StoryGloss('laut', 'loudly'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Welche Nummer probiert Jonas?',
            options: <String>['Zwölf', 'Zwanzig', 'Einundzwanzig'],
            correctIndex: 0,
            explanation: '„Nummer zwölf, natürlich.“',
          ),
          ChoiceQuestion(
            prompt: 'Wo wohnen sie jetzt?',
            options: <String>['In Nummer zwölf', 'In Nummer einundzwanzig', 'In einem Haus'],
            correctIndex: 1,
            explanation: '„Wir wohnen jetzt in Nummer einundzwanzig.“',
          ),
        ],
      ),
    ],
  ),

  // ---------------------------------------------------------------- A2 ----
  Story(
    id: 'st-a2-03',
    level: CefrLevel.a2,
    emoji: '🥖',
    title: 'Die Bäckerei am Eck',
    titleEnglish: 'The bakery on the corner',
    blurb: 'The old bakery is closing, and the neighbourhood has other plans.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-a2-03-c1',
        title: 'Ein Schild im Fenster',
        titleEnglish: 'A sign in the window',
        lines: <StoryLine>[
          StoryLine('Seit vierzig Jahren gibt es die Bäckerei am Eck.', 'The bakery on the corner has been there for forty years.'),
          StoryLine('Heute hängt ein Schild im Fenster.', 'Today there is a sign in the window.'),
          StoryLine('„Wir schließen Ende des Monats.“', '"We are closing at the end of the month."'),
          StoryLine('Frau Özdemir liest es zweimal.', 'Mrs Özdemir reads it twice.'),
          StoryLine('Sie kauft hier jeden Morgen ihr Brot.', 'She buys her bread here every morning.'),
          StoryLine('Im Laden ist es still.', 'It is quiet in the shop.'),
          StoryLine('Der Bäcker sieht müde aus.', 'The baker looks tired.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('das Schild', 'sign'),
          StoryGloss('schließen', 'to close'),
          StoryGloss('still', 'quiet'),
          StoryGloss('müde', 'tired'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was steht auf dem Schild?',
            options: <String>[
              'Die Bäckerei schließt Ende des Monats.',
              'Die Bäckerei zieht um.',
              'Es gibt neues Brot.',
            ],
            correctIndex: 0,
            explanation: '„Wir schließen Ende des Monats.“',
          ),
          ChoiceQuestion(
            prompt: 'Wie lange gibt es die Bäckerei schon?',
            options: <String>['Seit vier Jahren', 'Seit vierzig Jahren', 'Seit hundert Jahren'],
            correctIndex: 1,
            explanation: 'Seit vierzig Jahren gibt es die Bäckerei am Eck.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a2-03-c2',
        title: 'Warum eigentlich?',
        titleEnglish: 'But why?',
        lines: <StoryLine>[
          StoryLine('„Warum schließen Sie?“, fragt Frau Özdemir.', '"Why are you closing?" Mrs Özdemir asks.'),
          StoryLine('„Die Miete ist zu hoch geworden“, antwortet er.', '"The rent has become too high," he answers.'),
          StoryLine('„Und mein Sohn will die Bäckerei nicht.“', '"And my son does not want the bakery."'),
          StoryLine('Frau Özdemir erzählt es den Nachbarn.', 'Mrs Özdemir tells the neighbours.'),
          StoryLine('Am Abend sprechen alle über die Bäckerei.', 'In the evening everyone is talking about the bakery.'),
          StoryLine('Jemand hat eine Idee.', 'Someone has an idea.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('die Miete', 'rent'),
          StoryGloss('antworten', 'to answer'),
          StoryGloss('erzählen', 'to tell'),
          StoryGloss('die Idee', 'idea'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Warum schließt die Bäckerei?',
            options: <String>[
              'Die Miete ist zu hoch und der Sohn will sie nicht.',
              'Der Bäcker ist krank.',
              'Es kommen keine Kunden.',
            ],
            correctIndex: 0,
            explanation:
                'Die Miete ist zu hoch geworden, und sein Sohn will die '
                'Bäckerei nicht.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a2-03-c3',
        title: 'Zusammen geht es',
        titleEnglish: 'Together it works',
        lines: <StoryLine>[
          StoryLine('Zwölf Nachbarn treffen sich im Hinterzimmer.', 'Twelve neighbours meet in the back room.'),
          StoryLine('Sie wollen die Bäckerei zusammen übernehmen.', 'They want to take over the bakery together.'),
          StoryLine('Jeder zahlt einen kleinen Betrag im Monat.', 'Each pays a small amount per month.'),
          StoryLine('Der Bäcker soll weiter backen, aber weniger arbeiten.', 'The baker is to keep baking, but work less.'),
          StoryLine('Zuerst glaubt niemand richtig daran.', 'At first nobody really believes in it.'),
          StoryLine('Aber nach drei Monaten läuft es gut.', 'But after three months it is going well.'),
          StoryLine('Das Schild im Fenster ist längst verschwunden.', 'The sign in the window disappeared long ago.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('übernehmen', 'to take over'),
          StoryGloss('der Betrag', 'amount'),
          StoryGloss('verschwinden', 'to disappear'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was machen die Nachbarn?',
            options: <String>[
              'Sie übernehmen die Bäckerei zusammen.',
              'Sie kaufen woanders ein.',
              'Sie schreiben an die Zeitung.',
            ],
            correctIndex: 0,
            explanation: 'Sie wollen die Bäckerei zusammen übernehmen.',
          ),
          ChoiceQuestion(
            prompt: 'Wie ist die Lage nach drei Monaten?',
            options: <String>['Es läuft gut.', 'Die Bäckerei ist zu.', 'Der Bäcker ist weg.'],
            correctIndex: 0,
            explanation: 'Aber nach drei Monaten läuft es gut.',
          ),
        ],
      ),
    ],
  ),
  Story(
    id: 'st-a2-04',
    level: CefrLevel.a2,
    emoji: '📻',
    title: 'Das alte Radio',
    titleEnglish: 'The old radio',
    blurb: 'A radio from a flea market plays something it should not.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-a2-04-c1',
        title: 'Fünf Euro',
        titleEnglish: 'Five euros',
        lines: <StoryLine>[
          StoryLine('Auf dem Flohmarkt findet Lena ein altes Radio.', 'At the flea market Lena finds an old radio.'),
          StoryLine('Es kostet nur fünf Euro.', 'It costs only five euros.'),
          StoryLine('Der Verkäufer sagt, es funktioniert noch.', 'The seller says it still works.'),
          StoryLine('Zu Hause stellt sie es auf den Tisch.', 'At home she puts it on the table.'),
          StoryLine('Sie dreht langsam an dem Knopf.', 'She slowly turns the knob.'),
          StoryLine('Zuerst hört sie nur ein Rauschen.', 'At first she hears only static.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('der Flohmarkt', 'flea market'),
          StoryGloss('funktionieren', 'to work, function'),
          StoryGloss('der Knopf', 'knob, button'),
          StoryGloss('das Rauschen', 'static, hiss'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wo findet Lena das Radio?',
            options: <String>['Auf dem Flohmarkt', 'Im Keller', 'Im Laden'],
            correctIndex: 0,
            explanation: 'Auf dem Flohmarkt findet Lena ein altes Radio.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a2-04-c2',
        title: 'Eine fremde Stimme',
        titleEnglish: 'A strange voice',
        lines: <StoryLine>[
          StoryLine('Plötzlich spricht eine Stimme aus dem Radio.', 'Suddenly a voice speaks from the radio.'),
          StoryLine('Sie liest Namen und Zahlen vor.', 'It reads out names and numbers.'),
          StoryLine('Die Stimme klingt sehr ruhig.', 'The voice sounds very calm.'),
          StoryLine('Lena versteht kein einziges Wort davon.', 'Lena does not understand a single word of it.'),
          StoryLine('Nach zwei Minuten ist wieder Ruhe.', 'After two minutes it is quiet again.'),
          StoryLine('Am nächsten Abend passiert das Gleiche.', 'The next evening the same thing happens.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('plötzlich', 'suddenly'),
          StoryGloss('die Stimme', 'voice'),
          StoryGloss('vorlesen', 'to read aloud'),
          StoryGloss('das Gleiche', 'the same thing'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was liest die Stimme vor?',
            options: <String>['Namen und Zahlen', 'Ein Gedicht', 'Die Nachrichten'],
            correctIndex: 0,
            explanation: 'Sie liest Namen und Zahlen vor.',
          ),
          ChoiceQuestion(
            prompt: 'Was passiert am nächsten Abend?',
            options: <String>['Das Gleiche', 'Nichts', 'Das Radio geht kaputt.'],
            correctIndex: 0,
            explanation: 'Am nächsten Abend passiert das Gleiche.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-a2-04-c3',
        title: 'Die Erklärung',
        titleEnglish: 'The explanation',
        lines: <StoryLine>[
          StoryLine('Lena fragt einen Freund, der sich mit Technik auskennt.', 'Lena asks a friend who knows about technology.'),
          StoryLine('Er hört sich die Sendung an und lächelt.', 'He listens to the broadcast and smiles.'),
          StoryLine('„Das ist ein Zahlensender“, erklärt er.', '"That is a numbers station," he explains.'),
          StoryLine('„Solche Sender gibt es seit vielen Jahrzehnten.“', '"Such stations have existed for many decades."'),
          StoryLine('„Niemand weiß genau, wer dahintersteckt.“', '"Nobody knows exactly who is behind them."'),
          StoryLine('Lena lässt das Radio jetzt jeden Abend laufen.', 'Lena now leaves the radio on every evening.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('sich auskennen', 'to know about something'),
          StoryGloss('die Sendung', 'broadcast'),
          StoryGloss('erklären', 'to explain'),
          StoryGloss('das Jahrzehnt', 'decade'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was ist die Erklärung?',
            options: <String>[
              'Es ist ein Zahlensender.',
              'Das Radio ist kaputt.',
              'Es ist ein Nachbar.',
            ],
            correctIndex: 0,
            explanation: '„Das ist ein Zahlensender“, erklärt er.',
          ),
          ChoiceQuestion(
            prompt: 'Was weiß man über die Sender?',
            options: <String>[
              'Niemand weiß genau, wer dahintersteckt.',
              'Sie gehören dem Staat.',
              'Sie sind neu.',
            ],
            correctIndex: 0,
            explanation: '„Niemand weiß genau, wer dahintersteckt.“',
          ),
        ],
      ),
    ],
  ),

  // ---------------------------------------------------------------- B1 ----
  Story(
    id: 'st-b1-03',
    level: CefrLevel.b1,
    emoji: '🧭',
    title: 'Der Umweg',
    titleEnglish: 'The detour',
    blurb: 'A closed road sends two colleagues somewhere neither expected.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-b1-03-c1',
        title: 'Gesperrt',
        titleEnglish: 'Closed',
        lines: <StoryLine>[
          StoryLine('Die Landstraße war seit dem Morgen gesperrt.', 'The country road had been closed since the morning.'),
          StoryLine('Markus fluchte leise, während er wendete.', 'Markus swore quietly while he turned around.'),
          StoryLine('Neben ihm saß Frau Radek und sagte nichts.', 'Beside him sat Mrs Radek and said nothing.'),
          StoryLine('Sie mussten in zwei Stunden beim Kunden sein.', 'They had to be at the client in two hours.'),
          StoryLine('Das Navi schlug einen Weg durch die Dörfer vor.', 'The satnav suggested a route through the villages.'),
          StoryLine('Markus glaubte ihm nicht, folgte aber trotzdem.', 'Markus did not believe it, but followed anyway.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('gesperrt', 'closed, blocked'),
          StoryGloss('wenden', 'to turn around'),
          StoryGloss('vorschlagen', 'to suggest'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Warum müssen sie umkehren?',
            options: <String>[
              'Die Landstraße ist gesperrt.',
              'Das Auto ist kaputt.',
              'Sie haben etwas vergessen.',
            ],
            correctIndex: 0,
            explanation: 'Die Landstraße war seit dem Morgen gesperrt.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-b1-03-c2',
        title: 'Ein Dorf ohne Namen',
        titleEnglish: 'A village without a name',
        lines: <StoryLine>[
          StoryLine('Nach zwanzig Minuten hörte das Navi einfach auf zu sprechen.', 'After twenty minutes the satnav simply stopped speaking.'),
          StoryLine('Sie fuhren durch ein Dorf, das auf keiner Karte stand.', 'They drove through a village that was on no map.'),
          StoryLine('Vor dem Gasthaus saßen drei ältere Männer.', 'Three older men sat in front of the inn.'),
          StoryLine('Frau Radek stieg aus und fragte nach dem Weg.', 'Mrs Radek got out and asked for directions.'),
          StoryLine('Die Männer erklärten es ausführlich und widersprachen sich dabei.', 'The men explained it in detail and contradicted each other doing so.'),
          StoryLine('Am Ende zeichnete einer eine Karte auf eine Serviette.', 'In the end one of them drew a map on a napkin.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('das Gasthaus', 'inn'),
          StoryGloss('ausführlich', 'in detail'),
          StoryGloss('widersprechen', 'to contradict'),
          StoryGloss('die Serviette', 'napkin'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was passiert mit dem Navi?',
            options: <String>[
              'Es hört auf zu sprechen.',
              'Es zeigt einen Stau.',
              'Es fällt herunter.',
            ],
            correctIndex: 0,
            explanation: 'Nach zwanzig Minuten hörte das Navi einfach auf zu sprechen.',
          ),
          ChoiceQuestion(
            prompt: 'Wie helfen die Männer am Ende?',
            options: <String>[
              'Einer zeichnet eine Karte auf eine Serviette.',
              'Sie fahren voraus.',
              'Sie rufen den Kunden an.',
            ],
            correctIndex: 0,
            explanation: 'Am Ende zeichnete einer eine Karte auf eine Serviette.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-b1-03-c3',
        title: 'Pünktlich, fast',
        titleEnglish: 'On time, almost',
        lines: <StoryLine>[
          StoryLine('Die Serviette war erstaunlich genau.', 'The napkin was astonishingly accurate.'),
          StoryLine('Sie kamen zwölf Minuten zu spät an.', 'They arrived twelve minutes late.'),
          StoryLine('Der Kunde hatte den Termin ohnehin verschoben.', 'The client had postponed the appointment anyway.'),
          StoryLine('Auf der Rückfahrt sprachen sie zum ersten Mal privat.', 'On the way back they spoke privately for the first time.'),
          StoryLine('Markus erfuhr, dass Frau Radek in diesem Dorf geboren war.', 'Markus learned that Mrs Radek had been born in that village.'),
          StoryLine('Sie hatte es seit dreißig Jahren nicht mehr gesehen.', 'She had not seen it for thirty years.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('erstaunlich', 'astonishing'),
          StoryGloss('verschieben', 'to postpone'),
          StoryGloss('erfahren', 'to find out'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wie spät kamen sie an?',
            options: <String>['Zwölf Minuten zu spät', 'Eine Stunde zu spät', 'Pünktlich'],
            correctIndex: 0,
            explanation: 'Sie kamen zwölf Minuten zu spät an.',
          ),
          ChoiceQuestion(
            prompt: 'Was erfährt Markus über Frau Radek?',
            options: <String>[
              'Sie wurde in dem Dorf geboren.',
              'Sie kündigt bald.',
              'Sie kennt den Kunden.',
            ],
            correctIndex: 0,
            explanation:
                'Markus erfuhr, dass Frau Radek in diesem Dorf geboren war.',
          ),
        ],
      ),
    ],
  ),
  Story(
    id: 'st-b1-04',
    level: CefrLevel.b1,
    emoji: '📦',
    title: 'Das Paket',
    titleEnglish: 'The parcel',
    blurb: 'A parcel keeps arriving for someone who does not live here.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-b1-04-c1',
        title: 'Falsch zugestellt',
        titleEnglish: 'Wrongly delivered',
        lines: <StoryLine>[
          StoryLine('Das Paket stand am Dienstag vor der Tür.', 'The parcel was in front of the door on Tuesday.'),
          StoryLine('Auf dem Aufkleber stand ein Name, den Tobias nicht kannte.', 'On the label was a name Tobias did not know.'),
          StoryLine('Er brachte es zur Post, die es wieder zurückschickte.', 'He took it to the post office, which sent it back again.'),
          StoryLine('Eine Woche später kam ein zweites Paket.', 'A week later a second parcel came.'),
          StoryLine('Diesmal war es deutlich schwerer.', 'This time it was noticeably heavier.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('der Aufkleber', 'label, sticker'),
          StoryGloss('zurückschicken', 'to send back'),
          StoryGloss('deutlich', 'noticeably, clearly'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was stimmt mit dem Paket nicht?',
            options: <String>[
              'Der Name ist Tobias unbekannt.',
              'Es ist offen.',
              'Es ist leer.',
            ],
            correctIndex: 0,
            explanation:
                'Auf dem Aufkleber stand ein Name, den Tobias nicht kannte.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-b1-04-c2',
        title: 'Nachforschungen',
        titleEnglish: 'Enquiries',
        lines: <StoryLine>[
          StoryLine('Tobias fragte im ganzen Haus nach dem Namen.', 'Tobias asked about the name throughout the building.'),
          StoryLine('Eine Nachbarin erinnerte sich vage an eine Familie.', 'A neighbour vaguely remembered a family.'),
          StoryLine('Die sei vor Jahren ausgezogen, sagte sie.', 'They had moved out years ago, she said.'),
          StoryLine('Wohin, wusste niemand mehr genau.', 'Nobody remembered exactly where to.'),
          StoryLine('Tobias stellte die Pakete in den Keller.', 'Tobias put the parcels in the cellar.'),
          StoryLine('Dort standen sie den ganzen Winter über.', 'They stood there all winter.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('vage', 'vague'),
          StoryGloss('ausziehen', 'to move out'),
          StoryGloss('der Keller', 'cellar'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was sagt die Nachbarin?',
            options: <String>[
              'Die Familie ist vor Jahren ausgezogen.',
              'Sie kennt niemanden.',
              'Die Familie wohnt oben.',
            ],
            correctIndex: 0,
            explanation: 'Die sei vor Jahren ausgezogen, sagte sie.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-b1-04-c3',
        title: 'Im Frühling',
        titleEnglish: 'In spring',
        lines: <StoryLine>[
          StoryLine('Im März klingelte eine Frau an der Tür.', 'In March a woman rang the doorbell.'),
          StoryLine('Sie suchte Post, die vor Jahren verschwunden war.', 'She was looking for mail that had disappeared years ago.'),
          StoryLine('Tobias führte sie wortlos in den Keller.', 'Tobias led her wordlessly to the cellar.'),
          StoryLine('Sie öffnete das schwerere Paket sofort.', 'She opened the heavier parcel immediately.'),
          StoryLine('Darin lagen Fotoalben und ein Stapel Briefe.', 'Inside were photo albums and a stack of letters.'),
          StoryLine('Sie bedankte sich und weinte dabei ein wenig.', 'She thanked him and cried a little doing so.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('wortlos', 'wordlessly'),
          StoryGloss('der Stapel', 'stack'),
          StoryGloss('sich bedanken', 'to thank'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was war in dem schweren Paket?',
            options: <String>[
              'Fotoalben und Briefe',
              'Bücher',
              'Kleidung',
            ],
            correctIndex: 0,
            explanation: 'Darin lagen Fotoalben und ein Stapel Briefe.',
          ),
          ChoiceQuestion(
            prompt: 'Wie reagiert die Frau?',
            options: <String>[
              'Sie bedankt sich und weint ein wenig.',
              'Sie ärgert sich.',
              'Sie geht sofort weg.',
            ],
            correctIndex: 0,
            explanation: 'Sie bedankte sich und weinte dabei ein wenig.',
          ),
        ],
      ),
    ],
  ),

  // ---------------------------------------------------------------- B2 ----
  Story(
    id: 'st-b2-03',
    level: CefrLevel.b2,
    emoji: '🗂️',
    title: 'Der Vermerk',
    titleEnglish: 'The memo',
    blurb: 'A single sentence in an old file changes what everyone assumed.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-b2-03-c1',
        title: 'Aktenzeichen ohne Vorgang',
        titleEnglish: 'A file number without a case',
        lines: <StoryLine>[
          StoryLine('Der Vermerk stammte aus einem Jahr, in dem angeblich nichts geschehen war.', 'The memo came from a year in which supposedly nothing had happened.'),
          StoryLine('Er umfasste einen einzigen Satz und trug keine Unterschrift.', 'It consisted of a single sentence and bore no signature.'),
          StoryLine('Kellner las ihn dreimal, ohne klüger zu werden.', 'Kellner read it three times without becoming any wiser.'),
          StoryLine('Das Aktenzeichen verwies auf einen Vorgang, den es nicht gab.', 'The file number referred to a case that did not exist.'),
          StoryLine('In der Datenbank endete die Spur schlicht.', 'In the database the trail simply ended.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('der Vermerk', 'memo, note'),
          StoryGloss('umfassen', 'to comprise'),
          StoryGloss('verweisen auf', 'to refer to'),
          StoryGloss('die Spur', 'trail, trace'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was ist an dem Vermerk auffällig?',
            options: <String>[
              'Er hat keine Unterschrift und verweist auf einen Vorgang, den es nicht gibt.',
              'Er ist sehr lang.',
              'Er ist auf Englisch.',
            ],
            correctIndex: 0,
            explanation:
                'Er trug keine Unterschrift, und das Aktenzeichen verwies auf '
                'einen Vorgang, den es nicht gab.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-b2-03-c2',
        title: 'Zuständigkeiten',
        titleEnglish: 'Responsibilities',
        lines: <StoryLine>[
          StoryLine('Die Abteilungsleiterin reagierte zurückhaltend auf seine Frage.', 'The head of department reacted with restraint to his question.'),
          StoryLine('Man solle alte Vorgänge nicht ohne Anlass aufrollen.', 'One should not reopen old cases without reason.'),
          StoryLine('Kellner hielt das für eine Ausrede, sagte es aber nicht.', 'Kellner considered that an excuse, but did not say so.'),
          StoryLine('Stattdessen schrieb er an das zuständige Archiv.', 'Instead he wrote to the responsible archive.'),
          StoryLine('Die Antwort kam nach elf Wochen und bestand aus zwei Zeilen.', 'The answer came after eleven weeks and consisted of two lines.'),
          StoryLine('Der Vorgang sei vernichtet worden, fristgerecht.', 'The case had been destroyed, within the required period.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('zurückhaltend', 'reserved, restrained'),
          StoryGloss('aufrollen', 'to reopen, roll up'),
          StoryGloss('die Ausrede', 'excuse'),
          StoryGloss('vernichten', 'to destroy'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wie reagiert die Abteilungsleiterin?',
            options: <String>[
              'Zurückhaltend, sie will keine alten Vorgänge aufrollen.',
              'Sie hilft sofort.',
              'Sie kennt den Vermerk nicht.',
            ],
            correctIndex: 0,
            explanation:
                'Man solle alte Vorgänge nicht ohne Anlass aufrollen.',
          ),
          ChoiceQuestion(
            prompt: 'Was antwortet das Archiv?',
            options: <String>[
              'Der Vorgang sei fristgerecht vernichtet worden.',
              'Der Vorgang liege bereit.',
              'Es gebe keine Unterlagen.',
            ],
            correctIndex: 0,
            explanation: 'Der Vorgang sei vernichtet worden, fristgerecht.',
          ),
        ],
      ),
    ],
  ),

  // ---------------------------------------------------------------- C1 ----
  Story(
    id: 'st-c1-03',
    level: CefrLevel.c1,
    emoji: '🎻',
    title: 'Die zweite Aufnahme',
    titleEnglish: 'The second recording',
    blurb: 'Two recordings of the same piece, forty years apart, by the same hands.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-c1-03-c1',
        title: 'Dasselbe Stück',
        titleEnglish: 'The same piece',
        lines: <StoryLine>[
          StoryLine('Zwischen den beiden Aufnahmen lagen vierzig Jahre und dieselben Hände.', 'Between the two recordings lay forty years and the same hands.'),
          StoryLine('Die frühere war schneller, brillanter, im Grunde makellos.', 'The earlier one was faster, more brilliant, essentially flawless.'),
          StoryLine('Die spätere wirkte auf den ersten Eindruck schlicht schwächer.', 'The later one seemed at first impression simply weaker.'),
          StoryLine('Erst beim wiederholten Hören verschob sich das Urteil.', 'Only on repeated listening did the judgement shift.'),
          StoryLine('Was zunächst als Nachlassen erschien, erwies sich als Auslassen.', 'What at first appeared as decline proved to be omission.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('makellos', 'flawless'),
          StoryGloss('der Eindruck', 'impression'),
          StoryGloss('das Nachlassen', 'decline, waning'),
          StoryGloss('das Auslassen', 'omission, leaving out'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wie wirkt die spätere Aufnahme zunächst?',
            options: <String>['Schwächer', 'Brillanter', 'Schneller'],
            correctIndex: 0,
            explanation:
                'Die spätere wirkte auf den ersten Eindruck schlicht schwächer.',
          ),
          ChoiceQuestion(
            prompt: 'Wie ändert sich das Urteil?',
            options: <String>[
              'Das Nachlassen erweist sich als bewusstes Auslassen.',
              'Es bleibt gleich.',
              'Die frühere gefällt noch besser.',
            ],
            correctIndex: 0,
            explanation:
                'Was zunächst als Nachlassen erschien, erwies sich als '
                'Auslassen.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-c1-03-c2',
        title: 'Was fehlt',
        titleEnglish: 'What is missing',
        lines: <StoryLine>[
          StoryLine('Der Pianist hatte offenkundig entschieden, weniger zu zeigen.', 'The pianist had evidently decided to show less.'),
          StoryLine('Passagen, die er einst ausgekostet hatte, gingen nun vorüber.', 'Passages he had once savoured now simply passed.'),
          StoryLine('Dadurch trat hervor, was zuvor im Glanz untergegangen war.', 'Thereby what had previously been lost in the brilliance emerged.'),
          StoryLine('Kritiker sprachen von Alterswerk, was wenig erklärt.', 'Critics spoke of a late work, which explains little.'),
          StoryLine('Treffender wäre gewesen, von einer anderen Frage zu sprechen.', 'It would have been more apt to speak of a different question.'),
          StoryLine('Nicht mehr, was möglich ist, sondern was nötig.', 'No longer what is possible, but what is necessary.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('offenkundig', 'evidently'),
          StoryGloss('auskosten', 'to savour'),
          StoryGloss('hervortreten', 'to emerge'),
          StoryGloss('treffend', 'apt'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was hatte der Pianist entschieden?',
            options: <String>[
              'Weniger zu zeigen',
              'Schneller zu spielen',
              'Das Stück zu ändern',
            ],
            correctIndex: 0,
            explanation:
                'Der Pianist hatte offenkundig entschieden, weniger zu zeigen.',
          ),
          ChoiceQuestion(
            prompt: 'Wie beurteilt der Text den Begriff Alterswerk?',
            options: <String>[
              'Er erklärt wenig.',
              'Er trifft genau zu.',
              'Er ist beleidigend.',
            ],
            correctIndex: 0,
            explanation:
                'Kritiker sprachen von Alterswerk, was wenig erklärt.',
          ),
        ],
      ),
    ],
  ),

  // ---------------------------------------------------------------- C2 ----
  Story(
    id: 'st-c2-03',
    level: CefrLevel.c2,
    emoji: '🗺️',
    title: 'Die Karte des Landvermessers',
    titleEnglish: 'The surveyor map',
    blurb: 'A map that was accurate, and a village that insisted otherwise.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-c2-03-c1',
        title: 'Vermessung',
        titleEnglish: 'Survey',
        lines: <StoryLine>[
          StoryLine('Der Landvermesser hatte, soweit sich rekonstruieren lässt, sorgfältig gearbeitet.', 'The surveyor had, as far as can be reconstructed, worked carefully.'),
          StoryLine('Seine Karte wich gleichwohl von jener ab, die im Dorf in Gebrauch war.', 'His map nevertheless deviated from the one in use in the village.'),
          StoryLine('Die Abweichung betrug an der entscheidenden Stelle knapp zweihundert Meter.', 'At the decisive point the deviation amounted to barely two hundred metres.'),
          StoryLine('Da es um Weiderechte ging, war sie alles andere als unerheblich.', 'Since grazing rights were at stake, it was anything but insignificant.'),
          StoryLine('Zwei Familien beriefen sich fortan auf jeweils eine der Karten.', 'Two families thereafter each invoked one of the maps.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('der Landvermesser', 'surveyor'),
          StoryGloss('abweichen', 'to deviate'),
          StoryGloss('unerheblich', 'insignificant'),
          StoryGloss('sich berufen auf', 'to invoke, cite'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Worum ging der Streit?',
            options: <String>['Um Weiderechte', 'Um eine Straße', 'Um ein Haus'],
            correctIndex: 0,
            explanation: 'Da es um Weiderechte ging, war sie alles andere als unerheblich.',
          ),
        ],
      ),
      StoryChapter(
        id: 'st-c2-03-c2',
        title: 'Beharrlichkeit',
        titleEnglish: 'Persistence',
        lines: <StoryLine>[
          StoryLine('Dass die neuere Karte genauer war, bestritt nach einiger Zeit niemand mehr.', 'That the newer map was more accurate was after a while disputed by nobody.'),
          StoryLine('Gehandelt wurde dennoch weiterhin nach der älteren.', 'Business was nevertheless still conducted according to the older one.'),
          StoryLine('Der Grund war weniger Trotz als Gewohnheit.', 'The reason was less defiance than habit.'),
          StoryLine('Zäune standen, wo sie seit Generationen gestanden hatten.', 'Fences stood where they had stood for generations.'),
          StoryLine('Eine Korrektur hätte mehr gekostet, als der Streit wert war.', 'A correction would have cost more than the dispute was worth.'),
          StoryLine('So blieb der Irrtum bestehen, und zwar einvernehmlich.', 'So the error persisted, and by mutual agreement at that.'),
        ],
        glossary: <StoryGloss>[
          StoryGloss('bestreiten', 'to dispute'),
          StoryGloss('der Trotz', 'defiance'),
          StoryGloss('die Gewohnheit', 'habit'),
          StoryGloss('einvernehmlich', 'by mutual agreement'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Warum galt weiter die ältere Karte?',
            options: <String>[
              'Aus Gewohnheit, und weil eine Korrektur zu teuer gewesen wäre',
              'Weil sie genauer war',
              'Weil ein Gericht es anordnete',
            ],
            correctIndex: 0,
            explanation:
                'Der Grund war weniger Trotz als Gewohnheit, und eine '
                'Korrektur hätte mehr gekostet, als der Streit wert war.',
          ),
          ChoiceQuestion(
            prompt: 'Wie endet die Sache?',
            options: <String>[
              'Der Irrtum bleibt einvernehmlich bestehen.',
              'Die Karte wird korrigiert.',
              'Die Familien ziehen weg.',
            ],
            correctIndex: 0,
            explanation: 'So blieb der Irrtum bestehen, und zwar einvernehmlich.',
          ),
        ],
      ),
    ],
  ),
];
