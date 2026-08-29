import 'package:deutsch_garden/compound_breakdown.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocab_compounds.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

GermanWord byGerman(String g) =>
    vocabulary.firstWhere((GermanWord w) => w.german == g);

Widget host(Widget child, {double width = 400}) => MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: width, child: child)),
      ),
    );

void main() {
  group('the compound table', () {
    test('is substantial and every part is a real card', () {
      expect(vocabCompounds.length, greaterThan(1000));
      final Set<String> ids = <String>{
        for (final GermanWord w in vocabulary) w.id,
      };
      for (final MapEntry<String, VocabCompound> e in vocabCompounds.entries) {
        expect(ids, contains(e.key));
        expect(ids, contains(e.value.modifierId), reason: '${e.key} modifier');
        expect(ids, contains(e.value.headId), reason: '${e.key} head');
      }
    });

    test('nothing is its own part', () {
      for (final MapEntry<String, VocabCompound> e in vocabCompounds.entries) {
        expect(e.value.modifierId, isNot(e.key));
        expect(e.value.headId, isNot(e.key));
      }
    });

    test('known splits are right', () {
      final ({GermanWord modifier, GermanWord head, String link})? flughafen =
          compoundParts(byGerman('Flughafen'));
      expect(flughafen, isNotNull);
      expect(flughafen!.modifier.german, 'Flug');
      expect(flughafen.head.german, 'Hafen');

      final ({GermanWord modifier, GermanWord head, String link})? krankenhaus =
          compoundParts(byGerman('Krankenhaus'));
      expect(krankenhaus, isNotNull);
      expect(krankenhaus!.head.german, 'Haus');
      expect(krankenhaus.link, 'en',
          reason: 'the Fugenelement is shown as the seam it is, because a '
              'learner who thinks it belongs to krank will spell it wrong');
    });

    test('the misleading splits are excluded', () {
      // Recorded in tool/vocab_compounds_excluded.tsv with a reason each.
      // An autograph is not a car gramme.
      for (final String word in <String>['Autogramm', 'Zusammenhang']) {
        expect(vocabCompounds.containsKey(byGerman(word).id), isFalse,
            reason: '$word should be excluded');
      }
    });
  });

  group('the widget', () {
    testWidgets('shows both parts and the joiner', (WidgetTester t) async {
      debugResetVocabIcons();
      await loadVocabIconIndex(rootBundle);
      await t.pumpWidget(host(CompoundBreakdown(word: byGerman('Flughafen'))));
      expect(find.text('Built from'), findsOneWidget);
      expect(find.textContaining('Flug'), findsWidgets);
      expect(find.textContaining('Hafen'), findsWidgets);
    });

    testWidgets('says "built from", never "means"', (WidgetTester t) async {
      // Plenty of compounds are not compositional. Claiming the meaning
      // follows from the parts would be wrong for a large minority of them.
      await t.pumpWidget(host(CompoundBreakdown(word: byGerman('Flughafen'))));
      expect(find.textContaining('means'), findsNothing);
    });

    testWidgets('shows the linking letter as its own chip',
        (WidgetTester t) async {
      await t.pumpWidget(host(CompoundBreakdown(word: byGerman('Krankenhaus'))));
      expect(find.text('-en-'), findsOneWidget);
    });

    testWidgets('a non-compound renders nothing at all',
        (WidgetTester t) async {
      await t.pumpWidget(host(CompoundBreakdown(word: byGerman('Mann'))));
      expect(find.text('Built from'), findsNothing);
    });

    testWidgets('survives a narrow phone without overflowing',
        (WidgetTester t) async {
      // Two long German parts plus a joiner is exactly what does not fit.
      await t.pumpWidget(host(
        CompoundBreakdown(word: byGerman('Krankenschwester')),
        width: 200,
      ));
      // pump, not pumpAndSettle: a part may carry an animated pictogram on a
      // repeating controller, which never settles.
      await t.pump(const Duration(milliseconds: 200));
      expect(tester_hasNoOverflow(), isTrue);
      // Let the repeating controller go so the test can end.
      await t.pumpWidget(host(const SizedBox()));
    });
  });
}

/// flutter_test records overflow as an exception during paint.
bool tester_hasNoOverflow() {
  final Object? error = TestWidgetsFlutterBinding.instance.takeException();
  return error == null;
}
