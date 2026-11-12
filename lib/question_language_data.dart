/// Authored language scaffolds; official question/answer data stays intact.
class QuestionLanguageHint {
  const QuestionLanguageHint({
    required this.words,
    required this.phrase,
    required this.german,
    required this.english,
    required this.exampleGerman,
    required this.exampleEnglish,
  });
  final List<String> words;
  final String phrase, german, english, exampleGerman, exampleEnglish;
}

const questionLanguageHints = <QuestionLanguageHint>[
  QuestionLanguageHint(
    words: ['müssen', 'muss', 'musst', 'müsst'],
    phrase: 'müssen + Infinitiv',
    german:
        'Müssen drückt eine Notwendigkeit oder Pflicht aus. Im Hauptsatz steht der Infinitiv meist am Ende. Nicht müssen bedeutet, dass keine Pflicht besteht.',
    english:
        'Müssen expresses necessity or obligation. In a main clause, the infinitive usually goes at the end. Nicht müssen means there is no obligation; it does not mean a prohibition.',
    exampleGerman: 'Ich muss heute zehn neue Wörter wiederholen.',
    exampleEnglish: 'I have to review ten new words today.',
  ),
  QuestionLanguageHint(
    words: ['dürfen', 'darf', 'darfst', 'dürft'],
    phrase: 'dürfen / nicht dürfen',
    german:
        'Dürfen beschreibt eine Erlaubnis. Nicht dürfen bedeutet, dass etwas nicht erlaubt ist.',
    english:
        'Dürfen expresses permission. Nicht dürfen means that something is not allowed.',
    exampleGerman: 'Hier darf ich in Ruhe lesen.',
    exampleEnglish: 'I am allowed to read quietly here.',
  ),
  QuestionLanguageHint(
    words: [
      'sollen',
      'soll',
      'sollst',
      'sollt',
      'sollte',
      'sollten',
      'solltest',
    ],
    phrase: 'sollen / sollten',
    german:
        'Sollen kann eine Anweisung oder Erwartung ausdrücken. Sollten wird oft für einen Rat verwendet. Achte auf den Kontext.',
    english:
        'Sollen can express an instruction or expectation. Sollten often gives advice. Pay attention to the context.',
    exampleGerman: 'Du solltest das neue Wort in einem Satz verwenden.',
    exampleEnglish: 'You should use the new word in a sentence.',
  ),
  QuestionLanguageHint(
    words: ['können', 'kann', 'kannst', 'könnt'],
    phrase: 'können + Infinitiv',
    german:
        'Können beschreibt eine Fähigkeit oder Möglichkeit. Es bedeutet nicht automatisch, dass etwas erlaubt ist.',
    english:
        'Können describes an ability or possibility. It does not automatically mean that something is permitted.',
    exampleGerman: 'Ich kann diesen Satz schon ohne Hilfe verstehen.',
    exampleEnglish: 'I can already understand this sentence without help.',
  ),
  QuestionLanguageHint(
    words: ['nicht'],
    phrase: 'nicht',
    german:
        'Nicht verneint eine Aussage oder einen Teil davon. Lies genau, worauf sich die Verneinung bezieht.',
    english:
        'Nicht negates a statement or part of it. Read carefully to see what is being negated.',
    exampleGerman: 'Ich lerne heute nicht allein.',
    exampleEnglish: 'I am not studying alone today.',
  ),
  QuestionLanguageHint(
    words: ['kein', 'keine', 'keinen', 'keinem', 'keiner', 'keines'],
    phrase: 'kein / keine',
    german:
        'Kein verneint ein Nomen. Die Endung verändert sich mit Genus, Numerus und Kasus.',
    english:
        'Kein negates a noun. Its ending changes with gender, number and case.',
    exampleGerman: 'Ich habe heute keine Frage.',
    exampleEnglish: 'I have no question today.',
  ),
  QuestionLanguageHint(
    words: ['welche', 'welcher', 'welches', 'welchen', 'welchem'],
    phrase: 'welche / welcher / welches',
    german:
        'Welche fragt nach einer Auswahl. Die Form passt zum Nomen und seinem Kasus.',
    english:
        'Welche asks you to select something. Its form agrees with the noun and its case.',
    exampleGerman: 'Welche Wörter möchtest du heute üben?',
    exampleEnglish: 'Which words would you like to practise today?',
  ),
  QuestionLanguageHint(
    words: ['wer', 'wen', 'wem'],
    phrase: 'wer / wen / wem',
    german:
        'Wer fragt nach dem Subjekt, wen nach einem Akkusativobjekt und wem nach einem Dativobjekt.',
    english:
        'Wer asks about the subject, wen about an accusative object, and wem about a dative object.',
    exampleGerman: 'Wer hilft wem? Die Lehrerin hilft dem Schüler.',
    exampleEnglish: 'Who helps whom? The teacher helps the pupil.',
  ),
  QuestionLanguageHint(
    words: ['warum', 'weshalb', 'weswegen'],
    phrase: 'warum / weil',
    german:
        'Warum fragt nach einem Grund. In einem Nebensatz mit weil steht das konjugierte Verb am Ende.',
    english:
        'Warum asks for a reason. In a clause introduced by weil, the conjugated verb goes at the end.',
    exampleGerman:
        'Ich lerne Deutsch, weil ich mit meinen Nachbarn sprechen möchte.',
    exampleEnglish:
        'I am learning German because I would like to speak with my neighbours.',
  ),
  QuestionLanguageHint(
    words: ['wodurch'],
    phrase: 'wodurch / durch',
    german:
        'Wodurch fragt nach einem Mittel oder einer Ursache. Eine passende Wendung ist durch mit Akkusativ.',
    english:
        'Wodurch asks about a means or cause. A useful response uses durch with the accusative.',
    exampleGerman:
        'Wodurch verbessert sich mein Deutsch? Durch regelmäßiges Üben.',
    exampleEnglish: 'What improves my German? Regular practice.',
  ),
  QuestionLanguageHint(
    words: ['worauf'],
    phrase: 'worauf / auf',
    german:
        'Worauf verbindet wo mit auf. Achte auf die Präposition des Verbs, zum Beispiel achten auf.',
    english:
        'Worauf combines wo with auf. Notice the preposition required by the verb, for example achten auf.',
    exampleGerman: 'Worauf achtest du beim Lesen? Auf die Verben.',
    exampleEnglish: 'What do you pay attention to when reading? The verbs.',
  ),
  QuestionLanguageHint(
    words: ['woran'],
    phrase: 'woran / an',
    german:
        'Woran verbindet wo mit an. Bei erkennen an fragt es nach einem Erkennungsmerkmal.',
    english:
        'Woran combines wo with an. With erkennen an, it asks how you can recognise something.',
    exampleGerman: 'Woran erkennst du eine Frage? Am Fragezeichen.',
    exampleEnglish: 'How do you recognise a question? By its question mark.',
  ),
  QuestionLanguageHint(
    words: ['wann'],
    phrase: 'wann',
    german:
        'Wann fragt nach einem Zeitpunkt. Antworte zum Beispiel mit um, am oder im und einer passenden Zeitangabe.',
    english:
        'Wann asks about a point in time. Useful answers use um, am or im with an appropriate time expression.',
    exampleGerman: 'Wann übst du Deutsch? Am Abend.',
    exampleEnglish: 'When do you practise German? In the evening.',
  ),
  QuestionLanguageHint(
    words: ['wo'],
    phrase: 'wo',
    german:
        'Wo fragt nach einem Ort, nicht nach einer Richtung. Wohin fragt dagegen nach dem Ziel einer Bewegung.',
    english:
        'Wo asks about a location, rather than a direction. Wohin asks about the destination of a movement.',
    exampleGerman: 'Wo lernst du? In der Bibliothek.',
    exampleEnglish: 'Where do you study? In the library.',
  ),
  QuestionLanguageHint(
    words: ['bedeutet', 'bedeuten'],
    phrase: 'Was bedeutet ...?',
    german:
        'Mit „Was bedeutet ...?“ fragst du nach einer Bedeutung. Erkläre den Ausdruck möglichst mit anderen, einfachen Wörtern.',
    english:
        '„Was bedeutet ...?“ asks about meaning. Try explaining the expression with other, simpler words.',
    exampleGerman: 'Was bedeutet „täglich“? Es bedeutet „jeden Tag“.',
    exampleEnglish: 'What does täglich mean? It means every day.',
  ),
];

QuestionLanguageHint? questionLanguageHintFor(String question) {
  final words = RegExp(
    r'[a-zäöüß]+',
  ).allMatches(question.toLowerCase()).map((match) => match[0]!).toSet();
  for (final hint in questionLanguageHints) {
    if (hint.words.any(words.contains)) return hint;
  }
  return null;
}
