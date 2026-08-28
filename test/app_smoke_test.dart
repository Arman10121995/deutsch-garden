import 'package:deutsch_garden/app.dart';
import 'package:deutsch_garden/app_state.dart';
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

  testWidgets('the app boots and every bottom-bar tab renders', (tester) async {
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    // Learn is the single default path.
    expect(find.text('Learn German'), findsOneWidget);
    expect(find.text('NEXT UP · ~8 MIN'), findsOneWidget);

    for (final String label in <String>['Explore', 'Profile']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    expect(find.text('Profil'), findsOneWidget);
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

    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await tester.pumpAndSettle();

    expect(find.text('A1 • Learn new words'), findsOneWidget);
    expect(find.textContaining('Vocabulary Bank'), findsNothing);
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
