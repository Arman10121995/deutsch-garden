import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/conversation.dart';
import 'package:deutsch_garden/conversation_screens.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('role-play hints reveal progressively and Previous restores', (
    WidgetTester tester,
  ) async {
    final AppController controller = AppController();
    await controller.load();
    controller.ttsEnabled = false;
    final ConversationScenario scenario = conversationsFor(CefrLevel.a1).first;

    await tester.pumpWidget(
      MaterialApp(
        home: ConversationScreen(controller: controller, scenario: scenario),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(scenario.steps.first.tutorGerman), findsOneWidget);

    Future<void> openHint() async {
      await tester.tap(find.byTooltip('Progressive hint'));
      await tester.pumpAndSettle();
    }

    Future<void> closeHint() async {
      Navigator.of(tester.element(find.text('Your task'))).pop();
      await tester.pumpAndSettle();
    }

    await openHint();
    expect(find.text('Model answer'), findsNothing);
    expect(find.text('Ask again for useful phrases.'), findsOneWidget);
    await closeHint();

    await openHint();
    expect(find.text('Language you can build with'), findsOneWidget);
    expect(find.text('Model answer'), findsNothing);
    await closeHint();

    await openHint();
    expect(find.text('Model answer'), findsOneWidget);
    await closeHint();

    await tester.enterText(
      find.byType(TextField),
      scenario.steps.first.modelAnswer,
    );
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();
    expect(find.text(scenario.steps[1].tutorGerman), findsOneWidget);

    await tester.tap(find.byTooltip('Previous turn'));
    await tester.pumpAndSettle();
    expect(find.text(scenario.steps.first.tutorGerman), findsOneWidget);
    expect(find.text(scenario.steps[1].tutorGerman), findsNothing);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('pronunciation sentences can be skipped and revisited', (
    WidgetTester tester,
  ) async {
    final AppController controller = AppController();
    await controller.load();
    controller.ttsEnabled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: PronunciationLabScreen(
          controller: controller,
          level: CefrLevel.a1,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sentence 1 of 12'), findsOneWidget);

    await tester.tap(find.text('Skip sentence'));
    await tester.pumpAndSettle();
    expect(find.text('Sentence 2 of 12'), findsOneWidget);

    await tester.tap(find.text('Previous'));
    await tester.pumpAndSettle();
    expect(find.text('Sentence 1 of 12'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
