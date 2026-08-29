/// The course spine.
///
/// The app has always held a great deal of content and almost no *order*. A
/// learner opening it saw five skill hubs, six levels and several hundred
/// lessons, and had to invent a study plan before they could study. That is
/// the single thing most likely to decide whether anyone is still here in
/// month three, and it is not a content problem — nothing here is new
/// material. It is a sequencing problem.
///
/// So this file states the sequence. Seventy-two units, twelve per level:
/// four teaching units then a review unit, repeating. Each teaching unit
/// carries a can-do outcome written in the first person, an explicit list of
/// grammar lessons in the order they should be met, a share of the level's
/// listening, reading, writing, speaking, story, role-play and radio
/// material, and a vocabulary target. Each review unit folds the previous
/// block back in. Every unit ends in a checkpoint that has to be passed
/// before the next one opens.
///
/// Two decisions worth stating plainly:
///
/// **The order is hand-written, the distribution is not.** Which grammar
/// lesson belongs in which unit is a teaching judgement and appears below as
/// data. Which listening lesson lands in unit three is not a judgement worth
/// making seventy-two times, so supporting material is dealt out round-robin
/// from the registry. That also means adding a lesson to the catalogue lands
/// it in the course automatically, while adding a grammar lesson deliberately
/// does not — it has to be placed.
///
/// **Nothing here is stored.** A unit's state is derived from the activity
/// progress the app already keeps, because every lesson, story chapter,
/// role-play and radio episode already records itself through
/// `recordActivity`. The spine is a view over that, not a second copy of it.
/// A learner who did half the A1 lessons before this existed opens the course
/// and finds that half of it is already ticked.
library;

import 'cloze_bank.dart';
import 'conversation.dart';
import 'lesson_registry.dart';
import 'models.dart';
import 'radio.dart';
import 'stories.dart';

/// What a unit is for: teaching new material, or folding the previous four
/// units back together.
enum CourseUnitKind { teaching, review }

/// What a step opens. Distinct from [SkillType] because the course also
/// sequences stories, role-plays and radio episodes, which are not skills,
/// and a vocabulary target, which is not a lesson.
enum CourseStepKind {
  grammar,
  listening,
  reading,
  writing,
  speaking,
  story,
  conversation,
  radio,
  vocabulary,
  matching,
  sentenceBuilder,
  dictation,
}

/// One thing to do inside a unit.
class CourseStep {
  const CourseStep({
    required this.kind,
    required this.title,
    required this.route,
    required this.completionIds,
    this.isCore = true,
  });

  final CourseStepKind kind;

  final String title;

  /// The id the UI opens. Usually the same as the single completion id; for a
  /// story it is the story, whose chapters are the completion ids.
  final String route;

  /// Activity ids that must all be completed for this step to count. Empty
  /// for the vocabulary step, which is measured against a word count instead.
  final List<String> completionIds;

  /// Whether this step belongs to the compact path that prepares the unit
  /// checkpoint. Every other item remains attached to the unit as enrichment,
  /// but does not turn a unit into a fifteen-item gate.
  final bool isCore;

  bool get isVocabulary => kind == CourseStepKind.vocabulary;

  CourseStep copyWith({bool? isCore}) => CourseStep(
    kind: kind,
    title: title,
    route: route,
    completionIds: completionIds,
    isCore: isCore ?? this.isCore,
  );
}

/// One unit of the course.
class CourseUnit {
  const CourseUnit({
    required this.id,
    required this.level,
    required this.number,
    required this.kind,
    required this.title,
    required this.canDo,
    required this.steps,
    required this.wordTarget,
    required this.reviewOf,
    required this.checkpoint,
  });

  final String id;

  final CefrLevel level;

  /// Position within the level, 1-based, counting review units. Unit 5 of
  /// every level is therefore always a review.
  final int number;

  final CourseUnitKind kind;

  final String title;

  /// What the learner can do once this unit is passed, in the first person.
  /// Phrased as an outcome rather than as a syllabus item: "I can say what I
  /// did yesterday", not "the Perfekt".
  final String canDo;

  final List<CourseStep> steps;

  /// Cumulative words at this level the learner is expected to have met by
  /// the end of this unit. Cumulative rather than per-unit so that the target
  /// cannot be gamed by doing units out of order, and so a learner arriving
  /// with vocabulary already behind them sees it counted.
  final int wordTarget;

  /// For a review unit, the ids of the units it folds back in. Empty
  /// otherwise.
  final List<String> reviewOf;

  /// The gate. Passing it is what opens the next unit.
  final List<ChoiceQuestion> checkpoint;

  String get checkpointId => '$id-check';

  bool get isReview => kind == CourseUnitKind.review;

  /// Every activity id this unit touches, in step order.
  List<String> get activityIds => <String>[
    for (final CourseStep step in steps) ...step.completionIds,
  ];

  List<CourseStep> get coreSteps =>
      steps.where((CourseStep step) => step.isCore).toList(growable: false);

  List<CourseStep> get enrichmentSteps =>
      steps.where((CourseStep step) => !step.isCore).toList(growable: false);
}

/// Score needed to pass a checkpoint.
///
/// Eighty rather than a bare pass: the checkpoint is the only thing standing
/// between a learner and material they are not ready for, and a gate at 60%
/// is not a gate. Not higher than eighty either, because a learner who has
/// understood the unit but misreads one of ten questions should not be held
/// back by it.
const int courseCheckpointPass = 80;

/// New words per teaching unit.
///
/// Deliberately modest. Four grammar lessons, three or four skill activities
/// and twenty new words is already a week for most people, and the course is
/// not the only way vocabulary is met — spaced review runs across the whole
/// ten thousand cards independently of this. The course sequences; it does
/// not try to be the only door to the content.
const int courseWordsPerUnit = 20;

