import 'models.dart';
import 'radio_models.dart';

const Map<CefrLevel, int> radioLevelTargets = <CefrLevel, int>{
  CefrLevel.a1: 30,
  CefrLevel.a2: 30,
  CefrLevel.b1: 25,
  CefrLevel.b2: 20,
  CefrLevel.c1: 10,
  CefrLevel.c2: 5,
};

/// Turns the hand-written short broadcasts into long-form listening and fills
/// the remaining slots with thematic vocabulary magazines.
///
/// The vocabulary segment is not padding: every sentence introduces a unique
/// level-matched headword in its existing validated example context. Across a
/// level no card is reused, so repeated listening keeps exposing new language.
List<RadioEpisode> buildLongformRadioLibrary({
  required List<RadioEpisode> seeds,
  required List<GermanWord> deck,
}) {
  final List<RadioEpisode> result = <RadioEpisode>[];
  final Set<String> usedWordIds = <String>{};

  for (final CefrLevel level in CefrLevel.values) {
    final List<RadioEpisode> levelSeeds = seeds
        .where((RadioEpisode episode) => episode.level == level)
        .toList(growable: false);
    final List<GermanWord> levelWords = deck
        .where(
          (GermanWord word) =>
              word.cefr == level &&
              word.german.trim().isNotEmpty &&
              word.english.trim().isNotEmpty &&
              word.exampleGerman.trim().isNotEmpty &&
              word.exampleEnglish.trim().isNotEmpty,
        )
        .toList(growable: false);

    for (int index = 0; index < levelSeeds.length; index++) {
      final RadioEpisode seed = levelSeeds[index];
      final List<String> preferred = _preferredCategories(seed.genre);
      final List<GermanWord> words = _selectWords(
        pool: levelWords,
        usedWordIds: usedWordIds,
        preferredCategories: preferred,
        existingLines: seed.lines,
        level: level,
      );
      result.add(_extendSeed(seed, words, preferred.first));
    }

    final int target = radioLevelTargets[level]!;
    final List<String> categories = _rankedCategories(levelWords);
    for (int number = levelSeeds.length + 1; number <= target; number++) {
      final int generatedIndex = number - levelSeeds.length - 1;
      final String category = categories[generatedIndex % categories.length];
      final List<GermanWord> words = _selectWords(
        pool: levelWords,
        usedWordIds: usedWordIds,
        preferredCategories: <String>[category],
        existingLines: const <RadioLine>[],
        level: level,
      );
      result.add(
        _buildMagazine(
          level: level,
          number: number,
          category: category,
          cycle: generatedIndex ~/ categories.length + 1,
          words: words,
        ),
      );
    }
  }

  return List<RadioEpisode>.unmodifiable(result);
}

List<GermanWord> _selectWords({
  required List<GermanWord> pool,
  required Set<String> usedWordIds,
  required List<String> preferredCategories,
  required List<RadioLine> existingLines,
  required CefrLevel level,
}) {
  final Set<String> preferred = preferredCategories
      .map((String value) => value.toLowerCase())
      .toSet();
  final List<GermanWord> ordered = <GermanWord>[
    ...pool.where(
      (GermanWord word) =>
          !usedWordIds.contains(word.id) &&
          preferred.contains(word.category.toLowerCase()),
    ),
    ...pool.where(
      (GermanWord word) =>
          !usedWordIds.contains(word.id) &&
          !preferred.contains(word.category.toLowerCase()),
    ),
  ];

  final List<GermanWord> selected = <GermanWord>[];
  final Set<String> localLemmas = <String>{};
  final List<RadioLine> provisional = <RadioLine>[
    ...existingLines,
    _bridgeLine(level, _categoryLabel(preferredCategories.first)),
  ];

  for (final GermanWord word in ordered) {
    final String lemma = word.german.trim().toLowerCase();
    if (!localLemmas.add(lemma)) continue;
    selected.add(word);
    provisional.add(_wordLine(word, selected.length - 1));
    if (selected.length >= 10 && _wordCount(provisional) >= 270) break;
  }

  if (selected.length < 10 || _wordCount(provisional) < 250) {
    throw StateError(
      'Not enough unused ${level.label} vocabulary to build a radio episode.',
    );
  }
  usedWordIds.addAll(selected.map((GermanWord word) => word.id));
  return selected;
}

