import 'package:deutsch_garden/app.dart';
import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('the app boots and every bottom-bar tab renders', (tester) async {
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    // Learn tab.
    expect(find.text('DeutschGarden'), findsOneWidget);
    expect(find.text('Tagesaufgaben'), findsOneWidget);

    for (final String label in <String>['Speak', 'Stories', 'Practice', 'Profile']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('a fresh install starts at A1 with everything above it locked',
      (tester) async {
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    expect(controller.highestUnlockedLevel.label, 'A1');
    expect(controller.isLevelUnlocked(CefrLevel.a1), isTrue);
    expect(controller.isLevelUnlocked(CefrLevel.a2), isFalse);
  });

  testWidgets('the speaking hub lists role-plays for the current level',
      (tester) async {
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Speak'));
    await tester.pumpAndSettle();
    expect(find.text('Im Café'), findsOneWidget);
    expect(find.text('Pronunciation lab'), findsOneWidget);
  });

  testWidgets('the story library lists A1 stories', (tester) async {
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(DeutschGardenApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stories'));
    await tester.pumpAndSettle();
    expect(find.text('Der erste Tag in Rostock'), findsOneWidget);
  });
}
