import 'dart:math';

/// The subject areas used by the German Class B theory examination.
///
/// The questions in this file are original study questions written for
/// DeutschGarden. They are aligned with the subject areas in FeV Anlage 7;
/// they are not a copied official question catalogue.
enum DrivingQuestionCategory {
  danger,
  speedAndDistance,
  rightOfWay,
  signsAndMarkings,
  motorway,
  vulnerableRoadUsers,
  vehicleTechnology,
  fitnessAndEnvironment,
}

extension DrivingQuestionCategoryX on DrivingQuestionCategory {
  String get label => switch (this) {
    DrivingQuestionCategory.danger => 'Danger awareness',
    DrivingQuestionCategory.speedAndDistance => 'Speed and distance',
    DrivingQuestionCategory.rightOfWay => 'Right of way',
    DrivingQuestionCategory.signsAndMarkings => 'Signs and markings',
    DrivingQuestionCategory.motorway => 'Motorway driving',
    DrivingQuestionCategory.vulnerableRoadUsers => 'People at risk',
    DrivingQuestionCategory.vehicleTechnology => 'Vehicle technology',
    DrivingQuestionCategory.fitnessAndEnvironment => 'Fitness and environment',
  };
}

class DrivingOption {
  const DrivingOption({required this.german, required this.english});

  final String german;
  final String english;
}

class DrivingQuestion {
  const DrivingQuestion({
    required this.id,
    required this.category,
    required this.points,
    required this.questionGerman,
    required this.questionEnglish,
    required this.options,
    required this.correctIndex,
    required this.explanationGerman,
    required this.explanationEnglish,
  });

  final String id;
  final DrivingQuestionCategory category;
  final int points;
  final String questionGerman;
  final String questionEnglish;
  final List<DrivingOption> options;
  final int correctIndex;
  final String explanationGerman;
  final String explanationEnglish;

  DrivingOption get correctOption => options[correctIndex];

  bool get isUsable =>
      id.trim().isNotEmpty &&
      points >= 2 &&
      points <= 5 &&
      questionGerman.trim().isNotEmpty &&
      questionEnglish.trim().isNotEmpty &&
      options.length == 4 &&
      options.map((DrivingOption option) => option.german).toSet().length ==
          4 &&
      options.map((DrivingOption option) => option.english).toSet().length ==
          4 &&
      correctIndex >= 0 &&
      correctIndex < options.length &&
      options.every(
        (DrivingOption option) =>
            option.german.trim().isNotEmpty && option.english.trim().isNotEmpty,
      );

  /// Permute the option pair together so German and English never drift.
  DrivingQuestion shuffled(Random random) {
    final List<int> order = List<int>.generate(options.length, (int i) => i)
      ..shuffle(random);
    return DrivingQuestion(
      id: id,
      category: category,
      points: points,
      questionGerman: questionGerman,
      questionEnglish: questionEnglish,
      options: List<DrivingOption>.unmodifiable(<DrivingOption>[
        for (final int index in order) options[index],
      ]),
      correctIndex: order.indexOf(correctIndex),
      explanationGerman: explanationGerman,
      explanationEnglish: explanationEnglish,
    );
  }
}

class DrivingTheoryCatalog {
  DrivingTheoryCatalog._();

  static const int mockQuestionCount = 30;
  static const int officialMaximumPoints = 110;
  static const int officialMaximumErrorPoints = 10;