/// Four varied supporting activities alongside the unit's grammar and
/// vocabulary are enough to practise reception and production without making
/// the core path feel like a catalogue. The rest remain one tap away in the
/// same unit under "Extra practice".
const int courseCoreSupportPerUnit = 4;
const int courseCoreActivitiesMax = 9;

// ---------------------------------------------------------------------------
// The hand-written part: what each unit teaches, and in what order.
// ---------------------------------------------------------------------------

class _UnitSpec {
  const _UnitSpec(this.title, this.canDo, this.grammar);

  final String title;
  final String canDo;

  /// Grammar lesson ids, in teaching order.
  ///
  /// This is the whole point of the file. The catalogue's own ids are not a
  /// teaching order — `gr-a1-01` is verb position, which needs pronouns and
  /// `sein` first, and those live at `gr-a1-x01` and `gr-a1-x02`. Renumbering
  /// the catalogue was the alternative and it is not available: the ids are
  /// written into every saved profile.
  final List<String> grammar;
}

const List<_UnitSpec> _a1 = <_UnitSpec>[
  _UnitSpec(
    'Saying who you are',
    'I can say who I am, where I live and how I am doing, and keep the verb '
        'in second position while I do it.',
    <String>['gr-a1-x01', 'gr-a1-x02', 'gr-a1-x21', 'gr-a1-01'],
  ),
  _UnitSpec(
    'Naming things',
    'I can name everyday objects with the right article, make them plural, '
        'and guess the gender of a word I have never seen from how it ends.',
    <String>['gr-a1-x03', 'gr-a1-x29', 'gr-a1-x19', 'gr-a1-02'],
  ),
  _UnitSpec(
    'Asking and refusing',
    'I can ask for what I need, say what is not the case, and choose between '
        'du and Sie without having to think about it.',
    <String>['gr-a1-x22', 'gr-a1-03', 'gr-a1-x08', 'gr-a1-x17'],
  ),
  _UnitSpec(
    'Objects and ownership',
    'I can say what I have, want and am buying, and say whose it is, without '
        'confusing the subject of the sentence with its object.',
    <String>['gr-a1-x05', 'gr-a1-x23', 'gr-a1-x04', 'gr-a1-x14'],
  ),
  _UnitSpec(
    'Saying what you want to do',
    'I can say what I can, must and would like to do, say what I like doing, '
        'and tell someone else to do something.',
    <String>['gr-a1-04', 'gr-a1-x16', 'gr-a1-x13', 'gr-a1-x07'],
  ),
  _UnitSpec(
    'Getting around',
    'I can say where I am, where I am going and where I have come from, and '
        'use verbs like ankommen and abfahren with the prefix in its place.',
    <String>['gr-a1-x06', 'gr-a1-x15', 'gr-a1-x11', 'gr-a1-x24'],
  ),
  _UnitSpec(
    'Times and quantities',
    'I can give a time, a date and an amount, and order time, manner and '
        'place in one sentence the way German expects.',
    <String>['gr-a1-x27', 'gr-a1-x10', 'gr-a1-x20', 'gr-a1-x30'],
  ),
  _UnitSpec(
    'Joining ideas',
    'I can join two statements with und, aber, oder and denn, describe things '
        'with simple adjectives, and say what there is.',
    <String>['gr-a1-x09', 'gr-a1-x26', 'gr-a1-x18', 'gr-a1-x28'],
  ),
  _UnitSpec(
    'Talking about yesterday',
    'I can tell someone what I did yesterday in the Perfekt, and I know the '
        'places where German uses no article at all.',
    <String>['gr-a1-x12', 'gr-a1-x25'],
  ),
];

const List<_UnitSpec> _a2 = <_UnitSpec>[
  _UnitSpec(
    'Telling what happened',
    'I can tell a short story about the past, choose haben or sein without '
        'guessing, and use war, hatte and konnte.',
    <String>['gr-a2-01', 'gr-a2-x01', 'gr-a2-x02', 'gr-a2-x08'],
  ),
  _UnitSpec(
    'Giving and receiving',
    'I can say who I gave something to, replace both objects with pronouns, '
        'and put those pronouns in the order German wants.',
    <String>['gr-a2-02', 'gr-a2-x03', 'gr-a2-x13', 'gr-a2-x14'],
  ),
  _UnitSpec(
    'Giving reasons',
    'I can explain why I do something, report what someone said with dass, '
        'and start a sentence with the reason instead of the main clause.',
    <String>['gr-a2-03', 'gr-a2-x05', 'gr-a2-x28', 'gr-a2-x17'],
  ),
  _UnitSpec(
    'Comparing',
    'I can compare two things, name the best of several, and put the usual '
        'endings on an adjective standing in front of a noun.',
    <String>['gr-a2-04', 'gr-a2-x07', 'gr-a2-x26', 'gr-a2-x09'],
  ),
  _UnitSpec(
    'Where things are, where they go',
    'I can say where something is and where it is being put, and say how long '
        'something has lasted and how long ago it happened.',
    <String>['gr-a2-x04', 'gr-a2-x18', 'gr-a2-x30', 'gr-a2-x21'],
  ),
  _UnitSpec(
    'Your day, in detail',
    'I can describe my daily routine with reflexive verbs, say what we do to '
        'each other, and put nicht where I actually mean it.',
    <String>['gr-a2-x06', 'gr-a2-x24', 'gr-a2-x29', 'gr-a2-x15'],
  ),
  _UnitSpec(
    'Purpose and intention',
    'I can say what I intend to do and why, ask a question indirectly to be '
        'polite, and tell als from wenn when talking about the past.',
    <String>['gr-a2-x11', 'gr-a2-x20', 'gr-a2-x12', 'gr-a2-x16'],
  ),
  _UnitSpec(
    'Saying which one',
    'I can say which one I mean with a relative clause, and use dieser, '
        'jemand, niemand and meiner in the right case.',
    <String>['gr-a2-x10', 'gr-a2-x19', 'gr-a2-x22', 'gr-a2-x23'],
  ),
  _UnitSpec(
    'Finishing touches',
    'I can use viele, einige and ein paar with the right adjective endings, '
        'and link ideas with sowohl … als auch and entweder … oder.',
    <String>['gr-a2-x25', 'gr-a2-x27'],
  ),
];

