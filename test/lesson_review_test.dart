import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/lesson_registry.dart';
import 'package:deutsch_garden/models.dart';
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

  group('lesson registry', () {
    test('flattens every skill track across every level', () {
      // Asserting the composition rather than a frozen total: a hardcoded
      // number turns every content addition into a failing test, which trains
      // people to edit the number instead of reading it.
      final Map<SkillType, int> bySkill = <SkillType, int>{};
      for (final LessonRef lesson in allLessons) {
        bySkill[lesson.skill] = (bySkill[lesson.skill] ?? 0) + 1;
      }
      expect(bySkill[SkillType.grammar], greaterThanOrEqualTo(96));
      expect(bySkill[SkillType.listening], greaterThanOrEqualTo(36));
      expect(bySkill[SkillType.reading], greaterThanOrEqualTo(36));
      expect(bySkill[SkillType.writing], greaterThanOrEqualTo(36));
      expect(bySkill[SkillType.speaking], greaterThanOrEqualTo(18));
      expect(allLessons.length,
          bySkill.values.fold<int>(0, (int a, int b) => a + b),
          reason: 'every lesson must belong to exactly one track');
    });

    test('every lesson id is unique', () {
      final Set<String> ids =
          allLessons.map((LessonRef lesson) => lesson.id).toSet();
      expect(ids.length, allLessons.length);
    });

    test('covers all five reviewable skills', () {
      final Set<SkillType> skills =
          allLessons.map((LessonRef lesson) => lesson.skill).toSet();
      expect(skills, <SkillType>{
        SkillType.grammar,
        SkillType.listening,
        SkillType.reading,
        SkillType.writing,
        SkillType.speaking,
      });
    });

    test('resolves a known id and rejects an unknown one', () {
      final LessonRef first = allLessons.first;
      expect(lessonForId(first.id)?.title, first.title);
      expect(lessonForId('not-a-lesson'), isNull);
    });

    test('resolving a mixed id list drops non-lessons but keeps order', () {
      final String a = allLessons[0].id;
      final String b = allLessons[1].id;
      final List<LessonRef> resolved =
          lessonsForIds(<String>[a, 'story-chapter-1', b]);
      expect(resolved.map((LessonRef l) => l.id), <String>[a, b]);
    });
  });

  group('lessons enter the review rotation', () {
    test('a passed lesson is scheduled, a failed one is not completed', () async {
      final AppController controller = AppController();
      await controller.load();

      await controller.recordActivity('gr-a1-01', score: 90);
      final ActivityProgress passed =
          controller.progressForActivity('gr-a1-01');
      expect(passed.completed, isTrue);
      // Scheduled into the future rather than left at the epoch.
      expect(passed.dueAt.isAfter(DateTime.now()), isTrue);
      expect(passed.reps, greaterThan(0));

      await controller.recordActivity('gr-a1-02', score: 20);
      final ActivityProgress failed =
          controller.progressForActivity('gr-a1-02');
      expect(failed.completed, isFalse);
    });

    test('a higher score earns a longer interval than a bare pass', () async {
      final AppController controller = AppController();
      await controller.load();

      await controller.recordActivity('gr-a1-01', score: 100);
      await controller.recordActivity('gr-a1-02', score: 70);

      final ActivityProgress easy = controller.progressForActivity('gr-a1-01');
      final ActivityProgress hard = controller.progressForActivity('gr-a1-02');
      expect(easy.dueAt.isAfter(hard.dueAt), isTrue);
    });

    test('a lesson is not due the moment it is passed', () async {
      final AppController controller = AppController();
      await controller.load();

      await controller.recordActivity('gr-a1-01', score: 90);

      expect(controller.dueActivityIds, isNot(contains('gr-a1-01')));
      expect(controller.dueActivityCount, 0);
    });

    test('an unfinished lesson never appears in the review queue', () async {
      final AppController controller = AppController();
      await controller.load();

      await controller.recordActivity('gr-a1-03', score: 10);

      expect(controller.dueActivityIds, isEmpty);
    });

    test('a lesson that comes due is reported, oldest first', () async {
      final AppController controller = AppController();
      await controller.load();

      await controller.recordActivity('gr-a1-01', score: 90);
      await controller.recordActivity('gr-a1-02', score: 90);

      // Force both into the past, the older one further back.
      controller.progressForActivity('gr-a1-01').dueAt =
          DateTime.now().subtract(const Duration(days: 5));
      controller.progressForActivity('gr-a1-02').dueAt =
          DateTime.now().subtract(const Duration(days: 1));

      expect(controller.dueActivityIds, <String>['gr-a1-01', 'gr-a1-02']);
      expect(controller.dueActivityCount, 2);
    });

    test('failing a review counts as a lapse', () async {
      final AppController controller = AppController();
      await controller.load();

      await controller.recordActivity('gr-a1-01', score: 90);
      expect(controller.progressForActivity('gr-a1-01').lapses, 0);

      // bestScore stays high, but this attempt was a failure.
      await controller.recordActivity('gr-a1-01', score: 30);
      expect(controller.progressForActivity('gr-a1-01').lapses, 1);
    });
  });

  group('upgrading an existing profile', () {
    test('lessons passed before scheduling are spread, not dumped at once',
        () async {
      final AppController controller = AppController();
      await controller.load();

      // Simulate a pre-upgrade profile: passed lessons with an epoch due date.
      for (int i = 0; i < 40; i++) {
        final ActivityProgress p =
            controller.progressForActivity(allLessons[i].id);
        p.completed = true;
        p.bestScore = 80;
        p.dueAt = DateTime.fromMillisecondsSinceEpoch(0);
      }
      // Everything would be due right now without staggering.
      expect(controller.dueActivityCount, 40);

      // A reload runs the migration.
      final bool changed = controller.debugStaggerUnscheduledActivities();

      expect(changed, isTrue);
      expect(controller.dueActivityCount, 0,
          reason: 'nothing should be due immediately after staggering');

      final Set<int> horizons = <int>{};
      for (int i = 0; i < 40; i++) {
        horizons.add(controller.progressForActivity(allLessons[i].id).intervalDays);
      }
      // Spread across a fortnight rather than all on one day.
      expect(horizons.length, greaterThan(1));
      expect(horizons.reduce((a, b) => a > b ? a : b), lessThanOrEqualTo(14));
    });

    test('staggering is a no-op when there is nothing to stagger', () async {
      final AppController controller = AppController();
      await controller.load();
      expect(controller.debugStaggerUnscheduledActivities(), isFalse);
    });
  });
}
