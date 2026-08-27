import 'models.dart';
import 'stories.dart';

/// The extensive-reading tranche added after the original hand-authored
/// collection. Each seed contains seven original bilingual story beats. The
/// builder adds level-appropriate transitions, chapter glossaries and
/// comprehension checks without duplicating prose in the repository.
///
/// The split is deliberate: the narrative facts remain easy to review, while
/// chapter ids and repeated exercise scaffolding are derived consistently.
final List<Story> expandedStories = _readerSeeds
    .map<Story>(_storyFromSeed)
    .toList(growable: false);

class _ReaderSeed {
  const _ReaderSeed({
    required this.id,
    required this.level,
    required this.emoji,
    required this.title,
    required this.titleEnglish,
    required this.blurb,
    required this.protagonist,
    required this.chapterCount,
    required this.beats,
    required this.glossary,
  });

  final String id;
  final CefrLevel level;
  final String emoji;
  final String title;
  final String titleEnglish;
  final String blurb;
  final String protagonist;
  final int chapterCount;
  final List<_Beat> beats;
  final List<StoryGloss> glossary;
}

class _Beat {
  const _Beat(this.german, this.english);

  final String german;
  final String english;
}

Story _storyFromSeed(_ReaderSeed seed) {
  final List<int> starts = seed.chapterCount == 4
      ? const <int>[0, 2, 4, 6]
      : const <int>[0, 3, 5];
  final List<int> ends = seed.chapterCount == 4
      ? const <int>[2, 4, 6, 7]
      : const <int>[3, 5, 7];
  return Story(
    id: seed.id,
    level: seed.level,
    emoji: seed.emoji,
    title: seed.title,
    titleEnglish: seed.titleEnglish,
    blurb: seed.blurb,
    chapters: List<StoryChapter>.generate(seed.chapterCount, (int index) {
      final List<_Beat> section = seed.beats.sublist(
        starts[index],
        ends[index],
      );
      final _Beat answer = section.last;
      final ({String german, String english}) transition = _transition(
        seed,
        index,
      );
      final ({String german, String english}) closing = _closing(seed, index);
      return StoryChapter(
        id: '${seed.id}-c${index + 1}',
        title: _chapterTitles[index].$1,
        titleEnglish: _chapterTitles[index].$2,
        lines: <StoryLine>[
          StoryLine(transition.german, transition.english),
          ...section.map((beat) => StoryLine(beat.german, beat.english)),
          StoryLine(closing.german, closing.english),
        ],
        glossary: seed.glossary,
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was erfährt man in diesem Abschnitt?',
            options: <String>[
              answer.german,
              'Alle Beteiligten gehen sofort nach Hause.',
              'Es geschieht nichts Besonderes.',
            ],
            correctIndex: 0,
            explanation: answer.german,
          ),
          ChoiceQuestion(
            prompt: 'Welche Aussage passt zur Entwicklung?',
            options: <String>[
              closing.german,
              'Das Problem wird einfach vergessen.',
              'Niemand reagiert auf die Situation.',
            ],
            correctIndex: 0,
            explanation: closing.german,
          ),
        ],
      );
    }),
  );
}

const List<(String, String)> _chapterTitles = <(String, String)>[
  ('Der Anfang', 'The beginning'),
  ('Das Problem', 'The problem'),
  ('Die Entscheidung', 'The decision'),
  ('Das Ergebnis', 'The outcome'),
];

({String german, String english}) _transition(_ReaderSeed seed, int chapter) {
  final String name = seed.protagonist;
  switch (seed.level) {
    case CefrLevel.a1:
      return switch (chapter) {
        0 => (
          german: 'Für $name beginnt ein neuer Tag.',
          english: 'A new day begins for $name.',
        ),
        1 => (
          german: 'Dann kommt ein Problem.',
          english: 'Then a problem appears.',
        ),
        2 => (
          german: '$name denkt kurz nach.',
          english: '$name thinks for a moment.',
        ),
        _ => (
          german: 'Am Ende ist vieles klar.',
          english: 'In the end, many things are clear.',
        ),
      };
    case CefrLevel.a2:
      return switch (chapter) {
        0 => (
          german: 'Zuerst schien für $name alles ganz normal zu sein.',
          english: 'At first everything seemed quite normal for $name.',
        ),
        1 => (
          german: 'Kurz danach ist etwas Unerwartetes passiert.',
          english: 'Shortly afterwards something unexpected happened.',
        ),
        2 => (
          german: '$name musste deshalb einen neuen Plan machen.',
          english: '$name therefore had to make a new plan.',
        ),
        _ => (
          german: 'Später hat $name den ganzen Tag noch einmal betrachtet.',
          english: 'Later $name looked back over the whole day.',
        ),
      };
    case CefrLevel.b1:
      return switch (chapter) {
        0 => (
          german:
              'Was als gewöhnlicher Tag begann, wurde für $name bald wichtig.',
          english:
              'What began as an ordinary day soon became important for $name.',
        ),
        1 => (
          german:
              'Als die Lage schwieriger wurde, reichte der erste Plan nicht mehr aus.',
          english:
              'When the situation became more difficult, the first plan was no longer enough.',
        ),
        2 => (
          german: '$name musste abwägen, welche Lösung wirklich helfen würde.',
          english: '$name had to weigh up which solution would really help.',
        ),
        _ => (
          german:
              'Im Rückblick zeigte sich, was an der Entscheidung entscheidend war.',
          english:
              'Looking back, it became clear what had mattered in the decision.',
        ),
      };
    case CefrLevel.b2:
      return switch (chapter) {
        0 => (
          german:
              'Anfangs deutete wenig darauf hin, dass $name die Situation neu bewerten müsste.',
          english:
              'At first there was little indication that $name would have to reassess the situation.',
        ),
        1 => (
          german:
              'Mit jeder neuen Information wurde der ursprüngliche Plan fragwürdiger.',
          english:
              'With each new piece of information, the original plan became more questionable.',
        ),
        2 => (
          german:
              '$name suchte nach einer Lösung, die auch die Einwände der anderen berücksichtigte.',
          english:
              '$name looked for a solution that also took the others objections into account.',
        ),
        _ => (
          german:
              'Erst im Nachhinein ließen sich die Folgen der Entscheidung vollständig erkennen.',
          english:
              'Only afterwards could the consequences of the decision be fully recognised.',
        ),
      };
    case CefrLevel.c1:
      return switch (chapter) {
        0 => (
          german:
              'Die Angelegenheit wirkte zunächst überschaubar, obwohl $name bereits einen Widerspruch bemerkte.',
          english:
              'The matter initially seemed manageable, although $name had already noticed a contradiction.',
        ),
        1 => (
          german:
              'Je genauer die Beteiligten hinsahen, desto weniger trug die bequeme Erklärung.',
          english:
              'The more closely those involved looked, the less convincing the convenient explanation became.',
        ),
        2 => (
          german:
              '$name versuchte, zwischen berechtigtem Einwand und bloßer Verzögerung zu unterscheiden.',
          english:
              '$name tried to distinguish between a justified objection and mere delay.',
        ),
        _ => (
          german:
              'Die spätere Bewertung fiel differenzierter aus, als es der erste Eindruck erwarten ließ.',
          english:
              'The later assessment was more nuanced than the first impression had suggested.',
        ),
      };
    case CefrLevel.c2:
      return switch (chapter) {
        0 => (
          german:
              'Dass die Sache harmlos erschien, beruhte vor allem darauf, dass $name ihre Voraussetzungen noch nicht offengelegt hatte.',
          english:
              'That the matter seemed harmless was mainly because $name had not yet made its assumptions explicit.',
        ),
        1 => (
          german:
              'Der Konflikt verschärfte sich weniger durch neue Tatsachen als durch ihre unvereinbaren Deutungen.',
          english:
              'The conflict intensified less because of new facts than because of their incompatible interpretations.',
        ),
        2 => (
          german:
              '$name suchte folglich nicht nach einem Kompromiss um jeden Preis, sondern nach einer begründbaren Unterscheidung.',
          english:
              '$name therefore sought not a compromise at any price, but a defensible distinction.',
        ),
        _ => (
          german:
              'Was als Einzelfall begonnen hatte, erwies sich rückblickend als Prüfung des zugrunde liegenden Maßstabs.',
          english:
              'What had begun as an individual case proved, in retrospect, to be a test of the underlying standard.',
        ),
      };
  }
}

({String german, String english}) _closing(_ReaderSeed seed, int chapter) {
  final bool last = chapter == seed.chapterCount - 1;
  if (last) {
    return switch (seed.level) {
      CefrLevel.a1 => (
        german:
            '${seed.protagonist} hat jetzt eine gute Geschichte zu erzählen.',
        english: '${seed.protagonist} now has a good story to tell.',
      ),
      CefrLevel.a2 => (
        german:
            'So hat ${seed.protagonist} nicht nur das Problem gelöst, sondern auch etwas gelernt.',
        english:
            'In this way ${seed.protagonist} not only solved the problem but also learned something.',
      ),
      CefrLevel.b1 => (
        german:
            'Seitdem erinnert sich ${seed.protagonist} in ähnlichen Situationen an diesen Tag.',
        english:
            'Since then ${seed.protagonist} remembers this day in similar situations.',
      ),
      CefrLevel.b2 => (
        german:
            'Damit war die Sache nicht vollkommen abgeschlossen, aber wieder gemeinsam bearbeitbar.',
        english:
            'The matter was not completely closed, but it could once again be worked on together.',
      ),
      CefrLevel.c1 => (
        german:
            'Die Lösung beseitigte den Konflikt nicht, machte seine Voraussetzungen jedoch sichtbar.',
        english:
            'The solution did not remove the conflict, but it made its assumptions visible.',
      ),
      CefrLevel.c2 => (
        german:
            'Gerade die verbleibende Spannung bewahrte das Ergebnis davor, zur bequemen Formel zu erstarren.',
        english:
            'The remaining tension was precisely what kept the result from hardening into a convenient formula.',
      ),
    };
  }
  return switch (seed.level) {
    CefrLevel.a1 => (
      german: '${seed.protagonist} möchte jetzt weitermachen.',
      english: '${seed.protagonist} now wants to continue.',
    ),
    CefrLevel.a2 => (
      german:
          'Deshalb konnte ${seed.protagonist} nicht beim alten Plan bleiben.',
      english: 'That is why ${seed.protagonist} could not keep the old plan.',
    ),
    CefrLevel.b1 => (
      german: 'Damit begann der nächste Teil der Geschichte.',
      english: 'That began the next part of the story.',
    ),
    CefrLevel.b2 => (
      german: 'Diese Beobachtung veränderte den weiteren Verlauf.',
      english: 'This observation changed what happened next.',
    ),
    CefrLevel.c1 => (
      german: 'Damit verschob sich die Frage, die beantwortet werden musste.',
      english: 'This shifted the question that had to be answered.',
    ),
    CefrLevel.c2 => (
      german:
          'Von diesem Punkt an ließ sich die frühere Lesart nicht mehr widerspruchsfrei halten.',
      english:
          'From that point on, the earlier reading could no longer be maintained without contradiction.',
    ),
  };
}

