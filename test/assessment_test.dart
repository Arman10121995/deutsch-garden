import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/assessment.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/test_prep.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('placement instrument has six valid items per CEFR band', () {
    expect(
      placementQuestions.map((question) => question.id).toSet().length,
      placementQuestions.length,
    );
    for (final level in CefrLevel.values) {
      final items = placementQuestionsFor(level);
      expect(items.length, 6);
      expect(items.map((item) => item.domain).toSet().length, 4);
      for (final item in items) {
        expect(item.options.length, greaterThanOrEqualTo(3));
        expect(item.correctIndex, inInclusiveRange(0, item.options.length - 1));
      }
    }
  });

  test('each level has an exam profile and two original mini mocks', () {
    for (final level in CefrLevel.values) {
      final profile = examProfileFor(level);
      expect(profile.level, level);
      expect(profile.readingMinutes, greaterThan(0));
      expect(profile.listeningMinutes, greaterThan(0));
      expect(profile.writingMinutes, greaterThan(0));
      expect(profile.speakingMinutes, greaterThan(0));
      final mocks = examSetsFor(level);
      expect(mocks.length, 2);
      for (final mock in mocks) {
        expect(mock.objectiveQuestions.length, greaterThanOrEqualTo(4));
        expect(mock.writingPrompt, isNotEmpty);
        expect(mock.speakingPrompt, isNotEmpty);
      }
    }
  });

  test('saving placement result unlocks up to achieved level', () async {
    final controller = AppController();
    await controller.load();
    expect(controller.highestUnlockedLevel, CefrLevel.a1);

    await controller.savePlacementResult(CefrLevel.b1, score: 85);
    expect(controller.highestUnlockedLevel, CefrLevel.b1);
    expect(controller.isLevelUnlocked(CefrLevel.a1), isTrue);
    expect(controller.isLevelUnlocked(CefrLevel.a2), isTrue);
    expect(controller.isLevelUnlocked(CefrLevel.b1), isTrue);
    expect(controller.isLevelUnlocked(CefrLevel.b2), isFalse);
    expect(controller.lastPlacementLevel, 'B1');
    expect(controller.lastPlacementScore, 85);
  });
}
