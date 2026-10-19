import 'dart:async';
import 'dart:convert';

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/backup.dart';
import 'package:deutsch_garden/backup_dialogs.dart';
import 'package:deutsch_garden/civics_test.dart';
import 'package:deutsch_garden/civics_test_screens.dart';
import 'package:deutsch_garden/driving_test_screens.dart';
import 'package:deutsch_garden/driving_test.dart';
import 'package:deutsch_garden/explore_screen.dart';
import 'package:deutsch_garden/identity_screen.dart';
import 'package:deutsch_garden/l10n/app_localizations.dart';
import 'package:deutsch_garden/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'media_games_localisation_test.dart' show host, press, boot, action;

class DelayedIdentityController extends AppController {
  final gate = Completer<void>();
  int identityCalls = 0;
  @override
  Future<void> setIdentity({String? name, String? email}) async {
    identityCalls++;
    await gate.future;
    await super.setIdentity(name: name, email: email);
  }
}

class DelayedRestoreController extends AppController {
  final gate = Completer<void>();
  int restoreCalls = 0;
  @override
  Future<void> restoreFrom(Map<String, dynamic> state) async {
    restoreCalls++;
    await gate.future;
    await super.restoreFrom(state);
  }
}

Future<void> showBackupDialog(
  WidgetTester tester,
  Widget dialog, {
  String locale = 'en',
  double scale = 1,
}) async {
  await openRoute(
    tester,
    Scaffold(
      body: Builder(
        builder: (context) => FilledButton(
          onPressed: () =>
              showDialog<Object>(context: context, builder: (_) => dialog),
          child: const Text('Open backup dialog'),
        ),
      ),
    ),
    locale: locale,
    scale: scale,
  );
  await press(tester, 'Open backup dialog');
}

