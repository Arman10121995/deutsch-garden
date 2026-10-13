import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/asr.dart';
import 'package:deutsch_garden/asr_settings.dart';
import 'package:deutsch_garden/course.dart';
import 'package:deutsch_garden/course_screens.dart';
import 'package:deutsch_garden/l10n/app_localizations.dart';
import 'package:deutsch_garden/learning_path.dart';
import 'package:deutsch_garden/learning_path_screen.dart';
import 'package:deutsch_garden/learning_path_text.dart';
import 'package:deutsch_garden/lesson_registry.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'asr_controller_test.dart' show FakeRecogniser;

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  tearDown(() => AppController.debounceWrites = true);

  Future<AppController> boot() async {
    final AppController controller = AppController();
    await controller.load();
    addTearDown(controller.dispose);
    return controller;
  }

  Widget host(Widget screen, {double scale = 1}) => MaterialApp(
    locale: const Locale('de'),
    supportedLocales: AppText.supportedLocales,
    localizationsDelegates: AppText.localizationsDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: screen,
  );

  void narrow(WidgetTester tester) {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Learn translates its computed actions, drills and quests', (
    tester,
  ) async {
    narrow(tester);
    final controller = await boot();
    await tester.pumpWidget(
      host(
        Scaffold(body: LearningPathScreen(controller: controller)),
        scale: 1.5,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Deutsch lernen'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Lerneinheit starten'), 150);
    await tester.pumpAndSettle();
    expect(find.text('Lerneinheit starten'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Dein heutiger Fortschritt'),
      180,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dein heutiger Fortschritt'));
    await tester.pumpAndSettle();
    late AppText t;
    t = AppText.of(tester.element(find.byType(LearningPathScreen)));
    for (final quest in controller.todaysQuests) {
      await tester.scrollUntilVisible(find.text(questTitle(t, quest)), 150);
      expect(find.text(questTitle(t, quest)), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('action counts and multipart state survive translation', (
    tester,
  ) async {
    late AppText t;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) {
            t = AppText.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    final plan = buildLearningPath(
      status: courseStatus(
        activities: {},
        wordsSeenByLevel: {},
        placementLevel: CefrLevel.a1,
      ),
      activities: {},
      dueWords: 23,
      dueLessons: [],
      mistakeCount: 1,
      preferredLevel: CefrLevel.a1,
    );
    final review = plan.actions.first;
    expect(review.localizedTitle(t), '20 fällige Wörter wiederholen');
    expect(
      review.localizedSubtitle(t),
      '23 Wörter sind fällig; beginne mit 20 davon.',
    );
    final repair = plan.actions.firstWhere(
      (a) => a.kind == LearningPathActionKind.mistakeRepair,
    );
    expect(repair.localizedTitle(t), '1 Fehler nacharbeiten');
    final unit = courseUnits.firstWhere(
      (u) => u.steps.any((s) => s.kind == CourseStepKind.story),
    );
    final step = unit.steps.firstWhere((s) => s.kind == CourseStepKind.story);
    final action = LearningPathAction(
      id: 'story',
      kind: LearningPathActionKind.courseStep,
      title: step.title,
      subtitle: '',
      estimatedMinutes: 10,
      unit: unit,
      step: step,
      partsDone: 1,
      partsTotal: 3,
    );
    expect(action.localizedSubtitle(t), contains('Kapitel 2 von 3'));
    expect(action.localizedTitle(t), step.title);
    for (final drill in PracticeDrill.values) {
      expect(drillTitle(t, drill), isNotEmpty);
      expect(drillDescription(t, drill), isNot(drill.blurb));
    }
    for (final lesson in allLessons.take(1)) {
      expect(skillText(t, lesson.skill), isNot(lesson.skill.label));
    }
  });

  testWidgets('German course controls fit narrow screens and large text', (
    tester,
  ) async {
    narrow(tester);
    final controller = await boot();
    await tester.pumpWidget(
      host(
        CourseUnitScreen(controller: controller, unit: courseUnits.first),
        scale: 1.5,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('A1 · Einheit 1'), findsOneWidget);
    expect(find.text('Am Ende dieser Einheit'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Lernkontrolle starten'), 220);
    await tester.pumpAndSettle();
    expect(find.text('Lernkontrolle starten'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('German checkpoint results stay reachable at large text', (
    tester,
  ) async {
    narrow(tester);
    final controller = await boot();
    final unit = courseUnits.first;
    await tester.pumpWidget(
      host(CheckpointScreen(controller: controller, unit: unit), scale: 1.5),
    );
    await tester.pumpAndSettle();
    for (int i = 0; i < unit.checkpoint.length; i++) {
      final q = unit.checkpoint[i];
      final choice = find
          .widgetWithText(OutlinedButton, q.options[q.correctIndex])
          .first;
      await tester.scrollUntilVisible(choice, 150);
      await tester.pumpAndSettle();
      await tester.tap(choice);
      await tester.pumpAndSettle();
      final next = find.text(
        i + 1 < unit.checkpoint.length ? 'Weiter' : 'Abschließen',
      );
      await tester.scrollUntilVisible(next, 150);
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text('100%'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Zurück zur Einheit'), 150);
    await tester.pumpAndSettle();
    expect(find.text('Zurück zur Einheit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final state in [AsrModelState.absent, AsrModelState.ready]) {
    testWidgets('German speech settings explain $state at large text', (
      tester,
    ) async {
      narrow(tester);
      final controller = AppController()
        ..recogniser = FakeRecogniser(state: state);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          Scaffold(
            body: ListView(children: [AsrModelCard(controller: controller)]),
          ),
          scale: 1.5,
        ),
      );
      await tester.pumpAndSettle();
      final action = find.text(
        state == AsrModelState.ready
            ? 'Modell entfernen'
            : 'Sprachmodell herunterladen',
      );
      await tester.scrollUntilVisible(action, 150);
      await tester.pumpAndSettle();
      expect(action, findsOneWidget);
      if (state == AsrModelState.ready) {
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(find.text('Sprachmodell entfernen?'), findsOneWidget);
        expect(find.text('Behalten'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
