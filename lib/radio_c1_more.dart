import 'models.dart';
import 'radio.dart';

/// C1 Gartenradio scripts, second batch.
///
/// Original text written for this app. Episodes live in one file
/// per batch so a new set of scripts is a new file rather than a
/// rewrite of a growing one.
const List<RadioEpisode> radioC1MoreEpisodes = <RadioEpisode>[
  RadioEpisode(
    id: 'rd-c1-04',
    level: CefrLevel.c1,
    genre: RadioGenre.lecture,
    title: 'Die Stadt und ihr Lärm',
    lines: <RadioLine>[
      RadioLine(
        german: 'In dieser Folge geht es um den städtischen Lärm und um die Frage, was ein Messwert überhaupt aussagt.',
        english: 'This episode is about urban noise and about the question of what a measurement actually tells us.',
      ),
      RadioLine(
        german: 'Die in Dezibel angegebene Belastung gilt als objektiv, weil sie unabhängig vom einzelnen Ohr erhoben wird.',
        english: 'Exposure given in decibels counts as objective because it is recorded independently of any individual ear.',
      ),
      RadioLine(
        german: 'Genau darin liegt jedoch die Schwäche des Verfahrens, denn ein über vierundzwanzig Stunden gebildeter Mittelwert verschweigt die kurzen, scharfen Ereignisse.',
        english: 'That is precisely where the method is weak, because an average taken over twenty-four hours hides the brief, sharp events.',
      ),
      RadioLine(
        german: 'Ein einziger nächtlicher Lastwagen kann den Schlaf empfindlicher stören als ein gleichmäßig rauschender Verkehr am Nachmittag.',
        english: 'A single lorry at night can disturb sleep more severely than the steady hum of afternoon traffic.',
      ),
      RadioLine(
        german: 'Hinzu kommt, dass wir Geräusche nicht nur nach ihrer Lautstärke, sondern auch nach ihrer vermuteten Ursache bewerten.',
        english: 'On top of that, we judge sounds not only by their volume but also by their presumed source.',
      ),
      RadioLine(
        german: 'Wer den Lärm der eigenen Werkstatt hinnimmt, empfindet dasselbe Geräusch aus der Nachbarwohnung als Zumutung.',
        english: 'Someone who accepts the noise of their own workshop finds the same sound from the flat next door intolerable.',
      ),
      RadioLine(
        german: 'Die Verwaltung der Stadt Rehberg lässt deshalb seit drei Jahren nicht nur messen, sondern auch befragen.',
        english: 'For three years, therefore, the town administration of Rehberg has been carrying out surveys as well as measurements.',
      ),
      RadioLine(
        german: 'Die dabei entstandenen Karten zeigen Straßenzüge, in denen die gemessenen Werte niedrig und die Beschwerden dennoch hoch sind.',
        english: 'The maps produced from this show streets where the measured values are low and the complaints high all the same.',
      ),
      RadioLine(
        german: 'Man sollte daraus allerdings nicht schließen, dass Messungen überflüssig geworden seien.',
        english: 'One should not conclude from this, however, that measurements have become superfluous.',
      ),
      RadioLine(
        german: 'Ohne Zahlen ließe sich weder ein Grenzwert begründen noch eine Baumaßnahme rechtfertigen.',
        english: 'Without figures, neither a limit value could be justified nor a construction measure defended.',
      ),
      RadioLine(
        german: 'Sinnvoll erscheint vielmehr, das Empfinden der Bewohner als zweite, ergänzende Quelle zu behandeln.',
        english: 'It seems more sensible to treat what residents feel as a second, complementary source.',
      ),
      RadioLine(
        german: 'Wer nur eine der beiden Quellen ernst nimmt, wird die Ruhe entweder verwalten oder beschwören, aber kaum herstellen.',
        english: 'Anyone who takes only one of the two sources seriously will end up administering or invoking quiet, but hardly creating it.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Seit wann lässt die Verwaltung in Rehberg nicht nur messen, sondern auch befragen?',
        options: <String>[
          'seit fünf Jahren',
          'seit drei Jahren',
          'seit zwei Jahren',
        ],
        correctIndex: 1,
        explanation: 'Im Vortrag heißt es, die Verwaltung der Stadt Rehberg lasse seit drei Jahren nicht nur messen, sondern auch befragen.',
      ),
      ChoiceQuestion(
        prompt: 'Was verschweigt laut Vortrag ein über vierundzwanzig Stunden gebildeter Mittelwert?',
        options: <String>[
          'die kurzen, scharfen Ereignisse',
          'die Beschwerden der Bewohner',
          'die Lage der Messgeräte',
        ],
        correctIndex: 0,
        explanation: 'Der Vortrag sagt, ein über vierundzwanzig Stunden gebildeter Mittelwert verschweige die kurzen, scharfen Ereignisse.',
      ),
      ChoiceQuestion(
        prompt: 'Welche Folgerung lehnt der Vortrag ausdrücklich ab?',
        options: <String>[
          'dass Bewohner befragt werden sollten',
          'dass Geräusche nach der Ursache bewertet werden',
          'dass Messungen überflüssig geworden seien',
        ],
        correctIndex: 2,
        explanation: 'Es wird ausdrücklich gesagt, man solle daraus nicht schließen, dass Messungen überflüssig geworden seien.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-c1-05',
    level: CefrLevel.c1,
    genre: RadioGenre.news,
    title: 'Streit um die Ladezonen',
    lines: <RadioLine>[
      RadioLine(
        german: 'Der Stadtrat von Talheim hat gestern Abend beschlossen, in der Innenstadt fünfzehn zusätzliche Ladezonen einzurichten.',
        english: 'Talheim town council decided yesterday evening to create fifteen additional loading bays in the town centre.',
      ),
      RadioLine(
        german: 'Die Zonen sollen vom kommenden März an werktags zwischen sechs und elf Uhr allein dem Lieferverkehr vorbehalten sein.',
        english: 'From next March the bays are to be reserved for delivery traffic on weekdays between six and eleven.',
      ),
      RadioLine(
        german: 'Nach Angaben der Verwaltung entfallen dafür achtzig öffentliche Parkplätze.',
        english: 'According to the administration, eighty public parking spaces will be lost as a result.',
      ),
      RadioLine(
        german: 'Der Einzelhandelsverband hält diese Rechnung für zu schlicht und verweist auf die Kundschaft aus dem Umland.',
        english: 'The retailers association considers this calculation too simple and points to customers from the surrounding area.',
      ),
      RadioLine(
        german: 'Die Sprecherin des Verbands, Ines Marquardt, warnte vor Umsatzverlusten in den ohnehin schwachen Wintermonaten.',
        english: 'The association spokeswoman, Ines Marquardt, warned of lost turnover in the already weak winter months.',
      ),
      RadioLine(
        german: 'Die Verwaltung hält dem entgegen, dass in zweiter Reihe haltende Lieferwagen den Verkehr bislang stärker behinderten als fehlende Stellplätze.',
        english: 'The administration counters that double-parked delivery vans have so far obstructed traffic more than a shortage of spaces.',
      ),
      RadioLine(
        german: 'Eine im Frühjahr durchgeführte Zählung ergab an einem einzigen Vormittag zweihundertvierzig solcher Halte in der Brunnenstraße.',
        english: 'A count carried out in spring recorded two hundred and forty such stops on Brunnenstraße in a single morning.',
      ),
      RadioLine(
        german: 'Belastbare Erfahrungen aus vergleichbaren Städten liegen bisher allerdings nur in geringem Umfang vor.',
        english: 'Reliable experience from comparable towns is so far available only to a limited extent.',
      ),
      RadioLine(
        german: 'Der Beschluss ist deshalb zunächst auf achtzehn Monate befristet worden.',
        english: 'The decision has therefore been limited to eighteen months for the time being.',
      ),
      RadioLine(
        german: 'Danach soll ein Bericht sowohl den Lieferverkehr als auch die Umsätze der angrenzenden Geschäfte bewerten.',
        english: 'After that, a report is to assess both delivery traffic and the turnover of the neighbouring shops.',
      ),
      RadioLine(
        german: 'Kritik kam auch aus dem Ortsteil Sandhofen, dessen Bewohner eine Verlagerung des Parkdrucks befürchten.',
        english: 'Criticism also came from the Sandhofen district, whose residents fear that parking pressure will simply move.',
      ),
      RadioLine(
        german: 'Die Verwaltung sagte zu, die Wirkung auf die Wohnstraßen gesondert zu beobachten.',
        english: 'The administration promised to monitor the effect on residential streets separately.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie viele öffentliche Parkplätze entfallen nach Angaben der Verwaltung?',
        options: <String>[
          'sechzig',
          'achtzig',
          'hundertzwanzig',
        ],
        correctIndex: 1,
        explanation: 'Nach Angaben der Verwaltung entfallen achtzig öffentliche Parkplätze.',
      ),
      ChoiceQuestion(
        prompt: 'Auf welchen Zeitraum ist der Beschluss zunächst befristet?',
        options: <String>[
          'auf achtzehn Monate',
          'auf zwölf Monate',
          'auf zwei Jahre',
        ],
        correctIndex: 0,
        explanation: 'Der Beschluss ist zunächst auf achtzehn Monate befristet worden.',
      ),
      ChoiceQuestion(
        prompt: 'Was ergab die Zählung in der Brunnenstraße an einem Vormittag?',
        options: <String>[
          'achtzig Halte in zweiter Reihe',
          'hundertfünfzig Halte in zweiter Reihe',
          'zweihundertvierzig Halte in zweiter Reihe',
        ],
        correctIndex: 2,
        explanation: 'Eine im Frühjahr durchgeführte Zählung ergab an einem einzigen Vormittag zweihundertvierzig solcher Halte.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-c1-06',
    level: CefrLevel.c1,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Der Uhrensaal',
    lines: <RadioLine>[
      RadioLine(
        german: 'Sie stehen nun im Uhrensaal, dem ältesten erhaltenen Raum dieses Hauses.',
        english: 'You are now standing in the clock hall, the oldest surviving room in this building.',
      ),
      RadioLine(
        german: 'Die hier gezeigten Werke stammen aus den Werkstätten der Familie Bergedorf, die den Ort über vier Generationen prägte.',
        english: 'The works shown here come from the workshops of the Bergedorf family, who shaped the town over four generations.',
      ),
      RadioLine(
        german: 'Beachten Sie vor allem die große Pendeluhr an der Stirnwand, ein 1874 vollendetes Stück von bemerkenswerter Genauigkeit.',
        english: 'Note above all the large pendulum clock on the end wall, a piece of remarkable accuracy completed in 1874.',
      ),
      RadioLine(
        german: 'Ihre Abweichung betrug im Prüfjahr weniger als zwei Sekunden in der Woche.',
        english: 'In the year it was tested, its deviation was less than two seconds a week.',
      ),
      RadioLine(
        german: 'Solche Werte waren keine Spielerei, denn die Eisenbahn verlangte eine überall gleich laufende Zeit.',
        english: 'Such figures were no plaything, since the railway required a time that ran the same everywhere.',
      ),
      RadioLine(
        german: 'Mit der Vereinheitlichung der Zeit setzte sich zugleich ein neues Verständnis von Pünktlichkeit durch.',
        english: 'Along with the standardisation of time, a new understanding of punctuality took hold.',
      ),
      RadioLine(
        german: 'Man sollte die Umstellung dennoch nicht als bloßen Fortschritt beschreiben.',
        english: 'Even so, the change should not be described as mere progress.',
      ),
      RadioLine(
        german: 'Für die Weber im Tal bedeutete die genau vermessene Stunde auch eine schärfere Kontrolle ihrer Arbeit.',
        english: 'For the weavers in the valley, the precisely measured hour also meant tighter control of their work.',
      ),
      RadioLine(
        german: 'Die in der Vitrine rechts liegenden Lohnbücher lassen diese Verschiebung deutlich erkennen.',
        english: 'The wage books lying in the display case to your right make this shift clearly visible.',
      ),
      RadioLine(
        german: 'Sie werden dort neben den Stundenangaben zahlreiche nachträglich eingetragene Abzüge finden.',
        english: 'Beside the recorded hours you will find numerous deductions entered after the fact.',
      ),
      RadioLine(
        german: 'Wie streng diese Regeln tatsächlich angewandt wurden, lässt sich aus den erhaltenen Unterlagen jedoch nicht sicher ableiten.',
        english: 'How strictly these rules were actually applied cannot be established with certainty from the surviving records.',
      ),
      RadioLine(
        german: 'Der Rundgang wird im nächsten Saal mit den Werkzeugen der Uhrmacher fortgesetzt.',
        english: 'The tour continues in the next hall with the tools of the clockmakers.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie groß war die Abweichung der großen Pendeluhr im Prüfjahr?',
        options: <String>[
          'weniger als zwei Minuten im Monat',
          'weniger als zehn Sekunden am Tag',
          'weniger als zwei Sekunden in der Woche',
        ],
        correctIndex: 2,
        explanation: 'Die Abweichung der Pendeluhr betrug im Prüfjahr weniger als zwei Sekunden in der Woche.',
      ),
      ChoiceQuestion(
        prompt: 'Was liegt in der Vitrine rechts?',
        options: <String>[
          'Werkzeuge der Uhrmacher',
          'Lohnbücher',
          'Zeichnungen der Werkstatt',
        ],
        correctIndex: 1,
        explanation: 'Der Audioguide verweist auf die in der Vitrine rechts liegenden Lohnbücher.',
      ),
      ChoiceQuestion(
        prompt: 'Warum waren so genaue Uhren laut Audioguide keine Spielerei?',
        options: <String>[
          'weil die Eisenbahn eine überall gleich laufende Zeit verlangte',
          'weil die Weber im Tal sie bestellten',
          'weil das Museum sie prüfen ließ',
        ],
        correctIndex: 0,
        explanation: 'Es heißt, die Eisenbahn habe eine überall gleich laufende Zeit verlangt.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-c1-07',
    level: CefrLevel.c1,
    genre: RadioGenre.lecture,
    title: 'Was Karten verschweigen',
    lines: <RadioLine>[
      RadioLine(
        german: 'Karten gelten als nüchterne Abbilder der Welt, und gerade deshalb wirken sie so überzeugend.',
        english: 'Maps are taken to be sober images of the world, and that is exactly why they are so persuasive.',
      ),
      RadioLine(
        german: 'Tatsächlich beruht jede Karte auf einer Reihe von Entscheidungen, die im fertigen Blatt nicht mehr sichtbar sind.',
        english: 'In fact every map rests on a series of decisions that are no longer visible in the finished sheet.',
      ),
      RadioLine(
        german: 'Weggelassen wird stets mehr, als dargestellt werden kann.',
        english: 'More is always left out than can be shown.',
      ),
      RadioLine(
        german: 'Der Maßstab bestimmt dabei nicht nur die Größe, sondern auch, welche Orte überhaupt einen Namen behalten.',
        english: 'The scale determines not only size but also which places keep a name at all.',
      ),
      RadioLine(
        german: 'Ein Weiler von vierzig Einwohnern verschwindet, sobald das Blatt eine ganze Region fassen soll.',
        english: 'A hamlet of forty inhabitants disappears as soon as a sheet has to cover a whole region.',
      ),
      RadioLine(
        german: 'Ebenso folgenreich ist die Wahl der Farben, denn eine kräftig eingefärbte Fläche wird als bedeutend gelesen.',
        english: 'The choice of colours matters just as much, since a strongly coloured area is read as important.',
      ),
      RadioLine(
        german: 'Wer Wanderwege rot und Wirtschaftswege grau zeichnet, hat die Landschaft bereits gedeutet.',
        english: 'Anyone who draws hiking paths in red and farm tracks in grey has already interpreted the landscape.',
      ),
      RadioLine(
        german: 'Daraus folgt jedoch nicht, dass Karten beliebig oder gar unehrlich wären.',
        english: 'It does not follow, however, that maps are arbitrary or even dishonest.',
      ),
      RadioLine(
        german: 'Eine Auswahl zu treffen ist keine Verfälschung, sondern die Bedingung dafür, dass eine Darstellung lesbar bleibt.',
        english: 'Making a selection is not a falsification but the very condition of a depiction remaining legible.',
      ),
      RadioLine(
        german: 'Problematisch wird es erst dort, wo die getroffene Auswahl weder erklärt noch begründet wird.',
        english: 'It only becomes a problem where the selection made is neither explained nor justified.',
      ),
      RadioLine(
        german: 'Empfehlenswert ist deshalb ein Blick auf die Legende, die über Zweck und Herkunft eines Blattes mehr verrät als die Fläche selbst.',
        english: 'It is therefore worth looking at the key, which reveals more about a sheet\'s purpose and origin than the map area itself.',
      ),
      RadioLine(
        german: 'Wer eine Karte so liest, gewinnt neben der Orientierung auch ein Urteil über ihre Grenzen.',
        english: 'Reading a map in this way gives you orientation and a sense of its limits at the same time.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was verschwindet laut Vortrag, sobald ein Blatt eine ganze Region fassen soll?',
        options: <String>[
          'ein Weiler von vierzig Einwohnern',
          'eine Straße mit vierzig Häusern',
          'ein Fluss von vierzig Kilometern',
        ],
        correctIndex: 0,
        explanation: 'Ein Weiler von vierzig Einwohnern verschwindet, sobald das Blatt eine ganze Region fassen soll.',
      ),
      ChoiceQuestion(
        prompt: 'Wann wird die Auswahl auf einer Karte laut Vortrag problematisch?',
        options: <String>[
          'wenn sie zu viele Orte zeigt',
          'wenn sie weder erklärt noch begründet wird',
          'wenn sie kräftige Farben benutzt',
        ],
        correctIndex: 1,
        explanation: 'Problematisch werde es erst dort, wo die getroffene Auswahl weder erklärt noch begründet werde.',
      ),
      ChoiceQuestion(
        prompt: 'Worauf sollte man beim Lesen einer Karte besonders achten?',
        options: <String>[
          'auf den Maßstab am Rand',
          'auf die Farbe der Wege',
          'auf die Legende',
        ],
        correctIndex: 2,
        explanation: 'Empfehlenswert sei ein Blick auf die Legende, die über Zweck und Herkunft eines Blattes mehr verrate als die Fläche selbst.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-c1-08',
    level: CefrLevel.c1,
    genre: RadioGenre.news,
    title: 'Fahrplanwechsel mit Folgen',
    lines: <RadioLine>[
      RadioLine(
        german: 'Mit dem Fahrplanwechsel am zweiten Dezember verdichtet der Regionalverkehr Ostmark den Takt auf der Strecke zwischen Ahlbeck und Grünstedt.',
        english: 'With the timetable change on the second of December, Regionalverkehr Ostmark is increasing the frequency between Ahlbeck and Grünstedt.',
      ),
      RadioLine(
        german: 'Züge fahren dann montags bis freitags halbstündlich statt wie bisher stündlich.',
        english: 'Trains will then run every half hour from Monday to Friday instead of hourly as before.',
      ),
      RadioLine(
        german: 'Möglich wird das durch das im Sommer fertiggestellte zweite Gleis bei Marnitz.',
        english: 'This is made possible by the second track near Marnitz, completed in the summer.',
      ),
      RadioLine(
        german: 'Für die Fahrgäste der Nebenstrecke nach Sellin bedeutet der neue Plan allerdings eine Verschlechterung.',
        english: 'For passengers on the branch line to Sellin, however, the new plan means a step backwards.',
      ),
      RadioLine(
        german: 'Zwei am späten Abend verkehrende Verbindungen entfallen ersatzlos.',
        english: 'Two late evening services are being dropped without replacement.',
      ),
      RadioLine(
        german: 'Der Verkehrsverbund begründet den Schritt mit der geringen Auslastung von durchschnittlich elf Reisenden je Fahrt.',
        english: 'The transport authority justifies the move by the low occupancy of eleven passengers per journey on average.',
      ),
      RadioLine(
        german: 'Die Gemeinde Sellin hat dagegen Widerspruch angekündigt und verweist auf die Beschäftigten der Kliniken im Ort.',
        english: 'The municipality of Sellin has announced an objection and points to the staff of the clinics in the town.',
      ),
      RadioLine(
        german: 'Deren Schichten enden nach Angaben der Verwaltung regelmäßig erst gegen zweiundzwanzig Uhr.',
        english: 'According to the administration, their shifts regularly end only around ten in the evening.',
      ),
      RadioLine(
        german: 'Ob ein Rufbus die entfallenden Züge ersetzen kann, wird derzeit geprüft.',
        english: 'Whether an on-demand bus can replace the cancelled trains is currently being examined.',
      ),
      RadioLine(
        german: 'Eine Entscheidung darüber soll bis Ende November fallen.',
        english: 'A decision on this is due by the end of November.',
      ),
      RadioLine(
        german: 'Unstrittig ist unterdessen, dass der dichtere Takt auf der Hauptstrecke seit Jahren gefordert wurde.',
        english: 'Meanwhile there is no dispute that the denser service on the main line has been demanded for years.',
      ),
      RadioLine(
        german: 'Über die Verteilung der Mittel zwischen starken und schwachen Strecken dürfte damit jedoch nicht das letzte Wort gesprochen sein.',
        english: 'On the distribution of funds between strong and weak lines, though, the last word has probably not been spoken.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie oft fahren die Züge zwischen Ahlbeck und Grünstedt künftig werktags?',
        options: <String>[
          'stündlich',
          'halbstündlich',
          'alle zwanzig Minuten',
        ],
        correctIndex: 1,
        explanation: 'Die Züge fahren montags bis freitags künftig halbstündlich statt wie bisher stündlich.',
      ),
      ChoiceQuestion(
        prompt: 'Womit begründet der Verkehrsverbund den Wegfall der Abendverbindungen?',
        options: <String>[
          'mit der geringen Auslastung',
          'mit Bauarbeiten bei Marnitz',
          'mit fehlendem Personal',
        ],
        correctIndex: 0,
        explanation: 'Der Verkehrsverbund begründet den Schritt mit der geringen Auslastung von durchschnittlich elf Reisenden je Fahrt.',
      ),
      ChoiceQuestion(
        prompt: 'Bis wann soll über den Rufbus entschieden werden?',
        options: <String>[
          'bis Ende Oktober',
          'bis Anfang Dezember',
          'bis Ende November',
        ],
        correctIndex: 2,
        explanation: 'Eine Entscheidung über den Rufbus soll bis Ende November fallen.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-c1-09',
    level: CefrLevel.c1,
    genre: RadioGenre.lecture,
    title: 'Vom Reparieren',
    lines: <RadioLine>[
      RadioLine(
        german: 'Das Reparieren gilt gegenwärtig als Tugend, und tatsächlich spricht vieles für seine Wiederentdeckung.',
        english: 'Repairing is currently regarded as a virtue, and there is indeed much to be said for its revival.',
      ),
      RadioLine(
        german: 'Ein Gerät, das nach acht Jahren wieder in Gang gesetzt wird, spart die gesamte Herstellung eines neuen ein.',
        english: 'A device put back into working order after eight years saves the entire manufacture of a new one.',
      ),
      RadioLine(
        german: 'Die dabei vermiedenen Belastungen fallen deutlicher ins Gewicht als der Verbrauch im laufenden Betrieb.',
        english: 'The burdens avoided in this way weigh more heavily than consumption during everyday use.',
      ),
      RadioLine(
        german: 'Gegen diese Rechnung wird häufig eingewandt, ältere Geräte verbrauchten im Betrieb mehr Strom.',
        english: 'Against this calculation it is often objected that older appliances use more electricity in operation.',
      ),
      RadioLine(
        german: 'Der Einwand trifft zu, betrifft aber vor allem Kühlgeräte und kaum den Toaster oder die Lampe.',
        english: 'The objection is correct, but it applies mainly to fridges and hardly to a toaster or a lamp.',
      ),
      RadioLine(
        german: 'Entscheidend ist deshalb weniger die Frage nach dem Alter als die nach der Bauart.',
        english: 'What matters, therefore, is less the age of a device than the way it is built.',
      ),
      RadioLine(
        german: 'Ein mit gewöhnlichen Schrauben verbundenes Gehäuse lässt sich öffnen, ein verklebtes hingegen nur zerstören.',
        english: 'A casing held together by ordinary screws can be opened, whereas a glued one can only be destroyed.',
      ),
      RadioLine(
        german: 'In der Reparaturwerkstatt des Vereins Handgriff in Weidenau scheitern nach eigenen Angaben vier von zehn Versuchen an fehlenden Ersatzteilen.',
        english: 'In the repair workshop of the Handgriff association in Weidenau, by its own account, four out of ten attempts fail for lack of spare parts.',
      ),
      RadioLine(
        german: 'Damit verschiebt sich die Verantwortung von den Nutzern zu den Herstellern.',
        english: 'This shifts responsibility from users to manufacturers.',
      ),
      RadioLine(
        german: 'Man sollte die Werkstätten dennoch nicht überfordern.',
        english: 'Even so, the workshops should not be asked to do too much.',
      ),
      RadioLine(
        german: 'Sie können die Lebensdauer einzelner Geräte verlängern, die Entscheidungen der Konstruktion aber nicht rückgängig machen.',
        english: 'They can extend the life of individual devices, but they cannot undo decisions taken in the design.',
      ),
      RadioLine(
        german: 'Wer dauerhaft weniger wegwerfen will, muss schon beim Entwurf ansetzen und nicht erst beim Schraubenzieher.',
        english: 'Anyone who wants to throw less away for good has to start at the design stage, not at the screwdriver.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Woran scheitern in der Werkstatt in Weidenau vier von zehn Versuchen?',
        options: <String>[
          'an fehlenden Ersatzteilen',
          'an verklebten Gehäusen',
          'an fehlender Zeit',
        ],
        correctIndex: 0,
        explanation: 'In der Reparaturwerkstatt in Weidenau scheitern nach eigenen Angaben vier von zehn Versuchen an fehlenden Ersatzteilen.',
      ),
      ChoiceQuestion(
        prompt: 'Für welche Geräte trifft der Einwand zum Stromverbrauch vor allem zu?',
        options: <String>[
          'für Lampen',
          'für Toaster',
          'für Kühlgeräte',
        ],
        correctIndex: 2,
        explanation: 'Der Einwand treffe zu, betreffe aber vor allem Kühlgeräte und kaum den Toaster oder die Lampe.',
      ),
      ChoiceQuestion(
        prompt: 'Was ist laut Vortrag entscheidender als das Alter eines Geräts?',
        options: <String>[
          'der Preis',
          'die Bauart',
          'der Ort der Reparatur',
        ],
        correctIndex: 1,
        explanation: 'Entscheidend sei weniger die Frage nach dem Alter als die nach der Bauart.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-c1-10',
    level: CefrLevel.c1,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Der Wasserturm von Lindhorst',
    lines: <RadioLine>[
      RadioLine(
        german: 'Sie befinden sich am Fuß des Wasserturms von Lindhorst, der die Stadt von 1902 an mit Druck versorgte.',
        english: 'You are standing at the foot of the Lindhorst water tower, which supplied the town with pressure from 1902 onwards.',
      ),
      RadioLine(
        german: 'Der über dreißig Meter hohe Bau wirkt heute vor allem als Wahrzeichen.',
        english: 'Today the structure, over thirty metres high, works mainly as a landmark.',
      ),
      RadioLine(
        german: 'Seine Aufgabe war jedoch eine nüchterne, nämlich den Druck im Leitungsnetz gleichmäßig zu halten.',
        english: 'Its task, though, was a sober one, namely to keep the pressure in the pipe network steady.',
      ),
      RadioLine(
        german: 'Der in Ziegeln ausgeführte Schaft trägt einen Behälter, der bis zu vierhundert Kubikmeter fasste.',
        english: 'The brick shaft carries a tank that held up to four hundred cubic metres.',
      ),
      RadioLine(
        german: 'Bemerkenswert ist, dass die Anlage ohne dauerhaft laufende Pumpen auskam.',
        english: 'Remarkably, the installation managed without permanently running pumps.',
      ),
      RadioLine(
        german: 'Gefüllt wurde der Behälter in der Nacht, wenn die Stadt wenig Wasser entnahm.',
        english: 'The tank was filled at night, when the town drew little water.',
      ),
      RadioLine(
        german: 'Man erklärt solche Bauten gern allein aus der Technik ihrer Zeit.',
        english: 'Buildings like this are often explained purely by the technology of their time.',
      ),
      RadioLine(
        german: 'Ebenso wichtig war aber der Wunsch der Gemeinde, ihre Versorgung sichtbar in eigener Hand zu halten.',
        english: 'Just as important, however, was the community\'s wish to keep its supply visibly in its own hands.',
      ),
      RadioLine(
        german: 'Deshalb wurde der Turm nicht am Rand, sondern auf dem höchsten Punkt des Marktviertels errichtet.',
        english: 'That is why the tower was built not on the outskirts but on the highest point of the market quarter.',
      ),
      RadioLine(
        german: 'Sein Betrieb endete 1968, als ein Pumpwerk am Fluss die Aufgabe übernahm.',
        english: 'Its operation ended in 1968, when a pumping station by the river took over the task.',
      ),
      RadioLine(
        german: 'Ob der Behälter je vollständig gefüllt worden ist, geht aus den erhaltenen Betriebsbüchern nicht hervor.',
        english: 'Whether the tank was ever completely filled cannot be determined from the surviving operating logs.',
      ),
      RadioLine(
        german: 'Bitte folgen Sie dem Weg nun zur ehemaligen Pumpenhalle auf der Rückseite des Geländes.',
        english: 'Please now follow the path to the former pump hall at the back of the site.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann endete der Betrieb des Wasserturms?',
        options: <String>[
          '1955',
          '1968',
          '1902',
        ],
        correctIndex: 1,
        explanation: 'Der Betrieb des Turms endete 1968, als ein Pumpwerk am Fluss die Aufgabe übernahm.',
      ),
      ChoiceQuestion(
        prompt: 'Wann wurde der Behälter gefüllt?',
        options: <String>[
          'in der Nacht',
          'am frühen Morgen',
          'am Nachmittag',
        ],
        correctIndex: 0,
        explanation: 'Gefüllt wurde der Behälter in der Nacht, wenn die Stadt wenig Wasser entnahm.',
      ),
      ChoiceQuestion(
        prompt: 'Warum steht der Turm auf dem höchsten Punkt des Marktviertels?',
        options: <String>[
          'wegen des festen Baugrunds',
          'wegen der Nähe zum Fluss',
          'wegen des Wunsches nach sichtbarer eigener Versorgung',
        ],
        correctIndex: 2,
        explanation: 'Genannt wird der Wunsch der Gemeinde, ihre Versorgung sichtbar in eigener Hand zu halten.',
      ),
    ],
  ),
];