const List<_UnitSpec> _b1 = <_UnitSpec>[
  _UnitSpec(
    'Describing precisely',
    'I can put the right ending on any adjective, turn an adjective into a '
        'noun, and describe things with gekocht and kochend.',
    <String>['gr-b1-x01', 'gr-b1-x24', 'gr-b1-x23', 'gr-b1-x19'],
  ),
  _UnitSpec(
    'Which one, and whose',
    'I can pin down exactly which person or thing I mean — including whose — '
        'with a relative clause in any case.',
    <String>['gr-b1-02', 'gr-b1-x03', 'gr-b1-x20', 'gr-b1-x02'],
  ),
  _UnitSpec(
    'Narrating the past',
    'I can narrate a sequence of past events, say what had already happened '
        'before them, and choose Perfekt or Präteritum to suit the register.',
    <String>['gr-b1-01', 'gr-b1-x13', 'gr-b1-x08', 'gr-b1-x07'],
  ),
  _UnitSpec(
    'Space and direction',
    'I can use the preposition a verb demands, refer back to a whole idea '
        'with darauf or worüber, and hang a prepositional phrase on a noun.',
    <String>['gr-b1-03', 'gr-b1-x10', 'gr-b1-x11', 'gr-b1-x25'],
  ),
  _UnitSpec(
    'Politeness and hypothesis',
    'I can make a request sound polite, say what I would do, and say that '
        'something looks as if it were the case.',
    <String>['gr-b1-04', 'gr-b1-x05', 'gr-b1-x29', 'gr-b1-x30'],
  ),
  _UnitSpec(
    'Who does what to whom',
    'I can say what is done without naming who does it, and tell the future, '
        'passive and become senses of werden apart.',
    <String>['gr-b1-x04', 'gr-b1-x26', 'gr-b1-x18', 'gr-b1-x15'],
  ),
  _UnitSpec(
    'Word order under pressure',
    'I can keep the verb in the right place after any connector, and order '
        'pronouns in the middle of a clause without stopping to think.',
    <String>['gr-b1-x12', 'gr-b1-x16', 'gr-b1-x09', 'gr-b1-x17'],
  ),
  _UnitSpec(
    'Saying it in fewer words',
    'I can express purpose, absence and substitution with an infinitive, say '
        'what need not be done, and link two rising quantities.',
    <String>['gr-b1-x06', 'gr-b1-x27', 'gr-b1-x14', 'gr-b1-x28'],
  ),
  _UnitSpec(
    'Building new words',
    'I can read and build German compounds, and see how a prefix or a suffix '
        'turns one word into another.',
    <String>['gr-b1-x21', 'gr-b1-x22'],
  ),
];

const List<_UnitSpec> _b2 = <_UnitSpec>[
  _UnitSpec(
    'The passive, fully',
    'I can use the passive in any tense, add a modal verb to it, and tell an '
        'action being done from a state that has resulted.',
    <String>['gr-b2-01', 'gr-b2-x01', 'gr-b2-x02', 'gr-b2-x18'],
  ),
  _UnitSpec(
    'Saying it without the passive',
    'I can replace a passive with man, sich lassen or an -bar adjective, and '
        'assemble the verb cluster at the end of a clause correctly.',
    <String>['gr-b2-x03', 'gr-b2-x28', 'gr-b2-x27', 'gr-b2-x20'],
  ),
  _UnitSpec(
    'Reporting what others said',
    'I can report speech at a distance in Konjunktiv I, and use soll and will '
        'to mark a claim as someone else’s rather than mine.',
    <String>['gr-b2-x04', 'gr-b2-x21', 'gr-b2-x22', 'gr-b2-x13'],
  ),
  _UnitSpec(
    'Formal noun style',
    'I can write in the noun-heavy style German officialdom uses, decline the '
        'weak masculine nouns, and give a noun the complement it requires.',
    <String>['gr-b2-02', 'gr-b2-x05', 'gr-b2-x10', 'gr-b2-x24'],
  ),
  _UnitSpec(
    'Packing detail into a noun phrase',
    'I can read and write the long phrases that sit in front of a noun in '
        'written German, and keep agreement right when subjects are joined.',
    <String>['gr-b2-x06', 'gr-b2-x07', 'gr-b2-x14', 'gr-b2-x29'],
  ),
  _UnitSpec(
    'Connecting an argument',
    'I can concede a point and then counter it, state means and result, and '
        'mark my own attitude with a sentence adverb.',
    <String>['gr-b2-03', 'gr-b2-x08', 'gr-b2-x19', 'gr-b2-x30'],
  ),
  _UnitSpec(
    'What might have been',
    'I can say what would have happened if, state a condition without wenn, '
        'and negate a whole series of things cleanly.',
    <String>['gr-b2-04', 'gr-b2-x09', 'gr-b2-x17', 'gr-b2-x23'],
  ),
  _UnitSpec(
    'Ordering the sentence',
    'I can decide what belongs at the front of a German sentence, hold a '
        'clause open with es or darauf, and tell an argument from an adjunct.',
    <String>['gr-b2-x12', 'gr-b2-x15', 'gr-b2-x25', 'gr-b2-x26'],
  ),
  _UnitSpec(
    'Sounding German',
    'I can use doch, mal, ja and eben the way a native speaker does, and '
        'build the longer infinitive clauses of careful speech.',
    <String>['gr-b2-x11', 'gr-b2-x16'],
  ),
];

