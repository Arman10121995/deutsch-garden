import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/games.dart';
import 'package:deutsch_garden/grammar_tables.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:deutsch_garden/vocabulary_library_screen.dart';
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
    debugSetVocabIcons(const <String>[]);
  });

  tearDown(debugResetVocabIcons);

  Future<AppController> controller() async {
    final AppController value = AppController();
    await value.load();
    return value;
  }

  void useNarrowPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('article feedback remains reachable on a narrow phone', (
    WidgetTester tester,
  ) async {
    useNarrowPhone(tester);
    final AppController state = await controller();
    addTearDown(state.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ArticleTrainerScreen(controller: state, level: CefrLevel.a1),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('DER'), 180);
    // scrollUntilVisible stops as soon as the widget exists, leaving the
    // scroll still gliding. Tapping then aims at where the button was a frame
    // ago and lands on whatever has slid under the pointer, which is why this
    // failed on CI and passed locally: it is a race, not a layout fault.
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('DER'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DER'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Next noun'), 180);

    expect(find.text('Next noun'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('verb lab and its table shortcut fit a narrow phone', (
    WidgetTester tester,
  ) async {
    useNarrowPhone(tester);
    final AppController state = await controller();
    addTearDown(state.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: VerbLabScreen(controller: state, level: CefrLevel.a2),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byTooltip('Open conjugation and grammar tables'),
      findsOneWidget,
    );
    await tester.tap(find.byType(OutlinedButton).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Next Verb'), 180);

    expect(find.text('Next Verb'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('grammar tables and vocabulary filters remain scrollable', (
    WidgetTester tester,
  ) async {
    useNarrowPhone(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: GrammarTablesScreen(
          initialLevel: CefrLevel.a1,
          ttsEnabled: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Present tense: sein and haben'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final AppController state = await controller();
    addTearDown(state.dispose);
    await tester.pumpWidget(
      MaterialApp(home: VocabularyLibraryScreen(controller: state)),
    );
    await tester.pumpAndSettle();
    expect(find.text('All word classes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
