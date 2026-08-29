import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppController.debounceWrites = false;
  });

  tearDown(() => AppController.debounceWrites = true);

  GermanWord anyWord() => vocabulary.first;

  test('a skipped question joins the review queue', () async {
    // The mistake bank is what already drives targeted practice, so a skip
    // needs no second mechanism to be "marked for review".
    final AppController controller = AppController();
    await controller.load();

    await controller.recordSkip(
      id: 'gram-a1-1-q0',
      prompt: 'Ich sehe ___ Mann.',
      correctAnswer: 'den',
      source: 'grammar',
      level: 'A1',
    );

    expect(controller.mistakes, hasLength(1));
    expect(controller.mistakes.first.givenAnswer, 'Skipped');
    expect(controller.mistakes.first.correctAnswer, 'den');
    expect(controller.mistakes.first.source, 'grammar');
    expect(controller.skippedCount, 1);
  });

  test('skipping a vocabulary card makes it harder, not invisible', () async {
    // The failure mode this prevents: a learner skips a card repeatedly while
    // the scheduler goes on believing it is known, so it drifts to a long
    // interval and disappears. Skipping has to cost the card something.
    final AppController controller = AppController();
    await controller.load();
    final GermanWord word = anyWord();

    // Graduate it first, so there is an interval to lose.
    await controller.answer(word, correct: true);
    await controller.answer(word, correct: true);
    await controller.answer(word, correct: true);
    final WordProgress before = controller.progressFor(word.id);
    final int intervalBefore = before.intervalDays;
    final double easeBefore = before.ease;
    final int lapsesBefore = before.lapses;

    await controller.recordSkip(
      id: 'vocab-${word.id}',
      prompt: word.english,
      correctAnswer: word.displayGerman,
      source: 'vocabulary',
      level: word.level,
      word: word,
    );

    final WordProgress after = controller.progressFor(word.id);
    expect(after.lapses, greaterThan(lapsesBefore),
        reason: 'a skip is a lapse: the card must come back sooner');
    expect(after.ease, lessThanOrEqualTo(easeBefore),
        reason: 'a skipped card is a harder card');
    expect(after.intervalDays, lessThanOrEqualTo(intervalBefore));
  });

  test('skipping is not counted as a wrong answer', () async {
    // Declining to guess is honest. Punishing it in the accuracy statistics
    // would teach guessing, which is exactly what the answer-shuffle fix was
    // for -- it would be perverse to remove the incentive to guess from the
    // option order and then add it back here.
    final AppController controller = AppController();
    await controller.load();
    final GermanWord word = anyWord();
    final int wrongBefore = controller.totalWrong;

    await controller.recordSkip(
      id: 'vocab-${word.id}',
      prompt: word.english,
      correctAnswer: word.displayGerman,
      source: 'vocabulary',
      level: word.level,
      word: word,
    );

    expect(controller.totalWrong, wrongBefore,
        reason: 'a skip must not inflate the wrong-answer count');
  });

  test('skipping the same question twice does not duplicate it', () async {
    final AppController controller = AppController();
    await controller.load();
    for (int i = 0; i < 3; i++) {
      await controller.recordSkip(
        id: 'gram-a1-1-q0',
        prompt: 'p',
        correctAnswer: 'den',
        source: 'grammar',
        level: 'A1',
      );
    }
    expect(controller.mistakes, hasLength(1));
  });

  test('a skip survives a restart', () async {
    final AppController first = AppController();
    await first.load();
    await first.recordSkip(
      id: 'gram-a1-1-q0',
      prompt: 'p',
      correctAnswer: 'den',
      source: 'grammar',
      level: 'A1',
    );
    await first.flushSave();

    final AppController second = AppController();
    await second.load();
    expect(second.skippedCount, 1);
  });
}
