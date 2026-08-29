import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/glosses.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

GermanWord wordWithId(String id) =>
    vocabulary.firstWhere((GermanWord w) => w.id == id);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    debugClearGlosses();
  });

  tearDown(debugClearGlosses);

  group('the shipped Turkish table', () {
    test('loads from the bundled asset', () async {
      await loadGlosses('tr', bundle: rootBundle);
      expect(glossCount('tr'), greaterThan(400));
      expect(glossFor(wordWithId('041'), 'tr'), 'elma');
      expect(glossFor(wordWithId('043'), 'tr'), 'ekmek');
      expect(glossFor(wordWithId('x20142'), 'tr'), 'köpek');
    });

    test('covers the concrete nouns and nothing it cannot vouch for',
        () async {
      await loadGlosses('tr', bundle: rootBundle);
      // Abstract cards are deliberately left to the English gloss rather than
      // given a Turkish word that narrows a meaning the English was careful
      // about.
      expect(glossFor(wordWithId('069'), 'tr'), isNull);
      expect(meaningFor(wordWithId('069'), 'tr'), wordWithId('069').english,
          reason: 'a blank where a meaning should be is worse than a meaning '
              'in the wrong language');
    });
  });

  group('resolution', () {
    test('English is the fallback, not an entry in the table', () {
      debugSetGlosses('tr', <String, String>{'041': 'elma'});
      expect(meaningFor(wordWithId('041'), 'tr'), 'elma');
      expect(meaningFor(wordWithId('042'), 'tr'), wordWithId('042').english);
      expect(meaningFor(wordWithId('041'), ''), wordWithId('041').english,
          reason: 'an empty language code means English');
    });

    test('glossFor distinguishes "not covered" from "same as English"', () {
      debugSetGlosses('tr', <String, String>{'041': 'elma'});
      expect(glossFor(wordWithId('042'), 'tr'), isNull);
      expect(glossFor(wordWithId('041'), 'tr'), isNotNull);
    });

    test('an unknown language is empty rather than an error', () async {
      await loadGlosses('xx', bundle: rootBundle);
      expect(glossCount('xx'), 0);
      expect(meaningFor(wordWithId('041'), 'xx'), wordWithId('041').english);
    });

    test('the language list does not offer English', () {
      // English is on the card. Listing it as a gloss language would imply a
      // table that does not exist.
      expect(GlossLanguage.available.map((GlossLanguage g) => g.code),
          isNot(contains('en')));
      expect(GlossLanguage.byCode('tr'), isNotNull);
      expect(GlossLanguage.byCode('en'), isNull);
    });
  });

  group('through the controller', () {
    Future<AppController> boot() async {
      final AppController c = AppController();
      addTearDown(c.dispose);
      await c.load();
      return c;
    }

    test('defaults to English', () async {
      final AppController c = await boot();
      expect(c.glossLanguage, '');
      expect(c.meaningOf(wordWithId('041')), wordWithId('041').english);
    });

    test('switching loads the table before the change is announced', () async {
      final AppController c = await boot();
      await c.setGlossLanguage('tr');
      expect(c.meaningOf(wordWithId('041')), 'elma',
          reason: 'a list of two hundred words should not build once in '
              'English and then rebuild');
    });

    test('an unsupported code is refused rather than stored', () async {
      final AppController c = await boot();
      await c.setGlossLanguage('kl');
      expect(c.glossLanguage, '');
    });

    test('the choice survives a restart', () async {
      final AppController first = await boot();
      await first.setGlossLanguage('tr');
      await first.flushSave();

      final AppController second = AppController();
      addTearDown(second.dispose);
      await second.load();
      expect(second.glossLanguage, 'tr');
      expect(second.meaningOf(wordWithId('043')), 'ekmek',
          reason: 'load() should have read the table, not left it lazy');
    });

    test('the gloss language is independent of the interface language',
        () async {
      final AppController c = await boot();
      await c.setGlossLanguage('tr');
      expect(c.uiLocale, isNull,
          reason: 'choosing Turkish glosses must not silently change the '
              'language of the app itself');
    });
  });
}
