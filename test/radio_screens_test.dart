import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/curriculum.dart';
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
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('the radio library lists episodes and one opens', (tester) async {
    final controller = AppController();
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(
        home: RadioLibraryScreen(controller: controller, level: CefrLevel.a1),
      ),
    );
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

  testWidgets('no scrub controls without a backend that can be scrubbed', (
    tester,
  ) async {
    // In a test there is no bundled voice and no OS engine, so the transport
    // must degrade to play and stop. The point is not that a test environment
    // is unusual -- it is that the web build and any device where the voice
    // fails to load land in exactly this state, and a progress bar that
    // cannot move is worse than no progress bar. The speed chips shipped like
    // that once; they set a field nothing read.
    final controller = AppController();
    await controller.load();
    final episode = radioFor(CefrLevel.a1).first;
    await tester.pumpWidget(
      MaterialApp(
        home: RadioEpisodeScreen(controller: controller, episode: episode),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Play episode'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
    expect(find.byTooltip('Back ten seconds'), findsNothing);
    expect(find.byTooltip('Forward ten seconds'), findsNothing);

    // The transcript is the fallback, so it has to be there regardless.
    expect(find.text(episode.lines.first.german), findsOneWidget);
  });

  test('radio episodes do not share an activity id with a grammar lesson', () {
    // Twenty-one of the fifty-three episodes did, for three releases: the same
    // key in the same progress map, so passing a grammar lesson silently
    // marked a radio episode complete. The content gate catches this in the
    // source now; this asserts it from the app's own side, against the built
    // objects rather than the text that produced them.
    final Set<String> grammar = <String>{
      for (final level in CefrLevel.values)
        for (final lesson in grammarFor(level)) lesson.id,
    };
    final List<String> episodes = <String>[
      for (final level in CefrLevel.values)
        for (final episode in radioFor(level)) episode.id,
    ];

    expect(episodes.toSet().length, episodes.length, reason: 'duplicate id');
    expect(episodes.toSet().intersection(grammar), isEmpty);
    expect(episodes.every((String id) => id.startsWith('rd-')), isTrue);
  });

  testWidgets('progress recorded under the old radio ids is carried over', (
    tester,
  ) async {
    // rd-a1-05 was gr-a1-05, an id no grammar lesson ever claimed, so a record
    // under the old key can only have come from the radio player and moves
    // across intact.
    final controller = AppController();
    await controller.load();
    await controller.recordActivity('gr-a1-05', score: 90);
    expect(controller.debugMigrateRadioIds(), isTrue);
    expect(controller.progressForActivity('rd-a1-05').bestScore, 90);
    expect(controller.activities.containsKey('gr-a1-05'), isFalse);
  });

  testWidgets('an ambiguous old radio id is left with the grammar lesson', (
    tester,
  ) async {
    // gr-a1-04 was both a grammar lesson and an episode. Which one wrote the
    // record is unknowable, and inventing a radio completion would mark
    // content done that may never have been opened.
    final controller = AppController();
    await controller.load();
    await controller.recordActivity('gr-a1-04', score: 90);
    controller.debugMigrateRadioIds();
    expect(controller.progressForActivity('gr-a1-04').bestScore, 90);
    expect(controller.activities.containsKey('rd-a1-04'), isFalse);
  });

  test('every level hits its episode target with written scripts', () {
    // The library used to reach 120 by generating vocabulary magazines into
    // whatever slots the hand-written scripts left empty. That was honest
    // scaffolding -- each sentence was a real level-matched headword in a
    // validated context -- but it stood in for written broadcasts, and the
    // scripts exist now. If a magazine ever reappears here it means the seed
    // count fell below the target, which is a content regression rather than
    // a rendering one.
    const Map<String, int> targets = <String, int>{
      'A1': 30, 'A2': 30, 'B1': 25, 'B2': 20, 'C1': 10, 'C2': 5,
    };
    var total = 0;
    for (final level in CefrLevel.values) {
      final episodes = radioFor(level);
      expect(episodes, hasLength(targets[level.label]),
          reason: '${level.label} episode count');
      expect(
        episodes.where((e) => e.title.startsWith('Wortmagazin')),
        isEmpty,
        reason: '${level.label} still falls back on generated filler',
      );
      total += episodes.length;
    }
    expect(total, 120);
  });

  test('every episode carries the full checkpoint set', () {
    for (final level in CefrLevel.values) {
      for (final episode in radioFor(level)) {
        expect(episode.questions.length, greaterThanOrEqualTo(3),
            reason: '${episode.id} has too few questions');
        for (final q in episode.questions) {
          expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1),
              reason: '${episode.id}: ${q.prompt}');
          expect(q.options.toSet().length, q.options.length,
              reason: '${episode.id}: ${q.prompt} repeats an option');
        }
      }
    }
  });

  testWidgets('answering the questions records a score', (tester) async {
    final controller = AppController();
    await controller.load();
    final episode = radioFor(CefrLevel.a1).first;
    await tester.pumpWidget(
      MaterialApp(
        home: RadioEpisodeScreen(controller: controller, episode: episode),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Answer the questions'));
    await tester.pumpAndSettle();

    for (var i = 0; i < episode.questions.length; i++) {
      final q = episode.questions[i];
      await tester.tap(find.text(q.options[q.correctIndex]));
      await tester.pumpAndSettle();
      await tester.tap(
        find.textContaining(
          i + 1 < episode.questions.length ? 'Next question' : 'Start matching',
        ),
      );
      await tester.pumpAndSettle();
    }
    for (var i = 0; i < episode.matchingPairs.length; i++) {
      final pair = episode.matchingPairs[i];
      await tester.tap(find.text(pair.english));
      await tester.pumpAndSettle();
      final String nextLabel = i + 1 < episode.matchingPairs.length
          ? 'Next match'
          : 'Finish episode';
      await tester.scrollUntilVisible(find.text(nextLabel), 250);
      await tester.tap(find.text(nextLabel));
      await tester.pumpAndSettle();
    }
    expect(controller.progressForActivity(episode.id).bestScore, 100);
  });

  testWidgets('listening questions provide replay before revealing feedback', (
    tester,
  ) async {
    final controller = AppController();
    await controller.load();
    final episode = radioFor(CefrLevel.a1).first;
    await tester.pumpWidget(
      MaterialApp(
        home: RadioEpisodeScreen(controller: controller, episode: episode),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Answer the questions'));
    await tester.pumpAndSettle();

    expect(find.text('Play the sentence'), findsOneWidget);
    expect(
      find.text(episode.listenPrompts.first),
      findsOneWidget,
      reason: 'the spoken sentence must be one of the answer choices',
    );
    expect(
      find.textContaining('Zu hören war:'),
      findsNothing,
      reason: 'feedback must stay hidden until the learner chooses',
    );
  });
}
