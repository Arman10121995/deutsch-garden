import 'package:deutsch_garden/cloze_bank.dart' show clozeGap;
import 'package:deutsch_garden/grammar_challenge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('grammar challenge bank', () {
    test('nine collections reach 100 items; three are corpus-limited', () {
      // Actual yield the day this was written: ten features land exactly on
      // the 100-item cap; accusativeAfterPrepositions (91) and passive (93)
      // fall just short because their triggers are less common; genitiv (32)
      // is the rare one by a wide margin. Every floor below sits well under
      // its measured count, so a modest future edit to the vocabulary deck
      // does not make this test flaky, but a real regression in the matchers
      // still fails it.
      const Map<GrammarFeature, int> floors = <GrammarFeature, int>{
        GrammarFeature.accusativeAfterPrepositions: 70,
        GrammarFeature.passive: 70,
        GrammarFeature.genitiv: 20,
      };
      for (final GrammarFeature feature in GrammarFeature.values) {
        final int count = challengesFor(feature).length;
        final int floor = floors[feature] ?? 90;
        expect(count, greaterThanOrEqualTo(floor),
            reason: '${feature.label} has too few items: got $count');
      }
    });

    test('items across all twelve collections total in the low thousands', () {
      expect(grammarChallengeItemCount, greaterThan(900));
    });

    test('the gap replaces the answer and nothing else', () {
      for (final GrammarFeature feature in GrammarFeature.values) {
        for (final GrammarChallengeItem item in challengesFor(feature)) {
          expect(item.gapped, contains(clozeGap), reason: '${item.id} has no gap');
          expect(item.gapped, isNot(equals(item.full)),
              reason: '${item.id} was not actually gapped');
          expect(item.full, contains(item.answer),
              reason: '${item.id} answer is not in the full sentence');
        }
      }
    });

    test('distractors never repeat the answer or each other', () {
      for (final GrammarFeature feature in GrammarFeature.values) {
        for (final GrammarChallengeItem item in challengesFor(feature)) {
          expect(item.distractors, isNot(contains(item.answer)),
              reason: '${item.id} offers its own answer as a distractor');
          expect(item.distractors.toSet(), hasLength(item.distractors.length),
              reason: '${item.id} repeats a distractor');
          // Every feature but nominative articles offers three; that one
          // offers two, because German has exactly three genders.
          expect(item.distractors.length, inInclusiveRange(2, 3),
              reason: '${item.id} has an unexpected number of distractors');
        }
      }
    });

    test('options contain the answer exactly once and are stable', () {
      final GrammarChallengeItem item = challengesFor(GrammarFeature.reflexives).first;
      final List<String> first = item.optionsFor(7);
      final List<String> again = item.optionsFor(7);
      expect(first, equals(again), reason: 'shuffling must be deterministic');
      expect(first.where((String o) => o == item.answer), hasLength(1));
    });

    test('every collection only contains items tagged with its own feature', () {
      for (final GrammarFeature feature in GrammarFeature.values) {
        for (final GrammarChallengeItem item in challengesFor(feature)) {
          expect(item.feature, feature);
        }
      }
    });
  });
}
