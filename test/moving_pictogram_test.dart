import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/moving_pictogram.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:deutsch_garden/vocab_motion.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

GermanWord wordWithId(String id) =>
    vocabulary.firstWhere((GermanWord w) => w.id == id);

Widget host(Widget child, {bool disableAnimations = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: disableAnimations),
  child: MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('the motion table', () {
    test('every entry names a real card', () {
      final Set<String> ids = <String>{
        for (final GermanWord w in vocabulary) w.id,
      };
      for (final String id in vocabMotions.keys) {
        expect(ids, contains(id), reason: '$id is not a card');
      }
    });

    test('a verb of movement actually moves', () {
      // gehen, fahren, fliegen. If these were still, the whole point of
      // animating a pictogram would be missing.
      for (final String id in <String>['x10018', 'x10019', 'x10136']) {
        expect(vocabMotions[id], VocabMotion.travel, reason: id);
      }
    });

    test('words better served by stillness are still', () {
      expect(vocabMotions['x10032'], VocabMotion.none, reason: 'schließen');
      expect(vocabMotions['x10080'], VocabMotion.none, reason: 'zusammen');
    });
  });

  group('MovingPictogram', () {
    testWidgets('animates when it has a motion', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const MovingPictogram(
            motion: VocabMotion.travel,
            size: 40,
            child: SizedBox(
              width: 40,
              height: 40,
              key: ValueKey<String>('art'),
            ),
          ),
        ),
      );

      final Offset start = tester.getCenter(
        find.byKey(const ValueKey<String>('art')),
      );
      await tester.pump(const Duration(milliseconds: 650));
      final Offset moved = tester.getCenter(
        find.byKey(const ValueKey<String>('art')),
      );
      expect(
        moved.dx,
        isNot(closeTo(start.dx, 0.5)),
        reason: 'travel should displace the pictogram horizontally',
      );

      // Let the repeating controller settle so the test can end.
      await tester.pumpWidget(host(const SizedBox()));
    });

    testWidgets('a still motion adds no animation at all', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const MovingPictogram(
            motion: VocabMotion.none,
            size: 40,
            child: SizedBox(
              width: 40,
              height: 40,
              key: ValueKey<String>('art'),
            ),
          ),
        ),
      );
      final Offset start = tester.getCenter(
        find.byKey(const ValueKey<String>('art')),
      );
      await tester.pump(const Duration(milliseconds: 650));
      expect(
        tester.getCenter(find.byKey(const ValueKey<String>('art'))),
        start,
      );
    });

    testWidgets('obeys the system request to stop animating', (
      WidgetTester tester,
    ) async {
      // Someone who has asked their device to stop animating things has asked
      // this app too. Vestibular disorders are a real reason to ask.
      await tester.pumpWidget(
        host(
          const MovingPictogram(
            motion: VocabMotion.travel,
            size: 40,
            child: SizedBox(
              width: 40,
              height: 40,
              key: ValueKey<String>('art'),
            ),
          ),
          disableAnimations: true,
        ),
      );
      final Offset start = tester.getCenter(
        find.byKey(const ValueKey<String>('art')),
      );
      await tester.pump(const Duration(milliseconds: 650));
      expect(
        tester.getCenter(find.byKey(const ValueKey<String>('art'))),
        start,
      );
      // Scoped to this widget: MaterialApp uses AnimatedBuilder internally, so
      // a bare byType finder would be asserting about the framework.
      expect(
        find.descendant(
          of: find.byType(MovingPictogram),
          matching: find.byType(AnimatedBuilder),
        ),
        findsNothing,
      );
    });

    testWidgets('fading never hides the pictogram completely', (
      WidgetTester tester,
    ) async {
      // A pictogram that vanishes reads as a bug rather than as "asleep".
      await tester.pumpWidget(
        host(
          const MovingPictogram(
            motion: VocabMotion.fade,
            size: 40,
            child: SizedBox(width: 40, height: 40),
          ),
        ),
      );
      for (int step = 0; step < 8; step++) {
        await tester.pump(const Duration(milliseconds: 325));
        final Opacity opacity = tester.widget<Opacity>(
          find.byType(Opacity).first,
        );
        expect(opacity.opacity, greaterThanOrEqualTo(0.5));
      }
      await tester.pumpWidget(host(const SizedBox()));
    });

    testWidgets('switching the word switches the motion', (
      WidgetTester tester,
    ) async {
      // Lists recycle rows, so the same widget gets handed a different word.
      await tester.pumpWidget(
        host(
          const MovingPictogram(
            motion: VocabMotion.travel,
            size: 40,
            child: SizedBox(
              width: 40,
              height: 40,
              key: ValueKey<String>('art'),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.pumpWidget(
        host(
          const MovingPictogram(
            motion: VocabMotion.none,
            size: 40,
            child: SizedBox(
              width: 40,
              height: 40,
              key: ValueKey<String>('art'),
            ),
          ),
        ),
      );
      final Offset settled = tester.getCenter(
        find.byKey(const ValueKey<String>('art')),
      );
      await tester.pump(const Duration(milliseconds: 650));
      expect(
        tester.getCenter(find.byKey(const ValueKey<String>('art'))),
        settled,
      );
    });
  });

  group('through VocabIcon', () {
    testWidgets('visual priority keeps generated scenes and moving fallbacks', (
      WidgetTester tester,
    ) async {
      debugResetVocabIcons();
      await loadVocabIconIndex(rootBundle);

      await tester.pumpWidget(host(VocabIcon(word: wordWithId('x10018'))));
      expect(
        find.byType(Image),
        findsOneWidget,
        reason: 'gehen has a purpose-built semantic action scene',
      );
      expect(find.byType(MovingPictogram), findsNothing);

      // fahren has since gained a generated scene, and a scene outranks
      // everything below it. Suppress all the higher tiers in this fixture so
      // the assertion stays about the priority rule rather than about which
      // cards happen to have art today -- which is exactly what broke it.
      debugSetVocabIcons(
        const <String>{},
        lineIds: const <String>{'x10019'},
        generated: const <String, String>{},
      );
      await tester.pumpWidget(host(VocabIcon(word: wordWithId('x10019'))));
      expect(
        find.byType(MovingPictogram),
        findsOneWidget,
        reason: 'the fahren line pictogram keeps its travel motion',
      );

      debugSetVocabIcons(const <String>{'001'});
      await tester.pumpWidget(host(VocabIcon(word: wordWithId('001'))));
      expect(
        find.byType(MovingPictogram),
        findsNothing,
        reason: 'Mann is a drawing and does not move',
      );
      await tester.pumpWidget(host(const SizedBox()));
    });
  });
}
