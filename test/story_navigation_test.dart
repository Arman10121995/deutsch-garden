import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/mini_story.dart';
import 'package:deutsch_garden/mini_story_screens.dart';
import 'package:deutsch_garden/story_screens.dart';
import 'package:deutsch_garden/stories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late AppController controller;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppController.debounceWrites = false;
    controller = AppController();
    await controller.load();
  });

  tearDown(() {
    controller.dispose();
    AppController.debounceWrites = true;
  });

  Widget host(Widget child) =>
      MaterialApp(theme: ThemeData(useMaterial3: true), home: child);

  testWidgets('the story library is a safe standalone route with Back', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => StoryLibraryScreen(controller: controller),
                  ),
                ),
                child: const Text('Open stories'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open stories'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Geschichten'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
  });

  testWidgets('every story, chapter, quiz and mini-story builds safely', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final Story story in stories) {
      await tester.pumpWidget(
        host(StoryDetailScreen(controller: controller, story: story)),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '${story.id} detail');

      await tester.pumpWidget(
        host(
          MiniStoryDrillScreen(
            controller: controller,
            drill: miniStoryFor(story),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '${story.id} mini-story');

      for (int index = 0; index < story.chapters.length; index++) {
        final StoryChapter chapter = story.chapters[index];
        await tester.pumpWidget(
          host(
            StoryReaderScreen(
              controller: controller,
              story: story,
              chapterIndex: index,
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '${chapter.id} reader');

        await tester.pumpWidget(
          host(
            StoryQuizScreen(
              controller: controller,
              chapter: chapter,
              level: story.level,
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '${chapter.id} quiz');
      }
    }
  });

  testWidgets('a stale chapter index shows recovery UI instead of crashing', (
    tester,
  ) async {
    final Story story = stories.first;
    await tester.pumpWidget(
      host(
        StoryReaderScreen(
          controller: controller,
          story: story,
          chapterIndex: story.chapters.length + 5,
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Chapter unavailable'), findsOneWidget);
    expect(find.text('Back to the story'), findsOneWidget);
  });
}
