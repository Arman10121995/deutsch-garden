import 'dart:async';

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/curriculum.dart';
import 'package:deutsch_garden/games.dart';
import 'package:deutsch_garden/glosses.dart';
import 'package:deutsch_garden/l10n/app_localizations.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/permissions_screen.dart';
import 'package:deutsch_garden/skill_screens.dart';
import 'package:deutsch_garden/speaking_curriculum.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/study_session.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:deutsch_garden/vocabulary_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class DelayedGradeController extends AppController {
  final Completer<void> gate = Completer<void>();
  int gradeCalls = 0;

  @override
  Future<void> gradeWord(GermanWord word, ReviewGrade grade) async {
    gradeCalls++;
    await gate.future;
    await super.gradeWord(word, grade);
  }
}

class DelayedActivityController extends AppController {
  final Completer<void> gate = Completer<void>();
  int activityCalls = 0;

  @override
  Future<void> recordActivity(
    String activityId, {
    required int score,
    int passingScore = 70,
  }) async {
    activityCalls++;
    await gate.future;
    await super.recordActivity(
      activityId,
      score: score,
      passingScore: passingScore,
    );
  }
}

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    debugSetVocabIcons(const <String>[]);
    debugClearGlosses();
  });

  tearDown(() {
    AppController.debounceWrites = true;
    debugResetVocabIcons();
    debugClearGlosses();
  });

  Future<AppController> boot() async {
    final controller = AppController();
    addTearDown(controller.dispose);
    await controller.load();
    controller.ttsEnabled = false;
    return controller;
  }

  VoidCallback submitButton(WidgetTester tester, String label) => tester
      .widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate(
            (widget) => widget is ButtonStyleButton,
          ),
        ),
      )
      .onPressed!;

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
    await tester.pumpAndSettle();
  }

  testWidgets(
    'writing drafts survive leaving and reopening without evaluation',
    (tester) async {
      final controller = await boot();
      final lesson = writingLessons.first;
      const draft = 'Ich wohne in einer kleinen Wohnung.';
      await show(
        tester,
        WritingLessonScreen(controller: controller, lesson: lesson),
      );
      await tester.enterText(find.byType(TextField), draft);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await controller.flushSave();
      expect(controller.progressForActivity(lesson.id).attempts, 0);

      final restored = await boot();
      await show(
        tester,
        WritingLessonScreen(controller: restored, lesson: lesson),
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        draft,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'typed speaking drafts resume without counting as a completed attempt',
    (tester) async {
      final controller = await boot();
      final lesson = speakingLessons.first;
      const draft = 'Guten Tag, ich möchte mich vorstellen.';
      await show(
        tester,
        SpeakingLessonScreen(controller: controller, lesson: lesson),
      );
      await tester.enterText(find.byType(TextField), draft);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await controller.flushSave();
      expect(controller.progressForActivity(lesson.id).attempts, 0);

      final restored = await boot();
      await show(
        tester,
        SpeakingLessonScreen(controller: restored, lesson: lesson),
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        draft,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('rapid review grades record one event and advance one card', (
    tester,
  ) async {
    final controller = DelayedGradeController();
    addTearDown(controller.dispose);
    await controller.load();
    controller.ttsEnabled = false;
    await controller.markSeen(vocabulary[0]);
    await controller.markSeen(vocabulary[1]);
    await show(tester, ReviewSessionScreen(controller: controller));
    await tester.tap(find.textContaining('Show answer'));
    await tester.pumpAndSettle();
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Good'),
    );
    button.onPressed!();
    button.onPressed!();
    final calls = controller.gradeCalls;
    controller.gate.complete();
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(controller.reviewLog, hasLength(1));
    expect(find.textContaining('Show answer'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('library accepts German ASCII spelling and the article', (
    tester,
  ) async {
    final controller = await boot();
    await show(tester, VocabularyLibraryScreen(controller: controller));
    final girl = vocabulary.firstWhere((word) => word.german == 'Mädchen');
    await tester.enterText(find.byType(TextField), 'das Maedchen');
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey<String>('word-${girl.id}')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'favorites results refresh immediately when a favorite is removed',
    (tester) async {
      final controller = await boot();
      await controller.toggleFavorite(vocabulary.first.id);
      await show(tester, VocabularyLibraryScreen(controller: controller));
      await tester.ensureVisible(find.text('Favorites'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilterChip>(find.byType(FilterChip)).selected,
        isTrue,
      );
      await tester.tap(find.byTooltip('Remove from favorites'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(ValueKey<String>('word-${vocabulary.first.id}')),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('each written or typed speaking submission is recorded once', (
    tester,
  ) async {
    for (final bool writing in <bool>[true, false]) {
      final controller = DelayedActivityController();
      addTearDown(controller.dispose);
      await controller.load();
      controller.ttsEnabled = false;
      final String id = writing
          ? writingLessons.first.id
          : speakingLessons.first.id;
      await show(
        tester,
        writing
            ? WritingLessonScreen(
                controller: controller,
                lesson: writingLessons.first,
              )
            : SpeakingLessonScreen(
                controller: controller,
                lesson: speakingLessons.first,
              ),
      );
      await tester.enterText(
        find.byType(TextField),
        writingLessons.first.example,
      );
      await tester.pumpAndSettle();
      final String label = writing
          ? 'Save & evaluate writing'
          : 'Check transcript or typed answer';
      await tester.scrollUntilVisible(
        find.text(label),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      final int previousEvents = controller.reviewLog.length;
      final VoidCallback submit = submitButton(tester, label);
      submit();
      submit();
      await tester.pump();
      final int calls = controller.activityCalls;
      controller.gate.complete();
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(controller.progressForActivity(id).attempts, 1);
      expect(controller.reviewLog, hasLength(previousEvents + 1));
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('a failed microphone start preserves the typed draft', (
    tester,
  ) async {
    final controller = await boot();
    await show(
      tester,
      SpeakingLessonScreen(
        controller: controller,
        lesson: speakingLessons.first,
      ),
    );
    const draft = 'Ich möchte meinen Entwurf behalten.';
    await tester.enterText(find.byType(TextField), draft);
    await tester.pumpAndSettle();
    submitButton(tester, 'Start speaking')();
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      draft,
    );
    expect(
      controller.progressForActivity(speakingLessons.first.id).draft,
      draft,
    );
    await tester.pumpWidget(const SizedBox());
  }, variant: TargetPlatformVariant(<TargetPlatform>{TargetPlatform.linux}));

  testWidgets(
    'a wrong vocabulary choice records the answer actually selected',
    (tester) async {
      final controller = DelayedGradeController();
      addTearDown(controller.dispose);
      await controller.load();
      controller.ttsEnabled = false;
      final word = controller.newWordsForLevel(CefrLevel.a1).first;
      await show(
        tester,
        StudySessionScreen(
          controller: controller,
          kind: SessionKind.learn,
          level: CefrLevel.a1,
        ),
      );
      submitButton(tester, 'Got it — test me')();
      await tester.pumpAndSettle();
      final options = tester
          .widgetList<OutlinedButton>(find.byType(OutlinedButton))
          .where(
            (button) =>
                button.child is Padding &&
                (button.child! as Padding).child is Text,
          );
      final wrong = options.firstWhere(
        (button) =>
            ((button.child! as Padding).child! as Text).data != word.english,
      );
      final chosen = ((wrong.child! as Padding).child! as Text).data!;
      wrong.onPressed!();
      wrong.onPressed!();
      final calls = controller.gradeCalls;
      controller.gate.complete();
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(controller.mistakes.single.givenAnswer, chosen);
      expect(controller.mistakes.single.correctAnswer, word.english);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('selected glosses are displayed, searched and refreshed live', (
    tester,
  ) async {
    final controller = await boot();
    final word = vocabulary.first;
    debugSetGlosses('tr', <String, String>{word.id: 'adam'});
    await controller.setGlossLanguage('tr');
    await show(tester, VocabularyLibraryScreen(controller: controller));
    expect(find.textContaining('adam ·'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'adam');
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey<String>('word-${word.id}')), findsOneWidget);
    await controller.setGlossLanguage('');
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey<String>('word-${word.id}')), findsNothing);
    await tester.pumpWidget(const SizedBox());

    await controller.setGlossLanguage('tr');
    await show(
      tester,
      VocabularyLevelScreen(controller: controller, level: CefrLevel.a1),
    );
    await tester.scrollUntilVisible(
      find.byType(TextField),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'adam');
    await tester.pumpAndSettle();
    expect(find.textContaining('adam ·'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('German search and reset controls work on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await boot();
    await show(
      tester,
      VocabularyLibraryScreen(controller: controller),
      locale: 'de',
    );
    expect(find.text('Wortschatzbibliothek'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      'does-not-exist-in-the-deck',
    );
    await tester.pumpAndSettle();
    expect(find.text('Keine passenden Wörter'), findsOneWidget);
    await tester.tap(find.text('Filter zurücksetzen'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(find.text('Keine passenden Wörter'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('permissions and time goals respect German interface selection', (
    tester,
  ) async {
    final controller = await boot();
    await show(
      tester,
      PermissionsAndDownloadsScreen(controller: controller),
      locale: 'de',
    );
    expect(find.text('Berechtigungen und Downloads'), findsOneWidget);
    expect(find.text('Mikrofon'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Tägliches Zeitziel'), 200);
    expect(find.text('Tägliches Zeitziel'), findsOneWidget);
    expect(find.text('Wöchentliches Zeitziel'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
