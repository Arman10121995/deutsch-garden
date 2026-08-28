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
  });

  final String id;
  final LearningPathActionKind kind;
  final String title;
  final String subtitle;
  final int estimatedMinutes;
  final CourseUnit? unit;
  final CourseStep? step;
  final LessonRef? lesson;

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

  LearningPathAction? get next => actions.isEmpty ? null : actions.first;
  bool get courseComplete => currentUnit != null && unitsPassed >= unitsTotal;
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
  }
}

int _minutesFor(CourseStepKind kind) {
  switch (kind) {
    case CourseStepKind.vocabulary:
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
