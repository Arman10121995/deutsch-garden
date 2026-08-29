import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/course.dart';
import 'package:deutsch_garden/learning_path.dart';
import 'package:deutsch_garden/lesson_registry.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

LearningPathPlan planFor({
  bool includeDrill = true,
  DateTime? today,
  Map<String, ActivityProgress>? activities,
}) {
  final Map<String, ActivityProgress> progress =
      activities ?? <String, ActivityProgress>{};
  return buildLearningPath(
    status: courseStatus(
      activities: progress,
      wordsSeenByLevel: const <CefrLevel, int>{},
      placementLevel: CefrLevel.a1,
    ),
    activities: progress,
    dueWords: 0,
    dueLessons: const <LessonRef>[],
    mistakeCount: 0,
    preferredLevel: CefrLevel.a1,
    today: today,
    includePracticeDrill: includeDrill,
  );
}

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('the guided session', () {
    test('ends on a practice drill', () {
      final LearningPathPlan plan = planFor();
      expect(plan.actions.last.kind, LearningPathActionKind.practiceDrill,
          reason: 'the labs were only reachable by going to Explore and '
              'choosing one, so the learners who most needed retrieval '
              'practice were the least likely to find it');
      expect(plan.actions.last.drill, isNotNull);
    });

    test('the drill is not optional-looking', () {
      // Enrichment is explicitly optional; the drill is part of the session.
      expect(planFor().actions.last.isOptional, isFalse);
    });

    test('can be switched off, and then the path has no drill', () {
      final LearningPathPlan plan = planFor(includeDrill: false);
      expect(
          plan.actions.any((LearningPathAction a) =>
              a.kind == LearningPathActionKind.practiceDrill),
          isFalse);
      expect(plan.actions, isNotEmpty, reason: 'the rest of the path remains');
    });

    test('adding the drill does not displace the course work', () {
      final LearningPathPlan with_ = planFor();
      final LearningPathPlan without = planFor(includeDrill: false);
      expect(with_.actions.length, without.actions.length + 1);
      for (int i = 0; i < without.actions.length; i++) {
        expect(with_.actions[i].id, without.actions[i].id);
      }
    });
  });

  group('the rotation', () {
    test('covers every drill across a week', () {
      final Set<PracticeDrill> seen = <PracticeDrill>{
        for (int day = 0; day < PracticeDrill.values.length; day++)
          drillForDay(DateTime.utc(2026, 3, 1).add(Duration(days: day))),
      };
      expect(seen.length, PracticeDrill.values.length,
          reason: 'a learner should not get dictation three days running');
    });

    test('is stable within a day', () {
      // Keyed on the day rather than a counter, so rebuilding the plan after
      // an answer does not advance it mid-session.
      final DateTime morning = DateTime.utc(2026, 3, 4, 8);
      final DateTime evening = DateTime.utc(2026, 3, 4, 21);
      expect(drillForDay(morning), drillForDay(evening));
      expect(planFor(today: morning).actions.last.id,
          planFor(today: evening).actions.last.id);
    });

    test('moves on the next day', () {
      expect(drillForDay(DateTime.utc(2026, 3, 4)),
          isNot(drillForDay(DateTime.utc(2026, 3, 5))));
    });

    test('every drill has a label and a blurb', () {
      for (final PracticeDrill drill in PracticeDrill.values) {
        expect(drill.label, isNotEmpty);
        expect(drill.blurb, isNotEmpty);
      }
    });
  });

  group('the settings', () {
    test('both default to on, so nothing is taken away by upgrading',
        () async {
      final AppController c = AppController();
      addTearDown(c.dispose);
      await c.load();
      expect(c.guidedIncludesDrills, isTrue);
      expect(c.showExploreLabs, isTrue);
    });

    test('the choice survives a restart', () async {
      final AppController first = AppController();
      addTearDown(first.dispose);
      await first.load();
      await first.setShowExploreLabs(false);
      await first.setGuidedIncludesDrills(false);
      await first.flushSave();

      final AppController second = AppController();
      addTearDown(second.dispose);
      await second.load();
      expect(second.showExploreLabs, isFalse);
      expect(second.guidedIncludesDrills, isFalse);
    });
  });
}
