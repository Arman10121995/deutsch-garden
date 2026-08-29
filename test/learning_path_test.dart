import 'package:deutsch_garden/course.dart';
import 'package:deutsch_garden/learning_path.dart';
import 'package:deutsch_garden/lesson_registry.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<CourseUnitStatus> status(
    Map<String, ActivityProgress> activities, {
    int words = 0,
  }) => courseStatus(
    activities: activities,
    wordsSeenByLevel: <CefrLevel, int>{CefrLevel.a1: words},
    placementLevel: CefrLevel.a1,
  );

  ActivityProgress done() =>
      ActivityProgress(attempts: 1, bestScore: 100, completed: true);

  test('a fresh learner gets one direct course action, not a catalogue', () {
    final LearningPathPlan plan = buildLearningPath(
      status: status(const <String, ActivityProgress>{}),
      activities: const <String, ActivityProgress>{},
      dueWords: 0,
      dueLessons: const <LessonRef>[],
      mistakeCount: 0,
      preferredLevel: CefrLevel.a1,
      // These tests are about course sequencing. The closing practice drill
      // has its own file; leaving it on here would couple every assertion
      // about the path's shape to a feature it is not testing.
      includePracticeDrill: false,
    );

    expect(plan.next?.kind, LearningPathActionKind.courseStep);
    expect(plan.next?.step?.kind, CourseStepKind.vocabulary);
    expect(plan.next?.unit?.id, courseUnits.first.id);
    expect(plan.requiredActions, hasLength(1));
    expect(plan.estimatedMinutes, 8);
    expect(plan.enrichment?.kind, LearningPathActionKind.enrichment);
    expect(
      plan.actions.where((LearningPathAction action) => action.isOptional),
      hasLength(1),
    );
  });

  test('optional enrichment never becomes the required next action', () {
    const LearningPathAction extra = LearningPathAction(
      id: 'extra',
      kind: LearningPathActionKind.enrichment,
      title: 'Extra listening',
      subtitle: 'Optional',
      estimatedMinutes: 10,
    );
    const LearningPathPlan plan = LearningPathPlan(
      actions: <LearningPathAction>[extra],
      currentUnit: null,
      unitsPassed: 0,
      unitsTotal: 1,
    );

    expect(plan.next, isNull);
    expect(plan.requiredActions, isEmpty);
    expect(plan.enrichment, same(extra));
    expect(plan.estimatedMinutes, 0);
  });

  test('due retrieval is placed before new learning automatically', () {
    final LessonRef lesson = allLessons.first;
    final LearningPathPlan plan = buildLearningPath(
      status: status(const <String, ActivityProgress>{}),
      activities: const <String, ActivityProgress>{},
      dueWords: 47,
      dueLessons: <LessonRef>[lesson],
      mistakeCount: 3,
      preferredLevel: CefrLevel.a1,
      // These tests are about course sequencing. The closing practice drill
      // has its own file; leaving it on here would couple every assertion
      // about the path's shape to a feature it is not testing.
      includePracticeDrill: false,
    );

    expect(
      plan.actions.map((LearningPathAction action) => action.kind).take(4),
      <LearningPathActionKind>[
        LearningPathActionKind.wordReview,
        LearningPathActionKind.lessonReview,
        LearningPathActionKind.courseStep,
        LearningPathActionKind.mistakeRepair,
      ],
    );
    expect(plan.actions.first.title, contains('20'));
  });

  test(
    'finishing the core offers the checkpoint while extras stay optional',
    () {
      final CourseUnit unit = courseUnits.first;
      final Map<String, ActivityProgress> activities =
          <String, ActivityProgress>{
            for (final CourseStep step in unit.coreSteps)
              for (final String id in step.completionIds) id: done(),
          };
      final LearningPathPlan plan = buildLearningPath(
        status: status(activities, words: unit.wordTarget),
        activities: activities,
        dueWords: 0,
        dueLessons: const <LessonRef>[],
        mistakeCount: 0,
        preferredLevel: CefrLevel.a1,
      // These tests are about course sequencing. The closing practice drill
      // has its own file; leaving it on here would couple every assertion
      // about the path's shape to a feature it is not testing.
      includePracticeDrill: false,
      );

      expect(plan.next?.kind, LearningPathActionKind.checkpoint);
      expect(plan.next?.unit?.id, unit.id);
      expect(plan.actions.last.kind, LearningPathActionKind.enrichment);
    },
  );

  test('passing a checkpoint advances to the next unit', () {
    final CourseUnit first = courseUnits.first;
    final Map<String, ActivityProgress> activities = <String, ActivityProgress>{
      first.checkpointId: done(),
    };
    final LearningPathPlan plan = buildLearningPath(
      status: status(activities),
      activities: activities,
      dueWords: 0,
      dueLessons: const <LessonRef>[],
      mistakeCount: 0,
      preferredLevel: CefrLevel.a1,
      // These tests are about course sequencing. The closing practice drill
      // has its own file; leaving it on here would couple every assertion
      // about the path's shape to a feature it is not testing.
      includePracticeDrill: false,
    );

    expect(plan.currentUnit?.unit.id, courseUnits[1].id);
    expect(plan.next?.unit?.id, courseUnits[1].id);
  });

  test('matching, sentence building or dictation becomes an automatic next '
      'step inside the unit', () {
    final CourseUnit unit = courseUnits.first;
    final CourseStep practice = unit.coreSteps.firstWhere((CourseStep step) =>
        <CourseStepKind>{
          CourseStepKind.matching,
          CourseStepKind.sentenceBuilder,
          CourseStepKind.dictation,
        }.contains(step.kind));
    final Map<String, ActivityProgress> activities = <String, ActivityProgress>{};
    for (final CourseStep step in unit.coreSteps) {
      if (identical(step, practice)) break;
      for (final String id in step.completionIds) {
        activities[id] = done();
      }
    }
    final LearningPathPlan plan = buildLearningPath(
      status: status(activities, words: unit.wordTarget),
      activities: activities,
      dueWords: 0,
      dueLessons: const <LessonRef>[],
      mistakeCount: 0,
      preferredLevel: CefrLevel.a1,
      // These tests are about course sequencing. The closing practice drill
      // has its own file; leaving it on here would couple every assertion
      // about the path's shape to a feature it is not testing.
      includePracticeDrill: false,
    );
    expect(plan.next?.step?.kind, practice.kind);
    expect(plan.next?.step?.completionIds, practice.completionIds);
  });

  test('placement makes the placed level the automatic starting point', () {
    final List<CourseUnitStatus> placed = courseStatus(
      activities: const <String, ActivityProgress>{},
      wordsSeenByLevel: const <CefrLevel, int>{},
      placementLevel: CefrLevel.b1,
    );
    final LearningPathPlan plan = buildLearningPath(
      status: placed,
      activities: const <String, ActivityProgress>{},
      dueWords: 0,
      dueLessons: const <LessonRef>[],
      mistakeCount: 0,
      preferredLevel: CefrLevel.b1,
    );

    expect(plan.currentUnit?.unit.level, CefrLevel.b1);
    expect(plan.currentUnit?.unit.number, 1);
  });
}