  /// Original, compact practice questions. The official exam contains many
  /// more variants; this bank is intentionally transparent about its scope.
  static const List<DrivingQuestion> questions = <DrivingQuestion>[
    DrivingQuestion(
      id: 'drive-danger-01',
      category: DrivingQuestionCategory.danger,
      points: 5,
      questionGerman:
          'Ein Kind steht an der Straße und schaut nicht auf den Verkehr. Wie verhalten Sie sich?',
      questionEnglish:
          'A child is standing beside the road and is not watching the traffic. What do you do?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Geschwindigkeit verringern und bremsbereit sein',
          english: 'Reduce speed and be ready to brake',
        ),
        DrivingOption(
          german: 'Unverändert weiterfahren',
          english: 'Continue at the same speed',
        ),
        DrivingOption(
          german: 'Nur die Lichthupe benutzen',
          english: 'Use only the headlight flasher',
        ),
        DrivingOption(
          german: 'Dicht am Kind vorbeifahren',
          english: 'Drive close past the child',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Kinder können die Geschwindigkeit eines Fahrzeugs und die Gefahr oft noch nicht zuverlässig einschätzen.',
      explanationEnglish:
          'Children may not yet be able to judge vehicle speed and danger reliably.',
    ),
    DrivingQuestion(
      id: 'drive-danger-02',
      category: DrivingQuestionCategory.danger,
      points: 4,
      questionGerman:
          'Nach starkem Regen liegen nasse Blätter auf der Fahrbahn. Was ist besonders wichtig?',
      questionEnglish:
          'After heavy rain, wet leaves are lying on the road. What is especially important?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Langsamer fahren und mehr Abstand halten',
          english: 'Drive more slowly and keep a greater distance',
        ),
        DrivingOption(
          german: 'Schneller fahren, damit die Reifen warm werden',
          english: 'Drive faster so the tyres become warm',
        ),
        DrivingOption(
          german: 'Den Reifendruck sofort verdoppeln',
          english: 'Immediately double the tyre pressure',
        ),
        DrivingOption(
          german: 'Nur auf den Gegenverkehr achten',
          english: 'Watch only the oncoming traffic',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Nässe und Laub können die Haftung deutlich verringern. Geschwindigkeit und Abstand müssen angepasst werden.',
      explanationEnglish:
          'Water and leaves can greatly reduce grip. Adjust both speed and distance.',
    ),
    DrivingQuestion(
      id: 'drive-danger-03',
      category: DrivingQuestionCategory.danger,
      points: 5,
      questionGerman:
          'Bei dichtem Nebel können Sie nur wenige Meter weit sehen. Wie fahren Sie?',
      questionEnglish:
          'In dense fog you can see only a few metres ahead. How should you drive?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'So langsam, dass Sie innerhalb der Sichtweite anhalten können',
          english: 'Slowly enough to stop within the visible distance',
        ),
        DrivingOption(
          german: 'Mit der erlaubten Höchstgeschwindigkeit',
          english: 'At the posted maximum speed',
        ),
        DrivingOption(
          german: 'Mit eingeschalteter Warnblinkanlage weiterfahren',
          english: 'Continue with the hazard warning lights on',
        ),
        DrivingOption(
          german: 'Dicht hinter einem anderen Fahrzeug bleiben',
          english: 'Stay close behind another vehicle',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Die Geschwindigkeit muss zur Sichtweite passen. Die erlaubte Höchstgeschwindigkeit ist keine Pflichtgeschwindigkeit.',
      explanationEnglish:
          'Speed must match visibility. The posted maximum speed is not a required speed.',
    ),
    DrivingQuestion(
      id: 'drive-danger-04',
      category: DrivingQuestionCategory.danger,
      points: 4,
      questionGerman:
          'Vor einer unübersichtlichen Kurve möchten Sie ein langsames Fahrzeug überholen. Was gilt?',
      questionEnglish:
          'You want to overtake a slow vehicle before a blind bend. What applies?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Nicht überholen, wenn der Gegenverkehr nicht sicher ausgeschlossen ist',
          english:
              'Do not overtake unless oncoming traffic can safely be ruled out',
        ),
        DrivingOption(
          german: 'Überholen, wenn Sie kurz hupen',
          english: 'Overtake if you sound the horn briefly',
        ),
        DrivingOption(
          german: 'Überholen, weil das andere Fahrzeug langsam ist',
          english: 'Overtake because the other vehicle is slow',
        ),
        DrivingOption(
          german: 'Nur in der Kurve beschleunigen',
          english: 'Accelerate only in the bend',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'An unübersichtlichen Stellen fehlt der nötige Überblick für ein sicheres Überholen.',
      explanationEnglish:
          'At a blind location you do not have the overview required for safe overtaking.',
    ),
    DrivingQuestion(
      id: 'drive-danger-05',
      category: DrivingQuestionCategory.danger,
      points: 3,
      questionGerman:
          'Sie nähern sich einer Baustelle mit Menschen auf der Fahrbahn. Was tun Sie?',
      questionEnglish:
          'You approach roadworks where people are on the carriageway. What do you do?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Geschwindigkeit verringern und besonders aufmerksam fahren',
          english: 'Reduce speed and drive with extra attention',
        ),
        DrivingOption(
          german: 'Die Arbeiter durch Hupen vertreiben',
          english: 'Move the workers away by sounding the horn',
        ),
        DrivingOption(
          german: 'So nah wie möglich an der Absperrung fahren',
          english: 'Drive as close as possible to the barrier',
        ),
        DrivingOption(
          german: 'Nur nach hinten sehen',
          english: 'Look only behind you',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Baustellen verändern die Fahrbahn und bringen besonders gefährdete Personen in die Nähe des Verkehrs.',
      explanationEnglish:
          'Roadworks change the road layout and bring especially vulnerable people close to traffic.',
    ),
    DrivingQuestion(
      id: 'drive-danger-06',
      category: DrivingQuestionCategory.danger,
      points: 5,
      questionGerman:
          'Sie sind während der Fahrt sehr müde. Welche Entscheidung ist sicher?',
      questionEnglish:
          'You are very tired while driving. Which decision is safe?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'An einem sicheren Ort anhalten und eine Pause machen',
          english: 'Stop in a safe place and take a break',
        ),
        DrivingOption(
          german: 'Das Fenster öffnen und unverändert weiterfahren',
          english: 'Open the window and continue unchanged',
        ),
        DrivingOption(
          german: 'Laut Musik hören und schneller fahren',
          english: 'Play loud music and drive faster',
        ),
        DrivingOption(
          german: 'Die Augen kurz schließen',
          english: 'Close your eyes briefly',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Müdigkeit verlängert Reaktionszeiten. Frische Luft oder laute Musik ersetzen keine Pause.',
      explanationEnglish:
          'Fatigue increases reaction time. Fresh air or loud music is not a substitute for a break.',
    ),
    DrivingQuestion(
      id: 'drive-danger-07',
      category: DrivingQuestionCategory.danger,
      points: 5,
      questionGerman:
          'Im Stau nähert sich ein Einsatzfahrzeug mit Blaulicht und Martinshorn. Was müssen Sie ermöglichen?',
      questionEnglish:
          'In a traffic jam, an emergency vehicle approaches with blue lights and a siren. What must you enable?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Eine freie Rettungsgasse',
          english: 'A clear emergency corridor',
        ),
        DrivingOption(
          german: 'Eine Fahrt auf dem Gehweg',
          english: 'Travel on the pavement',
        ),
        DrivingOption(
          german: 'Das Wenden aller Fahrzeuge',
          english: 'All vehicles turning around',
        ),
        DrivingOption(
          german: 'Das Überholen des Einsatzfahrzeugs',
          english: 'Overtaking the emergency vehicle',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Bei stockendem Verkehr muss die Rettungsgasse frühzeitig gebildet und offen gehalten werden.',
      explanationEnglish:
          'When traffic is queuing, form the emergency corridor early and keep it open.',
    ),
    DrivingQuestion(
      id: 'drive-danger-08',
      category: DrivingQuestionCategory.danger,
      points: 4,
      questionGerman: 'Ein Reh steht am Straßenrand. Womit müssen Sie rechnen?',
      questionEnglish:
          'A deer is standing at the side of the road. What must you expect?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Dass weitere Tiere folgen können',
          english: 'That more animals may follow',
        ),
        DrivingOption(
          german: 'Dass die Fahrbahn sicher frei bleibt',
          english: 'That the road will certainly stay clear',
        ),
        DrivingOption(
          german: 'Dass Sie immer hupen müssen',
          english: 'That you must always sound the horn',
        ),
        DrivingOption(
          german: 'Dass Fernlicht die Tiere sicher wegführt',
          english: 'That high beam will safely lead the animals away',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Wildtiere treten häufig nicht allein auf. Fahren Sie langsamer und bremsbereit.',
      explanationEnglish:
          'Wild animals often do not appear alone. Slow down and be ready to brake.',
    ),
    DrivingQuestion(
      id: 'drive-danger-09',
      category: DrivingQuestionCategory.danger,
      points: 3,
      questionGerman:
          'Ein Fahrzeug vor Ihnen hält plötzlich ohne erkennbaren Grund. Was ist richtig?',
      questionEnglish:
          'A vehicle ahead suddenly stops for no apparent reason. What is correct?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Abstand vergrößern und mit einer Gefahr rechnen',
          english: 'Increase the distance and expect a hazard',
        ),
        DrivingOption(
          german: 'Sofort dicht auffahren',
          english: 'Immediately drive close behind it',
        ),
        DrivingOption(
          german: 'Ohne Sichtprüfung links vorbeifahren',
          english: 'Pass on the left without checking',
        ),
        DrivingOption(
          german: 'Die Hupe dauerhaft drücken',
          english: 'Press the horn continuously',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Ein unerwarteter Halt kann auf Personen, ein Hindernis oder eine Gefahr vor dem Fahrzeug hinweisen.',
      explanationEnglish:
          'An unexpected stop may indicate people, an obstacle, or a hazard ahead.',
    ),
    DrivingQuestion(
      id: 'drive-speed-01',
      category: DrivingQuestionCategory.speedAndDistance,
      points: 3,
      questionGerman: 'Was bedeutet ein Tempolimit von 50 km/h?',
      questionEnglish: 'What does a 50 km/h speed limit mean?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              '50 km/h ist die höchstens erlaubte Geschwindigkeit, wenn die Bedingungen es zulassen',
          english:
              '50 km/h is the maximum permitted speed when conditions allow it',
        ),
        DrivingOption(
          german: 'Sie müssen immer genau 50 km/h fahren',
          english: 'You must always drive exactly 50 km/h',
        ),
        DrivingOption(
          german: 'Sie dürfen mindestens 50 km/h fahren',
          english: 'You may drive at least 50 km/h',
        ),
        DrivingOption(
          german: 'Das Limit gilt nur bei Sonnenschein',
          english: 'The limit applies only in sunshine',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Bei schlechter Sicht, Nässe oder einer Gefahr kann eine niedrigere Geschwindigkeit notwendig sein.',
      explanationEnglish:
          'Poor visibility, wet roads, or a hazard may require a lower speed.',
    ),
    DrivingQuestion(
      id: 'drive-speed-02',
      category: DrivingQuestionCategory.speedAndDistance,
      points: 4,
      questionGerman:
          'Warum müssen Sie bei Regen den Abstand zum vorausfahrenden Fahrzeug vergrößern?',
      questionEnglish:
          'Why must you increase your distance from the vehicle ahead in rain?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Der Bremsweg kann länger werden',
          english: 'The braking distance may become longer',
        ),
        DrivingOption(
          german: 'Damit andere schneller überholen können',
          english: 'So that others can overtake faster',
        ),
        DrivingOption(
          german: 'Weil die Fahrbahn dann breiter ist',
          english: 'Because the road is wider then',
        ),
        DrivingOption(
          german: 'Damit das eigene Fahrzeug weniger wiegt',
          english: 'So that your vehicle weighs less',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Nässe verringert die Haftung zwischen Reifen und Fahrbahn und kann den Bremsweg verlängern.',
      explanationEnglish:
          'Wet conditions reduce tyre grip and can lengthen the braking distance.',
    ),
    DrivingQuestion(
      id: 'drive-speed-03',
      category: DrivingQuestionCategory.speedAndDistance,
      points: 5,
      questionGerman:
          'Sie sehen wegen einer Kuppe die Straße vor Ihnen nicht. Wie wählen Sie die Geschwindigkeit?',
      questionEnglish:
          'You cannot see the road ahead because of a crest. How do you choose your speed?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'So, dass Sie auf der einsehbaren Strecke anhalten können',
          english: 'So that you can stop within the visible stretch',
        ),
        DrivingOption(
          german: 'Nach dem Fahrzeug hinter Ihnen',
          english: 'Based on the vehicle behind you',
        ),
        DrivingOption(
          german: 'Immer nach der zulässigen Höchstgeschwindigkeit',
          english: 'Always based on the maximum permitted speed',
        ),
        DrivingOption(
          german: 'So schnell wie möglich, damit die Kuppe endet',
          english: 'As fast as possible so the crest ends sooner',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Sichtweite und möglicher Anhalteweg müssen zusammenpassen.',
      explanationEnglish:
          'Visibility and the possible stopping distance must match.',
    ),
    DrivingQuestion(
      id: 'drive-speed-04',
      category: DrivingQuestionCategory.speedAndDistance,
      points: 3,
      questionGerman:
          'Was ist ein guter Grund, den Sicherheitsabstand auch bei trockener Fahrbahn zu vergrößern?',
      questionEnglish:
          'What is a good reason to increase the safety distance even on a dry road?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Das vorausfahrende Fahrzeug fährt ungleichmäßig',
          english: 'The vehicle ahead is driving erratically',
        ),
        DrivingOption(
          german: 'Sie möchten den Verkehr dichter machen',
          english: 'You want to make traffic denser',
        ),
        DrivingOption(
          german: 'Der eigene Tank ist voll',
          english: 'Your own tank is full',
        ),
        DrivingOption(
          german: 'Die Straße hat eine Mittellinie',
          english: 'The road has a centre line',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Ein größerer Abstand gibt mehr Zeit zum Reagieren, wenn das vordere Fahrzeug plötzlich bremst.',
      explanationEnglish:
          'A greater distance gives you more time to react if the vehicle ahead brakes suddenly.',
    ),
    DrivingQuestion(
      id: 'drive-speed-05',
      category: DrivingQuestionCategory.speedAndDistance,
      points: 4,
      questionGerman: 'Was müssen Sie bei Glätte besonders beachten?',
      questionEnglish:
          'What must you pay particular attention to on icy roads?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Langsam und ohne abrupte Lenk- oder Bremsmanöver fahren',
          english: 'Drive slowly without abrupt steering or braking',
        ),
        DrivingOption(
          german: 'Stark beschleunigen',
          english: 'Accelerate strongly',
        ),
        DrivingOption(
          german: 'Den Abstand verkürzen',
          english: 'Shorten the distance',
        ),
        DrivingOption(
          german: 'Die Kupplung dauerhaft treten und schnell lenken',
          english: 'Keep the clutch pressed and steer quickly',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Abrupte Aktionen können auf glatter Fahrbahn zum Verlust der Kontrolle führen.',
      explanationEnglish:
          'Abrupt actions can cause loss of control on a slippery road.',
    ),
    DrivingQuestion(
      id: 'drive-speed-06',
      category: DrivingQuestionCategory.speedAndDistance,
      points: 5,
      questionGerman:
          'Warum ist dichtes Auffahren hinter einem Lkw besonders gefährlich?',
      questionEnglish:
          'Why is following very closely behind a lorry especially dangerous?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Die Sicht nach vorn ist eingeschränkt',
          english: 'Your view ahead is restricted',
        ),
        DrivingOption(
          german: 'Der Lkw fährt dadurch automatisch schneller',
          english: 'The lorry automatically drives faster',
        ),
        DrivingOption(
          german: 'Der eigene Bremsweg wird immer kürzer',
          english: 'Your braking distance always becomes shorter',
        ),
        DrivingOption(
          german: 'Die Fahrbahn wird dadurch schmaler',
          english: 'The road becomes narrower because of it',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Hindernisse und bremsende Fahrzeuge vor dem Lkw werden möglicherweise zu spät gesehen.',
      explanationEnglish:
          'Obstacles and braking vehicles in front of the lorry may be seen too late.',
    ),
    DrivingQuestion(
      id: 'drive-speed-07',
      category: DrivingQuestionCategory.speedAndDistance,
      points: 4,
      questionGerman: 'Wann müssen Sie einen Überholvorgang abbrechen?',
      questionEnglish: 'When must you abort an overtaking manoeuvre?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Wenn die Verkehrslage nicht mehr sicher überblickt werden kann',
          english:
              'When the traffic situation can no longer be assessed safely',
        ),
        DrivingOption(
          german: 'Wenn der Überholte langsamer wird',
          english: 'When the vehicle being overtaken slows down',
        ),
        DrivingOption(
          german: 'Wenn Sie schon den Blinker gesetzt haben',
          english: 'When you have already indicated',
        ),
        DrivingOption(
          german: 'Wenn hinter Ihnen niemand fährt',
          english: 'When nobody is driving behind you',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Sicherheit geht vor dem Abschluss eines begonnenen Überholvorgangs.',
      explanationEnglish:
          'Safety takes priority over completing a manoeuvre that has already begun.',
    ),
    DrivingQuestion(
      id: 'drive-speed-08',
      category: DrivingQuestionCategory.speedAndDistance,
      points: 3,
      questionGerman: 'Was kann den Anhalteweg eines Fahrzeugs verlängern?',
      questionEnglish: 'What can lengthen a vehicle’s stopping distance?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Hohe Geschwindigkeit und nasse Fahrbahn',
          english: 'High speed and a wet road',
        ),
        DrivingOption(
          german: 'Gute Sicht und trockene Fahrbahn',
          english: 'Good visibility and a dry road',
        ),
        DrivingOption(
          german: 'Ein größerer Sicherheitsabstand',
          english: 'A greater safety distance',
        ),
        DrivingOption(german: 'Eine freie Fahrbahn', english: 'A clear road'),
      ],
      correctIndex: 0,
      explanationGerman:
          'Reaktionsweg und Bremsweg werden bei höherer Geschwindigkeit größer; Nässe kann die Bremsung zusätzlich erschweren.',
      explanationEnglish:
          'Reaction and braking distances grow with speed; wetness can make braking harder as well.',
    ),
    DrivingQuestion(
      id: 'drive-speed-09',
      category: DrivingQuestionCategory.speedAndDistance,
      points: 2,
      questionGerman: 'Was ist bei einer Gefällestrecke sinnvoll?',
      questionEnglish: 'What is sensible on a downhill stretch?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Geschwindigkeit kontrollieren und die Motorbremse nutzen',
          english: 'Control speed and use engine braking',
        ),
        DrivingOption(
          german: 'Den Motor ausschalten',
          english: 'Switch off the engine',
        ),
        DrivingOption(
          german: 'In den Leerlauf schalten und schneller werden',
          english: 'Select neutral and gain speed',
        ),
        DrivingOption(
          german: 'Den Sicherheitsabstand verringern',
          english: 'Reduce the safety distance',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Eine passende Geschwindigkeit und Motorbremswirkung entlasten die Betriebsbremse.',
      explanationEnglish:
          'A suitable speed and engine braking reduce the load on the service brake.',
    ),
    DrivingQuestion(
      id: 'drive-right-01',
      category: DrivingQuestionCategory.rightOfWay,
      points: 4,
      questionGerman:
          'An einer gleichrangigen, ungeregelten Kreuzung gilt grundsätzlich:',
      questionEnglish:
          'At an equal, uncontrolled intersection, the basic rule is:',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Rechts vor links',
          english: 'Traffic from the right has priority',
        ),
        DrivingOption(
          german: 'Links vor rechts',
          english: 'Traffic from the left has priority',
        ),
        DrivingOption(
          german: 'Das größere Fahrzeug fährt zuerst',
          english: 'The larger vehicle goes first',
        ),
        DrivingOption(
          german: 'Wer hupt, hat Vorrang',
          english: 'Whoever sounds the horn has priority',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Ohne andere Regelung gilt an gleichrangigen Kreuzungen grundsätzlich rechts vor links.',
      explanationEnglish:
          'Without another rule, traffic from the right generally has priority at equal intersections.',
    ),
    DrivingQuestion(
      id: 'drive-right-02',
      category: DrivingQuestionCategory.rightOfWay,
      points: 3,
      questionGerman: 'Was verlangt das Zeichen „Vorfahrt gewähren“?',
      questionEnglish: 'What does the “Give way” sign require?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Dem Verkehr auf der bevorrechtigten Straße Vorrang lassen',
          english: 'Give priority to traffic on the priority road',
        ),
        DrivingOption(
          german: 'Immer vollständig anhalten',
          english: 'Always come to a complete stop',
        ),
        DrivingOption(
          german: 'Nur Fußgängern Vorrang lassen',
          english: 'Give priority only to pedestrians',
        ),
        DrivingOption(
          german: 'Die eigene Geschwindigkeit erhöhen',
          english: 'Increase your own speed',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Anhalten ist nur nötig, wenn es die Verkehrslage verlangt; der bevorrechtigte Verkehr darf nicht behindert werden.',
      explanationEnglish:
          'Stopping is needed when the traffic situation requires it; priority traffic must not be obstructed.',
    ),
    DrivingQuestion(
      id: 'drive-right-03',
      category: DrivingQuestionCategory.rightOfWay,
      points: 4,
      questionGerman: 'Was bedeutet ein Stoppschild?',
      questionEnglish: 'What does a stop sign mean?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Anhalten und erst dann die Vorfahrtlage prüfen',
          english: 'Stop and then check the priority situation',
        ),
        DrivingOption(
          german: 'Nur langsamer werden',
          english: 'Only slow down',
        ),
        DrivingOption(
          german: 'Nur bei Gegenverkehr anhalten',
          english: 'Stop only if there is oncoming traffic',
        ),
        DrivingOption(
          german: 'Vorfahrt gegenüber allen anderen haben',
          english: 'Have priority over everyone else',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Das Zeichen verlangt einen Halt an der Haltlinie oder, wenn nötig, dort, wo die Sicht möglich ist.',
      explanationEnglish:
          'The sign requires a stop at the stop line or, if necessary, where visibility is possible.',
    ),
    DrivingQuestion(
      id: 'drive-right-04',
      category: DrivingQuestionCategory.rightOfWay,
      points: 5,
      questionGerman:
          'Sie wollen links abbiegen. Ein Fahrzeug kommt Ihnen entgegen und fährt geradeaus. Wer wartet?',
      questionEnglish:
          'You want to turn left. An oncoming vehicle is going straight ahead. Who waits?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Sie warten und lassen das entgegenkommende Fahrzeug durch',
          english: 'You wait and let the oncoming vehicle pass',
        ),
        DrivingOption(
          german: 'Das entgegenkommende Fahrzeug wartet immer',
          english: 'The oncoming vehicle always waits',
        ),
        DrivingOption(
          german: 'Beide fahren gleichzeitig',
          english: 'Both drive at the same time',
        ),
        DrivingOption(
          german: 'Wer zuerst blinkt, fährt zuerst',
          english: 'Whoever indicates first goes first',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Beim Linksabbiegen muss der Gegenverkehr, der geradeaus fährt oder rechts abbiegt, durchgelassen werden.',
      explanationEnglish:
          'When turning left, let oncoming traffic going straight or turning right pass first.',
    ),
    DrivingQuestion(
      id: 'drive-right-05',
      category: DrivingQuestionCategory.rightOfWay,
      points: 3,
      questionGerman:
          'Wie verhalten Sie sich beim Einfahren in einen Kreisverkehr?',
      questionEnglish: 'How do you behave when entering a roundabout?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Dem Verkehr im Kreisverkehr Vorrang lassen, wenn dies beschildert ist',
          english: 'Give priority to traffic in the roundabout when signposted',
        ),
        DrivingOption(
          german: 'Immer sofort in die Mitte fahren',
          english: 'Always drive immediately into the centre',
        ),
        DrivingOption(
          german: 'Im Kreisverkehr rückwärts fahren',
          english: 'Drive backwards in the roundabout',
        ),
        DrivingOption(
          german: 'Den Kreisverkehr entgegen der Richtung befahren',
          english: 'Use the roundabout against its direction',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Die Beschilderung an der Einfahrt bestimmt die Vorfahrt. Im Kreisverkehr wird grundsätzlich gegen den Uhrzeigersinn gefahren.',
      explanationEnglish:
          'Signs at the entrance determine priority. Traffic generally travels anticlockwise in the roundabout.',
    ),
    DrivingQuestion(
      id: 'drive-right-06',
      category: DrivingQuestionCategory.rightOfWay,
      points: 4,
      questionGerman:
          'Sie biegen ab und kreuzen einen Fußgängerüberweg. Was müssen Sie tun?',
      questionEnglish:
          'You are turning and cross a pedestrian crossing. What must you do?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Auf querende Fußgänger achten und ihnen das Überqueren ermöglichen',
          english: 'Watch for crossing pedestrians and allow them to cross',
        ),
        DrivingOption(
          german: 'Nur auf Fahrzeuge achten',
          english: 'Watch only for vehicles',
        ),
        DrivingOption(
          german: 'Den Überweg schnell überfahren',
          english: 'Cross the crossing quickly',
        ),
        DrivingOption(
          german: 'Immer auf dem Überweg halten',
          english: 'Always stop on the crossing',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Beim Abbiegen müssen Sie besonders auf zu Fuß Gehende achten und sie nicht gefährden oder behindern.',
      explanationEnglish:
          'When turning, pay special attention to pedestrians and do not endanger or obstruct them.',
    ),
    DrivingQuestion(
      id: 'drive-right-07',
      category: DrivingQuestionCategory.rightOfWay,
      points: 3,
      questionGerman: 'Was tun Sie bei einer roten Ampel?',
      questionEnglish: 'What do you do at a red traffic light?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Vor der Haltlinie anhalten',
          english: 'Stop before the stop line',
        ),
        DrivingOption(
          german: 'Langsam weiterrollen',
          english: 'Roll through slowly',
        ),
        DrivingOption(
          german: 'Nur hupen und weiterfahren',
          english: 'Sound the horn and continue',
        ),
        DrivingOption(
          german: 'Auf der Kreuzung wenden',
          english: 'Turn around on the intersection',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Rot ordnet Halt an; die Haltlinie darf nicht überfahren werden.',
      explanationEnglish: 'Red means stop; do not cross the stop line.',
    ),
    DrivingQuestion(
      id: 'drive-right-08',
      category: DrivingQuestionCategory.rightOfWay,
      points: 4,
      questionGerman:
          'Sie verlassen ein Grundstück und fahren auf die Straße. Wer hat Vorrang?',
      questionEnglish:
          'You leave a property and enter the road. Who has priority?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Der Verkehr auf der Straße',
          english: 'Traffic on the road',
        ),
        DrivingOption(
          german: 'Immer das Fahrzeug, das aus dem Grundstück kommt',
          english: 'Always the vehicle leaving the property',
        ),
        DrivingOption(
          german: 'Das langsamere Fahrzeug',
          english: 'The slower vehicle',
        ),
        DrivingOption(
          german: 'Das Fahrzeug mit dem helleren Licht',
          english: 'The vehicle with the brighter light',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Wer aus einem Grundstück, Parkplatz oder einer ähnlichen Fläche herausfährt, muss den Verkehr auf der Straße durchlassen.',
      explanationEnglish:
          'Anyone leaving a property, car park, or similar area must let road traffic pass.',
    ),
    DrivingQuestion(
      id: 'drive-right-09',
      category: DrivingQuestionCategory.rightOfWay,
      points: 3,
      questionGerman:
          'Ein Linienbus fährt an einer Haltestelle mit eingeschaltetem Warnblinker an. Was ist richtig?',
      questionEnglish:
          'A scheduled bus is leaving a stop with its hazard lights on. What is correct?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Warten und das Einordnen ermöglichen',
          english: 'Wait and allow it to move into traffic',
        ),
        DrivingOption(
          german: 'Schnell rechts vorbeifahren',
          english: 'Pass quickly on the right',
        ),
        DrivingOption(
          german: 'Dicht auffahren, damit der Bus nicht herauskommt',
          english: 'Follow closely so the bus cannot pull out',
        ),
        DrivingOption(
          german: 'Nur auf Fahrräder achten',
          english: 'Watch only for bicycles',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Ein anfahrender Linienbus mit Warnblinker darf nicht behindert werden; fahren Sie vorsichtig vorbei, wenn es nötig und sicher ist.',
      explanationEnglish:
          'Do not obstruct a scheduled bus signalling its departure; pass cautiously only if necessary and safe.',
    ),
    DrivingQuestion(
      id: 'drive-sign-01',
      category: DrivingQuestionCategory.signsAndMarkings,
      points: 2,
      questionGerman:
          'Wovor warnt ein dreieckiges Verkehrszeichen mit rotem Rand grundsätzlich?',
      questionEnglish:
          'What does a triangular traffic sign with a red border generally warn of?',
      options: <DrivingOption>[
        DrivingOption(german: 'Vor einer Gefahr', english: 'A hazard ahead'),
        DrivingOption(
          german: 'Vor einer Pflichtfahrtrichtung',
          english: 'A mandatory direction',
        ),
        DrivingOption(german: 'Vor einem Parkplatz', english: 'A car park'),
        DrivingOption(
          german: 'Vor dem Ende aller Regeln',
          english: 'The end of all rules',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Dreieckige Zeichen mit rotem Rand sind in der Regel Gefahrzeichen. Die konkrete Gefahr steht im Zeichen.',
      explanationEnglish:
          'Triangular signs with a red border are generally warning signs; the specific hazard is shown inside.',
    ),
    DrivingQuestion(
      id: 'drive-sign-02',
      category: DrivingQuestionCategory.signsAndMarkings,
      points: 2,
      questionGerman:
          'Was zeigen runde Verkehrszeichen mit rotem Rand meistens an?',
      questionEnglish:
          'What do round traffic signs with a red border usually indicate?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Verbote oder Beschränkungen',
          english: 'Prohibitions or restrictions',
        ),
        DrivingOption(
          german: 'Erlaubte Parkplätze',
          english: 'Permitted parking places',
        ),
        DrivingOption(
          german: 'Eine Empfehlung zum Ausruhen',
          english: 'A recommendation to rest',
        ),
        DrivingOption(
          german: 'Den Beginn einer Wohnstraße ohne Regeln',
          english: 'The start of a residential road with no rules',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Form und Randfarbe helfen, die Funktion eines Verkehrszeichens schnell zu erkennen.',
      explanationEnglish:
          'Shape and border colour help you recognise a sign’s function quickly.',
    ),
    DrivingQuestion(
      id: 'drive-sign-03',
      category: DrivingQuestionCategory.signsAndMarkings,
      points: 2,
      questionGerman:
          'Was kennzeichnen blaue runde Verkehrszeichen typischerweise?',
      questionEnglish: 'What do blue round traffic signs typically indicate?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Gebote, zum Beispiel eine vorgeschriebene Fahrtrichtung',
          english: 'Requirements, such as a prescribed direction',
        ),
        DrivingOption(
          german: 'Eine allgemeine Gefahrenstelle',
          english: 'A general hazard',
        ),
        DrivingOption(
          german: 'Ein absolutes Halteverbot in jedem Fall',
          english: 'An absolute no-stopping rule in every case',
        ),
        DrivingOption(
          german: 'Eine Autobahnausfahrt',
          english: 'A motorway exit',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Blaue runde Zeichen enthalten häufig verbindliche Gebote, die befolgt werden müssen.',
      explanationEnglish:
          'Blue round signs often contain mandatory requirements that must be followed.',
    ),
    DrivingQuestion(
      id: 'drive-sign-04',
      category: DrivingQuestionCategory.signsAndMarkings,
      points: 3,
      questionGerman: 'Was bedeutet eine durchgezogene Fahrstreifenbegrenzung?',
      questionEnglish: 'What does a solid lane boundary mean?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Sie darf grundsätzlich nicht überfahren werden',
          english: 'It must generally not be crossed',
        ),
        DrivingOption(
          german: 'Sie markiert immer einen Parkplatz',
          english: 'It always marks a parking space',
        ),
        DrivingOption(
          german: 'Sie gilt nur für Fahrräder',
          english: 'It applies only to bicycles',
        ),
        DrivingOption(
          german: 'Sie erlaubt jederzeit das Wenden',
          english: 'It always permits turning around',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Eine durchgezogene Linie trennt Verkehrsbereiche. Ausnahmen gelten nur, wenn die konkrete Verkehrslage und Regelung sie zulassen.',
      explanationEnglish:
          'A solid line separates traffic areas. Exceptions depend on the specific traffic situation and rule.',
    ),
    DrivingQuestion(
      id: 'drive-sign-05',
      category: DrivingQuestionCategory.signsAndMarkings,
      points: 3,
      questionGerman:
          'Was ist der Unterschied zwischen eingeschränktem und absolutem Halteverbot?',
      questionEnglish:
          'What is the difference between limited and absolute no-stopping?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Beim eingeschränkten Halteverbot kann kurzes Halten erlaubt sein; beim absoluten nicht',
          english:
              'Brief stopping may be allowed in limited no-stopping; not in absolute no-stopping',
        ),
        DrivingOption(
          german: 'Beide Zeichen bedeuten immer genau dasselbe',
          english: 'Both signs always mean exactly the same',
        ),
        DrivingOption(
          german: 'Absolutes Halteverbot gilt nur nachts',
          english: 'Absolute no-stopping applies only at night',
        ),
        DrivingOption(
          german: 'Eingeschränktes Halteverbot gilt nur für Busse',
          english: 'Limited no-stopping applies only to buses',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Die Zeichen unterscheiden, ob ein kurzes Halten zum Ein- oder Aussteigen beziehungsweise Be- oder Entladen zulässig sein kann.',
      explanationEnglish:
          'The signs distinguish whether brief stopping for passengers or loading may be allowed.',
    ),
    DrivingQuestion(
      id: 'drive-sign-06',
      category: DrivingQuestionCategory.signsAndMarkings,
      points: 3,
      questionGerman:
          'Was müssen Sie an einem Fußgängerüberweg besonders beachten?',
      questionEnglish:
          'What must you pay particular attention to at a pedestrian crossing?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Fußgängern das Überqueren ermöglichen und nötigenfalls warten',
          english: 'Allow pedestrians to cross and wait if necessary',
        ),
        DrivingOption(
          german: 'Auf dem Überweg überholen',
          english: 'Overtake on the crossing',
        ),
        DrivingOption(
          german: 'Den Überweg blockieren',
          english: 'Block the crossing',
        ),
        DrivingOption(
          german: 'Nur auf den Fahrbahnrand schauen',
          english: 'Look only at the edge of the road',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Der Überweg schützt querende Fußgänger. Fahren Sie nur weiter, wenn niemand gefährdet oder behindert wird.',
      explanationEnglish:
          'The crossing protects pedestrians crossing the road. Continue only when nobody is endangered or obstructed.',
    ),
    DrivingQuestion(
      id: 'drive-sign-07',
      category: DrivingQuestionCategory.signsAndMarkings,
      points: 3,
      questionGerman: 'Was ist in einer Fahrradstraße besonders zu erwarten?',
      questionEnglish:
          'What should you particularly expect in a bicycle street?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Radverkehr prägt die Straße; zugelassener anderer Verkehr muss besonders rücksichtsvoll sein',
          english:
              'Bicycle traffic shapes the street; permitted other traffic must be especially considerate',
        ),
        DrivingOption(
          german: 'Radfahrende dürfen dort nie fahren',
          english: 'Cyclists may never ride there',
        ),
        DrivingOption(
          german: 'Es gilt automatisch die Autobahnregel',
          english: 'Motorway rules apply automatically',
        ),
        DrivingOption(
          german: 'Parken ist dort immer ohne Einschränkung erlaubt',
          english: 'Parking is always unrestricted there',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Die Beschilderung kann anderen Verkehr zulassen, aber die besondere Rücksicht auf den Radverkehr bleibt entscheidend.',
      explanationEnglish:
          'Signs may allow other traffic, but special consideration for bicycle traffic remains essential.',
    ),
    DrivingQuestion(
      id: 'drive-sign-08',
      category: DrivingQuestionCategory.signsAndMarkings,
      points: 3,
      questionGerman: 'Was zeigt ein Umweltzonenzeichen an?',
      questionEnglish: 'What does an environmental-zone sign indicate?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Die Zufahrt ist nur nach den dort angegebenen Emissionsregeln erlaubt',
          english:
              'Entry is allowed only under the emissions rules shown there',
        ),
        DrivingOption(
          german: 'Alle Fahrzeuge dürfen ohne Einschränkung einfahren',
          english: 'All vehicles may enter without restriction',
        ),
        DrivingOption(
          german: 'Nur Motorräder dürfen einfahren',
          english: 'Only motorcycles may enter',
        ),
        DrivingOption(
          german: 'Die Straße ist für Fußgänger gesperrt',
          english: 'The road is closed to pedestrians',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Prüfen Sie die Plaketten- oder Ausnahmeregeln, bevor Sie in die Zone einfahren.',
      explanationEnglish:
          'Check the required sticker or exemption rules before entering the zone.',
    ),
    DrivingQuestion(
      id: 'drive-sign-09',
      category: DrivingQuestionCategory.signsAndMarkings,
      points: 3,
      questionGerman:
          'Welche Verkehrsfläche wird durch das Autobahnzeichen angekündigt?',
      questionEnglish: 'Which type of road is announced by the motorway sign?',
      options: <DrivingOption>[
        DrivingOption(german: 'Eine Autobahn', english: 'A motorway'),
        DrivingOption(german: 'Eine Sackgasse', english: 'A dead end'),
        DrivingOption(
          german: 'Eine reine Fußgängerzone',
          english: 'A pedestrian-only zone',
        ),
        DrivingOption(
          german: 'Einen Bahnübergang',
          english: 'A level crossing',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Auf der Autobahn gelten besondere Regeln, zum Beispiel für die Benutzung durch bestimmte Verkehrsteilnehmer.',
      explanationEnglish:
          'Motorways have special rules, including rules about which road users may use them.',
    ),
    DrivingQuestion(
      id: 'drive-motorway-01',
      category: DrivingQuestionCategory.motorway,
      points: 5,
      questionGerman:
          'Wie bilden Sie auf einer mehrspurigen Autobahn eine Rettungsgasse?',
      questionEnglish:
          'How do you form an emergency corridor on a multi-lane motorway?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Zwischen dem äußerst linken und dem rechts daneben liegenden Fahrstreifen',
          english:
              'Between the far-left lane and the lane immediately to its right',
        ),
        DrivingOption(
          german: 'Auf dem Standstreifen allein',
          english: 'On the hard shoulder alone',
        ),
        DrivingOption(
          german: 'In der Mitte des rechten Fahrstreifens',
          english: 'In the middle of the right lane',
        ),
        DrivingOption(
          german: 'Erst wenn das Einsatzfahrzeug sichtbar ist',
          english: 'Only once the emergency vehicle is visible',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Die Gasse wird bei stockendem Verkehr frühzeitig gebildet, damit Rettungskräfte nicht warten müssen.',
      explanationEnglish:
          'Form the corridor early in queuing traffic so emergency services do not have to wait.',
    ),
    DrivingQuestion(
      id: 'drive-motorway-02',
      category: DrivingQuestionCategory.motorway,
      points: 4,
      questionGerman:
          'Dürfen Sie den Standstreifen auf der Autobahn zum normalen Überholen benutzen?',
      questionEnglish:
          'May you use the hard shoulder for ordinary overtaking on a motorway?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Nein, der Standstreifen ist nicht zum normalen Überholen da',
          english: 'No, the hard shoulder is not for ordinary overtaking',
        ),
        DrivingOption(
          german: 'Ja, wenn der Verkehr langsam ist',
          english: 'Yes, if traffic is slow',
        ),
        DrivingOption(
          german: 'Ja, bei jedem eingeschalteten Blinker',
          english: 'Yes, whenever you indicate',
        ),
        DrivingOption(german: 'Nur nachts ja', english: 'Yes only at night'),
      ],
      correctIndex: 0,
      explanationGerman:
          'Der Standstreifen dient grundsätzlich Notfällen und besonderen Anordnungen, nicht dem normalen Weiterfahren.',
      explanationEnglish:
          'The hard shoulder is generally for emergencies and specific instructions, not ordinary travel.',
    ),
    DrivingQuestion(
      id: 'drive-motorway-03',
      category: DrivingQuestionCategory.motorway,
      points: 4,
      questionGerman:
          'Was bedeutet das Reißverschlussverfahren bei einer Fahrstreifenverengung?',
      questionEnglish:
          'What does the zip/zipper merge mean when a lane narrows?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Fahrzeuge ordnen sich abwechselnd unmittelbar vor der Verengung ein',
          english:
              'Vehicles merge alternately immediately before the narrowing',
        ),
        DrivingOption(
          german: 'Der endende Fahrstreifen bleibt vollständig leer',
          english: 'The ending lane must remain completely empty',
        ),
        DrivingOption(
          german: 'Alle wechseln schon einen Kilometer vorher',
          english: 'Everyone changes one kilometre earlier',
        ),
        DrivingOption(
          german: 'Nur schwere Fahrzeuge dürfen einfädeln',
          english: 'Only heavy vehicles may merge',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Die vorhandene Fahrbahnbreite wird besser genutzt, wenn beide Fahrstreifen bis zur Verengung verwendet werden.',
      explanationEnglish:
          'Road space is used more effectively when both lanes are used until the narrowing.',
    ),
    DrivingQuestion(
      id: 'drive-motorway-04',
      category: DrivingQuestionCategory.motorway,
      points: 3,
      questionGerman:
          'Ihr Fahrzeug bleibt auf der Autobahn liegen. Was tun Sie zuerst?',
      questionEnglish:
          'Your vehicle breaks down on a motorway. What do you do first?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Warnblinker einschalten und das Fahrzeug möglichst sicher abstellen',
          english: 'Switch on hazard lights and stop as safely as possible',
        ),
        DrivingOption(
          german: 'Auf der Fahrbahn stehen bleiben und telefonieren',
          english: 'Stay in the lane and make a phone call',
        ),
        DrivingOption(
          german: 'Sofort rückwärts zur letzten Ausfahrt fahren',
          english: 'Reverse immediately to the last exit',
        ),
        DrivingOption(
          german: 'Das Fahrzeug ohne Warnung verlassen',
          english: 'Leave the vehicle without warning',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Sichern Sie die Gefahrenstelle und bringen Sie sich anschließend hinter der Leitplanke in Sicherheit, wenn möglich.',
      explanationEnglish:
          'Secure the hazard and then move to safety behind the barrier if possible.',
    ),
    DrivingQuestion(
      id: 'drive-motorway-05',
      category: DrivingQuestionCategory.motorway,
      points: 5,
      questionGerman:
          'Was ist auf der Autobahn bei einer verpassten Ausfahrt erlaubt?',
      questionEnglish: 'What is allowed on a motorway if you miss an exit?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Bis zur nächsten Ausfahrt weiterfahren',
          english: 'Continue to the next exit',
        ),
        DrivingOption(
          german: 'Auf dem Standstreifen zurückfahren',
          english: 'Reverse on the hard shoulder',
        ),
        DrivingOption(
          german: 'Wenden und entgegen der Richtung fahren',
          english: 'Turn around and drive against the direction',
        ),
        DrivingOption(
          german: 'Auf der Fahrbahn anhalten und warten',
          english: 'Stop in the lane and wait',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Rückwärtsfahren, Wenden und Halten auf der Fahrbahn gefährden den Verkehr erheblich.',
      explanationEnglish:
          'Reversing, turning around, and stopping in the lane are highly dangerous.',
    ),
    DrivingQuestion(
      id: 'drive-motorway-06',
      category: DrivingQuestionCategory.motorway,
      points: 3,
      questionGerman: 'Was gilt für das Einfahren auf die Autobahn?',
      questionEnglish: 'What applies when entering a motorway?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Der Verkehr auf der durchgehenden Fahrbahn hat Vorrang',
          english: 'Traffic on the continuous carriageway has priority',
        ),
        DrivingOption(
          german: 'Der Einfahrende hat immer Vorrang',
          english: 'The entering vehicle always has priority',
        ),
        DrivingOption(
          german: 'Alle Fahrzeuge müssen anhalten',
          english: 'All vehicles must stop',
        ),
        DrivingOption(
          german: 'Der Standstreifen ist der Beschleunigungsstreifen',
          english: 'The hard shoulder is the acceleration lane',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Nutzen Sie den Beschleunigungsstreifen, passen Sie die Geschwindigkeit an und fädeln Sie sich ohne Vorrangforderung ein.',
      explanationEnglish:
          'Use the acceleration lane, match speed, and merge without claiming priority.',
    ),
    DrivingQuestion(
      id: 'drive-motorway-07',
      category: DrivingQuestionCategory.motorway,
      points: 4,
      questionGerman:
          'Welche Verkehrsteilnehmer dürfen die Autobahn grundsätzlich nicht benutzen?',
      questionEnglish: 'Which road users generally may not use a motorway?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Fußgänger und Fahrräder',
          english: 'Pedestrians and bicycles',
        ),
        DrivingOption(german: 'Personenkraftwagen', english: 'Passenger cars'),
        DrivingOption(german: 'Kraftomnibusse', english: 'Buses'),
        DrivingOption(german: 'Motorräder', english: 'Motorcycles'),
      ],
      correctIndex: 0,
      explanationGerman:
          'Die Autobahn ist für den schnellen Kraftfahrzeugverkehr bestimmt; nicht zugelassene Verkehrsteilnehmer dürfen sie nicht betreten.',
      explanationEnglish:
          'Motorways are for motor traffic; road users not permitted there must not enter.',
    ),
    DrivingQuestion(
      id: 'drive-motorway-08',
      category: DrivingQuestionCategory.motorway,
      points: 4,
      questionGerman:
          'Warum muss eine Rettungsgasse auch nach dem Durchfahren eines Einsatzfahrzeugs offen bleiben?',
      questionEnglish:
          'Why must an emergency corridor remain open after one emergency vehicle passes?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Weitere Einsatzfahrzeuge können folgen',
          english: 'More emergency vehicles may follow',
        ),
        DrivingOption(
          german: 'Damit schneller überholt werden kann',
          english: 'So that overtaking is faster',
        ),
        DrivingOption(
          german: 'Damit der Standstreifen frei bleibt',
          english: 'So that the hard shoulder stays free',
        ),
        DrivingOption(
          german: 'Weil dort geparkt werden darf',
          english: 'Because parking is allowed there',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Rettungskräfte kommen häufig in mehreren Fahrzeugen oder aus mehreren Richtungen.',
      explanationEnglish:
          'Emergency services often arrive in several vehicles or from several directions.',
    ),
    DrivingQuestion(
      id: 'drive-motorway-09',
      category: DrivingQuestionCategory.motorway,
      points: 2,
      questionGerman: 'Was sollten Sie vor einer langen Autobahnfahrt prüfen?',
      questionEnglish: 'What should you check before a long motorway journey?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Reifen, Beleuchtung, Flüssigkeiten und Ladungssicherung',
          english: 'Tyres, lights, fluids, and load security',
        ),
        DrivingOption(
          german: 'Nur die Farbe des Fahrzeugs',
          english: 'Only the vehicle colour',
        ),
        DrivingOption(
          german: 'Nur die Lautstärke der Musik',
          english: 'Only the music volume',
        ),
        DrivingOption(
          german: 'Ob die Hupe besonders laut ist',
          english: 'Whether the horn is especially loud',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Eine einfache Sicherheitskontrolle kann technische Ausfälle und verlorene Ladung verhindern.',
      explanationEnglish:
          'A simple safety check can prevent technical failures and lost loads.',
    ),
    DrivingQuestion(
      id: 'drive-vulnerable-01',
      category: DrivingQuestionCategory.vulnerableRoadUsers,
      points: 4,
      questionGerman:
          'Warum ist das Öffnen einer Autotür neben einem Radfahrstreifen gefährlich?',
      questionEnglish:
          'Why is opening a car door beside a cycle lane dangerous?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Radfahrende können in die Tür fahren',
          english: 'Cyclists may ride into the door',
        ),
        DrivingOption(
          german: 'Die Tür macht den Radweg breiter',
          english: 'The door makes the cycle lane wider',
        ),
        DrivingOption(
          german: 'Radfahrende müssen immer absteigen',
          english: 'Cyclists must always dismount',
        ),
        DrivingOption(
          german: 'Es besteht nur bei Regen eine Gefahr',
          english: 'There is a danger only in rain',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Prüfen Sie den rückwärtigen Verkehr und öffnen Sie die Tür vorsichtig, möglichst mit der entfernten Hand.',
      explanationEnglish:
          'Check traffic behind and open carefully, preferably using the far hand.',
    ),
    DrivingQuestion(
      id: 'drive-vulnerable-02',
      category: DrivingQuestionCategory.vulnerableRoadUsers,
      points: 5,
      questionGerman: 'Sie überholen ein Fahrrad. Was ist entscheidend?',
      questionEnglish: 'You overtake a bicycle. What is decisive?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Ausreichender seitlicher Abstand und eine sichere Verkehrslage',
          english: 'Sufficient lateral distance and a safe traffic situation',
        ),
        DrivingOption(
          german: 'So nah wie möglich vorbeifahren',
          english: 'Pass as close as possible',
        ),
        DrivingOption(
          german: 'Nur kurz hupen',
          english: 'Sound the horn briefly',
        ),
        DrivingOption(
          german: 'Immer auf dem Radweg überholen',
          english: 'Always overtake on the cycle lane',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Wenn der nötige Abstand nicht möglich ist, warten Sie. Der Zeitgewinn rechtfertigt keine Gefährdung.',
      explanationEnglish:
          'If the necessary distance is not possible, wait. Saving time never justifies endangering someone.',
    ),
    DrivingQuestion(
      id: 'drive-vulnerable-03',
      category: DrivingQuestionCategory.vulnerableRoadUsers,
      points: 4,
      questionGerman:
          'Menschen steigen an einer Haltestelle aus einem Bus. Was müssen Sie erwarten?',
      questionEnglish:
          'People are getting off a bus at a stop. What must you expect?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Dass Personen plötzlich die Fahrbahn betreten können',
          english: 'That people may suddenly enter the road',
        ),
        DrivingOption(
          german: 'Dass alle Personen auf dem Gehweg bleiben',
          english: 'That everyone will stay on the pavement',
        ),
        DrivingOption(
          german: 'Dass der Bus sofort rückwärts fährt',
          english: 'That the bus will immediately reverse',
        ),
        DrivingOption(
          german: 'Dass Sie ohne Blickkontakt beschleunigen können',
          english: 'That you can accelerate without eye contact',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Halten Sie die Umgebung der Haltestelle im Blick und fahren Sie langsam sowie bremsbereit.',
      explanationEnglish:
          'Watch the area around the stop and drive slowly, ready to brake.',
    ),
    DrivingQuestion(
      id: 'drive-vulnerable-04',
      category: DrivingQuestionCategory.vulnerableRoadUsers,
      points: 5,
      questionGerman:
          'Kinder spielen in der Nähe der Fahrbahn. Womit müssen Sie rechnen?',
      questionEnglish:
          'Children are playing near the road. What must you expect?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Dass ein Kind unvermittelt auf die Fahrbahn läuft',
          english: 'That a child may suddenly run into the road',
        ),
        DrivingOption(
          german: 'Dass ein Ball niemals auf die Straße rollt',
          english: 'That a ball will never roll onto the road',
        ),
        DrivingOption(
          german: 'Dass Kinder den Verkehr sicher einschätzen',
          english: 'That children judge traffic safely',
        ),
        DrivingOption(
          german: 'Dass Hupen jede Gefahr beseitigt',
          english: 'That sounding the horn removes every danger',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Fahren Sie langsam und bremsbereit; Kinder reagieren oft spontan und sind schwer vorhersehbar.',
      explanationEnglish:
          'Drive slowly and be ready to brake; children often act spontaneously and are hard to predict.',
    ),
    DrivingQuestion(
      id: 'drive-vulnerable-05',
      category: DrivingQuestionCategory.vulnerableRoadUsers,
      points: 3,
      questionGerman:
          'Eine ältere Person überquert die Straße langsam. Was ist richtig?',
      questionEnglish:
          'An older person is crossing the road slowly. What is correct?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Warten und nicht drängeln oder hupen',
          english: 'Wait and do not pressure or sound the horn',
        ),
        DrivingOption(
          german: 'Dicht vor der Person vorbeifahren',
          english: 'Drive closely in front of the person',
        ),
        DrivingOption(
          german: 'Die Person durch Lichthupe beschleunigen',
          english: 'Make the person hurry with the headlight flasher',
        ),
        DrivingOption(
          german: 'Nur bei Grün warten',
          english: 'Wait only when the light is green',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Rücksicht bedeutet, Schwächere nicht unter Zeitdruck zu setzen.',
      explanationEnglish:
          'Consideration means not putting vulnerable people under time pressure.',
    ),
    DrivingQuestion(
      id: 'drive-vulnerable-06',
      category: DrivingQuestionCategory.vulnerableRoadUsers,
      points: 4,
      questionGerman:
          'Warum müssen Sie mit Radfahrenden im toten Winkel rechnen?',
      questionEnglish: 'Why must you expect cyclists in the blind spot?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Spiegel decken nicht jeden Bereich neben dem Fahrzeug ab',
          english: 'Mirrors do not cover every area beside the vehicle',
        ),
        DrivingOption(
          german: 'Radfahrende dürfen dort nicht fahren',
          english: 'Cyclists may not ride there',
        ),
        DrivingOption(
          german: 'Der tote Winkel ist nur bei Nacht vorhanden',
          english: 'The blind spot exists only at night',
        ),
        DrivingOption(
          german: 'Ein Blinker ersetzt jede Kontrolle',
          english: 'An indicator replaces every check',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Vor dem Abbiegen oder Spurwechsel müssen Sie Spiegel und Schulterblick kombinieren.',
      explanationEnglish:
          'Before turning or changing lanes, combine mirror checks with a shoulder check.',
    ),
    DrivingQuestion(
      id: 'drive-vulnerable-07',
      category: DrivingQuestionCategory.vulnerableRoadUsers,
      points: 3,
      questionGerman:
          'Eine Straßenbahn nähert sich einer Haltestelle ohne eigenen Bahnsteig. Was ist zu beachten?',
      questionEnglish:
          'A tram approaches a stop without its own platform. What must you consider?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Mit aussteigenden und einsteigenden Personen rechnen und vorsichtig warten',
          english: 'Expect boarding and alighting people and wait carefully',
        ),
        DrivingOption(
          german: 'Die Straßenbahn immer rechts überholen',
          english: 'Always overtake the tram on the right',
        ),
        DrivingOption(
          german: 'Dicht an der Bahn vorbeifahren',
          english: 'Drive close to the tram',
        ),
        DrivingOption(
          german: 'Nur auf die Schienen schauen',
          english: 'Watch only the rails',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Fahrgäste müssen möglicherweise die Fahrbahn überqueren. Halten Sie ausreichend Abstand und Sicht.',
      explanationEnglish:
          'Passengers may need to cross the road. Keep enough distance and visibility.',
    ),
    DrivingQuestion(
      id: 'drive-vulnerable-08',
      category: DrivingQuestionCategory.vulnerableRoadUsers,
      points: 4,
      questionGerman:
          'Was ist bei Menschen mit Rollstuhl oder Gehhilfe besonders wichtig?',
      questionEnglish:
          'What is especially important around people using a wheelchair or walking aid?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Mehr Zeit einplanen und ausreichend Abstand halten',
          english: 'Allow more time and keep enough distance',
        ),
        DrivingOption(
          german: 'So nah wie möglich heranfahren',
          english: 'Drive as close as possible',
        ),
        DrivingOption(
          german: 'Mit der Hupe zur Seite drängen',
          english: 'Push them aside with the horn',
        ),
        DrivingOption(
          german: 'Nur auf die Fahrbahnmitte sehen',
          english: 'Look only at the centre of the road',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Mobilitätshilfen können unebenem Untergrund ausweichen müssen und brauchen häufig mehr Zeit.',
      explanationEnglish:
          'People using mobility aids may need to avoid uneven surfaces and often need more time.',
    ),
    DrivingQuestion(
      id: 'drive-vulnerable-09',
      category: DrivingQuestionCategory.vulnerableRoadUsers,
      points: 3,
      questionGerman:
          'Warum sollten Sie Blickkontakt mit zu Fuß Gehenden nicht als sichere Freigabe missverstehen?',
      questionEnglish:
          'Why should you not mistake eye contact with pedestrians for a guaranteed permission to go?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Blickkontakt kann die tatsächliche Verkehrslage und Vorfahrt nicht ersetzen',
          english:
              'Eye contact cannot replace the actual traffic situation and priority rules',
        ),
        DrivingOption(
          german: 'Blickkontakt bedeutet immer Vorrang für das Fahrzeug',
          english: 'Eye contact always gives the vehicle priority',
        ),
        DrivingOption(
          german: 'Fußgänger sehen Fahrzeuge immer vollständig',
          english: 'Pedestrians always see vehicles completely',
        ),
        DrivingOption(
          german: 'Blickkontakt gilt nur auf Autobahnen',
          english: 'Eye contact applies only on motorways',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Verlassen Sie sich auf sichere Sicht, Signale und Verkehrsregeln, nicht auf eine vermutete Absicht.',
      explanationEnglish:
          'Rely on clear visibility, signals, and traffic rules, not on a guessed intention.',
    ),
    DrivingQuestion(
      id: 'drive-tech-01',
      category: DrivingQuestionCategory.vehicleTechnology,
      points: 3,
      questionGerman: 'Warum ist der richtige Reifendruck wichtig?',
      questionEnglish: 'Why is the correct tyre pressure important?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Für Haftung, Bremsverhalten und gleichmäßigen Verschleiß',
          english: 'For grip, braking behaviour, and even wear',
        ),
        DrivingOption(
          german: 'Nur für die Farbe der Reifen',
          english: 'Only for the colour of the tyres',
        ),
        DrivingOption(
          german: 'Damit der Motor lauter wird',
          english: 'So that the engine becomes louder',
        ),
        DrivingOption(
          german: 'Damit die Scheibenwischer besser arbeiten',
          english: 'So that the wipers work better',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Prüfen Sie den vom Fahrzeughersteller vorgesehenen Druck, besonders vor längeren Fahrten oder hoher Beladung.',
      explanationEnglish:
          'Check the pressure specified by the manufacturer, especially before long journeys or heavy loading.',
    ),
    DrivingQuestion(
      id: 'drive-tech-02',
      category: DrivingQuestionCategory.vehicleTechnology,
      points: 3,
      questionGerman: 'Was unterstützt ABS beim Bremsen?',
      questionEnglish: 'What does ABS help with during braking?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Es hilft, ein Blockieren der Räder zu verhindern und die Lenkbarkeit zu erhalten',
          english: 'It helps prevent wheel lock and maintain steering ability',
        ),
        DrivingOption(
          german: 'Es verkürzt jeden Bremsweg unabhängig von der Fahrbahn',
          english: 'It shortens every braking distance regardless of the road',
        ),
        DrivingOption(
          german: 'Es ersetzt den Sicherheitsabstand',
          english: 'It replaces the safety distance',
        ),
        DrivingOption(
          german: 'Es schaltet den Motor aus',
          english: 'It switches off the engine',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'ABS unterstützt die Lenkbarkeit bei einer starken Bremsung; es hebt die Grenzen der Physik nicht auf.',
      explanationEnglish:
          'ABS supports steering during hard braking; it does not remove the limits of physics.',
    ),
    DrivingQuestion(
      id: 'drive-tech-03',
      category: DrivingQuestionCategory.vehicleTechnology,
      points: 3,
      questionGerman: 'Wozu dient ein elektronisches Stabilitätsprogramm?',
      questionEnglish: 'What is an electronic stability programme for?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Es kann das Ausbrechen des Fahrzeugs durch gezieltes Abbremsen unterstützen',
          english: 'It can help counter a skid by braking individual wheels',
        ),
        DrivingOption(
          german: 'Es erlaubt schnelleres Fahren in jeder Kurve',
          english: 'It permits faster driving in every bend',
        ),
        DrivingOption(
          german: 'Es ersetzt Winterreifen',
          english: 'It replaces winter tyres',
        ),
        DrivingOption(
          german: 'Es macht den Fahrer aufmerksamkeitsfrei',
          english: 'It means the driver no longer needs attention',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Assistenzsysteme helfen innerhalb ihrer Grenzen; angepasstes Fahren bleibt notwendig.',
      explanationEnglish:
          'Assistance systems help within their limits; adapted driving is still necessary.',
    ),
    DrivingQuestion(
      id: 'drive-tech-04',
      category: DrivingQuestionCategory.vehicleTechnology,
      points: 4,
      questionGerman:
          'Eine rote Ölwarnleuchte leuchtet während der Fahrt. Was ist richtig?',
      questionEnglish:
          'A red oil warning light comes on while driving. What is correct?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Sicher anhalten und die Ursache prüfen lassen',
          english: 'Stop safely and have the cause checked',
        ),
        DrivingOption(
          german: 'Schneller fahren, bis die Leuchte ausgeht',
          english: 'Drive faster until it goes out',
        ),
        DrivingOption(
          german: 'Die Leuchte mit Klebeband abdecken',
          english: 'Cover the light with tape',
        ),
        DrivingOption(
          german: 'Nur die Innenbeleuchtung ausschalten',
          english: 'Switch off only the interior light',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Eine rote Warnleuchte kann auf einen schweren Motorschaden hinweisen. Fahren Sie nicht einfach weiter.',
      explanationEnglish:
          'A red warning light may indicate serious engine damage. Do not simply continue driving.',
    ),
    DrivingQuestion(
      id: 'drive-tech-05',
      category: DrivingQuestionCategory.vehicleTechnology,
      points: 2,
      questionGerman:
          'Was müssen Sie mit der Fahrzeugbeleuchtung sicherstellen?',
      questionEnglish: 'What must you ensure regarding vehicle lighting?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Sie müssen sauber, funktionsfähig und der Sicht angepasst sein',
          english: 'It must be clean, working, and suited to visibility',
        ),
        DrivingOption(
          german: 'Sie muss immer auf Fernlicht stehen',
          english: 'It must always be on high beam',
        ),
        DrivingOption(
          german: 'Nur die Innenbeleuchtung muss funktionieren',
          english: 'Only the interior light must work',
        ),
        DrivingOption(
          german: 'Licht ist bei Nebel unwichtig',
          english: 'Lights are unimportant in fog',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Gute Beleuchtung hilft Ihnen zu sehen und gesehen zu werden, ohne andere zu blenden.',
      explanationEnglish:
          'Good lighting helps you see and be seen without dazzling others.',
    ),
    DrivingQuestion(
      id: 'drive-tech-06',
      category: DrivingQuestionCategory.vehicleTechnology,
      points: 4,
      questionGerman: 'Wie sichern Sie Gepäck im Fahrzeug?',
      questionEnglish: 'How do you secure luggage in a vehicle?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'So, dass es auch bei einer starken Bremsung nicht verrutscht oder Personen trifft',
          english: 'So it cannot slide or hit people during hard braking',
        ),
        DrivingOption(
          german: 'Lose auf der Hutablage',
          english: 'Loose on the parcel shelf',
        ),
        DrivingOption(
          german: 'Nur mit einem dünnen Tuch',
          english: 'Only with a thin cloth',
        ),
        DrivingOption(
          german: 'Auf dem Fahrersitz',
          english: 'On the driver’s seat',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Ungesicherte Gegenstände werden bei einer Bremsung zu gefährlichen Geschossen.',
      explanationEnglish:
          'Unsecured objects can become dangerous projectiles during braking.',
    ),
    DrivingQuestion(
      id: 'drive-tech-07',
      category: DrivingQuestionCategory.vehicleTechnology,
      points: 5,
      questionGerman:
          'Warum müssen Kinder mit einem geeigneten Rückhaltesystem gesichert werden?',
      questionEnglish:
          'Why must children be secured with a suitable restraint system?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Damit das System zur Größe und zum Gewicht des Kindes passt',
          english: 'So the system matches the child’s size and weight',
        ),
        DrivingOption(
          german: 'Damit Kinder während der Fahrt besser aus dem Fenster sehen',
          english: 'So children can see better out of the window',
        ),
        DrivingOption(
          german: 'Damit der Airbag immer ausgeschaltet bleibt',
          english: 'So the airbag always stays switched off',
        ),
        DrivingOption(
          german: 'Damit der Kindersitz lose bleiben kann',
          english: 'So the child seat can remain loose',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Ein passendes, korrekt eingebautes Rückhaltesystem reduziert Verletzungsrisiken.',
      explanationEnglish:
          'A suitable, correctly installed restraint reduces injury risks.',
    ),
    DrivingQuestion(
      id: 'drive-tech-08',
      category: DrivingQuestionCategory.vehicleTechnology,
      points: 3,
      questionGerman: 'Was gehört vor einem Spurwechsel zur Kontrolle?',
      questionEnglish: 'What belongs in the check before changing lanes?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Spiegel, Blinker und Schulterblick',
          english: 'Mirrors, indicator, and shoulder check',
        ),
        DrivingOption(
          german: 'Nur die Farbe des Fahrzeugs nebenan',
          english: 'Only the colour of the vehicle beside you',
        ),
        DrivingOption(
          german: 'Nur ein kurzer Blick nach vorn',
          english: 'Only a brief look ahead',
        ),
        DrivingOption(
          german: 'Die Hupe statt des Blinkers',
          english: 'The horn instead of the indicator',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Der Schulterblick deckt Bereiche ab, die Spiegel nicht vollständig zeigen.',
      explanationEnglish:
          'The shoulder check covers areas that mirrors do not show completely.',
    ),
    DrivingQuestion(
      id: 'drive-tech-09',
      category: DrivingQuestionCategory.vehicleTechnology,
      points: 2,
      questionGerman: 'Was sollten Sie vor der Fahrt mit dem Gurt tun?',
      questionEnglish: 'What should you do with the seat belt before driving?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Anlegen und auf korrekten Sitz prüfen',
          english: 'Fasten it and check that it fits correctly',
        ),
        DrivingOption(
          german: 'Nur bei hoher Geschwindigkeit anlegen',
          english: 'Fasten it only at high speed',
        ),
        DrivingOption(
          german: 'Hinter dem Rücken entlangführen',
          english: 'Run it behind your back',
        ),
        DrivingOption(
          german: 'Lose über die Armlehne legen',
          english: 'Lay it loosely over the armrest',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Der Gurt muss eng am Körper anliegen und darf nicht verdreht sein.',
      explanationEnglish:
          'The belt must lie close to the body and must not be twisted.',
    ),
    DrivingQuestion(
      id: 'drive-fitness-01',
      category: DrivingQuestionCategory.fitnessAndEnvironment,
      points: 5,
      questionGerman:
          'Warum ist die Nutzung eines Handys während der Fahrt gefährlich?',
      questionEnglish: 'Why is using a phone while driving dangerous?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Die Aufmerksamkeit und Reaktionsfähigkeit werden beeinträchtigt',
          english: 'Attention and reaction ability are impaired',
        ),
        DrivingOption(
          german: 'Das Fahrzeug wird automatisch langsamer',
          english: 'The vehicle automatically becomes slower',
        ),
        DrivingOption(
          german: 'Die Reifen verlieren sofort Luft',
          english: 'The tyres immediately lose air',
        ),
        DrivingOption(
          german: 'Das Handy verbessert die Sicht',
          english: 'The phone improves visibility',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Schon kurze Ablenkung kann dazu führen, dass Gefahren oder Signale zu spät erkannt werden.',
      explanationEnglish:
          'Even brief distraction can make hazards or signals go unnoticed until too late.',
    ),
    DrivingQuestion(
      id: 'drive-fitness-02',
      category: DrivingQuestionCategory.fitnessAndEnvironment,
      points: 5,
      questionGerman: 'Welche Wirkung kann Alkohol beim Fahren haben?',
      questionEnglish: 'What effect can alcohol have on driving?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Schlechtere Wahrnehmung, langsamere Reaktion und mehr Risikobereitschaft',
          english: 'Worse perception, slower reactions, and more risk-taking',
        ),
        DrivingOption(
          german: 'Bessere Einschätzung von Entfernungen',
          english: 'Better judgement of distances',
        ),
        DrivingOption(
          german: 'Sichereres Fahren bei Müdigkeit',
          english: 'Safer driving when tired',
        ),
        DrivingOption(
          german: 'Kürzerer Bremsweg',
          english: 'A shorter braking distance',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Alkohol beeinträchtigt mehrere für das Fahren wichtige Fähigkeiten. Fahren Sie nicht nach Alkoholkonsum.',
      explanationEnglish:
          'Alcohol affects several abilities needed for driving. Do not drive after drinking.',
    ),
    DrivingQuestion(
      id: 'drive-fitness-03',
      category: DrivingQuestionCategory.fitnessAndEnvironment,
      points: 5,
      questionGerman: 'Was gilt nach der Einnahme eines neuen Medikaments?',
      questionEnglish: 'What applies after taking a new medication?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Beipackzettel und ärztlichen Rat auf mögliche Fahrbeeinträchtigung prüfen',
          english:
              'Check the leaflet and medical advice for effects on driving',
        ),
        DrivingOption(
          german: 'Immer sofort fahren, um die Wirkung zu testen',
          english: 'Always drive immediately to test the effect',
        ),
        DrivingOption(
          german: 'Medikamente beeinflussen das Fahren nie',
          english: 'Medication never affects driving',
        ),
        DrivingOption(
          german: 'Nur die Farbe der Tablette beachten',
          english: 'Pay attention only to the pill colour',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Medikamente können Müdigkeit, Schwindel oder verlangsamte Reaktionen verursachen.',
      explanationEnglish:
          'Medication can cause tiredness, dizziness, or slower reactions.',
    ),
    DrivingQuestion(
      id: 'drive-fitness-04',
      category: DrivingQuestionCategory.fitnessAndEnvironment,
      points: 4,
      questionGerman:
          'Wie können Sie Kraftstoff sparen und die Umwelt schonen?',
      questionEnglish: 'How can you save fuel and protect the environment?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Vorausschauend und mit passender Geschwindigkeit fahren',
          english: 'Drive predictively and at a suitable speed',
        ),
        DrivingOption(
          german: 'Den Motor im Stand lange laufen lassen',
          english: 'Leave the engine running for a long time while stationary',
        ),
        DrivingOption(
          german: 'Jede Strecke mit maximaler Beschleunigung fahren',
          english: 'Accelerate maximally on every trip',
        ),
        DrivingOption(
          german: 'Reifendruck ignorieren',
          english: 'Ignore tyre pressure',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Vorausschauendes Fahren vermeidet unnötiges Bremsen und Beschleunigen; im Stand ist der Motor meist nicht nötig.',
      explanationEnglish:
          'Predictive driving avoids unnecessary braking and acceleration; an idling engine is usually unnecessary.',
    ),
    DrivingQuestion(
      id: 'drive-fitness-05',
      category: DrivingQuestionCategory.fitnessAndEnvironment,
      points: 4,
      questionGerman:
          'Sie haben nach einer kurzen Nacht starke Müdigkeit. Was ist richtig?',
      questionEnglish:
          'You are very tired after a short night. What is correct?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Nicht fahren oder zuerst ausreichend erholen',
          english: 'Do not drive or recover sufficiently first',
        ),
        DrivingOption(
          german: 'Kaffee macht jede Fahrt sicher',
          english: 'Coffee makes every journey safe',
        ),
        DrivingOption(
          german: 'Mit geöffnetem Fenster ist Müdigkeit egal',
          english: 'An open window makes fatigue irrelevant',
        ),
        DrivingOption(
          german: 'Schneller fahren, damit die Fahrt kürzer ist',
          english: 'Drive faster so the journey is shorter',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Müdigkeit kann zu Sekundenschlaf führen. Hilfsmittel ersetzen keine Erholung.',
      explanationEnglish:
          'Fatigue can cause microsleep. Aids are no substitute for rest.',
    ),
    DrivingQuestion(
      id: 'drive-fitness-06',
      category: DrivingQuestionCategory.fitnessAndEnvironment,
      points: 3,
      questionGerman:
          'Warum ist unnötiges Laufenlassen des Motors im Stand problematisch?',
      questionEnglish:
          'Why is leaving the engine running unnecessarily while stationary a problem?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Es verursacht Emissionen, Lärm und unnötigen Kraftstoffverbrauch',
          english: 'It causes emissions, noise, and unnecessary fuel use',
        ),
        DrivingOption(
          german: 'Es lädt die Reifen auf',
          english: 'It charges the tyres',
        ),
        DrivingOption(
          german: 'Es macht die Bremsen automatisch stärker',
          english: 'It automatically strengthens the brakes',
        ),
        DrivingOption(
          german: 'Es verbessert immer die Luftqualität',
          english: 'It always improves air quality',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Schalten Sie den Motor aus, wenn er nicht für die Weiterfahrt benötigt wird und die Situation es erlaubt.',
      explanationEnglish:
          'Switch the engine off when it is not needed for moving and the situation permits it.',
    ),
    DrivingQuestion(
      id: 'drive-fitness-07',
      category: DrivingQuestionCategory.fitnessAndEnvironment,
      points: 3,
      questionGerman: 'Was hilft gegen Ablenkung durch Mitfahrende?',
      questionEnglish: 'What helps prevent distraction by passengers?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Blick und Aufmerksamkeit auf die Verkehrslage richten',
          english: 'Keep your eyes and attention on traffic',
        ),
        DrivingOption(
          german: 'Während des Fahrens nach hinten drehen',
          english: 'Turn around while driving',
        ),
        DrivingOption(
          german: 'Mit beiden Händen gestikulieren',
          english: 'Gesture with both hands',
        ),
        DrivingOption(
          german: 'Die Straße nur über den Beifahrer beobachten',
          english: 'Watch the road only through the passenger',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Gespräche dürfen die sichere Fahrzeugführung nicht beeinträchtigen.',
      explanationEnglish:
          'Conversations must not interfere with safe vehicle control.',
    ),
    DrivingQuestion(
      id: 'drive-fitness-08',
      category: DrivingQuestionCategory.fitnessAndEnvironment,
      points: 2,
      questionGerman: 'Wann sollten Sie eine Pause einplanen?',
      questionEnglish: 'When should you plan a break?',
      options: <DrivingOption>[
        DrivingOption(
          german: 'Bevor die Konzentration deutlich nachlässt',
          english: 'Before concentration noticeably decreases',
        ),
        DrivingOption(
          german: 'Erst wenn Sie die Augen nicht mehr offen halten können',
          english: 'Only when you can no longer keep your eyes open',
        ),
        DrivingOption(
          german: 'Nur nach dem Tanken',
          english: 'Only after refuelling',
        ),
        DrivingOption(
          german: 'Nie auf kurzen Autobahnfahrten',
          english: 'Never on short motorway journeys',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Frühe Pausen verhindern, dass Müdigkeit zur akuten Gefahr wird.',
      explanationEnglish:
          'Early breaks prevent fatigue from becoming an immediate danger.',
    ),
    DrivingQuestion(
      id: 'drive-fitness-09',
      category: DrivingQuestionCategory.fitnessAndEnvironment,
      points: 3,
      questionGerman:
          'Warum sind regelmäßige Fahrzeugkontrollen Teil der Verkehrssicherheit?',
      questionEnglish: 'Why are regular vehicle checks part of road safety?',
      options: <DrivingOption>[
        DrivingOption(
          german:
              'Mängel an Bremsen, Reifen oder Beleuchtung können früh erkannt werden',
          english: 'Defects in brakes, tyres, or lights can be found early',
        ),
        DrivingOption(
          german: 'Sie machen Verkehrszeichen überflüssig',
          english: 'They make traffic signs unnecessary',
        ),
        DrivingOption(
          german: 'Sie ersetzen den Sicherheitsabstand',
          english: 'They replace the safety distance',
        ),
        DrivingOption(
          german: 'Sie erlauben immer höhere Geschwindigkeit',
          english: 'They always permit higher speed',
        ),
      ],
      correctIndex: 0,
      explanationGerman:
          'Technische Zuverlässigkeit und eine verantwortungsvolle Fahrweise gehören zusammen.',
      explanationEnglish:
          'Technical reliability and responsible driving belong together.',
    ),
  ];

  static List<DrivingQuestion> questionsFor(
    DrivingQuestionCategory? category,
  ) => category == null
      ? questions
      : questions
            .where((DrivingQuestion question) => question.category == category)
            .toList(growable: false);

  static DrivingMock buildMock({required int seed}) {
    final Random random = Random(seed);
    final List<DrivingQuestion> selected = List<DrivingQuestion>.of(questions)
      ..shuffle(random);
    final List<DrivingQuestion> mock =
        <DrivingQuestion>[...selected.take(mockQuestionCount)]..replaceRange(
          0,
          mockQuestionCount,
          selected
              .take(mockQuestionCount)
              .map((DrivingQuestion question) => question.shuffled(random)),
        );
    return DrivingMock(
      seed: seed,
      questions: List<DrivingQuestion>.unmodifiable(mock),
    );
  }
}

