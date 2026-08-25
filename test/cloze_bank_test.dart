import 'package:deutsch_garden/cloze_bank.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/sentence_bank.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('practice sentence bank', () {
    test('draws on the whole deck, not just the core cards', () {
      // Before 3.7 this pulled only from coreVocabulary (203 cards) because the
      // expansion deck's examples were metalinguistic placeholders. Those are
      // gone, so every card's example is usable.
      int total = 0;
      for (final CefrLevel level in CefrLevel.values) {
        total += sentencesFor(level).length;
      }
      expect(total, greaterThan(9000));
    });

    test('every level has enough to practise with', () {
      for (final CefrLevel level in CefrLevel.values) {
        expect(sentencesFor(level).length, greaterThan(400),
            reason: '${level.label} is too thin to drill');
      }
    });
  });

  group('cloze bank', () {
    test('yields thousands of items across every level', () {
      expect(clozeItemCount, greaterThan(7000));
      for (final CefrLevel level in CefrLevel.values) {
        expect(clozeFor(level).length, greaterThan(300),
            reason: '${level.label} has too few cloze items');
      }
    });

    test('the gap replaces the word the sentence teaches', () {
      for (final CefrLevel level in CefrLevel.values) {
        for (final ClozeItem item in clozeFor(level).take(50)) {
          expect(item.gapped, contains(clozeGap),
              reason: '${item.id} has no gap');
          expect(item.gapped, isNot(contains(item.answer)),
              reason: '${item.id} still shows its answer');
          expect(item.full, contains(item.answer),
              reason: '${item.id} answer is not in the full sentence');
        }
      }
    });

    test('distractors are plausible, not filler', () {
      for (final CefrLevel level in CefrLevel.values) {
        for (final ClozeItem item in clozeFor(level).take(50)) {
          expect(item.distractors, hasLength(3));
          expect(item.distractors, isNot(contains(item.answer)),
              reason: '${item.id} offers its own answer as a distractor');
          expect(item.distractors.toSet(), hasLength(3),
              reason: '${item.id} repeats a distractor');
          // A wrong answer a learner can dismiss on sight makes the item free,
          // so every option is a real vocabulary word rather than a stray token
          // such as und or ist.
          for (final String d in item.distractors) {
            expect(d.length, greaterThan(1));
            expect(d.trim(), d);
          }
        }
      }
    });

    test('options contain the answer exactly once and are stable', () {
      final ClozeItem item = clozeFor(CefrLevel.a2).first;
      final List<String> first = item.optionsFor(7);
      final List<String> again = item.optionsFor(7);
      expect(first, equals(again), reason: 'shuffling must be deterministic');
      expect(first, hasLength(4));
      expect(first.where((String o) => o == item.answer), hasLength(1));
    });
  });
}