const List<_UnitSpec> _c1 = <_UnitSpec>[
  _UnitSpec(
    'Reporting a source',
    'I can report a source across several sentences without losing the '
        'thread, keeping tense and reference consistent throughout.',
    <String>['gr-c1-01', 'gr-c1-x01', 'gr-c1-x13', 'gr-c1-x11'],
  ),
  _UnitSpec(
    'Nominal style',
    'I can move between nominal and verbal style at will, and keep the '
        'arguments a nominalisation inherits from the verb it came from.',
    <String>['gr-c1-03', 'gr-c1-x02', 'gr-c1-x03', 'gr-c1-x24'],
  ),
  _UnitSpec(
    'Complex noun phrases',
    'I can unpack the longest pre-noun phrases in academic German, and insert '
        'an apposition or a parenthesis without breaking the sentence.',
    <String>['gr-c1-02', 'gr-c1-x04', 'gr-c1-x23', 'gr-c1-x20'],
  ),
  _UnitSpec(
    'Case in formal registers',
    'I can use the genitive where formal German still requires it, and choose '
        'the case after prepositions like trotz, dank and wegen.',
    <String>['gr-c1-x06', 'gr-c1-x21', 'gr-c1-x22', 'gr-c1-x14'],
  ),
  _UnitSpec(
    'Relations between clauses',
    'I can express fine relations between clauses, and tell a relative clause '
        'that narrows a reference from one that merely adds to it.',
    <String>['gr-c1-04', 'gr-c1-x07', 'gr-c1-x15', 'gr-c1-x29'],
  ),
  _UnitSpec(
    'Word order as meaning',
    'I can put given and new information where German expects them, and move '
        'heavy material out past the end of the verb bracket.',
    <String>['gr-c1-x12', 'gr-c1-x16', 'gr-c1-x27', 'gr-c1-x26'],
  ),
  _UnitSpec(
    'Stance and scope',
    'I can signal my stance precisely, control exactly what a negation covers, '
        'and read ist zu tun as the modal passive it is.',
    <String>['gr-c1-x08', 'gr-c1-x09', 'gr-c1-x05', 'gr-c1-x10'],
  ),
  _UnitSpec(
    'Verb clusters and predicates',
    'I can order a three-verb cluster at the end of a clause, and build a '
        'counterfactual that spans two different times at once.',
    <String>['gr-c1-x18', 'gr-c1-x19', 'gr-c1-x28', 'gr-c1-x17'],
  ),
  _UnitSpec(
    'The edges of the syntax',
    'I can use the several different es of German correctly, and recognise a '
        'verb-second clause embedded after a verb of saying or thinking.',
    <String>['gr-c1-x25', 'gr-c1-x30'],
  ),
];

const List<_UnitSpec> _c2 = <_UnitSpec>[
  _UnitSpec(
    'Particles and stance',
    'I can shade a statement with particles the way native speakers do, mark '
        'how I know something, and soften a claim without weakening it.',
    <String>['gr-c2-01', 'gr-c2-x14', 'gr-c2-x03', 'gr-c2-x08'],
  ),
  _UnitSpec(
    'Marked word order',
    'I can move an element to the front for emphasis, and build the focusing '
        'structures that answer which one exactly.',
    <String>['gr-c2-02', 'gr-c2-x01', 'gr-c2-x10', 'gr-c2-x19'],
  ),
  _UnitSpec(
    'Leaving things out',
    'I can omit what German allows to be omitted, in speech and in writing, '
        'without becoming ambiguous.',
    <String>['gr-c2-x02', 'gr-c2-x17', 'gr-c2-x31', 'gr-c2-x32'],
  ),
  _UnitSpec(
    'Register and idiom',
    'I can rewrite the same content across registers, and choose the '
        'preposition an idiom demands rather than the one logic suggests.',
    <String>['gr-c2-03', 'gr-c2-x09', 'gr-c2-x12', 'gr-c2-x30'],
  ),
  _UnitSpec(
    'Dense academic syntax',
    'I can read the densest academic German and unpack it into clear '
        'sentences, and compress my own prose when the register asks for it.',
    <String>['gr-c2-04', 'gr-c2-x06', 'gr-c2-x20', 'gr-c2-x29'],
  ),
  _UnitSpec(
    'Perspective in narrative',
    'I can hold a narrative perspective across a whole passage, including '
        'free indirect speech and the historical present.',
    <String>['gr-c2-x07', 'gr-c2-x13', 'gr-c2-x27', 'gr-c2-x26'],
  ),
  _UnitSpec(
    'Counterfactual and conditional',
    'I can express regret and hypothesis about the past, and use verb-first '
        'clauses for conditions, concessions and wishes.',
    <String>['gr-c2-x04', 'gr-c2-x15', 'gr-c2-x24', 'gr-c2-x22'],
  ),
  _UnitSpec(
    'Scope and ambiguity',
    'I can see where a sentence could be read two ways and rewrite it so it '
        'cannot, including the scope of negation and quantifiers.',
    <String>['gr-c2-x11', 'gr-c2-x25', 'gr-c2-x05', 'gr-c2-x18'],
  ),
  _UnitSpec(
    'The last corners',
    'I can use the constructions that live at the edges of the grammar: '
        'verbless adjuncts, stand-alone subordinate clauses, and spoken weil '
        'with the verb in second position.',
    <String>['gr-c2-x16', 'gr-c2-x21', 'gr-c2-x23', 'gr-c2-x28', 'gr-c2-x33'],
  ),
];

