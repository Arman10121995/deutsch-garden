import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/skill_screens.dart';
import 'package:deutsch_garden/speaking_curriculum.dart';
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

  tearDown(() => AppController.debounceWrites = true);

  testWidgets('speaking lessons default to automatic transcript feedback', (
    WidgetTester tester,
  ) async {
    final AppController controller = AppController();
    await controller.load();
    controller.ttsEnabled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SpeakingLessonScreen(
          controller: controller,
          lesson: speakingLessons.first,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Automatic speaking check'), findsOneWidget);
    expect(find.text('Start speaking'), findsOneWidget);
    expect(find.text('Transcript or typed fallback'), findsOneWidget);
    expect(find.textContaining('assess this attempt'), findsNothing);
    expect(find.textContaining('Needs work'), findsNothing);
    expect(find.textContaining('Controlled & confident'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
