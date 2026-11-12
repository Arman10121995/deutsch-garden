// Renders the app's screens to PNG files for a visual audit.
//
// Flutter web draws to a canvas, so walking the app in a browser means one
// screenshot and one coordinate click per step. This pumps each screen in a
// widget test instead and writes what it drew, at phone size in the dark
// theme plus a handful in the light theme, in German, at 150% text and at
// desktop width. About seventy images in under a minute.
//
// It lives in tool/ rather than test/ so `flutter test` does not run it.
//
//   flutter test tool/audit/capture_screens.dart --update-goldens //       --dart-define=SHOTS=/absolute/output/folder
//
// Limits: emoji have no font here and draw as empty boxes, so this says
// nothing about how emoji look on a device. Audio and the microphone are off.
// Each image is a screen's first state unless the entry has an `act`.
// A few entries (match pairs, the speaking lesson, the pronunciation lab)
// report a failure after their image is written, because the screen still
// has a timer running when the test ends. Their images are valid; the run
// exits non-zero. The review-card entry currently writes a black image.
// ignore_for_file: avoid_print, invalid_use_of_visible_for_testing_member
import 'dart:io';

import 'package:deutsch_garden/app.dart';
import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/audio_course_screens.dart';
import 'package:deutsch_garden/civics_test.dart';
import 'package:deutsch_garden/civics_test_screens.dart';
import 'package:deutsch_garden/conversation.dart';
import 'package:deutsch_garden/conversation_screens.dart';
import 'package:deutsch_garden/course.dart';
import 'package:deutsch_garden/course_screens.dart';
import 'package:deutsch_garden/curriculum.dart';
import 'package:deutsch_garden/driving_test_screens.dart';
import 'package:deutsch_garden/games.dart';
import 'package:deutsch_garden/grammar_challenge.dart';
import 'package:deutsch_garden/l10n/app_localizations.dart';
import 'package:deutsch_garden/mini_story.dart';
import 'package:deutsch_garden/mini_story_screens.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/radio.dart';
import 'package:deutsch_garden/radio_screens.dart';
import 'package:deutsch_garden/screens.dart';
import 'package:deutsch_garden/skill_screens.dart';
import 'package:deutsch_garden/speaking_curriculum.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/stories.dart';
import 'package:deutsch_garden/story_screens.dart';
import 'package:deutsch_garden/study_session.dart';
import 'package:deutsch_garden/test_screens.dart';
import 'package:deutsch_garden/vocabulary_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const String out = String.fromEnvironment('SHOTS');

ThemeData theme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7C5CFC),
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF101116)
        : const Color(0xFFF6F6FA),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}

Future<void> loadFonts() async {
  final String root = Platform.environment['FLUTTER_ROOT'] ?? 'C:/flutter';
  final String dir = '$root/bin/cache/artifacts/material_fonts/';
  ByteData bytes(String f) =>
      ByteData.view(File('$dir$f').readAsBytesSync().buffer);
  final roboto = FontLoader('Roboto');
  for (final f in [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-black.ttf',
    'roboto-light.ttf',
    'roboto-italic.ttf',
  ]) {
    roboto.addFont(Future.value(bytes(f)));
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(bytes('materialicons-regular.otf')));
  await icons.load();
}