const Map<CefrLevel, List<_UnitSpec>> _spine = <CefrLevel, List<_UnitSpec>>{
  CefrLevel.a1: _a1,
  CefrLevel.a2: _a2,
  CefrLevel.b1: _b1,
  CefrLevel.b2: _b2,
  CefrLevel.c1: _c1,
  CefrLevel.c2: _c2,
};

/// Teaching units between review units.
const int _blockSize = 4;

// ---------------------------------------------------------------------------
// Building the course.
// ---------------------------------------------------------------------------

List<CourseUnit>? _cache;

/// Every unit of the course, level by level, in the order they are to be done.
List<CourseUnit> get courseUnits => _cache ??= _build();

List<CourseUnit> unitsFor(CefrLevel level) =>
    courseUnits.where((CourseUnit unit) => unit.level == level).toList();

CourseUnit? unitById(String id) {
  for (final CourseUnit unit in courseUnits) {
    if (unit.id == id) return unit;
  }
  return null;
}

/// The unit a given activity belongs to, or null if the catalogue holds it but
/// the course does not sequence it.
CourseUnit? unitForActivity(String activityId) {
  for (final CourseUnit unit in courseUnits) {
    for (final CourseStep step in unit.steps) {
      if (step.completionIds.contains(activityId)) return unit;
    }
  }
  return null;
}

List<CourseUnit> _build() {
  final List<CourseUnit> units = <CourseUnit>[];
  for (final CefrLevel level in CefrLevel.values) {
    units.addAll(_buildLevel(level));
  }
  return List<CourseUnit>.unmodifiable(units);
}

List<CourseUnit> _buildLevel(CefrLevel level) {
  final List<_UnitSpec> specs = _spine[level]!;
  final Map<String, LessonRef> grammarById = <String, LessonRef>{
    for (final LessonRef ref in allLessons)
      if (ref.skill == SkillType.grammar) ref.id: ref,
  };

  // Supporting material, dealt round-robin. See the file header: this is the
  // part not worth deciding by hand.
  //
  // Dealt like cards — item p to unit p % specs.length — rather than sliced
  // into contiguous blocks. Slicing looked tidier and was wrong: the material
  // is interleaved by kind and the kinds run out at different points, so the
  // tail of the list is all radio episodes, and the last unit of every level
  // got nothing but radio. Dealing spreads that tail across all of them.
  final List<CourseStep> support = _supportFor(level);
  final List<List<CourseStep>> dealt = List<List<CourseStep>>.generate(
    specs.length,
    (_) => <CourseStep>[],
  );
  for (int p = 0; p < support.length; p++) {
    dealt[p % specs.length].add(support[p]);
  }

  final List<CourseUnit> result = <CourseUnit>[];
  final List<String> teachingIds = <String>[];
  final List<String> levelIds = <String>[];
  int slot = 0;
  int teaching = 0;

  for (int i = 0; i < specs.length; i++) {
    // A review unit occupies every fifth slot.
    if (teaching == _blockSize) {
      slot += 1;
      result.add(_reviewUnit(level, slot, result, teachingIds));
      teaching = 0;
      teachingIds.clear();
    }

    final _UnitSpec spec = specs[i];
    slot += 1;
    teaching += 1;

    final String id = _unitId(level, slot);
    teachingIds.add(id);
    levelIds.add(id);

    final List<CourseStep> grammarSteps = <CourseStep>[
      for (final String gid in spec.grammar)
        _lessonStep(grammarById[gid], gid, CourseStepKind.grammar),
    ];

    final int wordTarget = courseWordsPerUnit * (i + 1);
    final CourseStep vocabularyStep = CourseStep(
      kind: CourseStepKind.vocabulary,
      title: 'Vocabulary — $wordTarget ${level.label} words',
      route: 'vocab-${level.label.toLowerCase()}',
      completionIds: const <String>[],
    );
    final CourseStep practiceStep = _practiceStep(level, id, slot);
    final int supportTarget =
        (courseCoreActivitiesMax - grammarSteps.length - 2).clamp(
          2,
          courseCoreSupportPerUnit,
        );
    final List<CourseStep> supportSteps = _markCoreSupport(
      dealt[i],
      target: supportTarget,
    );
    final List<CourseStep> steps = _sequenceUnitSteps(
      grammarSteps,
      supportSteps,
      vocabularyStep,
      practiceStep,
    );

    result.add(
      CourseUnit(
        id: id,
        level: level,
        number: slot,
        kind: CourseUnitKind.teaching,
        title: spec.title,
        canDo: spec.canDo,
        steps: List<CourseStep>.unmodifiable(steps),
        wordTarget: wordTarget,
        reviewOf: const <String>[],
        checkpoint: _teachingCheckpoint(level, slot, steps),
      ),
    );
  }

  // Every level ends on a review, and that one covers the whole level rather
  // than the trailing block. Otherwise the last gate before moving up to A2
  // would test one unit, which is not a level test by any reading.
  if (levelIds.isNotEmpty) {
    slot += 1;
    result.add(_reviewUnit(level, slot, result, levelIds, closing: true));
  }
  return result;
}

String _unitId(CefrLevel level, int slot) =>
    '${level.label.toLowerCase()}-u${slot.toString().padLeft(2, '0')}';

CourseStep _lessonStep(LessonRef? ref, String id, CourseStepKind kind) {
  // A missing id is a mistake in the table above, not a runtime condition.
  // `tool/validate_content.py` fails the build on it; this is the fallback for
  // the seconds between someone editing the table and running the gate.
  final String title = ref?.title ?? id;
  return CourseStep(
    kind: kind,
    title: title,
    route: id,
    completionIds: <String>[id],
  );
}

