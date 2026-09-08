/// The guided path has to take yes for an answer.
///
/// Two separate things used to make it hand back work the learner had just
/// finished. An activity walked the vocabulary learning steps, so a lesson
/// passed at a bare pass fell due again sixty seconds later and returned to
/// the top of the path as "Refresh:". And a story is one step made of several
/// chapters, so reading a chapter left the path's card byte-identical to the
/// one that had been there before.
library;

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/course.dart';
import 'package:deutsch_garden/course_screens.dart';
import 'package:deutsch_garden/learning_path.dart';
import 'package:deutsch_garden/lesson_registry.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/stories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('a passed activity graduates instead of returning in a minute', () {
    test('a bare pass is scheduled in days, not in learning steps', () {
      final SrsOutcome outcome = Sm2Scheduler.scheduleActivity(
        ease: 2.5,
        intervalDays: 0,
        reps: 0,
        lapses: 0,
        learningStep: 0,
        grade: ReviewGrade.hard,
      );

      expect(outcome.intervalDays, greaterThanOrEqualTo(1));
      expect(outcome.learningStep, Sm2Scheduler.learningStepMinutes.length);
      expect(outcome.reps, 1);
    });

    test('a better pass earns a longer first interval', () {
      int daysFor(ReviewGrade grade) => Sm2Scheduler.scheduleActivity(
        ease: 2.5,
        intervalDays: 0,
        reps: 0,
        lapses: 0,
        learningStep: 0,
        grade: grade,
        // No spread: the point here is the ordering, and the fuzz exists to
        // break same-day clumps rather than to change it.
        fuzz: null,
      ).intervalDays;

      expect(daysFor(ReviewGrade.hard), 1);
      expect(daysFor(ReviewGrade.good), 2);
      expect(daysFor(ReviewGrade.easy), 4);
    });

    test('a graduated activity that lapses still comes back inside the '
        'session', () {
      final SrsOutcome outcome = Sm2Scheduler.scheduleActivity(
        ease: 2.5,
        intervalDays: 4,
        reps: 3,
        lapses: 0,
        learningStep: Sm2Scheduler.learningStepMinutes.length,
        grade: ReviewGrade.again,
      );

      expect(
        outcome.intervalDays,
        0,
        reason: 'a real lapse re-enters learning',
      );
      expect(outcome.lapses, 1);
    });

    test('a graduated activity keeps ordinary SM-2 spacing', () {
      final SrsOutcome outcome = Sm2Scheduler.scheduleActivity(
        ease: 2.5,
        intervalDays: 4,
        reps: 3,
        lapses: 0,
        learningStep: Sm2Scheduler.learningStepMinutes.length,
        grade: ReviewGrade.good,
        fuzz: null,
      );

      expect(outcome.intervalDays, 10, reason: '4 days times an ease of 2.5');
    });
  });

  group('the learning path does not re-offer what was just finished', () {
    test('a writing lesson passed at a bare pass is not due again today',
        () async {
      final AppController controller = AppController();
      await controller.load();
      final LessonRef writing = allLessons.firstWhere(
        (LessonRef lesson) => lesson.skill == SkillType.writing,
      );

      // 72 grades as `hard` against the default pass mark of 70, which is
      // exactly the band the rubric-scored writing task lands in.
      await controller.recordActivity(writing.id, score: 72);

      expect(controller.activities[writing.id]?.completed, isTrue);
      expect(
        controller.dueActivityIds,
        isNot(contains(writing.id)),
        reason: 'it was passed a moment ago; it is not due',
      );
    });

    test('the finished lesson does not reappear as the next path action',
        () async {
      final AppController controller = AppController();
      await controller.load();
      final LessonRef writing = allLessons.firstWhere(
        (LessonRef lesson) => lesson.skill == SkillType.writing,
      );
      await controller.recordActivity(writing.id, score: 72);

      final LearningPathPlan plan = buildLearningPath(
        status: courseStatus(
          activities: controller.activities,
          wordsSeenByLevel: controller.wordsSeenByLevel,
          placementLevel: controller.highestUnlockedLevel,
        ),
        activities: controller.activities,
        dueWords: 0,
        dueLessons: lessonsForIds(controller.dueActivityIds),
        mistakeCount: 0,
        preferredLevel: controller.highestUnlockedLevel,
        includePracticeDrill: false,
      );

      expect(
        plan.actions.where(
          (LearningPathAction action) =>
              action.kind == LearningPathActionKind.lessonReview,
        ),
        isEmpty,
      );
    });
  });

  group('a multi-chapter story shows that a chapter counted', () {
    ActivityProgress done() =>
        ActivityProgress(attempts: 1, bestScore: 100, completed: true);

    /// The first core story step in the course, with every core step before it
    /// already finished so the path is pointing at it.
    (CourseUnit, CourseStep, Map<String, ActivityProgress>) storyStep() {
      for (final CourseUnit unit in courseUnits) {
        final Map<String, ActivityProgress> activities =
            <String, ActivityProgress>{};
        for (final CourseStep step in unit.coreSteps) {
          if (step.kind == CourseStepKind.story &&
              step.completionIds.length > 1) {
            return (unit, step, activities);
          }
          for (final String id in step.completionIds) {
            activities[id] = done();
          }
        }
      }
      throw StateError('no core story step with several chapters');
    }

    LearningPathPlan planFor(
      CourseUnit unit,
      Map<String, ActivityProgress> activities,
    ) => buildLearningPath(
      status: courseStatus(
        activities: activities,
        wordsSeenByLevel: <CefrLevel, int>{unit.level: unit.wordTarget},
        placementLevel: unit.level,
      ),
      activities: activities,
      dueWords: 0,
      dueLessons: const <LessonRef>[],
      mistakeCount: 0,
      preferredLevel: unit.level,
      includePracticeDrill: false,
    );

    test('the path counts the chapters and names the next one', () {
      final (
        CourseUnit unit,
        CourseStep step,
        Map<String, ActivityProgress> activities,
      ) = storyStep();

      final LearningPathAction before = planFor(unit, activities).next!;
      expect(before.step?.route, step.route);
      expect(before.partsTotal, step.completionIds.length);
      expect(before.partsDone, 0);
      expect(before.subtitle, contains('chapter 1 of ${before.partsTotal}'));

      activities[step.completionIds.first] = done();
      final LearningPathAction after = planFor(unit, activities).next!;
      expect(
        after.step?.route,
        step.route,
        reason: 'the story is not finished',
      );
      expect(after.partsDone, 1);
      expect(after.subtitle, contains('chapter 2 of ${after.partsTotal}'));
    });

    test('a finished chapter is progress, so a guided session continues', () {
      final (
        CourseUnit unit,
        CourseStep step,
        Map<String, ActivityProgress> activities,
      ) = storyStep();
      final LearningPathAction before = planFor(unit, activities).next!;

      activities[step.completionIds.first] = done();
      final LearningPathAction after = planFor(unit, activities).next!;

      expect(after.id, before.id, reason: 'the same step is still in progress');
      expect(
        after.sameProgressAs(before),
        isFalse,
        reason: 'a chapter was read, so the session has moved on',
      );
      expect(after.sameProgressAs(after), isTrue);
    });

    test('the step ticks once the last chapter is read', () {
      final (
        CourseUnit unit,
        CourseStep step,
        Map<String, ActivityProgress> activities,
      ) = storyStep();
      for (final String id in step.completionIds) {
        activities[id] = done();
      }

      final LearningPathAction next = planFor(unit, activities).next!;
      expect(next.step?.route, isNot(step.route));
    });

    testWidgets('the course step opens the next unread chapter itself', (
      WidgetTester tester,
    ) async {
      AppController.debounceWrites = false;
      final AppController controller = AppController();
      addTearDown(controller.dispose);
      await controller.load();

      final CourseUnit unit = courseUnits.firstWhere(
        (CourseUnit candidate) => candidate.steps.any(
          (CourseStep step) =>
              step.kind == CourseStepKind.story &&
              step.completionIds.length > 1,
        ),
      );
      final CourseStep step = unit.steps.firstWhere(
        (CourseStep candidate) =>
            candidate.kind == CourseStepKind.story &&
            candidate.completionIds.length > 1,
      );
      final Story story = storiesFor(
        unit.level,
      ).firstWhere((Story candidate) => candidate.id == step.route);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) => ElevatedButton(
              onPressed: () =>
                  openCourseStep(context, controller, unit, step),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text(story.chapters.first.title), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await controller.recordStoryChapter(
        story.chapters.first.id,
        score: 100,
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(
        find.text(story.chapters[1].title),
        findsOneWidget,
        reason: 'the finished chapter is not offered again',
      );
    });

    test('a single-part step says nothing about parts', () {
      final CourseUnit unit = courseUnits.first;
      final LearningPathAction first = buildLearningPath(
        status: courseStatus(
          activities: const <String, ActivityProgress>{},
          wordsSeenByLevel: const <CefrLevel, int>{},
          placementLevel: unit.level,
        ),
        activities: const <String, ActivityProgress>{},
        dueWords: 0,
        dueLessons: const <LessonRef>[],
        mistakeCount: 0,
        preferredLevel: unit.level,
        includePracticeDrill: false,
      ).next!;

      expect(first.isMultiPart, isFalse);
      expect(first.subtitle, isNot(contains(' of ')));
    });
  });
}