const List<_ReaderSeed> _readerSeeds = <_ReaderSeed>[
  _ReaderSeed(
    id: 'st-a1-05',
    level: CefrLevel.a1,
    emoji: '📦',
    title: 'Das Paket für Frau Beck',
    titleEnglish: 'The parcel for Mrs Beck',
    blurb: 'Mila accepts a parcel and has to find the right neighbour.',
    protagonist: 'Mila',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat('Mila ist am Samstag zu Hause.', 'Mila is at home on Saturday.'),
      _Beat(
        'Der Paketbote bringt ein großes Paket für Frau Beck.',
        'The delivery driver brings a large parcel for Mrs Beck.',
      ),
      _Beat(
        'Im Haus wohnen aber zwei Frauen mit diesem Namen.',
        'But two women with that name live in the building.',
      ),
      _Beat(
        'Mila fragt zuerst im zweiten Stock.',
        'Mila first asks on the second floor.',
      ),
      _Beat(
        'Die ältere Frau Beck erwartet nur einen kleinen Brief.',
        'The older Mrs Beck is only expecting a small letter.',
      ),
      _Beat(
        'Die junge Frau Beck im vierten Stock hat einen Stuhl bestellt.',
        'The young Mrs Beck on the fourth floor ordered a chair.',
      ),
      _Beat(
        'Das Paket kommt bei der richtigen Person an.',
        'The parcel reaches the right person.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('der Paketbote', 'delivery driver'),
      StoryGloss('erwarten', 'to expect'),
      StoryGloss('bestellen', 'to order'),
      StoryGloss('richtig', 'correct'),
    ],
  ),
  _ReaderSeed(
    id: 'st-a1-06',
    level: CefrLevel.a1,
    emoji: '🥕',
    title: 'Fünf Euro auf dem Markt',
    titleEnglish: 'Five euros at the market',
    blurb: 'Omar wants to cook soup with only five euros in his pocket.',
    protagonist: 'Omar',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Omar geht am Morgen auf den Markt.',
        'Omar goes to the market in the morning.',
      ),
      _Beat(
        'Er möchte Gemüse für eine Suppe kaufen.',
        'He wants to buy vegetables for a soup.',
      ),
      _Beat(
        'In seiner Tasche sind nur fünf Euro.',
        'There are only five euros in his pocket.',
      ),
      _Beat(
        'Die Tomaten sind heute zu teuer.',
        'The tomatoes are too expensive today.',
      ),
      _Beat(
        'Eine Verkäuferin zeigt ihm Kartoffeln, Möhren und Lauch.',
        'A seller shows him potatoes, carrots and leeks.',
      ),
      _Beat(
        'Omar rechnet noch einmal und nimmt alles zusammen.',
        'Omar calculates again and takes everything together.',
      ),
      _Beat(
        'Am Abend essen drei Freunde eine warme Suppe.',
        'In the evening three friends eat a warm soup.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('der Markt', 'market'),
      StoryGloss('die Möhre', 'carrot'),
      StoryGloss('teuer', 'expensive'),
      StoryGloss('rechnen', 'to calculate'),
    ],
  ),
  _ReaderSeed(
    id: 'st-a1-07',
    level: CefrLevel.a1,
    emoji: '📚',
    title: 'Der Platz im Deutschkurs',
    titleEnglish: 'The place in the German course',
    blurb: 'Sofia arrives late and thinks there is no seat for her.',
    protagonist: 'Sofia',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Sofia hat heute ihren ersten Deutschkurs.',
        'Sofia has her first German course today.',
      ),
      _Beat(
        'Der Bus kommt zehn Minuten zu spät.',
        'The bus arrives ten minutes late.',
      ),
      _Beat(
        'Im Kursraum sind schon viele Menschen.',
        'There are already many people in the classroom.',
      ),
      _Beat('Sofia sieht keinen freien Stuhl.', 'Sofia sees no free chair.'),
      _Beat(
        'Ein Mann stellt seine Tasche vom Stuhl auf den Boden.',
        'A man puts his bag from the chair onto the floor.',
      ),
      _Beat(
        'Die Lehrerin gibt Sofia ein Buch und begrüßt sie.',
        'The teacher gives Sofia a book and welcomes her.',
      ),
      _Beat(
        'In der Pause kennt Sofia schon drei Namen.',
        'By the break Sofia already knows three names.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('der Kursraum', 'classroom'),
      StoryGloss('frei', 'free'),
      StoryGloss('begrüßen', 'to welcome'),
      StoryGloss('die Pause', 'break'),
    ],
  ),
  _ReaderSeed(
    id: 'st-a1-08',
    level: CefrLevel.a1,
    emoji: '🐈',
    title: 'Die Katze auf dem Balkon',
    titleEnglish: 'The cat on the balcony',
    blurb: 'A cat visits Kenan on a rainy afternoon.',
    protagonist: 'Kenan',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Kenan hört am Fenster ein leises Geräusch.',
        'Kenan hears a quiet sound at the window.',
      ),
      _Beat(
        'Auf dem Balkon sitzt eine nasse Katze.',
        'A wet cat is sitting on the balcony.',
      ),
      _Beat('Kenan kennt die Katze nicht.', 'Kenan does not know the cat.'),
      _Beat(
        'Auf dem Halsband steht eine Telefonnummer.',
        'There is a telephone number on the collar.',
      ),
      _Beat(
        'Kenan ruft an und gibt der Katze Wasser.',
        'Kenan calls and gives the cat water.',
      ),
      _Beat(
        'Nach zwanzig Minuten klingelt eine Familie an der Tür.',
        'After twenty minutes a family rings the doorbell.',
      ),
      _Beat(
        'Die Katze heißt Minka und wohnt im Nachbarhaus.',
        'The cat is called Minka and lives in the neighbouring building.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('nass', 'wet'),
      StoryGloss('das Halsband', 'collar'),
      StoryGloss('anrufen', 'to call'),
      StoryGloss('das Nachbarhaus', 'neighbouring building'),
    ],
  ),
  _ReaderSeed(
    id: 'st-a1-09',
    level: CefrLevel.a1,
    emoji: '🚌',
    title: 'Der falsche Bus',
    titleEnglish: 'The wrong bus',
    blurb: 'Ana boards the wrong bus on her way to work.',
    protagonist: 'Ana',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Ana muss um acht Uhr bei der Arbeit sein.',
        'Ana has to be at work at eight.',
      ),
      _Beat(
        'An der Haltestelle kommen zwei Busse gleichzeitig.',
        'Two buses arrive at the stop at the same time.',
      ),
      _Beat(
        'Ana steigt schnell in den Bus Nummer sechs.',
        'Ana quickly gets on bus number six.',
      ),
      _Beat(
        'Nach drei Haltestellen sieht sie einen großen See.',
        'After three stops she sees a large lake.',
      ),
      _Beat(
        'Der Fahrer erklärt ihr den Weg zurück.',
        'The driver explains the way back to her.',
      ),
      _Beat(
        'Ana ruft ihre Chefin an und fährt mit der Straßenbahn.',
        'Ana calls her boss and takes the tram.',
      ),
      _Beat(
        'Sie kommt nur fünf Minuten zu spät an.',
        'She arrives only five minutes late.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('gleichzeitig', 'at the same time'),
      StoryGloss('einsteigen', 'to get on'),
      StoryGloss('der Fahrer', 'driver'),
      StoryGloss('zu spät', 'late'),
    ],
  ),
  _ReaderSeed(
    id: 'st-a1-10',
    level: CefrLevel.a1,
    emoji: '🎂',
    title: 'Ein kleiner Geburtstag',
    titleEnglish: 'A small birthday',
    blurb: 'Bao says he wants no party, but his friends have another idea.',
    protagonist: 'Bao',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Bao hat am Dienstag Geburtstag.',
        'Bao has his birthday on Tuesday.',
      ),
      _Beat(
        'Er möchte nach der Arbeit nur ruhig essen.',
        'He only wants to eat quietly after work.',
      ),
      _Beat(
        'Seine Freunde schreiben den ganzen Tag keine Nachricht.',
        'His friends send no message all day.',
      ),
      _Beat(
        'Bao denkt, dass alle den Geburtstag vergessen haben.',
        'Bao thinks that everyone has forgotten his birthday.',
      ),
      _Beat('Zu Hause ist die Wohnung dunkel.', 'At home the flat is dark.'),
      _Beat(
        'Plötzlich gehen die Lichter an und alle rufen seinen Namen.',
        'Suddenly the lights come on and everyone calls his name.',
      ),
      _Beat(
        'Die kleine Feier macht Bao sehr glücklich.',
        'The small celebration makes Bao very happy.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('der Geburtstag', 'birthday'),
      StoryGloss('vergessen', 'to forget'),
      StoryGloss('plötzlich', 'suddenly'),
      StoryGloss('die Feier', 'celebration'),
    ],
  ),
  _ReaderSeed(
    id: 'st-a1-11',
    level: CefrLevel.a1,
    emoji: '🔑',
    title: 'Der Schlüssel im Café',
    titleEnglish: 'The key in the café',
    blurb: 'Nora cannot find her key after breakfast in a café.',
    protagonist: 'Nora',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Nora frühstückt vor der Arbeit in einem Café.',
        'Nora has breakfast in a café before work.',
      ),
      _Beat(
        'Sie bezahlt und geht schnell nach draußen.',
        'She pays and quickly goes outside.',
      ),
      _Beat(
        'Vor ihrem Fahrrad findet sie den Schlüssel nicht.',
        'By her bicycle she cannot find the key.',
      ),
      _Beat(
        'Nora sucht in der Jacke, in der Tasche und unter dem Tisch.',
        'Nora looks in her jacket, in her bag and under the table.',
      ),
      _Beat(
        'Der Kellner zeigt auf die leere Tasse.',
        'The waiter points to the empty cup.',
      ),
      _Beat(
        'Der Schlüssel liegt hinter der Tasse auf dem kleinen Teller.',
        'The key is lying behind the cup on the small plate.',
      ),
      _Beat(
        'Nora lacht und steckt ihn sicher in die Jackentasche.',
        'Nora laughs and puts it safely in her jacket pocket.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('bezahlen', 'to pay'),
      StoryGloss('suchen', 'to look for'),
      StoryGloss('die Tasse', 'cup'),
      StoryGloss('sicher', 'safely'),
    ],
  ),

  _ReaderSeed(
    id: 'st-a2-05',
    level: CefrLevel.a2,
    emoji: '🌱',
    title: 'Das Beet am Zaun',
    titleEnglish: 'The bed by the fence',
    blurb: 'Leila joins a community garden and discovers an unclear rule.',
    protagonist: 'Leila',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Leila hat im Gemeinschaftsgarten ein kleines Beet übernommen.',
        'Leila has taken over a small bed in the community garden.',
      ),
      _Beat(
        'Sie hat dort Tomaten und Kräuter gepflanzt.',
        'She planted tomatoes and herbs there.',
      ),
      _Beat(
        'Nach einer Woche lagen Bretter mitten auf ihrem Beet.',
        'After a week boards were lying in the middle of her bed.',
      ),
      _Beat(
        'Ein Nachbar wollte an dieser Stelle einen neuen Weg bauen.',
        'A neighbour wanted to build a new path at that spot.',
      ),
      _Beat(
        'Leila hat den alten Gartenplan im Vereinshaus gefunden.',
        'Leila found the old garden plan in the club house.',
      ),
      _Beat(
        'Gemeinsam haben sie den Weg einen Meter weiter nach links gelegt.',
        'Together they moved the path one metre further to the left.',
      ),
      _Beat(
        'Im Sommer haben beide die ersten Tomaten geteilt.',
        'In summer they shared the first tomatoes.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('das Beet', 'garden bed'),
      StoryGloss('pflanzen', 'to plant'),
      StoryGloss('das Brett', 'board'),
      StoryGloss('teilen', 'to share'),
    ],
  ),
  _ReaderSeed(
    id: 'st-a2-06',
    level: CefrLevel.a2,
    emoji: '🚆',
    title: 'Vierzig Minuten in Schwerin',
    titleEnglish: 'Forty minutes in Schwerin',
    blurb: 'A delayed train gives David an unexpected short visit.',
    protagonist: 'David',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'David ist mit dem Zug nach Hamburg gefahren.',
        'David travelled to Hamburg by train.',
      ),
      _Beat(
        'In Schwerin musste er plötzlich umsteigen.',
        'In Schwerin he suddenly had to change trains.',
      ),
      _Beat(
        'Der nächste Zug sollte erst in vierzig Minuten kommen.',
        'The next train was not due for forty minutes.',
      ),
      _Beat(
        'David wollte zuerst nur am Bahnsteig warten.',
        'At first David only wanted to wait on the platform.',
      ),
      _Beat(
        'Eine Mitarbeiterin hat ihm den kurzen Weg zum Schloss gezeigt.',
        'An employee showed him the short route to the castle.',
      ),
      _Beat(
        'Er hat das Schloss gesehen und pünktlich den Zug erreicht.',
        'He saw the castle and caught the train on time.',
      ),
      _Beat(
        'Seitdem plant David bei Reisen kleine Pausen bewusst ein.',
        'Since then David deliberately plans short breaks into journeys.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('umsteigen', 'to change trains'),
      StoryGloss('der Bahnsteig', 'platform'),
      StoryGloss('erreichen', 'to catch, reach'),
      StoryGloss('bewusst', 'deliberately'),
    ],
  ),
  _ReaderSeed(
    id: 'st-a2-07',
    level: CefrLevel.a2,
    emoji: '🏐',
    title: 'Training ohne Ball',
    titleEnglish: 'Training without a ball',
    blurb: 'A sports team arrives at the gym without its equipment bag.',
    protagonist: 'Marek',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Marek leitet am Mittwoch das Volleyballtraining.',
        'Marek leads volleyball training on Wednesday.',
      ),
      _Beat(
        'Zwölf Spielerinnen sind pünktlich in der Halle gewesen.',
        'Twelve players were on time in the gym.',
      ),
      _Beat(
        'Die Tasche mit allen Bällen stand noch im Auto der Trainerin.',
        'The bag with all the balls was still in the coach car.',
      ),
      _Beat(
        'Die Trainerin war aber schon auf dem Weg in eine andere Stadt.',
        'But the coach was already on her way to another city.',
      ),
      _Beat(
        'Marek hat zuerst Laufübungen und ein Spiel ohne Ball vorgeschlagen.',
        'Marek first suggested running exercises and a game without a ball.',
      ),
      _Beat(
        'Ein Hausmeister hat später zwei alte Bälle im Lager gefunden.',
        'A caretaker later found two old balls in storage.',
      ),
      _Beat(
        'Das ungewöhnliche Training hat der Mannschaft überraschend gut gefallen.',
        'The unusual training was surprisingly popular with the team.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('leiten', 'to lead'),
      StoryGloss('die Halle', 'gym hall'),
      StoryGloss('vorschlagen', 'to suggest'),
      StoryGloss('das Lager', 'storage room'),
    ],
  ),
  _ReaderSeed(
    id: 'st-a2-08',
    level: CefrLevel.a2,
    emoji: '🧥',
    title: 'Die Jacke vom Flohmarkt',
    titleEnglish: 'The jacket from the flea market',
    blurb: 'Elif finds a letter in the pocket of a second-hand jacket.',
    protagonist: 'Elif',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Elif hat auf dem Flohmarkt eine blaue Jacke gekauft.',
        'Elif bought a blue jacket at the flea market.',
      ),
      _Beat(
        'Zu Hause hat sie in der Innentasche einen alten Brief gefunden.',
        'At home she found an old letter in the inside pocket.',
      ),
      _Beat(
        'Auf dem Umschlag standen ein Name und eine Adresse in Rostock.',
        'A name and an address in Rostock were written on the envelope.',
      ),
      _Beat(
        'Elif war nicht sicher, ob die Adresse noch stimmte.',
        'Elif was not sure whether the address was still correct.',
      ),
      _Beat(
        'Sie hat zuerst eine kurze Nachricht an die Verkäuferin geschickt.',
        'She first sent a short message to the seller.',
      ),
      _Beat(
        'Die Verkäuferin hat den Brief für ihren Vater abgeholt.',
        'The seller collected the letter for her father.',
      ),
      _Beat(
        'Elif durfte die Jacke behalten und bekam ein dankbares Foto.',
        'Elif was allowed to keep the jacket and received a grateful photo.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('der Flohmarkt', 'flea market'),
      StoryGloss('die Innentasche', 'inside pocket'),
      StoryGloss('der Umschlag', 'envelope'),
      StoryGloss('behalten', 'to keep'),
    ],
  ),
  _ReaderSeed(
    id: 'st-a2-09',
    level: CefrLevel.a2,
    emoji: '🩺',
    title: 'Der Termin am Donnerstag',
    titleEnglish: 'The appointment on Thursday',
    blurb: 'Luis misunderstands a medical appointment and has to explain it.',
    protagonist: 'Luis',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Luis hat telefonisch einen Termin beim Arzt vereinbart.',
        'Luis arranged a doctor appointment by phone.',
      ),
      _Beat(
        'Er hat Donnerstag um dreizehn Uhr in seinen Kalender geschrieben.',
        'He wrote Thursday at one o clock in his calendar.',
      ),
      _Beat(
        'In der Praxis stand sein Name am Donnerstag nicht auf der Liste.',
        'At the practice his name was not on the list on Thursday.',
      ),
      _Beat(
        'Die Mitarbeiterin hatte Dienstag um dreizehn Uhr notiert.',
        'The employee had written down Tuesday at one o clock.',
      ),
      _Beat(
        'Luis hat ruhig erklärt, wann er angerufen hatte und warum der Termin wichtig war.',
        'Luis calmly explained when he had called and why the appointment was important.',
      ),
      _Beat(
        'Eine andere Patientin hat ihren späteren Termin mit ihm getauscht.',
        'Another patient swapped her later appointment with him.',
      ),
      _Beat(
        'Seitdem wiederholt Luis Datum und Uhrzeit am Telefon zweimal.',
        'Since then Luis repeats the date and time twice on the phone.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('vereinbaren', 'to arrange'),
      StoryGloss('die Praxis', 'medical practice'),
      StoryGloss('notieren', 'to note'),
      StoryGloss('tauschen', 'to swap'),
    ],
  ),
  _ReaderSeed(
    id: 'st-a2-10',
    level: CefrLevel.a2,
    emoji: '📖',
    title: 'Die Lesung in der Bibliothek',
    titleEnglish: 'The reading at the library',
    blurb: 'A small poster becomes a well-attended neighbourhood event.',
    protagonist: 'Hannah',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Hannah arbeitet ehrenamtlich in einer kleinen Bibliothek.',
        'Hannah volunteers in a small library.',
      ),
      _Beat(
        'Sie hat eine Lesung mit einer jungen Autorin geplant.',
        'She planned a reading with a young author.',
      ),
      _Beat(
        'Eine Woche vorher hatten sich erst drei Personen angemeldet.',
        'A week beforehand only three people had registered.',
      ),
      _Beat(
        'Die teure Werbung im Internet war für die Bibliothek nicht möglich.',
        'Expensive internet advertising was not possible for the library.',
      ),
      _Beat(
        'Hannah hat bunte Plakate in Cafés und im Jugendzentrum aufgehängt.',
        'Hannah put up colourful posters in cafés and the youth centre.',
      ),
      _Beat(
        'Am Abend der Lesung waren alle vierzig Stühle besetzt.',
        'On the evening of the reading all forty chairs were occupied.',
      ),
      _Beat(
        'Die Autorin hat danach einen zweiten Termin angeboten.',
        'The author offered a second date afterwards.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('ehrenamtlich', 'voluntarily'),
      StoryGloss('die Lesung', 'reading event'),
      StoryGloss('sich anmelden', 'to register'),
      StoryGloss('besetzt', 'occupied'),
    ],
  ),
  _ReaderSeed(
    id: 'st-a2-11',
    level: CefrLevel.a2,
    emoji: '🔧',
    title: 'Kein warmes Wasser',
    titleEnglish: 'No hot water',
    blurb: 'Yuki and her neighbours organise a repair in their building.',
    protagonist: 'Yuki',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Seit Montag gab es in Yukis Wohnung kein warmes Wasser.',
        'Since Monday there had been no hot water in Yuki flat.',
      ),
      _Beat(
        'Auch zwei Nachbarn hatten dasselbe Problem.',
        'Two neighbours had the same problem.',
      ),
      _Beat(
        'Der Vermieter antwortete nicht auf die erste E-Mail.',
        'The landlord did not answer the first email.',
      ),
      _Beat(
        'Am Telefon erreichte Yuki nur eine automatische Nachricht.',
        'On the phone Yuki only reached an automated message.',
      ),
      _Beat(
        'Die Nachbarn schrieben gemeinsam eine genaue Liste mit allen Wohnungen.',
        'The neighbours jointly wrote a precise list of all the flats.',
      ),
      _Beat(
        'Mit dieser Information kam am nächsten Morgen ein Handwerker.',
        'With this information a technician came the next morning.',
      ),
      _Beat(
        'Nach der Reparatur richteten sie eine gemeinsame Hausgruppe ein.',
        'After the repair they set up a shared building group.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('der Vermieter', 'landlord'),
      StoryGloss('erreichen', 'to reach'),
      StoryGloss('der Handwerker', 'technician'),
      StoryGloss('einrichten', 'to set up'),
    ],
  ),

  _ReaderSeed(
    id: 'st-b1-05',
    level: CefrLevel.b1,
    emoji: '🧰',
    title: 'Der erste Tag in der Werkstatt',
    titleEnglish: 'The first day in the workshop',
    blurb: 'Priya notices a safety problem on her first day at a new job.',
    protagonist: 'Priya',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Priya begann ihre neue Stelle in einer Fahrradwerkstatt mit großer Vorfreude.',
        'Priya began her new job in a bicycle workshop with great anticipation.',
      ),
      _Beat(
        'Der Meister zeigte ihr die Werkzeuge und erklärte den Tagesplan.',
        'The supervisor showed her the tools and explained the daily plan.',
      ),
      _Beat(
        'Neben einer Maschine lag jedoch ein Stromkabel mit beschädigter Isolierung.',
        'However, beside one machine lay a power cable with damaged insulation.',
      ),
      _Beat(
        'Ein Kollege meinte, die Maschine werde seit Monaten trotzdem benutzt.',
        'A colleague said the machine had nevertheless been used for months.',
      ),
      _Beat(
        'Priya unterbrach die Arbeit und meldete den Schaden sachlich beim Meister.',
        'Priya stopped the work and reported the damage calmly to the supervisor.',
      ),
      _Beat(
        'Gemeinsam sperrten sie die Maschine, bis ein Elektriker das Kabel ersetzt hatte.',
        'Together they blocked the machine until an electrician had replaced the cable.',
      ),
      _Beat(
        'Beim nächsten Teamgespräch wurde Priyas Aufmerksamkeit ausdrücklich gelobt.',
        'At the next team meeting Priya attention was explicitly praised.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('die Werkstatt', 'workshop'),
      StoryGloss('die Isolierung', 'insulation'),
      StoryGloss('den Schaden melden', 'to report damage'),
      StoryGloss('sperren', 'to block off'),
    ],
  ),
  _ReaderSeed(
    id: 'st-b1-06',
    level: CefrLevel.b1,
    emoji: '🎪',
    title: 'Das Fest im Innenhof',
    titleEnglish: 'The courtyard festival',
    blurb:
        'Neighbours plan a festival while disagreeing about noise and costs.',
    protagonist: 'Samir',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Samir wollte mit den Nachbarn ein Sommerfest im Innenhof organisieren.',
        'Samir wanted to organise a summer festival in the courtyard with the neighbours.',
      ),
      _Beat(
        'Viele Familien boten Essen, Musik oder Hilfe beim Aufbau an.',
        'Many families offered food, music or help setting up.',
      ),
      _Beat(
        'Zwei ältere Bewohner befürchteten jedoch Lärm bis spät in die Nacht.',
        'However, two older residents feared noise late into the night.',
      ),
      _Beat(
        'Außerdem war unklar, wer die Miete für Tische und Bänke bezahlen sollte.',
        'It was also unclear who should pay the rental for tables and benches.',
      ),
      _Beat(
        'Samir lud alle zu einem kurzen Planungstreffen mit einer Kostenliste ein.',
        'Samir invited everyone to a short planning meeting with a cost list.',
      ),
      _Beat(
        'Sie vereinbarten ein Ende um zehn Uhr und teilten die Ausgaben freiwillig.',
        'They agreed to finish at ten and shared the expenses voluntarily.',
      ),
      _Beat(
        'Das Fest verlief ruhig, und im Herbst traf sich die Gruppe erneut.',
        'The festival went peacefully, and in autumn the group met again.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('der Innenhof', 'courtyard'),
      StoryGloss('befürchten', 'to fear'),
      StoryGloss('vereinbaren', 'to agree'),
      StoryGloss('die Ausgabe', 'expense'),
    ],
  ),
  _ReaderSeed(
    id: 'st-b1-07',
    level: CefrLevel.b1,
    emoji: '🥫',
    title: 'Die Schicht bei der Tafel',
    titleEnglish: 'The shift at the food bank',
    blurb: 'A delivery mix-up forces a volunteer team to improvise.',
    protagonist: 'Jonas',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Jonas half jeden Freitag bei einer Ausgabestelle für Lebensmittel.',
        'Jonas helped every Friday at a food distribution centre.',
      ),
      _Beat(
        'An diesem Morgen warteten besonders viele Menschen vor der Tür.',
        'That morning an especially large number of people were waiting outside.',
      ),
      _Beat(
        'Die angekündigte Lieferung mit Brot und Milch kam nicht an.',
        'The announced delivery of bread and milk did not arrive.',
      ),
      _Beat(
        'Im Lager waren nur Konserven und wenige Packungen Reis übrig.',
        'Only tins and a few packets of rice were left in storage.',
      ),
      _Beat(
        'Jonas rief zwei Supermärkte an und erklärte die dringende Lage.',
        'Jonas called two supermarkets and explained the urgent situation.',
      ),
      _Beat(
        'Ein Markt stellte kurzfristig Brot bereit, der andere lieferte Obst.',
        'One market quickly provided bread, the other delivered fruit.',
      ),
      _Beat(
        'Danach führte das Team eine Liste mit mehreren Ersatzkontakten.',
        'Afterwards the team kept a list of several backup contacts.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('die Ausgabestelle', 'distribution centre'),
      StoryGloss('ankündigen', 'to announce'),
      StoryGloss('übrig', 'left over'),
      StoryGloss('bereitstellen', 'to provide'),
    ],
  ),
  _ReaderSeed(
    id: 'st-b1-08',
    level: CefrLevel.b1,
    emoji: '💻',
    title: 'Der gebrauchte Laptop',
    titleEnglish: 'The used laptop',
    blurb:
        'A private online purchase arrives in a different condition than promised.',
    protagonist: 'Mei',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Mei kaufte über eine Plattform einen gebrauchten Laptop für ihr Studium.',
        'Mei bought a used laptop for her studies through a platform.',
      ),
      _Beat(
        'In der Anzeige wurde das Gerät als vollständig funktionsfähig beschrieben.',
        'The listing described the device as fully functional.',
      ),
      _Beat(
        'Nach dem Auspacken bemerkte Mei einen Riss im Bildschirm und einen schwachen Akku.',
        'After unpacking, Mei noticed a crack in the screen and a weak battery.',
      ),
      _Beat(
        'Der Verkäufer behauptete zunächst, der Schaden müsse beim Transport entstanden sein.',
        'The seller initially claimed the damage must have occurred during transport.',
      ),
      _Beat(
        'Mei schickte ihm die Fotos aus der Anzeige und Bilder der unbeschädigten Verpackung.',
        'Mei sent him the listing photos and pictures of the undamaged packaging.',
      ),
      _Beat(
        'Nach einer sachlichen Nachricht akzeptierte er die Rückgabe gegen Erstattung.',
        'After a factual message he accepted the return for a refund.',
      ),
      _Beat(
        'Beim nächsten Kauf bat Mei vorab um ein aktuelles Video des Geräts.',
        'For her next purchase Mei asked in advance for a current video of the device.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('gebraucht', 'used'),
      StoryGloss('der Riss', 'crack'),
      StoryGloss('behaupten', 'to claim'),
      StoryGloss('die Erstattung', 'refund'),
    ],
  ),
  _ReaderSeed(
    id: 'st-b1-09',
    level: CefrLevel.b1,
    emoji: '🥾',
    title: 'Nebel auf dem Höhenweg',
    titleEnglish: 'Fog on the high trail',
    blurb: 'A hiking group changes its plan when the weather turns.',
    protagonist: 'Felix',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Felix wanderte mit drei Freunden auf einem gut markierten Höhenweg.',
        'Felix was hiking with three friends on a well-marked high trail.',
      ),
      _Beat(
        'Am Morgen hatte der Wetterbericht nur leichte Wolken angekündigt.',
        'In the morning the forecast had announced only light cloud.',
      ),
      _Beat(
        'Gegen Mittag zog dichter Nebel auf, sodass die nächste Markierung kaum zu sehen war.',
        'Around midday dense fog arrived, so the next marker was barely visible.',
      ),
      _Beat(
        'Ein Freund wollte trotzdem bis zum geplanten Gipfel weitergehen.',
        'One friend nevertheless wanted to continue to the planned summit.',
      ),
      _Beat(
        'Felix verglich Karte und Standort und schlug den kürzeren Weg ins Tal vor.',
        'Felix compared the map and location and suggested the shorter route into the valley.',
      ),
      _Beat(
        'Die Gruppe informierte die Unterkunft und stieg langsam gemeinsam ab.',
        'The group informed the accommodation and descended slowly together.',
      ),
      _Beat(
        'Am Abend waren alle enttäuscht, aber mit der Entscheidung zufrieden.',
        'In the evening everyone was disappointed but satisfied with the decision.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('der Höhenweg', 'high trail'),
      StoryGloss('dicht', 'dense'),
      StoryGloss('der Gipfel', 'summit'),
      StoryGloss('absteigen', 'to descend'),
    ],
  ),
  _ReaderSeed(
    id: 'st-b1-10',
    level: CefrLevel.b1,
    emoji: '🗣️',
    title: 'Zwei Sprachen am Küchentisch',
    titleEnglish: 'Two languages at the kitchen table',
    blurb:
        'A language tandem struggles until the partners change their routine.',
    protagonist: 'Nadia',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Nadia traf sich wöchentlich mit Paul zu einem Deutsch-Arabisch-Tandem.',
        'Nadia met Paul weekly for a German-Arabic tandem.',
      ),
      _Beat(
        'Beide wollten jeweils eine halbe Stunde in jeder Sprache sprechen.',
        'Both wanted to speak for half an hour in each language.',
      ),
      _Beat(
        'Nach wenigen Treffen redete Paul fast nur Deutsch, weil Gespräche so schneller liefen.',
        'After a few meetings Paul spoke almost only German because conversations moved faster that way.',
      ),
      _Beat(
        'Nadia lernte zwar viel, konnte Paul aber kaum beim Arabischen helfen.',
        'Nadia learned a lot, but could hardly help Paul with Arabic.',
      ),
      _Beat(
        'Sie schlug einen Timer und zwei vorbereitete Themenkarten vor.',
        'She suggested a timer and two prepared topic cards.',
      ),
      _Beat(
        'Mit der neuen Regel bekamen beide gleich viel Redezeit und konkretere Korrekturen.',
        'With the new rule both got equal speaking time and more concrete corrections.',
      ),
      _Beat(
        'Aus dem Tandem wurde schließlich eine verlässliche Lernfreundschaft.',
        'The tandem eventually became a reliable learning friendship.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('jeweils', 'each'),
      StoryGloss('die Redezeit', 'speaking time'),
      StoryGloss('vorbereiten', 'to prepare'),
      StoryGloss('verlässlich', 'reliable'),
    ],
  ),
  _ReaderSeed(
    id: 'st-b1-11',
    level: CefrLevel.b1,
    emoji: '🧪',
    title: 'Das Experiment der Klasse',
    titleEnglish: 'The class experiment',
    blurb:
        'A school project produces an unexpected result and a lesson about evidence.',
    protagonist: 'Rami',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Ramis Klasse untersuchte, unter welchem Licht Pflanzen am besten wachsen.',
        'Rami class investigated under which light plants grow best.',
      ),
      _Beat(
        'Drei Gruppen stellten gleiche Töpfe an unterschiedliche Fenster.',
        'Three groups placed identical pots at different windows.',
      ),
      _Beat(
        'Nach zwei Wochen war ausgerechnet die Pflanze im dunkleren Raum am höchsten.',
        'After two weeks, of all things, the plant in the darker room was tallest.',
      ),
      _Beat(
        'Einige Schülerinnen wollten daraus sofort eine klare Regel ableiten.',
        'Some pupils wanted to derive a clear rule from it immediately.',
      ),
      _Beat(
        'Rami bemerkte, dass diese Pflanze am Anfang bereits größer gewesen war.',
        'Rami noticed that this plant had already been larger at the start.',
      ),
      _Beat(
        'Die Klasse wiederholte den Versuch mit gemessenen Ausgangshöhen und mehr Pflanzen.',
        'The class repeated the experiment with measured starting heights and more plants.',
      ),
      _Beat(
        'Beim zweiten Versuch zeigte sich der erwartete Vorteil des helleren Fensters.',
        'The second experiment showed the expected advantage of the brighter window.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('untersuchen', 'to investigate'),
      StoryGloss('ableiten', 'to infer'),
      StoryGloss('die Ausgangshöhe', 'starting height'),
      StoryGloss('der Versuch', 'experiment'),
    ],
  ),

  _ReaderSeed(
    id: 'st-b2-04',
    level: CefrLevel.b2,
    emoji: '🚲',
    title: 'Die Petition für den Radweg',
    titleEnglish: 'The petition for the cycle path',
    blurb:
        'A citizens group learns that a popular demand still needs a workable design.',
    protagonist: 'Klara',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Klara sammelte mit einer Bürgerinitiative Unterschriften für einen geschützten Radweg.',
        'Klara collected signatures for a protected cycle path with a citizens initiative.',
      ),
      _Beat(
        'Innerhalb einer Woche unterstützten mehr als tausend Menschen die Forderung.',
        'Within a week more than a thousand people supported the demand.',
      ),
      _Beat(
        'Bei der Anhörung wiesen Geschäftsleute auf fehlende Lieferflächen entlang der Straße hin.',
        'At the hearing business owners pointed to a lack of delivery spaces along the street.',
      ),
      _Beat(
        'Einige Mitglieder wollten den Einwand als bloße Verzögerung abweisen.',
        'Some members wanted to dismiss the objection as mere delay.',
      ),
      _Beat(
        'Klara schlug stattdessen zeitlich begrenzte Ladezonen in den Seitenstraßen vor.',
        'Klara instead suggested time-limited loading zones in the side streets.',
      ),
      _Beat(
        'Die überarbeitete Planung erhielt schließlich eine breite Mehrheit im Ausschuss.',
        'The revised plan eventually received a broad majority in the committee.',
      ),
      _Beat(
        'Die Initiative verstand, dass Zustimmung und sorgfältige Umsetzung verschiedene Aufgaben sind.',
        'The initiative understood that approval and careful implementation are different tasks.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('die Bürgerinitiative', 'citizens initiative'),
      StoryGloss('die Anhörung', 'hearing'),
      StoryGloss('abweisen', 'to dismiss'),
      StoryGloss('die Ladezone', 'loading zone'),
    ],
  ),
  _ReaderSeed(
    id: 'st-b2-05',
    level: CefrLevel.b2,
    emoji: '🚀',
    title: 'Der Kunde, der nicht passte',
    titleEnglish: 'The client who did not fit',
    blurb:
        'A young company must choose between quick revenue and its product strategy.',
    protagonist: 'Tobias',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Tobias leitete ein junges Unternehmen, das Software für kleine Handwerksbetriebe entwickelte.',
        'Tobias ran a young company developing software for small craft businesses.',
      ),
      _Beat(
        'Ein großer Konzern bot plötzlich einen Auftrag an, der den Jahresumsatz verdoppelt hätte.',
        'A large corporation suddenly offered a contract that would have doubled annual revenue.',
      ),
      _Beat(
        'Dafür verlangte der Konzern zahlreiche Sonderfunktionen, die kein anderer Kunde brauchte.',
        'In return, the corporation demanded numerous special features that no other client needed.',
      ),
      _Beat(
        'Im Team entstand Streit darüber, ob finanzielle Sicherheit wichtiger als die Produktstrategie sei.',
        'The team argued about whether financial security was more important than product strategy.',
      ),
      _Beat(
        'Tobias berechnete nicht nur den Umsatz, sondern auch die langfristigen Wartungskosten.',
        'Tobias calculated not only the revenue but also the long-term maintenance costs.',
      ),
      _Beat(
        'Das Unternehmen lehnte den Großauftrag ab und gewann später drei passende mittelgroße Kunden.',
        'The company rejected the large contract and later won three suitable medium-sized clients.',
      ),
      _Beat(
        'Die Entscheidung blieb riskant, stärkte jedoch die gemeinsame Richtung.',
        'The decision remained risky, but strengthened the shared direction.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('der Jahresumsatz', 'annual revenue'),
      StoryGloss('die Sonderfunktion', 'custom feature'),
      StoryGloss('die Wartung', 'maintenance'),
      StoryGloss('ablehnen', 'to reject'),
    ],
  ),
  _ReaderSeed(
    id: 'st-b2-06',
    level: CefrLevel.b2,
    emoji: '🧑‍⚕️',
    title: 'Der neue Dienstplan',
    titleEnglish: 'The new rota',
    blurb:
        'A care team negotiates a rota that looks fair on paper but not in practice.',
    protagonist: 'Aylin',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Aylin koordinierte den Dienstplan einer kleinen Pflegeeinrichtung.',
        'Aylin coordinated the rota of a small care facility.',
      ),
      _Beat(
        'Eine neue Software verteilte Wochenenddienste automatisch und scheinbar gleichmäßig.',
        'New software distributed weekend shifts automatically and apparently evenly.',
      ),
      _Beat(
        'Beschäftigte mit kleinen Kindern erhielten dennoch mehrfach besonders ungünstige Kombinationen.',
        'Employees with young children nevertheless repeatedly received particularly difficult combinations.',
      ),
      _Beat(
        'Die reine Anzahl der Dienste zeigte diese Belastung nicht.',
        'The mere number of shifts did not show this burden.',
      ),
      _Beat(
        'Aylin ergänzte Kriterien für aufeinanderfolgende Dienste und dokumentierte persönliche Einschränkungen.',
        'Aylin added criteria for consecutive shifts and documented personal constraints.',
      ),
      _Beat(
        'Das Team prüfte den Plan gemeinsam, bevor er endgültig veröffentlicht wurde.',
        'The team reviewed the rota together before it was finally published.',
      ),
      _Beat(
        'Die Verteilung war nun nicht mathematisch identisch, wurde aber als gerechter erlebt.',
        'The distribution was no longer mathematically identical, but was experienced as fairer.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('der Dienstplan', 'rota'),
      StoryGloss('die Belastung', 'burden'),
      StoryGloss('aufeinanderfolgend', 'consecutive'),
      StoryGloss('veröffentlichen', 'to publish'),
    ],
  ),
  _ReaderSeed(
    id: 'st-b2-07',
    level: CefrLevel.b2,
    emoji: '🏠',
    title: 'Die Dämmung des alten Hauses',
    titleEnglish: 'Insulating the old building',
    blurb: 'Owners and tenants debate an energy renovation and its costs.',
    protagonist: 'Herr Nguyen',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Herr Nguyen verwaltete ein altes Mehrfamilienhaus mit hohen Heizkosten.',
        'Mr Nguyen managed an old apartment building with high heating costs.',
      ),
      _Beat(
        'Ein Gutachten empfahl eine umfassende Dämmung und neue Fenster.',
        'An assessment recommended comprehensive insulation and new windows.',
      ),
      _Beat(
        'Die Mieterinnen befürchteten, dass ein großer Teil der Kosten auf ihre Miete umgelegt würde.',
        'The tenants feared that a large part of the costs would be passed on to their rent.',
      ),
      _Beat(
        'Gleichzeitig litten besonders die Dachwohnungen unter Kälte und Zugluft.',
        'At the same time the attic flats suffered particularly from cold and draughts.',
      ),
      _Beat(
        'Herr Nguyen beantragte Fördermittel und ließ drei Varianten mit unterschiedlichen Kosten berechnen.',
        'Mr Nguyen applied for funding and had three options with different costs calculated.',
      ),
      _Beat(
        'Eine mittlere Lösung senkte den Energieverbrauch deutlich, ohne die höchste Umlage zu verlangen.',
        'A middle option significantly reduced energy use without requiring the highest surcharge.',
      ),
      _Beat(
        'Nach zwei Wintern bestätigten niedrigere Rechnungen einen Teil der Prognose.',
        'After two winters lower bills confirmed part of the forecast.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('die Dämmung', 'insulation'),
      StoryGloss('umlegen', 'to pass on costs'),
      StoryGloss('die Zugluft', 'draught'),
      StoryGloss('das Fördermittel', 'subsidy'),
    ],
  ),
  _ReaderSeed(
    id: 'st-b2-08',
    level: CefrLevel.b2,
    emoji: '🏺',
    title: 'Die Schale im Magazin',
    titleEnglish: 'The bowl in storage',
    blurb: 'A museum intern questions the uncertain origin of an exhibit.',
    protagonist: 'Mara',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Mara sichtete während ihres Praktikums alte Bestandslisten eines Stadtmuseums.',
        'During her internship Mara reviewed old inventory lists of a city museum.',
      ),
      _Beat(
        'Bei einer wertvollen Schale fehlten Angaben darüber, wie sie 1938 erworben worden war.',
        'For a valuable bowl, information was missing about how it had been acquired in 1938.',
      ),
      _Beat(
        'Der geplante Ausstellungstext bezeichnete die Herkunft trotzdem als vollständig geklärt.',
        'The planned exhibition text nevertheless described the origin as fully clarified.',
      ),
      _Beat(
        'Ein Kollege hielt den fehlenden Beleg für ein übliches Problem alter Akten.',
        'A colleague considered the missing evidence a common problem with old files.',
      ),
      _Beat(
        'Mara verglich Korrespondenzen und fand den Namen einer Familie, die fliehen musste.',
        'Mara compared correspondence and found the name of a family that had been forced to flee.',
      ),
      _Beat(
        'Das Museum stoppte die Präsentation und nahm Kontakt zu möglichen Erben auf.',
        'The museum stopped the presentation and contacted possible heirs.',
      ),
      _Beat(
        'Die offene Lücke wurde zum Ausgangspunkt weiterer Provenienzforschung.',
        'The open gap became the starting point for further provenance research.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('das Magazin', 'museum storage'),
      StoryGloss('der Erwerb', 'acquisition'),
      StoryGloss('der Beleg', 'evidence'),
      StoryGloss('die Provenienz', 'provenance'),
    ],
  ),
  _ReaderSeed(
    id: 'st-b2-09',
    level: CefrLevel.b2,
    emoji: '📰',
    title: 'Die Zahl in der Überschrift',
    titleEnglish: 'The number in the headline',
    blurb:
        'A local reporter discovers that a dramatic statistic needs context.',
    protagonist: 'Daniel',
    chapterCount: 4,
    beats: <_Beat>[
      _Beat(
        'Daniel schrieb für eine Lokalzeitung über einen Anstieg gemeldeter Fahrraddiebstähle.',
        'Daniel wrote for a local newspaper about an increase in reported bicycle thefts.',
      ),
      _Beat(
        'Die Pressemitteilung sprach von einer Zunahme um fünfzig Prozent.',
        'The press release spoke of an increase of fifty percent.',
      ),
      _Beat(
        'Kurz vor Redaktionsschluss bemerkte Daniel, dass die Zahl von vier auf sechs Fälle gestiegen war.',
        'Shortly before deadline Daniel noticed that the number had risen from four to six cases.',
      ),
      _Beat(
        'Die geplante Überschrift hätte einen viel größeren Trend vermuten lassen.',
        'The planned headline would have suggested a much larger trend.',
      ),
      _Beat(
        'Daniel ergänzte die absoluten Zahlen und verglich mehrere Jahre.',
        'Daniel added the absolute figures and compared several years.',
      ),
      _Beat(
        'Der Artikel berichtete nun über die Unsicherheit, ohne die neuen Fälle zu verharmlosen.',
        'The article now reported the uncertainty without trivialising the new cases.',
      ),
      _Beat(
        'Am nächsten Tag lobte sogar die Polizei die sachliche Einordnung.',
        'The next day even the police praised the factual context.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('die Pressemitteilung', 'press release'),
      StoryGloss('der Redaktionsschluss', 'deadline'),
      StoryGloss('absolut', 'absolute'),
      StoryGloss('verharmlosen', 'to play down'),
    ],
  ),
  _ReaderSeed(
    id: 'st-b2-10',
    level: CefrLevel.b2,
    emoji: '🤝',
    title: 'Zwei Teams, ein Termin',
    titleEnglish: 'Two teams, one deadline',
    blurb:
        'A project conflict turns out to be a conflict between different definitions of done.',
    protagonist: 'Svenja',
    chapterCount: 3,
    beats: <_Beat>[
      _Beat(
        'Svenja koordinierte ein Projekt zwischen einem Design- und einem Entwicklungsteam.',
        'Svenja coordinated a project between a design and a development team.',
      ),
      _Beat(
        'Beide Teams hatten demselben Veröffentlichungstermin zugestimmt.',
        'Both teams had agreed to the same release date.',
      ),
      _Beat(
        'Kurz davor warf jede Seite der anderen vor, wichtige Arbeit nicht abgeschlossen zu haben.',
        'Shortly beforehand each side accused the other of not having completed important work.',
      ),
      _Beat(
        'Im Gespräch zeigte sich, dass „fertig“ für beide Teams etwas anderes bedeutete.',
        'In the discussion it became clear that finished meant something different to each team.',
      ),
      _Beat(
        'Svenja ließ alle offenen Schritte mit Verantwortlichen und Prüfkriterien aufschreiben.',
        'Svenja had all open steps written down with owners and acceptance criteria.',
      ),
      _Beat(
        'Sie verschoben nur den riskanten Teil und veröffentlichten den stabilen Umfang pünktlich.',
        'They postponed only the risky part and released the stable scope on time.',
      ),
      _Beat(
        'Für künftige Projekte vereinbarten sie eine gemeinsame Definition von abgeschlossen.',
        'For future projects they agreed on a shared definition of completed.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('koordinieren', 'to coordinate'),
      StoryGloss('vorwerfen', 'to accuse'),
      StoryGloss('das Prüfkriterium', 'acceptance criterion'),
      StoryGloss('der Umfang', 'scope'),
    ],
  ),

  _ReaderSeed(
    id: 'st-c1-04',
    level: CefrLevel.c1,
    emoji: '⚖️',
    title: 'Die Stimme im Ethikrat',
    titleEnglish: 'The voice on the ethics council',
    blurb:
        'A committee member challenges a unanimous recommendation by exposing an omitted group.',
    protagonist: 'Dr. Weber',
    chapterCount: 3,
    beats: <_Beat>[
      _Beat(
        'Dr. Weber wirkte in einem Ethikrat mit, der Leitlinien für den Einsatz eines Diagnoseverfahrens erarbeitete.',
        'Dr Weber served on an ethics council developing guidelines for the use of a diagnostic procedure.',
      ),
      _Beat(
        'Nach mehreren Sitzungen schien eine einstimmige Empfehlung unmittelbar bevorzustehen.',
        'After several meetings a unanimous recommendation seemed imminent.',
      ),
      _Beat(
        'In der abschließenden Vorlage fehlte jedoch jede Betrachtung von Menschen ohne regulären Versicherungsschutz.',
        'The final draft, however, contained no consideration of people without regular insurance coverage.',
      ),
      _Beat(
        'Einige Mitglieder hielten diese Frage für außerhalb des eng gefassten Auftrags.',
        'Some members considered this issue outside the narrowly defined remit.',
      ),
      _Beat(
        'Dr. Weber zeigte, dass gerade der vorgeschlagene Zugangsweg diese Gruppe systematisch ausschließen würde.',
        'Dr Weber showed that the proposed access route itself would systematically exclude this group.',
      ),
      _Beat(
        'Der Rat ergänzte eine Minderheitenperspektive und knüpfte die Empfehlung an einen alternativen Zugang.',
        'The council added a minority perspective and tied the recommendation to an alternative route of access.',
      ),
      _Beat(
        'Die Einigkeit war weniger glatt, aber die Begründung belastbarer geworden.',
        'The consensus was less smooth, but the reasoning had become more robust.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('die Leitlinie', 'guideline'),
      StoryGloss('die Vorlage', 'draft document'),
      StoryGloss('eng gefasst', 'narrowly defined'),
      StoryGloss('belastbar', 'robust'),
    ],
  ),
  _ReaderSeed(
    id: 'st-c1-05',
    level: CefrLevel.c1,
    emoji: '🗄️',
    title: 'Die Lücke im Firmenarchiv',
    titleEnglish: 'The gap in the company archive',
    blurb:
        'An archivist finds that a celebrated anniversary narrative omits an uncomfortable decade.',
    protagonist: 'Helene',
    chapterCount: 3,
    beats: <_Beat>[
      _Beat(
        'Helene bereitete für ein traditionsreiches Unternehmen eine Ausstellung zum hundertjährigen Bestehen vor.',
        'Helene was preparing an exhibition for a long-established company centenary.',
      ),
      _Beat(
        'Die interne Chronik erzählte ausführlich von Innovationen, Krisen und erfolgreichen Produkten.',
        'The internal chronicle told in detail of innovations, crises and successful products.',
      ),
      _Beat(
        'Für die Jahre zwischen 1933 und 1945 enthielt sie dagegen nur zwei auffallend allgemeine Absätze.',
        'For the years between 1933 and 1945, however, it contained only two strikingly general paragraphs.',
      ),
      _Beat(
        'Die Geschäftsführung warnte davor, ungeklärte Verdachtsmomente öffentlich zu machen.',
        'Management warned against making unresolved suspicions public.',
      ),
      _Beat(
        'Helene schlug weder Anklage noch Schweigen vor, sondern eine sichtbare Dokumentation der Forschungslücke.',
        'Helene proposed neither accusation nor silence, but visible documentation of the research gap.',
      ),
      _Beat(
        'Das Unternehmen beauftragte unabhängige Historiker und öffnete ihnen die Bestände.',
        'The company commissioned independent historians and opened the holdings to them.',
      ),
      _Beat(
        'Die Ausstellung zeigte schließlich auch, wie institutionelle Erinnerung überhaupt entsteht.',
        'The exhibition ultimately also showed how institutional memory comes into being.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('das Bestehen', 'anniversary, existence'),
      StoryGloss('auffallend', 'striking'),
      StoryGloss('der Verdachtsmoment', 'ground for suspicion'),
      StoryGloss('der Bestand', 'archival holding'),
    ],
  ),
  _ReaderSeed(
    id: 'st-c1-06',
    level: CefrLevel.c1,
    emoji: '🏥',
    title: 'Eine Nacht auf Station Sieben',
    titleEnglish: 'A night on ward seven',
    blurb:
        'A hospital team must allocate a scarce monitoring bed under uncertainty.',
    protagonist: 'Miriam',
    chapterCount: 3,
    beats: <_Beat>[
      _Beat(
        'Miriam leitete in einer besonders angespannten Nacht den ärztlichen Dienst einer Klinikstation.',
        'Miriam led the medical duty team on a particularly strained night.',
      ),
      _Beat(
        'Für zwei gefährdete Patienten stand nur noch ein intensiv überwachtes Bett zur Verfügung.',
        'Only one intensively monitored bed was available for two at-risk patients.',
      ),
      _Beat(
        'Die üblichen Kennwerte sprachen leicht für den jüngeren Patienten, waren jedoch mit erheblicher Unsicherheit behaftet.',
        'The usual indicators slightly favoured the younger patient, but carried considerable uncertainty.',
      ),
      _Beat(
        'Ein rein schematisches Vorgehen hätte die unterschiedlichen Krankheitsverläufe ausgeblendet.',
        'A purely schematic approach would have ignored the different courses of illness.',
      ),
      _Beat(
        'Miriam ließ beide Fälle unabhängig bewerten und organisierte zugleich zusätzliche mobile Überwachung.',
        'Miriam had both cases assessed independently and simultaneously organised additional mobile monitoring.',
      ),
      _Beat(
        'So erhielt der akut gefährdetere Patient das Bett, während der andere engmaschig auf der Station blieb.',
        'Thus the more acutely endangered patient received the bed, while the other remained under close observation on the ward.',
      ),
      _Beat(
        'Der Fall führte später zu einer Leitlinie, die Urteil und dokumentierte Zweitbewertung verband.',
        'The case later led to a guideline combining judgement and documented second assessment.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('angespannt', 'strained'),
      StoryGloss('behaftet', 'burdened with'),
      StoryGloss('engmaschig', 'closely monitored'),
      StoryGloss('die Zweitbewertung', 'second assessment'),
    ],
  ),
  _ReaderSeed(
    id: 'st-c1-07',
    level: CefrLevel.c1,
    emoji: '🏙️',
    title: 'Der Platz zwischen den Plänen',
    titleEnglish: 'The square between the plans',
    blurb:
        'A participation process reveals that an apparently neutral design serves some users better than others.',
    protagonist: 'Farid',
    chapterCount: 3,
    beats: <_Beat>[
      _Beat(
        'Farid moderierte die Beteiligung zur Neugestaltung eines zentralen Stadtplatzes.',
        'Farid moderated participation in the redesign of a central city square.',
      ),
      _Beat(
        'Der Siegerentwurf versprach Offenheit, klare Sichtachsen und eine großzügige Veranstaltungsfläche.',
        'The winning design promised openness, clear sight lines and a generous event space.',
      ),
      _Beat(
        'Eltern, ältere Menschen und ein Jugendclub kritisierten jedoch den Verlust von Schatten, Sitzplätzen und informellen Nischen.',
        'Parents, older people and a youth club criticised the loss of shade, seating and informal niches.',
      ),
      _Beat(
        'Das Planungsteam verwies darauf, dass alle Gruppen dieselbe offene Fläche nutzen könnten.',
        'The planning team pointed out that all groups could use the same open space.',
      ),
      _Beat(
        'Farid machte sichtbar, dass formale Zugänglichkeit nicht mit gleicher Nutzbarkeit identisch ist.',
        'Farid made visible that formal accessibility is not identical with equal usability.',
      ),
      _Beat(
        'Der Entwurf wurde um Bäume, bewegliche Sitze und kleinere Aufenthaltsbereiche ergänzt.',
        'The design was supplemented with trees, movable seating and smaller areas to linger.',
      ),
      _Beat(
        'Der überarbeitete Platz verlor an grafischer Reinheit und gewann an tatsächlicher Öffentlichkeit.',
        'The revised square lost graphic purity and gained actual publicness.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('die Sichtachse', 'sight line'),
      StoryGloss('die Nische', 'niche'),
      StoryGloss('die Nutzbarkeit', 'usability'),
      StoryGloss('der Aufenthaltsbereich', 'area to linger'),
    ],
  ),
  _ReaderSeed(
    id: 'st-c1-08',
    level: CefrLevel.c1,
    emoji: '🔬',
    title: 'Der zweite Versuch',
    titleEnglish: 'The second attempt',
    blurb:
        'A research group cannot reproduce a celebrated finding and must decide how to respond.',
    protagonist: 'Lena',
    chapterCount: 3,
    beats: <_Beat>[
      _Beat(
        'Lena leitete eine Arbeitsgruppe, die ein viel beachtetes psychologisches Experiment wiederholen wollte.',
        'Lena led a research group that wanted to repeat a widely noted psychological experiment.',
      ),
      _Beat(
        'Das Team hielt sich eng an die veröffentlichte Methode und plante eine größere Stichprobe.',
        'The team adhered closely to the published method and planned a larger sample.',
      ),
      _Beat(
        'Der berichtete Effekt ließ sich dennoch nicht nachweisen, obwohl die Messungen zuverlässig erschienen.',
        'The reported effect nevertheless could not be demonstrated, although the measurements appeared reliable.',
      ),
      _Beat(
        'Ein Kollege schlug vor, zunächst weitere Varianten zu testen und die Abweichung vorläufig nicht zu veröffentlichen.',
        'A colleague suggested first testing further variants and not publishing the discrepancy for the time being.',
      ),
      _Beat(
        'Lena trennte mögliche Erklärungen von nachträglichen Rettungsversuchen und dokumentierte sämtliche Analysen.',
        'Lena separated possible explanations from retrospective rescue attempts and documented all analyses.',
      ),
      _Beat(
        'Die Gruppe veröffentlichte den Nullbefund zusammen mit Material und Daten für weitere Prüfungen.',
        'The group published the null result together with materials and data for further checks.',
      ),
      _Beat(
        'Die Debatte wurde dadurch nicht beendet, aber auf eine überprüfbare Grundlage gestellt.',
        'The debate was not ended by this, but placed on a verifiable foundation.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('die Stichprobe', 'sample'),
      StoryGloss('nachweisen', 'to demonstrate'),
      StoryGloss('die Abweichung', 'discrepancy'),
      StoryGloss('der Nullbefund', 'null result'),
    ],
  ),
  _ReaderSeed(
    id: 'st-c1-09',
    level: CefrLevel.c1,
    emoji: '🎭',
    title: 'Zwischen zwei Deutungen',
    titleEnglish: 'Between two interpretations',
    blurb:
        'A cultural mediator discovers that a conflict rests on different expectations about public criticism.',
    protagonist: 'Salma',
    chapterCount: 3,
    beats: <_Beat>[
      _Beat(
        'Salma begleitete eine deutsch-marokkanische Theaterproduktion als kulturelle Vermittlerin.',
        'Salma accompanied a German-Moroccan theatre production as a cultural mediator.',
      ),
      _Beat(
        'Nach einer Probe kritisierte der deutsche Regisseur eine Szene vor dem gesamten Ensemble sehr direkt.',
        'After a rehearsal the German director criticised a scene very directly in front of the whole ensemble.',
      ),
      _Beat(
        'Mehrere Darsteller verstanden die öffentliche Form als persönliche Herabsetzung und zogen sich zurück.',
        'Several performers understood the public form as personal humiliation and withdrew.',
      ),
      _Beat(
        'Der Regisseur wiederum hielt die Reaktion für mangelnde Bereitschaft zu professioneller Kritik.',
        'The director in turn considered the reaction a lack of willingness to accept professional criticism.',
      ),
      _Beat(
        'Salma übersetzte nicht nur die Worte, sondern erklärte die unterschiedlichen Erwartungen an Ort und Form von Rückmeldung.',
        'Salma translated not only the words, but explained the different expectations regarding place and form of feedback.',
      ),
      _Beat(
        'Das Ensemble vereinbarte öffentliche Sachhinweise und persönliche Kritik in kleineren Gesprächen.',
        'The ensemble agreed on public factual notes and personal criticism in smaller conversations.',
      ),
      _Beat(
        'Die neue Regel löste nicht jede Spannung, verhinderte aber vorschnelle Zuschreibungen.',
        'The new rule did not resolve every tension, but prevented premature attributions.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('die Vermittlerin', 'mediator'),
      StoryGloss('die Herabsetzung', 'humiliation'),
      StoryGloss('die Rückmeldung', 'feedback'),
      StoryGloss('die Zuschreibung', 'attribution'),
    ],
  ),

  _ReaderSeed(
    id: 'st-c2-04',
    level: CefrLevel.c2,
    emoji: '📜',
    title: 'Der Artikel und sein Schatten',
    titleEnglish: 'The article and its shadow',
    blurb:
        'A constitutional court weighs equal treatment against a rule designed for a different historical problem.',
    protagonist: 'Richterin Albrecht',
    chapterCount: 3,
    beats: <_Beat>[
      _Beat(
        'Richterin Albrecht bearbeitete ein Verfahren, in dem eine scheinbar eindeutige Gleichheitsregel auf eine neuartige Konstellation traf.',
        'Judge Albrecht handled a case in which a seemingly clear equality rule met a novel constellation.',
      ),
      _Beat(
        'Der Wortlaut sprach für eine identische Behandlung, während die Entstehungsgeschichte auf den Schutz vor einer bestimmten Benachteiligung zielte.',
        'The wording supported identical treatment, while the legislative history aimed to protect against a specific disadvantage.',
      ),
      _Beat(
        'Beide Seiten beanspruchten daher nicht nur das Recht, sondern jeweils dessen angeblich einzig konsequente Auslegung.',
        'Both sides therefore claimed not only the law, but its supposedly only consistent interpretation.',
      ),
      _Beat(
        'Eine enge Lesart bewahrte Berechenbarkeit, drohte jedoch den historischen Schutzzweck in sein Gegenteil zu verkehren.',
        'A narrow reading preserved predictability, but threatened to reverse the historical protective purpose.',
      ),
      _Beat(
        'Albrecht unterschied zwischen formaler Symmetrie und der Rechtfertigung vergleichbarer tatsächlicher Folgen.',
        'Albrecht distinguished between formal symmetry and the justification of comparable actual effects.',
      ),
      _Beat(
        'Das Urteil ließ begrenzte Differenzierung zu, band sie aber an strenge Begründungs- und Überprüfungspflichten.',
        'The judgment allowed limited differentiation, but tied it to strict duties of justification and review.',
      ),
      _Beat(
        'Seine Tragfähigkeit lag weniger in einer endgültigen Formel als in der offengelegten Grenze beider Prinzipien.',
        'Its strength lay less in a final formula than in the disclosed limit of both principles.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('die Konstellation', 'constellation'),
      StoryGloss('der Schutzzweck', 'protective purpose'),
      StoryGloss('verkehren', 'to turn into'),
      StoryGloss('die Tragfähigkeit', 'robustness'),
    ],
  ),
  _ReaderSeed(
    id: 'st-c2-05',
    level: CefrLevel.c2,
    emoji: '✒️',
    title: 'Die Notiz im Nachlass',
    titleEnglish: 'The note in the literary estate',
    blurb:
        'An editor must decide whether an unpublished note belongs to a writer work or merely to its workshop.',
    protagonist: 'Eva',
    chapterCount: 3,
    beats: <_Beat>[
      _Beat(
        'Eva sichtete den Nachlass einer Schriftstellerin, deren unvollendeter Roman postum erscheinen sollte.',
        'Eva reviewed the estate of a writer whose unfinished novel was to appear posthumously.',
      ),
      _Beat(
        'Zwischen den Manuskriptseiten fand sie eine scharf formulierte Notiz über eine noch lebende Person.',
        'Between the manuscript pages she found a sharply worded note about a person still alive.',
      ),
      _Beat(
        'Unklar blieb, ob die Passage für den Roman bestimmt, verworfen oder lediglich als private Gedächtnisstütze notiert worden war.',
        'It remained unclear whether the passage was intended for the novel, rejected, or merely recorded as a private memory aid.',
      ),
      _Beat(
        'Der Verlag verwies auf den dokumentarischen Wert einer ungekürzten Ausgabe, die Familie auf den fehlenden Veröffentlichungswillen.',
        'The publisher pointed to the documentary value of an unabridged edition, the family to the lack of intent to publish.',
      ),
      _Beat(
        'Eva entschied sich gegen eine Eingliederung in den fortlaufenden Text, aber für eine kommentierte Erwähnung im editorischen Bericht.',
        'Eva decided against integrating it into the continuous text, but in favour of a commented mention in the editorial report.',
      ),
      _Beat(
        'Damit blieb die Spur zugänglich, ohne aus einer unsicheren Notiz eine autorisierte Aussage zu machen.',
        'The trace thus remained accessible without turning an uncertain note into an authorised statement.',
      ),
      _Beat(
        'Die Ausgabe bekannte ihre Entscheidung, statt sie hinter dem Anschein bloßer Vollständigkeit zu verbergen.',
        'The edition acknowledged its decision instead of hiding it behind the appearance of mere completeness.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('der Nachlass', 'literary estate'),
      StoryGloss('postum', 'posthumously'),
      StoryGloss('verwerfen', 'to reject'),
      StoryGloss('der Veröffentlichungswille', 'intent to publish'),
    ],
  ),
  _ReaderSeed(
    id: 'st-c2-06',
    level: CefrLevel.c2,
    emoji: '🧮',
    title: 'Der gerechte Algorithmus',
    titleEnglish: 'The fair algorithm',
    blurb:
        'An audit team finds that two defensible fairness criteria cannot both be satisfied.',
    protagonist: 'Noah',
    chapterCount: 3,
    beats: <_Beat>[
      _Beat(
        'Noah prüfte ein Modell, das kommunale Förderanträge nach ihrer Erfolgsaussicht priorisieren sollte.',
        'Noah audited a model intended to prioritise municipal grant applications according to their prospects of success.',
      ),
      _Beat(
        'Im Durchschnitt traf das System zutreffendere Entscheidungen als das bisherige manuelle Verfahren.',
        'On average the system made more accurate decisions than the previous manual process.',
      ),
      _Beat(
        'Gleichzeitig unterschieden sich Fehlerquoten und Bewilligungsraten zwischen Stadtteilen mit verschiedener Sozialstruktur.',
        'At the same time error rates and approval rates differed between districts with different social structures.',
      ),
      _Beat(
        'Eine technische Anpassung glich die Fehlerquoten an, vergrößerte jedoch die Unterschiede bei den Bewilligungen.',
        'A technical adjustment equalised error rates, but increased differences in approvals.',
      ),
      _Beat(
        'Noah legte offen, dass die beiden gewünschten Fairnesskriterien unter den gegebenen Daten nicht gleichzeitig erfüllbar waren.',
        'Noah disclosed that the two desired fairness criteria could not be satisfied simultaneously under the given data.',
      ),
      _Beat(
        'Die Verwaltung musste deshalb eine normative Priorität beschließen und ein Einspruchsverfahren einrichten.',
        'The administration therefore had to decide on a normative priority and establish an appeal procedure.',
      ),
      _Beat(
        'Der Algorithmus wurde nicht zum neutralen Schiedsrichter, sondern zum überprüfbaren Teil einer politischen Entscheidung.',
        'The algorithm became not a neutral arbiter, but a reviewable part of a political decision.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('der Förderantrag', 'grant application'),
      StoryGloss('die Fehlerquote', 'error rate'),
      StoryGloss('normativ', 'normative'),
      StoryGloss('das Einspruchsverfahren', 'appeal procedure'),
    ],
  ),
  _ReaderSeed(
    id: 'st-c2-07',
    level: CefrLevel.c2,
    emoji: '🕯️',
    title: 'Der Name auf der Gedenktafel',
    titleEnglish: 'The name on the memorial plaque',
    blurb:
        'A town debates whether commemoration requires honour, explanation, or removal.',
    protagonist: 'Maja',
    chapterCount: 3,
    beats: <_Beat>[
      _Beat(
        'Maja leitete ein Stadtarchiv, als eine Initiative die Entfernung eines belasteten Namens von einer Gedenktafel forderte.',
        'Maja directed a municipal archive when an initiative demanded the removal of a compromised name from a memorial plaque.',
      ),
      _Beat(
        'Der Geehrte hatte kulturelle Einrichtungen gestiftet, zugleich aber nachweislich von enteignetem Vermögen profitiert.',
        'The honouree had endowed cultural institutions, but had also demonstrably profited from expropriated assets.',
      ),
      _Beat(
        'Die einen sahen im Namen eine fortgesetzte Ehrung, die anderen in seiner Tilgung eine bequeme Bereinigung der Geschichte.',
        'Some saw the name as continued honouring, others saw its erasure as a convenient cleansing of history.',
      ),
      _Beat(
        'Beide Positionen setzten stillschweigend voraus, dass eine Tafel nur loben oder verschwinden könne.',
        'Both positions tacitly assumed that a plaque could only praise or disappear.',
      ),
      _Beat(
        'Maja schlug eine Neugestaltung vor, die den Namen erhielt, die Ehrungsform jedoch sichtbar brach und die Herkunft des Vermögens dokumentierte.',
        'Maja proposed a redesign that retained the name but visibly broke the form of honour and documented the origin of the wealth.',
      ),
      _Beat(
        'Die neue Tafel wurde zum Gegenstand von Führungen und blieb dennoch umstritten.',
        'The new plaque became the subject of guided tours and nevertheless remained controversial.',
      ),
      _Beat(
        'Gerade der fortdauernde Streit verhinderte, dass Erinnerung mit abschließender Versöhnung verwechselt wurde.',
        'The continuing dispute itself prevented remembrance from being confused with final reconciliation.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('die Gedenktafel', 'memorial plaque'),
      StoryGloss('belastet', 'historically compromised'),
      StoryGloss('die Tilgung', 'erasure'),
      StoryGloss('die Ehrungsform', 'form of honouring'),
    ],
  ),
  _ReaderSeed(
    id: 'st-c2-08',
    level: CefrLevel.c2,
    emoji: '🕊️',
    title: 'Das Wort im Kommuniqué',
    titleEnglish: 'The word in the communiqué',
    blurb:
        'A translator discovers that one diplomatic verb carries two incompatible promises.',
    protagonist: 'Karim',
    chapterCount: 3,
    beats: <_Beat>[
      _Beat(
        'Karim übersetzte das gemeinsame Kommuniqué zweier Delegationen nach einer angespannten Verhandlungsnacht.',
        'Karim translated the joint communiqué of two delegations after a tense night of negotiations.',
      ),
      _Beat(
        'Im entscheidenden Absatz sollte eine Seite eine umstrittene Maßnahme „überprüfen“, ein bewusst offen gehaltener Ausdruck.',
        'In the decisive paragraph one side was to review a disputed measure, a deliberately open expression.',
      ),
      _Beat(
        'In der Zielsprache legte das naheliegende Verb jedoch entweder bloße Kontrolle oder bereits die Absicht zur Änderung nahe.',
        'In the target language, however, the obvious verb suggested either mere examination or already an intention to change.',
      ),
      _Beat(
        'Beide Delegationen bevorzugten jeweils jene Variante, die ihrem heimischen Publikum den größeren Erfolg versprach.',
        'Each delegation preferred the version that promised the greater success to its domestic audience.',
      ),
      _Beat(
        'Karim erklärte, dass scheinbare sprachliche Eleganz hier einen politischen Gegensatz nur verdecken würde.',
        'Karim explained that apparent linguistic elegance would merely conceal a political contradiction here.',
      ),
      _Beat(
        'Das Kommuniqué übernahm schließlich eine längere Formulierung, die Prüfung und mögliche Folgen ausdrücklich trennte.',
        'The communiqué ultimately adopted a longer formulation explicitly separating review and possible consequences.',
      ),
      _Beat(
        'Der umständlichere Satz war weniger glänzend, aber belastbarer als die elegante Mehrdeutigkeit.',
        'The more cumbersome sentence was less polished, but more robust than the elegant ambiguity.',
      ),
    ],
    glossary: <StoryGloss>[
      StoryGloss('das Kommuniqué', 'communiqué'),
      StoryGloss('offen gehalten', 'left open'),
      StoryGloss('naheliegend', 'obvious'),
      StoryGloss('die Mehrdeutigkeit', 'ambiguity'),
    ],
  ),
];