RadioEpisode _extendSeed(
  RadioEpisode seed,
  List<GermanWord> words,
  String category,
) {
  final List<RadioLine> lines = <RadioLine>[
    ...seed.lines,
    _bridgeLine(seed.level, _categoryLabel(category)),
    for (int index = 0; index < words.length; index++)
      _wordLine(words[index], index),
    _closingLine(seed.level),
  ];
  return RadioEpisode(
    id: seed.id,
    level: seed.level,
    genre: seed.genre,
    title: seed.title,
    lines: lines,
    listenPrompts: _listenPrompts(words),
    questions: <ChoiceQuestion>[
      ..._listenQuestions(words),
      ...seed.questions.take(2),
    ],
    matchingPairs: _matchingPairs(words),
  );
}

RadioEpisode _buildMagazine({
  required CefrLevel level,
  required int number,
  required String category,
  required int cycle,
  required List<GermanWord> words,
}) {
  final String label = _categoryLabel(category);
  final String suffix = cycle == 1 ? '' : ' · Folge $cycle';
  final List<RadioLine> lines = <RadioLine>[
    _magazineOpening(level, label),
    for (int index = 0; index < words.length; index++)
      _wordLine(words[index], index),
    _closingLine(level),
  ];
  return RadioEpisode(
    id: 'rd-${level.name}-${number.toString().padLeft(2, '0')}',
    level: level,
    genre: _genreForCategory(category),
    title: 'Wortmagazin ${level.label}: $label$suffix',
    lines: lines,
    listenPrompts: _listenPrompts(words),
    questions: <ChoiceQuestion>[
      ..._listenQuestions(words),
      ..._meaningQuestions(words),
    ],
    matchingPairs: _matchingPairs(words),
  );
}

List<String> _listenPrompts(List<GermanWord> words) => <String>[
  for (int index = 0; index < 3; index++)
    _punctuate(words[index].exampleGerman),
];

List<ChoiceQuestion> _listenQuestions(List<GermanWord> words) {
  return List<ChoiceQuestion>.generate(3, (int index) {
    final String correct = _punctuate(words[index].exampleGerman);
    final List<String> raw = <String>[
      correct,
      _punctuate(words[index + 3].exampleGerman),
      _punctuate(words[index + 6].exampleGerman),
    ];
    final int shift = index % raw.length;
    final List<String> options = <String>[
      ...raw.skip(shift),
      ...raw.take(shift),
    ];
    return ChoiceQuestion(
      prompt: 'Hörfrage ${index + 1}: Welche Aussage hören Sie?',
      options: options,
      correctIndex: options.indexOf(correct),
      explanation: 'Zu hören war: $correct',
    );
  });
}

List<ChoiceQuestion> _meaningQuestions(List<GermanWord> words) {
  return List<ChoiceQuestion>.generate(2, (int questionIndex) {
    final int targetIndex = questionIndex + 3;
    final GermanWord target = words[targetIndex];
    final String correct = target.displayGerman;
    final List<String> raw = <String>[
      correct,
      words[targetIndex + 3].displayGerman,
      words[targetIndex + 6].displayGerman,
    ];
    final int shift = (questionIndex + 1) % raw.length;
    final List<String> options = <String>[
      ...raw.skip(shift),
      ...raw.take(shift),
    ];
    return ChoiceQuestion(
      prompt: 'Welcher Ausdruck aus der Sendung bedeutet „${target.english}“?',
      options: options,
      correctIndex: options.indexOf(correct),
      explanation:
          '„${target.displayGerman}“ bedeutet „${target.english}“. '
          '${_punctuate(target.exampleGerman)}',
    );
  });
}

