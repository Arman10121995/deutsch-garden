import 'package:deutsch_garden/audio_course.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/sentence_bank.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the day schedule', () {
    test('day one introduces ten sentences and reviews nothing', () {
      final Playlist day1 = playlistFor(CefrLevel.a1, 1);
      expect(day1.newCount, audioCourseNewPerDay);
      expect(day1.reviewCount, 0);
    });

    test('a day brings back the batches at the documented gaps', () {
      // Day 34 is the first day every gap is reachable: 33, 32, 30, 26, 18, 2.
      final Playlist day = playlistFor(CefrLevel.a1, 34);
      expect(day.newCount, audioCourseNewPerDay);

      final Set<int> sources = day.items
          .where((PlaylistItem i) => !i.isNew)
          .map((PlaylistItem i) => i.fromDay)
          .toSet();
      expect(sources, <int>{33, 32, 30, 26, 18, 2});
      expect(day.reviewCount, audioCourseGaps.length * audioCourseNewPerDay);
    });

    test('early days only review what exists', () {
      // Day 3 can look back one and two days, but not four.
      final Playlist day3 = playlistFor(CefrLevel.a1, 3);
      final Set<int> sources = day3.items
          .where((PlaylistItem i) => !i.isNew)
          .map((PlaylistItem i) => i.fromDay)
          .toSet();
      expect(sources, <int>{1, 2});
    });

    test('a sentence appears once in a playlist even if two gaps hit it', () {
      for (int day = 1; day <= 40; day++) {
        final Playlist p = playlistFor(CefrLevel.a1, day);
        final List<String> ids =
            p.items.map((PlaylistItem i) => i.sentence.id).toList();
        expect(ids.toSet().length, ids.length, reason: 'day $day repeats');
      }
    });

    test('new material comes first, then oldest review to newest', () {
      final Playlist day = playlistFor(CefrLevel.a1, 34);
      final List<PlaylistItem> items = day.items;
      final int firstReview =
          items.indexWhere((PlaylistItem i) => !i.isNew);
      // Everything before the first review is new, everything after is not.
      expect(items.take(firstReview).every((PlaylistItem i) => i.isNew), isTrue);
      expect(items.skip(firstReview).any((PlaylistItem i) => i.isNew), isFalse);

      final List<int> reviewDays = items
          .skip(firstReview)
          .map((PlaylistItem i) => i.fromDay)
          .toSet()
          .toList();
      expect(reviewDays, List<int>.from(reviewDays)..sort());
    });

    test('a sentence met on day one is heard six more times, then stops', () {
      final String target = playlistFor(CefrLevel.a1, 1).items.first.sentence.id;
      final List<int> heard = <int>[
        for (int day = 1; day <= 60; day++)
          if (playlistFor(CefrLevel.a1, day)
              .items
              .any((PlaylistItem i) => i.sentence.id == target))
            day,
      ];
      // Introduced on 1, then one, two, four, eight, sixteen and thirty-two
      // days later.
      expect(heard, <int>[1, 2, 3, 5, 9, 17, 33]);
    });

    test('the course runs out rather than looping', () {
      final int total = totalDaysFor(CefrLevel.a1);
      expect(playlistFor(CefrLevel.a1, total).newCount, greaterThan(0));
      expect(playlistFor(CefrLevel.a1, total + 1).newCount, 0);
      // Past the end there is still review material for a while, and then
      // nothing at all.
      expect(playlistFor(CefrLevel.a1, total + 100).isEmpty, isTrue);
    });

    test('day zero and below produce nothing rather than throwing', () {
      expect(playlistFor(CefrLevel.a1, 0).isEmpty, isTrue);
      expect(playlistFor(CefrLevel.a1, -5).isEmpty, isTrue);
    });

    test('every level has a course worth doing', () {
      for (final CefrLevel level in CefrLevel.values) {
        expect(totalDaysFor(level), greaterThan(20),
            reason: '${level.label} has too few sentences to schedule');
        expect(playlistFor(level, 1).newCount, audioCourseNewPerDay);
      }
    });
  });

  group('the anticipation gap', () {
    test('scales with sentence length, within bounds', () {
      const PracticeSentence short = PracticeSentence(
        id: 't1',
        level: CefrLevel.a1,
        german: 'Ich bin müde.',
        english: 'I am tired.',
      );
      const PracticeSentence long = PracticeSentence(
        id: 't2',
        level: CefrLevel.b2,
        german: 'Nachdem wir das Problem besprochen hatten, haben wir uns auf '
            'einen gemeinsamen Vorschlag geeinigt.',
        english: 'After we had discussed the problem, we agreed on a joint '
            'proposal.',
      );

      // A three-word sentence still gets thinking time rather than a blink.
      expect(gapFor(short), const Duration(milliseconds: 2500));
      expect(gapFor(long), greaterThan(gapFor(short)));
      // And a very long sentence does not leave the learner in silence.
      expect(gapFor(long), lessThanOrEqualTo(const Duration(seconds: 9)));
    });
  });

  group('batch arithmetic', () {
    test('the last batch is short rather than overrunning', () {
      expect(batchIndices(1, 25), <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(batchIndices(3, 25), <int>[20, 21, 22, 23, 24]);
      expect(batchIndices(4, 25), isEmpty);
    });
  });
}
