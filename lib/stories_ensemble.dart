/// Stories written as scenes rather than as narration.
///
/// Measured on the existing corpus, only 13.5% of story lines contain any
/// direct speech, so `storySpokenTurns` — which gives a character voice only
/// to text inside German quotation marks — leaves most chapters read entirely
/// by the narrator. That is correct for the text: a narrated story is
/// narrated. It also means five bundled voices went almost unused.
///
/// These four are the other kind of story. Each is built around a scene with
/// people talking, so a chapter is read by the narrator *and* its cast: two
/// voices, then three, four and five. The narration between lines is kept
/// deliberately short — enough to say who moved and where, not enough to
/// swallow the dialogue.
///
/// Speakers are named in the prose as well as separated by voice. On a phone
/// whose engine offers one German voice, pitch is all that distinguishes
/// them, and a learner who cannot yet hear that difference still has to be
/// able to follow who is speaking.
library;

import 'models.dart';
import 'stories.dart';
import 'tts_service.dart';

const List<Story> ensembleStories = <Story>[
  // ------------------------------------------------------------------ two
  Story(
    id: 'st-a1-12',
    level: CefrLevel.a1,
    emoji: '🥖',
    title: 'Zwei am Tresen',
    titleEnglish: 'Two at the counter',
    blurb: 'A first conversation in a bakery, in two voices.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-a1-12-c1',
        title: 'In der Bäckerei',
        titleEnglish: 'In the bakery',
        lines: <StoryLine>[
          StoryLine(
            'Es ist acht Uhr. Nuria geht in die Bäckerei.',
            'It is eight o\'clock. Nuria goes into the bakery.',
          ),
          StoryLine(
            'Die Verkäuferin heißt Frau Ohm.',
            'The shop assistant is called Mrs Ohm.',
          ),
          StoryLine(
            '„Guten Morgen! Was möchten Sie?“',
            '"Good morning! What would you like?"',
            voice: GermanVoiceRole.speakerA,
          ),
          StoryLine(
            '„Guten Morgen. Ich möchte zwei Brötchen, bitte.“',
            '"Good morning. I would like two bread rolls, please."',
            voice: GermanVoiceRole.speakerB,
          ),
          StoryLine(
            'Frau Ohm nimmt eine Tüte.',
            'Mrs Ohm takes a bag.',
          ),
          StoryLine(
            '„Möchten Sie auch einen Kaffee?“',
            '"Would you like a coffee as well?"',
            voice: GermanVoiceRole.speakerA,
          ),
          StoryLine(
            '„Ja, gern. Einen Kaffee mit Milch.“',
            '"Yes, please. A coffee with milk."',
            voice: GermanVoiceRole.speakerB,
          ),
          StoryLine(
            '„Das macht drei Euro fünfzig.“',
            '"That comes to three euros fifty."',
            voice: GermanVoiceRole.speakerA,
          ),
          StoryLine(
            'Nuria bezahlt und lächelt.',
            'Nuria pays and smiles.',
          ),
          StoryLine(
            '„Danke schön. Bis morgen!“',
            '"Thank you. See you tomorrow!"',
            voice: GermanVoiceRole.speakerB,
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('das Brötchen', 'bread roll'),
          StoryGloss('die Tüte', 'paper bag'),
          StoryGloss('Das macht …', 'That comes to …', 'Used for prices.'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was kauft Nuria?',
            options: <String>[
              'Zwei Brötchen und einen Kaffee',
              'Einen Kuchen',
              'Nur einen Kaffee',
            ],
            correctIndex: 0,
            explanation: 'Sie möchte zwei Brötchen und einen Kaffee mit Milch.',
          ),
          ChoiceQuestion(
            prompt: 'Wie heißt die Verkäuferin?',
            options: <String>['Frau Ohm', 'Frau Weber', 'Nuria'],
            correctIndex: 0,
            explanation: '„Die Verkäuferin heißt Frau Ohm.“',
          ),
        ],
      ),
    ],
  ),

  // ---------------------------------------------------------------- three
  Story(
    id: 'st-a2-12',
    level: CefrLevel.a2,
    emoji: '🔑',
    title: 'Drei suchen einen Schlüssel',
    titleEnglish: 'Three look for a key',
    blurb: 'A shared flat, a missing key and three people talking at once.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-a2-12-c1',
        title: 'Wer hat den Schlüssel?',
        titleEnglish: 'Who has the key?',
        lines: <StoryLine>[
          StoryLine(
            'Timo, Katrin und Bea wohnen zusammen.',
            'Timo, Katrin and Bea live together.',
          ),
          StoryLine(
            'Am Abend steht Timo vor der Tür.',
            'In the evening Timo stands in front of the door.',
          ),
          StoryLine(
            '„Ich finde meinen Schlüssel nicht!“',
            '"I cannot find my key!"',
            voice: GermanVoiceRole.speakerA,
          ),
          StoryLine(
            'Katrin kommt aus der Küche.',
            'Katrin comes out of the kitchen.',
          ),
          StoryLine(
            '„Hast du in deiner Jacke nachgesehen?“',
            '"Have you looked in your jacket?"',
            voice: GermanVoiceRole.speakerB,
          ),
          StoryLine(
            'Bea sitzt am Tisch und lacht.',
            'Bea is sitting at the table and laughs.',
          ),
          StoryLine(
            '„Er liegt hier neben dem Brot, Timo.“',
            '"It is lying here next to the bread, Timo."',
            voice: GermanVoiceRole.speakerC,
          ),
          StoryLine(
            'Timo nimmt den Schlüssel.',
            'Timo takes the key.',
          ),
          StoryLine(
            '„Ihr seid unmöglich. Danke, Bea.“',
            '"You two are impossible. Thank you, Bea."',
            voice: GermanVoiceRole.speakerA,
          ),
          StoryLine(
            'Am nächsten Morgen hängt ein Haken neben der Tür.',
            'The next morning a hook is hanging next to the door.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('nachsehen', 'to check, to look'),
          StoryGloss('unmöglich', 'impossible'),
          StoryGloss('neben', 'next to', 'Two-way preposition.'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Wo liegt der Schlüssel?',
            options: <String>[
              'Neben dem Brot',
              'In der Jacke',
              'Vor der Tür',
            ],
            correctIndex: 0,
            explanation: 'Bea sagt: „Er liegt hier neben dem Brot.“',
          ),
          ChoiceQuestion(
            prompt: 'Wer findet den Schlüssel?',
            options: <String>['Bea', 'Katrin', 'Timo'],
            correctIndex: 0,
            explanation: 'Bea sieht ihn auf dem Tisch.',
          ),
        ],
      ),
    ],
  ),

  // ----------------------------------------------------------------- four
  Story(
    id: 'st-b1-12',
    level: CefrLevel.b1,
    emoji: '🍲',
    title: 'Vier am Tisch',
    titleEnglish: 'Four at the table',
    blurb: 'A dinner where nobody quite agrees about the recipe.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-b1-12-c1',
        title: 'Das Abendessen',
        titleEnglish: 'The dinner',
        lines: <StoryLine>[
          StoryLine(
            'Am Freitag kochen Ines, Malik, Ruth und Sven zusammen.',
            'On Friday Ines, Malik, Ruth and Sven cook together.',
          ),
          StoryLine(
            'Ines rührt in einem großen Topf.',
            'Ines stirs in a large pot.',
          ),
          StoryLine(
            '„Die Suppe braucht noch Salz, glaube ich.“',
            '"The soup still needs salt, I think."',
            voice: GermanVoiceRole.speakerA,
          ),
          StoryLine(
            'Malik probiert vorsichtig.',
            'Malik tastes carefully.',
          ),
          StoryLine(
            '„Auf keinen Fall. Sie ist schon kräftig genug.“',
            '"Absolutely not. It is already strong enough."',
            voice: GermanVoiceRole.speakerB,
          ),
          StoryLine(
            'Ruth stellt vier Teller auf den Tisch.',
            'Ruth puts four plates on the table.',
          ),
          StoryLine(
            '„Streitet nicht. Ich habe Brot mitgebracht.“',
            '"Do not argue. I have brought bread."',
            voice: GermanVoiceRole.speakerC,
          ),
          StoryLine(
            'Sven kommt als Letzter aus dem Flur.',
            'Sven comes last out of the hallway.',
          ),
          StoryLine(
            '„Entschuldigung, die Straßenbahn hatte Verspätung.“',
            '"Sorry, the tram was delayed."',
            voice: GermanVoiceRole.speakerD,
          ),
          StoryLine(
            'Später war der Topf leer und niemand sprach mehr vom Salz.',
            'Later the pot was empty and nobody mentioned the salt again.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('rühren', 'to stir'),
          StoryGloss('kräftig', 'strong, hearty', 'Of taste.'),
          StoryGloss('auf keinen Fall', 'absolutely not'),
          StoryGloss('die Verspätung', 'delay'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Worüber sind Ines und Malik verschiedener Meinung?',
            options: <String>[
              'Ob die Suppe Salz braucht',
              'Wer die Teller holt',
              'Wann Sven kommt',
            ],
            correctIndex: 0,
            explanation: 'Ines möchte Salz, Malik findet die Suppe kräftig '
                'genug.',
          ),
          ChoiceQuestion(
            prompt: 'Warum kommt Sven zu spät?',
            options: <String>[
              'Die Straßenbahn hatte Verspätung',
              'Er hat Brot gekauft',
              'Er hat den Topf gesucht',
            ],
            correctIndex: 0,
            explanation: '„Die Straßenbahn hatte Verspätung.“',
          ),
        ],
      ),
    ],
  ),

  // ----------------------------------------------------------------- five
  Story(
    id: 'st-b2-11',
    level: CefrLevel.b2,
    emoji: '🏛️',
    title: 'Fünf im Sitzungssaal',
    titleEnglish: 'Five in the meeting room',
    blurb: 'A residents\' meeting about a courtyard, and five ways of seeing '
        'it.',
    chapters: <StoryChapter>[
      StoryChapter(
        id: 'st-b2-11-c1',
        title: 'Die Versammlung',
        titleEnglish: 'The meeting',
        lines: <StoryLine>[
          StoryLine(
            'Die Hausverwalterin Frau Adler eröffnet die Versammlung.',
            'The property manager Mrs Adler opens the meeting.',
          ),
          StoryLine(
            '„Es geht um den Hof. Sollen wir dort Bäume pflanzen?“',
            '"It is about the courtyard. Should we plant trees there?"',
            voice: GermanVoiceRole.speakerA,
          ),
          StoryLine(
            'Herr Baric hebt sofort die Hand.',
            'Mr Baric immediately raises his hand.',
          ),
          StoryLine(
            '„Bäume brauchen Pflege, und die zahlen am Ende wir alle.“',
            '"Trees need care, and in the end all of us pay for it."',
            voice: GermanVoiceRole.speakerB,
          ),
          StoryLine(
            'Frau Cinar wohnt im Erdgeschoss.',
            'Mrs Cinar lives on the ground floor.',
          ),
          StoryLine(
            '„Im Sommer ist es bei mir unerträglich heiß. Schatten wäre '
            'viel wert.“',
            '"In summer it is unbearably hot in my flat. Shade would be '
            'worth a lot."',
            voice: GermanVoiceRole.speakerC,
          ),
          StoryLine(
            'Der Student Dario spricht als Letzter.',
            'The student Dario speaks last.',
          ),
          StoryLine(
            '„Ich pflege sie gern, wenn ich dafür den Hof nutzen darf.“',
            '"I will happily look after them, if I may use the courtyard in '
            'return."',
            voice: GermanVoiceRole.speakerD,
          ),
          StoryLine(
            'Frau Adler notiert den Vorschlag.',
            'Mrs Adler notes down the proposal.',
          ),
          StoryLine(
            '„Dann stimmen wir darüber ab.“',
            '"Then we shall vote on it."',
            voice: GermanVoiceRole.speakerA,
          ),
          StoryLine(
            'Der Hof bekam im Herbst vier junge Linden.',
            'In the autumn the courtyard got four young lime trees.',
          ),
        ],
        glossary: <StoryGloss>[
          StoryGloss('die Versammlung', 'meeting, assembly'),
          StoryGloss('die Pflege', 'care, maintenance'),
          StoryGloss('unerträglich', 'unbearable'),
          StoryGloss('abstimmen', 'to vote'),
          StoryGloss('die Linde', 'lime tree, linden'),
        ],
        questions: <ChoiceQuestion>[
          ChoiceQuestion(
            prompt: 'Was ist Herrn Barics Einwand?',
            options: <String>[
              'Die Pflege kostet alle Geld',
              'Der Hof ist zu klein',
              'Bäume sehen unordentlich aus',
            ],
            correctIndex: 0,
            explanation: '„Bäume brauchen Pflege, und die zahlen am Ende wir '
                'alle.“',
          ),
          ChoiceQuestion(
            prompt: 'Warum möchte Frau Cinar Bäume?',
            options: <String>[
              'Wegen des Schattens im Sommer',
              'Weil sie gern gärtnert',
              'Wegen der Vögel',
            ],
            correctIndex: 0,
            explanation: 'Bei ihr im Erdgeschoss ist es im Sommer sehr heiß.',
          ),
          ChoiceQuestion(
            prompt: 'Was schlägt Dario vor?',
            options: <String>[
              'Er pflegt die Bäume und darf den Hof nutzen',
              'Er bezahlt die Bäume',
              'Er sucht eine andere Wohnung',
            ],
            correctIndex: 0,
            explanation: 'Er bietet die Pflege im Tausch für die Nutzung an.',
          ),
        ],
      ),
    ],
  ),
];
