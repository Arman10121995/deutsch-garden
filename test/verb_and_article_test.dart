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

  test('vocabulary articles are valid across all CEFR bands', () async {
    final controller = AppController();
    await controller.load();

    for (final CefrLevel level in CefrLevel.values) {
      final words = controller.wordsForLevel(level);
      final nouns = words.where((w) => w.article.isNotEmpty).toList();
      for (final n in nouns) {
        expect(['der', 'die', 'das'], contains(n.article.toLowerCase()),
            reason: '${n.id} has invalid article ${n.article}');
      }
    }
  });

  test('practice sentence bank supports cloze and shadowing drills', () {
    for (final CefrLevel level in CefrLevel.values) {
      final sentences = sentencesFor(level);
      expect(sentences, isNotEmpty, reason: '${level.label} sentence bank empty');
      for (final s in sentences) {
        expect(s.tokens.length, greaterThanOrEqualTo(2));
        expect(s.german.trim(), isNotEmpty);
        expect(s.english.trim(), isNotEmpty);
      }
    }
  });
}
