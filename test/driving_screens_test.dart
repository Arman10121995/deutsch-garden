import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/driving_test_screens.dart';
import 'package:deutsch_garden/test_screens.dart';
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

  testWidgets('test hub exposes and opens driving theory', (
    WidgetTester tester,
  ) async {
    final AppController controller = AppController();
    await controller.load();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TestHubScreen(controller: controller)),
      ),
    );
    expect(find.text('German driving theory · Class B'), findsOneWidget);
    await tester.tap(find.text('German driving theory · Class B'));
    await tester.pumpAndSettle();
    expect(find.text('Class B practice'), findsOneWidget);
    expect(find.text('Practise by topic'), findsOneWidget);
    expect(find.text('Start a 30-question mock'), findsOneWidget);
  });

  testWidgets('topic practice has a bilingual toggle and navigation', (
    WidgetTester tester,
  ) async {
    final AppController controller = AppController();
    await controller.load();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: DrivingPracticeScreen(controller: controller)),
    );
    await tester.pump();
    expect(find.byTooltip('Show English helper'), findsOneWidget);
    expect(find.text('Question 1 of 72'), findsOneWidget);
    await tester.tap(find.byTooltip('Show English helper'));
    await tester.pump();
    expect(find.byTooltip('Hide English helper'), findsOneWidget);
    expect(find.textContaining('What do you'), findsWidgets);
  });
}
