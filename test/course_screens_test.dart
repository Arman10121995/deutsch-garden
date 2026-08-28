import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/course.dart';
import 'package:deutsch_garden/course_screens.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<AppController> boot() async {
    final AppController controller = AppController();
    await controller.load();
    return controller;
  }

  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('a unit shows what it is for and what it contains', (
    WidgetTester tester,
  ) async {
    final AppController controller = await boot();
    final CourseUnit unit = courseUnits.first;

    await tester.pumpWidget(
      wrap(CourseUnitScreen(controller: controller, unit: unit)),
    );
    await tester.pumpAndSettle();

    expect(find.text(unit.title), findsOneWidget);
    expect(find.text(unit.canDo), findsOneWidget);
    // The compact core is visible; the rest stays attached as enrichment.
    expect(find.text('Grammar'), findsWidgets);
    expect(find.textContaining('Core path'), findsOneWidget);
    expect(
      find.textContaining('of ${unit.wordTarget} A1 words met'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(find.text('Extra practice'), 200);
    expect(find.text('Extra practice'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Checkpoint'), 200);
    expect(find.text('Checkpoint'), findsOneWidget);
    expect(find.text('Start the checkpoint'), findsOneWidget);
  });

  testWidgets(
    'answering the checkpoint correctly passes and unlocks the next',
    (WidgetTester tester) async {
      final AppController controller = await boot();
      final CourseUnit unit = courseUnits.first;

      await tester.pumpWidget(
        wrap(CheckpointScreen(controller: controller, unit: unit)),
      );
      await tester.pumpAndSettle();

      for (int i = 0; i < unit.checkpoint.length; i++) {
        final ChoiceQuestion q = unit.checkpoint[i];
        await tester.tap(
          find.widgetWithText(OutlinedButton, q.options[q.correctIndex]).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(i + 1 < unit.checkpoint.length ? 'Next' : 'Finish'),
        );
        await tester.pumpAndSettle();
      }

      expect(find.text('100%'), findsOneWidget);
      // The outcome is restated on passing, which is the point of writing it.
      expect(find.text(unit.canDo), findsOneWidget);

      final List<CourseUnitStatus> status = courseStatus(
        activities: controller.activities,
        wordsSeenByLevel: controller.wordsSeenByLevel,
        placementLevel: controller.highestUnlockedLevel,
      );
      expect(status[0].checkpointPassed, isTrue);
      expect(status[1].unlocked, isTrue);
    },
  );

  testWidgets('a failed checkpoint does not unlock, and the misses are kept', (
    WidgetTester tester,
  ) async {
    final AppController controller = await boot();
    final CourseUnit unit = courseUnits.first;

    await tester.pumpWidget(
      wrap(CheckpointScreen(controller: controller, unit: unit)),
    );
    await tester.pumpAndSettle();

    for (int i = 0; i < unit.checkpoint.length; i++) {
      final ChoiceQuestion q = unit.checkpoint[i];
      // Answer everything wrong on purpose.
      final int wrong = q.correctIndex == 0 ? 1 : 0;
      await tester.tap(
        find.widgetWithText(OutlinedButton, q.options[wrong]).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(i + 1 < unit.checkpoint.length ? 'Next' : 'Finish'),
      );
      await tester.pumpAndSettle();
    }

    expect(find.text('0%'), findsOneWidget);

    final List<CourseUnitStatus> status = courseStatus(
      activities: controller.activities,
      wordsSeenByLevel: controller.wordsSeenByLevel,
      placementLevel: controller.highestUnlockedLevel,
    );
    expect(status[0].checkpointPassed, isFalse);
    expect(status[1].unlocked, isFalse);

    // A checkpoint is the one thing that can block progress, so what blocked
    // it has to be reviewable rather than merely reported.
    expect(controller.mistakes, hasLength(unit.checkpoint.length));
    expect(controller.mistakes.first.source, 'checkpoint');
  });

  testWidgets('the course lays out on a small phone without overflowing', (
    WidgetTester tester,
  ) async {
    // A RenderFlex overflow throws in a test, so rendering at 360x640 without
    // an exception is the assertion. Worth having: the course map stacks a
    // progress card, six expansion tiles and twelve unit rows with long
    // German-ish titles, and the unit screen puts a whole can-do sentence in
    // a card.
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppController controller = await boot();
    await tester.pumpWidget(
      wrap(Scaffold(body: CourseScreen(controller: controller))),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      wrap(CourseUnitScreen(controller: controller, unit: courseUnits.first)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // And the longest can-do in the course, not just the first one.
    final CourseUnit longest = courseUnits.reduce(
      (CourseUnit a, CourseUnit b) => b.canDo.length > a.canDo.length ? b : a,
    );
    await tester.pumpWidget(
      wrap(CourseUnitScreen(controller: controller, unit: longest)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the course map locks everything past the first unit', (
    WidgetTester tester,
  ) async {
    final AppController controller = await boot();

    await tester.pumpWidget(
      wrap(Scaffold(body: CourseScreen(controller: controller))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Continue'), findsOneWidget);
    expect(
      find.text('Pass the checkpoint before this to open it'),
      findsWidgets,
    );
  });
}
