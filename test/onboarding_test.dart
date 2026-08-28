import 'package:deutsch_garden/app.dart';
import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/onboarding_screen.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() async {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await loadVocabIconIndex(rootBundle);
  });

  Future<AppController> boot(WidgetTester tester) async {
    final AppController c = AppController();
    addTearDown(c.dispose);
    await c.load();
    await tester.pumpWidget(DeutschGardenApp(controller: c));
    await tester.pumpAndSettle();
    return c;
  }

  testWidgets('a first run opens on the intro, not on the app',
      (WidgetTester tester) async {
    await boot(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Willkommen'), findsOneWidget);
    // No bottom bar behind it: the learner has had nothing explained yet.
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('it says the two things a learner cannot discover by looking',
      (WidgetTester tester) async {
    await boot(tester);
    // That it is offline and account-free, and that progress is local and
    // therefore worth exporting. Both are invisible from the interface and
    // both change what someone does.
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.textContaining('No account'), findsOneWidget);
    expect(find.textContaining('Export'), findsOneWidget);
  });

  testWidgets('skipping lets the app through and is remembered',
      (WidgetTester tester) async {
    final AppController c = await boot(tester);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(c.onboardingDone, isTrue);
  });

  testWidgets('walking to the end lets the app through',
      (WidgetTester tester) async {
    final AppController c = await boot(tester);

    for (int i = 0; i < 3; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.widgetWithText(FilledButton, 'Los geht’s'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(c.onboardingDone, isTrue);
  });

  testWidgets('it is not shown again after a restart',
      (WidgetTester tester) async {
    final AppController first = await boot(tester);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await first.flushSave();

    final AppController second = AppController();
    addTearDown(second.dispose);
    await second.load();
    expect(second.onboardingDone, isTrue,
        reason: 'the flag is flushed rather than debounced, so being killed '
            'straight after the intro does not replay it');

    await tester.pumpWidget(DeutschGardenApp(controller: second));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('an existing profile from before onboarding sees it once',
      (WidgetTester tester) async {
    // Defaulting the flag to true for old profiles would silently skip the
    // intro for everyone who already had the app. The mild annoyance of
    // showing it to them is the better error.
    final AppController c = AppController();
    addTearDown(c.dispose);
    await c.load();
    await c.restoreFrom(<String, dynamic>{'xp': 4200, 'streak': 30});
    expect(c.onboardingDone, isFalse);

    await tester.pumpWidget(DeutschGardenApp(controller: c));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