void main() {
  setUpAll(loadFonts);
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  tearDown(() => AppController.debounceWrites = true);

  Future<AppController> boot() async {
    final c = AppController();
    addTearDown(c.dispose);
    await c.load();
    c.ttsEnabled = false;
    await c.completeOnboarding();
    // A little history so screens are not all empty states.
    final words = c.wordsForLevel(CefrLevel.a1);
    for (int i = 0; i < 12; i++) {
      await c.gradeWord(
        words[i],
        i % 4 == 0 ? ReviewGrade.again : ReviewGrade.good,
      );
    }
    await c.addMistake(
      MistakeEntry(
        id: 'vocab-${words[0].id}',
        prompt: 'What does this mean?',
        correctAnswer: words[0].english,
        givenAnswer: words[1].english,
        source: 'vocabulary',
        level: 'A1',
        timestamp: DateTime(2026, 11, 12),
      ),
    );
    return c;
  }

  Future<void> settle(WidgetTester tester) async {
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pump(const Duration(milliseconds: 250));
  }

  void shot(
    String name,
    Widget Function(AppController c) build, {
    Brightness brightness = Brightness.dark,
    String locale = 'en',
    Size size = const Size(375, 812),
    double scale = 1,
    bool wholeApp = false,
    Future<void> Function(WidgetTester tester)? act,
  }) {
    testWidgets(name, (tester) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = await tester.runAsync(boot) as AppController;
      if (wholeApp) {
        c.themeMode = brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light;
      }
      final Widget app = wholeApp
          ? build(c)
          : MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: Locale(locale),
              supportedLocales: AppText.supportedLocales,
              localizationsDelegates: AppText.localizationsDelegates,
              theme: theme(brightness),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: build(c),
            );
      await tester.pumpWidget(RepaintBoundary(child: app));
      await settle(tester);
      if (act != null) {
        try {
          await act(tester);
        } catch (e) {
          print('ACT FAILED $name: $e');
        }
        await settle(tester);
      }
      final Object? overflow = tester.takeException();
      if (overflow != null) {
        print('EXCEPTION $name: ${overflow.toString().split('\n').first}');
      }
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile(Uri.file('$out/$name.png')),
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });
  }

  Future<void> tapFirst(WidgetTester tester, Finder f) async {
    await tester.tap(f.first, warnIfMissed: false);
  }

  Widget scaffold(Widget body, [String title = '']) => Scaffold(
    appBar: title.isEmpty ? null : AppBar(title: Text(title)),
    body: body,
  );

  const a1 = CefrLevel.a1;

  // Games
  shot('g01_match_pairs', (c) => MatchPairsScreen(controller: c, level: a1));
  shot(
    'g02_sentence_builder',
    (c) => SentenceBuilderScreen(controller: c, level: a1),
  );
  shot('g03_dictation', (c) => DictationScreen(controller: c, level: a1));
  shot('g04_speed_review', (c) => SpeedReviewScreen(controller: c, level: a1));
  shot(
    'g05_article_trainer',
    (c) => ArticleTrainerScreen(controller: c, level: a1),
  );
  shot(
    'g06_article_answered',
    (c) => ArticleTrainerScreen(controller: c, level: a1),
    act: (t) => tapFirst(t, find.text('DER')),
  );
  shot('g07_verb_lab', (c) => VerbLabScreen(controller: c, level: a1));
  shot('g08_cloze', (c) => ClozeDrillScreen(controller: c, level: a1));
  shot(
    'g09_cloze_answered',
    (c) => ClozeDrillScreen(controller: c, level: a1),
    act: (t) => tapFirst(t, find.byType(OutlinedButton)),
  );
  shot('g10_shadow_lab', (c) => ShadowLabScreen(controller: c, level: a1));
  shot('g11_grammar_hub', (c) => GrammarChallengeHubScreen(controller: c));
  shot(
    'g12_grammar_drill',
    (c) => GrammarChallengeDrillScreen(
      controller: c,
      feature: GrammarFeature.values.first,
    ),
  );
  shot(
    'g13_grammar_drill_answered',
    (c) => GrammarChallengeDrillScreen(
      controller: c,
      feature: GrammarFeature.values.first,
    ),
    act: (t) => tapFirst(t, find.byType(OutlinedButton)),
  );
  shot('g14_mistake_bank', (c) => MistakeBankScreen(controller: c));
  shot('g15_difficult_words', (c) => DifficultWordsScreen(controller: c));
  shot(
    'g16_review_revealed',
    (c) => ReviewSessionScreen(controller: c),
    act: (t) => tapFirst(t, find.byType(FilledButton)),
  );

  // Tests
  shot('t01_test_hub', (c) => TestHubHostScreen(controller: c));
  shot('t02_placement_intro', (c) => PlacementIntroScreen(controller: c));
  shot('t03_placement_question', (c) => PlacementTestScreen(controller: c));
  shot('t04_exam_prep', (c) => ExamLevelPrepScreen(controller: c, level: a1));
  shot('t05_civics_hub', (c) => CivicsHubScreen(controller: c));
  shot('t08_driving_hub', (c) => DrivingTheoryScreen(controller: c));
  shot('t09_driving_practice', (c) => DrivingPracticeScreen(controller: c));
  shot(
    't10_driving_answered',
    (c) => DrivingPracticeScreen(controller: c),
    act: (t) => tapFirst(t, find.byType(OutlinedButton)),
  );
  shot(
    't11_checkpoint',
    (c) => CheckpointScreen(controller: c, unit: unitsFor(a1).first),
  );

  testWidgets('t06_t07_civics_practice', (tester) async {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final c = await tester.runAsync(boot) as AppController;
    final catalog = await tester.runAsync(CivicsCatalog.load) as CivicsCatalog;
    await tester.pumpWidget(
      RepaintBoundary(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          supportedLocales: AppText.supportedLocales,
          localizationsDelegates: AppText.localizationsDelegates,
          theme: theme(Brightness.dark),
          home: CivicsPracticeScreen(
            controller: c,
            catalog: catalog,
            stateCode: 'BE',
          ),
        ),
      ),
    );
    await settle(tester);
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile(Uri.file('$out/t06_civics_practice.png')),
    );
    try {
      await tester.tap(find.byType(OutlinedButton).first, warnIfMissed: false);
    } catch (e) {
      print('ACT FAILED civics: $e');
    }
    await settle(tester);
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile(Uri.file('$out/t07_civics_answered.png')),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  // Media
  final story = storiesFor(a1).first;
  shot('m01_story_library', (c) => StoryLibraryScreen(controller: c));
  shot(
    'm02_story_detail',
    (c) => StoryDetailScreen(controller: c, story: story),
  );
  shot(
    'm03_story_reader',
    (c) => StoryReaderScreen(controller: c, story: story, chapterIndex: 0),
  );
  shot(
    'm04_mini_story',
    (c) => MiniStoryDrillScreen(controller: c, drill: miniStoryDrills.first),
  );
  shot(
    'm05_radio_library',
    (c) => RadioLibraryScreen(controller: c, level: a1),
  );
  shot(
    'm06_radio_episode',
    (c) => RadioEpisodeScreen(controller: c, episode: radioFor(a1).first),
  );
  shot('m07_audio_course', (c) => AudioCourseScreen(controller: c, level: a1));

  // Skills
  shot(
    's01_level_dashboard',
    (c) => LevelDashboardScreen(controller: c, level: a1),
  );
  shot(
    's02_vocab_level',
    (c) => VocabularyLevelScreen(controller: c, level: a1),
  );
  shot('s03_vocab_library', (c) => VocabularyLibraryScreen(controller: c));
  shot('s04_grammar_handbook', (c) => GrammarHandbookScreen(controller: c));
  shot(
    's05_grammar_lesson_intro',
    (c) => GrammarLessonScreen(controller: c, lesson: grammarLessons.first),
  );
  shot(
    's06_listening_lesson',
    (c) => ListeningLessonScreen(controller: c, lesson: listeningLessons.first),
  );
  shot(
    's07_reading_lesson',
    (c) => ReadingLessonScreen(controller: c, lesson: readingLessons.first),
  );
  shot(
    's08_writing_lesson',
    (c) => WritingLessonScreen(controller: c, lesson: writingLessons.first),
  );
  shot(
    's09_speaking_lesson',
    (c) => SpeakingLessonScreen(controller: c, lesson: speakingLessons.first),
  );
  shot(
    's10_speak_hub',
    (c) => scaffold(SpeakHubScreen(controller: c), 'Speaking'),
  );
  shot(
    's11_conversation',
    (c) =>
        ConversationScreen(controller: c, scenario: conversationsFor(a1).first),
  );
  shot(
    's12_free_talk',
    (c) => FreeTalkScreen(controller: c, prompt: freeTalkFor(a1).first),
  );
  shot(
    's13_pronunciation_lab',
    (c) => PronunciationLabScreen(controller: c, level: a1),
  );
  shot(
    's14_course_map',
    (c) => scaffold(CourseScreen(controller: c), 'Course map'),
  );

  // Profile
  shot(
    'p01_stats',
    (c) => scaffold(StatsScreen(controller: c), 'Detailed progress'),
  );
  shot('p02_settings', (c) => SettingsScreen(controller: c));
  shot('p03_achievements', (c) => AchievementsScreen(controller: c));
  shot('p04_profile', (c) => scaffold(ProfileScreen(controller: c)));

  // Light theme
  for (final e in <String, Widget Function(AppController)>{
    'l01_light_shell': (c) => MainShell(controller: c),
    'l02_light_flashcard': (c) =>
        StudySessionScreen(controller: c, kind: SessionKind.learn, level: a1),
    'l03_light_settings': (c) => SettingsScreen(controller: c),
    'l04_light_story_reader': (c) =>
        StoryReaderScreen(controller: c, story: story, chapterIndex: 0),
    'l05_light_article': (c) => ArticleTrainerScreen(controller: c, level: a1),
    'l06_light_stats': (c) =>
        scaffold(StatsScreen(controller: c), 'Detailed progress'),
  }.entries) {
    shot(e.key, e.value, brightness: Brightness.light);
  }
  shot(
    'l07_light_quiz_answered',
    (c) =>
        StudySessionScreen(controller: c, kind: SessionKind.learn, level: a1),
    brightness: Brightness.light,
    act: (t) async {
      await t.tap(find.text('Got it — test me'));
      await t.pump(const Duration(milliseconds: 400));
      await t.sendKeyEvent(LogicalKeyboardKey.digit1);
    },
  );

  // German interface
  shot('d01_de_shell', (c) => MainShell(controller: c), locale: 'de');
  shot('d02_de_settings', (c) => SettingsScreen(controller: c), locale: 'de');
  shot(
    'd03_de_test_hub',
    (c) => TestHubHostScreen(controller: c),
    locale: 'de',
  );
  shot(
    'd04_de_big_text_shell',
    (c) => MainShell(controller: c),
    locale: 'de',
    scale: 1.5,
  );

  // Desktop width
  shot(
    'w01_desktop_learn',
    (c) => DeutschGardenApp(controller: c),
    size: const Size(1280, 800),
    wholeApp: true,
  );
  shot(
    'w02_desktop_explore',
    (c) => DeutschGardenApp(controller: c),
    size: const Size(1280, 800),
    wholeApp: true,
    act: (t) => tapFirst(t, find.text('Explore')),
  );
  shot(
    'w03_desktop_profile',
    (c) => DeutschGardenApp(controller: c),
    size: const Size(1280, 800),
    wholeApp: true,
    act: (t) => tapFirst(t, find.text('Profile')),
  );
  shot(
    'w04_desktop_flashcard',
    (c) =>
        StudySessionScreen(controller: c, kind: SessionKind.learn, level: a1),
    size: const Size(1280, 800),
  );
  shot(
    'w05_desktop_story',
    (c) => StoryReaderScreen(controller: c, story: story, chapterIndex: 0),
    size: const Size(1280, 800),
  );
  shot(
    'w06_desktop_settings',
    (c) => SettingsScreen(controller: c),
    size: const Size(1280, 800),
  );
}