List<RadioMatchPair> _matchingPairs(List<GermanWord> words) {
  final List<RadioMatchPair> pairs = <RadioMatchPair>[];
  final Set<String> german = <String>{};
  final Set<String> english = <String>{};
  for (final GermanWord word in words) {
    if (!german.add(word.displayGerman.toLowerCase()) ||
        !english.add(word.english.toLowerCase())) {
      continue;
    }
    pairs.add(
      RadioMatchPair(german: word.displayGerman, english: word.english),
    );
    if (pairs.length == 5) break;
  }
  if (pairs.length != 5) {
    throw StateError(
      'A radio matching block could not find five unique pairs.',
    );
  }
  return pairs;
}

RadioLine _bridgeLine(CefrLevel level, String category) {
  switch (level) {
    case CefrLevel.a1:
      return RadioLine(
        german:
            'Nach der Sendung kommt unser Wortfenster zum Thema $category. Hören Sie jedes Wort und danach ein Beispiel.',
        english:
            'After the broadcast comes our word window about $category. Listen to each word and then an example.',
      );
    case CefrLevel.a2:
      return RadioLine(
        german:
            'Jetzt folgt das Wortfenster zum Thema $category. Die Beispiele zeigen, wie die neuen Ausdrücke im Alltag klingen.',
        english:
            'Now comes the word window about $category. The examples show how the new expressions sound in everyday life.',
      );
    case CefrLevel.b1:
      return RadioLine(
        german:
            'Im anschließenden Wortfenster vertiefen wir das Thema $category mit Ausdrücken, die jeweils in einem vollständigen Kontext erscheinen.',
        english:
            'In the following word window we deepen the topic of $category with expressions that each appear in a complete context.',
      );
    case CefrLevel.b2:
      return RadioLine(
        german:
            'Das Wortfenster greift nun $category auf und verbindet zentrale Ausdrücke mit authentisch wirkenden Beispielsätzen aus unterschiedlichen Situationen.',
        english:
            'The word window now takes up $category and connects key expressions with natural examples from different situations.',
      );
    case CefrLevel.c1:
      return RadioLine(
        german:
            'Zum Abschluss erweitert das Wortfenster den Schwerpunkt $category um präzise Ausdrücke, deren Bedeutung sich aus dem jeweiligen Satzkontext erschließt.',
        english:
            'To finish, the word window expands the focus on $category with precise expressions whose meaning emerges from each sentence context.',
      );
    case CefrLevel.c2:
      return RadioLine(
        german:
            'Das abschließende Wortfenster beleuchtet $category anhand differenzierter Ausdrücke, wobei Gebrauch, Register und Kontext gemeinsam hörbar werden.',
        english:
            'The closing word window examines $category through nuanced expressions, making usage, register and context audible together.',
      );
  }
}

RadioLine _magazineOpening(CefrLevel level, String category) {
  switch (level) {
    case CefrLevel.a1:
      return RadioLine(
        german:
            'Willkommen beim Wortmagazin. Heute geht es um $category. Sie hören wichtige Wörter und kurze Beispiele. Sprechen Sie nach der Pause gern mit.',
        english:
            'Welcome to the vocabulary magazine. Today is about $category. You will hear important words and short examples. Feel free to repeat after the pause.',
      );
    case CefrLevel.a2:
      return RadioLine(
        german:
            'Willkommen beim Wortmagazin über $category. Achten Sie zuerst auf das neue Wort und dann auf seinen Platz im Beispielsatz.',
        english:
            'Welcome to the vocabulary magazine about $category. First notice the new word and then its place in the example sentence.',
      );
    case CefrLevel.b1:
      return RadioLine(
        german:
            'Diese Ausgabe des Wortmagazins führt durch das Thema $category. Jeder Ausdruck wird in einem vollständigen Satz vorgestellt, damit Form und Bedeutung zusammenbleiben.',
        english:
            'This edition of the vocabulary magazine explores $category. Every expression is presented in a complete sentence so form and meaning stay connected.',
      );
    case CefrLevel.b2:
      return RadioLine(
        german:
            'Im heutigen Wortmagazin steht $category im Mittelpunkt. Statt isolierter Definitionen hören Sie jeden Ausdruck in einem konkreten Zusammenhang und können auf typische Verbindungen achten.',
        english:
            'Today’s vocabulary magazine focuses on $category. Instead of isolated definitions, you hear every expression in context and can notice typical combinations.',
      );
    case CefrLevel.c1:
      return RadioLine(
        german:
            'Die heutige Ausgabe widmet sich dem Wortfeld $category. Entscheidend ist nicht nur die lexikalische Bedeutung, sondern auch, welche Perspektive und welches Register der jeweilige Ausdruck eröffnet.',
        english:
            'Today’s edition is devoted to the semantic field of $category. What matters is not only lexical meaning but also the perspective and register each expression opens.',
      );
    case CefrLevel.c2:
      return RadioLine(
        german:
            'Diese Ausgabe untersucht das Wortfeld $category in seiner begrifflichen Feinzeichnung. Die Beispiele sollen hörbar machen, wie minimale lexikalische Entscheidungen Ton, Präzision und Argumentationsrichtung verändern.',
        english:
            'This edition examines the semantic field of $category in fine conceptual detail. The examples reveal how small lexical choices change tone, precision and direction of argument.',
      );
  }
}

