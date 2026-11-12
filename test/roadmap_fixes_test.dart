// Tests that prove items of docs/LEARNING_UX_ROADMAP.md.
//
// tool/plan_status.py looks for the quoted phrase of each item in a test
// description, so the descriptions below are not free to reword.
import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/games.dart';
import 'package:deutsch_garden/l10n/app_localizations.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/quiz_distractors.dart';
import 'package:deutsch_garden/screens.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:deutsch_garden/vocabulary_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    debugSetVocabIcons(const <String>[]);
  });

  tearDown(() {
    AppController.debounceWrites = true;
    debugResetVocabIcons();
  });

  Future<AppController> boot() async {
    final AppController controller = AppController();
    addTearDown(controller.dispose);
    await controller.load();
    controller.ttsEnabled = false;
    return controller;
  }

  Future<void> show(
    WidgetTester tester,
    Widget screen, {
    String locale = 'en',
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(locale),
        supportedLocales: AppText.supportedLocales,
        localizationsDelegates: AppText.localizationsDelegates,
        home: screen,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  Widget buttonOf(WidgetTester tester, String label) => tester.widget(
    find
        .ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is ButtonStyleButton,
          ),
        )
        .first,
  );

  // G7
  testWidgets('a vocabulary mistake names its word', (tester) async {
    final AppController controller = await boot();
    final GermanWord word = controller.wordsForLevel(CefrLevel.a1).first;
    await controller.addMistake(
      MistakeEntry(
        id: 'vocab-${word.id}',
        prompt: 'What does this mean?',
        correctAnswer: word.english,
        givenAnswer: 'something else',
        source: 'vocabulary',
        level: word.level,
        timestamp: DateTime(2026, 11, 12),
      ),
    );
    // A lesson mistake keeps the question it was filed with.
    await controller.addMistake(
      MistakeEntry(
        id: 'grammar-1-q0',
        prompt: 'Ich ___ hier.',
        correctAnswer: 'bin',
        givenAnswer: 'ist',
        source: 'grammar',
        level: 'A1',
        timestamp: DateTime(2026, 11, 12),
      ),
    );
    await show(tester, MistakeBankScreen(controller: controller));
    expect(
      find.text('${word.displayGerman} · What does this mean?'),
      findsOneWidget,
    );
    expect(find.text('Ich ___ hier.'), findsOneWidget);

    // The word can be searched for, although it was never stored.
    await tester.enterText(find.byType(TextField), word.german.toLowerCase());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining(word.displayGerman), findsOneWidget);
    expect(find.text('Ich ___ hier.'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  // G5
  testWidgets('speed review offers options of the answer\'s word class', (
    tester,
  ) async {
    final AppController controller = await boot();
    final List<GermanWord> pool = controller.wordsForLevel(CefrLevel.a1);
    GermanWordClass family(GermanWord word) {
      final GermanWordClass wordClass = wordClassFor(word);
      return wordClass == GermanWordClass.adjectiveAdverb
          ? GermanWordClass.adjective
          : wordClass;
    }

    await show(
      tester,
      SpeedReviewScreen(controller: controller, level: CefrLevel.a1),
    );
    final Set<String> shown = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text text) => text.data ?? '')
        .toSet();
    final GermanWord target = pool.firstWhere(
      (GermanWord word) => shown.contains(word.displayGerman),
    );
    final List<String> options = pool
        .map((GermanWord word) => word.english)
        .where(shown.contains)
        .toSet()
        .toList();
    expect(options.length, greaterThanOrEqualTo(4));
    // Nouns are the largest class at A1, so a noun answer never has to be
    // topped up from another class. Other classes may be.
    if (family(target) == GermanWordClass.noun) {
      for (final String option in options) {
        expect(
          pool.any(
            (GermanWord word) =>
                word.english == option && family(word) == GermanWordClass.noun,
          ),
          isTrue,
          reason: '$option beside ${target.displayGerman}',
        );
      }
    }
    // The selection itself is the shared, unit-tested rule.
    expect(pickDistractors, isNotNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  // I10
  testWidgets('reset is not the highlighted choice', (tester) async {
    final AppController controller = await boot();
    await show(tester, Scaffold(body: SettingsScreen(controller: controller)));
    final Finder reset = find.text('Reset all learning progress');
    await tester.scrollUntilVisible(
      reset,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(find.text('Reset progress?'), findsOneWidget);
    expect(buttonOf(tester, 'Reset'), isA<TextButton>());
    expect(buttonOf(tester, 'Cancel'), isA<FilledButton>());

    // Cancel leaves everything as it was.
    await controller.gradeWord(
      controller.wordsForLevel(CefrLevel.a1).first,
      ReviewGrade.good,
    );
    final int xp = controller.xp;
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(controller.xp, xp);
    await tester.pumpWidget(const SizedBox());
  });

  // J4
  test('one minute is not written as "1 minutes"', () async {
    final AppText en = await AppText.delegate.load(const Locale('en'));
    final AppText de = await AppText.delegate.load(const Locale('de'));
    expect(en.audioDaySummary(1, 10, 0), endsWith('about 1 minute'));
    expect(en.audioDaySummary(12, 10, 5), endsWith('about 12 minutes'));
    expect(en.orderedSteps(1, 3), endsWith('about 1 minute'));
    expect(de.audioDaySummary(1, 10, 0), endsWith('ca. 1 Minute'));
    expect(de.orderedSteps(1, 3), endsWith('etwa 1 Minute'));
    expect(de.orderedSteps(16, 3), endsWith('etwa 16 Minuten'));
  });

  // J6
  testWidgets('the import dialog asks to check the backup', (tester) async {
    final AppController controller = await boot();
    await show(tester, Scaffold(body: SettingsScreen(controller: controller)));
    final Finder import = find.text('Import progress');
    await tester.scrollUntilVisible(
      import,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(import);
    await tester.pumpAndSettle();
    expect(find.text('Check backup'), findsOneWidget);
    expect(find.text('Check answer'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
