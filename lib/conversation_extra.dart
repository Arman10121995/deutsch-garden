import 'conversation.dart';
import 'models.dart';

/// A second set of guided role-plays.
///
/// Original scenarios written for this app, following the same shape as the
/// first set: a stated goal, per-turn tasks, tappable starter phrases, a model
/// answer and a coaching note. The evaluator is the same deterministic rule
/// engine, so every turn states plainly what counts as addressing it.
const List<ConversationScenario> extraScenarios = <ConversationScenario>[
  ConversationScenario(
    id: 'cv-a1-04',
    level: CefrLevel.a1,
    emoji: '🥐',
    title: 'In der Bäckerei',
    setting: 'Eine kleine Bäckerei am Morgen.',
    tutorRole: 'Verkäuferin',
    learnerRole: 'Kunde oder Kundin',
    goal: 'Brot und ein Getränk kaufen und bezahlen.',
    usefulPhrases: <String>[
      'Ich hätte gern …',
      'Was kostet …?',
      'Das ist alles, danke.',
      'Ich zahle mit Karte.',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Guten Morgen! Was darf es sein?',
        tutorEnglish: 'Good morning! What can I get you?',
        task: 'Sag, welches Brot du möchtest.',
        keywords: <String>['brot', 'brötchen', 'hätte', 'möchte', 'bitte'],
        modelAnswer: 'Guten Morgen. Ich hätte gern ein Brot, bitte.',
        modelAnswerEnglish: 'Good morning. I would like a loaf of bread, please.',
        quickReplies: <String>['Ich hätte gern ein Brot.', 'Zwei Brötchen, bitte.'],
        coachTip: '„Ich hätte gern“ ist die höfliche Standardform beim Einkaufen.',
      ),
      DialogueStep(
        tutorGerman: 'Gern. Möchten Sie sonst noch etwas?',
        tutorEnglish: 'Certainly. Would you like anything else?',
        task: 'Bestelle zusätzlich ein Getränk.',
        keywords: <String>['kaffee', 'tee', 'wasser', 'saft', 'auch', 'noch'],
        modelAnswer: 'Ja, einen Kaffee bitte.',
        modelAnswerEnglish: 'Yes, a coffee please.',
        quickReplies: <String>['Einen Kaffee, bitte.', 'Ein Wasser, bitte.'],
        coachTip: 'Nach „einen“ steht der Akkusativ: einen Kaffee, einen Tee.',
      ),
      DialogueStep(
        tutorGerman: 'Das macht vier Euro fünfzig.',
        tutorEnglish: 'That comes to four euros fifty.',
        task: 'Sag, wie du bezahlen möchtest.',
        keywords: <String>['karte', 'bar', 'zahle', 'bezahlen'],
        modelAnswer: 'Ich zahle mit Karte.',
        modelAnswerEnglish: 'I will pay by card.',
        quickReplies: <String>['Mit Karte, bitte.', 'Ich zahle bar.'],
        coachTip: '„mit“ verlangt den Dativ: mit Karte, mit dem Handy.',
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-a2-04',
    level: CefrLevel.a2,
    emoji: '🩺',
    title: 'In der Hausarztpraxis',
    setting: 'Eine Hausarztpraxis am Vormittag.',
    tutorRole: 'Arzt',
    learnerRole: 'Patient oder Patientin',
    goal: 'Beschwerden schildern und einen Rat bekommen.',
    usefulPhrases: <String>[
      'Ich habe seit … Schmerzen.',
      'Es tut hier weh.',
      'Können Sie mir etwas verschreiben?',
      'Wie oft soll ich das nehmen?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Guten Tag. Was führt Sie zu mir?',
        tutorEnglish: 'Hello. What brings you here?',
        task: 'Beschreibe dein Problem und sag, seit wann es besteht.',
        keywords: <String>['schmerz', 'weh', 'seit', 'tage', 'kopf', 'hals', 'bauch'],
        modelAnswer: 'Guten Tag. Ich habe seit drei Tagen Halsschmerzen.',
        modelAnswerEnglish: 'Hello. I have had a sore throat for three days.',
        quickReplies: <String>[
          'Ich habe seit drei Tagen Halsschmerzen.',
          'Mein Kopf tut seit gestern weh.',
        ],
        coachTip: '„seit“ steht mit dem Dativ und beschreibt einen Zeitraum, der noch andauert.',
        minWords: 5,
      ),
      DialogueStep(
        tutorGerman: 'Haben Sie auch Fieber gemessen?',
        tutorEnglish: 'Have you also taken your temperature?',
        task: 'Antworte und nenne einen weiteren Umstand.',
        keywords: <String>['fieber', 'gemessen', 'grad', 'nein', 'ja', 'müde'],
        modelAnswer: 'Ja, gestern Abend hatte ich achtunddreißig Grad Fieber.',
        modelAnswerEnglish: 'Yes, yesterday evening I had a temperature of thirty-eight degrees.',
        quickReplies: <String>[
          'Ja, ich hatte Fieber.',
          'Nein, Fieber habe ich nicht.',
        ],
        coachTip: 'Im Perfekt steht das Partizip am Satzende: Ich habe Fieber gemessen.',
        minWords: 5,
      ),
      DialogueStep(
        tutorGerman: 'Ich verschreibe Ihnen etwas. Nehmen Sie es dreimal täglich.',
        tutorEnglish: 'I will prescribe you something. Take it three times a day.',
        task: 'Frage nach, wie lange du das Medikament nehmen sollst.',
        keywords: <String>['wie lange', 'tage', 'woche', 'nehmen', 'soll'],
        modelAnswer: 'Wie lange soll ich das Medikament nehmen?',
        modelAnswerEnglish: 'How long should I take the medicine?',
        quickReplies: <String>[
          'Wie lange soll ich das nehmen?',
          'Und wenn es nicht besser wird?',
        ],
        coachTip: 'Bei Modalverben steht der Infinitiv am Ende: soll ich … nehmen?',
        minWords: 4,
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-a2-05',
    level: CefrLevel.a2,
    emoji: '🏠',
    title: 'Eine Wohnung besichtigen',
    setting: 'Eine Dreizimmerwohnung im zweiten Stock.',
    tutorRole: 'Vermieterin',
    learnerRole: 'Interessent oder Interessentin',
    goal: 'Die wichtigsten Fragen zur Wohnung stellen.',
    usefulPhrases: <String>[
      'Wie hoch sind die Nebenkosten?',
      'Ab wann ist die Wohnung frei?',
      'Ist eine Küche vorhanden?',
      'Darf man hier Haustiere halten?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Das ist das Wohnzimmer. Wie gefällt Ihnen die Wohnung?',
        tutorEnglish: 'This is the living room. How do you like the flat?',
        task: 'Sag deine Meinung und begründe sie kurz.',
        keywords: <String>['gefällt', 'hell', 'groß', 'schön', 'weil', 'gut'],
        modelAnswer: 'Sie gefällt mir gut, weil sie sehr hell ist.',
        modelAnswerEnglish: 'I like it, because it is very bright.',
        quickReplies: <String>[
          'Sie gefällt mir gut.',
          'Das Zimmer ist schön hell.',
        ],
        coachTip: 'Nach „weil“ steht das Verb am Satzende.',
        minWords: 5,
      ),
      DialogueStep(
        tutorGerman: 'Haben Sie Fragen zu den Kosten?',
        tutorEnglish: 'Do you have questions about the costs?',
        task: 'Frage nach den Nebenkosten.',
        keywords: <String>['nebenkosten', 'kosten', 'miete', 'wie hoch', 'warm'],
        modelAnswer: 'Ja, wie hoch sind die Nebenkosten im Monat?',
        modelAnswerEnglish: 'Yes, how high are the additional costs per month?',
        quickReplies: <String>[
          'Wie hoch sind die Nebenkosten?',
          'Ist das die Warmmiete?',
        ],
        coachTip: 'Kaltmiete ist die Miete ohne Nebenkosten, Warmmiete mit.',
        minWords: 5,
      ),
      DialogueStep(
        tutorGerman: 'Die Wohnung wäre ab dem ersten Mai frei.',
        tutorEnglish: 'The flat would be available from the first of May.',
        task: 'Sag, ob der Termin passt, und nenne einen Grund.',
        keywords: <String>['passt', 'früher', 'später', 'weil', 'leider', 'gut'],
        modelAnswer: 'Das passt gut, weil mein alter Vertrag Ende April endet.',
        modelAnswerEnglish: 'That suits me well, because my old contract ends at the end of April.',
        quickReplies: <String>[
          'Das passt sehr gut.',
          'Etwas früher wäre besser.',
        ],
        coachTip: 'Datumsangaben stehen mit „ab dem“ plus Dativ: ab dem ersten Mai.',
        minWords: 6,
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-b1-04',
    level: CefrLevel.b1,
    emoji: '🧾',
    title: 'Eine Reklamation',
    setting: 'Der Kundenservice eines Elektronikgeschäfts.',
    tutorRole: 'Mitarbeiter im Kundenservice',
    learnerRole: 'Kunde oder Kundin',
    goal: 'Ein defektes Gerät reklamieren und eine Lösung aushandeln.',
    usefulPhrases: <String>[
      'Ich möchte das Gerät reklamieren.',
      'Es funktioniert seit … nicht mehr.',
      'Ich hätte gern einen Ersatz.',
      'Wie lange dauert die Reparatur?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Guten Tag, worum geht es?',
        tutorEnglish: 'Hello, what is it about?',
        task: 'Erkläre das Problem und wann es aufgetreten ist.',
        keywords: <String>['reklamieren', 'funktioniert', 'kaputt', 'seit', 'gekauft', 'defekt'],
        modelAnswer:
            'Ich möchte diesen Kopfhörer reklamieren, er funktioniert seit einer Woche nicht mehr.',
        modelAnswerEnglish:
            'I would like to make a complaint about these headphones, they have not worked for a week.',
        quickReplies: <String>[
          'Ich möchte das Gerät reklamieren.',
          'Der Kopfhörer ist defekt.',
        ],
        coachTip: '„reklamieren“ ist der übliche Ausdruck; „sich beschweren“ klingt schärfer.',
        minWords: 7,
      ),
      DialogueStep(
        tutorGerman: 'Haben Sie den Kassenbon dabei?',
        tutorEnglish: 'Do you have the receipt with you?',
        task: 'Antworte und nenne das Kaufdatum.',
        keywords: <String>['bon', 'quittung', 'rechnung', 'gekauft', 'monat', 'ja', 'nein'],
        modelAnswer: 'Ja, hier ist der Kassenbon. Ich habe das Gerät vor zwei Monaten gekauft.',
        modelAnswerEnglish:
            'Yes, here is the receipt. I bought the device two months ago.',
        quickReplies: <String>[
          'Ja, hier ist der Bon.',
          'Den Bon habe ich leider nicht mehr.',
        ],
        coachTip: '„vor“ plus Dativ beschreibt einen Zeitpunkt in der Vergangenheit.',
        minWords: 6,
      ),
      DialogueStep(
        tutorGerman: 'Wir könnten das Gerät einschicken. Das dauert etwa drei Wochen.',
        tutorEnglish: 'We could send the device in. That takes about three weeks.',
        task: 'Widersprich höflich und schlage eine andere Lösung vor.',
        keywords: <String>['lange', 'ersatz', 'umtausch', 'lieber', 'möglich', 'stattdessen'],
        modelAnswer:
            'Drei Wochen sind mir ehrlich gesagt zu lang. Wäre ein Umtausch möglich?',
        modelAnswerEnglish:
            'Three weeks is honestly too long for me. Would an exchange be possible?',
        quickReplies: <String>[
          'Das dauert mir zu lange.',
          'Wäre ein Umtausch möglich?',
        ],
        coachTip:
            'Mit dem Konjunktiv „wäre“ klingt eine Forderung deutlich verbindlicher.',
        minWords: 8,
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-b1-05',
    level: CefrLevel.b1,
    emoji: '📅',
    title: 'Einen Termin verschieben',
    setting: 'Ein Telefonat mit dem Büro einer Kollegin.',
    tutorRole: 'Assistentin',
    learnerRole: 'Anrufer oder Anruferin',
    goal: 'Einen Termin absagen und einen neuen vereinbaren.',
    usefulPhrases: <String>[
      'Es tut mir leid, aber …',
      'Wäre es möglich, den Termin zu verschieben?',
      'Passt Ihnen der Donnerstag?',
      'Ich melde mich rechtzeitig.',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Büro Hartmann, guten Tag. Was kann ich für Sie tun?',
        tutorEnglish: 'Hartmann office, hello. What can I do for you?',
        task: 'Nenne deinen Namen und dein Anliegen.',
        keywords: <String>['heiße', 'mein name', 'termin', 'verschieben', 'morgen'],
        modelAnswer:
            'Guten Tag, mein Name ist Sanchez. Es geht um meinen Termin morgen.',
        modelAnswerEnglish:
            'Hello, my name is Sanchez. It is about my appointment tomorrow.',
        quickReplies: <String>[
          'Mein Name ist …, es geht um meinen Termin.',
          'Ich möchte einen Termin verschieben.',
        ],
        coachTip: '„Es geht um …“ ist die neutrale Art, ein Anliegen einzuleiten.',
        minWords: 6,
      ),
      DialogueStep(
        tutorGerman: 'Der Termin ist um zehn Uhr eingetragen. Stimmt etwas nicht?',
        tutorEnglish: 'The appointment is booked for ten. Is something wrong?',
        task: 'Sage höflich ab und nenne einen Grund.',
        keywords: <String>['leider', 'kann nicht', 'weil', 'krank', 'dienstlich', 'absagen'],
        modelAnswer:
            'Leider kann ich morgen nicht kommen, weil ich kurzfristig verreisen muss.',
        modelAnswerEnglish:
            'Unfortunately I cannot come tomorrow, because I have to travel at short notice.',
        quickReplies: <String>[
          'Leider kann ich morgen nicht.',
          'Ich muss den Termin leider absagen.',
        ],
        coachTip: 'Ein kurzer Grund macht eine Absage verbindlicher, ohne privat zu werden.',
        minWords: 7,
      ),
      DialogueStep(
        tutorGerman: 'Kein Problem. Wann würde es Ihnen denn passen?',
        tutorEnglish: 'No problem. When would suit you?',
        task: 'Schlage zwei mögliche Termine vor.',
        keywords: <String>['donnerstag', 'freitag', 'montag', 'uhr', 'oder', 'vormittag'],
        modelAnswer:
            'Am Donnerstag um elf oder am Freitag am Vormittag würde es mir passen.',
        modelAnswerEnglish:
            'Thursday at eleven or Friday morning would suit me.',
        quickReplies: <String>[
          'Am Donnerstag um elf?',
          'Freitagvormittag wäre gut.',
        ],
        coachTip:
            'Zwei Alternativen anzubieten ist üblich und beschleunigt die Terminfindung.',
        minWords: 8,
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-b2-04',
    level: CefrLevel.b2,
    emoji: '💼',
    title: 'Gehaltsgespräch',
    setting: 'Ein Jahresgespräch mit der Vorgesetzten.',
    tutorRole: 'Vorgesetzte',
    learnerRole: 'Mitarbeiter oder Mitarbeiterin',
    goal: 'Eine Gehaltserhöhung sachlich begründen.',
    usefulPhrases: <String>[
      'In den vergangenen Monaten habe ich …',
      'Mein Beitrag lässt sich daran messen, dass …',
      'Ich halte eine Anpassung für angemessen.',
      'Wie sehen Sie das?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman: 'Sie wollten über Ihre Vergütung sprechen. Ich höre.',
        tutorEnglish: 'You wanted to talk about your remuneration. I am listening.',
        task: 'Nenne dein Anliegen und begründe es mit einem konkreten Ergebnis.',
        keywords: <String>['erhöhung', 'anpassung', 'projekt', 'übernommen', 'verantwortung', 'ergebnis'],
        modelAnswer:
            'Ich möchte über eine Anpassung sprechen, weil ich seit Januar das Projekt Nord verantworte.',
        modelAnswerEnglish:
            'I would like to talk about an adjustment, because I have been responsible for the Nord project since January.',
        quickReplies: <String>[
          'Ich möchte über eine Gehaltsanpassung sprechen.',
          'Seit Januar habe ich mehr Verantwortung übernommen.',
        ],
        coachTip:
            'Ein konkretes Ergebnis trägt weiter als eine allgemeine Aussage über Einsatz.',
        minWords: 9,
      ),
      DialogueStep(
        tutorGerman: 'Das ist mir bekannt. Der Rahmen ist dieses Jahr allerdings eng.',
        tutorEnglish: 'I am aware of that. The scope is tight this year, however.',
        task: 'Nimm den Einwand auf und halte trotzdem an deiner Position fest.',
        keywords: <String>['verstehe', 'nachvollziehen', 'dennoch', 'trotzdem', 'gleichwohl', 'dass'],
        modelAnswer:
            'Das kann ich nachvollziehen. Dennoch halte ich eine Anpassung für angemessen, gerade weil der Aufgabenzuschnitt sich geändert hat.',
        modelAnswerEnglish:
            'I can understand that. Nevertheless I consider an adjustment appropriate, precisely because the scope of the role has changed.',
        quickReplies: <String>[
          'Das kann ich nachvollziehen, dennoch …',
          'Verstehe ich, gleichwohl halte ich …',
        ],
        coachTip:
            'Erst zustimmen, dann widersprechen: „Das kann ich nachvollziehen. Dennoch …“',
        minWords: 12,
      ),
      DialogueStep(
        tutorGerman: 'Was schwebt Ihnen konkret vor?',
        tutorEnglish: 'What do you have in mind specifically?',
        task: 'Nenne eine konkrete Vorstellung und biete einen Prüfzeitpunkt an.',
        keywords: <String>['prozent', 'euro', 'quartal', 'halbjahr', 'prüfen', 'vorschlag'],
        modelAnswer:
            'Ich denke an fünf Prozent. Alternativ könnten wir die Frage im dritten Quartal erneut prüfen.',
        modelAnswerEnglish:
            'I am thinking of five percent. Alternatively we could review the question again in the third quarter.',
        quickReplies: <String>[
          'Ich denke an fünf Prozent.',
          'Wir könnten es im dritten Quartal erneut prüfen.',
        ],
        coachTip:
            'Eine Zahl plus eine Alternative hält das Gespräch offen, ohne die Forderung aufzugeben.',
        minWords: 10,
      ),
    ],
  ),
  ConversationScenario(
    id: 'cv-c1-03',
    level: CefrLevel.c1,
    emoji: '🏛️',
    title: 'Einwand in einer Sitzung',
    setting: 'Eine Projektsitzung, in der eine Entscheidung ansteht.',
    tutorRole: 'Sitzungsleitung',
    learnerRole: 'Teilnehmer oder Teilnehmerin',
    goal: 'Einen begründeten Einwand vorbringen, ohne die Sitzung zu blockieren.',
    usefulPhrases: <String>[
      'Ich möchte einen Punkt zu bedenken geben.',
      'Das setzt voraus, dass …',
      'Unter der Bedingung, dass …, trage ich es mit.',
      'Ließe sich das noch prüfen?',
    ],
    steps: <DialogueStep>[
      DialogueStep(
        tutorGerman:
            'Wir würden den Beschluss so fassen. Gibt es dazu noch Anmerkungen?',
        tutorEnglish:
            'We would frame the decision like this. Are there any further comments?',
        task: 'Bringe einen Einwand vor und benenne die Annahme, die du bezweifelst.',
        keywords: <String>['bedenken', 'annahme', 'setzt voraus', 'einwand', 'zweifel', 'frage'],
        modelAnswer:
            'Ich möchte einen Punkt zu bedenken geben: Der Beschluss setzt voraus, dass die Zulieferung im Mai steht.',
        modelAnswerEnglish:
            'I would like to raise a point: the decision presupposes that the delivery is in place in May.',
        quickReplies: <String>[
          'Ich möchte einen Punkt zu bedenken geben.',
          'Das setzt voraus, dass …',
        ],
        coachTip:
            'Einen Einwand als Frage nach einer Annahme zu formulieren wirkt sachlich statt blockierend.',
        minWords: 12,
      ),
      DialogueStep(
        tutorGerman: 'Die Zulieferung gilt als gesichert. Worauf stützen Sie Ihren Zweifel?',
        tutorEnglish: 'The delivery is considered secure. What do you base your doubt on?',
        task: 'Begründe deinen Zweifel mit einem Beleg und bleibe dabei verbindlich.',
        keywords: <String>['bericht', 'zahlen', 'erfahrung', 'letzten', 'verzögerung', 'belegt'],
        modelAnswer:
            'Im letzten Quartal kam es zweimal zu Verzögerungen, das ist im Statusbericht dokumentiert.',
        modelAnswerEnglish:
            'Last quarter there were delays twice, which is documented in the status report.',
        quickReplies: <String>[
          'Im Statusbericht sind zwei Verzögerungen dokumentiert.',
          'Die Erfahrung aus dem letzten Quartal spricht dagegen.',
        ],
        coachTip:
            'Ein Beleg macht aus einem Bauchgefühl ein Argument, das die Sitzung annehmen kann.',
        minWords: 10,
      ),
      DialogueStep(
        tutorGerman: 'Gut. Wie kommen wir heute trotzdem zu einer Entscheidung?',
        tutorEnglish: 'Good. How do we still reach a decision today?',
        task: 'Biete eine Lösung an, die den Beschluss ermöglicht und deinen Einwand sichert.',
        keywords: <String>['bedingung', 'vorbehalt', 'protokoll', 'prüfen', 'zustimmen', 'sofern'],
        modelAnswer:
            'Unter dem Vorbehalt, dass wir die Zulieferung bis Ende April bestätigen, trage ich den Beschluss mit.',
        modelAnswerEnglish:
            'Subject to confirming the delivery by the end of April, I will support the decision.',
        quickReplies: <String>[
          'Unter Vorbehalt trage ich das mit.',
          'Sofern wir das bis April prüfen, stimme ich zu.',
        ],
        coachTip:
            'Zustimmung unter Vorbehalt ist das übliche Mittel, um einen Einwand zu sichern, ohne zu blockieren.',
        minWords: 12,
      ),
    ],
  ),
];
