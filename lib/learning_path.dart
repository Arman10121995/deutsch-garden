import 'course.dart';
import 'lesson_registry.dart';
import 'models.dart';

/// The small set of route shapes the automatic Learn screen can offer.
enum LearningPathActionKind {
  wordReview,
  lessonReview,
  courseStep,
  checkpoint,
  mistakeRepair,
  enrichment,

  /// One drill from the practice labs, chosen for the learner.
  ///
  /// The labs were only ever reachable by going to Explore and picking one,
  /// which meant the learners who most needed the retrieval practice were the
  /// ones least likely to go looking for it. Learn now closes each session
  /// with one, so following the path is enough.
  practiceDrill,
}

/// The drills the path can hand out, in rotation.
///
/// A fixed rotation rather than a random pick: variety matters, but so does
/// not asking the same person for dictation three days running because a die
/// said so.
enum PracticeDrill {
  matchPairs,
  sentenceBuilder,
  cloze,
  articles,
  verbs,
  speedReview,
  dictation,
}

extension PracticeDrillX on PracticeDrill {
  String get label {
    switch (this) {
      case PracticeDrill.matchPairs:
        return 'Match pairs';
      case PracticeDrill.sentenceBuilder:
        return 'Sentence builder';
      case PracticeDrill.cloze:
        return 'Cloze drill';
      case PracticeDrill.articles:
        return 'Der / die / das';
      case PracticeDrill.verbs:
        return 'Verb lab';
      case PracticeDrill.speedReview:
        return 'Speed review';
      case PracticeDrill.dictation:
        return 'Dictation';
    }
  }

  String get blurb {
    switch (this) {
      case PracticeDrill.matchPairs:
        return 'Recall under a little pressure';
      case PracticeDrill.sentenceBuilder:
        return 'Rebuild complete sentences';
      case PracticeDrill.cloze:
        return 'Fill words in context';
      case PracticeDrill.articles:
        return 'Article and gender patterns';
      case PracticeDrill.verbs:
        return 'Conjugation across tenses';
      case PracticeDrill.speedReview:
        return 'One-minute retrieval sprint';
      case PracticeDrill.dictation:
        return 'Write what you hear';
    }
  }
}

/// Which drill today's session ends on.
///
/// Keyed on the day rather than on a counter, so the rotation is the same
/// whichever screen asks and does not advance just because the plan was
/// rebuilt after an answer.
PracticeDrill drillForDay(DateTime day) {
  final int index = day.difference(DateTime.utc(2026, 1, 1)).inDays;
  final List<PracticeDrill> all = PracticeDrill.values;
  return all[index.abs() % all.length];
}

class LearningPathAction {
  const LearningPathAction({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.estimatedMinutes,
    this.unit,
    this.step,
    this.lesson,
    this.drill,
  });

  final String id;
  final LearningPathActionKind kind;
  final String title;
  final String subtitle;
  final int estimatedMinutes;
  final CourseUnit? unit;
  final CourseStep? step;
  final LessonRef? lesson;
  final PracticeDrill? drill;

  bool get isOptional => kind == LearningPathActionKind.enrichment;
}

class LearningPathPlan {
  const LearningPathPlan({
    required this.actions,
    required this.currentUnit,
    required this.unitsPassed,
    required this.unitsTotal,
  });

  final List<LearningPathAction> actions;
  final CourseUnitStatus? currentUnit;
  final int unitsPassed;
  final int unitsTotal;

  List<LearningPathAction> get requiredActions => actions
      .where((LearningPathAction action) => !action.isOptional)
      .toList(growable: false);

  LearningPathAction? get next {
    for (final LearningPathAction action in actions) {
      if (!action.isOptional) return action;
    }
    return null;
  }

  LearningPathAction? get enrichment {
    for (final LearningPathAction action in actions) {
      if (action.isOptional) return action;
    }
    return null;
  }

  int get estimatedMinutes => requiredActions.fold<int>(
    0,
    (int total, LearningPathAction action) => total + action.estimatedMinutes,
  );

  bool get courseComplete => unitsTotal > 0 && unitsPassed >= unitsTotal;
}

