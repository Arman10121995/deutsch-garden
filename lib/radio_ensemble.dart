/// Radio episodes written for more than one speaker.
///
/// The rest of the library is very largely one voice reading to you, which is
/// what a bulletin or a diary entry actually is. That was fine while there
/// were two bundled voices and only one of them ever got used for a
/// programme; with five it wastes the thing that makes a conversation
/// listenable — being able to tell who is talking without being told.
///
/// So these are deliberately ensemble pieces: an interview at two voices, a
/// panel at three, a family scene at four, a phone-in at five. Each one is
/// written so the speakers are distinguishable by *content* as well as by
/// voice — a learner who cannot yet hear the difference between two
/// synthesised speakers can still follow who is who from what they say, which
/// is the honest fallback on a device whose engine has only one German voice.
///
/// Ids continue each level's existing sequence, so nothing already recorded
/// against an episode moves.
library;

import 'models.dart';
import 'radio_models.dart';

const List<RadioEpisode> radioEnsembleEpisodes = <RadioEpisode>[
  // ---------------------------------------------------------------- two
  RadioEpisode(
    id: 'rd-a1-31',
    level: CefrLevel.a1,
    genre: RadioGenre.news,
    title: 'Zwei Stimmen: Im Café',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Tag! Willkommen im Gartenradio.',
        english: 'Good afternoon! Welcome to Garden Radio.',
      ),
      RadioLine(
        german: 'Heute bin ich im Café am Markt. Neben mir sitzt Frau Weber.',
        english: 'Today I am in the café by the market. Mrs Weber is sitting '
            'next to me.',
      ),
      RadioLine(
        german: 'Guten Tag! Ich heiße Anna Weber.',
        english: 'Good afternoon! My name is Anna Weber.',
        voice: RadioVoice.guest,
      ),
      RadioLine(
        german: 'Frau Weber, was trinken Sie gern?',
        english: 'Mrs Weber, what do you like to drink?',
      ),
      RadioLine(
        german: 'Ich trinke jeden Morgen einen Kaffee mit Milch.',
        english: 'I drink a coffee with milk every morning.',
        voice: RadioVoice.guest,
      ),
      RadioLine(
        german: 'Und was essen Sie dazu?',
        english: 'And what do you eat with it?',
      ),
      RadioLine(
        german: 'Meistens ein Brötchen. Manchmal auch einen Kuchen.',
        english: 'Usually a bread roll. Sometimes a cake as well.',
        voice: RadioVoice.guest,
      ),
      RadioLine(
        german: 'Vielen Dank, Frau Weber. Schönen Tag noch!',
        english: 'Thank you very much, Mrs Weber. Have a nice day!',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wer ist der Gast?',
        options: <String>['Anna Weber', 'Anna Schmidt', 'Eva Weber'],
        correctIndex: 0,
        explanation: 'Sie sagt: „Ich heiße Anna Weber.“',
      ),
      ChoiceQuestion(
        prompt: 'Was trinkt Frau Weber jeden Morgen?',
        options: <String>['Kaffee mit Milch', 'Tee mit Zucker', 'Nur Wasser'],
        correctIndex: 0,
        explanation: 'Sie trinkt jeden Morgen einen Kaffee mit Milch.',
      ),
      ChoiceQuestion(
        prompt: 'Was isst sie meistens dazu?',
        options: <String>['Ein Brötchen', 'Einen Apfel', 'Eine Suppe'],
        correctIndex: 0,
        explanation: 'Meistens ein Brötchen, manchmal auch einen Kuchen.',
      ),
    ],
  ),

  // -------------------------------------------------------------- three
  RadioEpisode(
    id: 'rd-a2-31',
    level: CefrLevel.a2,
    genre: RadioGenre.lecture,
    title: 'Drei Stimmen: Wie kommst du zur Arbeit?',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen zur Runde. Heute geht es um den Weg zur Arbeit.',
        english: 'Welcome to the discussion. Today it is about the journey to '
            'work.',
      ),
      RadioLine(
        german: 'Ich habe zwei Gäste im Studio: Herrn Baumann und Frau Kern.',
        english: 'I have two guests in the studio: Mr Baumann and Mrs Kern.',
      ),
      RadioLine(
        german: 'Hallo! Ich fahre jeden Tag mit dem Fahrrad.',
        english: 'Hello! I cycle every day.',
        voice: RadioVoice.guest,
      ),
      RadioLine(
        german: 'Und ich nehme immer die Straßenbahn. Das dauert zwanzig '
            'Minuten.',
        english: 'And I always take the tram. That takes twenty minutes.',
        voice: RadioVoice.guestTwo,
      ),
      RadioLine(
        german: 'Herr Baumann, wie weit ist Ihr Weg?',
        english: 'Mr Baumann, how far is your journey?',
      ),
      RadioLine(
        german: 'Ungefähr sechs Kilometer. Bei Regen wird es unangenehm.',
        english: 'About six kilometres. In the rain it becomes unpleasant.',
        voice: RadioVoice.guest,
      ),
      RadioLine(
        german: 'Bei Regen ist die Straßenbahn wirklich besser.',
        english: 'In the rain the tram really is better.',
        voice: RadioVoice.guestTwo,
      ),
      RadioLine(
        german: 'Da sind sich beide einig. Vielen Dank Ihnen beiden!',
        english: 'On that they both agree. Many thanks to you both!',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie fährt Herr Baumann zur Arbeit?',
        options: <String>['Mit dem Fahrrad', 'Mit der Straßenbahn',
            'Mit dem Auto'],
        correctIndex: 0,
        explanation: 'Er sagt: „Ich fahre jeden Tag mit dem Fahrrad.“',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange dauert die Fahrt von Frau Kern?',
        options: <String>['Zwanzig Minuten', 'Zehn Minuten', 'Eine Stunde'],
        correctIndex: 0,
        explanation: 'Die Straßenbahn dauert zwanzig Minuten.',
      ),
      ChoiceQuestion(
        prompt: 'Worin sind sich beide Gäste einig?',
        options: <String>[
          'Bei Regen ist die Straßenbahn besser',
          'Das Fahrrad ist immer schneller',
          'Der Weg dauert zu lange',
        ],
        correctIndex: 0,
        explanation: 'Beide sagen, bei Regen sei die Straßenbahn besser.',
      ),
    ],
  ),

  // --------------------------------------------------------------- four
  RadioEpisode(
    id: 'rd-b1-26',
    level: CefrLevel.b1,
    genre: RadioGenre.diary,
    title: 'Vier Stimmen: Der Umzug',
    lines: <RadioLine>[
      RadioLine(
        german: 'In unserer Reihe „Familienleben“ hören Sie heute eine '
            'Familie beim Umzug.',
        english: 'In our series "Family life" you hear a family moving house '
            'today.',
      ),
      RadioLine(
        german: 'Wir hören Sabine, ihren Mann Jonas und die Tochter Lea.',
        english: 'We hear Sabine, her husband Jonas and their daughter Lea.',
      ),
      RadioLine(
        german: 'Die Kartons stehen alle im Flur. Jonas, wer trägt sie nach '
            'unten?',
        english: 'The boxes are all in the hallway. Jonas, who is carrying '
            'them down?',
        voice: RadioVoice.guest,
      ),
      RadioLine(
        german: 'Ich nehme die schweren, Sabine. Du kümmerst dich um die '
            'Küche.',
        english: 'I will take the heavy ones, Sabine. You look after the '
            'kitchen.',
        voice: RadioVoice.guestTwo,
      ),
      RadioLine(
        german: 'Und ich? Ich bin Lea und ich möchte auch helfen!',
        english: 'And me? I am Lea and I want to help too!',
        voice: RadioVoice.guestThree,
      ),
      RadioLine(
        german: 'Lea, du kannst die Bücher einpacken. Aber vorsichtig, bitte.',
        english: 'Lea, you can pack the books. But carefully, please.',
        voice: RadioVoice.guest,
      ),
      RadioLine(
        german: 'Sabine, wo ist eigentlich der Schlüssel für die neue '
            'Wohnung?',
        english: 'Sabine, where actually is the key for the new flat?',
        voice: RadioVoice.guestTwo,
      ),
      RadioLine(
        german: 'In meiner Jacke, Jonas. Ich habe ihn gestern vom Vermieter '
            'geholt.',
        english: 'In my jacket, Jonas. I collected it from the landlord '
            'yesterday.',
        voice: RadioVoice.guest,
      ),
      RadioLine(
        german: 'Dann können wir losfahren!',
        english: 'Then we can set off!',
        voice: RadioVoice.guestThree,
      ),
      RadioLine(
        german: 'Drei Stunden später war die Wohnung leer.',
        english: 'Three hours later the flat was empty.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wer trägt die schweren Kartons?',
        options: <String>[
          'Die zweite Person',
          'Das Kind',
          'Der Vermieter',
        ],
        correctIndex: 0,
        explanation: 'Sie sagt: „Ich nehme die schweren.“',
      ),
      ChoiceQuestion(
        prompt: 'Was soll das Kind machen?',
        options: <String>['Die Bücher einpacken', 'Die Küche putzen',
            'Den Schlüssel holen'],
        correctIndex: 0,
        explanation: '„Du kannst die Bücher einpacken.“',
      ),
      ChoiceQuestion(
        prompt: 'Wo ist der Schlüssel für die neue Wohnung?',
        options: <String>['In der Jacke', 'In der Küche', 'Beim Vermieter'],
        correctIndex: 0,
        explanation: 'Der Schlüssel liegt in der Jacke.',
      ),
    ],
  ),

  // --------------------------------------------------------------- five
  RadioEpisode(
    id: 'rd-b2-21',
    level: CefrLevel.b2,
    genre: RadioGenre.news,
    title: 'Fünf Stimmen: Die Hörerrunde',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Abend. In der Hörerrunde geht es heute um die Frage, '
            'ob Innenstädte autofrei werden sollten.',
        english: 'Good evening. In tonight\'s listener round the question is '
            'whether city centres should become car-free.',
      ),
      RadioLine(
        german: 'Im Studio begrüße ich eine Verkehrsplanerin, einen '
            'Ladenbesitzer und eine Ärztin. Am Telefon ist ein Hörer.',
        english: 'In the studio I welcome a transport planner, a shop owner '
            'and a doctor. A listener is on the phone.',
      ),
      RadioLine(
        german: 'Weniger Autos bedeuten weniger Lärm und sauberere Luft. Die '
            'Zahlen sind eindeutig.',
        english: 'Fewer cars mean less noise and cleaner air. The figures are '
            'unambiguous.',
        voice: RadioVoice.guest,
      ),
      RadioLine(
        german: 'Für mich ist das nicht so einfach. Meine Kunden kommen mit '
            'dem Auto und tragen schwere Taschen.',
        english: 'For me it is not that simple. My customers come by car and '
            'carry heavy bags.',
        voice: RadioVoice.guestTwo,
      ),
      RadioLine(
        german: 'In der Notaufnahme sehen wir jeden Monat Unfälle, die in '
            'einer ruhigen Straße nicht passiert wären.',
        english: 'In the emergency department we see accidents every month '
            'that would not have happened on a quiet street.',
        voice: RadioVoice.guestThree,
      ),
      RadioLine(
        german: 'Guten Abend, ich rufe aus einem Dorf an. Ohne Auto komme ich '
            'überhaupt nicht in die Stadt.',
        english: 'Good evening, I am calling from a village. Without a car I '
            'cannot get into the city at all.',
        voice: RadioVoice.caller,
      ),
      RadioLine(
        german: 'Das ist genau der Punkt: Eine autofreie Innenstadt braucht '
            'zuerst gute Busse und Bahnen.',
        english: 'That is exactly the point: a car-free city centre needs '
            'good buses and trains first.',
        voice: RadioVoice.guest,
      ),
      RadioLine(
        german: 'Damit könnte ich leben, wenn die Lieferungen weiter möglich '
            'bleiben.',
        english: 'I could live with that, as long as deliveries remain '
            'possible.',
        voice: RadioVoice.guestTwo,
      ),
      RadioLine(
        german: 'Vier Meinungen, ein gemeinsamer Nenner. Vielen Dank für '
            'Ihre Anrufe.',
        english: 'Four opinions, one common denominator. Thank you for your '
            'calls.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Worum geht es in der Sendung?',
        options: <String>[
          'Ob Innenstädte autofrei werden sollten',
          'Ob Busse teurer werden sollten',
          'Ob Läden länger öffnen sollten',
        ],
        correctIndex: 0,
        explanation: 'Die Frage ist, ob Innenstädte autofrei werden sollten.',
      ),
      ChoiceQuestion(
        prompt: 'Welches Bedenken nennt der Ladenbesitzer?',
        options: <String>[
          'Seine Kunden kommen mit dem Auto',
          'Die Miete ist zu hoch',
          'Er findet keine Mitarbeiter',
        ],
        correctIndex: 0,
        explanation: 'Seine Kunden kommen mit dem Auto und tragen schwere '
            'Taschen.',
      ),
      ChoiceQuestion(
        prompt: 'Woher ruft der Hörer an?',
        options: <String>['Aus einem Dorf', 'Aus der Innenstadt',
            'Aus dem Krankenhaus'],
        correctIndex: 0,
        explanation: 'Er sagt: „Ich rufe aus einem Dorf an.“',
      ),
      ChoiceQuestion(
        prompt: 'Worauf einigen sich die Gäste am Ende?',
        options: <String>[
          'Zuerst braucht es gute Busse und Bahnen',
          'Autos sollen sofort verboten werden',
          'Die Innenstadt soll unverändert bleiben',
        ],
        correctIndex: 0,
        explanation: 'Eine autofreie Innenstadt braucht zuerst guten '
            'Nahverkehr.',
      ),
    ],
  ),
];
