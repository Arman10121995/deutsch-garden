import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/backup.dart';
import 'package:deutsch_garden/clock.dart';
import 'package:deutsch_garden/study_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class WindingClock {
  WindingClock(this.at);
  DateTime at;
  AppClock get clock => AppClock(read: () => at);
}

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('an interval crossing midnight is credited to both calendar days', () {
    final StudyInterval interval = StudyInterval(
      startedAt: DateTime(2026, 8, 31, 23, 50),
      endedAt: DateTime(2026, 9, 1, 0, 20),
      activity: 'Story',
    );
    expect(
      studyDurationOnDay(<StudyInterval>[interval], DateTime(2026, 8, 31)),
      const Duration(minutes: 10),
    );
    expect(
      studyDurationOnDay(<StudyInterval>[interval], DateTime(2026, 9, 1)),
      const Duration(minutes: 20),
    );
  });

  test('nested activities never double-count their parent', () async {
    final WindingClock winding = WindingClock(DateTime(2026, 9, 1, 10));
    final AppController controller = AppController()..clock = winding.clock;
    addTearDown(controller.dispose);
    await controller.load();

    controller.beginStudyActivity('Story');
    winding.at = DateTime(2026, 9, 1, 10, 10);
    controller.beginStudyActivity('Story quiz');
    winding.at = DateTime(2026, 9, 1, 10, 15);
    controller.endStudyActivity('Story quiz');
    winding.at = DateTime(2026, 9, 1, 10, 20);
    controller.endStudyActivity('Story');

    expect(controller.studyMinutesToday, 20);
    expect(
      controller.studyIntervals.map((StudyInterval i) => i.activity),
      <String>['Story', 'Story quiz', 'Story'],
    );
  });

  test('background time is excluded and intervals survive restart', () async {
    final WindingClock winding = WindingClock(DateTime(2026, 9, 1, 9));
    final AppController first = AppController()..clock = winding.clock;
    await first.load();
    first.beginStudyActivity('Vocabulary');
    winding.at = DateTime(2026, 9, 1, 9, 12);
    await first.prepareForBackground();
    winding.at = DateTime(2026, 9, 1, 12);
    first.resumeStudyTracking();
    winding.at = DateTime(2026, 9, 1, 12, 8);
    first.endStudyActivity('Vocabulary');
    await first.flushSave();
    first.dispose();

    final AppController second = AppController()..clock = winding.clock;
    addTearDown(second.dispose);
    await second.load();
    expect(second.studyMinutesToday, 20);
    expect(second.studyIntervals, hasLength(2));
  });

  test('backup merge de-duplicates identical study intervals', () {
    final Map<String, dynamic> interval = StudyInterval(
      startedAt: DateTime(2026, 9, 1, 9),
      endedAt: DateTime(2026, 9, 1, 9, 10),
      activity: 'Grammar',
    ).toJson();
    final Map<String, dynamic> merged = ProgressBackup.merge(
      <String, dynamic>{
        'studyIntervals': <Object>[interval],
      },
      <String, dynamic>{
        'studyIntervals': <Object>[interval],
      },
    );
    expect(merged['studyIntervals'], hasLength(1));
  });

  test(
    'overlapping exported snapshots count once and merge to the longest',
    () {
      final StudyInterval short = StudyInterval(
        startedAt: DateTime(2026, 9, 1, 9),
        endedAt: DateTime(2026, 9, 1, 9, 10),
        activity: 'Grammar',
      );
      final StudyInterval long = StudyInterval(
        startedAt: DateTime(2026, 9, 1, 9),
        endedAt: DateTime(2026, 9, 1, 9, 18),
        activity: 'Grammar',
      );

      expect(
        studyDurationOnDay(<StudyInterval>[short, long], DateTime(2026, 9, 1)),
        const Duration(minutes: 18),
      );
      final Map<String, dynamic> merged = ProgressBackup.merge(
        <String, dynamic>{
          'studyIntervals': <Object>[short.toJson()],
        },
        <String, dynamic>{
          'studyIntervals': <Object>[long.toJson()],
        },
      );
      expect(merged['studyIntervals'], hasLength(1));
      expect(
        StudyInterval.fromJson(
          (merged['studyIntervals'] as List).single,
        )!.duration,
        const Duration(minutes: 18),
      );
    },
  );
}
