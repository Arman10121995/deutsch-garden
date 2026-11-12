import 'dart:async';
import 'dart:math';

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/backup.dart';
import 'package:deutsch_garden/civics_test.dart';
import 'package:deutsch_garden/civics_test_screens.dart';
import 'package:deutsch_garden/driving_test.dart';
import 'package:deutsch_garden/driving_test_screens.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/test_question_selection.dart';
import 'package:deutsch_garden/test_question_tools.dart';
import 'package:deutsch_garden/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'media_games_localisation_test.dart' show host, press;

class PendingQuestionSpeech extends TtsService {
  final completion = Completer<void>();
  final spoken = <String>[];
  int stops = 0;

  @override
  TtsBackend get backend => TtsBackend.plugin;

  @override
  Future<void> speakTurns(Iterable<SpokenTurn> turns, {double rate = 1}) {
    spoken.addAll(turns.map((turn) => turn.text));
    return completion.future;
  }

  @override
  Future<void> stop() async => stops++;
}

class UnavailableQuestionSpeech extends PendingQuestionSpeech {
  @override
  TtsBackend get backend => TtsBackend.none;

  @override
  Future<void> speakTurns(
    Iterable<SpokenTurn> turns, {
    double rate = 1,
  }) async {}
}

TestQuestionTools tools(WidgetTester tester) =>
    tester.widget<TestQuestionTools>(find.byType(TestQuestionTools));

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
    'random selection exhausts unseen, then unanswered, without repeating the current item',
    () {
      final ids = ['a', 'b', 'c', 'd'];
      for (var seed = 0; seed < 30; seed++) {
        expect(
          preferredTestQuestion(
            ids: ids,
            seen: {'a', 'b', 'd'},
            current: 1,
            random: Random(seed),
          ),
          2,
        );
        expect(
          preferredTestQuestion(
            ids: ids,
            seen: ids.toSet(),
            current: 1,
            answered: {'a', 'b', 'c'},
            random: Random(seed),
          ),
          3,
        );
        expect(
          preferredTestQuestion(
            ids: ids,
            seen: ids.toSet(),
            current: 1,
            answered: ids.toSet(),
            random: Random(seed),
          ),
          isNot(1),
        );
      }
      expect(
        preferredTestQuestion(
          ids: ['only'],
          seen: {'only'},
          current: 0,
          random: Random(1),
        ),
        0,
      );
      expect(preferredTestQuestion(ids: [], seen: {}), 0);
    },
  );

  test(
    'viewed history persists without awards, merges, and clears on full reset',
    () async {
      final c = await controller();
      await c.recordTestQuestionSeen('civics:one');
      await c.recordTestQuestionSeen('driving:one');
      await c.recordTestQuestionSeen('civics:one');
      await c.flushSave();
      expect(c.xp, 0);
      expect(c.totalCorrect, 0);
      expect(c.totalWrong, 0);
      expect(c.mistakes, isEmpty);
      final reloaded = await controller();
      expect(reloaded.seenTestQuestionIds, {'civics:one', 'driving:one'});
      final merged = ProgressBackup.merge(reloaded.toBackupJson(), {
        'seenTestQuestionIds': ['driving:two', 'civics:one'],
        'civicsCorrectQuestionIds': ['old-answer'],
      });
      await reloaded.restoreFrom(merged);
      expect(reloaded.seenTestQuestionIds, {
        'civics:one',
        'driving:one',
        'driving:two',
        'civics:old-answer',
      });
      await reloaded.resetAllProgress();
      expect(reloaded.seenTestQuestionIds, isEmpty);
    },
  );

  testWidgets(
    'driving starts with an unseen item, random skips seen items, and a viewed-only item survives reopening',
    (tester) async {
      final c = await controller();
      final bank = DrivingTheoryCatalog.questions;
      final old = bank.take(2).map((q) => 'driving:${q.id}').toSet();
      for (final id in old) {
        await c.recordTestQuestionSeen(id);
      }
      await tester.pumpWidget(host(DrivingPracticeScreen(controller: c)));
      await tester.pumpAndSettle();
      expect(tools(tester).questionId, 'driving:${bank[2].id}');
      final viewed = tools(tester).questionId;
      await tester.pumpWidget(host(const SizedBox()));
      await tester.pumpAndSettle();
      await c.flushSave();
      final reloaded = await controller();
      await tester.pumpWidget(
        host(DrivingPracticeScreen(controller: reloaded)),
      );
      await tester.pumpAndSettle();
      expect(tools(tester).questionId, 'driving:${bank[3].id}');
      final beforeRandom = Set<String>.of(reloaded.seenTestQuestionIds);
      await press(tester, 'Random question');
      expect(beforeRandom, isNot(contains(tools(tester).questionId)));
      expect(reloaded.seenTestQuestionIds, contains(viewed));
      expect(reloaded.totalWrong, 0);
      expect(reloaded.mistakes, isEmpty);
    },
  );

  testWidgets('driving random and unseen selection stay inside the topic', (
    tester,
  ) async {
    final c = await controller();
    const category = DrivingQuestionCategory.motorway;
    final bank = DrivingTheoryCatalog.questionsFor(category);
    for (final q in bank.skip(2)) {
      await c.recordTestQuestionSeen('driving:${q.id}');
    }
    await tester.pumpWidget(host(DrivingPracticeScreen(controller: c)));
    await tester.pumpAndSettle();
    tester
        .widget<DropdownButtonFormField<DrivingQuestionCategory?>>(
          find.byType(DropdownButtonFormField<DrivingQuestionCategory?>),
        )
        .onChanged!(category);
    await tester.pumpAndSettle();
    expect(tools(tester).questionId, 'driving:${bank.first.id}');
    await press(tester, 'Random question');
    expect(tools(tester).questionId, 'driving:${bank[1].id}');
  });

  testWidgets(
    'civics starts unseen and random respects the selected Bundesland',
    (tester) async {
      final c = await controller();
      final catalog = (await tester.runAsync(CivicsCatalog.load))!;
      final bank = catalog.relevantQuestions('BE');
      for (final q in bank.take(bank.length - 2)) {
        await c.recordTestQuestionSeen('civics:${q.id}');
      }
      await tester.pumpWidget(
        host(
          CivicsPracticeScreen(
            controller: c,
            catalog: catalog,
            stateCode: 'BE',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tools(tester).questionId, 'civics:${bank[bank.length - 2].id}');
      await press(tester, 'Random question');
      expect(tools(tester).questionId, 'civics:${bank.last.id}');
      await tester.pumpWidget(host(const SizedBox()));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'civics mock random preserves the fixed paper and selected answers',
    (tester) async {
      final c = await controller();
      final catalog = (await tester.runAsync(CivicsCatalog.load))!;
      final paper = catalog.buildMock(stateCode: 'BE', seed: 19);
      await c.recordTestQuestionSeen('civics:${paper.questions.first.id}');
      await tester.pumpWidget(
        host(
          CivicsMockScreen(
            controller: c,
            catalog: catalog,
            stateCode: 'BE',
            kind: CivicsTestKind.citizenship,
            seed: 19,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tools(tester).questionId, 'civics:${paper.questions[1].id}');
      final answeredId = tools(tester).questionId;
      final answer = find.byType(ListTile).first;
      await tester.ensureVisible(answer);
      await tester.tap(answer);
      await tester.pump();
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await tester.pumpAndSettle();
      await press(tester, 'Random question');
      expect(
        paper.questions.map((q) => 'civics:${q.id}'),
        contains(tools(tester).questionId),
      );
      expect(tools(tester).questionId, isNot(answeredId));
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await tester.pumpAndSettle();
      expect(find.text('1 answered'), findsOneWidget);
      // Number 2 is the answered item; returning must restore its selected tile.
      await press(tester, '2');
      expect(tools(tester).questionId, answeredId);
      await tester.scrollUntilVisible(
        find.byType(ListTile).first,
        160,
        scrollable: find.byType(Scrollable).first,
      );
      final selectedCard = find
          .ancestor(
            of: find.byType(ListTile).first,
            matching: find.byType(Card),
          )
          .first;
      expect(
        tester.widget<Card>(selectedCard).color,
        Theme.of(tester.element(selectedCard)).colorScheme.primaryContainer,
      );
      await tester.pumpWidget(host(const SizedBox()));
      await tester.pumpAndSettle();
      expect(c.civicsTestsCompleted, 0);
    },
  );

  testWidgets(
    'driving mock random does not redraw, answer, or reset its timer',
    (tester) async {
      final c = await controller();
      await tester.pumpWidget(host(DrivingMockScreen(controller: c)));
      await tester.pumpAndSettle();
      final before = tools(tester).questionId;
      await press(tester, 'Random question');
      expect(tools(tester).questionId, isNot(before));
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await tester.pumpAndSettle();
      expect(find.text('0 answered'), findsOneWidget);
      expect(c.seenTestQuestionIds, hasLength(2));
      int remaining() {
        final clock = tester
            .widget<Text>(find.textContaining(RegExp(r'^\d\d:\d\d$')))
            .data!;
        final parts = clock.split(':').map(int.parse).toList();
        return parts[0] * 60 + parts[1];
      }

      final seconds = remaining();
      await tester.pump(const Duration(seconds: 2));
      expect(remaining(), seconds - 2);
      await tester.pumpWidget(host(const SizedBox()));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'read aloud uses displayed options, stops on navigation, and ignores late completion',
    (tester) async {
      final c = await controller();
      final speech = PendingQuestionSpeech();
      Widget page(String id) => host(
        Scaffold(
          body: TestQuestionTools(
            controller: c,
            questionId: id,
            spokenText: spokenTestQuestion('Welche Antwort?', [
              'Erste.',
              'Zweite.',
            ]),
            onRandom: () {},
            speech: speech,
          ),
        ),
      );
      await tester.pumpWidget(page('civics:a'));
      await tester.pumpAndSettle();
      await press(tester, 'Read question aloud');
      expect(speech.spoken.single, 'Welche Antwort?\nA. Erste.\nB. Zweite.');
      expect(find.text('Stop reading'), findsOneWidget);
      await tester.pumpWidget(page('civics:b'));
      await tester.pump();
      expect(speech.stops, 1);
      expect(find.text('Read question aloud'), findsOneWidget);
      speech.completion.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(host(const SizedBox()));
      await tester.pumpAndSettle();
      expect(speech.stops, 2);
    },
  );

  test(
    'legacy answers imply seen, while unanswered mock items do not',
    () async {
      final c = await controller();
      Map<String, dynamic> mistake(String id, String answer) => MistakeEntry(
        id: 'civics:$id',
        prompt: 'Frage',
        correctAnswer: 'Richtig',
        givenAnswer: answer,
        source: 'civics',
        level: 'LiD',
        timestamp: DateTime(2026, 11, 11),
      ).toJson();
      c.applyJson({
        ...c.toBackupJson(),
        'civicsCorrectQuestionIds': ['correct'],
        'mistakes': [
          mistake('wrong', 'Falsch'),
          mistake('unvisited', 'Keine Antwort'),
        ],
      });
      expect(c.seenTestQuestionIds, {'civics:correct', 'civics:wrong'});
    },
  );

  testWidgets(
    'reading survives scrolling to the choices and can be stopped manually',
    (tester) async {
      final c = await controller();
      final speech = PendingQuestionSpeech();
      await tester.pumpWidget(
        host(
          Scaffold(
            body: ListView(
              children: [
                TestQuestionTools(
                  controller: c,
                  questionId: 'driving:scroll',
                  spokenText: 'Frage und Antworten',
                  onRandom: () {},
                  speech: speech,
                ),
                const SizedBox(height: 3000),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await press(tester, 'Read question aloud');
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      position.jumpTo(2000);
      await tester.pumpAndSettle();
      expect(speech.stops, 0);
      position.jumpTo(0);
      await tester.pumpAndSettle();
      await press(tester, 'Stop reading');
      expect(speech.stops, 1);
      speech.completion.complete();
      await tester.pumpAndSettle();
      expect(find.text('Read question aloud'), findsOneWidget);
      await tester.pumpWidget(host(const SizedBox()));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'missing speech has a German explanation and does not block random selection',
    (tester) async {
      final c = await controller();
      int randomCalls = 0;
      await tester.pumpWidget(
        host(
          Scaffold(
            body: TestQuestionTools(
              controller: c,
              questionId: 'civics:no-voice',
              spokenText: 'Frage',
              onRandom: () => randomCalls++,
              speech: UnavailableQuestionSpeech(),
            ),
          ),
          locale: 'de',
        ),
      );
      await tester.pumpAndSettle();
      await press(tester, 'Frage vorlesen');
      expect(
        find.textContaining('Vorlesen ist nicht verfügbar.'),
        findsOneWidget,
      );
      await press(tester, 'Zufällige Frage');
      expect(randomCalls, 1);
    },
  );
}
