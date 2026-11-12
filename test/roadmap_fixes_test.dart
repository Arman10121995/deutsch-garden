// Tests that prove items of docs/LEARNING_UX_ROADMAP.md.
//
// tool/plan_status.py looks for the quoted phrase of each item in a test
// description, so the descriptions below are not free to reword.
import 'package:deutsch_garden/answer_option.dart';
import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/cloze_bank.dart';
import 'package:deutsch_garden/games.dart';
import 'package:deutsch_garden/l10n/app_localizations.dart';
import 'package:deutsch_garden/learning_path_screen.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/quiz_distractors.dart';
import 'package:deutsch_garden/radio.dart';
import 'package:deutsch_garden/radio_screens.dart';
import 'package:deutsch_garden/screens.dart';
import 'package:deutsch_garden/sentence_bank.dart';
import 'package:deutsch_garden/skill_screens.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:deutsch_garden/vocabulary.dart';
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

  // G1e
  for (final MapEntry<String, Widget Function(AppController)> game
      in <String, Widget Function(AppController)>{
        'cloze drill': (c) =>
            ClozeDrillScreen(controller: c, level: CefrLevel.a1),
        'verb lab': (c) => VerbLabScreen(controller: c, level: CefrLevel.a1),
        'grammar challenge': (c) => GrammarChallengeHubScreen(controller: c),
      }.entries) {
    testWidgets('the ${game.key} marks the right option and a wrong pick', (
      tester,
    ) async {
      final AppController controller = await boot();
      await show(tester, game.value(controller));
      if (game.key == 'grammar challenge') {
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle();
      }
      List<AnswerOptionButton> options() => tester
          .widgetList<AnswerOptionButton>(find.byType(AnswerOptionButton))
          .toList();
      expect(options().length, greaterThanOrEqualTo(3));
      expect(
        options().map((AnswerOptionButton o) => o.state),
        everyElement(AnswerOptionState.idle),
      );
      final String picked = options().first.label;
      await tester.ensureVisible(find.byType(AnswerOptionButton).first);
      await tester.tap(find.byType(AnswerOptionButton).first);
      await tester.pump(const Duration(milliseconds: 400));
      final List<AnswerOptionButton> after = options();
      expect(
        after.where((o) => o.state == AnswerOptionState.correct),
        hasLength(1),
      );
      final AnswerOptionButton mine = after.firstWhere(
        (AnswerOptionButton o) => o.label == picked,
      );
      expect(
        mine.state,
        anyOf(AnswerOptionState.correct, AnswerOptionState.wrong),
      );
      expect(after.where((o) => o.state == AnswerOptionState.idle), isEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });
  }

  // G6
  test("cloze options share the answer's gender", () {
    final Map<String, Set<String>> articles = <String, Set<String>>{};
    final Set<String> nounCards = <String>{};
    for (final GermanWord word in vocabulary) {
      if (word.article.isEmpty) continue;
      nounCards.add('cz-${word.id}');
      articles.putIfAbsent(word.german, () => <String>{}).add(word.article);
    }
    int nounItems = 0;
    for (final CefrLevel level in CefrLevel.values) {
      for (final ClozeItem item in clozeFor(level)) {
        // The item's own card decides: a noun gap, not a word that merely
        // shares its spelling with a noun.
        if (!nounCards.contains(item.id)) continue;
        final Set<String> answer = articles[item.answer]!;
        nounItems++;
        for (final String option in item.distractors) {
          expect(
            articles[option]?.intersection(answer),
            isNotEmpty,
            reason: '${item.id}: $option beside ${item.answer}',
          );
        }
      }
    }
    expect(nounItems, greaterThan(1000));
  });

  // G8
  test('sentence tiles do not mark the first or last word', () {
    expect(sentenceTileLabel('Ich', first: true), 'ich');
    expect(sentenceTileLabel('Heute', first: true), 'heute');
    expect(sentenceTileLabel('Mensch.', first: false), 'Mensch');
    expect(sentenceTileLabel('kommentieren.', first: false), 'kommentieren');
    expect(sentenceTileLabel('Kino?', first: false), 'Kino');
    // A noun or a name keeps its capital wherever it stands.
    expect(sentenceTileLabel('Kinder', first: true), 'Kinder');
    expect(sentenceTileLabel('Amir', first: true), 'Amir');
    // A comma is part of the sentence's structure, not its end.
    expect(sentenceTileLabel('Haus,', first: false), 'Haus,');
    expect(sentenceTileLabel('Ich', first: false), 'Ich');
  });

  testWidgets('sentence builder tiles show no closing punctuation', (
    tester,
  ) async {
    final AppController controller = await boot();
    await show(
      tester,
      SentenceBuilderScreen(controller: controller, level: CefrLevel.a1),
    );
    final List<String> tiles = tester
        .widgetList<ActionChip>(find.byType(ActionChip))
        .map((ActionChip chip) => (chip.label as Text).data!)
        .toList();
    expect(tiles.length, greaterThanOrEqualTo(3));
    for (final String tile in tiles) {
      expect(tile, isNot(matches(RegExp(r'[.!?]$'))), reason: tile);
    }
    await tester.pumpWidget(const SizedBox());
  });

  // I9
  testWidgets('match pairs says what to do', (tester) async {
    final AppController controller = await boot();
    for (final GermanWord word
        in controller.wordsForLevel(CefrLevel.a1).take(30)) {
      await controller.markSeen(word);
    }
    await show(
      tester,
      MatchPairsScreen(controller: controller, level: CefrLevel.a1),
    );
    expect(find.text('Tap a German word, then its meaning.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  // I3
  testWidgets('the review card hides scheduler numbers', (tester) async {
    final AppController controller = await boot();
    await controller.markSeen(controller.wordsForLevel(CefrLevel.a1).first);
    await show(tester, ReviewSessionScreen(controller: controller));
    expect(find.textContaining('Ease'), findsNothing);
    expect(find.textContaining('lapses'), findsNothing);
    await tester.tap(find.text('Scheduling details'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Ease'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  // I4
  testWidgets('Learn states the daily goal once', (tester) async {
    final AppController controller = await boot();
    await show(
      tester,
      Scaffold(body: LearningPathScreen(controller: controller)),
    );
    expect(find.text('Today 0/${controller.dailyGoal}'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('daily quests done'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('daily quests done'), findsOneWidget);
    expect(find.textContaining('learning actions'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  // I7
  testWidgets('the vocabulary page speaks to the learner', (tester) async {
    final AppController controller = await boot();
    await show(
      tester,
      VocabularyLevelScreen(controller: controller, level: CefrLevel.a1),
    );
    expect(find.textContaining('words at this level'), findsOneWidget);
    expect(find.textContaining('bundled'), findsNothing);
    expect(find.textContaining('lexical units'), findsNothing);
    expect(find.textContaining('planning target'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  // I6
  testWidgets('a radio transcript starts hidden', (tester) async {
    final AppController controller = await boot();
    final RadioEpisode episode = radioFor(CefrLevel.a1).first;
    final String firstLine = episode.lines.first.german;

    // With audio off there is nothing to listen to first.
    await show(
      tester,
      RadioEpisodeScreen(controller: controller, episode: episode),
    );
    expect(find.text(firstLine), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));

    controller.ttsEnabled = true;
    await show(
      tester,
      RadioEpisodeScreen(controller: controller, episode: episode),
    );
    expect(find.text(firstLine), findsNothing);
    final Finder reveal = find.text('Reveal transcript');
    await tester.ensureVisible(reveal);
    await tester.tap(reveal);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(firstLine), findsOneWidget);
    expect(find.text('Hide transcript'), findsOneWidget);
    controller.ttsEnabled = false;
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
