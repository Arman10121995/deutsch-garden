import 'models.dart';
import 'radio.dart';

/// C2 Gartenradio scripts, second batch.
///
/// Original text written for this app. Episodes live in one file
/// per batch so a new set of scripts is a new file rather than a
/// rewrite of a growing one.
const List<RadioEpisode> radioC2MoreEpisodes = <RadioEpisode>[
  RadioEpisode(
    id: 'rd-c2-03',
    level: CefrLevel.c2,
    genre: RadioGenre.lecture,
    title: 'Vom Nutzen des Vergessens',
    lines: <RadioLine>[
      RadioLine(
        german: 'Vom Gedächtnis erwarten wir Treue, vom Vergessen hingegen nichts als Verlust.',
        english: 'From memory we expect loyalty, whereas from forgetting we expect nothing but loss.',
      ),
      RadioLine(
        german: 'Dabei ist das Vergessen keineswegs das Versagen des Erinnerns, sondern dessen stille Voraussetzung.',
        english: 'Yet forgetting is by no means the failure of remembering; it is its quiet precondition.',
      ),
      RadioLine(
        german: 'Ein Gedächtnis, das alles behielte, wäre kein Gedächtnis mehr, sondern ein Archiv ohne jede Ordnung.',
        english: 'A memory that kept everything would no longer be a memory, but an archive without any order at all.',
      ),
      RadioLine(
        german: 'Erst weil das Unwichtige verblasst, tritt das Bedeutsame überhaupt hervor.',
        english: 'Only because the unimportant fades does what matters stand out in the first place.',
      ),
      RadioLine(
        german: 'Wer sich an jeden Regentag seiner Kindheit erinnerte, erinnerte sich an keinen einzigen.',
        english: 'Someone who remembered every rainy day of their childhood would remember none of them.',
      ),
      RadioLine(
        german: 'Auch unser Urteil lebt vom Vergessen, denn nur so lässt sich ein Mensch anders sehen als gestern.',
        english: 'Our judgement, too, lives off forgetting, since only in that way can a person be seen differently than yesterday.',
      ),
      RadioLine(
        german: 'Man verzeiht ja nicht dadurch, dass man die Kränkung leugnet, sondern dadurch, dass man ihr das letzte Wort entzieht.',
        english: 'After all, you do not forgive by denying the insult, but by refusing to let it have the last word.',
      ),
      RadioLine(
        german: 'Freilich hat diese Nachsicht ihre Grenzen, denn wer bloß verdrängt, der hat noch nichts geklärt.',
        english: 'Admittedly this leniency has its limits, because merely pushing something aside settles nothing.',
      ),
      RadioLine(
        german: 'Vergessen im guten Sinne ist deshalb keine Lücke, sondern eine Entscheidung darüber, was weiterwirken darf.',
        english: 'Forgetting in the good sense is therefore not a gap, but a decision about what is allowed to go on having an effect.',
      ),
      RadioLine(
        german: 'Dass Notizbücher, Kalender und Geräte uns diese Entscheidung abnehmen, verändert weniger unser Wissen als unser Verhältnis dazu.',
        english: 'That notebooks, calendars and devices take this decision off our hands changes our knowledge less than our relationship to it.',
      ),
      RadioLine(
        german: 'Denn wo nichts mehr von selbst verblasst, muss alles eigens ausgewählt werden.',
        english: 'For where nothing fades of its own accord any more, everything has to be selected deliberately.',
      ),
      RadioLine(
        german: 'Wer je einen alten Ordner durchgesehen hat, kennt das Unbehagen, das aus lauter Vollständigkeit entsteht.',
        english: 'Anyone who has ever leafed through an old file knows the unease that comes from sheer completeness.',
      ),
      RadioLine(
        german: 'Nicht das Behalten also ist die eigentliche Leistung, sondern das kluge Ablegen dessen, was uns nichts mehr angeht.',
        english: 'So the real achievement is not holding on, but wisely putting away whatever no longer concerns us.',
      ),
      RadioLine(
        german: 'Vielleicht sollten wir dem Vergessen deshalb nicht misstrauen, sondern ihm gelegentlich sogar danken.',
        english: 'Perhaps, then, we should not be suspicious of forgetting, but occasionally even be grateful to it.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Welche Rolle schreibt der Vortrag dem Vergessen zu?',
        options: <String>[
          'Es ist ein Versagen des Erinnerns.',
          'Es ist die Voraussetzung des Erinnerns.',
          'Es ist eine Folge des Alters.',
        ],
        correctIndex: 1,
        explanation: 'Im Vortrag heißt es, das Vergessen sei keineswegs das Versagen des Erinnerns, sondern dessen stille Voraussetzung.',
      ),
      ChoiceQuestion(
        prompt: 'Womit vergleicht der Vortrag ein Gedächtnis, das alles behielte?',
        options: <String>[
          'Mit einem ungeordneten Archiv',
          'Mit einer verschlossenen Bibliothek',
          'Mit einem übervollen Kalender',
        ],
        correctIndex: 0,
        explanation: 'Ein Gedächtnis, das alles behielte, wäre laut Vortrag ein Archiv ohne jede Ordnung.',
      ),
      ChoiceQuestion(
        prompt: 'Was folgt laut dem Vortrag daraus, dass Geräte uns das Entscheiden abnehmen?',
        options: <String>[
          'Unser Wissen wächst schneller als früher.',
          'Unser Gedächtnis wird deutlich zuverlässiger.',
          'Alles muss eigens ausgewählt werden.',
        ],
        correctIndex: 2,
        explanation: 'Wo nichts mehr von selbst verblasst, muss alles eigens ausgewählt werden.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-c2-04',
    level: CefrLevel.c2,
    genre: RadioGenre.news,
    title: 'Ein Preis für Grundwasser',
    lines: <RadioLine>[
      RadioLine(
        german: 'Der Kreistag in Weidbach berät von kommender Woche an über ein Entgelt für die Entnahme von Grundwasser.',
        english: 'From next week the district council in Weidbach will debate a charge for the extraction of groundwater.',
      ),
      RadioLine(
        german: 'Was zunächst nach einer bloßen Gebührenfrage klingt, ist der Sache nach eine Verteilungsfrage.',
        english: 'What at first sounds like a mere matter of fees is in substance a question of distribution.',
      ),
      RadioLine(
        german: 'Denn nicht der Verbrauch als solcher steht zur Debatte, sondern die Frage, wer die Kosten seiner Knappheit trägt.',
        english: 'For it is not consumption as such that is up for debate, but the question of who bears the cost of its scarcity.',
      ),
      RadioLine(
        german: 'Nach dem Gutachten der Hochschule Lindforst ist der Grundwasserspiegel im Weidbachtal seit 2018 um durchschnittlich vierzehn Zentimeter gesunken.',
        english: 'According to the report by Lindforst College, the water table in the Weidbach valley has fallen by an average of fourteen centimetres since 2018.',
      ),
      RadioLine(
        german: 'Vorgesehen sind acht Cent je Kubikmeter; für Haushalte wären das rund neunzehn Euro im Jahr.',
        english: 'Eight cents per cubic metre are planned, which for households would amount to around nineteen euros a year.',
      ),
      RadioLine(
        german: 'Landwirtschaftliche Betriebe sollen in den ersten drei Jahren nur die Hälfte zahlen.',
        english: 'Farming businesses are to pay only half of that for the first three years.',
      ),
      RadioLine(
        german: 'Der Wasserverband Weidbachtal begrüßt den Vorschlag, hält den Satz allerdings für zu niedrig, um Verhalten zu ändern.',
        english: 'The Weidbach Valley water association welcomes the proposal, but regards the rate as too low to change anyone\'s behaviour.',
      ),
      RadioLine(
        german: 'Die Kreishandwerkerschaft wiederum warnt vor Belastungen, die gerade kleine Betriebe kaum weiterreichen könnten.',
        english: 'The district trades association, for its part, warns of costs that small firms in particular could hardly pass on.',
      ),
      RadioLine(
        german: 'Bemerkenswert ist, dass beide Seiten die Zahlen des Gutachtens gar nicht bestreiten.',
        english: 'What is striking is that neither side disputes the figures in the report at all.',
      ),
      RadioLine(
        german: 'Gestritten wird vielmehr über deren Deutung und damit über die Frage, was ein knappes Gut kosten darf.',
        english: 'The argument is rather about how to interpret them, and thus about what a scarce good may be allowed to cost.',
      ),
      RadioLine(
        german: 'Eine öffentliche Anhörung findet am zwölften November im Kreishaus statt.',
        english: 'A public hearing will be held on the twelfth of November at the district offices.',
      ),
      RadioLine(
        german: 'Die Entscheidung soll nach Angaben der Verwaltung noch vor dem Frühjahr fallen.',
        english: 'According to the administration, the decision is to be taken before the spring.',
      ),
      RadioLine(
        german: 'Ob das Entgelt am Ende Wasser spart oder nur Haushaltslöcher schließt, wird sich erst in einigen Jahren zeigen.',
        english: 'Whether the charge will ultimately save water or merely plug holes in the budget will only become clear in a few years.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie hoch soll das Entgelt je Kubikmeter sein?',
        options: <String>[
          'Sechs Cent',
          'Acht Cent',
          'Vierzehn Cent',
        ],
        correctIndex: 1,
        explanation: 'In der Meldung heißt es, vorgesehen seien acht Cent je Kubikmeter.',
      ),
      ChoiceQuestion(
        prompt: 'Welche Regelung ist für landwirtschaftliche Betriebe vorgesehen?',
        options: <String>[
          'Sie zahlen drei Jahre lang die Hälfte.',
          'Sie sind dauerhaft von dem Entgelt befreit.',
          'Sie zahlen erst ab dem dritten Jahr.',
        ],
        correctIndex: 0,
        explanation: 'Landwirtschaftliche Betriebe sollen in den ersten drei Jahren nur die Hälfte zahlen.',
      ),
      ChoiceQuestion(
        prompt: 'Worüber wird laut der Meldung vor allem gestritten?',
        options: <String>[
          'Über die Höhe des Grundwasserspiegels',
          'Über den Termin der öffentlichen Anhörung',
          'Über die Deutung der Zahlen',
        ],
        correctIndex: 2,
        explanation: 'Beide Seiten bestreiten die Zahlen gar nicht; gestritten wird vielmehr über deren Deutung.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-c2-05',
    level: CefrLevel.c2,
    genre: RadioGenre.lecture,
    title: 'Formeln der Höflichkeit',
    lines: <RadioLine>[
      RadioLine(
        german: 'Höflichkeit gilt vielen als Fassade, hinter der sich angeblich nichts verbirgt.',
        english: 'Many people regard politeness as a facade with supposedly nothing behind it.',
      ),
      RadioLine(
        german: 'Wer nach dem Befinden fragt, erwartet ja selten einen ausführlichen Bericht.',
        english: 'After all, someone who asks how you are is rarely expecting a detailed report.',
      ),
      RadioLine(
        german: 'Und doch wäre es ein Missverständnis, aus dieser Leere auf Unaufrichtigkeit zu schließen.',
        english: 'And yet it would be a misunderstanding to infer insincerity from that emptiness.',
      ),
      RadioLine(
        german: 'Höfliche Formeln behaupten nämlich nichts über Gefühle, sondern regeln den Abstand, in dem zwei Menschen miteinander umgehen.',
        english: 'Polite formulas make no claim about feelings; they regulate the distance at which two people deal with each other.',
      ),
      RadioLine(
        german: 'Sie sind weniger Aussage als Verkehrszeichen.',
        english: 'They are less a statement than a road sign.',
      ),
      RadioLine(
        german: 'Gerade weil sie austauschbar sind, kosten sie niemanden etwas und stehen deshalb allen offen.',
        english: 'Precisely because they are interchangeable, they cost nobody anything and are therefore available to everyone.',
      ),
      RadioLine(
        german: 'Ein Gruß im Treppenhaus verpflichtet zu nichts und schafft dennoch einen Raum, in dem man einander um Hilfe bitten kann.',
        english: 'A greeting in the stairwell commits you to nothing and still creates a space in which people can ask one another for help.',
      ),
      RadioLine(
        german: 'Auffällig wird das freilich erst, wenn die Formel fehlt.',
        english: 'Admittedly, this only becomes noticeable when the formula is missing.',
      ),
      RadioLine(
        german: 'Wer auf dem Amt ohne jeden Gruß sein Anliegen vorträgt, wirkt nicht etwa ehrlich, sondern schroff.',
        english: 'Someone who states their business at a public office without any greeting does not come across as honest, but as brusque.',
      ),
      RadioLine(
        german: 'Nun lässt sich einwenden, dass Höflichkeit Unterschiede verdeckt und Konflikte vertagt.',
        english: 'Now it might be objected that politeness covers up differences and postpones conflicts.',
      ),
      RadioLine(
        german: 'Das trifft zu, ist aber kein Einwand, denn ein vertagter Konflikt lässt sich später mit kühlerem Kopf austragen.',
        english: 'That is true, but it is no objection, since a postponed conflict can later be settled with a cooler head.',
      ),
      RadioLine(
        german: 'Entscheidend ist allein, dass die Form nicht an die Stelle der Sache tritt.',
        english: 'All that matters is that the form does not take the place of the substance.',
      ),
      RadioLine(
        german: 'Wo man einander nur noch bedauert, ohne je etwas zu ändern, wird aus der Formel tatsächlich eine Ausrede.',
        english: 'Where people merely commiserate with each other without ever changing anything, the formula really does turn into an excuse.',
      ),
      RadioLine(
        german: 'Wer die Formeln beherrscht, hat damit noch nichts gesagt, sich aber die Möglichkeit offengehalten, etwas zu sagen.',
        english: 'Mastering the formulas means you have not yet said anything, but you have kept open the possibility of saying something.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Womit vergleicht der Vortrag höfliche Formeln?',
        options: <String>[
          'Mit kurzen Verträgen',
          'Mit alten Sprichwörtern',
          'Mit Verkehrszeichen',
        ],
        correctIndex: 2,
        explanation: 'Im Vortrag heißt es, sie seien weniger Aussage als Verkehrszeichen.',
      ),
      ChoiceQuestion(
        prompt: 'Wie wirkt jemand, der auf dem Amt ohne Gruß sein Anliegen vorträgt?',
        options: <String>[
          'Schroff',
          'Ehrlich',
          'Schüchtern',
        ],
        correctIndex: 0,
        explanation: 'Ein solcher Mensch wirke nicht etwa ehrlich, sondern schroff.',
      ),
      ChoiceQuestion(
        prompt: 'Wann wird die höfliche Formel laut dem Vortrag zur Ausrede?',
        options: <String>[
          'Wenn ein Konflikt später ausgetragen wird',
          'Wenn niemand etwas ändert',
          'Wenn ein Gruß im Treppenhaus fehlt',
        ],
        correctIndex: 1,
        explanation: 'Wo man einander nur noch bedauert, ohne je etwas zu ändern, wird aus der Formel eine Ausrede.',
      ),
    ],
  ),
];
