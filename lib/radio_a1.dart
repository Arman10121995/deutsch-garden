import 'models.dart';
import 'radio_models.dart';

/// A1 Gartenradio scripts.
///
/// Short sentences, present tense, concrete vocabulary, and an English line
/// beside every German one. Original text written for this app.
const List<RadioEpisode> radioA1Episodes = <RadioEpisode>[
  RadioEpisode(
    id: 'rd-a1-04',
    level: CefrLevel.a1,
    genre: RadioGenre.announcement,
    title: 'Durchsage im Supermarkt',
    lines: <RadioLine>[
      RadioLine(
        german: 'Liebe Kundinnen und Kunden, guten Tag.',
        english: 'Dear customers, good afternoon.',
      ),
      RadioLine(
        german: 'Heute ist das Obst besonders günstig.',
        english: 'Today the fruit is particularly cheap.',
      ),
      RadioLine(
        german: 'Ein Kilo Äpfel kostet nur einen Euro.',
        english: 'One kilo of apples costs only one euro.',
      ),
      RadioLine(
        german: 'Sie finden das Obst hinten rechts.',
        english: 'You will find the fruit at the back on the right.',
      ),
      RadioLine(
        german: 'Der Supermarkt schließt um zwanzig Uhr.',
        english: 'The supermarket closes at eight in the evening.',
      ),
      RadioLine(
        german: 'Wir wünschen Ihnen einen schönen Einkauf.',
        english: 'We wish you a pleasant shopping trip.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was ist heute günstig?',
        options: <String>['Das Obst', 'Das Fleisch', 'Der Käse'],
        correctIndex: 0,
        explanation: 'Heute ist das Obst besonders günstig.',
      ),
      ChoiceQuestion(
        prompt: 'Was kostet ein Kilo Äpfel?',
        options: <String>['Einen Euro', 'Zwei Euro', 'Drei Euro'],
        correctIndex: 0,
        explanation: 'Ein Kilo Äpfel kostet nur einen Euro.',
      ),
      ChoiceQuestion(
        prompt: 'Wann schließt der Supermarkt?',
        options: <String>[
          'Um achtzehn Uhr',
          'Um zwanzig Uhr',
          'Um zweiundzwanzig Uhr',
        ],
        correctIndex: 1,
        explanation: 'Der Supermarkt schließt um zwanzig Uhr.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-05',
    level: CefrLevel.a1,
    genre: RadioGenre.diary,
    title: 'Mein Montag',
    lines: <RadioLine>[
      RadioLine(
        german: 'Am Montag stehe ich um halb sieben auf.',
        english: 'On Monday I get up at half past six.',
      ),
      RadioLine(
        german: 'Ich trinke Kaffee und esse ein Brot.',
        english: 'I drink coffee and eat a piece of bread.',
      ),
      RadioLine(
        german: 'Um acht Uhr fahre ich mit dem Bus zur Arbeit.',
        english: 'At eight I take the bus to work.',
      ),
      RadioLine(
        german: 'Die Fahrt dauert zwanzig Minuten.',
        english: 'The journey takes twenty minutes.',
      ),
      RadioLine(
        german: 'Am Abend koche ich und lese ein Buch.',
        english: 'In the evening I cook and read a book.',
      ),
      RadioLine(
        german: 'Um elf Uhr gehe ich ins Bett.',
        english: 'At eleven I go to bed.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann steht die Person auf?',
        options: <String>['Um halb sieben', 'Um sieben', 'Um acht'],
        correctIndex: 0,
        explanation: 'Am Montag stehe ich um halb sieben auf.',
      ),
      ChoiceQuestion(
        prompt: 'Wie fährt sie zur Arbeit?',
        options: <String>['Mit dem Auto', 'Mit dem Bus', 'Mit dem Fahrrad'],
        correctIndex: 1,
        explanation: 'Um acht Uhr fahre ich mit dem Bus zur Arbeit.',
      ),
      ChoiceQuestion(
        prompt: 'Was macht sie am Abend?',
        options: <String>[
          'Sie kocht und liest.',
          'Sie geht ins Kino.',
          'Sie arbeitet weiter.',
        ],
        correctIndex: 0,
        explanation: 'Am Abend koche ich und lese ein Buch.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-06',
    level: CefrLevel.a1,
    genre: RadioGenre.weather,
    title: 'Wetter am Wochenende',
    lines: <RadioLine>[
      RadioLine(
        german: 'Am Samstag ist es sonnig und warm.',
        english: 'On Saturday it is sunny and warm.',
      ),
      RadioLine(
        german: 'Die Temperatur steigt auf sechsundzwanzig Grad.',
        english: 'The temperature rises to twenty-six degrees.',
      ),
      RadioLine(
        german: 'Am Sonntag kommen Wolken aus dem Norden.',
        english: 'On Sunday clouds come from the north.',
      ),
      RadioLine(
        german: 'Am Nachmittag gibt es vielleicht ein Gewitter.',
        english: 'In the afternoon there may be a thunderstorm.',
      ),
      RadioLine(
        german: 'Es wird kühler, nur noch achtzehn Grad.',
        english: 'It gets cooler, only eighteen degrees.',
      ),
      RadioLine(
        german: 'Ein schönes Wochenende wünscht Ihnen das Gartenradio.',
        english: 'Gartenradio wishes you a lovely weekend.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie ist das Wetter am Samstag?',
        options: <String>['Sonnig und warm', 'Kalt und windig', 'Es schneit.'],
        correctIndex: 0,
        explanation: 'Am Samstag ist es sonnig und warm.',
      ),
      ChoiceQuestion(
        prompt: 'Was passiert am Sonntagnachmittag vielleicht?',
        options: <String>[
          'Es gibt Schnee.',
          'Es gibt ein Gewitter.',
          'Es wird sehr heiß.',
        ],
        correctIndex: 1,
        explanation: 'Am Nachmittag gibt es vielleicht ein Gewitter.',
      ),
      ChoiceQuestion(
        prompt: 'Wie warm wird es am Sonntag?',
        options: <String>['Sechsundzwanzig Grad', 'Achtzehn Grad', 'Acht Grad'],
        correctIndex: 1,
        explanation: 'Es wird kühler, nur noch achtzehn Grad.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-07',
    level: CefrLevel.a1,
    genre: RadioGenre.voicemail,
    title: 'Nachricht vom Arzt',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Tag, hier ist die Praxis Doktor Weber.',
        english: 'Hello, this is the practice of Doctor Weber.',
      ),
      RadioLine(
        german: 'Ihr Termin am Dienstag geht leider nicht.',
        english: 'Unfortunately your appointment on Tuesday is not possible.',
      ),
      RadioLine(
        german: 'Wir haben einen neuen Termin am Donnerstag.',
        english: 'We have a new appointment on Thursday.',
      ),
      RadioLine(
        german: 'Der Termin ist um halb zehn am Vormittag.',
        english: 'The appointment is at half past nine in the morning.',
      ),
      RadioLine(
        german: 'Bitte bringen Sie Ihre Karte mit.',
        english: 'Please bring your card with you.',
      ),
      RadioLine(
        german: 'Rufen Sie uns an, wenn das nicht geht.',
        english: 'Call us if that does not work.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Warum ruft die Praxis an?',
        options: <String>[
          'Der Termin am Dienstag geht nicht.',
          'Die Praxis ist geschlossen.',
          'Der Arzt ist krank.',
        ],
        correctIndex: 0,
        explanation: 'Ihr Termin am Dienstag geht leider nicht.',
      ),
      ChoiceQuestion(
        prompt: 'Wann ist der neue Termin?',
        options: <String>['Am Mittwoch', 'Am Donnerstag', 'Am Freitag'],
        correctIndex: 1,
        explanation: 'Wir haben einen neuen Termin am Donnerstag.',
      ),
      ChoiceQuestion(
        prompt: 'Was soll man mitbringen?',
        options: <String>['Die Karte', 'Ein Buch', 'Geld'],
        correctIndex: 0,
        explanation: 'Bitte bringen Sie Ihre Karte mit.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-08',
    level: CefrLevel.a1,
    genre: RadioGenre.recipe,
    title: 'Brot mit Käse',
    lines: <RadioLine>[
      RadioLine(
        german: 'Das ist ein sehr einfaches Rezept.',
        english: 'This is a very simple recipe.',
      ),
      RadioLine(
        german: 'Sie brauchen Brot, Butter, Käse und eine Tomate.',
        english: 'You need bread, butter, cheese and a tomato.',
      ),
      RadioLine(
        german: 'Nehmen Sie zwei Scheiben Brot.',
        english: 'Take two slices of bread.',
      ),
      RadioLine(
        german: 'Dann legen Sie den Käse auf das Brot.',
        english: 'Then put the cheese on the bread.',
      ),
      RadioLine(
        german: 'Die Tomate schneiden Sie in dünne Scheiben.',
        english: 'Cut the tomato into thin slices.',
      ),
      RadioLine(
        german: 'Fertig! Das schmeckt gut zum Frühstück.',
        english: 'Done! That tastes good for breakfast.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was braucht man für das Rezept?',
        options: <String>[
          'Brot, Butter, Käse und eine Tomate',
          'Reis und Fisch',
          'Eier und Milch',
        ],
        correctIndex: 0,
        explanation: 'Sie brauchen Brot, Butter, Käse und eine Tomate.',
      ),
      ChoiceQuestion(
        prompt: 'Wie viele Scheiben Brot nimmt man?',
        options: <String>['Eine', 'Zwei', 'Vier'],
        correctIndex: 1,
        explanation: 'Nehmen Sie zwei Scheiben Brot.',
      ),
      ChoiceQuestion(
        prompt: 'Wann schmeckt das gut?',
        options: <String>['Zum Frühstück', 'Zum Abendessen', 'In der Nacht'],
        correctIndex: 0,
        explanation: 'Das schmeckt gut zum Frühstück.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-09',
    level: CefrLevel.a1,
    genre: RadioGenre.announcement,
    title: 'Durchsage in der Schule',
    lines: <RadioLine>[
      RadioLine(
        german: 'Achtung, eine Information für alle Schüler.',
        english: 'Attention, an announcement for all pupils.',
      ),
      RadioLine(
        german: 'Der Sportunterricht fällt heute aus.',
        english: 'Physical education is cancelled today.',
      ),
      RadioLine(
        german: 'Die Turnhalle ist leider zu kalt.',
        english: 'Unfortunately the gym is too cold.',
      ),
      RadioLine(
        german: 'Ihr geht bitte in Zimmer zwölf.',
        english: 'Please go to room twelve.',
      ),
      RadioLine(
        german: 'Dort macht ihr Mathematik mit Frau Berg.',
        english: 'There you will do mathematics with Mrs Berg.',
      ),
      RadioLine(
        german: 'Der Unterricht beginnt in fünf Minuten.',
        english: 'The lesson begins in five minutes.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Welcher Unterricht fällt aus?',
        options: <String>['Der Sportunterricht', 'Mathematik', 'Deutsch'],
        correctIndex: 0,
        explanation: 'Der Sportunterricht fällt heute aus.',
      ),
      ChoiceQuestion(
        prompt: 'Warum fällt er aus?',
        options: <String>[
          'Die Turnhalle ist zu kalt.',
          'Der Lehrer ist krank.',
          'Es regnet.',
        ],
        correctIndex: 0,
        explanation: 'Die Turnhalle ist leider zu kalt.',
      ),
      ChoiceQuestion(
        prompt: 'Wohin gehen die Schüler?',
        options: <String>['In Zimmer zehn', 'In Zimmer zwölf', 'Nach Hause'],
        correctIndex: 1,
        explanation: 'Ihr geht bitte in Zimmer zwölf.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-10',
    level: CefrLevel.a1,
    genre: RadioGenre.diary,
    title: 'Meine Familie',
    lines: <RadioLine>[
      RadioLine(
        german: 'Ich heiße Laura und bin dreißig Jahre alt.',
        english: 'My name is Laura and I am thirty years old.',
      ),
      RadioLine(
        german: 'Ich wohne mit meinem Mann in einer kleinen Wohnung.',
        english: 'I live with my husband in a small flat.',
      ),
      RadioLine(
        german: 'Wir haben eine Tochter. Sie ist vier.',
        english: 'We have a daughter. She is four.',
      ),
      RadioLine(
        german: 'Meine Eltern wohnen in einem Dorf am Meer.',
        english: 'My parents live in a village by the sea.',
      ),
      RadioLine(
        german: 'Im Sommer besuchen wir sie oft.',
        english: 'In summer we often visit them.',
      ),
      RadioLine(
        german: 'Meine Tochter spielt dann den ganzen Tag draußen.',
        english: 'My daughter then plays outside all day.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie alt ist Lauras Tochter?',
        options: <String>['Vier', 'Zehn', 'Dreißig'],
        correctIndex: 0,
        explanation: 'Wir haben eine Tochter. Sie ist vier.',
      ),
      ChoiceQuestion(
        prompt: 'Wo wohnen Lauras Eltern?',
        options: <String>[
          'In einem Dorf am Meer',
          'In der Stadt',
          'In den Bergen',
        ],
        correctIndex: 0,
        explanation: 'Meine Eltern wohnen in einem Dorf am Meer.',
      ),
      ChoiceQuestion(
        prompt: 'Wann besuchen sie die Eltern?',
        options: <String>['Im Winter', 'Im Sommer', 'Nie'],
        correctIndex: 1,
        explanation: 'Im Sommer besuchen wir sie oft.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-11',
    level: CefrLevel.a1,
    genre: RadioGenre.announcement,
    title: 'Im Zug nach Hamburg',
    lines: <RadioLine>[
      RadioLine(
        german: 'Willkommen im Zug nach Hamburg.',
        english: 'Welcome aboard the train to Hamburg.',
      ),
      RadioLine(
        german: 'Wir fahren gleich ab.',
        english: 'We are departing shortly.',
      ),
      RadioLine(
        german: 'Der nächste Halt ist Bremen.',
        english: 'The next stop is Bremen.',
      ),
      RadioLine(
        german: 'Im Wagen vier finden Sie ein Restaurant.',
        english: 'In carriage four you will find a restaurant.',
      ),
      RadioLine(
        german: 'Dort gibt es Kaffee, Wasser und kleine Speisen.',
        english: 'There is coffee, water and small dishes there.',
      ),
      RadioLine(
        german: 'Wir kommen um vierzehn Uhr in Hamburg an.',
        english: 'We arrive in Hamburg at two in the afternoon.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was ist der nächste Halt?',
        options: <String>['Hamburg', 'Bremen', 'München'],
        correctIndex: 1,
        explanation: 'Der nächste Halt ist Bremen.',
      ),
      ChoiceQuestion(
        prompt: 'Wo ist das Restaurant?',
        options: <String>['Im Wagen zwei', 'Im Wagen vier', 'Im Wagen zehn'],
        correctIndex: 1,
        explanation: 'Im Wagen vier finden Sie ein Restaurant.',
      ),
      ChoiceQuestion(
        prompt: 'Wann kommt der Zug an?',
        options: <String>['Um zwölf Uhr', 'Um vierzehn Uhr', 'Um sechzehn Uhr'],
        correctIndex: 1,
        explanation: 'Wir kommen um vierzehn Uhr in Hamburg an.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-12',
    level: CefrLevel.a1,
    genre: RadioGenre.diary,
    title: 'Ein Tag im Park',
    lines: <RadioLine>[
      RadioLine(
        german: 'Gestern war das Wetter sehr schön.',
        english: 'Yesterday the weather was very nice.',
      ),
      RadioLine(
        german: 'Wir sind in den Park gegangen.',
        english: 'We went to the park.',
      ),
      RadioLine(
        german: 'Die Kinder haben Fußball gespielt.',
        english: 'The children played football.',
      ),
      RadioLine(
        german: 'Ich habe unter einem Baum gesessen und gelesen.',
        english: 'I sat under a tree and read.',
      ),
      RadioLine(
        german: 'Am Nachmittag haben wir Eis gegessen.',
        english: 'In the afternoon we ate ice cream.',
      ),
      RadioLine(
        german: 'Um sechs Uhr sind wir nach Hause gefahren.',
        english: 'At six we drove home.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wohin sind sie gegangen?',
        options: <String>['In den Park', 'Ins Kino', 'In die Stadt'],
        correctIndex: 0,
        explanation: 'Wir sind in den Park gegangen.',
      ),
      ChoiceQuestion(
        prompt: 'Was haben die Kinder gemacht?',
        options: <String>[
          'Sie haben gelesen.',
          'Sie haben Fußball gespielt.',
          'Sie haben geschlafen.',
        ],
        correctIndex: 1,
        explanation: 'Die Kinder haben Fußball gespielt.',
      ),
      ChoiceQuestion(
        prompt: 'Was haben sie am Nachmittag gegessen?',
        options: <String>['Kuchen', 'Eis', 'Brot'],
        correctIndex: 1,
        explanation: 'Am Nachmittag haben wir Eis gegessen.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-13',
    level: CefrLevel.a1,
    genre: RadioGenre.audioGuide,
    title: 'Audioguide: Der Marktplatz',
    lines: <RadioLine>[
      RadioLine(
        german: 'Sie stehen jetzt auf dem Marktplatz.',
        english: 'You are now standing on the market square.',
      ),
      RadioLine(
        german: 'Der Platz ist sehr alt.',
        english: 'The square is very old.',
      ),
      RadioLine(
        german: 'Links sehen Sie das Rathaus.',
        english: 'On the left you see the town hall.',
      ),
      RadioLine(
        german: 'Rechts ist eine kleine Kirche.',
        english: 'On the right there is a small church.',
      ),
      RadioLine(
        german: 'Am Mittwoch und Samstag gibt es hier einen Markt.',
        english: 'On Wednesday and Saturday there is a market here.',
      ),
      RadioLine(
        german: 'Gehen Sie jetzt bitte geradeaus weiter.',
        english: 'Please continue straight ahead now.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was sieht man links?',
        options: <String>['Das Rathaus', 'Die Kirche', 'Den Bahnhof'],
        correctIndex: 0,
        explanation: 'Links sehen Sie das Rathaus.',
      ),
      ChoiceQuestion(
        prompt: 'Wann gibt es einen Markt?',
        options: <String>[
          'Am Montag und Dienstag',
          'Am Mittwoch und Samstag',
          'Jeden Tag',
        ],
        correctIndex: 1,
        explanation: 'Am Mittwoch und Samstag gibt es hier einen Markt.',
      ),
      ChoiceQuestion(
        prompt: 'Wohin soll man jetzt gehen?',
        options: <String>['Nach links', 'Nach rechts', 'Geradeaus'],
        correctIndex: 2,
        explanation: 'Gehen Sie jetzt bitte geradeaus weiter.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-14',
    level: CefrLevel.a1,
    genre: RadioGenre.voicemail,
    title: 'Nachricht vom Vermieter',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Abend, hier spricht Herr Klein.',
        english: 'Good evening, this is Mr Klein speaking.',
      ),
      RadioLine(
        german: 'Am Freitag kommt ein Mann für die Heizung.',
        english: 'On Friday a man is coming about the heating.',
      ),
      RadioLine(
        german: 'Er kommt zwischen neun und elf Uhr.',
        english: 'He is coming between nine and eleven.',
      ),
      RadioLine(
        german: 'Bitte bleiben Sie am Vormittag zu Hause.',
        english: 'Please stay at home in the morning.',
      ),
      RadioLine(
        german: 'Die Arbeit dauert ungefähr eine Stunde.',
        english: 'The work takes about an hour.',
      ),
      RadioLine(
        german: 'Vielen Dank und einen schönen Abend.',
        english: 'Many thanks and have a nice evening.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Warum kommt am Freitag ein Mann?',
        options: <String>['Für die Heizung', 'Für das Fenster', 'Für die Tür'],
        correctIndex: 0,
        explanation: 'Am Freitag kommt ein Mann für die Heizung.',
      ),
      ChoiceQuestion(
        prompt: 'Wann kommt er?',
        options: <String>[
          'Zwischen neun und elf Uhr',
          'Am Nachmittag',
          'Am Abend',
        ],
        correctIndex: 0,
        explanation: 'Er kommt zwischen neun und elf Uhr.',
      ),
      ChoiceQuestion(
        prompt: 'Wie lange dauert die Arbeit?',
        options: <String>[
          'Zehn Minuten',
          'Ungefähr eine Stunde',
          'Den ganzen Tag',
        ],
        correctIndex: 1,
        explanation: 'Die Arbeit dauert ungefähr eine Stunde.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-15',
    level: CefrLevel.a1,
    genre: RadioGenre.news,
    title: 'Kurze Nachrichten',
    lines: <RadioLine>[
      RadioLine(
        german: 'Guten Morgen. Hier sind die Nachrichten.',
        english: 'Good morning. Here is the news.',
      ),
      RadioLine(
        german: 'Im Zentrum gibt es einen neuen Kindergarten.',
        english: 'There is a new kindergarten in the centre.',
      ),
      RadioLine(
        german: 'Er öffnet im September.',
        english: 'It opens in September.',
      ),
      RadioLine(
        german: 'Das Schwimmbad ist diese Woche geschlossen.',
        english: 'The swimming pool is closed this week.',
      ),
      RadioLine(
        german: 'Am Sonntag fährt der Bus nicht.',
        english: 'On Sunday the bus does not run.',
      ),
      RadioLine(
        german: 'Das war es. Einen guten Tag!',
        english: 'That was all. Have a good day!',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wann öffnet der Kindergarten?',
        options: <String>['Im Juli', 'Im September', 'Im Dezember'],
        correctIndex: 1,
        explanation: 'Er öffnet im September.',
      ),
      ChoiceQuestion(
        prompt: 'Was ist diese Woche geschlossen?',
        options: <String>['Das Schwimmbad', 'Die Schule', 'Der Supermarkt'],
        correctIndex: 0,
        explanation: 'Das Schwimmbad ist diese Woche geschlossen.',
      ),
      ChoiceQuestion(
        prompt: 'Was passiert am Sonntag?',
        options: <String>[
          'Der Bus fährt nicht.',
          'Der Markt ist offen.',
          'Es gibt ein Fest.',
        ],
        correctIndex: 0,
        explanation: 'Am Sonntag fährt der Bus nicht.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-16',
    level: CefrLevel.a1,
    genre: RadioGenre.diary,
    title: 'Einkaufen am Samstag',
    lines: <RadioLine>[
      RadioLine(
        german: 'Am Samstag gehe ich immer einkaufen.',
        english: 'On Saturday I always go shopping.',
      ),
      RadioLine(
        german: 'Zuerst kaufe ich Brot und Milch.',
        english: 'First I buy bread and milk.',
      ),
      RadioLine(
        german: 'Dann gehe ich zum Markt und kaufe Gemüse.',
        english: 'Then I go to the market and buy vegetables.',
      ),
      RadioLine(
        german: 'Das Gemüse dort ist frisch und nicht teuer.',
        english: 'The vegetables there are fresh and not expensive.',
      ),
      RadioLine(
        german: 'Danach trinke ich einen Kaffee im Café.',
        english: 'Afterwards I drink a coffee in the café.',
      ),
      RadioLine(
        german: 'Um zwölf Uhr bin ich wieder zu Hause.',
        english: 'At twelve I am back home.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Was kauft die Person zuerst?',
        options: <String>['Brot und Milch', 'Gemüse', 'Kaffee'],
        correctIndex: 0,
        explanation: 'Zuerst kaufe ich Brot und Milch.',
      ),
      ChoiceQuestion(
        prompt: 'Wie ist das Gemüse auf dem Markt?',
        options: <String>[
          'Frisch und nicht teuer',
          'Alt und teuer',
          'Sehr teuer',
        ],
        correctIndex: 0,
        explanation: 'Das Gemüse dort ist frisch und nicht teuer.',
      ),
      ChoiceQuestion(
        prompt: 'Wann ist sie wieder zu Hause?',
        options: <String>['Um zehn Uhr', 'Um zwölf Uhr', 'Um zwei Uhr'],
        correctIndex: 1,
        explanation: 'Um zwölf Uhr bin ich wieder zu Hause.',
      ),
    ],
  ),
  RadioEpisode(
    id: 'rd-a1-17',
    level: CefrLevel.a1,
    genre: RadioGenre.weather,
    title: 'Wetter im Winter',
    lines: <RadioLine>[
      RadioLine(
        german: 'Heute ist es sehr kalt.',
        english: 'Today it is very cold.',
      ),
      RadioLine(
        german: 'Am Morgen liegt die Temperatur bei minus drei Grad.',
        english: 'In the morning the temperature is minus three degrees.',
      ),
      RadioLine(
        german: 'In den Bergen schneit es seit gestern.',
        english: 'In the mountains it has been snowing since yesterday.',
      ),
      RadioLine(
        german: 'Die Straßen sind glatt. Fahren Sie langsam.',
        english: 'The roads are slippery. Drive slowly.',
      ),
      RadioLine(
        german: 'Am Nachmittag scheint kurz die Sonne.',
        english: 'In the afternoon the sun shines briefly.',
      ),
      RadioLine(
        german: 'In der Nacht wird es wieder kälter.',
        english: 'At night it gets colder again.',
      ),
    ],
    questions: <ChoiceQuestion>[
      ChoiceQuestion(
        prompt: 'Wie kalt ist es am Morgen?',
        options: <String>['Minus drei Grad', 'Drei Grad', 'Zehn Grad'],
        correctIndex: 0,
        explanation: 'Am Morgen liegt die Temperatur bei minus drei Grad.',
      ),
      ChoiceQuestion(
        prompt: 'Wo schneit es?',
        options: <String>['In den Bergen', 'Am Meer', 'In der Stadt'],
        correctIndex: 0,
        explanation: 'In den Bergen schneit es seit gestern.',
      ),
      ChoiceQuestion(
        prompt: 'Warum soll man langsam fahren?',
        options: <String>[
          'Die Straßen sind glatt.',
          'Es ist dunkel.',
          'Es gibt viel Verkehr.',
        ],
        correctIndex: 0,
        explanation: 'Die Straßen sind glatt. Fahren Sie langsam.',
      ),
    ],
  ),
];
