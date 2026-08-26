import 'models.dart';
import 'radio.dart';

/// B2, C1 and C2 Gartenradio scripts.
///
/// Nominal style, passive, Konjunktiv, hedged claims and argument structure —
/// the register of written German read aloud, which is exactly what a
/// synthesised narrator handles well. Original text written for this app.
const List<RadioEpisode> radioCEpisodes = <RadioEpisode>[
  // ---------------------------------------------------------------- B2 ----
  RadioEpisode(
    id: 'rd-b2-02',
    level: CefrLevel.b2,
    genre: RadioGenre.lecture,
    title: 'Warum Prognosen so oft danebenliegen',
    lines: <RadioLine>[
      RadioLine(
        german:
            'Prognosen scheitern selten daran, dass die Rechnung falsch war.',
        english: 'Forecasts rarely fail because the calculation was wrong.',
      ),
      RadioLine(
        german:
            'Häufiger stimmen die Annahmen nicht, auf denen sie beruhen.',
        english: 'More often the assumptions they rest on are incorrect.',
      ),
      RadioLine(
        german:
            'Ein Modell schreibt in der Regel die Vergangenheit fort.',
        english: 'A model as a rule extrapolates the past.',
      ),
      RadioLine(
        german:
            'Genau das misslingt, sobald sich die Bedingungen ändern.',
        english: 'That is exactly what fails as soon as conditions change.',
      ),
      RadioLine(
        german:
            'Hinzu kommt, dass Prognosen das Verhalten selbst beeinflussen.',
        english: 'In addition, forecasts influence behaviour themselves.',
      ),
      RadioLine(
        german:
            'Wer eine Krise erwartet, spart und verstärkt sie damit.',
        english: 'Anyone expecting a crisis saves and thereby intensifies it.',
      ),
      RadioLine(
        german:
            'Nützlich sind Prognosen daher weniger als Vorhersage denn als Warnung.',
        english:
            'Forecasts are therefore useful less as prediction than as warning.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Woran scheitern Prognosen laut Text meistens?',
        options: <String>[
          'An falschen Annahmen',
          'An Rechenfehlern',
          'An fehlenden Daten',
        ],
        correctIndex: 0,
        explanation:
            'Häufiger stimmen die Annahmen nicht, auf denen sie beruhen.',
      ),
      ChoiceQuestion(
        prompt: 'Welchen Effekt haben Prognosen auf das Verhalten?',
        options: <String>[
          'Sie beeinflussen es und können sich selbst verstärken.',
          'Sie haben keinen Einfluss.',
          'Sie verhindern Krisen zuverlässig.',
        ],
        correctIndex: 0,
        explanation:
            'Wer eine Krise erwartet, spart und verstärkt sie damit.',
      ),
      ChoiceQuestion(
        prompt: 'Wozu taugen Prognosen laut Text am ehesten?',
        options: <String>['Als Warnung', 'Als Vorhersage', 'Als Beweis'],
        correctIndex: 0,
        explanation:
            'Nützlich sind Prognosen weniger als Vorhersage denn als Warnung.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-03',
    level: CefrLevel.b2,
    genre: RadioGenre.news,
    title: 'Wohnungsbau bleibt hinter dem Ziel zurück',
    lines: <RadioLine>[
      RadioLine(
        german:
            'Im vergangenen Jahr wurden deutlich weniger Wohnungen fertiggestellt als geplant.',
        english:
            'Last year significantly fewer flats were completed than planned.',
      ),
      RadioLine(
        german:
            'Als Gründe gelten hohe Baukosten und langwierige Genehmigungen.',
        english:
            'High construction costs and lengthy approvals are considered the reasons.',
      ),
      RadioLine(
        german:
            'Die Branche fordert vereinfachte Verfahren und verlässliche Förderung.',
        english:
            'The industry is calling for simplified procedures and reliable subsidies.',
      ),
      RadioLine(
        german:
            'Kommunen verweisen dagegen auf fehlendes Personal in den Ämtern.',
        english:
            'Municipalities, by contrast, point to a lack of staff in the authorities.',
      ),
      RadioLine(
        german:
            'Ein Gutachten hält beide Erklärungen für zutreffend.',
        english: 'An expert report considers both explanations accurate.',
      ),
      RadioLine(
        german:
            'Es warnt zugleich davor, allein auf Neubau zu setzen.',
        english:
            'At the same time it warns against relying on new construction alone.',
      ),
      RadioLine(
        german:
            'Leerstand und Umbau blieben weitgehend ungenutzte Reserven.',
        english:
            'Vacancy and conversion remained largely unused reserves.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Welche Gründe werden für die Lücke genannt?',
        options: <String>[
          'Hohe Baukosten und langwierige Genehmigungen',
          'Fehlendes Interesse der Käufer',
          'Zu strenge Mietgesetze',
        ],
        correctIndex: 0,
        explanation:
            'Als Gründe gelten hohe Baukosten und langwierige Genehmigungen.',
      ),
      ChoiceQuestion(
        prompt: 'Wie bewertet das Gutachten die beiden Erklärungen?',
        options: <String>[
          'Beide treffen zu.',
          'Nur die der Branche trifft zu.',
          'Keine trifft zu.',
        ],
        correctIndex: 0,
        explanation: 'Ein Gutachten hält beide Erklärungen für zutreffend.',
      ),
      ChoiceQuestion(
        prompt: 'Wovor warnt das Gutachten?',
        options: <String>[
          'Allein auf Neubau zu setzen',
          'Vor steigenden Zinsen',
          'Vor zu schnellem Umbau',
        ],
        correctIndex: 0,
        explanation:
            'Es warnt davor, allein auf Neubau zu setzen; Leerstand und Umbau '
            'blieben ungenutzte Reserven.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-04',
    level: CefrLevel.b2,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Das Werk und sein Publikum',
    lines: <RadioLine>[
      RadioLine(
        german:
            'Das Gemälde vor Ihnen wurde bei seiner ersten Ausstellung verrissen.',
        english:
            'The painting in front of you was panned at its first exhibition.',
      ),
      RadioLine(
        german:
            'Kritiker warfen dem Maler handwerkliche Nachlässigkeit vor.',
        english: 'Critics accused the painter of technical carelessness.',
      ),
      RadioLine(
        german:
            'Erst Jahrzehnte später galt genau das als sein Verdienst.',
        english: 'Only decades later was exactly that seen as his achievement.',
      ),
      RadioLine(
        german:
            'Die Umwertung sagt weniger über das Bild als über sein Publikum.',
        english:
            'The reassessment says less about the picture than about its audience.',
      ),
      RadioLine(
        german:
            'Was als Fehler erschien, wurde als Absicht gelesen.',
        english: 'What appeared to be a mistake was read as intention.',
      ),
      RadioLine(
        german:
            'Solche Verschiebungen sind in der Kunstgeschichte keineswegs selten.',
        english:
            'Such shifts are by no means rare in art history.',
      ),
      RadioLine(
        german:
            'Sie mahnen zur Vorsicht gegenüber dem eigenen Urteil.',
        english: 'They counsel caution towards one own judgement.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie wurde das Gemälde zuerst aufgenommen?',
        options: <String>['Es wurde verrissen.', 'Es wurde gefeiert.', 'Es wurde übersehen.'],
        correctIndex: 0,
        explanation:
            'Das Gemälde wurde bei seiner ersten Ausstellung verrissen.',
      ),
      ChoiceQuestion(
        prompt: 'Worüber sagt die Umwertung laut Text mehr aus?',
        options: <String>[
          'Über das Publikum',
          'Über das Bild',
          'Über den Preis',
        ],
        correctIndex: 0,
        explanation:
            'Die Umwertung sagt weniger über das Bild als über sein Publikum.',
      ),
      ChoiceQuestion(
        prompt: 'Welche Schlussfolgerung zieht der Text?',
        options: <String>[
          'Vorsicht gegenüber dem eigenen Urteil',
          'Kritiker haben immer recht.',
          'Kunst lässt sich objektiv bewerten.',
        ],
        correctIndex: 0,
        explanation: 'Sie mahnen zur Vorsicht gegenüber dem eigenen Urteil.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-05',
    level: CefrLevel.b2,
    genre: RadioGenre.lecture,
    title: 'Der Nutzen von Langeweile',
    lines: <RadioLine>[
      RadioLine(
        german:
            'Langeweile hat einen schlechten Ruf, den sie nur teilweise verdient.',
        english:
            'Boredom has a bad reputation which it only partly deserves.',
      ),
      RadioLine(
        german:
            'Experimente deuten darauf hin, dass sie kreatives Denken begünstigt.',
        english:
            'Experiments suggest that it encourages creative thinking.',
      ),
      RadioLine(
        german:
            'Teilnehmer, die zuvor eine monotone Aufgabe erledigten, fanden mehr Ideen.',
        english:
            'Participants who had previously completed a monotonous task found more ideas.',
      ),
      RadioLine(
        german:
            'Eine mögliche Erklärung ist das Abschweifen der Gedanken.',
        english: 'One possible explanation is the wandering of thoughts.',
      ),
      RadioLine(
        german:
            'Das Gehirn verknüpft dann Dinge, die sonst getrennt bleiben.',
        english:
            'The brain then connects things that otherwise stay separate.',
      ),
      RadioLine(
        german:
            'Wer jede Pause mit dem Telefon füllt, verzichtet auf diesen Effekt.',
        english:
            'Anyone filling every break with a phone forgoes this effect.',
      ),
      RadioLine(
        german:
            'Gemeint ist damit kein Verzicht, sondern gelegentliches Nichtstun.',
        english:
            'What is meant is not abstinence but occasional idleness.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was legen die Experimente nahe?',
        options: <String>[
          'Langeweile begünstigt kreatives Denken.',
          'Langeweile schadet der Konzentration.',
          'Langeweile hat keinen Effekt.',
        ],
        correctIndex: 0,
        explanation:
            'Experimente deuten darauf hin, dass sie kreatives Denken begünstigt.',
      ),
      ChoiceQuestion(
        prompt: 'Welche Erklärung wird angeboten?',
        options: <String>[
          'Das Abschweifen der Gedanken',
          'Mehr Schlaf',
          'Bessere Ernährung',
        ],
        correctIndex: 0,
        explanation: 'Eine mögliche Erklärung ist das Abschweifen der Gedanken.',
      ),
      ChoiceQuestion(
        prompt: 'Was empfiehlt der Text?',
        options: <String>[
          'Gelegentliches Nichtstun',
          'Vollständigen Verzicht auf das Telefon',
          'Mehr monotone Arbeit',
        ],
        correctIndex: 0,
        explanation:
            'Gemeint ist kein Verzicht, sondern gelegentliches Nichtstun.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- C1 ----
  RadioEpisode(
    id: 'rd-c1-02',
    level: CefrLevel.c1,
    genre: RadioGenre.lecture,
    title: 'Über den Begriff der Verantwortung',
    lines: <RadioLine>[
      RadioLine(
        german:
            'Verantwortung setzt voraus, dass jemand anders hätte handeln können.',
        english:
            'Responsibility presupposes that someone could have acted otherwise.',
      ),
      RadioLine(
        german:
            'Genau diese Voraussetzung wird zunehmend bestritten.',
        english: 'It is precisely this presupposition that is increasingly disputed.',
      ),
      RadioLine(
        german:
            'Wo Strukturen das Handeln vorzeichnen, verliert der Einzelne an Gewicht.',
        english:
            'Where structures prefigure action, the individual loses weight.',
      ),
      RadioLine(
        german:
            'Daraus folgt allerdings nicht, dass niemand verantwortlich wäre.',
        english:
            'It does not follow from this, however, that nobody would be responsible.',
      ),
      RadioLine(
        german:
            'Die Verantwortung verschiebt sich vielmehr auf jene, die Strukturen gestalten.',
        english:
            'Rather, responsibility shifts to those who shape structures.',
      ),
      RadioLine(
        german:
            'Diese Verschiebung ist unbequem, weil sie schwerer zuzurechnen ist.',
        english:
            'This shift is uncomfortable because it is harder to attribute.',
      ),
      RadioLine(
        german:
            'Bequemlichkeit ist aber kein Argument in der Sache.',
        english: 'But convenience is not an argument on the matter.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Welche Voraussetzung nennt der Text für Verantwortung?',
        options: <String>[
          'Dass anders gehandelt werden konnte',
          'Dass ein Gesetz existiert',
          'Dass jemand zustimmt',
        ],
        correctIndex: 0,
        explanation:
            'Verantwortung setzt voraus, dass jemand anders hätte handeln können.',
      ),
      ChoiceQuestion(
        prompt: 'Wohin verschiebt sich die Verantwortung?',
        options: <String>[
          'Auf jene, die Strukturen gestalten',
          'Auf niemanden',
          'Auf den Gesetzgeber allein',
        ],
        correctIndex: 0,
        explanation:
            'Die Verantwortung verschiebt sich auf jene, die Strukturen gestalten.',
      ),
      ChoiceQuestion(
        prompt: 'Wie bewertet der Text die Unbequemlichkeit dieser These?',
        options: <String>[
          'Sie ist kein Argument in der Sache.',
          'Sie widerlegt die These.',
          'Sie bestätigt die These.',
        ],
        correctIndex: 0,
        explanation: 'Bequemlichkeit ist aber kein Argument in der Sache.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-c1-03',
    level: CefrLevel.c1,
    genre: RadioGenre.news,
    title: 'Reform mit offenem Ausgang',
    lines: <RadioLine>[
      RadioLine(
        german:
            'Der Entwurf sieht vor, die Zuständigkeiten neu zu ordnen.',
        english:
            'The draft provides for reorganising responsibilities.',
      ),
      RadioLine(
        german:
            'Befürworter versprechen sich davon kürzere Wege und klarere Zuordnung.',
        english:
            'Supporters expect shorter routes and clearer allocation from it.',
      ),
      RadioLine(
        german:
            'Die Länder sehen darin einen Eingriff in ihre Kompetenzen.',
        english: 'The federal states see it as an encroachment on their powers.',
      ),
      RadioLine(
        german:
            'Ob das Vorhaben die notwendige Mehrheit findet, ist offen.',
        english:
            'Whether the project finds the necessary majority is open.',
      ),
      RadioLine(
        german:
            'Beobachter rechnen mit erheblichen Änderungen im Verfahren.',
        english:
            'Observers expect considerable changes during the procedure.',
      ),
      RadioLine(
        german:
            'Erfahrungsgemäß überlebt kaum ein Entwurf die Ausschüsse unverändert.',
        english:
            'Experience shows that hardly any draft survives the committees unchanged.',
      ),
      RadioLine(
        german:
            'Insofern sagt der heutige Text wenig über das spätere Gesetz.',
        english:
            'In that respect the present text says little about the later law.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was kritisieren die Länder?',
        options: <String>[
          'Einen Eingriff in ihre Kompetenzen',
          'Die Kosten der Reform',
          'Den Zeitpunkt',
        ],
        correctIndex: 0,
        explanation: 'Die Länder sehen darin einen Eingriff in ihre Kompetenzen.',
      ),
      ChoiceQuestion(
        prompt: 'Womit rechnen die Beobachter?',
        options: <String>[
          'Mit erheblichen Änderungen im Verfahren',
          'Mit schneller Zustimmung',
          'Mit einem Rückzug des Entwurfs',
        ],
        correctIndex: 0,
        explanation:
            'Beobachter rechnen mit erheblichen Änderungen im Verfahren.',
      ),
      ChoiceQuestion(
        prompt: 'Welche Schlussfolgerung zieht der Text?',
        options: <String>[
          'Der heutige Text sagt wenig über das spätere Gesetz.',
          'Das Gesetz ist bereits beschlossen.',
          'Die Reform wird sicher scheitern.',
        ],
        correctIndex: 0,
        explanation:
            'Insofern sagt der heutige Text wenig über das spätere Gesetz.',
      ),
    ],
  ),

  // ---------------------------------------------------------------- C2 ----
  RadioEpisode(
    id: 'rd-c2-01',
    level: CefrLevel.c2,
    genre: RadioGenre.lecture,
    title: 'Die Grenzen des Vergleichs',
    lines: <RadioLine>[
      RadioLine(
        german:
            'Vergleiche ordnen das Unübersichtliche und verfälschen es dabei zwangsläufig.',
        english:
            'Comparisons order what is confusing and inevitably distort it in doing so.',
      ),
      RadioLine(
        german:
            'Denn jeder Vergleich unterstellt eine gemeinsame Bezugsgröße.',
        english:
            'For every comparison presupposes a common frame of reference.',
      ),
      RadioLine(
        german:
            'Fehlt sie, wird das Verglichene einander erst angeähnelt.',
        english:
            'Where it is absent, the compared items are first made similar to one another.',
      ),
      RadioLine(
        german:
            'Historische Analogien leiden regelmäßig unter diesem Mangel.',
        english:
            'Historical analogies regularly suffer from this deficiency.',
      ),
      RadioLine(
        german:
            'Sie erhellen eine Facette und verdecken die übrigen zuverlässig.',
        english:
            'They illuminate one facet and reliably obscure the rest.',
      ),
      RadioLine(
        german:
            'Das spricht nicht gegen den Vergleich als Verfahren.',
        english: 'That does not argue against comparison as a procedure.',
      ),
      RadioLine(
        german:
            'Wohl aber gegen die Annahme, er sei ein Beweis.',
        english: 'It does, however, argue against assuming it is a proof.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was unterstellt laut Text jeder Vergleich?',
        options: <String>[
          'Eine gemeinsame Bezugsgröße',
          'Eine gemeinsame Sprache',
          'Ein gemeinsames Interesse',
        ],
        correctIndex: 0,
        explanation: 'Jeder Vergleich unterstellt eine gemeinsame Bezugsgröße.',
      ),
      ChoiceQuestion(
        prompt: 'Woran leiden historische Analogien?',
        options: <String>[
          'Am Fehlen einer gemeinsamen Bezugsgröße',
          'An mangelnder Quellenlage',
          'An zu großer Genauigkeit',
        ],
        correctIndex: 0,
        explanation:
            'Historische Analogien leiden regelmäßig unter diesem Mangel.',
      ),
      ChoiceQuestion(
        prompt: 'Wogegen argumentiert der Text?',
        options: <String>[
          'Gegen die Annahme, der Vergleich sei ein Beweis',
          'Gegen jeden Vergleich',
          'Gegen die Geschichtswissenschaft',
        ],
        correctIndex: 0,
        explanation:
            'Das spricht nicht gegen den Vergleich als Verfahren, wohl aber '
            'gegen die Annahme, er sei ein Beweis.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-c2-02',
    level: CefrLevel.c2,
    genre: RadioGenre.lecture,
    title: 'Vom Umgang mit Nichtwissen',
    lines: <RadioLine>[
      RadioLine(
        german:
            'Nichtwissen gilt gemeinhin als Mangel, den es zu beheben gelte.',
        english:
            'Not knowing is commonly regarded as a deficiency to be remedied.',
      ),
      RadioLine(
        german:
            'Diese Auffassung greift jedoch erkennbar zu kurz.',
        english: 'This view, however, is recognisably too narrow.',
      ),
      RadioLine(
        german:
            'Manches Nichtwissen ist nicht vorläufig, sondern grundsätzlich.',
        english:
            'Some not knowing is not provisional but fundamental.',
      ),
      RadioLine(
        german:
            'Wer es als vorläufig behandelt, verspricht Sicherheiten, die es nicht gibt.',
        english:
            'Anyone treating it as provisional promises certainties that do not exist.',
      ),
      RadioLine(
        german:
            'Verantwortliches Handeln verlangt daher, Nichtwissen auszuweisen.',
        english:
            'Responsible action therefore requires declaring what is not known.',
      ),
      RadioLine(
        german:
            'Das erschwert die Kommunikation und erhöht zugleich ihre Redlichkeit.',
        english:
            'That complicates communication and at the same time increases its honesty.',
      ),
      RadioLine(
        german:
            'Der Preis dafür ist ein Autoritätsverlust, den man in Kauf nehmen sollte.',
        english:
            'The price is a loss of authority that one ought to accept.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie gilt Nichtwissen gemeinhin?',
        options: <String>[
          'Als Mangel, den es zu beheben gilt',
          'Als Vorteil',
          'Als unvermeidlich',
        ],
        correctIndex: 0,
        explanation:
            'Nichtwissen gilt gemeinhin als Mangel, den es zu beheben gelte.',
      ),
      ChoiceQuestion(
        prompt: 'Was verlangt verantwortliches Handeln laut Text?',
        options: <String>[
          'Nichtwissen auszuweisen',
          'Nichtwissen zu verschweigen',
          'Nichtwissen schnell zu beseitigen',
        ],
        correctIndex: 0,
        explanation:
            'Verantwortliches Handeln verlangt daher, Nichtwissen auszuweisen.',
      ),
      ChoiceQuestion(
        prompt: 'Welchen Preis nennt der Text?',
        options: <String>[
          'Einen Autoritätsverlust',
          'Höhere Kosten',
          'Längere Verfahren',
        ],
        correctIndex: 0,
        explanation:
            'Der Preis dafür ist ein Autoritätsverlust, den man in Kauf nehmen '
            'sollte.',
      ),
    ],
  ),
];
