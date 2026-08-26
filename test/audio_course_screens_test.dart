import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/audio_course.dart';
import 'package:deutsch_garden/audio_course_screens.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/sentence_bank.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// A two-item playlist, so a test can walk the whole thing without pumping
/// through ten sentences of timers.
Playlist tinyPlaylist() => const Playlist(
      level: CefrLevel.a1,
      day: 1,
      totalDays: 65,
      items: <PlaylistItem>[
        PlaylistItem(
          sentence: PracticeSentence(
            id: 't1',
            level: CefrLevel.a1,
            german: 'Ich bin müde.',
            english: 'I am tired.',
            focus: 'sein in the present',
          ),
          isNew: true,
          fromDay: 1,
        ),
        PlaylistItem(
          sentence: PracticeSentence(
            id: 't2',
            level: CefrLevel.a1,
            german: 'Wir gehen nach Hause.',
            english: 'We are going home.',
          ),
          isNew: true,
          fromDay: 1,
        ),
      ],
    );

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<AppController> boot() async {
    final AppController controller = AppController();
    await controller.load();
    return controller;
  }

  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('the German stays hidden until after the gap',
      (WidgetTester tester) async {
    final AppController controller = await boot();
    await tester.pumpWidget(
      wrap(AnticipationDrillScreen(
        controller: controller,
        playlist: tinyPlaylist(),
      )),
    );
    await tester.pump();

    // Nothing runs until asked: audio that starts itself is rude, and the
    // learner needs a moment to get somewhere they can speak out loud.
    expect(find.text('I am tired.'), findsOneWidget);
    expect(find.text('Read it'), findsOneWidget);

    await tester.tap(find.text('Play'));
    await tester.pump();
    expect(find.text('Read it'), findsOneWidget);

    // Prompt beat, then the silence. This is the part that has to exist:
    // producing the sentence is the exercise, so the answer must not be on
    // screen while the learner is meant to be producing it.
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('Say it in German, out loud'), findsOneWidget);

    // The answer is faded rather than removed, so finding the Text proves
    // nothing -- the opacity is what actually hides it.
    double opacity() => tester
        .widget<AnimatedOpacity>(find.byType(AnimatedOpacity))
        .opacity;
    expect(opacity(), 0);

    await tester.pump(const Duration(milliseconds: 2600));
    expect(find.text('Listen'), findsOneWidget);
    expect(opacity(), 1);

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Ich bin müde.'), findsOneWidget);

    // Stop the timers before the test ends.
    await tester.tap(find.text('Pause'));
    await tester.pump();
  });

  testWidgets('pausing stops the clock', (WidgetTester tester) async {
    final AppController controller = await boot();
    await tester.pumpWidget(
      wrap(AnticipationDrillScreen(
        controller: controller,
        playlist: tinyPlaylist(),
      )),
    );
    await tester.pump();

    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('Say it in German, out loud'), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pump(const Duration(seconds: 30));
    // Still in the gap half a minute later, because the timer was cancelled
    // rather than merely ignored.
    expect(find.text('Say it in German, out loud'), findsOneWidget);
  });

  testWidgets('skipping to the end records the day once',
      (WidgetTester tester) async {
    final AppController controller = await boot();
    expect(controller.audioCourseDaysDone(CefrLevel.a1), 0);

    await tester.pumpWidget(
      wrap(AnticipationDrillScreen(
        controller: controller,
        playlist: tinyPlaylist(),
      )),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Next sentence'));
    await tester.pumpAndSettle();
    expect(find.text('We are going home.'), findsOneWidget);

    await tester.tap(find.byTooltip('Next sentence'));
    await tester.pumpAndSettle();

    expect(find.text('Day 1 done'), findsOneWidget);
    expect(controller.audioCourseDaysDone(CefrLevel.a1), 1);
  });

  testWidgets('replaying an old day does not advance the counter',
      (WidgetTester tester) async {
    final AppController controller = await boot();
    await controller.completeAudioCourseDay(CefrLevel.a1, 1);
    await controller.completeAudioCourseDay(CefrLevel.a1, 2);
    expect(controller.audioCourseDaysDone(CefrLevel.a1), 2);

    // Finishing day 1 again must not push the counter to 3, and must not
    // rewind it to 1 either.
    await controller.completeAudioCourseDay(CefrLevel.a1, 1);
    expect(controller.audioCourseDaysDone(CefrLevel.a1), 2);
    expect(controller.audioCourseDay(CefrLevel.a1), 3);
  });

  testWidgets('the day counter survives a save and reload',
      (WidgetTester tester) async {
    final AppController first = await boot();
    await first.completeAudioCourseDay(CefrLevel.a1, 1);
    await first.completeAudioCourseDay(CefrLevel.b1, 1);
    await first.completeAudioCourseDay(CefrLevel.b1, 2);

    final AppController second = AppController();
    await second.load();
    expect(second.audioCourseDaysDone(CefrLevel.a1), 1);
    expect(second.audioCourseDaysDone(CefrLevel.b1), 2);
    expect(second.audioCourseDaysDone(CefrLevel.c2), 0);
  });

  testWidgets('the day card says what today holds',
      (WidgetTester tester) async {
    final AppController controller = await boot();
    await tester.pumpWidget(
      wrap(AudioCourseScreen(controller: controller, level: CefrLevel.a1)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Day 1 of'), findsOneWidget);
    expect(find.textContaining('10 new'), findsOneWidget);
    expect(find.text('Start today'), findsOneWidget);
    // No history yet, so no replay control.
    expect(find.text('Replay an earlier day'), findsNothing);
  });
}
