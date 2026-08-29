import 'package:deutsch_garden/app.dart';
import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/l10n/app_localizations.dart';
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

  Future<AppController> boot(WidgetTester tester, {Locale? locale}) async {
    final AppController c = AppController();
    addTearDown(c.dispose);
    await c.load();
    if (locale != null) await c.setUiLocale(locale);
    await tester.pumpWidget(DeutschGardenApp(controller: c));
    await tester.pumpAndSettle();
    return c;
  }

  group('the interface language', () {
    testWidgets('defaults to English chrome', (WidgetTester tester) async {
      final AppController c = await boot(tester);
      await c.completeOnboarding();
      await tester.pumpAndSettle();

      expect(find.text('Learn'), findsWidgets);
      expect(find.text('Explore'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('switches the shell when set to German',
        (WidgetTester tester) async {
      final AppController c = await boot(tester, locale: const Locale('de'));
      await c.completeOnboarding();
      await tester.pumpAndSettle();

      expect(find.text('Lernen'), findsWidgets);
      expect(find.text('Entdecken'), findsWidgets);
      expect(find.text('Profil'), findsWidgets);
      expect(find.text('Learn'), findsNothing);
    });

    testWidgets('switches the intro too', (WidgetTester tester) async {
      await boot(tester, locale: const Locale('de'));
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Willkommen'), findsOneWidget);
      expect(find.textContaining('Kein Konto'), findsNothing,
          reason: 'that line is on the second page, not the first');
      expect(find.widgetWithText(FilledButton, 'Weiter'), findsOneWidget);
    });

    testWidgets('the choice survives a restart', (WidgetTester tester) async {
      final AppController first = await boot(tester, locale: const Locale('de'));
      await first.flushSave();

      final AppController second = AppController();
      addTearDown(second.dispose);
      await second.load();
      expect(second.uiLocale, const Locale('de'));
    });

    testWidgets('following the device is stored as no choice at all',
        (WidgetTester tester) async {
      final AppController c = await boot(tester, locale: const Locale('de'));
      await c.setUiLocale(null);
      await c.flushSave();

      final AppController second = AppController();
      addTearDown(second.dispose);
      await second.load();
      expect(second.uiLocale, isNull,
          reason: 'null means follow the device, and must not be persisted '
              'as a language code');
    });
  });

  group('the strings themselves', () {
    testWidgets('German keeps the words the learner is meant to read as German',
        (WidgetTester tester) async {
      // A handful of strings are German in every locale, because they are the
      // language being taught rather than interface chrome.
      late AppText en;
      late AppText de;
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppText.supportedLocales,
        localizationsDelegates: AppText.localizationsDelegates,
        home: Builder(builder: (BuildContext context) {
          en = AppText.of(context);
          return const SizedBox();
        }),
      ));
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('de'),
        supportedLocales: AppText.supportedLocales,
        localizationsDelegates: AppText.localizationsDelegates,
        home: Builder(builder: (BuildContext context) {
          de = AppText.of(context);
          return const SizedBox();
        }),
      ));

      expect(en.actionUnderstood, 'Verstanden');
      expect(de.actionUnderstood, 'Verstanden');
      expect(en.actionStart, de.actionStart);
      expect(en.appTitle, de.appTitle);
    });

    testWidgets('plurals are not one string with an "s" bolted on',
        (WidgetTester tester) async {
      late AppText text;
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('de'),
        supportedLocales: AppText.supportedLocales,
        localizationsDelegates: AppText.localizationsDelegates,
        home: Builder(builder: (BuildContext context) {
          text = AppText.of(context);
          return const SizedBox();
        }),
      ));

      expect(text.reviewDueToday(0), 'Nichts fällig');
      expect(text.reviewDueToday(1), '1 Karte fällig');
      expect(text.reviewDueToday(7), '7 Karten fällig');
    });
  });
}
