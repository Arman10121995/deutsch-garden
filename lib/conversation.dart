import 'conversation_extra.dart';
import 'models.dart';
import 'pronunciation.dart';
import 'stories.dart';
import 'stories_expansion.dart';

/// One tutor turn plus everything needed to evaluate the learner's reply.
class DialogueStep {
  const DialogueStep({
    required this.tutorGerman,
    required this.tutorEnglish,
    required this.task,
    required this.keywords,
    required this.modelAnswer,
    required this.modelAnswerEnglish,
    this.quickReplies = const <String>[],
    this.coachTip = '',
    this.minWords = 3,
    this.requiredHits = 1,
  });

  /// What the conversation partner says, in German.
  final String tutorGerman;

  /// Support translation, hidden unless the learner asks for it.
  final String tutorEnglish;

  /// What the learner has to achieve in this turn.
  final String task;

  /// Any-of markers that show the learner actually addressed the turn.
  /// Matching is stem-tolerant, so 'wohn' catches wohne/wohnst/gewohnt.
  final List<String> keywords;

  /// How many distinct keywords a full-credit answer needs.
  final int requiredHits;

  /// Minimum length before an answer counts as a real contribution.
  final int minWords;

  final String modelAnswer;
  final String modelAnswerEnglish;

  /// Tappable starter phrases for learners who freeze — Busuu and Babbel both
  /// use this to keep a conversation moving instead of ending it in silence.
  final List<String> quickReplies;

  /// The length actually demanded of the learner.
  ///
  /// A turn must never require more words than its own model answer contains:
  /// otherwise the app would reject the very sentence it holds up as correct.
  /// Authored [minWords] therefore acts as a ceiling, not an absolute.
  /// Counted with the same tokenizer the evaluator uses, so punctuation such
  /// as a dash never inflates the requirement above what the model answer
  /// actually delivers.
  int get effectiveMinWords {
    final int modelWords = PronunciationScorer.wordCount(modelAnswer);
    if (modelWords == 0) return minWords;
    return minWords < modelWords ? minWords : modelWords;
  }

  /// Short grammar or pragmatics note surfaced after the turn is answered.
  final String coachTip;
}

/// A guided role-play with a fixed goal, in the spirit of Babbel's real-life
/// dialogues and Busuu's conversation practice.
class ConversationScenario {
  const ConversationScenario({
    required this.id,
    required this.level,
    required this.emoji,
    required this.title,
    required this.setting,
    required this.tutorRole,
    required this.learnerRole,
    required this.goal,
    required this.usefulPhrases,
    required this.steps,
  });

  final String id;
  final CefrLevel level;
  final String emoji;
  final String title;
  final String setting;
  final String tutorRole;
  final String learnerRole;
  final String goal;
  final List<String> usefulPhrases;
  final List<DialogueStep> steps;
}

/// Open-ended speaking prompt with no scripted branch: the learner talks, the
/// app measures coverage, length and connector use, then shows a model answer.
class FreeTalkPrompt {
  const FreeTalkPrompt({
    required this.id,
    required this.level,
    required this.question,
    required this.questionEnglish,
    required this.expectedPoints,
    required this.usefulConnectors,
    required this.targetSeconds,
    required this.targetWords,
    required this.modelAnswer,
  });

  final String id;
  final CefrLevel level;
  final String question;
  final String questionEnglish;

  /// Content points a complete answer should touch.
  final List<String> expectedPoints;

  /// Level-appropriate discourse markers the learner should be reaching for.
  final List<String> usefulConnectors;

  final int targetSeconds;
  final int targetWords;
  final String modelAnswer;
}

