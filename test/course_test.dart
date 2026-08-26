import 'package:deutsch_garden/course.dart';
import 'package:deutsch_garden/lesson_registry.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the spine', () {
    test('every level has twelve slots in the documented pattern', () {
      for (final CefrLevel level in CefrLevel.values) {
        final List<CourseUnit> units = unitsFor(level);
        expect(units.length, 12, reason: '${level.label} unit count');

        // Four teaching units, then a review, repeating, and the level always
        // ends on a review so the last thing done is a whole-level test.
        const List<CourseUnitKind> expected = <CourseUnitKind>[
          CourseUnitKind.teaching,
          CourseUnitKind.teaching,
          CourseUnitKind.teaching,
          CourseUnitKind.teaching,
          CourseUnitKind.review,
          CourseUnitKind.teaching,
          CourseUnitKind.teaching,
          CourseUnitKind.teaching,
          CourseUnitKind.teaching,
          CourseUnitKind.review,
          CourseUnitKind.teaching,
          CourseUnitKind.review,
        ];
        expect(
          units.map((CourseUnit u) => u.kind).toList(),
          expected,
          reason: '${level.label} unit pattern',
        );

        for (int i = 0; i < units.length; i++) {
          expect(units[i].number, i + 1);
        }
      }
    });

    test('unit ids are unique and sort into course order', () {
      final List<String> ids =
          courseUnits.map((CourseUnit u) => u.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate unit id');
      expect(ids, List<String>.from(ids)..sort());
    });

    test('every grammar lesson is placed exactly once', () {
      final Set<String> catalogue = <String>{
        for (final LessonRef ref in allLessons)
          if (ref.skill == SkillType.grammar) ref.id,
      };

      final List<String> placed = <String>[
        for (final CourseUnit unit in courseUnits)
          if (!unit.isReview)
            for (final CourseStep step in unit.steps)
              if (step.kind == CourseStepKind.grammar) step.route,
      ];

      expect(placed.toSet().length, placed.length,
          reason: 'a grammar lesson is placed in two units');
      // Both directions: nothing invented, nothing forgotten. A grammar
      // lesson added to the catalogue but not to the spine fails here, which
      // is the point — placing it is a teaching decision, not a default.
      expect(placed.toSet().difference(catalogue), isEmpty,
          reason: 'the spine names a grammar lesson that does not exist');
      expect(catalogue.difference(placed.toSet()), isEmpty,
          reason: 'a grammar lesson exists but no unit teaches it');
    });

    test('every supporting lesson is dealt to exactly one unit', () {
      final List<String> routes = <String>[
        for (final CourseUnit unit in courseUnits)
          if (!unit.isReview)
            for (final CourseStep step in unit.steps)
              if (step.kind != CourseStepKind.grammar && !step.isVocabulary)
                step.route,
      ];
      expect(routes.toSet().length, routes.length,
          reason: 'supporting material dealt twice');
    });

    test('the supporting material is spread, not clumped', () {
      for (final CourseUnit unit in courseUnits) {
        if (unit.isReview) continue;
        final List<CourseStep> support = unit.steps
            .where((CourseStep s) =>
                s.kind != CourseStepKind.grammar && !s.isVocabulary)
            .toList();
        expect(support, isNotEmpty,
            reason: '${unit.id} has no supporting activity at all');
        // A unit of five listening lessons and nothing else would satisfy the
        // count while being useless, so assert the mix directly.
        final int kinds = support.map((CourseStep s) => s.kind).toSet().length;
        expect(kinds, greaterThanOrEqualTo(2),
            reason: '${unit.id} draws on only one kind of activity');
      }
    });

    test('every unit states a first-person outcome', () {
      for (final CourseUnit unit in courseUnits) {
        expect(unit.title, isNotEmpty);
        expect(unit.canDo, startsWith('I can '),
            reason: '${unit.id} does not state what the learner can do');
        expect(unit.canDo.length, greaterThan(40),
            reason: '${unit.id} outcome is too vague to mean anything');
      }
    });

    test('the last unit of a level tests the whole level', () {
      for (final CefrLevel level in CefrLevel.values) {
        final List<CourseUnit> units = unitsFor(level);
        final CourseUnit closing = units.last;
        expect(closing.isReview, isTrue);
        expect(closing.title, 'Level test: ${level.label}');

        // Not the trailing block: every teaching unit of the level. The gate
        // before moving up has to be a level test, not a unit test.
        final Set<String> teaching = <String>{
          for (final CourseUnit u in units)
            if (!u.isReview) u.id,
        };
        expect(closing.reviewOf.toSet(), teaching);
      }
    });

    test('a review unit folds in the four units before it', () {
      for (final CourseUnit unit in courseUnits) {
        if (!unit.isReview) continue;
        expect(unit.reviewOf, isNotEmpty);
        for (final String id in unit.reviewOf) {
          final CourseUnit? source = unitById(id);
          expect(source, isNotNull, reason: '$id referenced by ${unit.id}');
          expect(source!.level, unit.level);
          expect(source.number, lessThan(unit.number));
        }
        expect(unit.steps, isNotEmpty);
      }
    });
  });

  group('checkpoints', () {
    test('each has enough questions and exactly one right answer', () {
      for (final CourseUnit unit in courseUnits) {
        final List<ChoiceQuestion> check = unit.checkpoint;
        expect(check.length, greaterThanOrEqualTo(10),
            reason: '${unit.id} checkpoint is too short to gate anything');
        for (final ChoiceQuestion q in check) {
          expect(q.options.length, greaterThanOrEqualTo(2),
              reason: '${unit.id}: "${q.prompt}"');
          expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1),
              reason: '${unit.id}: "${q.prompt}" has no correct option');
          expect(q.options.toSet().length, q.options.length,
              reason: '${unit.id}: "${q.prompt}" repeats an option');
          expect(q.prompt.trim(), isNotEmpty);
        }
      }
    });

    test('a review checkpoint is not the teaching checkpoints again', () {
      for (final CourseUnit review in courseUnits) {
        if (!review.isReview) continue;
        final Set<String> reviewPrompts =
            review.checkpoint.map((ChoiceQuestion q) => q.prompt).toSet();
        for (final String id in review.reviewOf) {
          final Set<String> taught = unitById(id)!
              .checkpoint
              .map((ChoiceQuestion q) => q.prompt)
              .toSet();
          final Set<String> shared = reviewPrompts.intersection(taught);
          // Some overlap is unavoidable where a lesson only wrote one drill.
          // Wholesale repetition is not.
          expect(shared.length, lessThan(review.checkpoint.length ~/ 2),
              reason: '${review.id} mostly repeats $id');
        }
      }
    });

    test('the same unit always produces the same checkpoint', () {
      final CourseUnit first = courseUnits.first;
      expect(
        unitById(first.id)!.checkpoint.map((ChoiceQuestion q) => q.prompt),
        first.checkpoint.map((ChoiceQuestion q) => q.prompt),
      );
    });
  });

  group('gating', () {
    Map<String, ActivityProgress> passed(Iterable<String> ids) =>
        <String, ActivityProgress>{
          for (final String id in ids)
            id: ActivityProgress(attempts: 1, bestScore: 100, completed: true),
        };

    test('a fresh learner has exactly one unit open', () {
      final List<CourseUnitStatus> status = courseStatus(
        activities: const <String, ActivityProgress>{},
        wordsSeenByLevel: const <CefrLevel, int>{},
        placementLevel: CefrLevel.a1,
      );
      final List<CourseUnitStatus> open =
          status.where((CourseUnitStatus s) => s.unlocked).toList();
      expect(open.length, 1);
      expect(open.single.unit.id, courseUnits.first.id);
      expect(nextUnit(status)!.unit.id, courseUnits.first.id);
    });

    test('passing a checkpoint opens the next unit and nothing further', () {
      final List<CourseUnitStatus> status = courseStatus(
        activities: passed(<String>[courseUnits.first.checkpointId]),
        wordsSeenByLevel: const <CefrLevel, int>{},
        placementLevel: CefrLevel.a1,
      );
      expect(status[0].checkpointPassed, isTrue);
      expect(status[1].unlocked, isTrue);
      expect(status[2].unlocked, isFalse);
      expect(nextUnit(status)!.unit.id, courseUnits[1].id);
    });

    test('a checkpoint below the pass mark does not open the next unit', () {
      final List<CourseUnitStatus> status = courseStatus(
        activities: <String, ActivityProgress>{
          courseUnits.first.checkpointId: ActivityProgress(
            attempts: 3,
            bestScore: courseCheckpointPass - 1,
            completed: true,
          ),
        },
        wordsSeenByLevel: const <CefrLevel, int>{},
        placementLevel: CefrLevel.a1,
      );
      expect(status[0].checkpointPassed, isFalse);
      expect(status[1].unlocked, isFalse);
    });

    test('a placement result opens that level without grinding the ones below',
        () {
      final List<CourseUnitStatus> status = courseStatus(
        activities: const <String, ActivityProgress>{},
        wordsSeenByLevel: const <CefrLevel, int>{},
        placementLevel: CefrLevel.b1,
      );
      final CourseUnitStatus b1 = status.firstWhere(
        (CourseUnitStatus s) => s.unit.level == CefrLevel.b1,
      );
      expect(b1.unlocked, isTrue);
      // ...but only the first unit of it.
      final List<CourseUnitStatus> b1Units = status
          .where((CourseUnitStatus s) => s.unit.level == CefrLevel.b1)
          .toList();
      expect(b1Units[1].unlocked, isFalse);
      // And A1 is still open, because being placed at B1 does not forbid
      // going back.
      expect(status.first.unlocked, isTrue);
    });

    test('work done before the course existed already counts', () {
      final CourseUnit unit = courseUnits.first;
      final List<String> ids = unit.activityIds;
      final List<CourseUnitStatus> status = courseStatus(
        activities: passed(ids),
        wordsSeenByLevel: const <CefrLevel, int>{CefrLevel.a1: 500},
        placementLevel: CefrLevel.a1,
      );
      expect(status.first.stepsDone, unit.steps.length);
      expect(status.first.ready, isTrue);
      // Ready, but not complete: the checkpoint has still to be sat.
      expect(status.first.complete, isFalse);
    });

    test('the vocabulary target counts words, not lessons', () {
      final CourseUnit unit = courseUnits.first;
      final List<CourseUnitStatus> short = courseStatus(
        activities: passed(unit.activityIds),
        wordsSeenByLevel: <CefrLevel, int>{CefrLevel.a1: unit.wordTarget - 1},
        placementLevel: CefrLevel.a1,
      );
      expect(short.first.ready, isFalse);
      expect(short.first.stepsDone, unit.steps.length - 1);
    });
  });
}
