import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/assessment.dart';
import 'package:deutsch_garden/curriculum.dart';
import 'package:deutsch_garden/feedback_text.dart';
import 'package:deutsch_garden/games.dart';
import 'package:deutsch_garden/glosses.dart';
import 'package:deutsch_garden/l10n/app_localizations.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/review_text.dart';
import 'package:deutsch_garden/skill_screens.dart';
import 'package:deutsch_garden/speaking_curriculum.dart';
import 'package:deutsch_garden/speaking_evaluation.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/study_session.dart';
import 'package:deutsch_garden/test_prep.dart';
import 'package:deutsch_garden/test_screens.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:deutsch_garden/writing_evaluation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'practice_usability_test.dart' show DelayedActivityController;

const singleGrammar = GrammarLesson(
  id: 'test-grammar-save',
  level: CefrLevel.a1,
  title: 'Test lesson',
  explanation: 'A rule.',
  examples: ['Ich bin hier.'],
  questions: [
    ChoiceQuestion(
      prompt: 'Ich ___ hier.',
      options: ['bin', 'ist'],
      correctIndex: 0,
      explanation: 'ich bin',
    ),
  ],
);
const singleExam = ExamPracticeSet(
  id: 'test-exam-save',
  level: CefrLevel.a1,
  title: 'Test exam',
  objectiveQuestions: [
    ExamObjectiveQuestion(
      module: ExamModuleType.reading,
      prompt: 'Ich ___ hier.',
      options: ['bin', 'ist'],
      correctIndex: 0,
      explanation: 'ich bin',
    ),
  ],
  writingPrompt: 'Schreibe einen Satz.',
  writingChecklist: [],
  speakingPrompt: 'Sprich einen Satz.',
  speakingChecklist: [],
);

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    debugSetVocabIcons(const []);
    debugClearGlosses();
  });
  tearDown(() {
    AppController.debounceWrites = true;
    debugResetVocabIcons();
    debugClearGlosses();
  });

  Widget host(Widget child, {String locale = 'en', double scale = 1}) =>
      MaterialApp(
        locale: Locale(locale),
        supportedLocales: AppText.supportedLocales,
        localizationsDelegates: AppText.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: child,
      );
  Future<T> boot<T extends AppController>(T c) async {
    await c.load();
    c.ttsEnabled = false;
    addTearDown(c.dispose);
    return c;
  }

  VoidCallback action(WidgetTester tester, String label) => tester
      .widget<ButtonStyleButton>(
        find
            .ancestor(
              of: find.text(label),
              matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
            )
            .first,
      )
      .onPressed!;
  Future<void> press(WidgetTester tester, String label) async {
    final target = find.text(label);
    if (find.byType(Scrollable).evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(
        target,
        180,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.pumpAndSettle();
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> showRoute(
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

  testWidgets('lesson results save once during a slow write', (tester) async {
    final c = await boot(DelayedActivityController());
    await showRoute(
      tester,
      GrammarLessonScreen(controller: c, lesson: singleGrammar),
    );
    await press(tester, 'Start quiz');
    await press(tester, 'bin');
    await press(tester, 'Continue');
    final save = action(tester, 'Save result');
    save();
    save();
    final calls = c.activityCalls;
    c.gate.complete();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    expect(calls, 1);
    expect(c.progressForActivity(singleGrammar.id).attempts, 1);
  });

  testWidgets('mini mocks save once during a slow write', (tester) async {
    final c = await boot(DelayedActivityController());
    await showRoute(tester, ExamPracticeScreen(controller: c, set: singleExam));
    await press(tester, 'bin');
    await press(tester, 'Continue');
    await press(tester, 'Continue to speaking');
    final save = action(tester, 'Finish mini mock');
    save();
    save();
    final calls = c.activityCalls;
    c.gate.complete();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    expect(calls, 1);
    expect(c.progressForActivity(singleExam.id).attempts, 1);
  });

  testWidgets('practice meanings stay fixed when language settings change', (
    tester,
  ) async {
    final c = await boot(AppController());
    final word = c.newWordsForLevel(CefrLevel.a1).first;
    debugSetGlosses('tr', {
      for (final w in c.wordsForLevel(CefrLevel.a1)) w.id: 'tr:${w.id}',
    });
    await c.setGlossLanguage('tr');
    Widget screen() => StudySessionScreen(
      key: const ValueKey('meaning-snapshot'),
      controller: c,
      kind: SessionKind.learn,
      level: CefrLevel.a1,
    );
    await tester.pumpWidget(host(screen()));
    await tester.pumpAndSettle();
    expect(find.text('tr:${word.id}'), findsOneWidget);
    await press(tester, 'Got it — test me');
    await c.setGlossLanguage('');
    await tester.pumpWidget(host(screen(), locale: 'de'));
    await tester.pumpAndSettle();
    expect(find.text('Was bedeutet das?'), findsOneWidget);
    expect(find.text('tr:${word.id}'), findsOneWidget);
    await press(tester, 'tr:${word.id}');
    expect(find.textContaining('Richtig! +XP'), findsOneWidget);
    expect(find.textContaining('Nicht ganz.'), findsNothing);
    expect(c.mistakes, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'wrong meaning choices preserve the displayed answers in history',
    (tester) async {
      final c = await boot(AppController());
      final word = c.newWordsForLevel(CefrLevel.a1).first;
      debugSetGlosses('tr', {
        for (final w in c.wordsForLevel(CefrLevel.a1)) w.id: 'tr:${w.id}',
      });
      await c.setGlossLanguage('tr');
      await tester.pumpWidget(
        host(
          StudySessionScreen(
            controller: c,
            kind: SessionKind.learn,
            level: CefrLevel.a1,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await press(tester, 'Got it — test me');
      final wrong = tester
          .widgetList<OutlinedButton>(find.byType(OutlinedButton))
          .firstWhere(
            (b) => (find
                .descendant(
                  of: find.byWidget(b),
                  matching: find.text('tr:${word.id}'),
                )
                .evaluate()
                .isEmpty),
          );
      final label = (tester.widget<Text>(
        find.descendant(of: find.byWidget(wrong), matching: find.byType(Text)),
      )).data!;
      wrong.onPressed!();
      await tester.pumpAndSettle();
      expect(c.mistakes.single.correctAnswer, 'tr:${word.id}');
      expect(c.mistakes.single.givenAnswer, label);
      await tester.pumpWidget(const SizedBox());
    },
  );

  void narrow(WidgetTester tester) {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  for (final entry in <String, Widget Function(AppController)>{
    'tests hub': (c) => TestHubHostScreen(controller: c),
    'level dashboard': (c) =>
        LevelDashboardScreen(controller: c, level: CefrLevel.a1),
    'vocabulary level': (c) =>
        VocabularyLevelScreen(controller: c, level: CefrLevel.a1),
    'placement intro': (c) => PlacementIntroScreen(controller: c),
    'placement questions': (c) => PlacementTestScreen(controller: c),
    'exam references': (c) =>
        ExamLevelPrepScreen(controller: c, level: CefrLevel.b2),
    'grammar handbook': (c) => GrammarHandbookScreen(controller: c),
  }.entries) {
    testWidgets('German ${entry.key} fits narrow screens with larger text', (
      tester,
    ) async {
      narrow(tester);
      final c = await boot(AppController());
      await tester.pumpWidget(host(entry.value(c), locale: 'de', scale: 1.5));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('German grammar quiz and completion fit larger text', (
    tester,
  ) async {
    narrow(tester);
    final c = await boot(AppController());
    final de = await AppText.delegate.load(const Locale('de'));
    await showRoute(
      tester,
      GrammarLessonScreen(controller: c, lesson: singleGrammar),
      locale: 'de',
      scale: 1.5,
    );
    await press(tester, de.startQuiz);
    await press(tester, 'bin');
    await press(tester, de.continueAction);
    await press(tester, de.saveResult);
    expect(c.progressForActivity(singleGrammar.id).attempts, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('German writing feedback fits and translates coaching', (
    tester,
  ) async {
    narrow(tester);
    final c = await boot(AppController());
    final de = await AppText.delegate.load(const Locale('de'));
    final lesson = writingLessons.first;
    await tester.pumpWidget(
      host(
        WritingLessonScreen(controller: c, lesson: lesson),
        locale: 'de',
        scale: 1.5,
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(TextField),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byType(TextField), 'ich habe ein haus.');
    await press(tester, de.evaluateWriting);
    final result = WritingEvaluator.evaluate(lesson, 'ich habe ein haus.');
    for (final tip in feedbackTexts(de, result.feedback, result.tips)) {
      await tester.scrollUntilVisible(
        find.text('• $tip'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('• $tip'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('German speaking fallback translates live feedback', (
    tester,
  ) async {
    narrow(tester);
    final c = await boot(AppController());
    final de = await AppText.delegate.load(const Locale('de'));
    final lesson = speakingLessons.first;
    await tester.pumpWidget(
      host(
        SpeakingLessonScreen(controller: c, lesson: lesson),
        locale: 'de',
        scale: 1.5,
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(TextField),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byType(TextField), 'Ich heiße Amina.');
    await press(tester, de.checkTranscript);
    final result = SpeakingEvaluator.evaluate(lesson, 'Ich heiße Amina.');
    for (final tip in feedbackTexts(de, result.feedback, result.tips)) {
      await tester.scrollUntilVisible(
        find.text('• $tip'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('• $tip'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('German mini mock completes at larger text sizes', (
    tester,
  ) async {
    narrow(tester);
    final c = await boot(AppController());
    final de = await AppText.delegate.load(const Locale('de'));
    await showRoute(
      tester,
      ExamPracticeScreen(controller: c, set: singleExam),
      locale: 'de',
      scale: 1.5,
    );
    await press(tester, 'bin');
    await press(tester, de.continueAction);
    await press(tester, de.continueSpeaking);
    await press(tester, de.finishMiniMock);
    expect(c.progressForActivity(singleExam.id).attempts, 1);
    await press(tester, de.doneAction);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('German vocabulary summary remains usable with larger text', (
    tester,
  ) async {
    narrow(tester);
    final c = await boot(AppController());
    await c.markSeen(c.wordsForLevel(CefrLevel.a1).first);
    final de = await AppText.delegate.load(const Locale('de'));
    await showRoute(
      tester,
      StudySessionScreen(
        controller: c,
        kind: SessionKind.review,
        level: CefrLevel.a1,
      ),
      locale: 'de',
      scale: 1.5,
    );
    await press(tester, de.actionSkip);
    expect(find.text(de.sessionComplete), findsOneWidget);
    await press(tester, de.backHome);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('German placement results remain readable with larger text', (
    tester,
  ) async {
    narrow(tester);
    final c = await boot(AppController());
    final de = await AppText.delegate.load(const Locale('de'));
    await tester.pumpWidget(
      host(PlacementTestScreen(controller: c), locale: 'de', scale: 1.5),
    );
    await tester.pumpAndSettle();
    for (final question in placementQuestionsFor(CefrLevel.a1)) {
      if (find.text(de.assessmentResult).evaluate().isNotEmpty) break;
      final wrong = question.options.firstWhere(
        (option) => option != question.options[question.correctIndex],
      );
      await press(tester, wrong);
      await press(tester, de.continueAction);
    }
    expect(find.text(de.assessmentResult), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(de.useThisLevel),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'German review uses selected meanings and readable grade controls',
    (tester) async {
      narrow(tester);
      final c = await boot(AppController());
      final word = c.wordsForLevel(CefrLevel.a1).first;
      await c.gradeWord(word, ReviewGrade.again);
      c.progressFor(word.id).dueAt = DateTime.now().subtract(
        const Duration(days: 1),
      );
      debugSetGlosses('tr', {word.id: 'tr:${word.id}'});
      await c.setGlossLanguage('tr');
      final de = await AppText.delegate.load(const Locale('de'));
      await tester.pumpWidget(
        host(
          ReviewSessionScreen(controller: c, limit: 1),
          locale: 'de',
          scale: 1.5,
        ),
      );
      await tester.pumpAndSettle();
      await press(tester, de.showAnswer);
      await tester.ensureVisible(find.text('tr:${word.id}'));
      await tester.pumpAndSettle();
      expect(find.text('tr:${word.id}'), findsOneWidget);
      expect(find.text(de.gradeAgain), findsOneWidget);
      await tester.tap(find.text(de.gradeGood));
      await tester.pumpAndSettle();
      expect(find.text(de.reviewCleared(1)), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  test(
    'structured feedback preserves existing English evaluation across lessons',
    () async {
      final en = await AppText.delegate.load(const Locale('en'));
      final de = await AppText.delegate.load(const Locale('de'));
      for (final lesson in writingLessons) {
        for (final text in ['', 'ich habe ein haus.', lesson.example]) {
          final result = WritingEvaluator.evaluate(lesson, text);
          expect(
            feedbackTexts(en, result.feedback, result.tips),
            result.tips,
            reason: lesson.id,
          );
          expect(
            feedbackTexts(de, result.feedback, result.tips),
            hasLength(result.tips.length),
          );
        }
      }
      for (final lesson in speakingLessons) {
        for (final text in [
          '',
          'Ich heiße Amina.',
          lesson.modelPhrases.join(' '),
        ]) {
          final result = SpeakingEvaluator.evaluate(lesson, text);
          expect(
            feedbackTexts(en, result.feedback, result.tips),
            result.tips,
            reason: lesson.id,
          );
        }
      }
      expect(feedbackTexts(de, [], ['legacy feedback']), ['legacy feedback']);
    },
  );

  test(
    'review interval previews translate the same unfuzzed schedule',
    () async {
      final en = await AppText.delegate.load(const Locale('en'));
      final de = await AppText.delegate.load(const Locale('de'));
      for (final days in [0, 1, 14, 30, 120, 365]) {
        for (final grade in ReviewGrade.values) {
          final next = Sm2Scheduler.schedule(
            ease: 2.5,
            intervalDays: days,
            reps: 5,
            lapses: 1,
            learningStep: 2,
            grade: grade,
          );
          String preview(AppText t) => reviewIntervalText(
            t,
            ease: 2.5,
            intervalDays: days,
            reps: 5,
            lapses: 1,
            learningStep: 2,
            grade: grade,
          );
          if (next.intervalDays <= 0) {
            expect(preview(de), '10 Min.');
          } else if (next.intervalDays < 30) {
            expect(preview(de), de.reviewDays(next.intervalDays));
          }
          expect(preview(en), isNotEmpty);
        }
      }
    },
  );
}