RadioLine _wordLine(GermanWord word, int index) {
  const List<String> germanLeads = <String>[
    'Unser nächster Ausdruck lautet',
    'Achten Sie nun auf',
    'Zum Wortfeld gehört auch',
    'Im nächsten Beispiel hören Sie',
    'Ein weiterer wichtiger Ausdruck ist',
    'Nun folgt',
  ];
  const List<String> englishLeads = <String>[
    'Our next expression is',
    'Now pay attention to',
    'The semantic field also includes',
    'In the next example you hear',
    'Another important expression is',
    'Next comes',
  ];
  final int template = index % germanLeads.length;
  final String formGerman;
  final String formEnglish;
  if (word.article.isNotEmpty) {
    if (word.plural.trim().isEmpty || word.plural.trim() == '—') {
      formGerman =
          'Der Artikel gehört fest dazu; einen üblichen Plural gibt es hier nicht.';
      formEnglish =
          'Its article belongs with the noun; there is no usual plural here.';
    } else {
      formGerman = 'Der Plural lautet „${word.plural}“.';
      formEnglish = 'Its plural is “${word.plural}”.';
    }
  } else {
    final String category = _categoryLabel(word.category);
    formGerman = 'Der Ausdruck gehört zum Wortfeld $category.';
    formEnglish = 'The expression belongs to the semantic field of $category.';
  }
  return RadioLine(
    german:
        '${germanLeads[template]} „${word.displayGerman}“. $formGerman ${_punctuate(word.exampleGerman)}',
    english:
        '${englishLeads[template]} “${word.displayGerman}”, meaning “${word.english}”. $formEnglish ${_punctuate(word.exampleEnglish)}',
    voice: index.isOdd ? RadioVoice.guest : RadioVoice.host,
  );
}

RadioLine _closingLine(CefrLevel level) {
  if (level.order <= CefrLevel.a2.order) {
    return const RadioLine(
      german:
          'Das war unser Wortfenster. Hören Sie die Sendung noch einmal und achten Sie jetzt auf die neuen Wörter. Danach beginnen die Fragen.',
      english:
          'That was our word window. Listen to the broadcast once more and now notice the new words. The questions begin afterwards.',
    );
  }
  return const RadioLine(
    german:
        'Damit endet das Wortfenster. Beim zweiten Hören können Sie beobachten, welche Ausdrücke Sie bereits ohne Übersetzung erkennen. Anschließend folgen die Hör- und Verständnisfragen.',
    english:
        'That concludes the word window. On the second listen, notice which expressions you already recognise without translation. The listening and comprehension questions follow.',
  );
}

List<String> _preferredCategories(RadioGenre genre) {
  switch (genre) {
    case RadioGenre.news:
      return <String>['Society', 'Economy', 'Politics', 'Environment'];
    case RadioGenre.weather:
      return <String>['Weather', 'Nature', 'Time'];
    case RadioGenre.announcement:
      return <String>['Travel', 'Transport', 'Directions', 'Services'];
    case RadioGenre.voicemail:
      return <String>['Communication', 'People', 'Daily life', 'Work'];
    case RadioGenre.recipe:
      return <String>['Food', 'Kitchen', 'Home'];
    case RadioGenre.audioGuide:
      return <String>['Culture', 'Places', 'History', 'Society'];
    case RadioGenre.lecture:
      return <String>['Education', 'Science', 'Language', 'Work & Study'];
    case RadioGenre.diary:
      return <String>['Feelings', 'Daily life', 'People', 'Time'];
  }
}

