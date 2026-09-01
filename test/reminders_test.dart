import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/reminders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

final class FakeReminders implements Reminders {
  FakeReminders({this.supported = true, this.permission = true});

  final bool supported;
  final bool permission;
  int permissionRequests = 0;
  int cancellations = 0;
  final List<ReminderPlan> scheduled = <ReminderPlan>[];

  @override
  bool get isSupported => supported;

  @override
  Future<void> initialise() async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequests += 1;
    return permission;
  }

  @override
  Future<void> schedule(ReminderPlan plan) async => scheduled.add(plan);

  @override
  Future<void> cancel() async => cancellations += 1;
}

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'reminders are opt-in, persisted and scheduled only after permission',
    () async {
      final AppController controller = AppController();
      addTearDown(controller.dispose);
      final FakeReminders fake = FakeReminders();
      controller.reminders = fake;

      expect(controller.remindersEnabled, isFalse);
      expect(await controller.setRemindersEnabled(true), isTrue);
      expect(fake.permissionRequests, 1);
      expect(fake.scheduled, hasLength(1));
      expect(controller.toJson()['remindersEnabled'], isTrue);

      await controller.setReminderTime(7, 35);
      expect(fake.scheduled.last.hour, 7);
      expect(fake.scheduled.last.minute, 35);
      expect(controller.toJson()['reminderHour'], 7);
      expect(controller.toJson()['reminderMinute'], 35);

      await controller.setDailyMinuteGoal(30);
      await controller.setWeeklyMinuteGoal(210);
      expect(fake.scheduled.last.dailyMinuteGoal, 30);
      expect(fake.scheduled.last.weeklyMinuteGoal, 210);
      expect(controller.toJson()['dailyMinuteGoal'], 30);
      expect(controller.toJson()['weeklyMinuteGoal'], 210);

      expect(await controller.setRemindersEnabled(false), isTrue);
      expect(fake.cancellations, 1);
    },
  );

  test(
    'denied permission leaves the setting off and schedules nothing',
    () async {
      final AppController controller = AppController();
      addTearDown(controller.dispose);
      final FakeReminders fake = FakeReminders(permission: false);
      controller.reminders = fake;

      expect(await controller.setRemindersEnabled(true), isFalse);
      expect(controller.remindersEnabled, isFalse);
      expect(fake.scheduled, isEmpty);
    },
  );

  test('unsupported platforms never display a fake working setting', () async {
    final AppController controller = AppController();
    addTearDown(controller.dispose);
    final FakeReminders fake = FakeReminders(supported: false);
    controller.reminders = fake;

    expect(controller.remindersSupported, isFalse);
    expect(await controller.setRemindersEnabled(true), isFalse);
    expect(fake.permissionRequests, 0);
  });

  test('reminder copy reports personal daily and weekly progress', () {
    const ReminderPlan plan = ReminderPlan(
      hour: 19,
      minute: 0,
      dueCount: 3,
      minutesToday: 12,
      dailyMinuteGoal: 20,
      minutesThisWeek: 95,
      weeklyMinuteGoal: 150,
    );

    expect(plan.dailyBody, contains('Noch 8 Min.'));
    expect(plan.dailyBody, contains('3 Wiederholungen'));
    expect(plan.weeklyBody, contains('Noch 55 Min.'));
    expect(plan.weeklyBody, contains('Heute: 12/20'));
  });

  test('completed time targets are celebrated without inventing due work', () {
    const ReminderPlan plan = ReminderPlan(
      hour: 19,
      minute: 0,
      dueCount: 0,
      minutesToday: 25,
      dailyMinuteGoal: 20,
      minutesThisWeek: 170,
      weeklyMinuteGoal: 150,
    );

    expect(plan.dailyBody, contains('Tagesziel geschafft'));
    expect(plan.dailyBody, contains('Nichts ist fällig'));
    expect(plan.weeklyBody, contains('Wochenziel geschafft'));
  });
}
