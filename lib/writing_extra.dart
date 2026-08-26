import 'models.dart';

/// A second set of writing tasks, two per level.
///
/// Each task states what the reader expects rather than only what the topic
/// is, because the offline scorer checks transparent features — length, and
/// whether the content points were addressed — and a learner deserves to know
/// what it is looking for. Every task carries a model answer that satisfies
/// its own requirements.
const List<WritingLesson> extraWritingLessons = <WritingLesson>[
  // ---------------------------------------------------------------- A1 ----
  WritingLesson(
    id: 'wr-a1-04',
    level: CefrLevel.a1,
    title: 'Eine Postkarte aus dem Urlaub',
    prompt:
        'Schreibe eine kurze Postkarte an einen Freund. Schreibe, wo du bist, '
        'wie das Wetter ist und was du machst.',
    guidance: <String>[
      'Beginne mit einer Anrede: Lieber … oder Liebe …',
      'Schreibe drei bis vier kurze Sätze im Präsens.',
      'Nenne den Ort, das Wetter und eine Aktivität.',
      'Schließe mit einem Gruß.',
    ],
    minWords: 30,
    keywords: <String>['bin', 'wetter', 'ist', 'grüße'],
    example:
        'Liebe Sara, ich bin jetzt in Hamburg. Das Wetter ist schön und warm. '
        'Ich gehe jeden Tag an den Hafen und esse Fisch. Morgen fahre ich mit '
        'dem Schiff. Viele Grüße, Tom',
  ),
  WritingLesson(
    id: 'wr-a1-05',
    level: CefrLevel.a1,
    title: 'Mein Zimmer',
    prompt:
        'Beschreibe dein Zimmer. Schreibe, was darin steht und wo es steht.',
    guidance: <String>[
      'Nenne mindestens vier Möbel oder Gegenstände.',
      'Sage, wo sie stehen: neben, auf, unter, vor.',
      'Benutze den Artikel: der Tisch, das Bett, die Lampe.',
      'Schreibe im Präsens.',
    ],
    minWords: 30,
    keywords: <String>['zimmer', 'steht', 'neben', 'ist'],
    example:
        'Mein Zimmer ist klein, aber hell. Links steht mein Bett. Neben dem '
        'Bett ist ein kleiner Tisch. Auf dem Tisch steht eine Lampe. Vor dem '
        'Fenster habe ich einen Stuhl. Das Zimmer gefällt mir gut.',
  ),

  // ---------------------------------------------------------------- A2 ----
  WritingLesson(
    id: 'wr-a2-04',
    level: CefrLevel.a2,
    title: 'Eine Einladung schreiben',
    prompt:
        'Lade eine Freundin zu deinem Geburtstag ein. Schreibe wann und wo die '
        'Feier ist und was sie mitbringen soll.',
    guidance: <String>[
      'Nenne Datum und Uhrzeit genau.',
      'Beschreibe kurz, wo die Feier stattfindet.',
      'Sage, was sie mitbringen kann.',
      'Bitte um eine Antwort.',
    ],
    minWords: 50,
    keywords: <String>['einladen', 'geburtstag', 'um', 'bring', 'antwort'],
    example:
        'Liebe Marie, am Samstag, dem zwölften Mai, feiere ich meinen '
        'Geburtstag. Die Feier beginnt um neunzehn Uhr bei mir zu Hause. Wir '
        'grillen im Garten, deshalb zieh bitte etwas Warmes an. Du musst nichts '
        'mitbringen, aber wenn du möchtest, bring einen Salat mit. Sag mir bitte '
        'bis Mittwoch Bescheid, ob du kommst. Ich freue mich sehr! Liebe Grüße, '
        'Nina',
  ),
  WritingLesson(
    id: 'wr-a2-05',
    level: CefrLevel.a2,
    title: 'Eine Entschuldigung für die Schule',
    prompt:
        'Schreibe eine kurze Entschuldigung. Erkläre, warum du gefehlt hast, '
        'und was du tun willst, um den Stoff nachzuholen.',
    guidance: <String>[
      'Benutze die höfliche Anrede: Sehr geehrte Frau … oder Sehr geehrter Herr …',
      'Nenne den Tag und den Grund.',
      'Schreibe im Perfekt über die Vergangenheit.',
      'Sage, wie du den Stoff nachholst.',
    ],
    minWords: 50,
    keywords: <String>['geehrte', 'gefehlt', 'weil', 'nachholen', 'grüßen'],
    example:
        'Sehr geehrte Frau Berg, am Montag habe ich im Unterricht gefehlt, weil '
        'ich krank war. Ich hatte Fieber und war beim Arzt. Die Bescheinigung '
        'bringe ich morgen mit. Den Stoff habe ich mir von Lukas geben lassen '
        'und die Aufgaben schon gemacht. Mit freundlichen Grüßen, Ali Demir',
  ),

  // ---------------------------------------------------------------- B1 ----
  WritingLesson(
    id: 'wr-b1-04',
    level: CefrLevel.b1,
    title: 'Eine Beschwerde über eine Lieferung',
    prompt:
        'Du hast ein Gerät bestellt, das beschädigt angekommen ist. Schreibe '
        'an den Kundenservice. Beschreibe den Schaden, nenne die Bestellnummer '
        'und sage, was du erwartest.',
    guidance: <String>[
      'Bleibe sachlich, auch wenn du verärgert bist.',
      'Nenne Bestellnummer und Lieferdatum.',
      'Beschreibe den Schaden konkret.',
      'Formuliere eine klare Forderung mit einer Frist.',
    ],
    minWords: 80,
    keywords: <String>['bestellnummer', 'beschädigt', 'bitte', 'frist', 'erwarte'],
    example:
        'Sehr geehrte Damen und Herren, am elften März habe ich bei Ihnen einen '
        'Wasserkocher bestellt, Bestellnummer 48127. Die Lieferung kam gestern '
        'an, allerdings ist das Gerät beschädigt: Der Griff ist gebrochen und '
        'der Deckel schließt nicht mehr richtig. Fotos habe ich angehängt. Ich '
        'bitte Sie, mir bis zum Ende der Woche einen Ersatz zuzuschicken. '
        'Sollte das nicht möglich sein, erwarte ich die Rückerstattung des '
        'Kaufpreises. Mit freundlichen Grüßen, Julia Kraus',
  ),
  WritingLesson(
    id: 'wr-b1-05',
    level: CefrLevel.b1,
    title: 'Ein Forumsbeitrag über das Homeoffice',
    prompt:
        'In einem Forum wird gefragt, ob Arbeiten von zu Hause besser ist. '
        'Schreibe deine Meinung mit zwei Argumenten und einem Gegenargument.',
    guidance: <String>[
      'Nenne deine Meinung im ersten Satz.',
      'Bringe zwei Argumente und begründe sie.',
      'Nenne ein Gegenargument und entkräfte es.',
      'Benutze Konnektoren: außerdem, allerdings, deshalb.',
    ],
    minWords: 90,
    keywords: <String>['meiner meinung', 'außerdem', 'allerdings', 'deshalb'],
    example:
        'Meiner Meinung nach ist das Homeoffice für viele Menschen die bessere '
        'Lösung. Erstens spart man jeden Tag Zeit, weil der Weg zur Arbeit '
        'wegfällt. Außerdem kann man ruhiger arbeiten, wenn im Büro viel '
        'geredet wird. Allerdings fehlt der Kontakt zu den Kollegen, und '
        'gerade neue Mitarbeiter lernen so weniger. Deshalb halte ich eine '
        'Mischung für sinnvoll: zwei Tage im Büro und drei Tage zu Hause. So '
        'bleiben beide Vorteile erhalten.',
  ),

  // ---------------------------------------------------------------- B2 ----
  WritingLesson(
    id: 'wr-b2-04',
    level: CefrLevel.b2,
    title: 'Eine Stellungnahme zu einem Vorschlag',
    prompt:
        'Deine Stadt will die Innenstadt für Autos sperren. Schreibe eine '
        'Stellungnahme, die den Vorschlag im Grundsatz unterstützt, aber zwei '
        'Bedingungen nennt.',
    guidance: <String>[
      'Ordne den Vorschlag zuerst sachlich ein.',
      'Nenne deine Position und begründe sie.',
      'Formuliere zwei konkrete Bedingungen.',
      'Nimm einen möglichen Einwand vorweg.',
    ],
    minWords: 130,
    keywords: <String>['grundsätzlich', 'bedingung', 'einwand', 'allerdings', 'voraussetzung'],
    example:
        'Der Vorschlag, die Innenstadt für den Autoverkehr zu sperren, ist '
        'grundsätzlich zu begrüßen. Weniger Verkehr bedeutet weniger Lärm und '
        'saubere Luft, und der gewonnene Raum kommt allen zugute. Meine '
        'Zustimmung steht allerdings unter zwei Bedingungen. Erstens muss der '
        'Nahverkehr vorher ausgebaut werden, denn wer heute auf das Auto '
        'angewiesen ist, braucht eine Alternative, bevor ihm die bisherige '
        'genommen wird. Zweitens sollten Lieferungen und Handwerksbetriebe '
        'weiterhin zu festgelegten Zeiten einfahren dürfen. Häufig wird '
        'eingewandt, eine Sperrung schade dem Einzelhandel. Erfahrungen aus '
        'vergleichbaren Städten sprechen dagegen: Dort ist der Umsatz nach '
        'einer Übergangszeit gestiegen, weil sich mehr Menschen länger in der '
        'Innenstadt aufhalten.',
  ),
  WritingLesson(
    id: 'wr-b2-05',
    level: CefrLevel.b2,
    title: 'Eine Grafik beschreiben',
    prompt:
        'Eine Grafik zeigt, dass der Anteil der Menschen, die täglich lesen, '
        'in zwanzig Jahren von 45 auf 28 Prozent gefallen ist. Beschreibe die '
        'Entwicklung und nenne mögliche Gründe.',
    guidance: <String>[
      'Nenne zuerst, was die Grafik zeigt und welchen Zeitraum sie umfasst.',
      'Beschreibe die Entwicklung mit konkreten Zahlen.',
      'Trenne Beschreibung und Deutung klar voneinander.',
      'Formuliere Vermutungen vorsichtig: vermutlich, es liegt nahe, dass …',
    ],
    minWords: 130,
    keywords: <String>['grafik', 'prozent', 'zeitraum', 'zurückgegangen', 'vermutlich'],
    example:
        'Die Grafik zeigt, wie sich der Anteil der Menschen, die täglich lesen, '
        'über einen Zeitraum von zwanzig Jahren entwickelt hat. Zu Beginn lag '
        'er bei fünfundvierzig Prozent, am Ende nur noch bei achtundzwanzig. '
        'Der Rückgang beträgt damit siebzehn Prozentpunkte und verläuft '
        'weitgehend gleichmäßig, ohne erkennbaren Einbruch in einem einzelnen '
        'Jahr. Über die Ursachen sagt die Grafik selbst nichts. Es liegt '
        'allerdings nahe, dass die Verbreitung des Smartphones eine Rolle '
        'spielt, weil es dieselbe Zeit beansprucht, die früher dem Lesen zur '
        'Verfügung stand. Vermutlich wirkt außerdem eine veränderte '
        'Arbeitswelt mit, in der Freizeit stärker zersplittert ist. Beides '
        'bleibt jedoch eine Vermutung, solange keine weiteren Daten vorliegen.',
  ),

  // ---------------------------------------------------------------- C1 ----
  WritingLesson(
    id: 'wr-c1-04',
    level: CefrLevel.c1,
    title: 'Eine Erörterung: Sollten Prüfungen abgeschafft werden?',
    prompt:
        'Erörtern Sie, ob schriftliche Prüfungen durch fortlaufende Bewertung '
        'ersetzt werden sollten. Gewichten Sie die Argumente und kommen Sie zu '
        'einem begründeten Schluss.',
    guidance: <String>[
      'Führen Sie das Thema ein, ohne die Frage sofort zu beantworten.',
      'Stellen Sie die stärkste Gegenposition fair dar.',
      'Gewichten Sie die Argumente ausdrücklich.',
      'Der Schluss darf offen bleiben, aber nicht unbegründet.',
    ],
    minWords: 180,
    keywords: <String>['einerseits', 'andererseits', 'gewicht', 'zugestehen', 'schluss'],
    example:
        'Die Forderung, schriftliche Prüfungen durch fortlaufende Bewertung zu '
        'ersetzen, wird meist mit dem Hinweis begründet, eine einzelne Klausur '
        'messe eher die Belastbarkeit an einem Tag als das Können über ein '
        'Semester. Dieser Einwand hat Gewicht. Wer an einem Prüfungstag krank '
        'oder erschöpft ist, erhält ein Ergebnis, das über Jahre nachwirkt, '
        'ohne dass es viel über die Sache aussagt. Andererseits ist der '
        'fortlaufenden Bewertung ein Problem eigen, das selten benannt wird: '
        'Sie erzeugt dauerhaften Bewertungsdruck. Wo jede Äußerung zählt, wird '
        'niemand mehr laut denken, und gerade das Nachdenken ohne Risiko ist '
        'für das Lernen unentbehrlich. Zugestehen muss man den Befürwortern '
        'gleichwohl, dass Prüfungen häufig schlecht gebaut sind. Daraus folgt '
        'allerdings nicht ihre Abschaffung, sondern ihre Verbesserung. Ein '
        'tragfähiger Schluss wäre daher, beide Formen zu kombinieren und ihr '
        'Gewicht offenzulegen, statt die eine gegen die andere auszuspielen.',
  ),

  // ---------------------------------------------------------------- C2 ----
  WritingLesson(
    id: 'wr-c2-04',
    level: CefrLevel.c2,
    title: 'Eine kritische Rezension',
    prompt:
        'Verfassen Sie die Rezension eines Sachbuchs, dessen These Sie für '
        'teilweise zutreffend halten. Arbeiten Sie heraus, wo das Argument '
        'trägt und wo es zu kurz greift.',
    guidance: <String>[
      'Referieren Sie die These, bevor Sie sie beurteilen.',
      'Belegen Sie Ihr Urteil an einer konkreten Stelle der Argumentation.',
      'Unterscheiden Sie zwischen einem Fehler und einer Entscheidung, die Sie anders getroffen hätten.',
      'Vermeiden Sie sowohl Gefälligkeit als auch Rechthaberei.',
    ],
    minWords: 200,
    keywords: <String>['these', 'insofern', 'gleichwohl', 'greift zu kurz', 'einwand'],
    example:
        'Das Buch verfolgt die These, dass die Verbreitung digitaler Medien die '
        'Aufmerksamkeitsspanne strukturell verkürzt habe, und stützt sie auf '
        'eine breite Auswahl empirischer Studien. In der Darstellung dieser '
        'Befunde liegt die Stärke des Bandes: Der Verfasser referiert sorgfältig '
        'und weist auf methodische Schwächen auch dort hin, wo sie seiner '
        'eigenen Position schaden. Insofern hebt sich die Arbeit wohltuend von '
        'der einschlägigen Ratgeberliteratur ab. Gleichwohl greift das zentrale '
        'Argument zu kurz. Der Verfasser schließt von einem veränderten '
        'Nutzungsverhalten auf eine veränderte Fähigkeit, ohne diesen Schritt '
        'eigens zu begründen. Dass jemand seltener lange liest, belegt nicht, '
        'dass er es nicht mehr könnte; es belegt zunächst nur, dass die '
        'Gelegenheiten seltener geworden sind. An dieser Stelle hätte man sich '
        'eine Auseinandersetzung mit der Gegenposition gewünscht, die im '
        'Literaturverzeichnis zwar auftaucht, im Text aber unerwähnt bleibt. '
        'Das ist kein Fehler im strengen Sinne, wohl aber eine Entscheidung, '
        'die den Ertrag des Buches schmälert.',
  ),
];