class DrivingMock {
  const DrivingMock({required this.seed, required this.questions});

  final int seed;
  final List<DrivingQuestion> questions;

  DrivingTestResult score(Map<String, int> answers) {
    int correct = 0;
    int errorPoints = 0;
    int fivePointErrors = 0;
    for (final DrivingQuestion question in questions) {
      if (answers[question.id] == question.correctIndex) {
        correct += 1;
      } else {
        errorPoints += question.points;
        if (question.points == 5) fivePointErrors += 1;
      }
    }
    return DrivingTestResult(
      correct: correct,
      total: questions.length,
      errorPoints: errorPoints,
      fivePointErrors: fivePointErrors,
    );
  }
}

class DrivingTestResult {
  const DrivingTestResult({
    required this.correct,
    required this.total,
    required this.errorPoints,
    required this.fivePointErrors,
  });

  final int correct;
  final int total;
  final int errorPoints;
  final int fivePointErrors;

  int get percent => total == 0 ? 0 : ((correct / total) * 100).round();

  /// The app's practice mock uses the official error-point rule as a clear
  /// training signal; its authored questions are not the official catalogue.
  bool get passed =>
      errorPoints <= DrivingTheoryCatalog.officialMaximumErrorPoints &&
      fivePointErrors < 2;
}
