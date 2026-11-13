import 'dart:math';

import 'package:deutsch_garden/answer_option.dart';
import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/l10n/app_localizations.dart';
import 'package:deutsch_garden/learning_path_screen.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/quiz_distractors.dart';
import 'package:deutsch_garden/skill_screens.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/study_session.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:deutsch_garden/vocabulary_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

GermanWord _word(
  String id,
  String german,
  String english, {
  String article = '',
  String category = 'things',
}) => GermanWord(
  id: id,
  article: article,
  german: german,
  plural: '—',
  english: english,
  exampleGerman: '$german.',
  exampleEnglish: '$english.',
  category: category,
  level: 'A1',
);

const _grammar = GrammarLesson(
  id: 'test-grammar-feedback',
  level: CefrLevel.a1,
  title: 'Test lesson',
  explanation: 'A rule.',
  examples: <String>['Ich bin hier.'],
  questions: <ChoiceQuestion>[
    ChoiceQuestion(
      prompt: 'Ich ___ hier.',
      options: <String>['bin', 'ist'],
      correctIndex: 0,
      explanation: 'ich bin',
    ),
    ChoiceQuestion(
      prompt: 'Du ___ hier.',
      options: <String>['bist', 'bin'],
      correctIndex: 0,
      explanation: 'du bist',
    ),
  ],
);

