import 'dart:async';
import 'dart:convert';

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/startup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class DelayedStartupController extends AppController {
  DelayedStartupController(this.completion);
  final Future<void> completion;
  @override
  Future<void> load() => completion;
}

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'startup draws while storage is pending and never retries it concurrently',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final pending = Completer<void>();
      var loads = 0;
      await tester.pumpWidget(
        GardenStartup(
          createController: () {
            loads++;
            return DelayedStartupController(pending.future);
          },
          loadIcons: () async {},
        ),
      );
      expect(find.text('Opening your garden…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 13));
      expect(find.textContaining('taking longer than usual'), findsOneWidget);
      expect(find.textContaining('Keep the app data'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
      expect(loads, 1);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.text('Opening your garden…'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets(
    'failed storage opens a recovery screen and retry preserves the profile',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final prefs = SharedPreferencesAsync();
      const key = 'deutsch_garden_state_v4';
      final original = jsonEncode({'xp': 987, 'onboardingDone': true});
      await prefs.setString(key, original);
      var calls = 0;
      AppController? restored;
      await tester.pumpWidget(
        GardenStartup(
          createController: () {
            calls++;
            if (calls == 1) {
              return DelayedStartupController(
                Future<void>.error(
                  PlatformException(
                    code: 'storage_unavailable',
                    message: 'private-profile-content',
                  ),
                ),
              );
            }
            return restored = AppController();
          },
          loadIcons: () async {},
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Your saved progress could not be opened.'),
        findsOneWidget,
      );
      expect(find.text('Startup detail: PlatformException'), findsOneWidget);
      expect(find.textContaining('private-profile-content'), findsNothing);
      expect(await prefs.getString(key), original);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Learn German'), findsOneWidget);
      expect(restored!.xp, 987);
      expect(calls, 2);
      expect(jsonDecode((await prefs.getString(key))!)['xp'], 987);
      await tester.pumpWidget(const SizedBox());
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('a hung optional illustration index cannot block launch', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final icons = Completer<void>();
    await tester.pumpWidget(
      GardenStartup(
        createController: AppController.new,
        loadIcons: () => icons.future,
      ),
    );
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Opening your garden…'), findsNothing);
    expect(find.text('Your saved progress could not be opened.'), findsNothing);
    icons.complete();
    await tester.pumpWidget(const SizedBox());
    debugDefaultTargetPlatformOverride = null;
  });
}
