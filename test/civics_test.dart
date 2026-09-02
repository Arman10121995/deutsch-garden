import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/civics_test.dart';
import 'package:deutsch_garden/civics_test_screens.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/test_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('official civics catalogue', () {
    test('contains the complete 300 plus 16 by 10 catalogue', () async {
      final CivicsCatalog catalog = await CivicsCatalog.load();
      expect(catalog.metadata.catalogStand, '07.05.2025');
      expect(catalog.questions, hasLength(460));
      expect(catalog.generalQuestions, hasLength(300));
      expect(catalog.states, hasLength(16));
      for (final GermanState state in catalog.states) {
        expect(
          catalog.stateQuestions(state.code),
          hasLength(10),
          reason: '${state.name} must have its ten official questions',
        );
        expect(catalog.relevantQuestions(state.code), hasLength(310));
      }
    });

    test('every question and bundled image is usable', () async {
      final CivicsCatalog catalog = await CivicsCatalog.load();
      final Set<String> ids = <String>{};
      int imageCount = 0;
      for (final CivicsQuestion question in catalog.questions) {
        expect(ids.add(question.id), isTrue, reason: question.id);
        expect(question.officialNumber, greaterThan(0), reason: question.id);
        expect(question.question.trim(), isNotEmpty, reason: question.id);
        expect(question.options, hasLength(4), reason: question.id);
        expect(question.options.toSet(), hasLength(4), reason: question.id);
        expect(
          question.correctIndex,
          inInclusiveRange(0, 3),
          reason: question.id,
        );
        if (question.scope == CivicsQuestionScope.state) {
          expect(question.stateCode, isNotNull, reason: question.id);
        } else {
          expect(question.stateCode, isNull, reason: question.id);
        }
        for (final CivicsImage image in question.images) {
          imageCount += 1;
          expect(image.sha256, hasLength(64));
          final ByteData bytes = await rootBundle.load(image.asset);
          expect(bytes.lengthInBytes, greaterThan(500), reason: image.asset);
        }
      }
      expect(imageCount, 100);
    });

    test('every official question has a bundled English helper', () async {
      final CivicsCatalog catalog = await CivicsCatalog.load();
      expect(catalog.translations, hasLength(catalog.questions.length));
      for (final CivicsQuestion question in catalog.questions) {
        final CivicsTranslation? translation = catalog.translationFor(
          question.id,
        );
        expect(translation, isNotNull, reason: question.id);
        expect(translation!.isUsable, isTrue, reason: question.id);
      }
    });

    test(
      'mock generation is exact, deterministic and state-specific',
      () async {
        final CivicsCatalog catalog = await CivicsCatalog.load();
        final CivicsMock first = catalog.buildMock(
          stateCode: 'NW',
          seed: 20260827,
        );
        final CivicsMock again = catalog.buildMock(
          stateCode: 'NW',
          seed: 20260827,
        );
        final CivicsMock different = catalog.buildMock(
          stateCode: 'NW',
          seed: 7,
        );

        expect(first.questions, hasLength(33));
        expect(
          first.questions.map((CivicsQuestion q) => q.id).toSet(),
          hasLength(33),
        );
        expect(
          first.questions.where(
            (CivicsQuestion q) => q.scope == CivicsQuestionScope.general,
          ),
          hasLength(30),
        );
        final List<CivicsQuestion> stateQuestions = first.questions
            .where((CivicsQuestion q) => q.scope == CivicsQuestionScope.state)
            .toList();
        expect(stateQuestions, hasLength(3));
        expect(
          stateQuestions.every((CivicsQuestion q) => q.stateCode == 'NW'),
          isTrue,
        );
        expect(
          first.questions.map((CivicsQuestion q) => q.id).toList(),
          again.questions.map((CivicsQuestion q) => q.id).toList(),
        );
        expect(
          first.questions.map((CivicsQuestion q) => q.id).toList(),
          isNot(different.questions.map((CivicsQuestion q) => q.id).toList()),
        );
      },
    );

    test('the two statutory thresholds stay distinct', () {
      expect(
        const CivicsTestResult(correct: 14, total: 33).passedLebenInDeutschland,
        isFalse,
      );
      const CivicsTestResult lidOnly = CivicsTestResult(correct: 15, total: 33);
      expect(lidOnly.passedLebenInDeutschland, isTrue);
      expect(lidOnly.passedCitizenship, isFalse);
      expect(
        const CivicsTestResult(correct: 17, total: 33).passedCitizenship,
        isTrue,
      );
      expect(CivicsTestKind.lebenInDeutschland.passMark, 15);
      expect(CivicsTestKind.citizenship.passMark, 17);
    });
  });

  group('civics progress', () {
    test(
      'wrong answers enter review and a correct retry clears them',
      () async {
        final AppController controller = AppController();
        await controller.load();
        await controller.recordCivicsPractice(
          questionId: 'general-001',
          prompt: 'Frage',
          correctAnswer: 'Richtig',
          givenAnswer: 'Falsch',
          correct: false,
        );
        expect(controller.civicsMistakeQuestionIds, contains('general-001'));

        await controller.recordCivicsPractice(
          questionId: 'general-001',
          prompt: 'Frage',
          correctAnswer: 'Richtig',
          givenAnswer: 'Richtig',
          correct: true,
        );
        expect(
          controller.civicsMistakeQuestionIds,
          isNot(contains('general-001')),
        );
        expect(controller.civicsCorrectQuestionIds, contains('general-001'));

        final AppController restored = AppController();
        restored.applyJson(controller.toJson());
        expect(restored.civicsCorrectQuestionIds, contains('general-001'));
      },
    );

    test('a mock result is persisted in one profile record', () async {
      final AppController controller = AppController();
      await controller.load();
      await controller.recordCivicsExam(
        kind: 'Einbürgerungstest',
        stateCode: 'BE',
        correct: 17,
        total: 33,
        correctQuestionIds: const <String>{'general-001'},
        mistakes: <MistakeEntry>[
          MistakeEntry(
            id: 'civics:general-002',
            prompt: 'Frage 2',
            correctAnswer: 'A',
            givenAnswer: 'B',
            source: 'civics',
            level: 'Einbürgerung',
            timestamp: DateTime(2026, 8, 27),
          ),
        ],
      );
      expect(controller.lastCivicsCorrect, 17);
      expect(controller.lastCivicsTotal, 33);
      expect(controller.lastCivicsStateCode, 'BE');
      expect(controller.civicsTestsCompleted, 1);
      expect(controller.civicsMistakeQuestionIds, contains('general-002'));

      final AppController restored = AppController();
      restored.applyJson(controller.toJson());
      expect(restored.lastCivicsCorrect, 17);
      expect(restored.lastCivicsTotal, 33);
      expect(restored.lastCivicsStateCode, 'BE');
      expect(restored.civicsTestsCompleted, 1);
      expect(restored.civicsMistakeQuestionIds, contains('general-002'));
    });
  });

  testWidgets('the timer submits unanswered questions at zero', (
    WidgetTester tester,
  ) async {
    final CivicsCatalog catalog = (await tester.runAsync(CivicsCatalog.load))!;
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(
        home: CivicsMockScreen(
          controller: controller,
          catalog: catalog,
          stateCode: 'BE',
          kind: CivicsTestKind.lebenInDeutschland,
          seed: 17,
          duration: const Duration(seconds: 1),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Mock result'), findsOneWidget);
    expect(find.text('0 / 33'), findsOneWidget);
    expect(find.textContaining('Time expired'), findsOneWidget);
    expect(controller.civicsTestsCompleted, 1);
    expect(controller.civicsMistakeQuestionIds, hasLength(33));
  });

  testWidgets('the offline test centre exposes practice and both mocks', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await CivicsCatalog.load();
    });
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(home: CivicsHubScreen(controller: controller)),
    );
    // A LinearProgressIndicator intentionally animates forever, so settling
    // is not the right wait primitive here. Two frames are enough for the
    // already bundled FutureBuilder asset to resolve.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Official question-bank preparation'), findsOneWidget);
    expect(find.text('Practise the question bank'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Leben in Deutschland mock'),
      300,
    );
    expect(find.text('Leben in Deutschland mock'), findsOneWidget);
    expect(find.text('Einbürgerungstest mock'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Stand 07.05.2025'),
      300,
    );
    expect(find.textContaining('Stand 07.05.2025'), findsOneWidget);
  });

  testWidgets('civics practice exposes the English helper toggle', (
    WidgetTester tester,
  ) async {
    final CivicsCatalog catalog = (await tester.runAsync(CivicsCatalog.load))!;
    final AppController controller = AppController();
    await controller.load();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: CivicsPracticeScreen(
          controller: controller,
          catalog: catalog,
          stateCode: 'BE',
        ),
      ),
    );
    await tester.pump();
    expect(find.byTooltip('Show English helper'), findsOneWidget);
    await tester.tap(find.byTooltip('Show English helper'));
    await tester.pump();
    expect(find.byTooltip('Hide English helper'), findsOneWidget);
  });

  testWidgets('the main test hub opens the civics centre', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await CivicsCatalog.load();
    });
    final AppController controller = AppController();
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TestHubScreen(controller: controller)),
      ),
    );
    await tester.pump();

    expect(find.text('Leben in Deutschland & citizenship'), findsOneWidget);
    await tester.tap(find.text('Leben in Deutschland & citizenship'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Official question-bank preparation'), findsOneWidget);
  });
}
