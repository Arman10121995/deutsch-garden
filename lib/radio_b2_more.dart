import 'models.dart';
import 'radio.dart';

/// B2 Gartenradio scripts, second batch.
///
/// Original text written for this app. Episodes live in one file
/// per batch so a new set of scripts is a new file rather than a
/// rewrite of a growing one.
const List<RadioEpisode> radioB2MoreEpisodes = <RadioEpisode>[
  RadioEpisode(
    id: 'rd-b2-06',
    level: CefrLevel.b2,
    genre: RadioGenre.news,
    title: 'Grundwasser unter Beobachtung',
    lines: <RadioLine>[
      RadioLine(
        german: 'Im Landkreis Weiherbach sind die Grundwasserstände nach Angaben des Umweltamts den vierten Sommer in Folge gesunken.',
        english: 'In the Weiherbach district, groundwater levels have fallen for the fourth summer in a row, according to the environmental office.',
      ),
      RadioLine(
        german: 'Zwar habe der Mai überdurchschnittlich viel Regen gebracht, sagte Amtsleiterin Carola Rieth, doch die tieferen Schichten seien davon kaum erreicht worden.',
        english: 'May did bring above-average rainfall, said office head Carola Rieth, but the deeper layers were hardly reached by it.',
      ),
      RadioLine(
        german: 'Ab dem ersten September gilt deshalb eine eingeschränkte Entnahme aus öffentlichen Brunnen.',
        english: 'From the first of September, therefore, restricted withdrawal from public wells will apply.',
      ),
      RadioLine(
        german: 'Betroffen sind vor allem die Kleingartenvereine, deren Bewässerung künftig auf die frühen Morgenstunden beschränkt wird.',
        english: 'Affected above all are the allotment associations, whose watering will in future be limited to the early morning hours.',
      ),
      RadioLine(
        german: 'Der Verband der Gartenfreunde kritisiert die Regelung als zu pauschal.',
        english: 'The gardeners\' association criticises the rule as too sweeping.',
      ),
      RadioLine(
        german: 'Nach seiner Darstellung werde die Landwirtschaft deutlich milder behandelt.',
        english: 'In its account, farming is being treated considerably more leniently.',
      ),
      RadioLine(
        german: 'Das Umweltamt weist diesen Vorwurf allerdings zurück und verweist auf laufende Messungen.',
        english: 'The environmental office, however, rejects that accusation and points to measurements still underway.',
      ),
      RadioLine(
        german: 'Eine abschließende Bewertung sei vor Oktober nicht zu erwarten.',
        english: 'A final assessment, it says, is not to be expected before October.',
      ),
      RadioLine(
        german: 'Offenbar hängt vieles vom Niederschlag der kommenden Wochen ab.',
        english: 'Evidently a great deal depends on the rainfall of the coming weeks.',
      ),
      RadioLine(
        german: 'Über die Verlängerung der Maßnahme wird der Kreistag im November entscheiden.',
        english: 'The district council will decide in November on extending the measure.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie lange sinken die Grundwasserstände laut Umweltamt bereits?',
        options: <String>[
          'Den zweiten Sommer in Folge',
          'Den vierten Sommer in Folge',
          'Den sechsten Sommer in Folge',
        ],
        correctIndex: 1,
        explanation: 'Gleich zu Beginn heißt es, die Grundwasserstände seien den vierten Sommer in Folge gesunken.',
      ),
      ChoiceQuestion(
        prompt: 'Wer ist von der eingeschränkten Bewässerung vor allem betroffen?',
        options: <String>[
          'Die Kleingartenvereine',
          'Die städtischen Schwimmbäder',
          'Die Betreiber der Baustellen',
        ],
        correctIndex: 0,
        explanation: 'Betroffen sind vor allem die Kleingartenvereine, deren Bewässerung auf die frühen Morgenstunden beschränkt wird.',
      ),
      ChoiceQuestion(
        prompt: 'Wann wird über eine Verlängerung der Maßnahme entschieden?',
        options: <String>[
          'Im September',
          'Im Oktober',
          'Im November',
        ],
        correctIndex: 2,
        explanation: 'Über die Verlängerung der Maßnahme entscheidet der Kreistag im November.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-07',
    level: CefrLevel.b2,
    genre: RadioGenre.lecture,
    title: 'Lärm im Großraumbüro',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen zur heutigen Folge unserer Reihe über Arbeitsumgebungen.',
        english: 'Welcome to today\'s episode of our series on working environments.',
      ),
      RadioLine(
        german: 'Großraumbüros wurden ursprünglich mit dem Versprechen kürzerer Wege und besserer Zusammenarbeit eingeführt.',
        english: 'Open-plan offices were originally introduced with the promise of shorter distances and better collaboration.',
      ),
      RadioLine(
        german: 'Untersuchungen einer Fachhochschule in Lindau legen jedoch nahe, dass vor allem die akustische Belastung unterschätzt wurde.',
        english: 'Studies at a university of applied sciences in Lindau suggest, however, that the acoustic burden in particular was underestimated.',
      ),
      RadioLine(
        german: 'Entscheidend sei nicht die Lautstärke an sich, sondern die Verständlichkeit fremder Gespräche, heißt es in dem Bericht.',
        english: 'What matters, the report states, is not volume as such but how intelligible other people\'s conversations are.',
      ),
      RadioLine(
        german: 'Wer Sprache versteht, kann sie bekanntlich schlechter ausblenden als ein gleichmäßiges Rauschen.',
        english: 'As is well known, speech you can understand is harder to tune out than a steady background hum.',
      ),
      RadioLine(
        german: 'Die befragten Beschäftigten gaben an, für konzentrierte Aufgaben durchschnittlich zwanzig Minuten länger zu benötigen.',
        english: 'The employees surveyed reported needing on average twenty minutes longer for tasks requiring concentration.',
      ),
      RadioLine(
        german: 'Trennwände allein bringen offenbar wenig, solange die Decken den Schall zurückwerfen.',
        english: 'Partitions alone apparently achieve little as long as the ceilings reflect the sound.',
      ),
      RadioLine(
        german: 'Empfohlen werden deshalb Rückzugsräume, klare Absprachen über Telefonate und schallschluckende Materialien.',
        english: 'Quiet rooms, clear agreements about phone calls and sound-absorbing materials are therefore recommended.',
      ),
      RadioLine(
        german: 'Ob sich der Aufwand rechnet, ist allerdings schwer zu belegen.',
        english: 'Whether the outlay pays off is admittedly hard to prove.',
      ),
      RadioLine(
        german: 'Denn Konzentration lässt sich nur schwer in Zahlen fassen.',
        english: 'After all, concentration is difficult to capture in figures.',
      ),
      RadioLine(
        german: 'Im nächsten Teil geht es um die Frage, wie Pausen gestaltet werden.',
        english: 'The next part will look at the question of how breaks are organised.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was ist laut dem Bericht für die Belastung entscheidend?',
        options: <String>[
          'Die Höhe der Trennwände zwischen den Tischen',
          'Die Verständlichkeit fremder Gespräche',
          'Die Lautstärke der Lüftung',
        ],
        correctIndex: 1,
        explanation: 'Entscheidend sei nicht die Lautstärke an sich, sondern die Verständlichkeit fremder Gespräche.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viel länger brauchten die Befragten für konzentrierte Aufgaben?',
        options: <String>[
          'Zehn Minuten',
          'Fünfzehn Minuten',
          'Zwanzig Minuten',
        ],
        correctIndex: 2,
        explanation: 'Die Beschäftigten gaben an, durchschnittlich zwanzig Minuten länger zu benötigen.',
      ),
      ChoiceQuestion(
        prompt: 'Womit beschäftigt sich der nächste Teil der Reihe?',
        options: <String>[
          'Mit der Gestaltung von Pausen',
          'Mit der Miete von Büroräumen',
          'Mit der Auswahl neuer Möbel',
        ],
        correctIndex: 0,
        explanation: 'Am Ende heißt es, im nächsten Teil gehe es darum, wie Pausen gestaltet werden.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-08',
    level: CefrLevel.b2,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Der Plakatsaal',
    lines: <RadioLine>[
      RadioLine(
        german: 'Sie stehen nun im Plakatsaal im zweiten Obergeschoss.',
        english: 'You are now standing in the poster hall on the second floor.',
      ),
      RadioLine(
        german: 'Gezeigt werden hier etwa vierzig Werbeplakate aus den Beständen einer Druckerei, die 1978 geschlossen wurde.',
        english: 'On display here are around forty advertising posters from the holdings of a printing works that closed in 1978.',
      ),
      RadioLine(
        german: 'Die Blätter wurden lange als reine Gebrauchsware betrachtet und deshalb selten aufbewahrt.',
        english: 'For a long time these sheets were regarded as mere consumables and were therefore rarely kept.',
      ),
      RadioLine(
        german: 'Erst mit ihrer Seltenheit wuchs das Interesse der Sammlungen.',
        english: 'Only as they became rare did collections begin to take an interest.',
      ),
      RadioLine(
        german: 'Auffällig ist die Sprache: Versprochen wird nicht ein Produkt, sondern ein Lebensgefühl.',
        english: 'The language is striking: what is promised is not a product but a way of feeling about life.',
      ),
      RadioLine(
        german: 'Bitte beachten Sie links das Plakat für eine Seifenmarke aus dem Jahr 1961.',
        english: 'Please note the poster on your left for a soap brand from 1961.',
      ),
      RadioLine(
        german: 'Der Entwurf stammt von einer Grafikerin, deren Name erst vor wenigen Jahren geklärt werden konnte.',
        english: 'The design is by a graphic artist whose name could only be established a few years ago.',
      ),
      RadioLine(
        german: 'Zwar wirkt die Bildsprache heute harmlos, doch die Rollenbilder verdienen einen zweiten Blick.',
        english: 'The visual language may seem harmless today, yet the gender roles deserve a second look.',
      ),
      RadioLine(
        german: 'Kritiker sehen darin bis heute ein Musterbeispiel für stille Erziehung durch Werbung.',
        english: 'Critics still see in it a textbook case of quiet instruction through advertising.',
      ),
      RadioLine(
        german: 'Für die Fortsetzung folgen Sie bitte dem grünen Pfeil zur Treppe.',
        english: 'To continue, please follow the green arrow to the staircase.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Woher stammen die gezeigten Plakate?',
        options: <String>[
          'Aus dem Nachlass eines Sammlers aus der Region',
          'Aus den Beständen einer Druckerei',
          'Aus dem Archiv der Stadtverwaltung',
        ],
        correctIndex: 1,
        explanation: 'Gezeigt werden Werbeplakate aus den Beständen einer Druckerei, die 1978 geschlossen wurde.',
      ),
      ChoiceQuestion(
        prompt: 'Aus welchem Jahr stammt das Plakat für die Seifenmarke?',
        options: <String>[
          'Aus dem Jahr 1961',
          'Aus dem Jahr 1971',
          'Aus dem Jahr 1978',
        ],
        correctIndex: 0,
        explanation: 'Links hängt das Plakat für eine Seifenmarke aus dem Jahr 1961.',
      ),
      ChoiceQuestion(
        prompt: 'Wie geht der Rundgang weiter?',
        options: <String>[
          'Man nimmt den Aufzug ins Erdgeschoss',
          'Man geht nach rechts durch den Lesesaal',
          'Man folgt dem grünen Pfeil zur Treppe',
        ],
        correctIndex: 2,
        explanation: 'Für die Fortsetzung soll man dem grünen Pfeil zur Treppe folgen.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-09',
    level: CefrLevel.b2,
    genre: RadioGenre.announcement,
    title: 'Hinweis im Bürgeramt',
    lines: <RadioLine>[
      RadioLine(
        german: 'Sehr geehrte Besucherinnen und Besucher, wir bitten um Ihre Aufmerksamkeit.',
        english: 'Dear visitors, may we have your attention please.',
      ),
      RadioLine(
        german: 'Ab kommendem Montag werden im Bürgeramt Schwanenstraße ausschließlich vereinbarte Termine bearbeitet.',
        english: 'From next Monday, only booked appointments will be handled at the Schwanenstraße citizens\' office.',
      ),
      RadioLine(
        german: 'Die Umstellung war ursprünglich für den Herbst geplant, wurde wegen des Umbaus jedoch vorgezogen.',
        english: 'The changeover was originally planned for the autumn but has been brought forward because of the building work.',
      ),
      RadioLine(
        german: 'Termine können über das Online-Portal der Stadt oder telefonisch vereinbart werden.',
        english: 'Appointments can be booked through the city\'s online portal or by telephone.',
      ),
      RadioLine(
        german: 'Wer keinen Zugang zum Internet hat, wird selbstverständlich weiterhin am Empfang unterstützt.',
        english: 'Anyone without internet access will of course continue to receive help at reception.',
      ),
      RadioLine(
        german: 'Für die Anmeldung des Wohnsitzes wird künftig eine Bearbeitungszeit von zehn Minuten eingeplant.',
        english: 'For registering a place of residence, a processing time of ten minutes will be scheduled in future.',
      ),
      RadioLine(
        german: 'Die Ausgabe von Ausweisdokumenten erfolgt ab sofort ausschließlich am Schalter vier.',
        english: 'Identity documents are issued exclusively at counter four with immediate effect.',
      ),
      RadioLine(
        german: 'Zwar rechnen wir in den ersten Wochen mit längeren Wartezeiten, dennoch soll der Andrang insgesamt zurückgehen.',
        english: 'We do expect longer waiting times in the first few weeks, yet overall the crowding is meant to decrease.',
      ),
      RadioLine(
        german: 'Nach Einschätzung der Amtsleitung werde sich das Verfahren bis Jahresende eingespielt haben.',
        english: 'In the view of the office management, the procedure will have settled in by the end of the year.',
      ),
      RadioLine(
        german: 'Wir danken für Ihr Verständnis und Ihre Geduld.',
        english: 'Thank you for your understanding and your patience.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Warum wurde die Umstellung vorgezogen?',
        options: <String>[
          'Wegen des Umbaus',
          'Wegen der Ferienzeit',
          'Wegen einer neuen Verordnung',
        ],
        correctIndex: 0,
        explanation: 'Die Umstellung war für den Herbst geplant, wurde wegen des Umbaus jedoch vorgezogen.',
      ),
      ChoiceQuestion(
        prompt: 'Wo werden Ausweisdokumente ab sofort ausgegeben?',
        options: <String>[
          'Am Schalter zwei',
          'Am Schalter vier',
          'Am Empfang neben dem Eingang',
        ],
        correctIndex: 1,
        explanation: 'Die Ausgabe von Ausweisdokumenten erfolgt ab sofort ausschließlich am Schalter vier.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viel Zeit wird für die Anmeldung des Wohnsitzes eingeplant?',
        options: <String>[
          'Fünf Minuten',
          'Fünfzehn Minuten',
          'Zehn Minuten',
        ],
        correctIndex: 2,
        explanation: 'Für die Anmeldung des Wohnsitzes wird eine Bearbeitungszeit von zehn Minuten eingeplant.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-10',
    level: CefrLevel.b2,
    genre: RadioGenre.diary,
    title: 'Mein Jahr als Kassenwartin',
    lines: <RadioLine>[
      RadioLine(
        german: 'Heute habe ich den Kassenbericht für den Chor endgültig abgeschlossen.',
        english: 'Today I finally finished the treasurer\'s report for the choir.',
      ),
      RadioLine(
        german: 'Als ich das Amt vor einem Jahr übernahm, hielt ich es für eine Sache von zwei Stunden im Monat.',
        english: 'When I took on the role a year ago, I thought it would be a matter of two hours a month.',
      ),
      RadioLine(
        german: 'Tatsächlich waren es eher sechs, vor allem wegen der Belege, die nie vollständig eingereicht wurden.',
        english: 'In reality it was more like six, mainly because of the receipts that were never handed in completely.',
      ),
      RadioLine(
        german: 'Bemerkenswert finde ich, wie selbstverständlich ehrenamtliche Arbeit vorausgesetzt wird.',
        english: 'What strikes me is how readily voluntary work is simply taken for granted.',
      ),
      RadioLine(
        german: 'Zwar wurde mir mehrfach gedankt, doch über die Verteilung der Aufgaben ist nie ernsthaft gesprochen worden.',
        english: 'I was thanked several times, but the distribution of tasks was never seriously discussed.',
      ),
      RadioLine(
        german: 'Der Vorstand meint, jüngere Mitglieder seien einfach schwerer zu gewinnen.',
        english: 'The board claims that younger members are simply harder to recruit.',
      ),
      RadioLine(
        german: 'Meiner Erfahrung nach liegt es eher an den Strukturen als am Willen.',
        english: 'In my experience it has more to do with the structures than with willingness.',
      ),
      RadioLine(
        german: 'Wer nur einmal im Quartal helfen möchte, findet bei uns bislang keine passende Aufgabe.',
        english: 'Anyone who only wants to help once a quarter has so far found no suitable task with us.',
      ),
      RadioLine(
        german: 'Für das kommende Jahr habe ich deshalb eine Aufteilung in drei kleinere Ämter vorgeschlagen.',
        english: 'For the coming year I have therefore proposed splitting the role into three smaller posts.',
      ),
      RadioLine(
        german: 'Ob der Vorschlag angenommen wird, entscheidet die Versammlung im Februar.',
        english: 'Whether the proposal is accepted will be decided by the assembly in February.',
      ),
      RadioLine(
        german: 'Weitermachen würde ich unter diesen Bedingungen allerdings gern.',
        english: 'Under those conditions, though, I would be glad to carry on.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie viel Zeit kostete das Amt tatsächlich pro Monat?',
        options: <String>[
          'Etwa zwei Stunden',
          'Etwa vier Stunden',
          'Etwa sechs Stunden',
        ],
        correctIndex: 2,
        explanation: 'Sie rechnete mit zwei Stunden im Monat, tatsächlich waren es eher sechs.',
      ),
      ChoiceQuestion(
        prompt: 'Was hat die Sprecherin für das kommende Jahr vorgeschlagen?',
        options: <String>[
          'Eine Aufteilung in drei kleinere Ämter',
          'Die Einstellung einer bezahlten Kraft für die Buchhaltung',
          'Eine Erhöhung der Mitgliedsbeiträge',
        ],
        correctIndex: 0,
        explanation: 'Für das kommende Jahr hat sie eine Aufteilung in drei kleinere Ämter vorgeschlagen.',
      ),
      ChoiceQuestion(
        prompt: 'Wann entscheidet die Versammlung über den Vorschlag?',
        options: <String>[
          'Im Dezember',
          'Im Februar',
          'Im April',
        ],
        correctIndex: 1,
        explanation: 'Ob der Vorschlag angenommen wird, entscheidet die Versammlung im Februar.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-11',
    level: CefrLevel.b2,
    genre: RadioGenre.lecture,
    title: 'Zweifel am Großraumbüro',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen zur dritten Sitzung unserer Reihe über Arbeitsorganisation.',
        english: 'Welcome to the third session of our series on how work is organised.',
      ),
      RadioLine(
        german: 'Im Mittelpunkt steht heute die vielfach beschworene Offenheit moderner Bürolandschaften.',
        english: 'Today we turn to the much-invoked openness of modern office landscapes.',
      ),
      RadioLine(
        german: 'Eine im Frühjahr veröffentlichte Untersuchung des Instituts für Arbeitsforschung Lindau hat achtzig Beschäftigte über sechs Monate begleitet.',
        english: 'A study published this spring by the Lindau Institute for Labour Research followed eighty employees over six months.',
      ),
      RadioLine(
        german: 'Die Leitung der Studie erklärt, der Umzug in ein Großraumbüro habe die direkte Ansprache unter Kollegen deutlich verringert.',
        english: 'According to the researchers in charge, the move into an open-plan office noticeably reduced how often colleagues spoke to one another directly.',
      ),
      RadioLine(
        german: 'Stattdessen sei die schriftliche Kommunikation um etwa vierzig Prozent gestiegen.',
        english: 'Written communication, they say, rose by around forty percent instead.',
      ),
      RadioLine(
        german: 'Bemerkenswerterweise wurde dieser Effekt auch dort gemessen, wo die Schreibtische nur wenige Meter auseinanderstanden.',
        english: 'Remarkably, the effect was measured even where the desks stood only a few metres apart.',
      ),
      RadioLine(
        german: 'Zwar lässt sich aus einem einzelnen Betrieb keine allgemeine Regel ableiten, doch decken sich die Zahlen mit älteren Beobachtungen.',
        english: 'Admittedly no general rule can be drawn from a single company, yet the figures match older observations.',
      ),
      RadioLine(
        german: 'Kritisch anzumerken ist allerdings, dass die Einsparung bei der Fläche in der Rechnung selten den Produktivitätsverlusten gegenübergestellt wird.',
        english: 'It should be noted critically, however, that savings on floor space are rarely set against the losses in productivity.',
      ),
      RadioLine(
        german: 'Offenbar wird Offenheit hier vor allem als Gestaltungsidee verstanden, nicht als messbares Ergebnis.',
        english: 'Openness, it seems, is understood here mainly as a design idea rather than as a measurable result.',
      ),
      RadioLine(
        german: 'In der nächsten Sitzung wenden wir uns den Rückzugsräumen zu.',
        english: 'In the next session we will turn to quiet rooms.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie lange wurden die Beschäftigten begleitet?',
        options: <String>[
          'über drei Monate',
          'über sechs Monate',
          'über zwölf Monate',
        ],
        correctIndex: 1,
        explanation: 'Im Text heißt es, die Untersuchung habe achtzig Beschäftigte über sechs Monate begleitet.',
      ),
      ChoiceQuestion(
        prompt: 'Wie veränderte sich laut Studienleitung die schriftliche Kommunikation?',
        options: <String>[
          'Sie sank um etwa vierzig Prozent.',
          'Sie blieb unverändert.',
          'Sie stieg um etwa vierzig Prozent.',
        ],
        correctIndex: 2,
        explanation: 'Die Leitung der Studie erklärt, die schriftliche Kommunikation sei um etwa vierzig Prozent gestiegen.',
      ),
      ChoiceQuestion(
        prompt: 'Womit befasst sich die nächste Sitzung?',
        options: <String>[
          'mit den Rückzugsräumen',
          'mit den Arbeitszeiten',
          'mit den Kantinen',
        ],
        correctIndex: 0,
        explanation: 'Am Ende wird angekündigt, dass man sich in der nächsten Sitzung den Rückzugsräumen zuwendet.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-12',
    level: CefrLevel.b2,
    genre: RadioGenre.news,
    title: 'Meldungen aus der Region',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Tag, hier sind die Meldungen aus der Region Oberwald.',
        english: 'Good afternoon, here are the news items from the Oberwald region.',
      ),
      RadioLine(
        german: 'Der Gemeinderat von Steinbach hat gestern Abend die Einführung eines einheitlichen Mehrwegsystems für Getränkebecher beschlossen.',
        english: 'Yesterday evening the council of Steinbach approved the introduction of a uniform reusable system for drinks cups.',
      ),
      RadioLine(
        german: 'Ab dem ersten Oktober werden auf städtischen Märkten nur noch Becher mit Pfand ausgegeben.',
        english: 'From the first of October, only cups carrying a deposit will be handed out at the municipal markets.',
      ),
      RadioLine(
        german: 'Die zuständige Dezernentin betonte, die Umstellung sei mit den Betrieben lange abgestimmt worden.',
        english: 'The department head responsible stressed that the changeover had been agreed with the businesses well in advance.',
      ),
      RadioLine(
        german: 'Einzelne Standbetreiber halten den Aufwand des Rücknahmesystems dagegen für unterschätzt.',
        english: 'Some stallholders, by contrast, consider the effort of running a return system to be underestimated.',
      ),
      RadioLine(
        german: 'Zweitens: Die Wohnbaugenossenschaft Talblick meldet, der Rohbau an der Färbergasse liege trotz der nassen Monate im Zeitplan.',
        english: 'Secondly, the Talblick housing cooperative reports that the shell construction on Färbergasse is on schedule despite the wet months.',
      ),
      RadioLine(
        german: 'Sechsunddreißig Wohnungen sollen im kommenden Frühjahr übergeben werden.',
        english: 'Thirty-six flats are due to be handed over next spring.',
      ),
      RadioLine(
        german: 'Und schließlich der Baumbestand: Nach einer Erhebung des Umweltamts sind im Stadtgebiet im vergangenen Jahr rund vierhundert Bäume nachgepflanzt worden.',
        english: 'And finally the tree population: according to a survey by the environmental office, around four hundred trees were replanted across the city last year.',
      ),
      RadioLine(
        german: 'Ob die Zahl den Verlust der trockenen Sommer ausgleicht, gilt unter Fachleuten allerdings als offen.',
        english: 'Whether that number makes up for the losses of the dry summers is, however, regarded as an open question among experts.',
      ),
      RadioLine(
        german: 'Die nächsten Meldungen folgen um sechzehn Uhr.',
        english: 'The next bulletin follows at four in the afternoon.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Ab wann gibt es auf den städtischen Märkten nur noch Becher mit Pfand?',
        options: <String>[
          'ab dem ersten Oktober',
          'ab dem ersten September',
          'ab dem ersten Januar',
        ],
        correctIndex: 0,
        explanation: 'Im Bericht heißt es, ab dem ersten Oktober würden nur noch Becher mit Pfand ausgegeben.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viele Wohnungen sollen im Frühjahr übergeben werden?',
        options: <String>[
          'sechsundzwanzig',
          'sechsunddreißig',
          'sechsundvierzig',
        ],
        correctIndex: 1,
        explanation: 'Es wird gemeldet, dass sechsunddreißig Wohnungen im kommenden Frühjahr übergeben werden sollen.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viele Bäume wurden laut Umweltamt nachgepflanzt?',
        options: <String>[
          'rund dreihundert',
          'rund fünfhundert',
          'rund vierhundert',
        ],
        correctIndex: 2,
        explanation: 'Nach der Erhebung des Umweltamts sind im vergangenen Jahr rund vierhundert Bäume nachgepflanzt worden.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-13',
    level: CefrLevel.b2,
    genre: RadioGenre.voicemail,
    title: 'Nachricht aus dem Stadtarchiv',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Tag, Frau Reinhardt, hier spricht Bernhard Kolm vom Stadtarchiv Neuburg.',
        english: 'Good afternoon, Ms Reinhardt, this is Bernhard Kolm from the Neuburg city archive.',
      ),
      RadioLine(
        german: 'Ich melde mich wegen Ihrer Anfrage zu den Betriebsakten der ehemaligen Tuchfabrik.',
        english: 'I am getting in touch about your enquiry concerning the company records of the former cloth factory.',
      ),
      RadioLine(
        german: 'Die Bestände sind inzwischen erschlossen, allerdings ist die Digitalisierung erst zur Hälfte abgeschlossen.',
        english: 'The holdings have now been catalogued, though the digitisation is only half finished.',
      ),
      RadioLine(
        german: 'Meine Kollegin teilt mit, die restlichen Kartons würden voraussichtlich bis Ende November bearbeitet.',
        english: 'My colleague informs me that the remaining boxes will probably be processed by the end of November.',
      ),
      RadioLine(
        german: 'Sie können die Unterlagen selbstverständlich schon jetzt im Lesesaal einsehen.',
        english: 'You are of course welcome to consult the documents in the reading room already.',
      ),
      RadioLine(
        german: 'Zu beachten wäre lediglich, dass Aufnahmen mit dem eigenen Gerät nur ohne Blitz erlaubt sind.',
        english: 'The only thing to bear in mind is that photographs with your own device are permitted only without flash.',
      ),
      RadioLine(
        german: 'Ein Platz im Lesesaal muss zudem mindestens drei Werktage vorher angemeldet werden.',
        english: 'A seat in the reading room also has to be booked at least three working days in advance.',
      ),
      RadioLine(
        german: 'Ob wir Ihnen zusätzlich Kopien anfertigen können, hängt vom Zustand der Papiere ab.',
        english: 'Whether we can also make copies for you depends on the condition of the papers.',
      ),
      RadioLine(
        german: 'Bei brüchigen Seiten wird aus konservatorischen Gründen grundsätzlich davon abgesehen.',
        english: 'Where pages are brittle, we refrain from it on conservation grounds as a matter of principle.',
      ),
      RadioLine(
        german: 'Rufen Sie mich gern unter der Durchwahl vierhundertzwölf zurück.',
        english: 'Do feel free to call me back on extension four hundred and twelve.',
      ),
      RadioLine(
        german: 'Ich bin von Dienstag bis Donnerstag im Haus.',
        english: 'I am in the building from Tuesday to Thursday.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann sollen die restlichen Kartons bearbeitet sein?',
        options: <String>[
          'bis Ende September',
          'bis Ende Oktober',
          'bis Ende November',
        ],
        correctIndex: 2,
        explanation: 'Die Kollegin teilt mit, die restlichen Kartons würden voraussichtlich bis Ende November bearbeitet.',
      ),
      ChoiceQuestion(
        prompt: 'Wie früh muss ein Platz im Lesesaal angemeldet werden?',
        options: <String>[
          'mindestens drei Werktage vorher',
          'mindestens fünf Werktage vorher',
          'mindestens einen Werktag vorher',
        ],
        correctIndex: 0,
        explanation: 'Im Text heißt es, ein Platz im Lesesaal müsse mindestens drei Werktage vorher angemeldet werden.',
      ),
      ChoiceQuestion(
        prompt: 'Wovon hängt es ab, ob Kopien angefertigt werden?',
        options: <String>[
          'vom Alter der Anfrage',
          'vom Zustand der Papiere',
          'von der Zahl der Kartons',
        ],
        correctIndex: 1,
        explanation: 'Ob zusätzlich Kopien angefertigt werden können, hängt laut Nachricht vom Zustand der Papiere ab.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-14',
    level: CefrLevel.b2,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Das Alpinum',
    lines: <RadioLine>[
      RadioLine(
        german: 'Sie stehen nun vor dem Alpinum, dem ältesten Teil unseres Botanischen Gartens.',
        english: 'You are now standing in front of the alpine garden, the oldest part of our botanical garden.',
      ),
      RadioLine(
        german: 'Die Anlage wurde im Jahr neunzehnhundertsechs auf einer Aufschüttung aus Kalkgestein errichtet.',
        english: 'The site was created in nineteen hundred and six on a mound of limestone rubble.',
      ),
      RadioLine(
        german: 'Bemerkenswert ist weniger die Größe als die Vielfalt der hier versammelten Hochgebirgspflanzen.',
        english: 'What is striking is less its size than the variety of high-mountain plants brought together here.',
      ),
      RadioLine(
        german: 'Etwa neunhundert Arten werden gepflegt, ein Drittel davon stammt aus eigener Anzucht.',
        english: 'Some nine hundred species are looked after, a third of them raised here on site.',
      ),
      RadioLine(
        german: 'Die Gärtnerinnen berichten, die milden Winter der letzten Jahre hätten den Beständen mehr zugesetzt als jede Kälte.',
        english: 'The gardeners report that the mild winters of recent years have harmed the collection more than any cold spell.',
      ),
      RadioLine(
        german: 'Ohne schützende Schneedecke seien die Polsterpflanzen im Februar besonders anfällig.',
        english: 'Without a protective blanket of snow, they say, the cushion plants are especially vulnerable in February.',
      ),
      RadioLine(
        german: 'Deshalb wird ein Teil der Fläche seit einigen Jahren künstlich beschattet.',
        english: 'For that reason part of the area has been artificially shaded for some years now.',
      ),
      RadioLine(
        german: 'Ob solche Eingriffe langfristig genügen, wird in der Fachwelt durchaus unterschiedlich beurteilt.',
        english: 'Whether such measures will suffice in the long run is judged quite differently among specialists.',
      ),
      RadioLine(
        german: 'Werfen Sie bitte einen Blick auf die niedrige Mauer zu Ihrer Rechten.',
        english: 'Please take a look at the low wall to your right.',
      ),
      RadioLine(
        german: 'Die Fugen wurden bewusst offen gelassen, damit sich Moose und Farne von selbst ansiedeln können.',
        english: 'Its joints were deliberately left open so that mosses and ferns can settle there of their own accord.',
      ),
      RadioLine(
        german: 'Ihr Weg führt Sie anschließend über die Holztreppe hinunter zum Teichgarten.',
        english: 'Your route then takes you down the wooden steps to the pond garden.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann wurde die Anlage errichtet?',
        options: <String>[
          'im Jahr neunzehnhundertsechsundzwanzig',
          'im Jahr neunzehnhundertsechs',
          'im Jahr neunzehnhundertsechzehn',
        ],
        correctIndex: 1,
        explanation: 'Es heißt, die Anlage sei im Jahr neunzehnhundertsechs auf einer Aufschüttung errichtet worden.',
      ),
      ChoiceQuestion(
        prompt: 'Was setzt den Beständen laut den Gärtnerinnen besonders zu?',
        options: <String>[
          'die milden Winter',
          'die trockenen Sommer',
          'die starken Winde',
        ],
        correctIndex: 0,
        explanation: 'Die Gärtnerinnen berichten, die milden Winter hätten den Beständen mehr zugesetzt als jede Kälte.',
      ),
      ChoiceQuestion(
        prompt: 'Wohin führt der Weg anschließend?',
        options: <String>[
          'zum Gewächshaus',
          'zum Rosenhang',
          'zum Teichgarten',
        ],
        correctIndex: 2,
        explanation: 'Am Schluss heißt es, der Weg führe über die Holztreppe hinunter zum Teichgarten.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-15',
    level: CefrLevel.b2,
    genre: RadioGenre.weather,
    title: 'Hochdruck über Mitteleuropa',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Abend, hier ist der Wetterbericht für die kommenden Tage.',
        english: 'Good evening, here is the weather report for the days ahead.',
      ),
      RadioLine(
        german: 'Bestimmend bleibt ein kräftiges Hoch über Mitteleuropa, das feuchte Luft vom Atlantik zuverlässig fernhält.',
        english: 'A strong high over central Europe remains dominant, reliably keeping damp Atlantic air at bay.',
      ),
      RadioLine(
        german: 'In den Niederungen hält sich am Vormittag zäher Nebel, der sich erst gegen Mittag auflöst.',
        english: 'In the lowlands stubborn fog persists through the morning and only clears around midday.',
      ),
      RadioLine(
        german: 'Oberhalb von achthundert Metern wird dagegen ungewöhnlich milde Luft erwartet.',
        english: 'Above eight hundred metres, by contrast, unusually mild air is expected.',
      ),
      RadioLine(
        german: 'Die Höchstwerte liegen zwischen elf Grad im Rheintal und achtzehn Grad auf den Voralpengipfeln.',
        english: 'Highs range from eleven degrees in the Rhine valley to eighteen degrees on the pre-alpine summits.',
      ),
      RadioLine(
        german: 'Der Wind weht schwach aus östlichen Richtungen.',
        english: 'The wind blows lightly from easterly directions.',
      ),
      RadioLine(
        german: 'In der Nacht zum Freitag ist verbreitet mit Bodenfrost zu rechnen.',
        english: 'Ground frost is to be expected widely in the night leading into Friday.',
      ),
      RadioLine(
        german: 'Empfindliche Pflanzen sollten daher rechtzeitig abgedeckt werden.',
        english: 'Sensitive plants should therefore be covered in good time.',
      ),
      RadioLine(
        german: 'Zum Wochenende deutet sich zwar eine leichte Umstellung an, doch bleiben die Modelle in der Frage des Niederschlags uneinheitlich.',
        english: 'A slight change is indicated for the weekend, though the models remain inconsistent on the question of rainfall.',
      ),
      RadioLine(
        german: 'Nach derzeitigem Stand fällt am Sonntag allenfalls etwas Sprühregen.',
        english: 'As things stand, Sunday will bring at most a little drizzle.',
      ),
      RadioLine(
        german: 'Die nächste Aktualisierung erfolgt morgen früh um sechs Uhr.',
        english: 'The next update follows tomorrow morning at six.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wo werden Höchstwerte von achtzehn Grad erwartet?',
        options: <String>[
          'im Rheintal',
          'in den Niederungen',
          'auf den Voralpengipfeln',
        ],
        correctIndex: 2,
        explanation: 'Die Höchstwerte reichen von elf Grad im Rheintal bis achtzehn Grad auf den Voralpengipfeln.',
      ),
      ChoiceQuestion(
        prompt: 'Womit ist in der Nacht zum Freitag zu rechnen?',
        options: <String>[
          'mit Bodenfrost',
          'mit Sprühregen',
          'mit dichtem Nebel',
        ],
        correctIndex: 0,
        explanation: 'Im Bericht heißt es, in der Nacht zum Freitag sei verbreitet mit Bodenfrost zu rechnen.',
      ),
      ChoiceQuestion(
        prompt: 'Wann erfolgt die nächste Aktualisierung?',
        options: <String>[
          'heute um zweiundzwanzig Uhr',
          'morgen früh um sechs Uhr',
          'morgen Mittag um zwölf Uhr',
        ],
        correctIndex: 1,
        explanation: 'Zum Schluss wird gesagt, die nächste Aktualisierung erfolge morgen früh um sechs Uhr.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-16',
    level: CefrLevel.b2,
    genre: RadioGenre.news,
    title: 'Mehrweg in der Innenstadt',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Morgen, hier sind die Nachrichten aus der Region Talheim.',
        english: 'Good morning, here is the news from the Talheim region.',
      ),
      RadioLine(
        german: 'Nach Angaben des Umweltamts sei der Verbrauch von Einwegbechern in der Innenstadt im vergangenen Jahr um knapp ein Fünftel gesunken.',
        english: 'According to the environmental office, the use of disposable cups in the town centre fell by almost a fifth last year.',
      ),
      RadioLine(
        german: 'Verantwortlich dafür sei vor allem das seit März geltende Pfandsystem, das inzwischen siebzig Betriebe nutzen.',
        english: 'The main reason, it says, is the deposit scheme in force since March, which seventy businesses now take part in.',
      ),
      RadioLine(
        german: 'Eine Untersuchung der Fachhochschule Talheim kommt allerdings zu einem vorsichtigeren Ergebnis.',
        english: 'A study by the Talheim University of Applied Sciences, however, reaches a more cautious conclusion.',
      ),
      RadioLine(
        german: 'Zwar werde deutlich weniger weggeworfen, doch ein erheblicher Teil der ausgegebenen Becher kehre nie zurück.',
        english: 'Far less is being thrown away, it is true, but a considerable share of the cups handed out never comes back.',
      ),
      RadioLine(
        german: 'Die Autorinnen der Studie sprechen von einer Rücklaufquote von etwa achtzig Prozent.',
        english: 'The authors of the study put the return rate at around eighty percent.',
      ),
      RadioLine(
        german: 'Der Handelsverband kritisiert unterdessen den zusätzlichen Aufwand beim Spülen und bei der Lagerung.',
        english: 'The retail association, meanwhile, criticises the extra effort involved in washing and storage.',
      ),
      RadioLine(
        german: 'Kleinere Bäckereien seien davon besonders betroffen, heißt es in einer Mitteilung.',
        english: 'Smaller bakeries are said to be particularly affected, according to a statement.',
      ),
      RadioLine(
        german: 'Die Stadt hält dennoch an ihrem Ziel fest, den Verbrauch bis Ende des Jahrzehnts zu halbieren.',
        english: 'The city is nevertheless sticking to its goal of halving consumption by the end of the decade.',
      ),
      RadioLine(
        german: 'Ob das gelingt, hängt erfahrungsgemäß weniger von Vorschriften als von Gewohnheiten ab.',
        english: 'Whether that works out tends to depend less on rules than on habits.',
      ),
      RadioLine(
        german: 'Weitere Einzelheiten folgen in der Mittagsausgabe.',
        english: 'Further details will follow in the midday edition.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie stark ist der Verbrauch von Einwegbechern laut Umweltamt gesunken?',
        options: <String>[
          'um knapp ein Fünftel',
          'um knapp ein Drittel',
          'um knapp die Hälfte',
        ],
        correctIndex: 0,
        explanation: 'Im Bericht heißt es, der Verbrauch sei im vergangenen Jahr um knapp ein Fünftel gesunken.',
      ),
      ChoiceQuestion(
        prompt: 'Wie hoch ist die Rücklaufquote laut der Studie?',
        options: <String>[
          'etwa sechzig Prozent',
          'etwa achtzig Prozent',
          'etwa neunzig Prozent',
        ],
        correctIndex: 1,
        explanation: 'Die Autorinnen der Studie sprechen von einer Rücklaufquote von etwa achtzig Prozent.',
      ),
      ChoiceQuestion(
        prompt: 'Was kritisiert der Handelsverband?',
        options: <String>[
          'die Höhe des geforderten Pfandbetrags',
          'die kurzen Öffnungszeiten der Rücknahmestellen',
          'den Aufwand beim Spülen und Lagern',
        ],
        correctIndex: 2,
        explanation: 'Der Handelsverband kritisiert den zusätzlichen Aufwand beim Spülen und bei der Lagerung.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-17',
    level: CefrLevel.b2,
    genre: RadioGenre.lecture,
    title: 'Der Lärm im Büro',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen zur heutigen Folge unserer Reihe über die Arbeitswelt.',
        english: 'Welcome to today\'s episode of our series on working life.',
      ),
      RadioLine(
        german: 'Wenn über Großraumbüros gestritten wird, geht es selten um Quadratmeter, sondern fast immer um Geräusche.',
        english: 'When open-plan offices are argued about, it is rarely about floor space and almost always about noise.',
      ),
      RadioLine(
        german: 'Untersuchungen aus der Arbeitspsychologie legen nahe, dass nicht die Lautstärke selbst am meisten stört, sondern die Verständlichkeit fremder Gespräche.',
        english: 'Research in occupational psychology suggests that what disturbs people most is not the volume itself but how intelligible other conversations are.',
      ),
      RadioLine(
        german: 'Ein Gespräch, dessen Inhalt man unfreiwillig mitbekommt, bindet Aufmerksamkeit, obwohl es nicht an uns gerichtet ist.',
        english: 'A conversation whose content you pick up against your will ties up attention, even though it is not addressed to you.',
      ),
      RadioLine(
        german: 'Gleichmäßige Geräusche wie Lüftung werden dagegen nach kurzer Zeit kaum noch wahrgenommen.',
        english: 'Steady sounds such as ventilation, by contrast, are barely noticed after a short while.',
      ),
      RadioLine(
        german: 'Daraus wird in der Praxis der Schluss gezogen, dass Sprache maskiert werden müsse, etwa durch Trennwände oder ein leises Hintergrundrauschen.',
        english: 'In practice the conclusion drawn from this is that speech has to be masked, for instance by partitions or a quiet background hum.',
      ),
      RadioLine(
        german: 'Allerdings ist die Wirkung solcher Maßnahmen umstritten.',
        english: 'The effect of such measures is disputed, however.',
      ),
      RadioLine(
        german: 'Manche Beschäftigte empfinden das Rauschen selbst als Belastung, andere berichten von deutlicher Entlastung.',
        english: 'Some employees experience the hum itself as a strain, while others report clear relief.',
      ),
      RadioLine(
        german: 'Hinzu kommt, dass die Bewertung stark davon abhängt, ob die Betroffenen bei der Gestaltung mitreden durften.',
        english: 'On top of that, the assessment depends heavily on whether the people affected had a say in the design.',
      ),
      RadioLine(
        german: 'Ein akustisches Problem ist insofern immer auch ein organisatorisches.',
        english: 'In that sense an acoustic problem is always an organisational one as well.',
      ),
      RadioLine(
        german: 'In der nächsten Folge geht es um die Verteilung von Pausen.',
        english: 'The next episode will look at how breaks are spread through the day.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was stört laut den Untersuchungen am meisten?',
        options: <String>[
          'die Lautstärke der Lüftung',
          'die Verständlichkeit fremder Gespräche',
          'die Größe des Arbeitsraums',
        ],
        correctIndex: 1,
        explanation: 'Im Vortrag heißt es, nicht die Lautstärke störe am meisten, sondern die Verständlichkeit fremder Gespräche.',
      ),
      ChoiceQuestion(
        prompt: 'Was geschieht mit gleichmäßigen Geräuschen wie der Lüftung?',
        options: <String>[
          'Sie werden bald kaum noch bemerkt.',
          'Sie wirken mit der Zeit immer lauter.',
          'Sie machen Gespräche verständlicher.',
        ],
        correctIndex: 0,
        explanation: 'Gleichmäßige Geräusche werden nach kurzer Zeit kaum noch wahrgenommen.',
      ),
      ChoiceQuestion(
        prompt: 'Wovon hängt die Bewertung der Maßnahmen zusätzlich ab?',
        options: <String>[
          'von der Höhe der Miete',
          'von der Zahl der Arbeitsplätze',
          'von der Mitsprache der Betroffenen',
        ],
        correctIndex: 2,
        explanation: 'Die Bewertung hängt stark davon ab, ob die Betroffenen bei der Gestaltung mitreden durften.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-18',
    level: CefrLevel.b2,
    genre: RadioGenre.diary,
    title: 'Zweite Stimme im Chor',
    lines: <RadioLine>[
      RadioLine(
        german: 'Donnerstag, halb elf, ich schreibe das direkt nach der Probe.',
        english: 'Thursday, half past ten, I am writing this straight after rehearsal.',
      ),
      RadioLine(
        german: 'Seit sechs Wochen singe ich nun in einem Laienchor, und ich muss zugeben, dass ich den Aufwand unterschätzt habe.',
        english: 'I have been singing in an amateur choir for six weeks now, and I have to admit I underestimated how much work it is.',
      ),
      RadioLine(
        german: 'Die Chorleiterin erklärte gleich am ersten Abend, Notenlesen sei keine Voraussetzung, wohl aber Geduld.',
        english: 'On the very first evening the choir director explained that reading music was not a requirement, but patience certainly was.',
      ),
      RadioLine(
        german: 'Genau das erweist sich als richtig.',
        english: 'That is turning out to be exactly right.',
      ),
      RadioLine(
        german: 'Meine Stimme, die zweite, führt fast nie die Melodie, sondern hält den Klang zusammen.',
        english: 'My part, the second, almost never carries the melody; it holds the sound together.',
      ),
      RadioLine(
        german: 'Wer allein übt, hört deshalb ständig etwas, das falsch klingt, obwohl es das gar nicht ist.',
        english: 'So if you practise on your own, you constantly hear something that sounds wrong even though it is not.',
      ),
      RadioLine(
        german: 'Heute wurde ein Stück wiederholt, das wir vor zwei Wochen schon einmal durchgearbeitet hatten.',
        english: 'Today we went over a piece again that we had already worked through two weeks ago.',
      ),
      RadioLine(
        german: 'Erstaunlicherweise saß diesmal fast alles.',
        english: 'Astonishingly, this time almost everything was solid.',
      ),
      RadioLine(
        german: 'Ob das an der Wiederholung liegt oder an der besseren Laune, kann ich nicht beurteilen.',
        english: 'Whether that is down to the repetition or simply to better spirits, I cannot judge.',
      ),
      RadioLine(
        german: 'Im Dezember soll es ein Konzert in der alten Turnhalle geben.',
        english: 'In December there is supposed to be a concert in the old gymnasium.',
      ),
      RadioLine(
        german: 'Bis dahin bleiben noch elf Proben, und ich freue mich darauf.',
        english: 'Until then there are eleven rehearsals to go, and I am looking forward to it.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie lange singt die Sprecherin schon im Chor?',
        options: <String>[
          'seit zwei Wochen',
          'seit sechs Wochen',
          'seit elf Wochen',
        ],
        correctIndex: 1,
        explanation: 'Sie sagt, dass sie seit sechs Wochen in einem Laienchor singt.',
      ),
      ChoiceQuestion(
        prompt: 'Was erklärte die Chorleiterin am ersten Abend?',
        options: <String>[
          'Notenlesen sei eine feste Voraussetzung.',
          'Tägliches Üben zu Hause sei Pflicht.',
          'Geduld sei wichtiger als Notenlesen.',
        ],
        correctIndex: 2,
        explanation: 'Die Chorleiterin erklärte, Notenlesen sei keine Voraussetzung, wohl aber Geduld.',
      ),
      ChoiceQuestion(
        prompt: 'Wo soll das Konzert im Dezember stattfinden?',
        options: <String>[
          'in der alten Turnhalle',
          'in der Kirche am Markt',
          'im Saal der Schule',
        ],
        correctIndex: 0,
        explanation: 'Im Dezember soll es ein Konzert in der alten Turnhalle geben.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-19',
    level: CefrLevel.b2,
    genre: RadioGenre.announcement,
    title: 'Änderungen im Tierpark',
    lines: <RadioLine>[
      RadioLine(
        german: 'Liebe Besucherinnen und Besucher, wir möchten Sie über einige Änderungen im Tagesablauf informieren.',
        english: 'Dear visitors, we would like to inform you about a few changes to today\'s schedule.',
      ),
      RadioLine(
        german: 'Der Rundweg im südlichen Teil des Tierparks bleibt wegen der Bauarbeiten an der neuen Voliere bis Ende Oktober gesperrt.',
        english: 'The path through the southern part of the park remains closed until the end of October because of construction work on the new aviary.',
      ),
      RadioLine(
        german: 'Eine Umleitung ist ausgeschildert und barrierefrei begehbar.',
        english: 'A signposted diversion is in place and is accessible without steps.',
      ),
      RadioLine(
        german: 'Die kommentierte Fütterung der Fischotter beginnt heute nicht um vierzehn Uhr, sondern bereits um dreizehn Uhr dreißig.',
        english: 'Today the commentated otter feeding does not start at two o\'clock but already at half past one.',
      ),
      RadioLine(
        german: 'Grund dafür ist eine Fortbildung des Pflegeteams am Nachmittag.',
        english: 'The reason is a training session for the keeper team this afternoon.',
      ),
      RadioLine(
        german: 'Diese Verschiebung ist eine einmalige Ausnahme und gilt nur für heute.',
        english: 'This change of time is a one-off exception and applies to today only.',
      ),
      RadioLine(
        german: 'Wir bitten Sie außerdem, die Tiere ausschließlich mit dem an den Automaten erhältlichen Futter zu versorgen.',
        english: 'We also ask you to feed the animals only with the food available from the dispensers.',
      ),
      RadioLine(
        german: 'Mitgebrachtes Brot ist, so gut es gemeint sein mag, für viele Arten ungeeignet.',
        english: 'Bread brought from home, however well meant, is unsuitable for many species.',
      ),
      RadioLine(
        german: 'Das Café am Teich schließt heute bereits um sechzehn Uhr.',
        english: 'The cafe by the pond closes early today, at four o\'clock.',
      ),
      RadioLine(
        german: 'Der Tierpark selbst wird um achtzehn Uhr geschlossen.',
        english: 'The park itself closes at six o\'clock.',
      ),
      RadioLine(
        german: 'Der letzte Einlass erfolgt um siebzehn Uhr.',
        english: 'Last admission is at five o\'clock.',
      ),
      RadioLine(
        german: 'Wir wünschen Ihnen einen angenehmen Aufenthalt.',
        english: 'We wish you a pleasant visit.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann beginnt heute die Fütterung der Fischotter?',
        options: <String>[
          'um vierzehn Uhr dreißig',
          'um vierzehn Uhr',
          'um dreizehn Uhr dreißig',
        ],
        correctIndex: 2,
        explanation: 'Die Fütterung beginnt heute nicht um vierzehn Uhr, sondern bereits um dreizehn Uhr dreißig.',
      ),
      ChoiceQuestion(
        prompt: 'Warum wurde die Fütterung verschoben?',
        options: <String>[
          'wegen einer Fortbildung des Pflegeteams',
          'wegen der Bauarbeiten an der Voliere',
          'wegen des früheren Schließens des Cafés',
        ],
        correctIndex: 0,
        explanation: 'Als Grund wird eine Fortbildung des Pflegeteams am Nachmittag genannt.',
      ),
      ChoiceQuestion(
        prompt: 'Wann ist der letzte Einlass?',
        options: <String>[
          'um sechzehn Uhr',
          'um siebzehn Uhr',
          'um achtzehn Uhr',
        ],
        correctIndex: 1,
        explanation: 'In der Durchsage heißt es, der letzte Einlass erfolge um siebzehn Uhr.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-b2-20',
    level: CefrLevel.b2,
    genre: RadioGenre.recipe,
    title: 'Ofengemüse mit Kräuterquark',
    lines: <RadioLine>[
      RadioLine(
        german: 'Dieses Ofengemüse ist für vier Portionen berechnet, die Zubereitung dauert etwa fünfzig Minuten.',
        english: 'This oven-baked vegetable dish is designed for four portions, and preparation takes about fifty minutes.',
      ),
      RadioLine(
        german: 'Benötigt werden zwei mittelgroße Zucchini, drei Möhren, eine rote Zwiebel und vierhundert Gramm Kartoffeln.',
        english: 'You will need two medium courgettes, three carrots, one red onion and four hundred grams of potatoes.',
      ),
      RadioLine(
        german: 'Hinzu kommen drei Esslöffel Öl, ein Teelöffel Salz sowie Pfeffer und Thymian.',
        english: 'Added to that are three tablespoons of oil, one teaspoon of salt, plus pepper and thyme.',
      ),
      RadioLine(
        german: 'Das Gemüse wird gewaschen und in Stücke von etwa zwei Zentimetern geschnitten.',
        english: 'The vegetables are washed and cut into pieces of about two centimetres.',
      ),
      RadioLine(
        german: 'Wichtig ist dabei weniger die Form als die gleichmäßige Größe, weil sonst manches verbrennt, während anderes noch hart bleibt.',
        english: 'What matters here is less the shape than the even size, since otherwise some pieces burn while others are still hard.',
      ),
      RadioLine(
        german: 'Anschließend wird alles mit Öl und den Gewürzen vermengt und auf einem Blech verteilt.',
        english: 'Everything is then tossed with the oil and the seasonings and spread out on a baking tray.',
      ),
      RadioLine(
        german: 'Der Ofen wird auf zweihundert Grad Ober- und Unterhitze vorgeheizt.',
        english: 'The oven is preheated to two hundred degrees, top and bottom heat.',
      ),
      RadioLine(
        german: 'Das Blech wird auf die mittlere Schiene geschoben, wo das Gemüse etwa fünfunddreißig Minuten braucht.',
        english: 'The tray goes onto the middle shelf, where the vegetables need about thirty-five minutes.',
      ),
      RadioLine(
        german: 'Nach etwa fünfundzwanzig Minuten wird das Gemüse einmal gewendet.',
        english: 'After about twenty-five minutes the vegetables are turned once.',
      ),
      RadioLine(
        german: 'Für den Quark werden dreihundert Gramm Speisequark mit zwei Esslöffeln Wasser glatt gerührt.',
        english: 'For the dip, three hundred grams of quark are stirred smooth with two tablespoons of water.',
      ),
      RadioLine(
        german: 'Danach werden frische Kräuter untergehoben.',
        english: 'Fresh herbs are then folded in.',
      ),
      RadioLine(
        german: 'Zwar lässt sich der Quark gut vorbereiten, doch schmeckt er am nächsten Tag deutlich milder.',
        english: 'The dip can certainly be made in advance, though it tastes noticeably milder the next day.',
      ),
      RadioLine(
        german: 'Serviert wird das Gemüse warm, der Quark hingegen kühl.',
        english: 'The vegetables are served warm, the dip by contrast chilled.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Auf welche Temperatur wird der Ofen vorgeheizt?',
        options: <String>[
          'auf hundertachtzig Grad',
          'auf zweihundert Grad',
          'auf zweihundertzwanzig Grad',
        ],
        correctIndex: 1,
        explanation: 'Im Rezept heißt es, der Ofen werde auf zweihundert Grad Ober- und Unterhitze vorgeheizt.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viel Speisequark wird gebraucht?',
        options: <String>[
          'zweihundert Gramm',
          'vierhundert Gramm',
          'dreihundert Gramm',
        ],
        correctIndex: 2,
        explanation: 'Für den Quark werden dreihundert Gramm Speisequark mit Wasser glatt gerührt.',
      ),
      ChoiceQuestion(
        prompt: 'Wann wird das Gemüse gewendet?',
        options: <String>[
          'nach etwa fünfundzwanzig Minuten',
          'nach etwa fünfzig Minuten',
          'nach etwa zehn Minuten',
        ],
        correctIndex: 0,
        explanation: 'Nach etwa fünfundzwanzig Minuten wird das Gemüse einmal gewendet.',
      ),
    ],
  ),
];