/// Builds a short session from the learner's real state. Nothing is persisted:
/// finish an activity, return to Learn, and the next call advances naturally.
LearningPathPlan buildLearningPath({
  required List<CourseUnitStatus> status,
  required Map<String, ActivityProgress> activities,
  required int dueWords,
  required List<LessonRef> dueLessons,
  required int mistakeCount,
  required CefrLevel preferredLevel,
  DateTime? today,
  bool includePracticeDrill = true,
}) {
  final CourseUnitStatus? current = nextUnit(
    status,
    preferredLevel: preferredLevel,
  );
  final List<LearningPathAction> actions = <LearningPathAction>[];

  // Retrieval comes before new material, but only as one visible block. The
  // review screen itself caps a Learn-session run, so a backlog cannot turn
  // this page into a hundred separate rows.
  if (dueWords > 0) {
    final int batch = dueWords < 20 ? dueWords : 20;
    actions.add(
      LearningPathAction(
        id: 'path-word-review',
        kind: LearningPathActionKind.wordReview,
        title: 'Review $batch due word${batch == 1 ? '' : 's'}',
        subtitle: dueWords > batch
            ? '$dueWords are due; start with a focused batch of $batch.'
            : 'Strengthen the words whose memory interval has elapsed.',
        estimatedMinutes: batch <= 10 ? 5 : 8,
      ),
    );
  }

  if (dueLessons.isNotEmpty) {
    final LessonRef lesson = dueLessons.first;
    actions.add(
      LearningPathAction(
        id: 'path-lesson-${lesson.id}',
        kind: LearningPathActionKind.lessonReview,
        title: 'Refresh: ${lesson.title}',
        subtitle:
            '${lesson.level.label} ${lesson.skill.label.toLowerCase()} '
            'is due for spaced review.',
        estimatedMinutes: 8,
        lesson: lesson,
      ),
    );
  }

  if (current != null && !current.checkpointPassed) {
    final CourseStep? step = nextCoreStep(current, activities);
    if (step != null) {
      actions.add(
        LearningPathAction(
          id: 'path-core-${current.unit.id}-${step.route}',
          kind: LearningPathActionKind.courseStep,
          title: step.title,
          subtitle:
              '${current.unit.level.label} · Unit '
              '${current.unit.number} · ${_stepLabel(step.kind)}',
          estimatedMinutes: _minutesFor(step.kind),
          unit: current.unit,
          step: step,
        ),
      );
    } else {
      actions.add(
        LearningPathAction(
          id: 'path-check-${current.unit.id}',
          kind: LearningPathActionKind.checkpoint,
          title: 'Checkpoint: ${current.unit.title}',
          subtitle:
              '${current.unit.checkpoint.length} questions · '
              '$courseCheckpointPass% opens the next unit.',
          estimatedMinutes: 10,
          unit: current.unit,
        ),
      );
    }
  }

  if (mistakeCount > 0) {
    actions.add(
      LearningPathAction(
        id: 'path-mistakes',
        kind: LearningPathActionKind.mistakeRepair,
        title:
            'Repair $mistakeCount recent mistake${mistakeCount == 1 ? '' : 's'}',
        subtitle: 'Revisit exactly what went wrong before it becomes a habit.',
        estimatedMinutes: mistakeCount < 6 ? 5 : 8,
      ),
    );
  }

  if (current != null) {
    final CourseStep? extra = nextEnrichmentStep(current, activities);
    if (extra != null) {
      actions.add(
        LearningPathAction(
          id: 'path-extra-${current.unit.id}-${extra.route}',
          kind: LearningPathActionKind.enrichment,
          title: 'Extra: ${extra.title}',
          subtitle:
              'Optional ${_stepLabel(extra.kind).toLowerCase()} attached '
              'to this unit; it does not block the checkpoint.',
          estimatedMinutes: _minutesFor(extra.kind),
          unit: current.unit,
          step: extra,
        ),
      );
    }
  }

  // One drill to close the session.
  //
  // The labs were only ever reachable by going to Explore and choosing one,
  // so the learners who most needed retrieval practice were the ones least
  // likely to go and find it. It sits last and is not optional-looking: the
  // point of the guided path is that following it is enough.
  if (includePracticeDrill) {
    final PracticeDrill drill = drillForDay(today ?? DateTime.now());
    actions.add(
      LearningPathAction(
        id: 'drill-${drill.name}',
        kind: LearningPathActionKind.practiceDrill,
        title: drill.label,
        subtitle: '${drill.blurb} — closes the session.',
        estimatedMinutes: 3,
        drill: drill,
      ),
    );
  }

  return LearningPathPlan(
    actions: List<LearningPathAction>.unmodifiable(actions),
    currentUnit: current,
    unitsPassed: status.where((CourseUnitStatus item) => item.complete).length,
    unitsTotal: status.length,
  );
}

String _stepLabel(CourseStepKind kind) {
  switch (kind) {
    case CourseStepKind.grammar:
      return 'Grammar';
    case CourseStepKind.listening:
      return 'Listening';
    case CourseStepKind.reading:
      return 'Reading';
    case CourseStepKind.writing:
      return 'Writing';
    case CourseStepKind.speaking:
      return 'Speaking';
    case CourseStepKind.story:
      return 'Story';
    case CourseStepKind.conversation:
      return 'Role-play';
    case CourseStepKind.radio:
      return 'Gartenradio';
    case CourseStepKind.vocabulary:
      return 'Vocabulary';
    case CourseStepKind.matching:
      return 'Matching';
    case CourseStepKind.sentenceBuilder:
      return 'Sentence builder';
    case CourseStepKind.dictation:
      return 'Dictation';
  }
}

int _minutesFor(CourseStepKind kind) {
  switch (kind) {
    case CourseStepKind.vocabulary:
      return 8;
    case CourseStepKind.matching:
    case CourseStepKind.sentenceBuilder:
    case CourseStepKind.dictation:
      return 8;
    case CourseStepKind.grammar:
    case CourseStepKind.listening:
    case CourseStepKind.reading:
    case CourseStepKind.speaking:
      return 10;
    case CourseStepKind.writing:
    case CourseStepKind.story:
    case CourseStepKind.conversation:
    case CourseStepKind.radio:
      return 15;
  }
}
