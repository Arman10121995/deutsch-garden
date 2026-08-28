import 'dart:convert';

import 'package:deutsch_garden/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const String kStateKey = 'deutsch_garden_state_v4';

/// Counts what actually reaches the storage backend, which is the thing the
/// debounce exists to reduce. Asserting on the controller's own bookkeeping
/// would only prove the bookkeeping.
final class CountingPrefs extends InMemorySharedPreferencesAsync {
  CountingPrefs() : super.empty();

  int writes = 0;

  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) {
    writes += 1;
    return super.setString(key, value, options);
  }
}

void main() {
  late CountingPrefs platform;

  setUp(() {
    // This file is the one that exercises the real deferral path.
    AppController.debounceWrites = true;
    platform = CountingPrefs();
    SharedPreferencesAsyncPlatform.instance = platform;
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('a burst of mutations becomes one write, not one write each',
      (WidgetTester tester) async {
    final AppController controller = AppController();
    await controller.load();
    platform.writes = 0;

    // Twelve mutations in the time a learner takes to answer one card.
    for (int i = 0; i < 12; i++) {
      await controller.setDailyGoal(20 + i);
    }
    expect(controller.hasPendingSave, isTrue,
        reason: 'the write should still be waiting to be coalesced');
    expect(platform.writes, 0,
        reason: 'nothing should have reached disk yet');

    await tester.pump(AppController.saveDebounce);
    await tester.pump(Duration.zero);

    expect(platform.writes, 1,
        reason: '12 mutations should coalesce into a single write');

    controller.dispose();
  });

  testWidgets('the coalesced write stores the last value, not the first',
      (WidgetTester tester) async {
    final AppController controller = AppController();
    await controller.load();

    for (int i = 0; i < 5; i++) {
      await controller.setDailyGoal(30 + i);
    }
    await controller.flushSave();

    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final Map<String, dynamic> saved =
        jsonDecode((await prefs.getString(kStateKey))!)
            as Map<String, dynamic>;
    expect(saved['dailyGoal'], 34);

    controller.dispose();
  });

  testWidgets('a steady stream of answers cannot defer the write forever',
      (WidgetTester tester) async {
    final AppController controller = AppController();
    await controller.load();
    platform.writes = 0;

    // Each mutation restarts the debounce. Without a ceiling on the deferral
    // this loop would never write, and a crash would cost the whole session.
    final DateTime start = DateTime.now();
    while (DateTime.now().difference(start) < AppController.saveMaxDeferral) {
      await controller.setDailyGoal(20);
    }
    await controller.setDailyGoal(21);
    await tester.pump(Duration.zero);

    expect(platform.writes, greaterThanOrEqualTo(1),
        reason: 'the deferral ceiling should have forced a write through');

    await controller.flushSave();
    controller.dispose();
  });

  testWidgets('backgrounding the app flushes what the debounce is holding',
      (WidgetTester tester) async {
    final AppController controller = AppController();
    await controller.load();
    await controller.setDailyGoal(42);
    platform.writes = 0;
    expect(controller.hasPendingSave, isTrue);

    // What AppLifecycleListener calls when the app leaves the foreground.
    await controller.flushSave();

    expect(platform.writes, 1);
    expect(controller.hasPendingSave, isFalse);

    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final Map<String, dynamic> saved =
        jsonDecode((await prefs.getString(kStateKey))!)
            as Map<String, dynamic>;
    expect(saved['dailyGoal'], 42,
        reason: 'the pending answer must survive being backgrounded');

    controller.dispose();
  });

  testWidgets('a restore is durable immediately, without waiting',
      (WidgetTester tester) async {
    final AppController controller = AppController();
    await controller.load();

    await controller.restoreFrom(<String, dynamic>{'dailyGoal': 77});

    // No pump: restoreFrom must not be subject to the debounce, because
    // callers read the stored blob straight afterwards.
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final Map<String, dynamic> saved =
        jsonDecode((await prefs.getString(kStateKey))!)
            as Map<String, dynamic>;
    expect(saved['dailyGoal'], 77);

    controller.dispose();
  });
}