bool _isReceptive(CourseStepKind kind) =>
    kind == CourseStepKind.listening ||
    kind == CourseStepKind.reading ||
    kind == CourseStepKind.story ||
    kind == CourseStepKind.radio;

bool _isProductive(CourseStepKind kind) =>
    kind == CourseStepKind.writing ||
    kind == CourseStepKind.speaking ||
    kind == CourseStepKind.conversation;

/// Pick a balanced core without dropping any material. The remaining support
/// is still attached to the same unit as enrichment.
List<CourseStep> _markCoreSupport(
  List<CourseStep> support, {
  int target = courseCoreSupportPerUnit,
}) {
  if (support.isEmpty) return const <CourseStep>[];
  final int limit = support.length < target ? support.length : target;
  final Set<int> chosen = <int>{};

  void chooseFirst(bool Function(CourseStepKind kind) predicate) {
    if (chosen.length >= limit) return;
    for (int i = 0; i < support.length; i++) {
      if (!chosen.contains(i) && predicate(support[i].kind)) {
        chosen.add(i);
        return;
      }
    }
  }

  // Every core should make the learner understand something and produce
  // something whenever that unit has both kinds available.
  chooseFirst(_isReceptive);
  chooseFirst(_isProductive);

  final Set<CourseStepKind> kinds = <CourseStepKind>{
    for (final int i in chosen) support[i].kind,
  };
  for (int i = 0; i < support.length && chosen.length < limit; i++) {
    if (chosen.contains(i) || kinds.contains(support[i].kind)) continue;
    chosen.add(i);
    kinds.add(support[i].kind);
  }
  for (int i = 0; i < support.length && chosen.length < limit; i++) {
    chosen.add(i);
  }

  return <CourseStep>[
    for (int i = 0; i < support.length; i++)
      support[i].copyWith(isCore: chosen.contains(i)),
  ];
}

/// Put vocabulary first, then alternate grammar with varied application. The
/// previous order placed every grammar lesson first and all real-world use
/// afterwards, so an automatic "next" button still produced four rules in a
/// row before the learner heard or said anything.
List<CourseStep> _sequenceUnitSteps(
  List<CourseStep> grammar,
  List<CourseStep> support,
  CourseStep vocabulary,
  CourseStep practice,
) {
  final List<CourseStep> coreSupport = support
      .where((CourseStep step) => step.isCore)
      .toList(growable: false);
  final List<CourseStep> enrichment = support
      .where((CourseStep step) => !step.isCore)
      .toList(growable: false);
  final List<CourseStep> out = <CourseStep>[vocabulary];
  final int rounds = grammar.length > coreSupport.length
      ? grammar.length
      : coreSupport.length;
  for (int i = 0; i < rounds; i++) {
    if (i < grammar.length) out.add(grammar[i]);
    if (i == 0) out.add(practice);
    if (i < coreSupport.length) out.add(coreSupport[i]);
  }
  if (rounds == 0) out.add(practice);
  out.addAll(enrichment);
  return List<CourseStep>.unmodifiable(out);
}

/// One short retrieval exercise per unit. The stable unit-specific completion
/// id lets the same game engine recur throughout the course without a single
/// A1 matching result marking every later unit complete.
CourseStep _practiceStep(CefrLevel level, String unitId, int slot) {
  final CourseStepKind kind;
  final String title;
  final String suffix;
  switch ((slot - 1) % 3) {
    case 0:
      kind = CourseStepKind.matching;
      title = 'Match words and meanings';
      suffix = 'matching';
      break;
    case 1:
      kind = CourseStepKind.sentenceBuilder;
      title = 'Build complete sentences';
      suffix = 'sentence-builder';
      break;
    default:
      kind = CourseStepKind.dictation;
      title = 'Listen and write';
      suffix = 'dictation';
      break;
  }
  final String activityId = '$unitId-$suffix';
  return CourseStep(
    kind: kind,
    title: '${level.label} · $title',
    route: activityId,
    completionIds: <String>[activityId],
  );
}

/// The level's non-grammar material, interleaved by kind.
///
/// Interleaved rather than concatenated so a unit gets a listening lesson and
/// a story rather than three listening lessons: the flattened list is read in
/// rounds, one item per kind per round.
List<CourseStep> _supportFor(CefrLevel level) {
  final List<List<CourseStep>> queues = <List<CourseStep>>[
    <CourseStep>[
      for (final LessonRef ref in allLessons)
        if (ref.level == level && ref.skill == SkillType.listening)
          _lessonStep(ref, ref.id, CourseStepKind.listening),
    ],
    <CourseStep>[
      for (final LessonRef ref in allLessons)
        if (ref.level == level && ref.skill == SkillType.reading)
          _lessonStep(ref, ref.id, CourseStepKind.reading),
    ],
    <CourseStep>[
      for (final Story story in storiesFor(level))
        CourseStep(
          kind: CourseStepKind.story,
          title: story.title,
          route: story.id,
          completionIds: <String>[
            for (final StoryChapter chapter in story.chapters) chapter.id,
          ],
        ),
    ],
    <CourseStep>[
      for (final ConversationScenario scenario in conversationsFor(level))
        CourseStep(
          kind: CourseStepKind.conversation,
          title: scenario.title,
          route: scenario.id,
          completionIds: <String>[scenario.id],
        ),
    ],
    <CourseStep>[
      for (final LessonRef ref in allLessons)
        if (ref.level == level && ref.skill == SkillType.writing)
          _lessonStep(ref, ref.id, CourseStepKind.writing),
    ],
    <CourseStep>[
      for (final RadioEpisode episode in radioFor(level))
        CourseStep(
          kind: CourseStepKind.radio,
          title: episode.title,
          route: episode.id,
          completionIds: <String>[episode.id],
        ),
    ],
    <CourseStep>[
      for (final LessonRef ref in allLessons)
        if (ref.level == level && ref.skill == SkillType.speaking)
          _lessonStep(ref, ref.id, CourseStepKind.speaking),
    ],
  ];

  final int longest = queues.fold(
    0,
    (int m, List<CourseStep> q) => q.length > m ? q.length : m,
  );
  final List<CourseStep> flat = <CourseStep>[];
  for (int round = 0; round < longest; round++) {
    for (final List<CourseStep> queue in queues) {
      if (round < queue.length) flat.add(queue[round]);
    }
  }
  return flat;
}

