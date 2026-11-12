import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/civics_test.dart';
import 'package:deutsch_garden/driving_test.dart';
import 'package:deutsch_garden/driving_test_screens.dart';
import 'package:deutsch_garden/learning_visuals.dart';
import 'package:deutsch_garden/question_language_data.dart';
import 'package:deutsch_garden/question_language_tip.dart';
import 'package:deutsch_garden/screens.dart';
import 'package:deutsch_garden/ui_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'media_games_localisation_test.dart' show host, press;

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  tearDown(() => AppController.debounceWrites = true);
  Future<AppController> controller() async {
    final c = AppController();
    await c.load();
    addTearDown(c.dispose);
    return c;
  }

  test(
    'all 15 authored language notes have German examples and bilingual explanations',
    () {
      expect(questionLanguageHints, hasLength(15));
      expect(questionLanguageHints.map((h) => h.phrase).toSet(), hasLength(15));
      for (final hint in questionLanguageHints) {
        expect(hint.german, isNotEmpty);
        expect(hint.english, isNotEmpty);
        expect(hint.exampleGerman, matches(RegExp(r'^[A-ZÄÖÜ].*[.!?]$')));
        expect(hint.exampleEnglish, isNotEmpty);
        expect(questionLanguageHintFor('${hint.words.first}?'), same(hint));
      }
      expect(
        questionLanguageHintFor('Was müssen Sie NICHT tun?')!.german,
        contains('keine Pflicht'),
      );
      expect(
        questionLanguageHintFor('Was dürfen Sie nicht tun?')!.german,
        contains('nicht erlaubt'),
      );
    },
  );

  test(
    'word boundaries prevent unrelated noun substrings becoming grammar advice',
    () {
      expect(
        questionLanguageHintFor('Die Kanne steht in der Wohnung.'),
        isNull,
      );
      expect(questionLanguageHintFor('Erwerb und Schwellen.'), isNull);
      expect(
        questionLanguageHintFor('WORAUF achten Sie?')!.phrase,
        'worauf / auf',
      );
    },
  );

  test('notes cover actual bundled question stems', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final catalog = await CivicsCatalog.load();
    final civic = catalog.questions
        .where((q) => questionLanguageHintFor(q.question) != null)
        .length;
    final driving = DrivingTheoryCatalog.questions
        .where((q) => questionLanguageHintFor(q.questionGerman) != null)
        .length;
    expect(civic, greaterThan(150));
    expect(driving, greaterThan(30));
    // Kept in the test output for a reviewable coverage count, not telemetry.
    // ignore: avoid_print
    print('Language notes: $civic/460 civics, $driving/72 driving questions.');
  });

  testWidgets(
    'language help appears after answering, not before, without changing scoring',
    (tester) async {
      final c = await controller();
      final q = DrivingTheoryCatalog.questions.firstWhere(
        (q) => questionLanguageHintFor(q.questionGerman) != null,
      );
      for (final earlier in DrivingTheoryCatalog.questions.takeWhile(
        (item) => item.id != q.id,
      )) {
        await c.recordTestQuestionSeen('driving:${earlier.id}');
      }
      final sounds = <UiFeedbackEvent>[];
      c.uiFeedback = sounds.add;
      await tester.pumpWidget(host(DrivingPracticeScreen(controller: c)));
      await tester.pumpAndSettle();
      expect(find.byType(QuestionLanguageTip), findsNothing);
      final answer = find.widgetWithText(ListTile, q.correctOption.german);
      await tester.scrollUntilVisible(
        answer,
        160,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await Scrollable.ensureVisible(tester.element(answer), alignment: .4);
      await tester.pumpAndSettle();
      await tester.tap(answer);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(QuestionLanguageTip),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      await press(tester, 'Understand the German');
      expect(
        find.text(questionLanguageHintFor(q.questionGerman)!.exampleGerman),
        findsOneWidget,
      );
      expect(c.totalWrong, 0);
      expect(sounds, contains(UiFeedbackEvent.success));
    },
  );

  testWidgets(
    'the separate interface sound switch preserves German speech preference',
    (tester) async {
      final c = await controller();
      await tester.pumpWidget(
        host(Scaffold(body: SettingsScreen(controller: c))),
      );
      await tester.pumpAndSettle();
      final toggle = find.widgetWithText(SwitchListTile, 'Interface sounds');
      await tester.scrollUntilVisible(
        toggle,
        160,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(c.uiSoundsEnabled, isFalse);
      expect(c.ttsEnabled, isTrue);
    },
  );

  for (final locale in ['en', 'de']) {
    testWidgets(
      'illustrated learning guidance fits 320 pixels at 150 percent in $locale',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 720));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          host(
            Scaffold(
              body: ListView(
                children: const [
                  LearningGuideCard(questions: true),
                  LearningIllustration(complete: true),
                ],
              ),
            ),
            locale: locale,
            scale: 1.5,
          ),
        );
        await tester.pumpAndSettle();
        await press(
          tester,
          locale == 'de'
              ? 'So übst du mit Fragen'
              : 'How to practise with questions',
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
