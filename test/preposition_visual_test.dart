import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/preposition_visual.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {bool motionOff = false, double width = 420}) =>
    MediaQuery(
      data: MediaQueryData(disableAnimations: motionOff),
      child: MaterialApp(
        home: Scaffold(body: Center(child: SizedBox(width: width, child: child))),
      ),
    );

void main() {
  group('the table', () {
    test('covers all nine two-way prepositions', () {
      const Set<String> nine = <String>{
        'an', 'auf', 'hinter', 'in', 'neben', 'über', 'unter', 'vor', 'zwischen',
      };
      expect(
        twoWayPrepositions.map((TwoWayPreposition p) => p.german).toSet(),
        nine,
      );
    });

    test('every one is a real vocabulary card', () {
      // A diagram for a word the learner never meets is a diagram nobody sees.
      final Set<String> deck = <String>{
        for (final GermanWord w in vocabulary) w.german.toLowerCase(),
      };
      for (final TwoWayPreposition p in twoWayPrepositions) {
        expect(deck, contains(p.german), reason: p.german);
      }
    });

    test('each pair changes the case and nothing else', () {
      // Changing the noun as well as the case would hide the thing being
      // taught, which is the entire point of showing them side by side.
      for (final TwoWayPreposition p in twoWayPrepositions) {
        expect(p.accusative, contains(p.german));
        expect(p.dative, contains(p.german));
        expect(p.accusative, isNot(p.dative));
      }
    });

    test('lookup is case-insensitive and rejects non-members', () {
      expect(twoWayPrepositionFor('AUF')?.german, 'auf');
      expect(twoWayPrepositionFor(' unter ')?.german, 'unter');
      // Accusative-only and dative-only prepositions must not get a diagram
      // claiming they are two-way.
      expect(twoWayPrepositionFor('mit'), isNull);
      expect(twoWayPrepositionFor('für'), isNull);
      expect(twoWayPrepositionFor('durch'), isNull);
    });
  });

  group('the diagram', () {
    testWidgets('shows both cases and both question words',
        (WidgetTester t) async {
      await t.pumpWidget(host(
        PrepositionDiagram(preposition: twoWayPrepositionFor('auf')!),
      ));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.text('wohin?'), findsOneWidget);
      expect(find.text('wo?'), findsOneWidget);
      expect(find.text('accusative'), findsOneWidget);
      expect(find.text('dative'), findsOneWidget);
      await t.pumpWidget(host(const SizedBox()));
    });

    testWidgets('renders every preposition without throwing',
        (WidgetTester t) async {
      for (final TwoWayPreposition p in twoWayPrepositions) {
        await t.pumpWidget(host(PrepositionDiagram(preposition: p)));
        await t.pump(const Duration(milliseconds: 80));
        expect(noExceptionRecorded(), isTrue, reason: p.german);
      }
      await t.pumpWidget(host(const SizedBox()));
    });

    testWidgets('obeys the system request to stop animating',
        (WidgetTester t) async {
      // With motion off there must be no repeating controller left running,
      // which is also what lets this test finish at all.
      await t.pumpWidget(host(
        PrepositionDiagram(preposition: twoWayPrepositionFor('in')!),
        motionOff: true,
      ));
      await t.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(PrepositionDiagram),
          matching: find.byType(AnimatedBuilder),
        ),
        findsNothing,
      );
    });

    testWidgets('stacks instead of overflowing on a narrow phone',
        (WidgetTester t) async {
      await t.pumpWidget(host(
        PrepositionDiagram(preposition: twoWayPrepositionFor('zwischen')!),
        width: 200,
      ));
      await t.pump(const Duration(milliseconds: 80));
      expect(noExceptionRecorded(), isTrue);
      await t.pumpWidget(host(const SizedBox()));
    });
  });
}

bool noExceptionRecorded() =>
    TestWidgetsFlutterBinding.instance.takeException() == null;
