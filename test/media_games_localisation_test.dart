import 'dart:async';

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/audio_course_screens.dart';
import 'package:deutsch_garden/conversation.dart';
import 'package:deutsch_garden/conversation_engine.dart';
import 'package:deutsch_garden/conversation_screens.dart';
import 'package:deutsch_garden/conversation_text.dart';
import 'package:deutsch_garden/feedback_text.dart';
import 'package:deutsch_garden/games.dart';
import 'package:deutsch_garden/glosses.dart';
import 'package:deutsch_garden/grammar_challenge.dart';
import 'package:deutsch_garden/l10n/app_localizations.dart';
import 'package:deutsch_garden/mini_story.dart';
import 'package:deutsch_garden/mini_story_screens.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/radio_models.dart';
import 'package:deutsch_garden/radio_screens.dart';
import 'package:deutsch_garden/stories.dart';
import 'package:deutsch_garden/story_screens.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'audio_course_screens_test.dart' show tinyPlaylist;
import 'practice_usability_test.dart'
    show DelayedActivityController, DelayedGradeController;

class TestDeckController extends DelayedGradeController {
  final pool = vocabulary
      .where((w) => w.level == 'A1' && w.article.isNotEmpty)
      .take(8)
      .toList();

  @override
  List<GermanWord> wordsForLevel(CefrLevel level) => pool;
}

class DelayedDayController extends AppController {
  final gate = Completer<void>();
  int dayCalls = 0;

  @override
  Future<void> completeAudioCourseDay(CefrLevel level, int day) async {
    dayCalls++;
    await gate.future;
    await super.completeAudioCourseDay(level, day);
  }
}

class DelayedSkipController extends AppController {
  final gate = Completer<void>();
  int skipCalls = 0;

  @override
  Future<void> recordSkip({
    required String id,
    required String prompt,
    required String correctAnswer,
    required String source,
    required String level,
    GermanWord? word,
  }) async {
    skipCalls++;
    await gate.future;
    await super.recordSkip(
      id: id,
      prompt: prompt,
      correctAnswer: correctAnswer,
      source: source,
      level: level,
      word: word,
    );
  }
}

class RetryActivityController extends AppController {
  int activityCalls = 0;

  @override
  Future<void> recordActivity(
    String activityId, {
    required int score,
    int passingScore = 70,
  }) async {
    if (++activityCalls == 1) throw StateError('test write failure');
    await super.recordActivity(
      activityId,
      score: score,
      passingScore: passingScore,
    );
  }
}

const turn = DialogueStep(
  tutorGerman: 'Wo bist du?',
  tutorEnglish: 'Where are you?',
  task: 'Say where you are.',
  keywords: ['hier'],
  modelAnswer: 'Ich bin hier.',
  modelAnswerEnglish: 'I am here.',
);
const scenario = ConversationScenario(
  id: 'test-conversation-save',
  level: CefrLevel.a1,
  emoji: '💬',
  title: 'Gespräch',
  setting: 'Ein Gespräch.',
  tutorRole: 'Tutor',
  learnerRole: 'Gast',
  goal: 'Sag, wo du bist.',
  usefulPhrases: ['Ich bin hier.'],
  steps: [turn],
);

