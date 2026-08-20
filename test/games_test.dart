import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/sentence_bank.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('mistake bank limits list size and sorts newest first', () async {
    final controller = AppController();
    await controller.load();

    for (int i = 0; i < 210; i++) {
      await controller.addMistake(
        MistakeEntry(
          id: 'm-$i',
          prompt: 'Prompt $i',
          correctAnswer: 'Answer $i',
          givenAnswer: 'Given $i',
          source: i % 2 == 0 ? 'vocabulary' : 'grammar',
          level: 'A1',
          timestamp: DateTime.now(),
        ),
      );
    }

    expect(controller.mistakes.length, AppController.mistakeBankLimit);
    expect(controller.mistakes.first.id, 'm-209');
  });

  test('mistake bank clear operations function correctly', () async {
    final controller = AppController();
    await controller.load();

    await controller.addMistake(
      MistakeEntry(
        id: 'test-1',
        prompt: 'Guten Tag',
        correctAnswer: 'Hello',
        givenAnswer: 'Bye',
        source: 'vocabulary',
        level: 'A1',
        timestamp: DateTime.now(),
      ),
    );
    expect(controller.mistakes.length, 1);

    await controller.clearMistake('test-1');
    expect(controller.mistakes, isEmpty);
    expect(controller.mistakesCleared, 1);

    await controller.addMistake(
      MistakeEntry(
        id: 'test-2',
        prompt: 'Wie gehts?',
        correctAnswer: 'How are you?',
        givenAnswer: 'Good',
        source: 'grammar',
        level: 'A1',
        timestamp: DateTime.now(),
      ),
    );

    await controller.clearAllMistakes();
    expect(controller.mistakes, isEmpty);
    expect(controller.mistakesCleared, 2);
  });

  test('sentence bank tokens produce valid German sentences', () {
    for (final CefrLevel level in CefrLevel.values) {
      final sentences = sentencesFor(level);
      for (final s in sentences) {
        expect(s.tokens, isNotEmpty);
        expect(s.german.trim(), isNotEmpty);
        expect(s.english.trim(), isNotEmpty);
      }
    }
  });
}