void main() {
  group('wrong options', () {
    List<GermanWord> level(String label) => vocabulary
        .where((GermanWord word) => word.level.toUpperCase() == label)
        .toList(growable: false);

    test('a noun is offered beside other nouns', () {
      final List<GermanWord> pool = level('A1');
      final GermanWord mann = pool.firstWhere(
        (GermanWord word) => word.german == 'Mann',
      );
      for (int seed = 0; seed < 20; seed++) {
        final List<GermanWord> picked = pickDistractors(
          target: mann,
          pool: pool,
          label: (GermanWord word) => word.english,
          random: Random(seed),
        );
        expect(picked, hasLength(3));
        expect(
          picked.map(wordClassFor),
          everyElement(GermanWordClass.noun),
          reason: 'seed $seed offered ${picked.map((w) => w.english)}',
        );
      }
    });

    test('a verb is offered beside other verbs', () {
      final List<GermanWord> pool = level('A1');
      final GermanWord verb = pool.firstWhere(
        (GermanWord word) => wordClassFor(word) == GermanWordClass.verb,
      );
      final List<GermanWord> picked = pickDistractors(
        target: verb,
        pool: pool,
        label: (GermanWord word) => word.english,
        random: Random(7),
      );
      expect(picked.map(wordClassFor), everyElement(GermanWordClass.verb));
    });

    test('every card in the deck gets three distinct wrong options', () {
      for (final CefrLevel cefr in CefrLevel.values) {
        final List<GermanWord> pool = level(cefr.label);
        final Map<String, GermanWordClass> cache = <String, GermanWordClass>{};
        final Random random = Random(cefr.index);
        // Every eleventh card keeps this a property of the whole deck without
        // making it the slowest test in the suite.
        for (int i = 0; i < pool.length; i += 11) {
          final GermanWord target = pool[i];
          for (final String Function(GermanWord) label
              in <String Function(GermanWord)>[
                (GermanWord word) => word.english,
                (GermanWord word) => word.displayGerman,
              ]) {
            final List<String> labels = pickDistractors(
              target: target,
              pool: pool,
              label: label,
              random: random,
              classCache: cache,
            ).map(label).toList();
            expect(labels, hasLength(3), reason: target.id);
            expect(labels.toSet(), hasLength(3), reason: target.id);
            expect(labels, isNot(contains(label(target))), reason: target.id);
          }
        }
      }
    });

    test('a synonym is never a second right answer', () {
      final GermanWord target = _word('t', 'beginnen', 'to begin');
      final List<GermanWord> pool = <GermanWord>[
        target,
        _word('s', 'anfangen', 'to begin'),
        _word('a', 'gehen', 'to go'),
        _word('b', 'kommen', 'to come'),
        _word('c', 'sehen', 'to see'),
      ];
      for (int seed = 0; seed < 20; seed++) {
        final List<GermanWord> picked = pickDistractors(
          target: target,
          pool: pool,
          label: (GermanWord word) => word.displayGerman,
          conflict: (GermanWord word) => word.english,
          random: Random(seed),
        );
        expect(picked.map((GermanWord word) => word.id), isNot(contains('s')));
        expect(picked, hasLength(3));
      }
    });

    test('a small word class is topped up rather than left short', () {
      final GermanWord target = _word('t', 'und', 'and');
      final List<GermanWord> pool = <GermanWord>[
        target,
        _word('o', 'oder', 'or'),
        _word('a', 'Haus', 'house', article: 'das'),
        _word('b', 'Tisch', 'table', article: 'der'),
        _word('c', 'Lampe', 'lamp', article: 'die'),
      ];
      final List<GermanWord> picked = pickDistractors(
        target: target,
        pool: pool,
        label: (GermanWord word) => word.english,
        random: Random(1),
      );
      expect(picked, hasLength(3));
      // The one other conjunction is always among them.
      expect(picked.map((GermanWord word) => word.id), contains('o'));
    });

    test('options that display the same text are offered once', () {
      final GermanWord target = _word('t', 'Bank', 'bank', article: 'die');
      final List<GermanWord> pool = <GermanWord>[
        target,
        _word('x', 'Bank', 'bench', article: 'die'),
        _word('a', 'Haus', 'house', article: 'das'),
        _word('b', 'Tisch', 'table', article: 'der'),
        _word('c', 'Tisch', 'desk', article: 'der'),
        _word('d', 'Lampe', 'lamp', article: 'die'),
      ];
      final List<String> labels = pickDistractors(
        target: target,
        pool: pool,
        label: (GermanWord word) => word.displayGerman,
        conflict: (GermanWord word) => word.english,
        random: Random(3),
      ).map((GermanWord word) => word.displayGerman).toList();
      expect(labels, isNot(contains('die Bank')));
      expect(labels.toSet(), hasLength(labels.length));
    });
  });

  group('practice screens', () {
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

    Future<void> show(WidgetTester tester, Widget screen) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppText.supportedLocales,
          localizationsDelegates: AppText.localizationsDelegates,
          home: screen,
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> press(WidgetTester tester, String label) async {
      final Finder target = find.text(label);
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    List<AnswerOptionButton> options(WidgetTester tester) => tester
        .widgetList<AnswerOptionButton>(find.byType(AnswerOptionButton))
        .toList();

    AnswerOptionButton option(WidgetTester tester, String label) =>
        options(tester).singleWhere((AnswerOptionButton o) => o.label == label);

    // The spoken name of the tick or cross beside an option.
    Finder mark(String label) => find.byWidgetPredicate(
      (Widget widget) => widget is Icon && widget.semanticLabel == label,
    );

    double progress(WidgetTester tester) => tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
        .value!;

    testWidgets('an answer marks the right option and the one chosen', (
      tester,
    ) async {
      final AppController controller = await boot();
      final GermanWord word = controller.newWordsForLevel(CefrLevel.a1).first;
      await show(
        tester,
        StudySessionScreen(
          controller: controller,
          kind: SessionKind.learn,
          level: CefrLevel.a1,
        ),
      );
      await press(tester, 'Got it — test me');

      expect(
        options(tester).map((AnswerOptionButton o) => o.state),
        everyElement(AnswerOptionState.idle),
      );
      final String wrong = options(
        tester,
      ).firstWhere((AnswerOptionButton o) => o.label != word.english).label;
      await press(tester, wrong);

      expect(option(tester, word.english).state, AnswerOptionState.correct);
      expect(option(tester, wrong).state, AnswerOptionState.wrong);
      expect(
        options(
          tester,
        ).where((AnswerOptionButton o) => o.state == AnswerOptionState.dimmed),
        hasLength(2),
      );
      // Shape, not only colour: one tick and one cross on the options, and
      // the same pair again in the verdict.
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.cancel_rounded), findsNWidgets(2));
      expect(mark('Correct answer'), findsOneWidget);
      expect(mark('Your answer'), findsOneWidget);
      // The word is shown in use, and the learner is told it will return.
      expect(find.text(word.exampleGerman), findsOneWidget);
      expect(
        find.text('You will meet this word once more before the session ends.'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the wrong options for a noun are nouns', (tester) async {
      final AppController controller = await boot();
      final List<GermanWord> pool = controller.wordsForLevel(CefrLevel.a1);
      final GermanWord word = controller.newWordsForLevel(CefrLevel.a1).first;
      expect(wordClassFor(word), GermanWordClass.noun);
      await show(
        tester,
        StudySessionScreen(
          controller: controller,
          kind: SessionKind.learn,
          level: CefrLevel.a1,
        ),
      );
      await press(tester, 'Got it — test me');
      final Set<String> nounMeanings = pool
          .where((GermanWord w) => wordClassFor(w) == GermanWordClass.noun)
          .map((GermanWord w) => w.english)
          .toSet();
      expect(options(tester), hasLength(4));
      for (final AnswerOptionButton shown in options(tester)) {
        expect(nounMeanings, contains(shown.label));
      }
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a missed word returns once at the end and is summarised', (
      tester,
    ) async {
      final AppController controller = await boot();
      final List<GermanWord> words = controller
          .newWordsForLevel(CefrLevel.a1)
          .take(10)
          .toList();
      await show(
        tester,
        StudySessionScreen(
          controller: controller,
          kind: SessionKind.learn,
          level: CefrLevel.a1,
        ),
      );

      // Miss the first word, then answer the other nine correctly.
      await press(tester, 'Got it — test me');
      final String wrong = options(tester)
          .firstWhere((AnswerOptionButton o) => o.label != words.first.english)
          .label;
      await press(tester, wrong);
      await press(tester, 'Continue');
      for (final GermanWord word in words.skip(1)) {
        expect(find.text('Second try'), findsNothing);
        await press(tester, 'Got it — test me');
        await press(tester, word.english);
        await press(tester, 'Continue');
      }

      // The missed word is asked again, in the same direction.
      expect(find.text('Second try'), findsOneWidget);
      expect(find.text(words.first.displayGerman), findsOneWidget);
      // Missing it a second time must not queue a third attempt.
      final String wrongAgain = options(tester)
          .firstWhere((AnswerOptionButton o) => o.label != words.first.english)
          .label;
      await press(tester, wrongAgain);
      expect(
        find.text('You will meet this word once more before the session ends.'),
        findsNothing,
      );
      await press(tester, 'Continue');

      expect(find.text('Session complete'), findsOneWidget);
      expect(find.text('Worth another look'), findsOneWidget);
      // Listed once although it was missed twice.
      expect(find.text(words.first.displayGerman), findsOneWidget);
      expect(find.text(words[1].displayGerman), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('undoing a wrong answer withdraws its second try', (
      tester,
    ) async {
      final AppController controller = await boot();
      final GermanWord word = controller.newWordsForLevel(CefrLevel.a1).first;
      await show(
        tester,
        StudySessionScreen(
          controller: controller,
          kind: SessionKind.learn,
          level: CefrLevel.a1,
        ),
      );
      await press(tester, 'Got it — test me');
      // Ten cards and ten questions: the second step of twenty.
      expect(progress(tester), closeTo(2 / 20, 1e-9));
      final String wrong = options(
        tester,
      ).firstWhere((AnswerOptionButton o) => o.label != word.english).label;
      await press(tester, wrong);
      // The queued second try does not pull the bar back.
      expect(progress(tester), closeTo(2 / 20, 1e-9));
      await press(tester, 'Continue');
      await press(tester, 'Previous');
      expect(progress(tester), closeTo(2 / 20, 1e-9));
      expect(controller.progressFor(word.id).lapses, 0);

      // Answered correctly this time, so nothing is queued.
      await press(tester, word.english);
      expect(progress(tester), closeTo(2 / 20, 1e-9));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('number keys answer and Enter continues', (tester) async {
      final AppController controller = await boot();
      final GermanWord word = controller.newWordsForLevel(CefrLevel.a1).first;
      await show(
        tester,
        StudySessionScreen(
          controller: controller,
          kind: SessionKind.learn,
          level: CefrLevel.a1,
        ),
      );
      expect(find.text('NEW WORD'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('What does this mean?'), findsOneWidget);

      // A key past the last option does nothing.
      await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
      await tester.pumpAndSettle();
      expect(find.textContaining('Richtig! +XP'), findsNothing);

      final int index = options(
        tester,
      ).indexWhere((AnswerOptionButton o) => o.label == word.english);
      const List<LogicalKeyboardKey> digits = <LogicalKeyboardKey>[
        LogicalKeyboardKey.digit1,
        LogicalKeyboardKey.digit2,
        LogicalKeyboardKey.digit3,
        LogicalKeyboardKey.digit4,
      ];
      await tester.sendKeyEvent(digits[index]);
      await tester.pumpAndSettle();
      expect(find.textContaining('Richtig! +XP'), findsOneWidget);
      expect(controller.mistakes, isEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(find.text('NEW WORD'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('the way forward stays on screen beside a tall card', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final AppController controller = await boot();
      await show(
        tester,
        StudySessionScreen(
          controller: controller,
          kind: SessionKind.learn,
          level: CefrLevel.a1,
        ),
      );
      // No scrolling: the button is hit-testable as the card first appears.
      final Finder next = find.text('Got it — test me');
      expect(next.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a lesson quiz says whether the answer was right', (
      tester,
    ) async {
      final AppController controller = await boot();
      await show(
        tester,
        GrammarLessonScreen(controller: controller, lesson: _grammar),
      );
      await press(tester, 'Start quiz');
      await press(tester, 'ist');
      expect(find.text('Not quite. Correct answer: bin'), findsOneWidget);
      expect(option(tester, 'bin').state, AnswerOptionState.correct);
      expect(option(tester, 'ist').state, AnswerOptionState.wrong);
      expect(mark('Correct answer'), findsOneWidget);
      expect(mark('Your answer'), findsOneWidget);

      // Enter continues; a number key then answers the next question.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Du ___ hier.'), findsOneWidget);
      final int index = options(
        tester,
      ).indexWhere((AnswerOptionButton o) => o.label == 'bist');
      await tester.sendKeyEvent(
        index == 0 ? LogicalKeyboardKey.digit1 : LogicalKeyboardKey.digit2,
      );
      await tester.pumpAndSettle();
      expect(find.text('Correct.'), findsOneWidget);
      expect(option(tester, 'bist').state, AnswerOptionState.correct);
      expect(option(tester, 'bin').state, AnswerOptionState.dimmed);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Learn shows the daily goal and names its counters', (
      tester,
    ) async {
      final AppController controller = await boot();
      await show(
        tester,
        Scaffold(body: LearningPathScreen(controller: controller)),
      );
      expect(find.text('Today 0/${controller.dailyGoal}'), findsOneWidget);
      expect(find.byTooltip('0-day streak'), findsOneWidget);
      expect(find.byTooltip('0 XP earned'), findsOneWidget);

      await controller.gradeWord(
        controller.wordsForLevel(CefrLevel.a1).first,
        ReviewGrade.good,
      );
      await tester.pumpAndSettle();
      expect(find.text('Today 1/${controller.dailyGoal}'), findsOneWidget);
      expect(find.byTooltip('1-day streak'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