CourseUnit _reviewUnit(
  CefrLevel level,
  int slot,
  List<CourseUnit> soFar,
  List<String> blockIds, {
  bool closing = false,
}) {
  final List<CourseUnit> block = <CourseUnit>[
    for (final CourseUnit unit in soFar)
      if (blockIds.contains(unit.id)) unit,
  ];
  final String range = block.length == 1
      ? 'unit ${block.first.number}'
      : 'units ${block.first.number}–${block.last.number}';
  final String id = _unitId(level, slot);

  return CourseUnit(
    id: id,
    level: level,
    number: slot,
    kind: CourseUnitKind.review,
    title: closing ? 'Level test: ${level.label}' : 'Review: $range',
    canDo: closing
        ? 'I can use everything at ${level.label} together, without being '
              'told which rule is being tested.'
        : 'I can use everything from $range together, without being told '
              'which rule is being tested.',
    steps: <CourseStep>[
      _practiceStep(level, id, slot),
      for (final CourseUnit unit in block)
        for (final CourseStep step in unit.steps)
          if (step.kind == CourseStepKind.grammar) step,
    ],
    wordTarget: block.isEmpty ? 0 : block.last.wordTarget,
    reviewOf: List<String>.unmodifiable(blockIds),
    checkpoint: _reviewCheckpoint(level, slot, block),
  );
}

// ---------------------------------------------------------------------------
// Checkpoints.
// ---------------------------------------------------------------------------

const int _teachingQuestions = 10;
const int _reviewQuestions = 14;

/// A checkpoint drawn from the unit's own material.
///
/// One question from each lesson in the unit that has questions, then gap-fill
/// items from the level to make up the number. Drawing from the unit rather
/// than writing fresh questions is deliberate: a checkpoint that tests
/// something the unit did not teach is a trap, and the drills already written
/// for each lesson are the best available statement of what it taught.
List<ChoiceQuestion> _teachingCheckpoint(
  CefrLevel level,
  int slot,
  List<CourseStep> steps,
) {
  final List<ChoiceQuestion> out = <ChoiceQuestion>[];
  for (final CourseStep step in steps) {
    if (!step.isCore) continue;
    if (out.length >= _teachingQuestions) break;
    final List<ChoiceQuestion> pool = _questionsForRoute(step.route);
    if (pool.isNotEmpty) out.add(pool.first);
  }
  _padWithCloze(out, level, slot, _teachingQuestions);
  return List<ChoiceQuestion>.unmodifiable(out);
}

/// A review checkpoint over four units' worth of grammar.
///
/// Takes the *second* question from each lesson where one exists, so a learner
/// who has just passed four teaching checkpoints is not re-answering the same
/// items from memory.
List<ChoiceQuestion> _reviewCheckpoint(
  CefrLevel level,
  int slot,
  List<CourseUnit> block,
) {
  final List<ChoiceQuestion> out = <ChoiceQuestion>[];
  for (final CourseUnit unit in block) {
    for (final CourseStep step in unit.steps) {
      if (step.kind != CourseStepKind.grammar) continue;
      if (out.length >= _reviewQuestions) break;
      final List<ChoiceQuestion> pool = _questionsForRoute(step.route);
      if (pool.isEmpty) continue;
      out.add(pool.length > 1 ? pool[1] : pool.first);
    }
  }
  _padWithCloze(out, level, slot, _reviewQuestions);
  return List<ChoiceQuestion>.unmodifiable(out);
}

Map<String, List<ChoiceQuestion>>? _questionCache;

List<ChoiceQuestion> _questionsForRoute(String route) {
  final Map<String, List<ChoiceQuestion>> cache = _questionCache ??=
      _buildQuestionIndex();
  return cache[route] ?? const <ChoiceQuestion>[];
}

Map<String, List<ChoiceQuestion>> _buildQuestionIndex() {
  final Map<String, List<ChoiceQuestion>> index =
      <String, List<ChoiceQuestion>>{};
  for (final LessonRef ref in allLessons) {
    final Object lesson = ref.lesson;
    if (lesson is GrammarLesson) {
      index[ref.id] = lesson.questions;
    } else if (lesson is ListeningLesson) {
      index[ref.id] = lesson.questions;
    } else if (lesson is ReadingLesson) {
      index[ref.id] = lesson.questions;
    }
  }
  for (final CefrLevel level in CefrLevel.values) {
    for (final RadioEpisode episode in radioFor(level)) {
      index[episode.id] = episode.questions;
    }
  }
  return index;
}