List<String> _rankedCategories(List<GermanWord> words) {
  final Map<String, int> counts = <String, int>{};
  for (final GermanWord word in words) {
    counts.update(word.category, (int value) => value + 1, ifAbsent: () => 1);
  }
  final List<String> categories = counts.keys.toList();
  categories.sort((String a, String b) {
    final int byCount = counts[b]!.compareTo(counts[a]!);
    return byCount != 0 ? byCount : a.compareTo(b);
  });
  return categories;
}

RadioGenre _genreForCategory(String category) {
  final String lower = category.toLowerCase();
  if (lower.contains('food') || lower.contains('kitchen')) {
    return RadioGenre.recipe;
  }
  if (lower.contains('culture') || lower.contains('place')) {
    return RadioGenre.audioGuide;
  }
  if (lower.contains('society') ||
      lower.contains('econom') ||
      lower.contains('politic') ||
      lower.contains('environment')) {
    return RadioGenre.news;
  }
  if (lower.contains('feeling') || lower.contains('daily')) {
    return RadioGenre.diary;
  }
  return RadioGenre.lecture;
}

String _categoryLabel(String category) {
  const Map<String, String> labels = <String, String>{
    'Abstract': 'abstrakte Begriffe',
    'Academic': 'akademische Sprache',
    'Actions': 'Handlungen',
    'Administration': 'Verwaltung',
    'Appliances': 'Haushaltsgeräte',
    'Appointments': 'Termine',
    'Bathroom': 'Badezimmer',
    'Character': 'Charakter',
    'Cleaning': 'Reinigung',
    'Communication': 'Kommunikation',
    'Culture': 'Kultur',
    'Daily life': 'Alltag',
    'Description': 'Beschreibungen',
    'Directions': 'Wegbeschreibung',
    'Economy': 'Wirtschaft',
    'Education': 'Bildung',
    'Environment': 'Umwelt',
    'Feelings': 'Gefühle',
    'Food': 'Essen',
    'Formal': 'formelle Sprache',
    'Frequency': 'Häufigkeit',
    'Furniture': 'Möbel',
    'General': 'Allgemeines',
    'Health': 'Gesundheit',
    'Home': 'Zuhause',
    'Household': 'Haushalt',
    'Housing': 'Wohnen',
    'Identity': 'Identität',
    'Kitchen': 'Küche',
    'Language': 'Sprache',
    'Law': 'Recht',
    'Lifestyle': 'Lebensstil',
    'Linking': 'Verknüpfungen',
    'Money': 'Geld',
    'Movement': 'Bewegung',
    'Nature': 'Natur',
    'People': 'Menschen',
    'Philosophy': 'Philosophie',
    'Places': 'Orte',
    'Politics': 'Politik',
    'Quantity': 'Mengen',
    'Questions': 'Fragen',
    'Research': 'Forschung',
    'Science': 'Wissenschaft',
    'Sequence': 'Reihenfolge',
    'Services': 'Dienstleistungen',
    'Shopping': 'Einkaufen',
    'Society': 'Gesellschaft',
    'Stance': 'Standpunkte',
    'Study': 'Lernen',
    'Technology': 'Technik',
    'Time': 'Zeit',
    'Transport': 'Verkehr',
    'Travel': 'Reisen',
    'Trend': 'Entwicklungen',
    'Weather': 'Wetter',
    'Work': 'Arbeit',
    'Work & Study': 'Arbeit und Studium',
  };
  return labels[category] ?? category;
}

int _wordCount(List<RadioLine> lines) => lines
    .expand((RadioLine line) => line.german.trim().split(RegExp(r'\s+')))
    .where((String token) => token.isNotEmpty)
    .length;

String _punctuate(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty || '.!?'.contains(trimmed[trimmed.length - 1])) {
    return trimmed;
  }
  return '$trimmed.';
}
