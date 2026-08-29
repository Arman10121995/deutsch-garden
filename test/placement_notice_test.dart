import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/models.dart';
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

  test('a fresh profile is told nothing', () async {
    final AppController c = AppController();
    await c.load();
    expect(c.placementPredatesShuffle, isFalse,
        reason: 'there is no stale result to warn about');
  });

  test('an old result is flagged exactly once', () async {
    final AppController c = AppController();
    await c.load();
    // A profile written before the stamp existed: has a result, no stamp.
    c.lastPlacementLevel = 'C2';
    expect(c.placementPredatesShuffle, isTrue);

    await c.dismissPlacementNotice();
    expect(c.placementPredatesShuffle, isFalse,
        reason: 'told once, then never again');
  });

  test('the dismissal survives a restart', () async {
    // The whole point. A notice that came back on every launch would be
    // nagging about a decision that belongs to the learner.
    final AppController first = AppController();
    await first.load();
    first.lastPlacementLevel = 'B2';
    await first.dismissPlacementNotice();
    await first.flushSave();

    final AppController second = AppController();
    await second.load();
    expect(second.placementNoticeDismissed, isTrue);
    expect(second.placementPredatesShuffle, isFalse);
  });

  test('a new result stamps itself and needs no notice', () async {
    final AppController c = AppController();
    await c.load();
    await c.savePlacementResult(CefrLevel.b1, score: 80);
    expect(c.placementWasShuffled, isTrue);
    expect(c.placementPredatesShuffle, isFalse);
  });

  test('retaking answers the notice without a separate dismissal', () async {
    final AppController c = AppController();
    await c.load();
    c.lastPlacementLevel = 'C2';
    expect(c.placementPredatesShuffle, isTrue);

    await c.savePlacementResult(CefrLevel.a2, score: 55);
    expect(c.placementPredatesShuffle, isFalse);
    expect(c.lastPlacementLevel, 'A2');
  });

  test('the old level is not silently discarded', () async {
    // Resetting someone's recorded level without asking would be its own
    // kind of wrong. The notice informs; it does not act.
    final AppController c = AppController();
    await c.load();
    c.lastPlacementLevel = 'C2';
    c.placementUnlockedOrder = CefrLevel.c2.order;

    await c.dismissPlacementNotice();
    expect(c.lastPlacementLevel, 'C2');
    expect(c.placementUnlockedOrder, CefrLevel.c2.order);
  });
}