const List<ConversationScenario> _foundationScenarios = <ConversationScenario>[
  // ---------------------------------------------------------------- A1 ----
  ConversationScenario(
    id: 'cv-a1-01',
    level: CefrLevel.a1,
    emoji: '☕',
    title: 'Im Café',
    setting: 'A small café in Rostock, late morning.',
    tutorRole: 'Kellner (waiter)',
    learnerRole: 'Gast (guest)',
    goal: 'Order a drink and something to eat, then ask for the bill.',
    usefulPhrases: <String>[
      'Ich hätte gern …',
      'Was kostet …?',
      'Die Rechnung, bitte.',
      'Zahlen bitte, mit Karte.',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Guten Morgen! Was möchten Sie trinken?',
        tutorEnglish: 'Good morning! What would you like to drink?',
        task: 'Order a drink politely.',
        keywords: <String>[
          'kaffee',
          'tee',
          'wasser',
          'saft',
          'hätte gern',
          'möchte',
          'bitte',
        ],
        modelAnswer: 'Guten Morgen! Ich hätte gern einen Kaffee, bitte.',
        modelAnswerEnglish: 'Good morning! I would like a coffee, please.',
        quickReplies: <String>[
          'Ich hätte gern einen Kaffee, bitte.',
          'Einen Tee, bitte.',
        ],
        coachTip:
            '„Ich hätte gern“ is the standard polite order form — softer than „Ich will“.',
      ),
      DialogueStep(
        tutorGerman: 'Gern. Möchten Sie auch etwas essen?',
        tutorEnglish: 'Certainly. Would you like something to eat as well?',
        task: 'Say yes and order food, or say no politely.',
        keywords: <String>[
          'brötchen',
          'kuchen',
          'brot',
          'käse',
          'nein danke',
          'ja',
          'hätte gern',
          'möchte',
        ],
        modelAnswer: 'Ja, ich möchte ein Käsebrötchen, bitte.',
        modelAnswerEnglish: 'Yes, I would like a cheese roll, please.',
        quickReplies: <String>[
          'Ja, ein Stück Kuchen, bitte.',
          'Nein danke, nur den Kaffee.',
        ],
        coachTip:
            'Accusative after „möchten“: ein Brötchen (das), einen Kuchen (der).',
      ),
      DialogueStep(
        tutorGerman: 'Sehr gern. Möchten Sie hier essen oder zum Mitnehmen?',
        tutorEnglish: 'Of course. Eat in or take away?',
        task: 'Choose one of the two options.',
        keywords: <String>[
          'hier',
          'mitnehmen',
          'zum mitnehmen',
          'bleibe',
          'bitte',
        ],
        modelAnswer: 'Ich esse hier, danke.',
        modelAnswerEnglish: 'I will eat here, thank you.',
        quickReplies: <String>['Hier, bitte.', 'Zum Mitnehmen, bitte.'],
        coachTip:
            'Short answers are normal here — a full sentence is optional.',
      ),
      DialogueStep(
        tutorGerman:
            'Alles klar. Der Kaffee kostet drei Euro zwanzig. Noch etwas?',
        tutorEnglish:
            'All right. The coffee is three euros twenty. Anything else?',
        task: 'Say no and ask for the bill.',
        keywords: <String>['nein', 'rechnung', 'zahlen', 'bezahlen', 'danke'],
        requiredHits: 2,
        modelAnswer: 'Nein danke. Die Rechnung, bitte.',
        modelAnswerEnglish: 'No thank you. The bill, please.',
        quickReplies: <String>[
          'Nein danke, die Rechnung bitte.',
          'Zahlen, bitte.',
        ],
        coachTip:
            '„Zahlen, bitte“ and „Die Rechnung, bitte“ are both fully idiomatic.',
      ),
      DialogueStep(
        tutorGerman: 'Das macht vier Euro fünfzig. Bar oder mit Karte?',
        tutorEnglish: 'That comes to four euros fifty. Cash or card?',
        task: 'Say how you want to pay.',
        keywords: <String>['karte', 'bar', 'bargeld', 'ec'],
        modelAnswer: 'Mit Karte, bitte.',
        modelAnswerEnglish: 'By card, please.',
        quickReplies: <String>['Mit Karte, bitte.', 'Bar, bitte.'],
        coachTip: '„mit Karte“ takes the dative — mit + Dativ, always.',
      ),
      DialogueStep(
        tutorGerman: 'Danke schön und einen schönen Tag noch!',
        tutorEnglish: 'Thank you and have a nice day!',
        task: 'Say goodbye politely.',
        keywords: <String>[
          'danke',
          'tschüss',
          'wiedersehen',
          'ebenfalls',
          'gleichfalls',
        ],
        modelAnswer: 'Danke, gleichfalls. Auf Wiedersehen!',
        modelAnswerEnglish: 'Thanks, you too. Goodbye!',
        quickReplies: <String>['Danke, gleichfalls!', 'Tschüss!'],
        coachTip:
            '„Gleichfalls“ / „ebenfalls“ returns a good wish in one word.',
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-a1-02',
    level: CefrLevel.a1,
    emoji: '👋',
    title: 'Der erste Kurstag',
    setting: 'The first day of a German course. Someone sits down next to you.',
    tutorRole: 'Kursteilnehmerin (fellow student)',
    learnerRole: 'Neue Person im Kurs',
    goal: 'Introduce yourself and find out about the other person.',
    usefulPhrases: <String>[
      'Ich heiße …',
      'Ich komme aus …',
      'Ich wohne in …',
      'Und du?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Hallo! Ich bin Lena. Wie heißt du?',
        tutorEnglish: 'Hi! I am Lena. What is your name?',
        task: 'Greet her and give your name.',
        keywords: <String>['heiße', 'ich bin', 'hallo', 'mein name'],
        modelAnswer: 'Hallo Lena! Ich heiße Arman.',
        modelAnswerEnglish: 'Hi Lena! My name is Arman.',
        quickReplies: <String>['Hallo! Ich heiße …', 'Hi, ich bin …'],
        coachTip: '„Ich heiße …“ and „Ich bin …“ are equally common.',
      ),
      DialogueStep(
        tutorGerman: 'Freut mich! Woher kommst du?',
        tutorEnglish: 'Nice to meet you! Where are you from?',
        task: 'Say which country or city you come from.',
        keywords: <String>['komme aus', 'aus', 'indien', 'ich komme'],
        modelAnswer: 'Ich komme aus Indien.',
        modelAnswerEnglish: 'I come from India.',
        quickReplies: <String>['Ich komme aus Indien.', 'Aus Deutschland.'],
        coachTip:
            'Countries usually take „aus“ with no article: aus Indien, aus Spanien.',
      ),
      DialogueStep(
        tutorGerman: 'Interessant! Und wo wohnst du jetzt?',
        tutorEnglish: 'Interesting! And where do you live now?',
        task: 'Say where you live.',
        keywords: <String>['wohne', 'in', 'rostock', 'stadt'],
        modelAnswer: 'Ich wohne jetzt in Rostock.',
        modelAnswerEnglish: 'I live in Rostock now.',
        quickReplies: <String>[
          'Ich wohne in Rostock.',
          'Ich wohne hier in der Stadt.',
        ],
        coachTip: '„wohnen in“ + Dativ: in Rostock, in der Stadt, im Zentrum.',
      ),
      DialogueStep(
        tutorGerman: 'Und was machst du beruflich?',
        tutorEnglish: 'And what do you do for a living?',
        task: 'Say your job or that you are studying.',
        keywords: <String>[
          'arbeite',
          'student',
          'studiere',
          'ingenieur',
          'bin',
        ],
        modelAnswer: 'Ich bin Ingenieur und arbeite bei einer Firma.',
        modelAnswerEnglish: 'I am an engineer and work at a company.',
        quickReplies: <String>[
          'Ich bin Student.',
          'Ich arbeite als Ingenieur.',
        ],
        coachTip:
            'German drops the article with professions: „Ich bin Ingenieur“, not „ein Ingenieur“.',
      ),
      DialogueStep(
        tutorGerman: 'Warum lernst du Deutsch?',
        tutorEnglish: 'Why are you learning German?',
        task: 'Give one reason.',
        keywords: <String>[
          'weil',
          'für',
          'arbeit',
          'studium',
          'lerne',
          'möchte',
        ],
        minWords: 4,
        modelAnswer: 'Ich lerne Deutsch für meine Arbeit.',
        modelAnswerEnglish: 'I am learning German for my work.',
        quickReplies: <String>[
          'Ich lerne Deutsch für meine Arbeit.',
          'Weil ich hier studiere.',
        ],
        coachTip:
            'At A1 „für + Akkusativ“ is easier than a „weil“ clause — both are fine.',
      ),
      DialogueStep(
        tutorGerman: 'Toll! Wollen wir zusammen lernen?',
        tutorEnglish: 'Great! Shall we study together?',
        task: 'Accept or decline, and say something friendly.',
        keywords: <String>[
          'ja',
          'gern',
          'gerne',
          'super',
          'nein',
          'vielleicht',
        ],
        modelAnswer: 'Ja, sehr gern! Das ist eine gute Idee.',
        modelAnswerEnglish: 'Yes, gladly! That is a good idea.',
        quickReplies: <String>['Ja, gern!', 'Ja, super Idee!'],
        coachTip:
            '„Gern“ is the single most useful word for accepting an offer.',
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-a1-03',
    level: CefrLevel.a1,
    emoji: '🛒',
    title: 'Im Supermarkt',
    setting: 'You are looking for a few things in a supermarket.',
    tutorRole: 'Mitarbeiterin (shop assistant)',
    learnerRole: 'Kunde (customer)',
    goal: 'Find products, ask about prices, and get to the checkout.',
    usefulPhrases: <String>[
      'Entschuldigung, wo finde ich …?',
      'Wie viel kostet …?',
      'Haben Sie …?',
      'Wo ist die Kasse?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Guten Tag! Kann ich Ihnen helfen?',
        tutorEnglish: 'Hello! Can I help you?',
        task: 'Ask where you can find milk.',
        keywords: <String>['wo', 'milch', 'finde', 'suche'],
        requiredHits: 2,
        modelAnswer: 'Ja, bitte. Wo finde ich die Milch?',
        modelAnswerEnglish: 'Yes, please. Where can I find the milk?',
        quickReplies: <String>['Wo finde ich die Milch?', 'Ich suche Milch.'],
        coachTip: 'W-questions put the verb second: Wo *finde* ich …?',
      ),
      DialogueStep(
        tutorGerman:
            'Die Milch ist hinten rechts, neben dem Käse. Brauchen Sie noch etwas?',
        tutorEnglish:
            'The milk is at the back on the right, next to the cheese. Do you need anything else?',
        task: 'Ask whether they have fresh bread.',
        keywords: <String>['haben sie', 'brot', 'frisch', 'gibt es'],
        requiredHits: 2,
        modelAnswer: 'Haben Sie frisches Brot?',
        modelAnswerEnglish: 'Do you have fresh bread?',
        quickReplies: <String>[
          'Haben Sie frisches Brot?',
          'Gibt es hier Brot?',
        ],
        coachTip: 'Yes/no questions start with the verb: *Haben* Sie …?',
      ),
      DialogueStep(
        tutorGerman:
            'Ja, das Brot kommt jeden Morgen frisch. Es liegt vorne links.',
        tutorEnglish:
            'Yes, the bread arrives fresh every morning. It is at the front on the left.',
        task: 'Ask how much the bread costs.',
        keywords: <String>['kostet', 'wie viel', 'preis', 'was kostet'],
        modelAnswer: 'Wie viel kostet das Brot?',
        modelAnswerEnglish: 'How much does the bread cost?',
        quickReplies: <String>['Wie viel kostet das Brot?', 'Was kostet das?'],
        coachTip:
            '„Wie viel kostet …?“ and „Was kostet …?“ are interchangeable.',
      ),
      DialogueStep(
        tutorGerman: 'Zwei Euro achtzig. Möchten Sie eine Tüte?',
        tutorEnglish: 'Two euros eighty. Would you like a bag?',
        task: 'Answer yes or no.',
        keywords: <String>['ja', 'nein', 'danke', 'tüte', 'brauche'],
        modelAnswer: 'Nein danke, ich habe eine Tasche.',
        modelAnswerEnglish: 'No thanks, I have a bag with me.',
        quickReplies: <String>['Ja, bitte.', 'Nein danke.'],
        coachTip:
            '„Nein danke“ is the polite refusal; „Nein“ alone can sound abrupt.',
      ),
      DialogueStep(
        tutorGerman: 'Alles klar. Haben Sie sonst noch Fragen?',
        tutorEnglish: 'All right. Do you have any other questions?',
        task: 'Ask where the checkout is.',
        keywords: <String>['kasse', 'wo ist', 'wo'],
        requiredHits: 2,
        modelAnswer: 'Ja, wo ist die Kasse?',
        modelAnswerEnglish: 'Yes, where is the checkout?',
        quickReplies: <String>['Wo ist die Kasse?', 'Wo kann ich bezahlen?'],
        coachTip: 'die Kasse — feminine, so „die“, not „der“.',
      ),
      DialogueStep(
        tutorGerman: 'Die Kasse ist ganz vorne. Schönen Tag noch!',
        tutorEnglish: 'The checkout is right at the front. Have a nice day!',
        task: 'Thank her and say goodbye.',
        keywords: <String>['danke', 'vielen dank', 'tschüss', 'wiedersehen'],
        modelAnswer: 'Vielen Dank! Auf Wiedersehen.',
        modelAnswerEnglish: 'Thank you very much! Goodbye.',
        quickReplies: <String>[
          'Vielen Dank, tschüss!',
          'Danke, auf Wiedersehen!',
        ],
        coachTip:
            'In a shop „Auf Wiedersehen“ is the safe register; „Tschüss“ is friendlier.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- A2 ----
  ConversationScenario(
    id: 'cv-a2-01',
    level: CefrLevel.a2,
    emoji: '🩺',
    title: 'Beim Arzt',
    setting: 'A GP practice. You have had a sore throat for three days.',
    tutorRole: 'Ärztin (doctor)',
    learnerRole: 'Patient',
    goal: 'Describe symptoms, answer questions and understand the treatment.',
    usefulPhrases: <String>[
      'Ich habe seit drei Tagen …',
      'Es tut weh, wenn ich …',
      'Muss ich etwas nehmen?',
      'Wie oft soll ich …?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Guten Tag, setzen Sie sich bitte. Was fehlt Ihnen denn?',
        tutorEnglish: 'Hello, please have a seat. What is the matter?',
        task: 'Describe your main symptom and how long you have had it.',
        keywords: <String>[
          'halsschmerzen',
          'seit',
          'weh',
          'schmerzen',
          'krank',
          'tagen',
        ],
        requiredHits: 2,
        minWords: 5,
        modelAnswer:
            'Guten Tag. Ich habe seit drei Tagen starke Halsschmerzen.',
        modelAnswerEnglish:
            'Hello. I have had a bad sore throat for three days.',
        quickReplies: <String>[
          'Ich habe seit drei Tagen Halsschmerzen.',
          'Mein Hals tut sehr weh.',
        ],
        coachTip:
            '„seit“ always takes the dative and a *present tense* verb: seit drei Tagen habe ich …',
      ),
      DialogueStep(
        tutorGerman: 'Haben Sie auch Fieber gehabt?',
        tutorEnglish: 'Have you had a fever as well?',
        task: 'Answer, and give a detail (temperature, when it started).',
        keywords: <String>[
          'fieber',
          'ja',
          'nein',
          'grad',
          'gestern',
          'gemessen',
        ],
        requiredHits: 2,
        minWords: 4,
        modelAnswer: 'Ja, gestern hatte ich achtunddreißig Grad Fieber.',
        modelAnswerEnglish:
            'Yes, yesterday I had a temperature of thirty-eight degrees.',
        quickReplies: <String>[
          'Ja, gestern hatte ich Fieber.',
          'Nein, ich hatte kein Fieber.',
        ],
        coachTip:
            'With „haben“ and „sein“, the Präteritum (hatte, war) sounds more natural than the Perfekt.',
      ),
      DialogueStep(
        tutorGerman: 'Tut es weh, wenn Sie schlucken?',
        tutorEnglish: 'Does it hurt when you swallow?',
        task: 'Answer and use a „wenn“ clause if you can.',
        keywords: <String>['ja', 'nein', 'schlucke', 'wenn', 'weh', 'schmerzt'],
        requiredHits: 2,
        minWords: 4,
        modelAnswer: 'Ja, es tut sehr weh, wenn ich schlucke.',
        modelAnswerEnglish: 'Yes, it hurts a lot when I swallow.',
        quickReplies: <String>[
          'Ja, wenn ich schlucke, tut es weh.',
          'Nein, nur beim Sprechen.',
        ],
        coachTip:
            'In a „wenn“ clause the verb goes to the very end: … wenn ich *schlucke*.',
      ),
      DialogueStep(
        tutorGerman: 'Nehmen Sie im Moment Medikamente?',
        tutorEnglish: 'Are you taking any medication at the moment?',
        task: 'Say what you are or are not taking.',
        keywords: <String>[
          'nehme',
          'tabletten',
          'nein',
          'nichts',
          'medikament',
          'ibuprofen',
        ],
        minWords: 3,
        modelAnswer: 'Nein, ich nehme im Moment keine Medikamente.',
        modelAnswerEnglish: 'No, I am not taking any medication at the moment.',
        quickReplies: <String>[
          'Nein, keine Medikamente.',
          'Ja, ich nehme Tabletten gegen Schmerzen.',
        ],
        coachTip:
            '„kein-“ negates a noun; „nicht“ negates a verb or the whole sentence.',
      ),
      DialogueStep(
        tutorGerman:
            'Gut. Ich verschreibe Ihnen ein Spray. Nehmen Sie es dreimal täglich.',
        tutorEnglish:
            'Good. I will prescribe a spray. Use it three times a day.',
        task:
            'Check that you understood — repeat the instruction as a question.',
        keywords: <String>[
          'dreimal',
          'täglich',
          'also',
          'richtig',
          'tag',
          'wie lange',
        ],
        requiredHits: 2,
        modelAnswer:
            'Also dreimal am Tag, richtig? Wie lange soll ich das nehmen?',
        modelAnswerEnglish:
            'So three times a day, correct? How long should I take it?',
        quickReplies: <String>[
          'Also dreimal täglich, richtig?',
          'Wie lange soll ich das nehmen?',
        ],
        coachTip:
            'Checking back with „Also …, richtig?“ is a core A2 repair strategy.',
      ),
      DialogueStep(
        tutorGerman:
            'Eine Woche. Wenn es dann nicht besser ist, kommen Sie bitte wieder.',
        tutorEnglish: 'One week. If it is not better then, please come back.',
        task: 'Thank her and close the conversation.',
        keywords: <String>[
          'danke',
          'vielen dank',
          'wiedersehen',
          'tschüss',
          'alles klar',
        ],
        modelAnswer: 'Vielen Dank, Frau Doktor. Auf Wiedersehen.',
        modelAnswerEnglish: 'Thank you very much, doctor. Goodbye.',
        quickReplies: <String>[
          'Vielen Dank, auf Wiedersehen.',
          'Alles klar, danke schön.',
        ],
        coachTip:
            'Address a doctor as „Frau Doktor“ / „Herr Doktor“ in formal German.',
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-a2-02',
    level: CefrLevel.a2,
    emoji: '🏠',
    title: 'Die Wohnungsbesichtigung',
    setting: 'You are viewing a two-room flat you found online.',
    tutorRole: 'Vermieter (landlord)',
    learnerRole: 'Interessent (prospective tenant)',
    goal: 'Ask about rent, costs and rules, and express interest.',
    usefulPhrases: <String>[
      'Wie hoch ist die Miete?',
      'Sind die Nebenkosten inklusive?',
      'Ab wann ist die Wohnung frei?',
      'Darf man hier …?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman:
            'Herzlich willkommen. Das ist das Wohnzimmer. Wie gefällt Ihnen die Wohnung?',
        tutorEnglish:
            'Welcome. This is the living room. How do you like the flat?',
        task: 'Give your first impression with a reason.',
        keywords: <String>['gefällt', 'schön', 'hell', 'groß', 'gut', 'weil'],
        requiredHits: 2,
        minWords: 5,
        modelAnswer:
            'Sie gefällt mir sehr gut, weil das Wohnzimmer so hell ist.',
        modelAnswerEnglish:
            'I like it very much because the living room is so bright.',
        quickReplies: <String>[
          'Sie gefällt mir gut.',
          'Das Zimmer ist sehr hell und groß.',
        ],
        coachTip:
            '„gefallen“ takes a dative person: Die Wohnung gefällt *mir*.',
      ),
      DialogueStep(
        tutorGerman: 'Das freut mich. Haben Sie Fragen zur Wohnung?',
        tutorEnglish: 'I am glad. Do you have any questions about the flat?',
        task: 'Ask about the rent.',
        keywords: <String>['miete', 'wie hoch', 'kostet', 'wie viel'],
        requiredHits: 2,
        modelAnswer: 'Ja, wie hoch ist die Miete?',
        modelAnswerEnglish: 'Yes, how high is the rent?',
        quickReplies: <String>[
          'Wie hoch ist die Miete?',
          'Was kostet die Wohnung im Monat?',
        ],
        coachTip:
            'Germans say „Wie hoch ist die Miete?“, not „Wie viel ist die Miete?“.',
      ),
      DialogueStep(
        tutorGerman: 'Die Kaltmiete beträgt 620 Euro im Monat.',
        tutorEnglish: 'The base rent is 620 euros a month.',
        task: 'Ask whether the utilities are included.',
        keywords: <String>[
          'nebenkosten',
          'warm',
          'inklusive',
          'dazu',
          'extra',
          'strom',
        ],
        requiredHits: 2,
        modelAnswer:
            'Sind die Nebenkosten inklusive oder kommen sie noch dazu?',
        modelAnswerEnglish:
            'Are the utilities included or do they come on top?',
        quickReplies: <String>[
          'Sind die Nebenkosten inklusive?',
          'Was kostet die Warmmiete?',
        ],
        coachTip: 'Kaltmiete = rent alone. Warmmiete = rent plus Nebenkosten.',
      ),
      DialogueStep(
        tutorGerman:
            'Die Nebenkosten betragen 150 Euro zusätzlich. Strom zahlen Sie selbst.',
        tutorEnglish:
            'Utilities are 150 euros on top. You pay for electricity yourself.',
        task: 'Ask from when the flat is available.',
        keywords: <String>['ab wann', 'frei', 'einziehen', 'wann', 'verfügbar'],
        requiredHits: 2,
        modelAnswer: 'Verstehe. Ab wann ist die Wohnung frei?',
        modelAnswerEnglish: 'I see. From when is the flat available?',
        quickReplies: <String>[
          'Ab wann ist die Wohnung frei?',
          'Wann kann ich einziehen?',
        ],
        coachTip:
            '„einziehen“ is separable: Wann kann ich *ein*ziehen? — prefix at the end.',
      ),
      DialogueStep(
        tutorGerman: 'Ab dem ersten Oktober. Möchten Sie noch etwas wissen?',
        tutorEnglish:
            'From the first of October. Would you like to know anything else?',
        task: 'Ask about one rule — pets, smoking or the deposit.',
        keywords: <String>[
          'kaution',
          'haustiere',
          'rauchen',
          'darf',
          'erlaubt',
          'waschmaschine',
        ],
        requiredHits: 2,
        modelAnswer:
            'Ja, wie hoch ist die Kaution? Und sind Haustiere erlaubt?',
        modelAnswerEnglish:
            'Yes, how high is the deposit? And are pets allowed?',
        quickReplies: <String>[
          'Wie hoch ist die Kaution?',
          'Sind Haustiere erlaubt?',
        ],
        coachTip:
            'A Kaution of up to three months\' Kaltmiete is standard in Germany.',
      ),
      DialogueStep(
        tutorGerman:
            'Zwei Kaltmieten Kaution, Haustiere nach Absprache. Interesse?',
        tutorEnglish:
            'Two months\' base rent as deposit, pets by agreement. Interested?',
        task: 'Express interest and propose a next step.',
        keywords: <String>[
          'interesse',
          'gern',
          'melde',
          'unterlagen',
          'ja',
          'überlegen',
        ],
        requiredHits: 2,
        minWords: 5,
        modelAnswer:
            'Ja, ich habe großes Interesse. Ich schicke Ihnen morgen meine Unterlagen.',
        modelAnswerEnglish:
            'Yes, I am very interested. I will send you my documents tomorrow.',
        quickReplies: <String>[
          'Ja, ich habe Interesse.',
          'Ich möchte es mir noch überlegen.',
        ],
        coachTip:
            'Closing with a concrete next step is what gets you the flat.',
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-a2-03',
    level: CefrLevel.a2,
    emoji: '🚆',
    title: 'Am Bahnhof',
    setting:
        'You need to get to Berlin this afternoon and your train is cancelled.',
    tutorRole: 'Mitarbeiter am Schalter (ticket clerk)',
    learnerRole: 'Reisende Person',
    goal: 'Rebook a journey and understand the new connection.',
    usefulPhrases: <String>[
      'Wann fährt der nächste Zug nach …?',
      'Muss ich umsteigen?',
      'Von welchem Gleis fährt er ab?',
      'Was kostet eine Fahrkarte nach …?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Guten Tag, was kann ich für Sie tun?',
        tutorEnglish: 'Hello, what can I do for you?',
        task: 'Explain your problem: your train was cancelled.',
        keywords: <String>[
          'zug',
          'ausgefallen',
          'problem',
          'berlin',
          'gestrichen',
          'nicht',
        ],
        requiredHits: 2,
        minWords: 5,
        modelAnswer: 'Guten Tag. Mein Zug nach Berlin ist ausgefallen.',
        modelAnswerEnglish: 'Hello. My train to Berlin has been cancelled.',
        quickReplies: <String>[
          'Mein Zug nach Berlin ist ausgefallen.',
          'Der Zug fährt heute nicht.',
        ],
        coachTip:
            '„ausfallen“ is the standard verb for a cancelled train or class.',
      ),
      DialogueStep(
        tutorGerman: 'Das tut mir leid. Wann möchten Sie fahren?',
        tutorEnglish: 'I am sorry about that. When would you like to travel?',
        task: 'Say when you need to be there.',
        keywords: <String>[
          'heute',
          'nachmittag',
          'uhr',
          'abend',
          'muss',
          'spätestens',
        ],
        requiredHits: 2,
        minWords: 4,
        modelAnswer:
            'Ich muss heute spätestens um achtzehn Uhr in Berlin sein.',
        modelAnswerEnglish:
            'I have to be in Berlin by six p.m. today at the latest.',
        quickReplies: <String>[
          'Heute Nachmittag, bitte.',
          'Ich muss um 18 Uhr dort sein.',
        ],
        coachTip:
            'Time before place: „heute um 18 Uhr in Berlin“ — Time, Manner, Place.',
      ),
      DialogueStep(
        tutorGerman: 'Es gibt einen Zug um vierzehn Uhr zwölf über Hamburg.',
        tutorEnglish: 'There is a train at 14:12 via Hamburg.',
        task: 'Ask whether you have to change trains.',
        keywords: <String>['umsteigen', 'direkt', 'muss ich', 'wo'],
        modelAnswer: 'Muss ich umsteigen oder fährt der Zug direkt?',
        modelAnswerEnglish: 'Do I have to change or does the train go direct?',
        quickReplies: <String>[
          'Muss ich umsteigen?',
          'Ist das eine direkte Verbindung?',
        ],
        coachTip:
            'umsteigen = change trains; einsteigen = board; aussteigen = get off.',
      ),
      DialogueStep(
        tutorGerman:
            'Sie steigen einmal in Hamburg um, dort haben Sie zwölf Minuten.',
        tutorEnglish:
            'You change once in Hamburg, where you have twelve minutes.',
        task: 'Ask what the ticket costs.',
        keywords: <String>[
          'kostet',
          'fahrkarte',
          'ticket',
          'preis',
          'wie viel',
        ],
        requiredHits: 2,
        modelAnswer: 'Alles klar. Was kostet die Fahrkarte?',
        modelAnswerEnglish: 'All right. What does the ticket cost?',
        quickReplies: <String>[
          'Was kostet die Fahrkarte?',
          'Wie viel kostet das Ticket?',
        ],
        coachTip: 'die Fahrkarte / das Ticket — both are used at the counter.',
      ),
      DialogueStep(
        tutorGerman:
            'Ihre alte Fahrkarte gilt weiter, Sie zahlen nichts extra.',
        tutorEnglish: 'Your old ticket remains valid, you pay nothing extra.',
        task: 'Ask which platform the train leaves from.',
        keywords: <String>['gleis', 'welchem', 'abfahrt', 'wo'],
        requiredHits: 2,
        modelAnswer: 'Sehr gut. Von welchem Gleis fährt der Zug ab?',
        modelAnswerEnglish:
            'Very good. Which platform does the train leave from?',
        quickReplies: <String>[
          'Von welchem Gleis fährt er ab?',
          'Wo finde ich den Zug?',
        ],
        coachTip: '„abfahren“ is separable: Der Zug *fährt* um 14:12 *ab*.',
      ),
      DialogueStep(
        tutorGerman: 'Von Gleis sieben. Gute Reise!',
        tutorEnglish: 'From platform seven. Have a good trip!',
        task: 'Thank him and close.',
        keywords: <String>[
          'danke',
          'vielen dank',
          'tschüss',
          'wiedersehen',
          'geholfen',
        ],
        modelAnswer: 'Vielen Dank für Ihre Hilfe! Auf Wiedersehen.',
        modelAnswerEnglish: 'Thank you very much for your help! Goodbye.',
        quickReplies: <String>[
          'Vielen Dank für Ihre Hilfe!',
          'Danke, auf Wiedersehen.',
        ],
        coachTip: '„Danke für + Akkusativ“: Danke für Ihre Hilfe.',
      ),
    ],
  ),
];

const List<ConversationScenario> _independentScenarios = <ConversationScenario>[
  // ---------------------------------------------------------------- B1 ----
  ConversationScenario(
    id: 'cv-b1-01',
    level: CefrLevel.b1,
    emoji: '💼',
    title: 'Das Vorstellungsgespräch',
    setting: 'A job interview for a technical position at a mid-sized company.',
    tutorRole: 'Personalerin (HR manager)',
    learnerRole: 'Bewerber (applicant)',
    goal: 'Present your background, motivation and questions convincingly.',
    usefulPhrases: <String>[
      'Zurzeit arbeite ich als …',
      'Ich habe mich beworben, weil …',
      'Meine Stärke liegt darin, …',
      'Könnten Sie mir sagen, ob …?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman:
            'Schön, dass Sie da sind. Erzählen Sie doch kurz etwas über sich.',
        tutorEnglish: 'Good to have you here. Tell us a bit about yourself.',
        task:
            'Give a structured 3-sentence self-presentation: education, current role, focus.',
        keywords: <String>[
          'studiert',
          'arbeite',
          'erfahrung',
          'zurzeit',
          'jahre',
          'abschluss',
        ],
        requiredHits: 3,
        minWords: 18,
        modelAnswer:
            'Gern. Ich habe Maschinenbau studiert und arbeite zurzeit als Prozessingenieur. '
            'In den letzten drei Jahren habe ich vor allem Regelungssysteme betreut. '
            'Besonders interessiert mich die Optimierung von Anlagen.',
        modelAnswerEnglish:
            'Gladly. I studied mechanical engineering and currently work as a process engineer. '
            'Over the last three years I mainly looked after control systems. '
            'I am particularly interested in optimising plants.',
        quickReplies: <String>['Ich habe … studiert und arbeite zurzeit als …'],
        coachTip:
            'Three sentences beats one long one: background → present role → focus.',
      ),
      DialogueStep(
        tutorGerman: 'Warum haben Sie sich gerade bei uns beworben?',
        tutorEnglish: 'Why did you apply to us in particular?',
        task: 'Give two reasons and link them with a connector.',
        keywords: <String>[
          'weil',
          'da',
          'außerdem',
          'interessiert',
          'passt',
          'entwickeln',
        ],
        requiredHits: 3,
        minWords: 16,
        modelAnswer:
            'Ich habe mich beworben, weil Ihr Unternehmen stark in der Automatisierung ist. '
            'Außerdem passt die Stelle sehr gut zu meiner bisherigen Erfahrung.',
        modelAnswerEnglish:
            'I applied because your company is strong in automation. '
            'Moreover, the position fits my previous experience very well.',
        quickReplies: <String>[
          'Ich habe mich beworben, weil …',
          'Außerdem passt die Stelle zu …',
        ],
        coachTip:
            'After „weil“ the verb goes last; after „außerdem“ it stays in position two.',
      ),
      DialogueStep(
        tutorGerman: 'Was würden Sie als Ihre größte Schwäche bezeichnen?',
        tutorEnglish: 'What would you describe as your greatest weakness?',
        task: 'Name a real weakness and say what you do about it.',
        keywords: <String>[
          'schwäche',
          'früher',
          'inzwischen',
          'daran',
          'arbeite',
          'gelernt',
          'versuche',
          'delegiere',
          'plane',
          'aufgaben',
        ],
        requiredHits: 3,
        minWords: 16,
        modelAnswer:
            'Früher habe ich zu viele Aufgaben selbst übernommen. '
            'Inzwischen delegiere ich bewusst und plane Zwischenschritte fest ein.',
        modelAnswerEnglish:
            'In the past I took on too many tasks myself. '
            'Now I deliberately delegate and plan intermediate steps.',
        quickReplies: <String>['Manchmal … . Daran arbeite ich, indem ich …'],
        coachTip:
            'Structure: weakness → concrete counter-measure. Never end on the weakness.',
      ),
      DialogueStep(
        tutorGerman: 'Wie gehen Sie mit Termindruck um?',
        tutorEnglish: 'How do you deal with deadline pressure?',
        task: 'Describe your approach with an example.',
        keywords: <String>[
          'priorisiere',
          'priorität',
          'zuerst',
          'plane',
          'kritisch',
          'zum beispiel',
          'abstimmung',
          'absprache',
        ],
        requiredHits: 3,
        minWords: 16,
        modelAnswer:
            'Ich priorisiere zuerst und kläre früh, was wirklich kritisch ist. '
            'Als wir letztes Jahr eine Anlage umbauen mussten, habe ich zum Beispiel täglich kurze Abstimmungen eingeführt.',
        modelAnswerEnglish:
            'I prioritise first and clarify early what is really critical. '
            'When we had to rebuild a plant last year, for example, I introduced short daily check-ins.',
        quickReplies: <String>[
          'Ich priorisiere zuerst und …',
          'Zum Beispiel habe ich …',
        ],
        coachTip:
            'A concrete example beats an abstract claim in every German interview.',
      ),
      DialogueStep(
        tutorGerman: 'Welche Gehaltsvorstellung haben Sie?',
        tutorEnglish: 'What are your salary expectations?',
        task: 'Name a range and justify it briefly.',
        keywords: <String>[
          'vorstellung',
          'euro',
          'bereich',
          'erfahrung',
          'zwischen',
          'brutto',
        ],
        requiredHits: 2,
        minWords: 12,
        modelAnswer:
            'Auf Basis meiner Erfahrung liegt meine Vorstellung zwischen 58.000 und 62.000 Euro brutto im Jahr.',
        modelAnswerEnglish:
            'Based on my experience my expectation is between 58,000 and 62,000 euros gross per year.',
        quickReplies: <String>[
          'Meine Vorstellung liegt zwischen … und … Euro.',
        ],
        coachTip: 'German salaries are quoted brutto (gross) and per year.',
      ),
      DialogueStep(
        tutorGerman: 'Haben Sie noch Fragen an uns?',
        tutorEnglish: 'Do you have any questions for us?',
        task: 'Ask two informed questions about the role or the team.',
        keywords: <String>[
          'team',
          'einarbeitung',
          'projekt',
          'könnten sie',
          'wie',
          'weiterbildung',
        ],
        requiredHits: 2,
        minWords: 12,
        modelAnswer:
            'Ja, zwei Fragen: Wie ist das Team aufgestellt? Und wie sieht die Einarbeitung in den ersten Monaten aus?',
        modelAnswerEnglish:
            'Yes, two questions: How is the team set up? And what does onboarding look like in the first months?',
        quickReplies: <String>[
          'Wie ist das Team aufgestellt?',
          'Wie sieht die Einarbeitung aus?',
        ],
        coachTip:
            'Having no questions is read as a lack of interest — always prepare two.',
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-b1-02',
    level: CefrLevel.b1,
    emoji: '🏛️',
    title: 'Beim Bürgeramt',
    setting: 'You are registering your new address and something is missing.',
    tutorRole: 'Sachbearbeiterin (case worker)',
    learnerRole: 'Antragsteller',
    goal: 'Complete the registration despite a missing document.',
    usefulPhrases: <String>[
      'Ich möchte mich anmelden.',
      'Leider habe ich … nicht dabei.',
      'Wäre es möglich, dass …?',
      'Was brauche ich noch?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Guten Tag. Worum geht es?',
        tutorEnglish: 'Hello. What is this about?',
        task: 'Say what you want to do and since when you live at the address.',
        keywords: <String>[
          'anmelden',
          'wohnung',
          'seit',
          'umgezogen',
          'adresse',
        ],
        requiredHits: 2,
        minWords: 8,
        modelAnswer:
            'Guten Tag. Ich möchte mich anmelden. Ich bin vor zwei Wochen umgezogen.',
        modelAnswerEnglish:
            'Hello. I would like to register. I moved two weeks ago.',
        quickReplies: <String>[
          'Ich möchte mich anmelden.',
          'Ich bin vor zwei Wochen umgezogen.',
        ],
        coachTip: 'sich anmelden is reflexive: Ich melde *mich* an.',
      ),
      DialogueStep(
        tutorGerman:
            'Haben Sie die Wohnungsgeberbestätigung und Ihren Ausweis dabei?',
        tutorEnglish:
            'Do you have the landlord confirmation and your ID with you?',
        task: 'Say you have one document but not the other.',
        keywords: <String>[
          'ausweis',
          'bestätigung',
          'leider',
          'nicht',
          'dabei',
          'nur',
        ],
        requiredHits: 3,
        minWords: 10,
        modelAnswer:
            'Meinen Ausweis habe ich dabei, die Wohnungsgeberbestätigung leider nicht.',
        modelAnswerEnglish:
            'I have my ID with me, but unfortunately not the landlord confirmation.',
        quickReplies: <String>[
          'Den Ausweis habe ich, die Bestätigung leider nicht.',
        ],
        coachTip:
            'Fronting the object („Meinen Ausweis habe ich …“) is a natural contrast device.',
      ),
      DialogueStep(
        tutorGerman:
            'Ohne die Bestätigung kann ich die Anmeldung nicht abschließen.',
        tutorEnglish:
            'Without the confirmation I cannot complete the registration.',
        task: 'Ask politely whether you can hand it in later.',
        keywords: <String>[
          'nachreichen',
          'später',
          'möglich',
          'könnte',
          'wäre',
          'per e-mail',
        ],
        requiredHits: 2,
        minWords: 10,
        modelAnswer:
            'Wäre es möglich, dass ich die Bestätigung nachreiche, zum Beispiel per E-Mail?',
        modelAnswerEnglish:
            'Would it be possible for me to submit the confirmation later, for example by email?',
        quickReplies: <String>[
          'Wäre es möglich, dass ich sie nachreiche?',
          'Kann ich sie per E-Mail schicken?',
        ],
        coachTip:
            '„Wäre es möglich, dass …?“ is the polite Konjunktiv II request form.',
      ),
      DialogueStep(
        tutorGerman:
            'Nachreichen geht leider nicht. Sie können aber einen neuen Termin buchen.',
        tutorEnglish:
            'Submitting later is unfortunately not possible. But you can book a new appointment.',
        task: 'Explain your problem: the deadline is in a few days.',
        keywords: <String>[
          'frist',
          'zwei wochen',
          'problem',
          'muss',
          'strafe',
          'termin',
        ],
        requiredHits: 2,
        minWords: 12,
        modelAnswer:
            'Das ist schwierig, denn die Frist läuft in wenigen Tagen ab. Gibt es einen früheren Termin?',
        modelAnswerEnglish:
            'That is difficult, because the deadline expires in a few days. Is there an earlier appointment?',
        quickReplies: <String>[
          'Die Frist läuft bald ab.',
          'Gibt es einen früheren Termin?',
        ],
        coachTip:
            '„denn“ keeps normal word order; „weil“ sends the verb to the end.',
      ),
      DialogueStep(
        tutorGerman:
            'Nächsten Dienstag um neun Uhr hätte ich noch einen Platz.',
        tutorEnglish: 'Next Tuesday at nine I still have a slot.',
        task: 'Accept and confirm the details.',
        keywords: <String>[
          'dienstag',
          'neun',
          'nehme',
          'passt',
          'gern',
          'bestätigen',
        ],
        requiredHits: 2,
        minWords: 8,
        modelAnswer:
            'Den nehme ich gern. Also Dienstag um neun Uhr — bekomme ich eine Bestätigung?',
        modelAnswerEnglish:
            'I will gladly take it. So Tuesday at nine — will I get a confirmation?',
        quickReplies: <String>[
          'Den Termin nehme ich gern.',
          'Bekomme ich eine Bestätigung?',
        ],
        coachTip:
            'Repeating the date back prevents the classic Amt misunderstanding.',
      ),
      DialogueStep(
        tutorGerman:
            'Sie bekommen sie per E-Mail. Bringen Sie bitte alle Unterlagen mit.',
        tutorEnglish:
            'You will get it by email. Please bring all documents with you.',
        task: 'Confirm what you will bring and thank her.',
        keywords: <String>[
          'bringe',
          'mit',
          'ausweis',
          'bestätigung',
          'danke',
          'unterlagen',
        ],
        requiredHits: 3,
        minWords: 10,
        modelAnswer:
            'Alles klar, ich bringe den Ausweis und die Wohnungsgeberbestätigung mit. Vielen Dank für Ihre Hilfe.',
        modelAnswerEnglish:
            'All right, I will bring my ID and the landlord confirmation. Thank you very much for your help.',
        quickReplies: <String>['Ich bringe alle Unterlagen mit. Vielen Dank!'],
        coachTip: 'mitbringen is separable: Ich *bringe* die Unterlagen *mit*.',
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-b1-03',
    level: CefrLevel.b1,
    emoji: '🔊',
    title: 'Streit mit dem Nachbarn',
    setting:
        'Your neighbour plays loud music late at night. You knock on the door.',
    tutorRole: 'Nachbar (neighbour)',
    learnerRole: 'Sie selbst',
    goal: 'Complain clearly but politely and agree on a solution.',
    usefulPhrases: <String>[
      'Es geht um …',
      'Ich möchte niemanden ärgern, aber …',
      'Könnten wir vereinbaren, dass …?',
      'Das wäre für mich in Ordnung.',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Ja bitte? Was gibt es denn so spät?',
        tutorEnglish: 'Yes? What is it, so late?',
        task: 'Introduce the problem politely and factually.',
        keywords: <String>[
          'entschuldigung',
          'musik',
          'laut',
          'geht um',
          'stört',
          'abend',
        ],
        requiredHits: 3,
        minWords: 12,
        modelAnswer:
            'Entschuldigen Sie die Störung. Es geht um die Musik — sie ist abends sehr laut bei mir zu hören.',
        modelAnswerEnglish:
            'Sorry to disturb you. It is about the music — in the evening it is very loud in my flat.',
        quickReplies: <String>[
          'Es geht um die Musik am Abend.',
          'Die Musik ist bei mir sehr laut.',
        ],
        coachTip:
            'Describe the effect („bei mir zu hören“), not the person. It de-escalates.',
      ),
      DialogueStep(
        tutorGerman: 'Wirklich? So laut ist das doch gar nicht.',
        tutorEnglish: 'Really? It is not that loud at all.',
        task: 'Stay calm and give a concrete detail (time, how often).',
        keywords: <String>[
          'gestern',
          'uhr',
          'jeden',
          'oft',
          'mitternacht',
          'seit',
        ],
        requiredHits: 2,
        minWords: 12,
        modelAnswer:
            'Gestern war es bis nach Mitternacht zu hören, und das passiert inzwischen fast jede Woche.',
        modelAnswerEnglish:
            'Yesterday it could be heard past midnight, and by now that happens almost every week.',
        quickReplies: <String>[
          'Gestern war es bis Mitternacht laut.',
          'Das passiert fast jede Woche.',
        ],
        coachTip:
            'Specific facts are far more persuasive than „immer“ or „ständig“.',
      ),
      DialogueStep(
        tutorGerman:
            'Ich arbeite tagsüber, abends will ich mich einfach entspannen.',
        tutorEnglish:
            'I work during the day, in the evening I just want to relax.',
        task: 'Show understanding, then state your own need.',
        keywords: <String>[
          'verstehe',
          'nachvollziehen',
          'aber',
          'trotzdem',
          'früh',
          'schlafen',
        ],
        requiredHits: 3,
        minWords: 14,
        modelAnswer:
            'Das kann ich gut nachvollziehen. Trotzdem muss ich morgens um halb sechs aufstehen und brauche Schlaf.',
        modelAnswerEnglish:
            'I fully understand that. Still, I have to get up at half past five and I need sleep.',
        quickReplies: <String>['Das kann ich nachvollziehen, aber …'],
        coachTip:
            'Acknowledge-then-object („Das verstehe ich, trotzdem …“) is the core B1 negotiation move.',
      ),
      DialogueStep(
        tutorGerman:
            'Und was soll ich jetzt machen? Die Musik ganz ausschalten?',
        tutorEnglish:
            'And what am I supposed to do now? Switch the music off entirely?',
        task: 'Propose a concrete, realistic compromise.',
        keywords: <String>[
          'vorschlag',
          'ab',
          'uhr',
          'leiser',
          'kopfhörer',
          'könnten wir',
        ],
        requiredHits: 2,
        minWords: 12,
        modelAnswer:
            'Mein Vorschlag wäre: ab zweiundzwanzig Uhr etwas leiser oder mit Kopfhörern. Wäre das machbar?',
        modelAnswerEnglish:
            'My suggestion would be: a bit quieter after ten p.m. or with headphones. Would that be doable?',
        quickReplies: <String>[
          'Könnten wir vereinbaren, dass es ab 22 Uhr leiser ist?',
        ],
        coachTip:
            'German law recognises Nachtruhe from 22:00 — naming it makes the request reasonable.',
      ),
      DialogueStep(
        tutorGerman: 'Ab zweiundzwanzig Uhr leiser — damit könnte ich leben.',
        tutorEnglish: 'Quieter after ten p.m. — I could live with that.',
        task: 'Confirm the agreement in your own words.',
        keywords: <String>[
          'abgemacht',
          'einverstanden',
          'super',
          'freut',
          'vereinbart',
          'danke',
        ],
        requiredHits: 2,
        minWords: 8,
        modelAnswer: 'Super, dann ist das abgemacht. Das freut mich wirklich.',
        modelAnswerEnglish: 'Great, then that is agreed. I am really glad.',
        quickReplies: <String>[
          'Dann ist das abgemacht.',
          'Einverstanden, vielen Dank!',
        ],
        coachTip: '„Abgemacht“ seals an informal agreement in one word.',
      ),
      DialogueStep(
        tutorGerman: 'Sagen Sie einfach Bescheid, wenn es wieder zu laut ist.',
        tutorEnglish: 'Just let me know if it gets too loud again.',
        task: 'Close positively and offer the same in return.',
        keywords: <String>[
          'gilt',
          'auch',
          'natürlich',
          'danke',
          'gute nacht',
          'ebenso',
        ],
        requiredHits: 2,
        minWords: 8,
        modelAnswer:
            'Mache ich — und das gilt natürlich auch umgekehrt. Gute Nacht!',
        modelAnswerEnglish:
            'I will — and of course that goes both ways. Good night!',
        quickReplies: <String>[
          'Das gilt natürlich auch umgekehrt.',
          'Danke, gute Nacht!',
        ],
        coachTip:
            'Offering reciprocity turns a complaint into a neighbourly relationship.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- B2 ----
  ConversationScenario(
    id: 'cv-b2-01',
    level: CefrLevel.b2,
    emoji: '📊',
    title: 'Die Teambesprechung',
    setting:
        'A project meeting. A deadline is at risk and you must propose a plan.',
    tutorRole: 'Teamleiterin (team lead)',
    learnerRole: 'Projektmitglied',
    goal: 'Present a problem, argue for a solution and handle objections.',
    usefulPhrases: <String>[
      'Aus meiner Sicht …',
      'Das lässt sich damit begründen, dass …',
      'Ich schlage vor, dass wir …',
      'Dem würde ich insofern widersprechen, als …',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Wie ist der aktuelle Stand beim Testmodul?',
        tutorEnglish: 'What is the current status of the test module?',
        task: 'Report status factually and name the risk.',
        keywords: <String>[
          'stand',
          'verzögerung',
          'risiko',
          'prozent',
          'fertig',
          'allerdings',
        ],
        requiredHits: 3,
        minWords: 18,
        modelAnswer:
            'Das Modul ist zu etwa achtzig Prozent fertig. Allerdings zeichnet sich eine Verzögerung ab, '
            'weil die Schnittstelle später geliefert wurde als geplant.',
        modelAnswerEnglish:
            'The module is about eighty percent complete. However, a delay is emerging '
            'because the interface was delivered later than planned.',
        quickReplies: <String>['Das Modul ist zu 80 % fertig, allerdings …'],
        coachTip:
            'Status first, risk second, cause third — that order keeps the room calm.',
      ),
      DialogueStep(
        tutorGerman: 'Wie groß ist die Verzögerung konkret?',
        tutorEnglish: 'How big is the delay in concrete terms?',
        task: 'Quantify and state your confidence.',
        keywords: <String>[
          'woche',
          'tage',
          'schätze',
          'voraussichtlich',
          'davon aus',
          'realistisch',
        ],
        requiredHits: 2,
        minWords: 14,
        modelAnswer:
            'Realistisch rechne ich mit rund zwei Wochen. Ich gehe davon aus, dass wir Mitte des Monats liefern können.',
        modelAnswerEnglish:
            'Realistically I reckon with around two weeks. I assume we can deliver by mid-month.',
        quickReplies: <String>[
          'Ich rechne mit rund zwei Wochen.',
          'Ich gehe davon aus, dass …',
        ],
        coachTip:
            '„Ich gehe davon aus, dass …“ is the professional way to state an assumption.',
      ),
      DialogueStep(
        tutorGerman:
            'Zwei Wochen sind viel. Können wir nicht einfach Ressourcen aufstocken?',
        tutorEnglish: 'Two weeks is a lot. Can we not simply add resources?',
        task: 'Disagree respectfully and explain why that will not help.',
        keywords: <String>[
          'widersprechen',
          'einarbeitung',
          'eingearbeitet',
          'kurzfristig',
          'allerdings',
          'problem',
          'nicht',
        ],
        requiredHits: 2,
        minWords: 18,
        modelAnswer:
            'Dem würde ich insofern widersprechen, als zusätzliche Personen zunächst eingearbeitet werden müssten. '
            'Kurzfristig würde das die Entwicklung eher verlangsamen.',
        modelAnswerEnglish:
            'I would disagree insofar as additional people would first have to be onboarded. '
            'In the short term that would rather slow development down.',
        quickReplies: <String>['Dem würde ich insofern widersprechen, als …'],
        coachTip:
            '„Dem würde ich widersprechen“ is firm but not confrontational.',
      ),
      DialogueStep(
        tutorGerman: 'Was schlagen Sie stattdessen vor?',
        tutorEnglish: 'What do you propose instead?',
        task: 'Make a structured proposal with two elements.',
        keywords: <String>[
          'schlage vor',
          'erstens',
          'zweitens',
          'priorisieren',
          'zunächst',
          'anschließend',
        ],
        requiredHits: 3,
        minWords: 20,
        modelAnswer:
            'Ich schlage vor, dass wir erstens den Funktionsumfang für das erste Release reduzieren '
            'und zweitens die Tests parallel zur Entwicklung aufsetzen.',
        modelAnswerEnglish:
            'I propose that we first reduce the scope for the initial release '
            'and second set up testing in parallel with development.',
        quickReplies: <String>[
          'Ich schlage vor, dass wir erstens … und zweitens …',
        ],
        coachTip:
            'Numbering your points („erstens … zweitens …“) makes you sound decisive.',
      ),
      DialogueStep(
        tutorGerman: 'Und wenn der Kunde auf dem vollen Umfang besteht?',
        tutorEnglish: 'And if the client insists on the full scope?',
        task: 'Handle the hypothetical with a conditional.',
        keywords: <String>[
          'falls',
          'sollte',
          'dann',
          'müssten',
          'würde',
          'termin',
        ],
        requiredHits: 2,
        minWords: 16,
        modelAnswer:
            'Sollte der Kunde darauf bestehen, müssten wir den Termin gemeinsam verschieben. '
            'Beides gleichzeitig ist nicht seriös zuzusagen.',
        modelAnswerEnglish:
            'Should the client insist, we would have to postpone the deadline together. '
            'Promising both at once would not be serious.',
        quickReplies: <String>[
          'Sollte der Kunde darauf bestehen, müssten wir …',
        ],
        coachTip:
            'Conditional „sollte …“ without „wenn“ inverts the verb — a very B2 move.',
      ),
      DialogueStep(
        tutorGerman:
            'Gut. Fassen Sie bitte zusammen, was wir beschlossen haben.',
        tutorEnglish: 'Good. Please summarise what we have decided.',
        task:
            'Summarise the decision and the next step with an owner and a date.',
        keywords: <String>[
          'zusammenfassend',
          'wir haben',
          'bis',
          'übernehme',
          'nächster schritt',
          'freitag',
        ],
        requiredHits: 3,
        minWords: 18,
        modelAnswer:
            'Zusammenfassend: Wir reduzieren den Umfang des ersten Releases und testen parallel. '
            'Ich stimme das bis Freitag mit dem Kunden ab.',
        modelAnswerEnglish:
            'To summarise: we reduce the scope of the first release and test in parallel. '
            'I will align this with the client by Friday.',
        quickReplies: <String>[
          'Zusammenfassend: wir … . Ich übernehme … bis …',
        ],
        coachTip: 'Every good German meeting ends with wer, was, bis wann.',
      ),
    ],
  ),
];

const List<ConversationScenario> _advancedScenarios = <ConversationScenario>[
  ConversationScenario(
    id: 'cv-b2-02',
    level: CefrLevel.b2,
    emoji: '📦',
    title: 'Die Reklamation',
    setting:
        'A delivered machine part is defective and the supplier is evasive.',
    tutorRole: 'Kundendienstmitarbeiter (customer service agent)',
    learnerRole: 'Kunde (business customer)',
    goal:
        'Assert your claim firmly, stay polite, and secure a binding commitment.',
    usefulPhrases: <String>[
      'Ich beziehe mich auf …',
      'Aus unserer Sicht liegt ein Mangel vor.',
      'Ich möchte Sie bitten, … zu veranlassen.',
      'Können Sie mir das schriftlich bestätigen?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Kundendienst, guten Tag. Wie kann ich helfen?',
        tutorEnglish: 'Customer service, hello. How can I help?',
        task: 'State your reference and the defect precisely.',
        keywords: <String>[
          'beziehe mich',
          'lieferung',
          'mangel',
          'defekt',
          'bestellung',
          'nummer',
        ],
        requiredHits: 3,
        minWords: 16,
        modelAnswer:
            'Guten Tag. Ich beziehe mich auf die Lieferung vom fünften März, Auftragsnummer 4471. '
            'Das gelieferte Ventil weist einen deutlichen Mangel auf.',
        modelAnswerEnglish:
            'Hello. I am referring to the delivery of 5 March, order number 4471. '
            'The valve delivered has a clear defect.',
        quickReplies: <String>['Ich beziehe mich auf die Lieferung vom …'],
        coachTip:
            '„Ich beziehe mich auf …“ opens any formal complaint precisely.',
      ),
      DialogueStep(
        tutorGerman: 'Haben Sie das Teil denn korrekt montiert?',
        tutorEnglish: 'Did you install the part correctly, though?',
        task: 'Reject the implication calmly and give evidence.',
        keywords: <String>[
          'fachgerecht',
          'nach anleitung',
          'dokumentiert',
          'protokoll',
          'ausschließen',
          'geprüft',
        ],
        requiredHits: 3,
        minWords: 16,
        modelAnswer:
            'Die Montage erfolgte fachgerecht und nach Ihrer Anleitung; das ist im Prüfprotokoll dokumentiert. '
            'Einen Montagefehler können wir daher ausschließen.',
        modelAnswerEnglish:
            'Installation was carried out properly and according to your manual; that is documented in the inspection report. '
            'We can therefore rule out an installation error.',
        quickReplies: <String>[
          'Die Montage erfolgte fachgerecht und ist dokumentiert.',
        ],
        coachTip:
            'Passive („Die Montage erfolgte …“) depersonalises the exchange and lowers the temperature.',
      ),
      DialogueStep(
        tutorGerman:
            'Ich müsste das intern prüfen lassen. Das kann einige Wochen dauern.',
        tutorEnglish:
            'I would have to have that checked internally. That may take several weeks.',
        task: 'Push back on the timeline and name the consequence.',
        keywords: <String>[
          'stillstand',
          'produktion',
          'kosten',
          'nicht hinnehmbar',
          'kurzfristig',
          'frist',
        ],
        requiredHits: 3,
        minWords: 18,
        modelAnswer:
            'Mehrere Wochen sind für uns nicht hinnehmbar, da die Anlage stillsteht und täglich Kosten entstehen. '
            'Ich bitte um eine Rückmeldung innerhalb von fünf Werktagen.',
        modelAnswerEnglish:
            'Several weeks are unacceptable for us, as the plant is idle and costs accrue daily. '
            'I request a response within five working days.',
        quickReplies: <String>['Das ist für uns nicht hinnehmbar, da …'],
        coachTip:
            'Naming a concrete deadline converts a complaint into a claim.',
      ),
      DialogueStep(
        tutorGerman: 'Fünf Tage kann ich nicht zusagen. Vielleicht eine Woche.',
        tutorEnglish: 'I cannot commit to five days. Maybe a week.',
        task: 'Negotiate a middle position and tie it to an action.',
        keywords: <String>[
          'einigen',
          'kompromiss',
          'ersatzteil',
          'zwischenlösung',
          'vorab',
          'akzeptieren',
        ],
        requiredHits: 3,
        minWords: 18,
        modelAnswer:
            'Dann einigen wir uns auf eine Woche, sofern Sie vorab ein Ersatzteil als Zwischenlösung versenden. '
            'Unter dieser Bedingung akzeptiere ich die Frist.',
        modelAnswerEnglish:
            'Then let us settle on a week, provided you send a replacement part in advance as an interim solution. '
            'Under that condition I accept the deadline.',
        quickReplies: <String>['Einigen wir uns auf eine Woche, sofern …'],
        coachTip: '„sofern“ introduces a condition more formally than „wenn“.',
      ),
      DialogueStep(
        tutorGerman: 'Ein Ersatzteil kann ich vermutlich morgen rausschicken.',
        tutorEnglish: 'I can probably send a replacement part out tomorrow.',
        task: 'Convert the vague promise into a firm one.',
        keywords: <String>[
          'schriftlich',
          'bestätigen',
          'verbindlich',
          'e-mail',
          'zusage',
          'vermutlich',
        ],
        requiredHits: 3,
        minWords: 14,
        modelAnswer:
            '„Vermutlich“ hilft mir leider nicht. Können Sie mir die Zusage verbindlich per E-Mail bestätigen?',
        modelAnswerEnglish:
            '"Probably" unfortunately does not help me. Can you confirm the commitment bindingly by email?',
        quickReplies: <String>[
          'Können Sie mir das verbindlich schriftlich bestätigen?',
        ],
        coachTip:
            'Quoting the other side\'s hedge word back at them is a very effective B2 device.',
      ),
      DialogueStep(
        tutorGerman: 'In Ordnung, Sie bekommen die Bestätigung heute noch.',
        tutorEnglish: 'All right, you will get the confirmation later today.',
        task: 'Summarise the agreement and close professionally.',
        keywords: <String>[
          'halten wir fest',
          'zusammenfassend',
          'dank',
          'melde',
          'somit',
          'vereinbart',
          'ersatzteil',
          'bestätigung',
        ],
        requiredHits: 2,
        minWords: 16,
        modelAnswer:
            'Halten wir fest: Ersatzteil morgen, Prüfergebnis in einer Woche, Bestätigung heute per E-Mail. '
            'Vielen Dank für Ihr Entgegenkommen.',
        modelAnswerEnglish:
            'Let us note: replacement part tomorrow, test result in a week, confirmation today by email. '
            'Thank you for your accommodation.',
        quickReplies: <String>['Halten wir fest: … . Vielen Dank.'],
        coachTip:
            '„Halten wir fest“ is the standard German phrase for locking in an agreement.',
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-b2-03',
    level: CefrLevel.b2,
    emoji: '🏡',
    title: 'Diskussion: Homeoffice',
    setting: 'A colleague argues that remote work harms teams. You disagree.',
    tutorRole: 'Kollege (colleague)',
    learnerRole: 'Diskussionspartner',
    goal: 'Argue a position, concede a point and reformulate under pressure.',
    usefulPhrases: <String>[
      'Da ist etwas dran, allerdings …',
      'Man muss unterscheiden zwischen …',
      'Das lässt sich empirisch kaum belegen.',
      'Ich sehe das differenzierter.',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Ich finde, Homeoffice zerstört jede Teamkultur.',
        tutorEnglish: 'I think remote work destroys any team culture.',
        task: 'Disagree, but concede something first.',
        keywords: <String>[
          'da ist etwas dran',
          'allerdings',
          'differenzierter',
          'pauschal',
          'sehe ich',
          'jedoch',
        ],
        requiredHits: 2,
        minWords: 16,
        modelAnswer:
            'Da ist etwas dran, allerdings sehe ich das differenzierter. Pauschal lässt sich das nicht sagen, '
            'weil es stark von der Führung abhängt.',
        modelAnswerEnglish:
            'There is something to that, but I see it in a more differentiated way. It cannot be said across the board, '
            'because it depends heavily on leadership.',
        quickReplies: <String>['Da ist etwas dran, allerdings …'],
        coachTip:
            'Concede-then-qualify is how educated German disagreement works.',
      ),
      DialogueStep(
        tutorGerman: 'Aber spontane Gespräche entstehen doch nur im Büro.',
        tutorEnglish:
            'But spontaneous conversations only happen in the office.',
        task: 'Make a distinction rather than a flat denial.',
        keywords: <String>[
          'unterscheiden',
          'zwischen',
          'einerseits',
          'andererseits',
          'zufällig',
          'strukturiert',
        ],
        requiredHits: 2,
        minWords: 18,
        modelAnswer:
            'Man muss zwischen zufälligem Austausch und strukturierter Zusammenarbeit unterscheiden. '
            'Ersterer leidet tatsächlich, letztere wird oft sogar besser dokumentiert.',
        modelAnswerEnglish:
            'One has to distinguish between chance exchange and structured collaboration. '
            'The former does suffer, the latter is often even better documented.',
        quickReplies: <String>['Man muss unterscheiden zwischen … und …'],
        coachTip:
            '„Ersterer/letzterer“ (the former/the latter) is a compact B2 cohesion device.',
      ),
      DialogueStep(
        tutorGerman: 'Studien zeigen doch klar, dass die Produktivität sinkt.',
        tutorEnglish: 'Studies clearly show that productivity falls.',
        task: 'Challenge the evidence claim carefully.',
        keywords: <String>[
          'studien',
          'kommen zu',
          'unterschiedlich',
          'kaum belegen',
          'methodisch',
          'hängt davon ab',
        ],
        requiredHits: 2,
        minWords: 18,
        modelAnswer:
            'Die Studienlage ist uneinheitlich; verschiedene Untersuchungen kommen zu gegenläufigen Ergebnissen. '
            'Methodisch hängt viel davon ab, wie Produktivität überhaupt gemessen wird.',
        modelAnswerEnglish:
            'The evidence is mixed; different studies reach opposing results. '
            'Methodologically much depends on how productivity is measured at all.',
        quickReplies: <String>['Die Studienlage ist uneinheitlich, weil …'],
        coachTip:
            'Attacking the operationalisation is stronger than denying the finding.',
      ),
      DialogueStep(
        tutorGerman: 'Du willst also einfach nicht ins Büro kommen.',
        tutorEnglish: 'So you just do not want to come into the office.',
        task: 'Deflect the personal attack and return to the issue.',
        keywords: <String>[
          'darum geht es nicht',
          'sachlich',
          'persönlich',
          'zurückkommen',
          'frage',
          'eigentlich',
        ],
        requiredHits: 2,
        minWords: 14,
        modelAnswer:
            'Darum geht es mir nicht. Ich würde gern bei der sachlichen Frage bleiben, nämlich unter welchen Bedingungen hybride Arbeit funktioniert.',
        modelAnswerEnglish:
            'That is not my point. I would like to stay with the substantive question, namely under which conditions hybrid work functions.',
        quickReplies: <String>[
          'Darum geht es mir nicht — die eigentliche Frage ist …',
        ],
        coachTip: '„Darum geht es mir nicht“ reframes without escalating.',
      ),
      DialogueStep(
        tutorGerman: 'Gut. Was wäre denn dein konkreter Vorschlag?',
        tutorEnglish: 'Fine. What would your concrete proposal be?',
        task: 'Give a specific, testable proposal.',
        keywords: <String>[
          'vorschlag',
          'tage',
          'fest',
          'evaluieren',
          'pilot',
          'monaten',
        ],
        requiredHits: 3,
        minWords: 18,
        modelAnswer:
            'Mein Vorschlag wäre ein Pilot: zwei feste Bürotage pro Woche für das ganze Team, '
            'nach drei Monaten gemeinsam evaluiert.',
        modelAnswerEnglish:
            'My proposal would be a pilot: two fixed office days a week for the whole team, '
            'evaluated together after three months.',
        quickReplies: <String>['Mein Vorschlag wäre ein Pilot mit …'],
        coachTip: 'Turning a debate into a testable pilot is how you win it.',
      ),
      DialogueStep(
        tutorGerman: 'Damit könnte ich mich anfreunden.',
        tutorEnglish: 'I could warm to that.',
        task: 'Close the disagreement constructively.',
        keywords: <String>[
          'freut mich',
          'gemeinsam',
          'vorschlagen',
          'runde',
          'dann',
          'einbringen',
        ],
        requiredHits: 2,
        minWords: 12,
        modelAnswer:
            'Das freut mich. Dann bringen wir den Vorschlag gemeinsam in die nächste Teamrunde ein.',
        modelAnswerEnglish:
            'I am glad. Then let us bring the proposal into the next team meeting together.',
        quickReplies: <String>['Dann bringen wir das gemeinsam ein.'],
        coachTip:
            'Ending with joint ownership prevents the argument from resurfacing.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- C1 ----
  ConversationScenario(
    id: 'cv-c1-01',
    level: CefrLevel.c1,
    emoji: '🎙️',
    title: 'Podiumsdiskussion: KI im Bildungswesen',
    setting:
        'A panel discussion. You are the invited expert; the host presses you.',
    tutorRole: 'Moderatorin (host)',
    learnerRole: 'Expertin/Experte',
    goal: 'Argue precisely, qualify claims and resist false dichotomies.',
    usefulPhrases: <String>[
      'Ich würde zunächst differenzieren …',
      'Das setzt allerdings voraus, dass …',
      'Die Frage ist weniger …, als vielmehr …',
      'Empirisch belastbar ist das bislang nicht.',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman:
            'Zerstört künstliche Intelligenz das eigenständige Denken der Schüler?',
        tutorEnglish:
            'Is artificial intelligence destroying pupils\' independent thinking?',
        task: 'Reject the framing and reformulate the question.',
        keywords: <String>[
          'differenzieren',
          'weniger',
          'vielmehr',
          'frage',
          'unter welchen bedingungen',
          'pauschal',
        ],
        requiredHits: 3,
        minWords: 24,
        modelAnswer:
            'Ich würde zunächst differenzieren. Die Frage ist weniger, ob KI das Denken zerstört, '
            'als vielmehr, unter welchen didaktischen Bedingungen sie es unterstützt oder ersetzt.',
        modelAnswerEnglish:
            'I would first differentiate. The question is less whether AI destroys thinking, '
            'and more under which pedagogical conditions it supports or replaces it.',
        quickReplies: <String>['Die Frage ist weniger …, als vielmehr …'],
        coachTip:
            '„weniger …, als vielmehr …“ is the classic C1 reframing structure.',
      ),
      DialogueStep(
        tutorGerman: 'Sie weichen aus. Sagen Sie doch einfach ja oder nein.',
        tutorEnglish: 'You are evading. Just say yes or no.',
        task: 'Defend the refusal to simplify without sounding defensive.',
        keywords: <String>[
          'verkürzung',
          'zulässig',
          'sachverhalt',
          'komplex',
          'gerecht',
          'seriös',
        ],
        requiredHits: 3,
        minWords: 22,
        modelAnswer:
            'Eine solche Verkürzung würde dem Sachverhalt nicht gerecht. Seriös lässt sich nur sagen: '
            'Der Effekt hängt entscheidend davon ab, ob das Werkzeug den Denkprozess begleitet oder ihn ersetzt.',
        modelAnswerEnglish:
            'Such a simplification would not do justice to the matter. Seriously one can only say: '
            'the effect depends decisively on whether the tool accompanies the thinking process or replaces it.',
        quickReplies: <String>[
          'Eine solche Verkürzung würde dem Sachverhalt nicht gerecht.',
        ],
        coachTip:
            'Naming the rhetorical move („Verkürzung“) is more powerful than resisting it silently.',
      ),
      DialogueStep(
        tutorGerman:
            'Lehrkräfte berichten aber, dass Hausaufgaben praktisch wertlos geworden sind.',
        tutorEnglish:
            'But teachers report that homework has become practically worthless.',
        task: 'Take the observation seriously and reinterpret it.',
        keywords: <String>[
          'beobachtung',
          'ernst',
          'hinweis',
          'aufgabenformat',
          'weniger',
          'verlagert',
        ],
        requiredHits: 3,
        minWords: 24,
        modelAnswer:
            'Diese Beobachtung nehme ich ernst, deute sie aber anders: Sie ist weniger ein Hinweis auf die Technologie '
            'als auf ein Aufgabenformat, das reproduzierbares Wissen abfragt. Die Prüfungslogik verlagert sich.',
        modelAnswerEnglish:
            'I take that observation seriously but interpret it differently: it points less to the technology '
            'than to a task format that queries reproducible knowledge. The logic of assessment is shifting.',
        quickReplies: <String>['Diese Beobachtung deute ich anders: …'],
        coachTip:
            'Reinterpreting rather than denying evidence is the hallmark of an expert register.',
      ),
      DialogueStep(
        tutorGerman:
            'Sie verlangen also, dass Lehrkräfte alles umstellen. Ist das realistisch?',
        tutorEnglish:
            'So you are demanding teachers change everything. Is that realistic?',
        task: 'Concede the constraint and name the precondition.',
        keywords: <String>[
          'setzt voraus',
          'ressourcen',
          'zugestehen',
          'nicht über nacht',
          'fortbildung',
          'zweifellos',
        ],
        requiredHits: 3,
        minWords: 22,
        modelAnswer:
            'Zweifellos ist das nicht über Nacht zu leisten, und das muss man zugestehen. '
            'Es setzt Fortbildung, Zeit und verlässliche Ressourcen voraus — andernfalls bleibt jede Forderung folgenlos.',
        modelAnswerEnglish:
            'It certainly cannot be achieved overnight, and that has to be conceded. '
            'It presupposes training, time and reliable resources — otherwise any demand remains without consequence.',
        quickReplies: <String>['Das setzt allerdings voraus, dass …'],
        coachTip:
            '„Das setzt voraus, dass …“ flags a precondition; „andernfalls“ flags the consequence of ignoring it.',
      ),
      DialogueStep(
        tutorGerman:
            'Es gibt Kollegen, die ein komplettes Verbot fordern. Ihre Antwort?',
        tutorEnglish: 'Some colleagues demand an outright ban. Your response?',
        task: 'Reject the extreme position with an argument, not a label.',
        keywords: <String>[
          'verbot',
          'kaum durchsetzbar',
          'verlagert',
          'kontrolle',
          'stattdessen',
          'kompetenz',
        ],
        requiredHits: 3,
        minWords: 24,
        modelAnswer:
            'Ein Verbot wäre kaum durchsetzbar und würde die Nutzung lediglich aus dem Blickfeld der Schule verlagern. '
            'Sinnvoller erscheint mir, Kompetenz im Umgang systematisch aufzubauen.',
        modelAnswerEnglish:
            'A ban would hardly be enforceable and would merely shift usage out of the school\'s view. '
            'It seems more sensible to me to build competence in handling it systematically.',
        quickReplies: <String>['Ein Verbot wäre kaum durchsetzbar, weil …'],
        coachTip:
            'Attack feasibility first, desirability second — it is harder to dismiss.',
      ),
      DialogueStep(
        tutorGerman: 'Ein Schlusswort in zwei Sätzen, bitte.',
        tutorEnglish: 'A closing word in two sentences, please.',
        task: 'Deliver a tight, quotable conclusion.',
        keywords: <String>[
          'entscheidend',
          'nicht ob',
          'sondern wie',
          'letztlich',
          'verantwortung',
          'gestaltung',
        ],
        requiredHits: 3,
        minWords: 18,
        modelAnswer:
            'Entscheidend ist nicht, ob wir diese Werkzeuge einsetzen, sondern wie wir sie didaktisch einbetten. '
            'Die Verantwortung dafür lässt sich nicht an die Technik delegieren.',
        modelAnswerEnglish:
            'What matters is not whether we use these tools, but how we embed them pedagogically. '
            'The responsibility for that cannot be delegated to the technology.',
        quickReplies: <String>['Entscheidend ist nicht, ob …, sondern wie …'],
        coachTip:
            '„nicht …, sondern …“ gives a closing line its rhetorical snap.',
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-c1-02',
    level: CefrLevel.c1,
    emoji: '💶',
    title: 'Die Gehaltsverhandlung',
    setting:
        'An annual review. You want a significant raise; your manager resists.',
    tutorRole: 'Vorgesetzte (manager)',
    learnerRole: 'Mitarbeiter',
    goal: 'Anchor a number, justify it with evidence and hold your position.',
    usefulPhrases: <String>[
      'Gemessen an … halte ich … für angemessen.',
      'Ich verweise auf …',
      'Darüber ließe sich reden, sofern …',
      'Das würde ich ungern entkoppeln von …',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman:
            'Sie wollten über Ihre Vergütung sprechen. Womit fangen wir an?',
        tutorEnglish:
            'You wanted to talk about your compensation. Where do we start?',
        task: 'Open with your contribution, not your demand.',
        keywords: <String>[
          'jahr',
          'verantwortung',
          'übernommen',
          'ergebnis',
          'projekt',
          'entwickelt',
        ],
        requiredHits: 3,
        minWords: 22,
        modelAnswer:
            'Am besten mit dem vergangenen Jahr: Ich habe die Verantwortung für zwei zusätzliche Anlagen übernommen '
            'und die Ausfallzeiten messbar reduziert. Darauf möchte ich meine Vorstellung stützen.',
        modelAnswerEnglish:
            'Best with the past year: I took on responsibility for two additional plants '
            'and measurably reduced downtime. I would like to base my expectation on that.',
        quickReplies: <String>['Am besten mit dem vergangenen Jahr: …'],
        coachTip:
            'Establish value before naming a number; the number then sounds derived, not demanded.',
      ),
      DialogueStep(
        tutorGerman: 'Konkret: An welche Größenordnung denken Sie?',
        tutorEnglish: 'Concretely: what magnitude are you thinking of?',
        task: 'Anchor a specific figure and justify the reference point.',
        keywords: <String>[
          'halte ich',
          'angemessen',
          'gemessen an',
          'prozent',
          'markt',
          'euro',
        ],
        requiredHits: 3,
        minWords: 20,
        modelAnswer:
            'Gemessen an der erweiterten Verantwortung und am Marktniveau halte ich eine Anhebung um zwölf Prozent für angemessen.',
        modelAnswerEnglish:
            'Measured against the expanded responsibility and market level, I consider an increase of twelve percent appropriate.',
        quickReplies: <String>['Gemessen an … halte ich … für angemessen.'],
        coachTip:
            '„halte ich für angemessen“ states a judgement, not a wish — much harder to refuse.',
      ),
      DialogueStep(
        tutorGerman: 'Zwölf Prozent liegen deutlich über unserem Budgetrahmen.',
        tutorEnglish: 'Twelve percent is well above our budget framework.',
        task: 'Acknowledge the constraint without lowering your anchor.',
        keywords: <String>[
          'nachvollziehbar',
          'gleichwohl',
          'entkoppeln',
          'leistung',
          'budget',
          'unabhängig',
        ],
        requiredHits: 3,
        minWords: 22,
        modelAnswer:
            'Der Budgetrahmen ist nachvollziehbar. Gleichwohl würde ich die Bewertung meiner Leistung ungern '
            'von der Haushaltslage entkoppeln — beides sind unterschiedliche Fragen.',
        modelAnswerEnglish:
            'The budget framework is understandable. Nevertheless I would be reluctant to decouple the assessment of my performance '
            'from the budget situation — these are two different questions.',
        quickReplies: <String>[
          'Gleichwohl würde ich das ungern entkoppeln von …',
        ],
        coachTip: '„gleichwohl“ concedes and resists in a single word.',
      ),
      DialogueStep(
        tutorGerman: 'Ich könnte Ihnen sechs Prozent anbieten.',
        tutorEnglish: 'I could offer you six percent.',
        task: 'Do not accept the split; make a conditional counter.',
        keywords: <String>[
          'sofern',
          'darüber ließe sich reden',
          'unter der voraussetzung',
          'zusätzlich',
          'überprüfung',
          'halbjahr',
        ],
        requiredHits: 3,
        minWords: 22,
        modelAnswer:
            'Darüber ließe sich reden, sofern wir eine Überprüfung nach sechs Monaten schriftlich vereinbaren '
            'und die zusätzliche Anlagenverantwortung formal im Vertrag abgebildet wird.',
        modelAnswerEnglish:
            'That could be discussed, provided we agree in writing on a review after six months '
            'and the additional plant responsibility is formally reflected in the contract.',
        quickReplies: <String>['Darüber ließe sich reden, sofern …'],
        coachTip:
            'Trading a lower number for a written review is the standard German counter-move.',
      ),
      DialogueStep(
        tutorGerman:
            'Eine schriftliche Zusage für eine Überprüfung ist unüblich.',
        tutorEnglish: 'A written commitment to a review is unusual.',
        task: 'Normalise your request and stay firm.',
        keywords: <String>[
          'üblich',
          'protokoll',
          'aktenvermerk',
          'unproblematisch',
          'lediglich',
          'festhalten',
        ],
        requiredHits: 3,
        minWords: 20,
        modelAnswer:
            'Es genügt mir ein kurzer Aktenvermerk im Protokoll. Das ist organisatorisch unproblematisch '
            'und hält lediglich fest, was wir ohnehin besprochen haben.',
        modelAnswerEnglish:
            'A brief note in the minutes is enough for me. That is organisationally unproblematic '
            'and merely records what we have discussed anyway.',
        quickReplies: <String>[
          'Ein kurzer Aktenvermerk im Protokoll genügt mir.',
        ],
        coachTip:
            'Shrinking the ask („lediglich“, „genügt“) makes refusal look petty.',
      ),
      DialogueStep(
        tutorGerman:
            'Gut. Sechs Prozent jetzt, Überprüfung im Protokoll. Einverstanden?',
        tutorEnglish:
            'Fine. Six percent now, review noted in the minutes. Agreed?',
        task: 'Accept, restate the terms exactly, and set the date.',
        keywords: <String>[
          'einverstanden',
          'festhalten',
          'ab',
          'überprüfung',
          'protokoll',
          'danke',
        ],
        requiredHits: 3,
        minWords: 18,
        modelAnswer:
            'Einverstanden. Halten wir fest: sechs Prozent ab dem ersten des kommenden Monats, '
            'Überprüfung nach sechs Monaten, im Protokoll vermerkt. Danke für das offene Gespräch.',
        modelAnswerEnglish:
            'Agreed. Let us record: six percent from the first of next month, '
            'review after six months, noted in the minutes. Thank you for the open conversation.',
        quickReplies: <String>['Einverstanden. Halten wir fest: …'],
        coachTip:
            'Never leave a negotiation without repeating the terms out loud.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- C2 ----
  ConversationScenario(
    id: 'cv-c2-01',
    level: CefrLevel.c2,
    emoji: '📰',
    title: 'Interview zur Medienethik',
    setting:
        'A journalist interviews you about anonymous sources and public interest.',
    tutorRole: 'Journalistin',
    learnerRole: 'Medienethikerin/Medienethiker',
    goal: 'Sustain a nuanced position under adversarial questioning.',
    usefulPhrases: <String>[
      'Das lässt sich nur kontextabhängig beantworten.',
      'Hier liegt ein Zielkonflikt vor zwischen … und …',
      'Ich würde die Beweislast anders verteilen.',
      'Das wäre eine unzulässige Verallgemeinerung.',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman:
            'Rechtfertigt öffentliches Interesse jeden Vertrauensbruch?',
        tutorEnglish: 'Does public interest justify any breach of confidence?',
        task: 'Reject the absolute and set up the trade-off.',
        keywords: <String>[
          'zielkonflikt',
          'kontextabhängig',
          'abwägung',
          'keineswegs',
          'verhältnismäßig',
          'zwischen',
        ],
        requiredHits: 3,
        minWords: 26,
        modelAnswer:
            'Keineswegs. Hier liegt ein Zielkonflikt vor zwischen dem Schutz vertraulicher Beziehungen '
            'und dem Informationsanspruch der Öffentlichkeit; entscheidend ist eine Verhältnismäßigkeitsprüfung im Einzelfall.',
        modelAnswerEnglish:
            'By no means. There is a conflict of goals here between protecting confidential relationships '
            'and the public\'s claim to information; what matters is a proportionality assessment case by case.',
        quickReplies: <String>[
          'Hier liegt ein Zielkonflikt vor zwischen … und …',
        ],
        coachTip:
            'Naming the conflict of goals immediately signals analytical control.',
      ),
      DialogueStep(
        tutorGerman:
            'Das klingt bequem. Wer entscheidet denn über die Verhältnismäßigkeit?',
        tutorEnglish: 'That sounds convenient. Who decides on proportionality?',
        task: 'Answer the procedural question without retreating to vagueness.',
        keywords: <String>[
          'redaktion',
          'nachvollziehbar',
          'dokumentiert',
          'rechenschaft',
          'verfahren',
          'nachträglich',
        ],
        requiredHits: 3,
        minWords: 26,
        modelAnswer:
            'Zunächst die Redaktion, allerdings nicht willkürlich: Die Abwägung muss dokumentiert, begründet '
            'und nachträglich überprüfbar sein. Ohne Rechenschaftsverfahren bleibt jede Berufung auf öffentliches Interesse eine Behauptung.',
        modelAnswerEnglish:
            'The editorial team first, but not arbitrarily: the weighing must be documented, justified '
            'and reviewable afterwards. Without an accountability procedure, any appeal to public interest remains an assertion.',
        quickReplies: <String>[
          'Die Abwägung muss dokumentiert und überprüfbar sein.',
        ],
        coachTip:
            'Answer „who decides“ with a *procedure*, never with an institution alone.',
      ),
      DialogueStep(
        tutorGerman:
            'Kritiker sagen, Medienethik sei folgenlose Selbstberuhigung.',
        tutorEnglish:
            'Critics say media ethics is self-soothing without consequence.',
        task: 'Concede the partial truth, then rebut the generalisation.',
        keywords: <String>[
          'teilweise',
          'berechtigt',
          'unzulässige verallgemeinerung',
          'gleichwohl',
          'sanktion',
          'wirkung',
        ],
        requiredHits: 3,
        minWords: 26,
        modelAnswer:
            'Teilweise ist der Vorwurf berechtigt, sofern Selbstverpflichtungen ohne jede Sanktion bleiben. '
            'Als Pauschalurteil wäre er gleichwohl eine unzulässige Verallgemeinerung — dokumentierte Rügen entfalten durchaus Wirkung.',
        modelAnswerEnglish:
            'The reproach is partly justified insofar as self-commitments remain without any sanction. '
            'As a blanket judgement it would nevertheless be an inadmissible generalisation — documented reprimands do have an effect.',
        quickReplies: <String>[
          'Teilweise berechtigt, als Pauschalurteil aber …',
        ],
        coachTip:
            'Splitting a criticism into its valid and invalid halves is a signature C2 move.',
      ),
      DialogueStep(
        tutorGerman:
            'Angenommen, eine Quelle hätte gelogen. Wäre die Veröffentlichung dann falsch gewesen?',
        tutorEnglish:
            'Suppose a source had lied. Would publication then have been wrong?',
        task:
            'Distinguish outcome from decision quality using counterfactual language.',
        keywords: <String>[
          'ex ante',
          'im nachhinein',
          'sorgfalt',
          'ergebnis',
          'entscheidungsqualität',
          'hätte',
        ],
        requiredHits: 3,
        minWords: 26,
        modelAnswer:
            'Man muss die Entscheidungsqualität ex ante von der Ergebnisbewertung im Nachhinein trennen. '
            'Wäre die Sorgfaltspflicht erfüllt worden, bliebe die Entscheidung vertretbar, auch wenn sich das Ergebnis als falsch erwiesen hätte.',
        modelAnswerEnglish:
            'One must separate decision quality ex ante from evaluation of the outcome in hindsight. '
            'Had due diligence been fulfilled, the decision would remain defensible even if the outcome had proved wrong.',
        quickReplies: <String>[
          'Man muss die Entscheidungsqualität von der Ergebnisbewertung trennen.',
        ],
        coachTip:
            'Counterfactual past: „Wäre … erfüllt worden, bliebe …“ — Konjunktiv II in both halves.',
      ),
      DialogueStep(
        tutorGerman: 'Sie schützen damit auch schlechte Journalisten.',
        tutorEnglish: 'In doing so you also protect bad journalists.',
        task: 'Turn the objection into a distinction.',
        keywords: <String>[
          'im gegenteil',
          'maßstab',
          'gerade',
          'unterscheidet',
          'nachlässig',
          'anspruchsvoll',
        ],
        requiredHits: 3,
        minWords: 24,
        modelAnswer:
            'Im Gegenteil: Gerade dieser Maßstab unterscheidet sorgfältige von nachlässiger Arbeit. '
            'Wer die Prüfpflichten nicht erfüllt hat, kann sich auf ein unglückliches Ergebnis eben nicht berufen.',
        modelAnswerEnglish:
            'On the contrary: precisely this standard distinguishes careful from negligent work. '
            'Whoever has not met the verification duties cannot appeal to an unfortunate outcome.',
        quickReplies: <String>[
          'Im Gegenteil: gerade dieser Maßstab unterscheidet …',
        ],
        coachTip:
            '„Im Gegenteil“ plus „gerade“ reverses an objection into supporting evidence.',
      ),
      DialogueStep(
        tutorGerman: 'Zum Schluss: Was müsste sich ändern?',
        tutorEnglish: 'Finally: what would have to change?',
        task: 'Close with a precise, implementable demand.',
        keywords: <String>[
          'verbindlich',
          'offenlegen',
          'unabhängig',
          'wäre',
          'forderung',
          'transparent',
        ],
        requiredHits: 3,
        minWords: 22,
        modelAnswer:
            'Meine Forderung wäre schlicht: Redaktionen sollten ihre Abwägungskriterien verbindlich offenlegen '
            'und eine unabhängige Instanz sollte deren Anwendung stichprobenartig prüfen.',
        modelAnswerEnglish:
            'My demand would be simple: newsrooms should disclose their weighing criteria bindingly '
            'and an independent body should audit their application by sampling.',
        quickReplies: <String>['Meine Forderung wäre: …'],
        coachTip: 'End with one demand, not three — it is what gets quoted.',
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-c2-02',
    level: CefrLevel.c2,
    emoji: '🤝',
    title: 'Die diplomatische Absage',
    setting:
        'A long-standing partner asks you to join a project you consider flawed.',
    tutorRole: 'Projektpartnerin',
    learnerRole: 'Sie selbst',
    goal: 'Refuse decisively while preserving the relationship.',
    usefulPhrases: <String>[
      'Ich schätze das Vertrauen sehr, gleichwohl …',
      'Es wäre unredlich, Ihnen … zuzusagen.',
      'Was ich anbieten kann, wäre …',
      'Bitte verstehen Sie das nicht als Abwertung von …',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman:
            'Wir würden Sie gern als fachliche Leitung gewinnen. Was sagen Sie?',
        tutorEnglish:
            'We would love to win you as technical lead. What do you say?',
        task: 'Acknowledge the offer warmly before signalling reservation.',
        keywords: <String>[
          'schätze',
          'freut',
          'gleichwohl',
          'zunächst',
          'vertrauen',
          'offen',
        ],
        requiredHits: 3,
        minWords: 22,
        modelAnswer:
            'Das Angebot ehrt mich, und ich schätze das Vertrauen sehr. Gleichwohl möchte ich offen sein: '
            'Ich habe erhebliche Vorbehalte gegenüber der derzeitigen Anlage des Projekts.',
        modelAnswerEnglish:
            'The offer honours me and I greatly value the trust. Nevertheless I want to be open: '
            'I have considerable reservations about the current design of the project.',
        quickReplies: <String>['Ich schätze das Vertrauen sehr, gleichwohl …'],
        coachTip:
            'Warmth first, reservation second — reversing this reads as rejection of the person.',
      ),
      DialogueStep(
        tutorGerman:
            'Vorbehalte? Die Finanzierung steht doch, das Team ist erfahren.',
        tutorEnglish:
            'Reservations? The funding is secured, the team is experienced.',
        task:
            'Name the substantive objection precisely, without insulting anyone.',
        keywords: <String>[
          'weniger',
          'sondern',
          'zielsetzung',
          'methodisch',
          'zweifel',
          'operationalisierung',
        ],
        requiredHits: 3,
        minWords: 24,
        modelAnswer:
            'Meine Zweifel betreffen weniger die Ausstattung als die methodische Anlage: '
            'Die zentrale Zielgröße ist meines Erachtens nicht sauber operationalisiert, und darauf baut die gesamte Auswertung auf.',
        modelAnswerEnglish:
            'My doubts concern the resourcing less than the methodological design: '
            'the central target variable is in my view not cleanly operationalised, and the entire analysis builds on it.',
        quickReplies: <String>['Meine Zweifel betreffen weniger … als …'],
        coachTip:
            'Criticise the design, never the designers — the sentence structure does the diplomacy.',
      ),
      DialogueStep(
        tutorGerman: 'Das ließe sich unterwegs korrigieren, oder?',
        tutorEnglish: 'That could be corrected along the way, could it not?',
        task: 'Explain why not, using a hypothetical.',
        keywords: <String>[
          'erfahrungsgemäß',
          'nachträglich',
          'vergleichbar',
          'würde man',
          'wären',
          'neu beginnen',
          'daten',
        ],
        requiredHits: 3,
        minWords: 24,
        modelAnswer:
            'Erfahrungsgemäß eher nicht: Würde man die Zielgröße nachträglich ändern, wären die bereits erhobenen Daten '
            'nicht mehr vergleichbar. Man müsste faktisch neu beginnen.',
        modelAnswerEnglish:
            'In my experience rather not: were the target variable changed retrospectively, the data already collected '
            'would no longer be comparable. One would effectively have to start again.',
        quickReplies: <String>['Würde man … ändern, wären …'],
        coachTip:
            'Konjunktiv II without „wenn“ („Würde man …, wären …“) sounds measured, not alarmist.',
      ),
      DialogueStep(
        tutorGerman: 'Sie lassen uns also hängen.',
        tutorEnglish: 'So you are leaving us in the lurch.',
        task: 'Refuse the guilt frame and reaffirm the relationship.',
        keywords: <String>[
          'bitte verstehen',
          'nicht als',
          'im gegenteil',
          'gerade weil',
          'unredlich',
          'zusagen',
        ],
        requiredHits: 3,
        minWords: 24,
        modelAnswer:
            'Bitte verstehen Sie das nicht als Abwertung Ihrer Arbeit — im Gegenteil. '
            'Gerade weil mir die Zusammenarbeit wichtig ist, wäre es unredlich, Ihnen eine Leitung zuzusagen, die ich fachlich nicht verantworten kann.',
        modelAnswerEnglish:
            'Please do not understand this as a devaluation of your work — quite the opposite. '
            'Precisely because the collaboration matters to me, it would be dishonest to promise you a leadership role I cannot professionally answer for.',
        quickReplies: <String>[
          'Gerade weil mir die Zusammenarbeit wichtig ist, wäre es unredlich, …',
        ],
        coachTip:
            '„Gerade weil …“ converts the accusation of disloyalty into evidence of loyalty.',
      ),
      DialogueStep(
        tutorGerman: 'Und wenn wir das Design vorher überarbeiten?',
        tutorEnglish: 'And if we revise the design beforehand?',
        task: 'Offer a bounded, concrete alternative contribution.',
        keywords: <String>[
          'anbieten',
          'beratend',
          'begrenzt',
          'workshop',
          'zur verfügung',
          'ohne',
        ],
        requiredHits: 3,
        minWords: 22,
        modelAnswer:
            'Was ich anbieten kann, wäre eine klar begrenzte beratende Rolle: '
            'ein zweitägiger Methodenworkshop und eine schriftliche Stellungnahme, ohne Leitungsverantwortung.',
        modelAnswerEnglish:
            'What I can offer would be a clearly limited advisory role: '
            'a two-day methods workshop and a written opinion, without leadership responsibility.',
        quickReplies: <String>['Was ich anbieten kann, wäre …'],
        coachTip:
            'A refusal that comes with a smaller yes is remembered as generosity.',
      ),
      DialogueStep(
        tutorGerman: 'Damit wäre uns tatsächlich geholfen.',
        tutorEnglish: 'That would actually help us.',
        task: 'Close warmly and fix the next step.',
        keywords: <String>[
          'freut',
          'schicke',
          'freitag',
          'termin',
          'melde',
          'skizze',
          'gern',
        ],
        requiredHits: 2,
        minWords: 18,
        modelAnswer:
            'Das freut mich aufrichtig. Ich schicke Ihnen bis Freitag zwei Terminvorschläge '
            'und eine kurze Skizze dessen, was der Workshop leisten kann.',
        modelAnswerEnglish:
            'That genuinely pleases me. I will send you two proposed dates by Friday '
            'and a short outline of what the workshop can achieve.',
        quickReplies: <String>[
          'Ich schicke Ihnen bis Freitag zwei Terminvorschläge.',
        ],
        coachTip: 'Attach a date to every goodwill offer, or it evaporates.',
      ),
    ],
  ),
];

const int storyInterviewTarget = 37;

final List<ConversationScenario> _storyInterviewScenarios = expandedStories
    .take(storyInterviewTarget)
    .map<ConversationScenario>(_storyInterview)
    .toList(growable: false);

ConversationScenario _storyInterview(Story story) {
  final StoryChapter opening = story.chapters.first;
  final StoryChapter turningPoint = story.chapters[story.chapters.length ~/ 2];
  final StoryChapter ending = story.chapters.last;
  return ConversationScenario(
    id: 'cv-story-${story.id.substring(3)}',
    level: story.level,
    emoji: story.emoji,
    title: 'Story interview: ${story.title}',
    setting: 'A guided oral retelling after reading ${story.title}.',
    tutorRole: 'Interviewer',
    learnerRole: 'Storyteller',
    // The model answer for these turns is the chapter itself, so the goal
    // must not tell the learner the transcript is off-limits and then show
    // it back to them under the heading Model answer. Retelling from memory
    // is still the exercise; the passage is the thing to compare against
    // afterwards, which is what a graded reader is for.
    goal: 'Retell the central events from memory, then compare with the '
        'passage.',
    usefulPhrases: _retellPhrases(story.level),
    steps: <DialogueStep>[
      _interviewStep(
        tutorGerman: 'Wer handelt in der Geschichte, und wie beginnt sie?',
        tutorEnglish: 'Who acts in the story, and how does it begin?',
        task: 'Introduce the people and the starting situation.',
        chapter: opening,
        coachTip: 'Name the person and place before you describe the event.',
      ),
      _interviewStep(
        tutorGerman: 'Was verändert die Situation oder verursacht das Problem?',
        tutorEnglish: 'What changes the situation or causes the problem?',
        task: 'Explain the central complication and the response to it.',
        chapter: turningPoint,
        coachTip: 'Use a cause connector such as weil, deshalb or sodass.',
      ),
      _interviewStep(
        tutorGerman: 'Wie endet die Geschichte, und was ist daran wichtig?',
        tutorEnglish: 'How does the story end, and what is important about it?',
        task: 'Give the outcome and one concluding observation.',
        chapter: ending,
        coachTip: 'Close with schließlich, am Ende or im Rückblick.',
      ),
    ],
  );
}

DialogueStep _interviewStep({
  required String tutorGerman,
  required String tutorEnglish,
  required String task,
  required StoryChapter chapter,
  required String coachTip,
}) {
  final String modelGerman = chapter.lines
      .map((StoryLine line) => line.german)
      .join(' ');
  final String modelEnglish = chapter.lines
      .map((StoryLine line) => line.english)
      .join(' ');
  return DialogueStep(
    tutorGerman: tutorGerman,
    tutorEnglish: tutorEnglish,
    task: task,
    keywords: _spokenKeywords(modelGerman),
    modelAnswer: modelGerman,
    modelAnswerEnglish: modelEnglish,
    quickReplies: <String>[chapter.lines.first.german],
    coachTip: coachTip,
    minWords: 10,
  );
}

List<String> _spokenKeywords(String text) {
  const Set<String> stop = <String>{
    'aber',
    'alle',
    'auch',
    'dann',
    'dass',
    'diese',
    'einem',
    'einen',
    'einer',
    'hatte',
    'haben',
    'nicht',
    'noch',
    'oder',
    'seine',
    'sich',
    'über',
    'unter',
    'wurde',
    'waren',
    'weil',
    'wieder',
  };
  final List<String> words = <String>[];
  for (final Match match in RegExp(r'[A-Za-zÄÖÜäöüß]{5,}').allMatches(text)) {
    final String word = match.group(0)!.toLowerCase();
    if (!stop.contains(word) && !words.contains(word)) words.add(word);
    if (words.length == 6) break;
  }
  return words;
}

List<String> _retellPhrases(CefrLevel level) => switch (level) {
  CefrLevel.a1 => <String>['Am Anfang …', 'Dann …', 'Am Ende …'],
  CefrLevel.a2 => <String>['Zuerst …', 'Weil …', 'Deshalb …'],
  CefrLevel.b1 => <String>['Nachdem …', 'Daraufhin …', 'Schließlich …'],
  CefrLevel.b2 => <String>['Zunächst …', 'Allerdings …', 'Im Ergebnis …'],
  CefrLevel.c1 => <String>[
    'Ausschlaggebend war …',
    'Daraus ergab sich …',
    'Im Rückblick …',
  ],
  CefrLevel.c2 => <String>[
    'Die Spannung bestand darin, dass …',
    'Demgegenüber …',
    'Letztlich erwies sich …',
  ],
};

final List<ConversationScenario> conversationScenarios = <ConversationScenario>[
  ..._foundationScenarios,
  ..._independentScenarios,
  ..._advancedScenarios,
  ...extraScenarios,
  ..._storyInterviewScenarios,
];

List<ConversationScenario> conversationsFor(CefrLevel level) =>
    conversationScenarios
        .where((scenario) => scenario.level == level)
        .toList(growable: false);

ConversationScenario? conversationById(String id) {
  for (final ConversationScenario scenario in conversationScenarios) {
    if (scenario.id == id) return scenario;
  }
  return null;
}

const List<FreeTalkPrompt> freeTalkPrompts = <FreeTalkPrompt>[
  FreeTalkPrompt(
    id: 'ft-a1-01',
    level: CefrLevel.a1,
    question: 'Erzähl mir von deiner Familie.',
    questionEnglish: 'Tell me about your family.',
    expectedPoints: <String>[
      'Wer gehört dazu',
      'Wo sie wohnen',
      'Was sie machen',
    ],
    usefulConnectors: <String>['und', 'auch', 'aber'],
    targetSeconds: 40,
    targetWords: 30,
    modelAnswer:
        'Meine Familie ist nicht sehr groß. Ich habe eine Schwester und einen Bruder. '
        'Meine Eltern wohnen in Indien. Mein Bruder arbeitet als Lehrer und meine Schwester studiert Medizin. '
        'Wir telefonieren jeden Sonntag.',
  ),
  FreeTalkPrompt(
    id: 'ft-a1-02',
    level: CefrLevel.a1,
    question: 'Was machst du normalerweise am Wochenende?',
    questionEnglish: 'What do you usually do at the weekend?',
    expectedPoints: <String>['Samstag', 'Sonntag', 'Mit wem'],
    usefulConnectors: <String>['dann', 'danach', 'meistens'],
    targetSeconds: 40,
    targetWords: 30,
    modelAnswer:
        'Am Samstag stehe ich spät auf. Dann gehe ich einkaufen und koche etwas. '
        'Am Nachmittag treffe ich meistens Freunde im Park. Am Sonntag lerne ich Deutsch und rufe meine Familie an.',
  ),
  FreeTalkPrompt(
    id: 'ft-a2-01',
    level: CefrLevel.a2,
    question: 'Beschreibe deinen letzten Urlaub. Was hast du gemacht?',
    questionEnglish: 'Describe your last holiday. What did you do?',
    expectedPoints: <String>['Wohin', 'Mit wem', 'Was gemacht', 'Wie war es'],
    usefulConnectors: <String>['zuerst', 'danach', 'am besten', 'weil'],
    targetSeconds: 60,
    targetWords: 55,
    modelAnswer:
        'Letztes Jahr bin ich mit einem Freund nach Hamburg gefahren. Wir sind drei Tage geblieben. '
        'Zuerst haben wir den Hafen besichtigt, danach sind wir durch die Speicherstadt gelaufen. '
        'Am besten hat mir das Essen gefallen, weil es überall frischen Fisch gab. '
        'Leider hat es am letzten Tag geregnet.',
  ),
  FreeTalkPrompt(
    id: 'ft-a2-02',
    level: CefrLevel.a2,
    question: 'Was ist dir bei einer Wohnung wichtig — und warum?',
    questionEnglish: 'What matters to you in a flat — and why?',
    expectedPoints: <String>['Lage', 'Preis', 'Zimmer', 'Begründung'],
    usefulConnectors: <String>['weil', 'außerdem', 'am wichtigsten', 'deshalb'],
    targetSeconds: 60,
    targetWords: 55,
    modelAnswer:
        'Am wichtigsten ist mir die Lage, weil ich ohne Auto lebe und zur Arbeit laufen möchte. '
        'Außerdem soll die Wohnung hell sein, denn ich arbeite oft zu Hause. '
        'Der Preis ist natürlich auch wichtig; deshalb suche ich etwas unter siebenhundert Euro warm.',
  ),
  FreeTalkPrompt(
    id: 'ft-b1-01',
    level: CefrLevel.b1,
    question: 'Sollten Schulen Handys verbieten? Begründe deine Meinung.',
    questionEnglish: 'Should schools ban mobile phones? Justify your opinion.',
    expectedPoints: <String>[
      'Eigene Position',
      'Zwei Argumente',
      'Gegenargument',
      'Fazit',
    ],
    usefulConnectors: <String>[
      'meiner Meinung nach',
      'einerseits',
      'andererseits',
      'trotzdem',
      'zusammenfassend',
    ],
    targetSeconds: 90,
    targetWords: 90,
    modelAnswer:
        'Meiner Meinung nach ist ein vollständiges Verbot nicht sinnvoll. Einerseits lenken Handys im Unterricht stark ab, '
        'und viele Lehrkräfte berichten über Konflikte. Andererseits gehören digitale Geräte inzwischen zum Alltag, '
        'und die Schule sollte den verantwortungsvollen Umgang damit vermitteln. '
        'Man könnte die Nutzung im Unterricht klar regeln und in den Pausen erlauben. '
        'Zusammenfassend halte ich klare Regeln für wirksamer als ein Verbot.',
  ),
  FreeTalkPrompt(
    id: 'ft-b1-02',
    level: CefrLevel.b1,
    question: 'Erzähl von einem Problem, das du selbst gelöst hast.',
    questionEnglish: 'Tell me about a problem you solved yourself.',
    expectedPoints: <String>['Situation', 'Problem', 'Lösung', 'Ergebnis'],
    usefulConnectors: <String>['als', 'zunächst', 'schließlich', 'dadurch'],
    targetSeconds: 90,
    targetWords: 90,
    modelAnswer:
        'Als ich neu in Deutschland war, habe ich keinen Termin beim Bürgeramt bekommen. '
        'Zunächst habe ich jeden Tag online geschaut, aber alle Termine waren belegt. '
        'Schließlich bin ich früh morgens hingegangen und habe nach einem Notfalltermin gefragt. '
        'Die Mitarbeiterin hat mir einen Platz am selben Tag gegeben. '
        'Dadurch konnte ich die Frist einhalten und mich rechtzeitig anmelden.',
  ),
  FreeTalkPrompt(
    id: 'ft-b2-01',
    level: CefrLevel.b2,
    question:
        'Wie verändert Automatisierung die Arbeitswelt? Argumentiere differenziert.',
    questionEnglish:
        'How is automation changing the world of work? Argue in a differentiated way.',
    expectedPoints: <String>[
      'These',
      'Zwei Belege',
      'Einschränkung',
      'Schlussfolgerung',
    ],
    usefulConnectors: <String>[
      'zwar … aber',
      'allerdings',
      'darüber hinaus',
      'folglich',
      'im Gegensatz dazu',
    ],
    targetSeconds: 120,
    targetWords: 130,
    modelAnswer:
        'Automatisierung verändert Tätigkeiten stärker als ganze Berufe. Zwar fallen einzelne Routineaufgaben weg, '
        'allerdings entstehen zugleich neue Anforderungen an Überwachung, Wartung und Datenauswertung. '
        'Darüber hinaus verschiebt sich der Wert von Wissen hin zu Urteilsfähigkeit: Wer Ergebnisse einordnen kann, '
        'bleibt gefragt. Im Gegensatz zu häufigen Prognosen zeigt die bisherige Entwicklung eher eine Verschiebung '
        'als einen Wegfall von Beschäftigung. Folglich hängt viel davon ab, ob Weiterbildung früh genug ansetzt.',
  ),
  FreeTalkPrompt(
    id: 'ft-c1-01',
    level: CefrLevel.c1,
    question: 'Inwiefern lässt sich Bildungsgerechtigkeit überhaupt messen?',
    questionEnglish:
        'To what extent can educational equity be measured at all?',
    expectedPoints: <String>[
      'Begriffsklärung',
      'Messprobleme',
      'Beispiel',
      'Abwägung',
      'Position',
    ],
    usefulConnectors: <String>[
      'zunächst',
      'insofern',
      'gleichwohl',
      'demgegenüber',
      'letztlich',
    ],
    targetSeconds: 150,
    targetWords: 170,
    modelAnswer:
        'Zunächst wäre zu klären, was gemeint ist: Chancengleichheit beim Zugang oder Ergebnisgleichheit am Ende. '
        'Beides führt zu völlig unterschiedlichen Indikatoren. Insofern ist die Messfrage bereits eine normative Frage. '
        'Üblich sind Übergangsquoten und Kompetenztests; gleichwohl erfassen sie nur, was operationalisiert wurde, '
        'und blenden etwa familiäre Unterstützung weitgehend aus. Demgegenüber erfassen qualitative Verfahren mehr Kontext, '
        'sind aber schlechter vergleichbar. Letztlich halte ich eine Kombination für unvermeidlich: '
        'quantitative Indikatoren zur Beobachtung von Trends, qualitative Studien zur Erklärung ihrer Ursachen.',
  ),
  FreeTalkPrompt(
    id: 'ft-c2-01',
    level: CefrLevel.c2,
    question:
        'Ist Objektivität in der Berichterstattung ein erreichbares Ziel oder eine nützliche Fiktion?',
    questionEnglish:
        'Is objectivity in reporting an achievable goal or a useful fiction?',
    expectedPoints: <String>[
      'Begriffliche Präzisierung',
      'Stärkste Gegenposition',
      'Eigene Abwägung',
      'Konsequenz',
    ],
    usefulConnectors: <String>[
      'man müsste unterscheiden',
      'zugestandenermaßen',
      'gleichwohl',
      'daraus folgt nicht',
      'vielmehr',
    ],
    targetSeconds: 180,
    targetWords: 210,
    modelAnswer:
        'Man müsste zunächst zwischen Objektivität als Zustand und als regulativer Idee unterscheiden. '
        'Als Zustand ist sie unerreichbar: Jede Auswahl von Themen, Quellen und Formulierungen ist bereits eine Entscheidung. '
        'Zugestandenermaßen trifft der Einwand, Objektivität verschleiere Interessen, einen realen Punkt. '
        'Daraus folgt gleichwohl nicht, dass der Begriff verzichtbar wäre. Vielmehr fungiert er als Maßstab, '
        'an dem sich Verfahren prüfen lassen: Offenlegung von Quellen, Trennung von Nachricht und Kommentar, '
        'Korrekturpraxis. Verzichtete man auf diesen Maßstab, verlöre man das Kriterium, mit dem sich sorgfältige '
        'von interessengeleiteter Darstellung unterscheiden lässt. Insofern wäre Objektivität weniger als erreichbarer '
        'Zustand denn als überprüfbare Verfahrensanforderung zu verstehen.',
  ),
  FreeTalkPrompt(
    id: 'ft-b2-02',
    level: CefrLevel.b2,
    question: 'Sollte der Staat kostenlosen öffentlichen Nahverkehr anbieten?',
    questionEnglish: 'Should the state offer free public transport?',
    expectedPoints: <String>[
      'Position',
      'Kosten',
      'Wirkung',
      'Einwand',
      'Fazit',
    ],
    usefulConnectors: <String>[
      'grundsätzlich',
      'allerdings',
      'hinzu kommt',
      'demgegenüber',
      'unter dem Strich',
    ],
    targetSeconds: 120,
    targetWords: 130,
    modelAnswer:
        'Grundsätzlich halte ich den Gedanken für sympathisch, die Umsetzung jedoch für schwieriger als oft dargestellt. '
        'Kostenlose Angebote erhöhen zwar die Nachfrage, allerdings nutzt das wenig, wenn Takt und Kapazität gleich bleiben. '
        'Hinzu kommt, dass die Finanzierung an anderer Stelle fehlt, etwa beim Netzausbau. '
        'Demgegenüber zeigen Erfahrungen aus einzelnen Städten durchaus positive Effekte auf die Verkehrsverlagerung. '
        'Unter dem Strich erschiene mir ein günstiges, aber nicht kostenloses Ticket bei gleichzeitigem Ausbau wirksamer.',
  ),
  FreeTalkPrompt(
    id: 'ft-c1-02',
    level: CefrLevel.c1,
    question:
        'Welche Rolle sollte Fachwissen in politischen Entscheidungen spielen?',
    questionEnglish: 'What role should expertise play in political decisions?',
    expectedPoints: <String>[
      'Unterscheidung',
      'Grenzen der Expertise',
      'Legitimation',
      'Beispiel',
      'Position',
    ],
    usefulConnectors: <String>[
      'zum einen',
      'zum anderen',
      'insofern',
      'gleichwohl',
      'daraus ergibt sich',
    ],
    targetSeconds: 150,
    targetWords: 170,
    modelAnswer:
        'Zu unterscheiden wäre zwischen der Beschreibung von Sachverhalten und der Bewertung von Zielen. '
        'Zum einen kann Fachwissen präzisieren, welche Folgen eine Maßnahme voraussichtlich hat; '
        'zum anderen kann es nicht bestimmen, welche Folgen wir für wünschenswert halten. '
        'Insofern ersetzt Expertise keine demokratische Legitimation, sondern strukturiert den Möglichkeitsraum. '
        'Gleichwohl wäre es fahrlässig, verfügbares Wissen zu ignorieren, wie sich in der Pandemieplanung gezeigt hat. '
        'Daraus ergibt sich für mich eine klare Arbeitsteilung: Fachleute liefern Prognosen und Unsicherheitsangaben, '
        'gewählte Gremien entscheiden über Abwägungen und tragen dafür die Verantwortung.',
  ),
  FreeTalkPrompt(
    id: 'ft-c2-02',
    level: CefrLevel.c2,
    question:
        'Lässt sich moralischer Fortschritt sinnvoll behaupten, oder ist das nur Selbstbeschreibung der Gegenwart?',
    questionEnglish:
        'Can moral progress be meaningfully claimed, or is it merely the present describing itself?',
    expectedPoints: <String>[
      'Problemstellung',
      'Stärkste Gegenposition',
      'Kriterium',
      'Abwägung',
      'Konsequenz',
    ],
    usefulConnectors: <String>[
      'zunächst wäre einzuwenden',
      'zugestandenermaßen',
      'gleichwohl',
      'vielmehr',
      'letztlich',
    ],
    targetSeconds: 180,
    targetWords: 210,
    modelAnswer:
        'Zunächst wäre einzuwenden, dass jede Fortschrittsbehauptung einen Maßstab voraussetzt, '
        'der selbst historisch entstanden ist. Zugestandenermaßen droht damit ein Zirkel: '
        'Wir messen die Vergangenheit an Normen, die wir für richtig halten, und stellen erwartungsgemäß Fortschritt fest. '
        'Gleichwohl folgt daraus kein vollständiger Relativismus. Vielmehr lassen sich schwächere, aber tragfähige Kriterien angeben, '
        'etwa die Ausweitung des Kreises derer, deren Interessen überhaupt zählen, oder die Verringerung vermeidbaren Leidens. '
        'Solche Kriterien sind nicht neutral, aber sie sind begründungsfähig und lassen sich kritisieren. '
        'Letztlich erschiene mir die vorsichtigere Formulierung angemessen: Nicht die Geschichte schreitet fort, '
        'sondern einzelne Institutionen werden gegenüber bestimmten Formen von Willkür widerstandsfähiger.',
  ),
];

List<FreeTalkPrompt> freeTalkFor(CefrLevel level) => freeTalkPrompts
    .where((prompt) => prompt.level == level)
    .toList(growable: false);
