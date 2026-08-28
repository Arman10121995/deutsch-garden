import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Everything an undo has to put back.
Map<String, Object> snapshot(WordProgress p) => <String, Object>{
      'interval': p.intervalDays,
      'ease': p.ease,
      'due': p.dueAt,
      'reps': p.reps,
      'lapses': p.lapses,
      'step': p.learningStep,
      'correct': p.correct,
      'wrong': p.wrong,
      'mastery': p.mastery,
    };

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<AppController> boot() async {
    final AppController c = AppController();
    addTearDown(c.dispose);
    await c.load();
    return c;
  }

  group('undoing a misgrade', () {
    testWidgets('puts the card back exactly, on a graduated card',
        (WidgetTester tester) async {
      final AppController c = await boot();
      final GermanWord word = vocabulary.first;

      // Get it out of learning and onto a real interval first, so the undo
      // has non-trivial state to restore.
      await c.gradeWord(word, ReviewGrade.good);
      await c.gradeWord(word, ReviewGrade.good);
      await c.gradeWord(word, ReviewGrade.good);
      final Map<String, Object> before = snapshot(c.progressFor(word.id));
      final int logLength = c.reviewLog.length;

      // The misgrade.
      await c.gradeWord(word, ReviewGrade.again);
      expect(snapshot(c.progressFor(word.id)), isNot(before));

      expect(await c.undoLastReview(word.id), isTrue);
      expect(snapshot(c.progressFor(word.id)), before);
      expect(c.reviewLog, hasLength(logLength),
          reason: 'the reverted answer must leave the history, or it would '
              'be counted twice by anything reading the log');
    });

    testWidgets('rewinds the correctness tallies but not the points',
        (WidgetTester tester) async {
      final AppController c = await boot();
      final GermanWord word = vocabulary.first;
      final int xpBefore = c.xp;

      await c.gradeWord(word, ReviewGrade.again);
      expect(c.totalWrong, 1);
      final int xpAfterGrade = c.xp;

      await c.undoLastReview(word.id);

      expect(c.totalWrong, 0, reason: 'accuracy is arithmetic and must be '
          'corrected');
      expect(c.progressFor(word.id).wrong, 0);
      expect(c.xp, xpAfterGrade,
          reason: 'XP already shown to the learner is not clawed back; '
              'gamification is not scheduling');
      expect(c.xp, greaterThanOrEqualTo(xpBefore));
    });

    testWidgets('undoes only the last review of that card',
        (WidgetTester tester) async {
      final AppController c = await boot();
      final GermanWord first = vocabulary[0];
      final GermanWord second = vocabulary[1];

      await c.gradeWord(first, ReviewGrade.good);
      await c.gradeWord(second, ReviewGrade.good);
      await c.gradeWord(first, ReviewGrade.again);

      await c.undoLastReview(first.id);

      expect(c.reviewLog.map((ReviewEvent e) => e.itemId),
          <String>[first.id, second.id],
          reason: 'the other card and the earlier review are untouched');
    });

    testWidgets('a lesson can be reverted too', (WidgetTester tester) async {
      final AppController c = await boot();
      await c.recordActivity('a-lesson', score: 100);
      final int intervalAfterPass = c.progressForActivity('a-lesson').intervalDays;
      expect(intervalAfterPass, greaterThan(0));

      expect(await c.undoLastReview('a-lesson'), isTrue);
      expect(c.progressForActivity('a-lesson').intervalDays, 0);
      expect(c.reviewLog, isEmpty);
    });

    testWidgets('returns false when there is nothing to undo',
        (WidgetTester tester) async {
      final AppController c = await boot();
      expect(await c.undoLastReview(vocabulary.first.id), isFalse);
      expect(await c.undoLastReview('never-seen'), isFalse);
    });

    testWidgets('undoing twice walks back two answers',
        (WidgetTester tester) async {
      final AppController c = await boot();
      final GermanWord word = vocabulary.first;
      final Map<String, Object> pristine = snapshot(c.progressFor(word.id));

      await c.gradeWord(word, ReviewGrade.good);
      await c.gradeWord(word, ReviewGrade.good);
      await c.undoLastReview(word.id);
      await c.undoLastReview(word.id);

      expect(snapshot(c.progressFor(word.id)), pristine);
      expect(c.reviewLog, isEmpty);
    });

    testWidgets('the undo survives a save and reload',
        (WidgetTester tester) async {
      final AppController first = await boot();
      final GermanWord word = vocabulary.first;
      await first.gradeWord(word, ReviewGrade.good);
      await first.gradeWord(word, ReviewGrade.again);
      await first.undoLastReview(word.id);
      final Map<String, Object> expected = snapshot(first.progressFor(word.id));
      await first.flushSave();

      final AppController second = AppController();
      addTearDown(second.dispose);
      await second.load();

      expect(snapshot(second.progressFor(word.id)), expected);
      expect(second.reviewLog, hasLength(1));
    });
  });

  group('lastReviewOf', () {
    testWidgets('finds the most recent, not the first',
        (WidgetTester tester) async {
      final AppController c = await boot();
      final GermanWord word = vocabulary.first;
      await c.gradeWord(word, ReviewGrade.good);
      await c.gradeWord(word, ReviewGrade.again);
      expect(c.lastReviewOf(word.id)!.grade, ReviewGrade.again);
      expect(c.lastReviewOf('nothing-here'), isNull);
    });
  });
}