Future<void> openRoute(
  WidgetTester tester,
  Widget screen, {
  String locale = 'en',
  double scale = 1,
}) async {
  await tester.pumpWidget(
    host(
      Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => screen),
            ),
            child: const Text('Open test route'),
          ),
        ),
      ),
      locale: locale,
      scale: scale,
    ),
  );
  await tester.pumpAndSettle();
  await press(tester, 'Open test route');
}

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  tearDown(() => AppController.debounceWrites = true);

  testWidgets(
    'identity saves once and returns to the parent after a delayed write',
    (tester) async {
      final c = await boot(DelayedIdentityController());
      await openRoute(tester, IdentityScreen(controller: c));
      await tester.enterText(find.byType(TextField).at(0), 'Ada');
      await tester.enterText(find.byType(TextField).at(1), 'ada@example.test');
      await tester.scrollUntilVisible(
        find.text('Save'),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      final save = action(tester, 'Save');
      save();
      save();
      await tester.pump();
      expect(c.identityCalls, 1);
      expect(find.text('Saving…'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).enabled,
        isFalse,
      );
      c.gate.complete();
      await tester.pumpAndSettle();
      expect(c.learnerName, 'Ada');
      expect(c.learnerEmail, 'ada@example.test');
      expect(find.text('Open test route'), findsOneWidget);
    },
  );

  testWidgets(
    'profile email validation is translated and a valid retry saves',
    (tester) async {
      final c = await boot(AppController());
      await openRoute(tester, IdentityScreen(controller: c), locale: 'de');
      await tester.enterText(find.byType(TextField).at(1), 'invalid');
      await press(tester, 'Speichern');
      expect(
        find.text('Das sieht nicht wie eine E-Mail-Adresse aus.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField).at(1), '');
      await press(tester, 'Speichern');
      expect(find.text('Open test route'), findsOneWidget);
    },
  );

  testWidgets(
    'export copies once even when its old button callback is invoked twice',
    (tester) async {
      final gate = Completer<Object?>();
      int writes = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            writes++;
            return gate.future;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await showBackupDialog(
        tester,
        const BackupExportDialog(payload: '{"state":{}}'),
      );
      final copy = action(tester, 'Copy');
      copy();
      copy();
      await tester.pump();
      expect(writes, 1);
      gate.complete(null);
      await tester.pumpAndSettle();
      expect(find.text('Open backup dialog'), findsOneWidget);
      expect(find.byType(BackupExportDialog), findsNothing);
      copy();
      await tester.pumpAndSettle();
      expect(writes, 1);
      expect(find.text('Open backup dialog'), findsOneWidget);
    },
  );

  testWidgets('cancel during clipboard paste ignores the late result', (
    tester,
  ) async {
    final gate = Completer<Object?>();
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData' ? gate.future : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await showBackupDialog(tester, const BackupImportDialog());
    action(tester, 'Paste from clipboard')();
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    gate.complete({'text': 'late clipboard contents'});
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Open backup dialog'), findsOneWidget);
  });

  testWidgets(
    'import errors are localised and invalid metadata does not throw',
    (tester) async {
      await showBackupDialog(tester, const BackupImportDialog(), locale: 'de');
      await tester.enterText(find.byType(TextField), '{bad');
      await tester.tap(find.text('Antwort prüfen'));
      await tester.pumpAndSettle();
      final t = AppText.of(tester.element(find.byType(BackupImportDialog)));
      expect(find.text(t.settingsBackupJson), findsOneWidget);
      final invalid = jsonEncode({
        'format': ProgressBackup.magic,
        'formatVersion': 'two',
        'state': {},
      });
      await tester.enterText(find.byType(TextField), invalid);
      await tester.tap(find.text('Antwort prüfen'));
      await tester.pumpAndSettle();
      expect(find.text(t.settingsBackupWrong), findsOneWidget);
      expect(ProgressBackup.parse('').reason, BackupFailure.empty);
      expect(
        ProgressBackup.parse(
          '{"format":"deutschgarden.backup","formatVersion":1e400,"state":{}}',
        ).reason,
        BackupFailure.notBackup,
      );
      expect(
        ProgressBackup.parse(
          '{"format":"deutschgarden.backup","formatVersion":2.5,"state":{}}',
        ).reason,
        BackupFailure.notBackup,
      );
      expect(
        ProgressBackup.parse(
          jsonEncode({
            'format': ProgressBackup.magic,
            'formatVersion': 999,
            'state': {},
          }),
        ).reason,
        BackupFailure.newerFormat,
      );
      expect(
        ProgressBackup.parse(
          jsonEncode({'format': ProgressBackup.magic, 'formatVersion': 2}),
        ).reason,
        BackupFailure.missingState,
      );
      for (final field in ['exportedAt', 'platform']) {
        expect(
          ProgressBackup.parse(
            jsonEncode({
              'format': ProgressBackup.magic,
              field: [],
              'state': {},
            }),
          ).reason,
          BackupFailure.notBackup,
        );
      }
    },
  );

  testWidgets(
    'civics practice shows questions and answers after changing the filter',
    (tester) async {
      final c = await boot(AppController());
      final catalog = (await tester.runAsync(CivicsCatalog.load))!;
      await tester.pumpWidget(
        host(
          CivicsPracticeScreen(
            controller: c,
            catalog: catalog,
            stateCode: 'BE',
          ),
          locale: 'de',
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Bundesland'));
      await tester.pumpAndSettle();
      final question = catalog.stateQuestions('BE').first;
      expect(find.text(question.question), findsOneWidget);
      final answer = find.widgetWithText(ListTile, question.correctAnswer);
      await tester.scrollUntilVisible(
        answer,
        160,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(answer);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Richtig.'),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Richtig.'), findsOneWidget);
      expect(c.civicsCorrectQuestionIds, contains(question.id));
      await tester.scrollUntilVisible(
        find.widgetWithText(ChoiceChip, 'Bundesland'),
        -160,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(ChoiceChip, 'Bundesland'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Richtig.'),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Richtig.'), findsOneWidget);
    },
  );

  for (final merge in [true, false]) {
    testWidgets(
      '${merge ? 'merge' : 'replace'} import confirms once and preserves the selected semantics',
      (tester) async {
        final c = await boot(DelayedRestoreController());
        c.applyJson({...c.toBackupJson(), 'xp': 40, 'themeMode': 'dark'});
        final incoming = {...c.toBackupJson(), 'xp': 90, 'themeMode': 'light'};
        final payload = jsonEncode({
          'format': ProgressBackup.magic,
          'formatVersion': 2,
          'state': incoming,
        });
        await openRoute(tester, Scaffold(body: SettingsScreen(controller: c)));
        await press(tester, 'Import progress');
        await tester.enterText(find.byType(TextField), payload);
        await tester.tap(find.text('Check answer'));
        await tester.pumpAndSettle();
        final confirm = action(tester, merge ? 'Merge safely' : 'Replace');
        confirm();
        confirm();
        await tester.pumpAndSettle();
        expect(c.restoreCalls, 1);
        c.gate.complete();
        await tester.pumpAndSettle();
        expect(c.xp, 90);
        expect(c.themeMode, merge ? ThemeMode.dark : ThemeMode.light);
        expect(find.byType(SettingsScreen), findsOneWidget);
      },
    );
  }

  testWidgets('reset confirmation cancels without changing the profile', (
    tester,
  ) async {
    final c = await boot(AppController());
    c.applyJson({...c.toBackupJson(), 'xp': 77});
    await openRoute(tester, Scaffold(body: SettingsScreen(controller: c)));
    await press(tester, 'Reset all learning progress');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(c.xp, 77);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets(
    'Explore shows the meaning language independently of its German interface',
    (tester) async {
      final c = await boot(AppController());
      c.glossLanguage = 'tr';
      c.showExploreLabs = true;
      await tester.pumpWidget(
        host(
          Scaffold(body: ExploreScreen(controller: c)),
          locale: 'de',
        ),
      );
      await tester.pumpAndSettle();
      await press(tester, 'Übungslabore');
      await tester.scrollUntilVisible(
        find.text('Deutsch ↔ Türkçe'),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Deutsch ↔ Türkçe'), findsOneWidget);
      expect(find.text('German ↔ English'), findsNothing);
    },
  );

  for (final page in ['settings', 'statistics', 'speaking']) {
    testWidgets(
      '$page route title updates when the interface language changes',
      (tester) async {
        final c = await boot(AppController());
        await tester.pumpWidget(
          AnimatedBuilder(
            animation: c,
          builder: (_, _) => host(
              Scaffold(
                body: page == 'speaking'
                    ? ExploreScreen(controller: c)
                    : ProfileScreen(controller: c),
              ),
              locale: c.uiLocale?.languageCode ?? 'en',
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (page == 'speaking') {
          await press(tester, 'A1 libraries');
          await press(tester, 'Speaking studio');
        } else {
          await press(
            tester,
            page == 'settings' ? 'Settings' : 'Detailed progress',
          );
        }
        await c.setUiLocale(const Locale('de'));
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(AppBar, switch (page) {
            'settings' => 'Einstellungen',
            'statistics' => 'Fortschritt',
            _ => 'Sprechstudio',
          }),
          findsOneWidget,
        );
      },
    );
  }

  for (final name in ['export', 'import', 'choice']) {
    testWidgets(
      '$name backup dialog fits large German text in a short narrow window',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 480));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final dialog = switch (name) {
          'export' => BackupExportDialog(
            payload: '{\n${'"large backup": 123,\n' * 150}}',
          ),
          'import' => const BackupImportDialog(),
          _ => ProfileChoiceDialog<bool>(
            title: 'Importierten Fortschritt zusammenführen?',
            body: 'Lange Sicherungsinformationen. ' * 30,
            choices: [
              ProfileDialogChoice('Abbrechen', false),
              ProfileDialogChoice('Sicher zusammenführen', true, primary: true),
            ],
          ),
        };
        await showBackupDialog(tester, dialog, locale: 'de', scale: 1.5);
        expect(tester.takeException(), isNull);
        if (name == 'import') {
          await tester.enterText(find.byType(TextField), 'invalid');
          await tester.tap(find.text('Antwort prüfen'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        await tester.tap(
          find.text(name == 'export' ? 'Schließen' : 'Abbrechen'),
        );
        await tester.pumpAndSettle();
        expect(find.text('Open backup dialog'), findsOneWidget);
      },
    );
  }

  for (final page in [
    'settings',
    'statistics',
    'profile',
    'achievements',
    'explore',
    'identity',
    'civics practice',
    'driving practice',
    'civics mock',
    'driving mock',
    'civics hub',
    'driving hub',
    'civics result',
    'driving result',
  ]) {
    testWidgets('$page fits a narrow German screen at 150 percent text', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final c = await boot(AppController());
      final catalog = page.startsWith('civics')
          ? (await tester.runAsync(CivicsCatalog.load))!
          : null;
      final Widget screen = switch (page) {
        'settings' => Scaffold(body: SettingsScreen(controller: c)),
        'statistics' => Scaffold(body: StatsScreen(controller: c)),
        'profile' => Scaffold(body: ProfileScreen(controller: c)),
        'achievements' => AchievementsScreen(controller: c),
        'explore' => Scaffold(body: ExploreScreen(controller: c)),
        'identity' => IdentityScreen(controller: c),
        'civics practice' => CivicsPracticeScreen(
          controller: c,
          catalog: catalog!,
          stateCode: 'BE',
        ),
        'driving practice' => DrivingPracticeScreen(controller: c),
        'civics mock' => CivicsMockScreen(
          controller: c,
          catalog: catalog!,
          stateCode: 'BE',
          kind: CivicsTestKind.lebenInDeutschland,
          seed: 19,
        ),
        'driving mock' => DrivingMockScreen(controller: c),
        'civics hub' => CivicsHubScreen(controller: c),
        'civics result' => CivicsResultScreen(
          controller: c,
          catalog: catalog!,
          stateCode: 'BE',
          kind: CivicsTestKind.lebenInDeutschland,
          result: const CivicsTestResult(correct: 14, total: 33),
          review: [
            CivicsReviewItem(
              question: catalog.questions.first,
              selectedIndex: null,
            ),
          ],
          timedOut: true,
        ),
        'driving result' => DrivingResultScreen(
          result: const DrivingTestResult(
            correct: 0,
            total: 30,
            errorPoints: 110,
            fivePointErrors: 6,
          ),
          review: [
            DrivingReviewItem(
              question: DrivingTheoryCatalog.questions.first,
              selectedIndex: null,
            ),
          ],
          timedOut: true,
        ),
        _ => DrivingTheoryScreen(controller: c),
      };
      await tester.pumpWidget(host(screen, locale: 'de', scale: 1.5));
      await tester.pumpAndSettle();
      if (page == 'civics hub') {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      for (int i = 0; i < 24; i++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -450));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '$page after scrolling $i',
        );
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  }

  for (final civics in [true, false]) {
    final name = civics ? 'civics' : 'driving';
    testWidgets(
      '$name submits once when the confirmation callback is repeated',
      (tester) async {
        final c = await boot(AppController());
        final catalog = civics
            ? (await tester.runAsync(CivicsCatalog.load))!
            : null;
        final screen = civics
            ? CivicsMockScreen(
                controller: c,
                catalog: catalog!,
                stateCode: 'BE',
                kind: CivicsTestKind.lebenInDeutschland,
                seed: 19,
              )
            : DrivingMockScreen(controller: c);
        await openRoute(tester, screen);
        await press(tester, civics ? '33' : '30');
        await press(tester, 'Submit');
        final submit = tester
            .widget<FilledButton>(
              find.descendant(
                of: find.byType(AlertDialog),
                matching: find.byType(FilledButton),
              ),
            )
            .onPressed!;
        submit();
        submit();
        await tester.pumpAndSettle();
        expect(
          find.byType(civics ? CivicsResultScreen : DrivingResultScreen),
          findsOneWidget,
        );
        if (civics) expect(c.civicsTestsCompleted, 1);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Open test route'), findsOneWidget);
      },
    );

    testWidgets(
      '$name timeout closes its confirmation and replaces the test route',
      (tester) async {
        final c = await boot(AppController());

        final catalog = civics
            ? (await tester.runAsync(CivicsCatalog.load))!
            : null;

        final screen = civics
            ? CivicsMockScreen(
                controller: c,
                catalog: catalog!,
                stateCode: 'BE',
                kind: CivicsTestKind.lebenInDeutschland,
                seed: 19,
                duration: const Duration(seconds: 20),
              )
            : DrivingMockScreen(
                controller: c,
                duration: const Duration(seconds: 20),
              );
        await openRoute(tester, screen);

        await press(tester, civics ? '33' : '30');

        await press(tester, 'Submit');
        expect(find.text('Submit mock?'), findsOneWidget);
        await tester.pump(const Duration(seconds: 21));

        await tester.pumpAndSettle();
        expect(
          find.byType(civics ? CivicsResultScreen : DrivingResultScreen),
          findsOneWidget,
        );
        if (civics) expect(c.civicsTestsCompleted, 1);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Open test route'), findsOneWidget);
        expect(
          find.byType(civics ? CivicsMockScreen : DrivingMockScreen),
          findsNothing,
        );
      },
    );

    testWidgets('$name opens one confirmation for repeated submit taps', (
      tester,
    ) async {
      final c = await boot(AppController());
      final catalog = civics
          ? (await tester.runAsync(CivicsCatalog.load))!
          : null;
      final screen = civics
          ? CivicsMockScreen(
              controller: c,
              catalog: catalog!,
              stateCode: 'BE',
              kind: CivicsTestKind.lebenInDeutschland,
              seed: 19,
            )
          : DrivingMockScreen(controller: c);
      await openRoute(tester, screen);
      await press(tester, civics ? '33' : '30');
      final submit = action(tester, 'Submit');
      submit();
      submit();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
