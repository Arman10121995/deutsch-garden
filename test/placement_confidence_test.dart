import 'package:deutsch_garden/assessment.dart';
import 'package:deutsch_garden/models.dart';
import 'package:flutter_test/flutter_test.dart';

PlacementBandResult band(int correct, int total) =>
    PlacementBandResult(level: CefrLevel.b1, correct: correct, total: total);

void main() {
  group('the Wilson interval', () {
    test('does not claim certainty from a clean sweep', () {
      // The normal approximation gives a zero-width interval here -- six
      // questions and therefore complete confidence -- which is the reason
      // it is not used.
      final ConfidenceInterval ci = wilsonInterval(6, 6);
      expect(ci.low, lessThan(1.0));
      expect(ci.high, closeTo(1.0, 0.001));
      expect(ci.low, greaterThan(placementThreshold),
          reason: '6/6 should be enough to place above the band');
    });

    test('is widest where the answer is least clear', () {
      expect(wilsonInterval(3, 6).width,
          greaterThan(wilsonInterval(6, 6).width));
    });

    test('narrows as more items are answered', () {
      // Same proportion, more evidence.
      expect(wilsonInterval(20, 30).width, lessThan(wilsonInterval(4, 6).width));
    });

    test('a total of zero admits it knows nothing', () {
      expect(wilsonInterval(0, 0), const ConfidenceInterval(0, 1));
    });

    test('stays inside 0 and 1', () {
      for (int n = 1; n <= 12; n++) {
        for (int k = 0; k <= n; k++) {
          final ConfidenceInterval ci = wilsonInterval(k, n);
          expect(ci.low, greaterThanOrEqualTo(0.0));
          expect(ci.high, lessThanOrEqualTo(1.0));
          expect(ci.low, lessThanOrEqualTo(ci.high));
        }
      }
    });
  });

  group('the band verdict', () {
    test('four out of six is the coin flip, and is not treated as a pass', () {
      // 4/6 is 66.7%, a hair under the mark on a bare comparison and over it
      // on a generous one. Its interval runs roughly 39-86%, so it does not
      // distinguish someone who has the level from someone who guessed two.
      expect(band(4, 6).verdict(), BandVerdict.unclear);
      expect(band(5, 6).verdict(), BandVerdict.unclear);
    });

    test('an unambiguous band settles at six', () {
      expect(band(6, 6).verdict(), BandVerdict.pass);
      expect(band(0, 6).verdict(), BandVerdict.fail);
      expect(band(1, 6).verdict(), BandVerdict.fail);
    });

    test('the extra four items can settle what six could not', () {
      expect(band(5, 6).verdict(), BandVerdict.unclear);
      expect(band(9, 10).verdict(), BandVerdict.pass,
          reason: 'this is the case the reserve items exist for');
      expect(band(3, 10).verdict(), BandVerdict.fail);
    });

    test('a genuinely borderline learner is still borderline at ten', () {
      // 7/10 is not a failure of the method; it is the honest answer that ten
      // multiple-choice items cannot separate this learner from the mark.
      expect(band(7, 10).verdict(), BandVerdict.unclear);
      expect(band(6, 10).verdict(), BandVerdict.unclear);
    });

    test('95% confidence would never settle a band, which is why it is not '
        'the operating point', () {
      expect(band(6, 6).verdict(z: 1.96), BandVerdict.unclear);
      expect(band(9, 10).verdict(z: 1.96), BandVerdict.unclear);
    });
  });

  group('the widened bank', () {
    test('every level carries ten items', () {
      for (final CefrLevel level in CefrLevel.values) {
        expect(placementQuestionsFor(level), hasLength(10),
            reason: '${level.label} must be able to reach the reserve items');
      }
    });

    test('the first six of every band still cover all four domains', () {
      // Most learners stop at six, so the sample they are judged on has to be
      // balanced on its own -- not only once the reserve items are included.
      for (final CefrLevel level in CefrLevel.values) {
        final Set<AssessmentDomain> covered = placementQuestionsFor(level)
            .take(6)
            .map((PlacementQuestion q) => q.domain)
            .toSet();
        expect(covered, hasLength(AssessmentDomain.values.length),
            reason: '${level.label} first six cover $covered');
      }
    });

    test('ids are unique across the whole bank', () {
      final List<String> ids =
          placementQuestions.map((PlacementQuestion q) => q.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('every item has four options and a correct index inside them', () {
      for (final PlacementQuestion q in placementQuestions) {
        expect(q.options, hasLength(4), reason: q.id);
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
        expect(q.explanation, isNotEmpty, reason: q.id);
      }
    });
  });
}
