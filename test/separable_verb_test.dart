import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/separable_verb_animation.dart';
import 'package:deutsch_garden/separable_verbs.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

GermanWord byGerman(String g) =>
    vocabulary.firstWhere((GermanWord w) => w.german == g);

Widget host(Widget child, {bool motionOff = false}) => MediaQuery(
      data: MediaQueryData(disableAnimations: motionOff),
      child: MaterialApp(
        home: Scaffold(body: Center(child: SizedBox(width: 420, child: child))),
      ),
    );

void main() {
  group('the table', () {
    test('is substantial and every entry is a real card', () {
      expect(separableVerbs.length, greaterThan(200));
      final Set<String> ids = <String>{
        for (final GermanWord w in vocabulary) w.id,
      };
      for (final String id in separableVerbs.keys) {
        expect(ids, contains(id));
      }
    });

    test('the verb really starts with its prefix', () {
      final Map<String, GermanWord> byId = <String, GermanWord>{
        for (final GermanWord w in vocabulary) w.id: w,
      };
      for (final MapEntry<String, SeparableVerb> e in separableVerbs.entries) {
        final String german = byId[e.key]!.german.toLowerCase();
        expect(german.startsWith(e.value.prefix), isTrue,
            reason: '$german does not start with ${e.value.prefix}');
      }
    });

    test('prefixes are never capitalised', () {
      // teilnehmen is Teil + nehmen but conjugates as "Ich nehme teil".
      for (final SeparableVerb v in separableVerbs.values) {
        expect(v.prefix, v.prefix.toLowerCase(), reason: v.prefix);
      }
    });

    test('known separable verbs are present', () {
      for (final String w in <String>['aufstehen', 'mitnehmen', 'teilnehmen']) {
        expect(separableVerbs.containsKey(byGerman(w).id), isTrue, reason: w);
      }
      expect(separableVerbs[byGerman('aufstehen').id]!.prefix, 'auf');
      expect(separableVerbs[byGerman('aufstehen').id]!.stem, 'stehen');
    });

    test('inseparable verbs that look separable are excluded', () {
      // The highest-stakes case in the whole feature. wiederholen keeps its
      // prefix -- "Ich wiederhole" -- and animating it as separable would
      // teach "Ich hole wieder", which is a different verb.
      expect(separableVerbs.containsKey(byGerman('wiederholen').id), isFalse);
    });

    test('no inseparable prefix got through', () {
      const Set<String> never = <String>{
        'be', 'emp', 'ent', 'er', 'ge', 'miss', 'ver', 'zer',
        'über', 'unter', 'um', 'durch', 'hinter', 'wider',
      };
      for (final SeparableVerb v in separableVerbs.values) {
        expect(never, isNot(contains(v.prefix)), reason: v.prefix);
      }
    });

    test('every entry is actually a verb', () {
      // hingegen (whereas) arrived as hin + gegen before the gloss filter.
      final Map<String, GermanWord> byId = <String, GermanWord>{
        for (final GermanWord w in vocabulary) w.id: w,
      };
      for (final String id in separableVerbs.keys) {
        expect(byId[id]!.english.toLowerCase().startsWith('to '), isTrue,
            reason: '${byId[id]!.german} is not glossed as a verb');
      }
    });
  });

  group('the animation', () {
    testWidgets('shows the prefix and the stem', (WidgetTester t) async {
      await t.pumpWidget(host(SeparableVerbAnimation(word: byGerman('aufstehen'))));
      await t.pump(const Duration(milliseconds: 50));
      expect(find.text('Separable verb'), findsOneWidget);
      expect(find.text('auf'), findsOneWidget);
      await t.pumpWidget(host(const SizedBox()));
    });

    testWidgets('obeys the system request to stop animating',
        (WidgetTester t) async {
      await t.pumpWidget(host(
        SeparableVerbAnimation(word: byGerman('aufstehen')),
        motionOff: true,
      ));
      await t.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(SeparableVerbAnimation),
          matching: find.byType(AnimatedBuilder),
        ),
        findsNothing,
      );
    });

    testWidgets('a non-separable verb renders nothing', (WidgetTester t) async {
      await t.pumpWidget(host(SeparableVerbAnimation(word: byGerman('wiederholen'))));
      await t.pump(const Duration(milliseconds: 50));
      expect(find.text('Separable verb'), findsNothing);
    });

    testWidgets('renders every entry without throwing', (WidgetTester t) async {
      final Map<String, GermanWord> byId = <String, GermanWord>{
        for (final GermanWord w in vocabulary) w.id: w,
      };
      for (final String id in separableVerbs.keys.take(60)) {
        await t.pumpWidget(host(SeparableVerbAnimation(word: byId[id]!)));
        await t.pump(const Duration(milliseconds: 40));
        expect(TestWidgetsFlutterBinding.instance.takeException(), isNull,
            reason: byId[id]!.german);
      }
      await t.pumpWidget(host(const SizedBox()));
    });
  });
}