const question = ChoiceQuestion(
  prompt: 'Ich ___ hier.',
  options: ['bin', 'ist'],
  correctIndex: 0,
  explanation: 'ich bin',
);
const chapter = StoryChapter(
  id: 'test-story-save',
  title: 'Testkapitel',
  titleEnglish: 'Test chapter',
  lines: [StoryLine('Ich bin hier.', 'I am here.')],
  glossary: [],
  questions: [question],
);
const story = Story(
  id: 'test-story',
  level: CefrLevel.a1,
  emoji: '📖',
  title: 'Testgeschichte',
  titleEnglish: 'Test story',
  blurb: 'A short story.',
  chapters: [chapter],
);
const drill = MiniStoryDrill(
  id: 'test-mini-save',
  story: story,
  transcript: [StoryLine('Ich bin hier.', 'I am here.')],
  questions: [question],
  retellPrompts: ['Wo bin ich?'],
);
const episode = RadioEpisode(
  id: 'test-radio-save',
  level: CefrLevel.a1,
  genre: RadioGenre.diary,
  title: 'Tagebuch',
  lines: [RadioLine(german: 'Ich bin hier.', english: 'I am here.')],
  questions: [question],
);

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
      160,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.pumpAndSettle();
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<T> boot<T extends AppController>(T controller) async {
  await controller.load();
  controller.ttsEnabled = false;
  addTearDown(controller.dispose);
  return controller;
}

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

  void narrow(WidgetTester tester) {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('story completion records one attempt during a slow save', (
    tester,
  ) async {
    final c = await boot(DelayedActivityController());
    await tester.pumpWidget(
      host(
        StoryQuizScreen(controller: c, chapter: chapter, level: CefrLevel.a1),
      ),
    );
    await tester.pumpAndSettle();
    await press(tester, 'bin');
    final finish = action(tester, 'Finish');
    finish();
    finish();
    await tester.pump();
    final calls = c.activityCalls;
    c.gate.complete();
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(c.activities[chapter.id]!.attempts, 1);
    expect(c.storyChaptersDone, 1);
    expect(find.text('1 of 1 correct'), findsOneWidget);
  });

  testWidgets('mini-story completion records one attempt during a slow save', (
    tester,
  ) async {
    final c = await boot(DelayedActivityController());
    await tester.pumpWidget(
      host(MiniStoryDrillScreen(controller: c, drill: drill)),
    );
    await tester.pumpAndSettle();
    await press(tester, 'bin');
    final finish = action(tester, 'Finish questions');
    finish();
    finish();
    await tester.pump();
    final calls = c.activityCalls;
    c.gate.complete();
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(c.activities[drill.id]!.attempts, 1);
    expect(find.text('Circling complete'), findsOneWidget);
  });

  testWidgets('radio completion records one attempt during a slow save', (
    tester,
  ) async {
    final c = await boot(DelayedActivityController());
    await tester.pumpWidget(
      host(RadioEpisodeScreen(controller: c, episode: episode)),
    );
    await tester.pumpAndSettle();
    await press(tester, 'Answer the questions');
    await press(tester, 'bin');
    final finish = action(tester, 'Finish');
    finish();
    finish();
    await tester.pump();
    final calls = c.activityCalls;
    c.gate.complete();
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(c.activities[episode.id]!.attempts, 1);
    expect(find.text('Answer the questions'), findsOneWidget);
  });

  testWidgets('audio day completion and navigation wait for one save', (
    tester,
  ) async {
    final c = await boot(DelayedDayController());
    await tester.pumpWidget(
      host(AnticipationDrillScreen(controller: c, playlist: tinyPlaylist())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next sentence'));
    await tester.pumpAndSettle();
    final next = tester
        .widget<IconButton>(
          find.byWidgetPredicate(
            (w) => w is IconButton && w.tooltip == 'Next sentence',
          ),
        )
        .onPressed!;
    next();
    next();
    await tester.pumpAndSettle();
    final calls = c.dayCalls;
    c.gate.complete();
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(c.audioCourseDaysDone(CefrLevel.a1), 1);
    expect(find.text('Day 1 done'), findsOneWidget);
  });

  testWidgets(
    'a role-play final reply saves once and coaches in the current locale',
    (tester) async {
      final c = await boot(DelayedActivityController());
      await tester.pumpWidget(
        host(
          ConversationScreen(controller: c, scenario: scenario),
          locale: 'de',
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), turn.modelAnswer);
      final send = tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (w) => w is IconButton && w.tooltip == 'Antwort senden',
            ),
          )
          .onPressed!;
      send();
      send();
      await tester.pumpAndSettle();
      final calls = c.activityCalls;
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      c.gate.complete();
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(c.activities[scenario.id]!.attempts, 1);
      expect(c.conversationsDone, 1);
      expect(c.speakingTurns, 1);
      expect(
        find.text(
          'Du hast die Gesprächsaufgabe vollständig und in passender Länge beantwortet.',
        ),
        findsOneWidget,
      );
      // Coach history contains structured reasons, so it follows a locale change.
      await tester.pumpWidget(
        host(ConversationScreen(controller: c, scenario: scenario)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('You addressed the turn fully and at the right length.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'matching uses frozen meanings and ignores repeated taps while grading',
    (tester) async {
      narrow(tester);
      final c = await boot(TestDeckController());
      for (final word in c.pool) {
        await c.markSeen(word);
      }
      debugSetGlosses('tr', {
        for (var i = 0; i < c.pool.length; i++) c.pool[i].id: 'anlam-$i',
      });
      await c.setGlossLanguage('tr');
      await tester.pumpWidget(
        host(
          MatchPairsScreen(controller: c, level: CefrLevel.a1),
          locale: 'de',
          scale: 1.5,
        ),
      );
      await tester.pumpAndSettle();
      final word = c.pool.firstWhere(
        (w) => find.text(w.displayGerman).evaluate().isNotEmpty,
      );
      final meaning = 'anlam-${c.pool.indexOf(word)}';
      action(tester, word.displayGerman)();
      final selectMeaning = action(tester, meaning);
      selectMeaning();
      selectMeaning();
      await tester.pumpAndSettle();
      expect(c.gradeCalls, 1);
      expect(tester.takeException(), isNull);
      await c.setGlossLanguage('');
      await tester.pump();
      expect(find.text(meaning), findsOneWidget);
      expect(find.text(word.english), findsNothing);
      c.gate.complete();
      await tester.pumpAndSettle();
      expect(c.progressFor(word.id).seen, isTrue);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'speed options have distinct selected meanings and store the shown answer',
    (tester) async {
      final c = await boot(TestDeckController());
      debugSetGlosses('tr', {
        for (var i = 0; i < c.pool.length; i++) c.pool[i].id: 'anlam-${i % 4}',
      });
      await c.setGlossLanguage('tr');
      await tester.pumpWidget(
        host(SpeedReviewScreen(controller: c, level: CefrLevel.a1)),
      );
      await tester.pumpAndSettle();
      final word = c.pool.firstWhere(
        (w) => find.text(w.displayGerman).evaluate().isNotEmpty,
      );
      final correct = 'anlam-${c.pool.indexOf(word) % 4}';
      expect(find.byType(OutlinedButton), findsNWidgets(4));
      for (var i = 0; i < 4; i++) {
        expect(find.text('anlam-$i'), findsOneWidget);
      }
      final wrong = correct == 'anlam-0' ? 'anlam-1' : 'anlam-0';
      action(tester, wrong)();
      await c.setGlossLanguage('');
      c.gate.complete();
      await tester.pumpAndSettle();
      expect(c.mistakes.single.correctAnswer, correct);
      expect(c.mistakes.single.givenAnswer, wrong);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('article taps cannot grade twice while storage is slow', (
    tester,
  ) async {
    final c = await boot(TestDeckController());
    await tester.pumpWidget(
      host(ArticleTrainerScreen(controller: c, level: CefrLevel.a1)),
    );
    await tester.pumpAndSettle();
    final choose = action(tester, 'DER');
    choose();
    choose();
    await tester.pumpAndSettle();
    expect(c.gradeCalls, 1);
    c.gate.complete();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Next noun'), 180);
    expect(find.text('Next noun'), findsOneWidget);
  });

  for (final kind in ['story', 'mini-story', 'radio']) {
    testWidgets('$kind repeated skip waits before advancing or saving', (
      tester,
    ) async {
      final c = await boot(DelayedSkipController());
      final Widget screen = switch (kind) {
        'story' => StoryQuizScreen(
          controller: c,
          chapter: chapter,
          level: CefrLevel.a1,
        ),
        'mini-story' => MiniStoryDrillScreen(controller: c, drill: drill),
        _ => RadioEpisodeScreen(controller: c, episode: episode),
      };
      await tester.pumpWidget(host(screen));
      await tester.pumpAndSettle();
      if (kind == 'radio') await press(tester, 'Answer the questions');
      if (kind == 'mini-story') {
        await tester.scrollUntilVisible(find.text('Skip'), 180);
        await tester.pumpAndSettle();
      }
      final skip = action(tester, 'Skip');
      skip();
      skip();
      await tester.pumpAndSettle();
      expect(c.skipCalls, 1);
      c.gate.complete();
      await tester.pumpAndSettle();
      final id = kind == 'story'
          ? chapter.id
          : kind == 'mini-story'
          ? drill.id
          : episode.id;
      expect(c.activities[id]!.attempts, 1);
      expect(c.mistakes.length, 1);
    });
  }

  testWidgets(
    'free-talk releases the controls and preserves a draft after a failed save',
    (tester) async {
      final c = await boot(RetryActivityController());
      final prompt = freeTalkFor(CefrLevel.a1).first;
      await tester.pumpWidget(
        host(FreeTalkScreen(controller: c, prompt: prompt)),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), prompt.modelAnswer);
      await tester.pumpAndSettle();
      final dynamic evaluate = action(tester, 'Check answer');
      await expectLater(evaluate(), throwsStateError);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        prompt.modelAnswer,
      );
      expect(action(tester, 'Check answer'), isNotNull);
      final dynamic retry = action(tester, 'Check answer');
      await retry();
      await tester.pumpAndSettle();
      expect(c.activities[prompt.id]!.attempts, 1);
      await tester.enterText(find.byType(TextField), 'Eine andere Antwort.');
      await tester.pumpAndSettle();
      expect(find.textContaining('target connectors'), findsNothing);
    },
  );

  test(
    'role-play and free-talk English feedback stays equal to the legacy evaluation',
    () async {
      final en = await AppText.delegate.load(const Locale('en'));
      final de = await AppText.delegate.load(const Locale('de'));
      for (final scenario in conversationScenarios) {
        for (final step in scenario.steps) {
          for (final reply in [
            '',
            step.modelAnswer,
            step.keywords.firstOrNull ?? '',
            'xyz xyz xyz',
          ]) {
            final result = ConversationEngine.evaluate(step, reply);
            expect(turnHeadline(en, result), result.headline);
            expect(turnDetail(en, result), result.detail);
            expect(turnDetail(de, result), isNotEmpty);
          }
        }
      }
      for (final level in CefrLevel.values) {
        for (final prompt in freeTalkFor(level)) {
          for (final answer in [
            '',
            prompt.modelAnswer,
            List.filled(prompt.targetWords * 2, 'Beispiel').join(' '),
          ]) {
            final result = ConversationEngine.evaluateFreeTalk(prompt, answer);
            expect(
              feedbackTexts(en, result.feedback, result.tips),
              result.tips,
            );
            expect(feedbackTexts(de, result.feedback, result.tips), isNotEmpty);
          }
        }
      }
    },
  );

  testWidgets(
    'German media and game controls fit a 320 pixel phone at 150 percent text',
    (tester) async {
      narrow(tester);
      final c = await boot(AppController());
      final screens = <Widget>[
        StoryLibraryScreen(controller: c),
        StoryDetailScreen(controller: c, story: stories.first),
        StoryReaderScreen(controller: c, story: story, chapterIndex: 0),
        StoryQuizScreen(controller: c, chapter: chapter, level: CefrLevel.a1),
        MiniStoryDrillScreen(controller: c, drill: drill),
        RadioEpisodeScreen(controller: c, episode: episode),
        RadioLibraryScreen(controller: c, level: CefrLevel.a1),
        AudioCourseScreen(controller: c, level: CefrLevel.a1),
        AnticipationDrillScreen(controller: c, playlist: tinyPlaylist()),
        MatchPairsScreen(controller: c, level: CefrLevel.a1),
        SentenceBuilderScreen(controller: c, level: CefrLevel.a1),
        DictationScreen(controller: c, level: CefrLevel.a1),
        ArticleTrainerScreen(controller: c, level: CefrLevel.a1),
        VerbLabScreen(controller: c, level: CefrLevel.a1),
        ClozeDrillScreen(controller: c, level: CefrLevel.a1),
        ShadowLabScreen(controller: c, level: CefrLevel.a1),
        GrammarChallengeDrillScreen(
          controller: c,
          feature: GrammarFeature.nominativeArticles,
        ),
        GrammarChallengeHubScreen(controller: c),
        SpeakHubScreen(controller: c),
        ConversationScreen(controller: c, scenario: scenario),
        FreeTalkScreen(controller: c, prompt: freeTalkFor(CefrLevel.a1).first),
        PronunciationLabScreen(controller: c, level: CefrLevel.a1),
      ];
      final issues = <String>[];
      for (final screen in screens) {
        await tester.pumpWidget(host(screen, locale: 'de', scale: 1.5));
        await tester.pumpAndSettle();
        final exception = tester.takeException();
        if (exception != null) issues.add('${screen.runtimeType}: $exception');
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      }
      expect(issues, isEmpty);
    },
  );
}