/// Fill a checkpoint out to [target] with gap-fill items from the level.
///
/// The stride is derived from the slot so two units at the same level do not
/// draw the same items, and it is deterministic so a learner retrying a
/// checkpoint meets the same test rather than an easier one.
void _padWithCloze(
  List<ChoiceQuestion> out,
  CefrLevel level,
  int slot,
  int target,
) {
  final List<ClozeItem> pool = clozeFor(level);
  if (pool.isEmpty) return;
  int cursor = (slot * 37) % pool.length;
  int guard = 0;
  while (out.length < target && guard < pool.length) {
    final ClozeItem item = pool[cursor % pool.length];
    final List<String> options = item.optionsFor(slot * 13 + guard);
    out.add(
      ChoiceQuestion(
        prompt: item.gapped,
        options: options,
        correctIndex: options.indexOf(item.answer),
        explanation: '${item.full} — ${item.english}',
      ),
    );
    cursor += 1;
    guard += 1;
  }
}

// ---------------------------------------------------------------------------
// Status: a pure view over progress the app already stores.
// ---------------------------------------------------------------------------

/// Where a learner stands in one unit.
class CourseUnitStatus {
  const CourseUnitStatus({
    required this.unit,
    required this.unlocked,
    required this.stepsDone,
    required this.stepsTotal,
    required this.wordsMet,
    required this.checkpointBest,
    required this.checkpointPassed,
  });

  final CourseUnit unit;

  /// False when the previous unit's checkpoint has not been passed. The first
  /// unit of a level the learner has been placed into is always unlocked.
  final bool unlocked;

  final int stepsDone;
  final int stepsTotal;

  /// Words at this level the learner has met, against [CourseUnit.wordTarget].
  final int wordsMet;

  final int checkpointBest;
  final bool checkpointPassed;

  bool get complete => checkpointPassed;

  /// Whether every step is done, so the checkpoint can be offered rather than
  /// merely allowed. A learner may sit it early — the gate is the score, not
  /// the tick list — but the UI should not push them into it.
  bool get ready => stepsDone >= stepsTotal && wordsMet >= unit.wordTarget;

  double get progress {
    final int total = stepsTotal + 1;
    final int done = stepsDone + (checkpointPassed ? 1 : 0);
    return total == 0 ? 0 : done / total;
  }
}

/// Status for every unit, in course order.
///
/// [wordsSeenByLevel] counts vocabulary the learner has met at each level;
/// [placementLevel] is the highest level a placement test has opened, so
/// someone who tested into B1 does not have to grind A1 to reach it.
List<CourseUnitStatus> courseStatus({
  required Map<String, ActivityProgress> activities,
  required Map<CefrLevel, int> wordsSeenByLevel,
  required CefrLevel placementLevel,
}) {
  final List<CourseUnitStatus> out = <CourseUnitStatus>[];
  bool previousPassed = true;
  CefrLevel? previousLevel;

  for (final CourseUnit unit in courseUnits) {
    // The first unit of a level is open if the learner was placed at or above
    // it; otherwise progression is strictly one unit at a time.
    final bool levelStart = unit.level != previousLevel;
    final bool unlocked = levelStart
        ? unit.level.order <= placementLevel.order || previousPassed
        : previousPassed;

    int done = 0;
    int total = 0;
    for (final CourseStep step in unit.steps) {
      if (!step.isCore) continue;
      total += 1;
      if (step.isVocabulary) {
        if ((wordsSeenByLevel[unit.level] ?? 0) >= unit.wordTarget) done += 1;
        continue;
      }
      final bool all =
          step.completionIds.isNotEmpty &&
          step.completionIds.every(
            (String id) => activities[id]?.completed ?? false,
          );
      if (all) done += 1;
    }

    final ActivityProgress? check = activities[unit.checkpointId];
    final int best = check?.bestScore ?? 0;
    final bool passed = best >= courseCheckpointPass;

    out.add(
      CourseUnitStatus(
        unit: unit,
        unlocked: unlocked,
        stepsDone: done,
        stepsTotal: total,
        wordsMet: wordsSeenByLevel[unit.level] ?? 0,
        checkpointBest: best,
        checkpointPassed: passed,
      ),
    );

    previousPassed = passed;
    previousLevel = unit.level;
  }
  return out;
}

/// The unit to open when the learner taps Continue: the first unlocked unit
/// whose checkpoint is not yet passed, or the last unit once the course is
/// finished.
CourseUnitStatus? nextUnit(
  List<CourseUnitStatus> status, {
  CefrLevel? preferredLevel,
}) {
  if (preferredLevel != null) {
    for (final CourseUnitStatus s in status) {
      if (s.unit.level == preferredLevel && s.unlocked && !s.checkpointPassed) {
        return s;
      }
    }
    for (final CourseUnitStatus s in status) {
      if (s.unit.level.order > preferredLevel.order &&
          s.unlocked &&
          !s.checkpointPassed) {
        return s;
      }
    }
  }
  for (final CourseUnitStatus s in status) {
    if (s.unlocked && !s.checkpointPassed) return s;
  }
  return status.isEmpty ? null : status.last;
}

/// Whether a course step is complete in the existing progress model.
bool courseStepDone(
  CourseUnitStatus status,
  CourseStep step,
  Map<String, ActivityProgress> activities,
) {
  if (step.isVocabulary) return status.wordsMet >= status.unit.wordTarget;
  return step.completionIds.isNotEmpty &&
      step.completionIds.every(
        (String id) => activities[id]?.completed ?? false,
      );
}

/// The exact required activity the learner should do next in this unit.
CourseStep? nextCoreStep(
  CourseUnitStatus status,
  Map<String, ActivityProgress> activities,
) {
  for (final CourseStep step in status.unit.coreSteps) {
    if (!courseStepDone(status, step, activities)) return step;
  }
  return null;
}

/// One unfinished attached activity for optional reinforcement.
CourseStep? nextEnrichmentStep(
  CourseUnitStatus status,
  Map<String, ActivityProgress> activities,
) {
  for (final CourseStep step in status.unit.enrichmentSteps) {
    if (!courseStepDone(status, step, activities)) return step;
  }
  return null;
}
