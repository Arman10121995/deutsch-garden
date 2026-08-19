import 'models.dart';

/// Pedagogical planning metadata for DeutschGarden.
///
/// CEFR itself does not prescribe fixed vocabulary counts. The lexical targets
/// below are internal breadth targets used to help learners understand the
/// scale of each stage. They are deliberately kept separate from the number of
/// bundled flashcards in the app.
class LevelCoverage {
  const LevelCoverage({
    required this.level,
    required this.lexicalBreadthTarget,
    required this.focus,
    required this.grammarFocus,
    required this.examFocus,
  });

  final CefrLevel level;
  final int lexicalBreadthTarget;
  final String focus;
  final List<String> grammarFocus;
  final String examFocus;
}

const List<LevelCoverage> levelCoverage = <LevelCoverage>[
  LevelCoverage(
    level: CefrLevel.a1,
    lexicalBreadthTarget: 650,
    focus: 'Survival German: identity, home, food, time, shopping, travel and simple routines.',
    grammarFocus: <String>[
      'Present tense and verb-second word order',
      'W-questions and yes/no questions',
      'Nominative and accusative',
      'Definite, indefinite and negative articles',
      'Personal and possessive pronouns',
      'Modal verbs and separable verbs',
      'Imperative, basic prepositions and time expressions',
      'Basic Perfekt recognition and coordination',
    ],
    examFocus: 'Short notices, simple messages, everyday listening and predictable personal interaction.',
  ),
  LevelCoverage(
    level: CefrLevel.a2,
    lexicalBreadthTarget: 1400,
    focus: 'Routine independence: work, appointments, services, travel, health and everyday explanations.',
    grammarFocus: <String>[
      'Perfekt with haben/sein and common participles',
      'Dative and two-way prepositions',
      'Subordinate clauses with weil, dass, wenn and obwohl',
      'Comparative and superlative',
      'Reflexive verbs and pronouns',
      'Adjective endings after common determiners',
      'Präteritum of sein, haben and modal verbs',
      'Relative clauses and infinitive constructions at introductory level',
    ],
    examFocus: 'Routine correspondence, announcements, conversations, short opinions and everyday problem solving.',
  ),
  LevelCoverage(
    level: CefrLevel.b1,
    lexicalBreadthTarget: 2600,
    focus: 'Independent communication: narration, reasons, opinions, plans and familiar abstract topics.',
    grammarFocus: <String>[
      'Full core case system and adjective declension',
      'Relative clauses across cases',
      'Passive voice in present and past',
      'Konjunktiv II for wishes, advice and hypotheticals',
      'Infinitive clauses with zu, um…zu, ohne…zu and statt…zu',
      'Temporal, causal, concessive and conditional connectors',
      'Präteritum in written narration',
      'Word order with multiple clause elements and pronouns',
    ],
    examFocus: 'Longer texts, structured emails, opinions with reasons, narratives and sustained interaction.',
  ),
  LevelCoverage(
    level: CefrLevel.b2,
    lexicalBreadthTarget: 4200,
    focus: 'Upper-intermediate precision: argumentation, professional communication and complex factual material.',
    grammarFocus: <String>[
      'Passive alternatives and advanced passive forms',
      'Nominalisation and verb-noun style shifts',
      'Participle constructions and extended attributes',
      'Advanced relative and subordinate clauses',
      'Konjunktiv I foundations and reported speech',
      'Complex connector patterns and information structure',
      'N-declension, genitive constructions and prepositional government',
      'Register-sensitive modal particles and verb-preposition combinations',
    ],
    examFocus: 'Dense reading, extended argument writing, lecture/interview listening and spontaneous discussion.',
  ),
  LevelCoverage(
    level: CefrLevel.c1,
    lexicalBreadthTarget: 6800,
    focus: 'Advanced flexibility: academic/professional discourse, inference, register control and precise argument.',
    grammarFocus: <String>[
      'Reported speech with Konjunktiv I/II',
      'Complex nominal style and functional verb structures',
      'Participial attributes and compressed syntax',
      'Fine distinctions in tense, modality and passive',
      'Advanced prepositional and genitive constructions',
      'Discourse connectors, thematic progression and emphasis',
      'Register-sensitive word order and information packaging',
      'Complex comparison, concession, condition and consequence',
    ],
    examFocus: 'Abstract texts, lectures, synthesis, formal writing and nuanced discussion across unfamiliar topics.',
  ),
  LevelCoverage(
    level: CefrLevel.c2,
    lexicalBreadthTarget: 10000,
    focus: 'Mastery: idiomatic range, rhetorical nuance, dense texts, subtle stance and near-effortless reformulation.',
    grammarFocus: <String>[
      'Stylistic variation across verbal and nominal structures',
      'Marked word order, ellipsis and rhetorical emphasis',
      'Fine modal and evidential distinctions',
      'Highly compressed participial and nominal constructions',
      'Idiomatic connector and particle use',
      'Register shifts, indirectness and pragmatic mitigation',
      'Complex quotation, reported thought and perspective',
      'Editing for cohesion, precision, rhythm and ambiguity control',
    ],
    examFocus: 'Very dense authentic-style material, synthesis, rhetorical analysis, precise writing and sophisticated oral argument.',
  ),
];

LevelCoverage coverageFor(CefrLevel level) =>
    levelCoverage.firstWhere((coverage) => coverage.level == level);
