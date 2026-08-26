import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/radio.dart';
import 'package:deutsch_garden/radio_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('the radio library lists episodes and one opens', (tester) async {
    final controller = AppController();
    await controller.load();
    await tester.pumpWidget(MaterialApp(
      home: RadioLibraryScreen(controller: controller, level: CefrLevel.a1),
    ));
    await tester.pumpAndSettle();

    final first = radioFor(CefrLevel.a1).first;
    expect(find.text(first.title), findsOneWidget);

    await tester.tap(find.text(first.title));
    await tester.pumpAndSettle();

    // Player surface: transcript and controls.
    expect(find.text('Play episode'), findsOneWidget);
    expect(find.text(first.lines.first.german), findsOneWidget);
    // A1 shows the English alongside by default.
    expect(find.text(first.lines.first.english), findsOneWidget);
    expect(find.text('Answer the questions'), findsOneWidget);
  });

  testWidgets('answering the questions records a score', (tester) async {
    final controller = AppController();
    await controller.load();
    final episode = radioFor(CefrLevel.a1).first;
    await tester.pumpWidget(MaterialApp(
      home: RadioEpisodeScreen(controller: controller, episode: episode),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Answer the questions'));
    await tester.pumpAndSettle();

    for (var i = 0; i < episode.questions.length; i++) {
      final q = episode.questions[i];
      await tester.tap(find.text(q.options[q.correctIndex]));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining(
          i + 1 < episode.questions.length ? 'Next question' : 'Finish'));
      await tester.pumpAndSettle();
    }
    expect(controller.progressForActivity(episode.id).bestScore, 100);
  });
}
