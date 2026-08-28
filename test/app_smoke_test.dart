import 'package:deutsch_garden/app.dart';
import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    debugResetVocabIcons();
    await loadVocabIconIndex(rootBundle);
  });

  testWidgets('the app boots and every bottom-bar tab renders', (tester) async {
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    // Learn is the single default path.
    expect(find.text('Learn German'), findsOneWidget);
    expect(find.text('NEXT UP · 1 STEP · ~8 MIN'), findsOneWidget);

    for (final String label in <String>['Explore', 'Profile']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Vocabulary library'), findsNothing);
  });

  testWidgets('a fresh install starts at A1 with everything above it locked', (
    tester,
  ) async {
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    expect(controller.highestUnlockedLevel.label, 'A1');
    expect(controller.isLevelUnlocked(CefrLevel.a1), isTrue);
    expect(controller.isLevelUnlocked(CefrLevel.a2), isFalse);
  });

  testWidgets('the speaking hub lists role-plays for the current level', (
    tester,
  ) async {
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('A1 libraries'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('A1 libraries'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Speaking studio'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Speaking studio'));
    await tester.pumpAndSettle();
    expect(find.text('Im Café'), findsOneWidget);
    expect(find.text('Pronunciation lab'), findsOneWidget);
  });

  testWidgets('the story library is reachable from Explore', (tester) async {
    // Browse-only content is grouped rather than competing with Learn.
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('A1 libraries'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('A1 libraries'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Story library'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Story library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Story library'));
    await tester.pumpAndSettle();
    expect(find.text('Der erste Tag in Rostock'), findsOneWidget);
  });

  testWidgets('the course opens on the first unit and gates the rest', (
    tester,
  ) async {
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Full course map'), 250);
    await tester.ensureVisible(find.text('Full course map'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Full course map'));
    await tester.pumpAndSettle();

    expect(find.text('Continue'), findsOneWidget);
    expect(find.textContaining('Saying who you are'), findsWidgets);
    // A fresh learner must not be able to walk into unit two.
    expect(
      find.text('Pass the checkpoint before this to open it'),
      findsWidgets,
    );
  });

  testWidgets('Learn starts the next activity directly', (tester) async {
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Start next activity'));
    await tester.pumpAndSettle();

    expect(find.text('A1 • Learn new words'), findsOneWidget);
    expect(find.textContaining('Vocabulary Bank'), findsNothing);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('a completed step offers the recalculated next guided step', (
    tester,
  ) async {
    final AppController controller = AppController();
    await controller.load();
    await controller.markSeen(vocabulary.first);
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Start guided session'));
    await tester.pumpAndSettle();
    expect(find.text('Review 1/1'), findsOneWidget);

    await tester.tap(find.text('Show answer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Next in your guided session'), findsOneWidget);
    expect(find.text('Continue session'), findsOneWidget);
    expect(find.text('Finish for now'), findsOneWidget);
  });

  testWidgets('the vocabulary library and its drawings live in Explore', (
    tester,
  ) async {
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('A1 libraries'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('A1 libraries'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Vocabulary library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vocabulary library'));
    await tester.pumpAndSettle();

    expect(find.text('10000 bundled words · A1 to C2'), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);
  });

  testWidgets('the three-area shell fits a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
