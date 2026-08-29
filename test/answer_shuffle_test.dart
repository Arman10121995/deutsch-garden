import 'dart:math';

import 'package:deutsch_garden/answer_shuffle.dart';
import 'package:deutsch_garden/assessment.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/test_prep.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where the answer lands over many shuffles.
List<int> positionHistogram(int optionCount, int Function(int) shuffleOnce,
    {int trials = 4000}) {
  final List<int> counts = List<int>.filled(optionCount, 0);
  for (int i = 0; i < trials; i++) {
    counts[shuffleOnce(i)] += 1;
  }
  return counts;
}

void main() {
  group('the bug this exists to prevent', () {
    test('the authored content really was answer-first', () {
      // Not a hypothetical. This is the measurement that motivated the fix,
      // pinned so the story cannot be quietly rewritten later: every single
      // placement question was authored with the answer at position 0.
      final Set<int> authored =
          placementQuestions.map((PlacementQuestion q) => q.correctIndex).toSet();
      expect(authored, <int>{0},
          reason: 'if this ever fails, the content changed and the comment in '
              'lib/answer_shuffle.dart needs updating with it');

      final Set<int> exam = <int>{
        for (final ExamPracticeSet s in examPracticeSets)
          for (final ExamObjectiveQuestion q in s.objectiveQuestions)
            q.correctIndex,
      };
      expect(exam, <int>{0});
    });

    test('tapping the top option scored 100% on placement before the fix', () {
      final int wouldHaveScored = placementQuestions
          .where((PlacementQuestion q) => q.correctIndex == 0)
          .length;
      expect(wouldHaveScored, placementQuestions.length);
      // Placement decides which level a learner starts at. A test that can be
      // passed without reading it hands a beginner a C2 course.
    });
  });

  group('shuffleChoices', () {
    test('keeps the answer pointing at the same string', () {
      final Random random = Random(1);
      for (int i = 0; i < 500; i++) {
        const List<String> options = <String>['right', 'a', 'b', 'c'];
        final ShuffledChoices s = shuffleChoices(options, 0, random);
        expect(s.options[s.correctIndex], 'right');
        expect(s.options.toSet(), options.toSet(),
            reason: 'a shuffle must not invent or lose an option');
        expect(s.options.length, options.length);
      }
    });

    test('handles repeated option strings by index, not by value', () {
      // der/die/das drills and grammar items repeat strings between options.
      // Finding the answer again with indexOf would silently mark the first
      // duplicate correct instead of the real one.
      final Random random = Random(7);
      for (int i = 0; i < 500; i++) {
        const List<String> options = <String>['der', 'die', 'das', 'die'];
        final ShuffledChoices s = shuffleChoices(options, 3, random);
        // Exactly one 'die' is the answer; the other must not be.
        expect(s.options[s.correctIndex], 'die');
        final int firstDie = s.options.indexOf('die');
        final int lastDie = s.options.lastIndexOf('die');
        expect(s.correctIndex, anyOf(firstDie, lastDie));
      }
    });

    test('reaches every position, including the last', () {
      // The authored content never once put an answer at position 4 of 4, so
      // "never the last one" was as exploitable as "always the first".
      final Random random = Random(3);
      final List<int> counts = positionHistogram(
        4,
        (_) => shuffleChoices(
          const <String>['right', 'a', 'b', 'c'],
          0,
          random,
        ).correctIndex,
      );
      for (int i = 0; i < 4; i++) {
        expect(counts[i], greaterThan(0), reason: 'position $i never used');
      }
    });

    test('is close to uniform, so no position is worth guessing', () {
      final Random random = Random(11);
      const int trials = 8000;
      final List<int> counts = positionHistogram(
        4,
        (_) => shuffleChoices(
          const <String>['right', 'a', 'b', 'c'],
          0,
          random,
        ).correctIndex,
        trials: trials,
      );
      const double expected = trials / 4;
      for (int i = 0; i < 4; i++) {
        // Generous bound: this is asserting "not exploitable", not "perfect".
        expect((counts[i] - expected).abs() / expected, lessThan(0.15),
            reason: 'position $i came up ${counts[i]} of $trials times');
      }
    });

    test('does not refuse to return the authored order', () {
      // A shuffle that guaranteed movement would mean the answer is never
      // where it was written -- and since almost everything is authored
      // answer-first, that is just "never position 0", which is exploitable
      // in exactly the same way.
      final Random random = Random(5);
      bool sawIdentity = false;
      for (int i = 0; i < 2000 && !sawIdentity; i++) {
        sawIdentity = shuffleChoices(
              const <String>['right', 'a', 'b', 'c'],
              0,
              random,
            ).correctIndex ==
            0;
      }
      expect(sawIdentity, isTrue);
    });

    test('leaves a question it cannot permute alone', () {
      final Random random = Random(2);
      // Civics questions parsed from JSON use -1 for "not answerable".
      final ShuffledChoices unanswerable =
          shuffleChoices(const <String>['a', 'b'], -1, random);
      expect(unanswerable.correctIndex, -1);
      expect(unanswerable.options, <String>['a', 'b']);

      final ShuffledChoices single =
          shuffleChoices(const <String>['only'], 0, random);
      expect(single.options, <String>['only']);
      expect(single.correctIndex, 0);

      final ShuffledChoices outOfRange =
          shuffleChoices(const <String>['a', 'b'], 9, random);
      expect(outOfRange.correctIndex, 9,
          reason: 'an index that was already wrong must not be made to look '
              'right by pointing it at an arbitrary option');
    });
  });

  group('seededFor', () {
    test('the same question and sitting give the same order every time', () {
      // A widget rebuilds for all sorts of reasons. Options that moved under
      // a finger about to tap would be their own wrong answer.
      const PlacementQuestion q = PlacementQuestion(
        id: 'pl-a1-01',
        level: CefrLevel.a1,
        domain: AssessmentDomain.vocabulary,
        prompt: 'p',
        options: <String>['right', 'a', 'b', 'c'],
        correctIndex: 0,
        explanation: 'e',
      );
      final List<String> first = q.shuffled(seededFor(q.id, 42)).options;
      for (int i = 0; i < 20; i++) {
        expect(q.shuffled(seededFor(q.id, 42)).options, first);
      }
    });

    test('a different sitting gives a different order', () {
      const PlacementQuestion q = PlacementQuestion(
        id: 'pl-a1-01',
        level: CefrLevel.a1,
        domain: AssessmentDomain.vocabulary,
        prompt: 'p',
        options: <String>['right', 'a', 'b', 'c'],
        correctIndex: 0,
        explanation: 'e',
      );
      final Set<int> positions = <int>{
        for (int salt = 0; salt < 60; salt++)
          q.shuffled(seededFor(q.id, salt)).correctIndex,
      };
      expect(positions.length, greaterThan(1),
          reason: 'the answer must move between sittings');
    });

    test('two questions in one sitting do not share an order', () {
      // Seeding from the salt alone would put every answer of a sitting in
      // the same position, which is the original bug with extra steps.
      final Set<int> positions = <int>{
        for (final PlacementQuestion q in placementQuestions.take(40))
          q.shuffled(seededFor(q.id, 7)).correctIndex,
      };
      expect(positions.length, greaterThan(1));
    });
  });

  group('the real content, through the real shuffle', () {
    test('placement answers spread across all four positions', () {
      final List<int> counts = List<int>.filled(4, 0);
      for (int salt = 0; salt < 200; salt++) {
        for (final PlacementQuestion q in placementQuestions) {
          if (q.options.length != 4) continue;
          counts[q.shuffled(seededFor(q.id, salt)).correctIndex] += 1;
        }
      }
      final int total = counts.reduce((int a, int b) => a + b);
      expect(total, greaterThan(0));
      for (int i = 0; i < 4; i++) {
        final double share = counts[i] / total;
        expect(share, greaterThan(0.20),
            reason: 'position $i holds only ${(share * 100).toStringAsFixed(1)}%');
        expect(share, lessThan(0.30),
            reason: 'position $i holds ${(share * 100).toStringAsFixed(1)}%');
      }
    });

    test('every placement question still has exactly one right answer', () {
      // The permutation must not damage the content it permutes.
      for (int salt = 0; salt < 25; salt++) {
        for (final PlacementQuestion q in placementQuestions) {
          final PlacementQuestion s = q.shuffled(seededFor(q.id, salt));
          expect(s.options[s.correctIndex], q.options[q.correctIndex],
              reason: '${q.id} lost its answer at salt $salt');
          expect(s.options.length, q.options.length);
          expect(s.prompt, q.prompt);
          expect(s.explanation, q.explanation);
          expect(s.level, q.level);
          expect(s.domain, q.domain);
        }
      }
    });

    test('exam prep answers move too', () {
      final List<int> counts = List<int>.filled(4, 0);
      int total = 0;
      for (int salt = 0; salt < 200; salt++) {
        for (final ExamPracticeSet set in examPracticeSets) {
          for (final ExamObjectiveQuestion q in set.objectiveQuestions) {
            if (q.options.length != 4) continue;
            final ExamObjectiveQuestion s =
                q.shuffled(seededFor(q.prompt, salt));
            expect(s.options[s.correctIndex], q.options[q.correctIndex]);
            counts[s.correctIndex] += 1;
            total += 1;
          }
        }
      }
      expect(total, greaterThan(0));
      for (int i = 0; i < 4; i++) {
        expect(counts[i] / total, greaterThan(0.20));
      }
    });

    test('a ChoiceQuestion keeps its answer through a permutation', () {
      final Random random = Random(13);
      const ChoiceQuestion q = ChoiceQuestion(
        prompt: 'Which is correct?',
        options: <String>['Ich lerne Deutsch.', 'Ich Deutsch lerne.', 'x', 'y'],
        correctIndex: 0,
        explanation: 'verb second',
      );
      for (int i = 0; i < 300; i++) {
        final ChoiceQuestion s = q.shuffled(random);
        expect(s.options[s.correctIndex], 'Ich lerne Deutsch.');
        expect(s.explanation, q.explanation);
      }
    });
  });
}
