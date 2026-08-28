import 'dart:convert';
import 'dart:io';

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/review_store.dart';
import 'package:deutsch_garden/review_store_io.dart';
import 'package:deutsch_garden/srs.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String kStateKey = 'deutsch_garden_state_v4';

/// A database nobody else is using.
///
/// `inMemoryDatabasePath` looked like the obvious choice and is a trap: in
/// sqflite_common_ffi it names one shared database, so each test opened the
/// previous test's rows and the counts climbed -- 120, 121, 122 -- until the
/// assertions stopped meaning anything.
int _dbSeq = 0;
String freshDbPath() {
  final Directory dir =
      Directory.systemTemp.createTempSync('dg_review_test_');
  addTearDown(() {
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {
      // Windows keeps a handle briefly after close; a stale temp dir is not
      // worth failing a test over.
    }
  });
  return '${dir.path}${Platform.pathSeparator}reviews_${_dbSeq++}.db';
}

ReviewEvent sample(String id, {int seconds = 1700000000, int interval = 10}) =>
    ReviewEvent(
      itemId: id,
      at: DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
      grade: ReviewGrade.good,
      intervalBefore: interval,
      easeBefore: 2.5,
      dueBefore: DateTime.fromMillisecondsSinceEpoch((seconds - 8000) * 1000),
      repsBefore: 3,
      lapsesBefore: 0,
      stepBefore: 2,
    );

List<Object> asStored(String id, int seconds) => <Object>[
      id, seconds, 2, 10, 2.5, seconds - 8000, 3, 0, 2,
    ];

/// A store that accepts writes and then loses them, which is what a full disk
/// looks like from here.
class LosesWrites extends SqliteReviewStore {
  LosesWrites(String path) : super(databasePath: path);
  @override
  Future<List<ReviewEvent>> readAll() async => const <ReviewEvent>[];
}

/// A store that cannot be opened at all.
class RefusesToOpen implements ReviewStore {
  @override
  bool get isPersistent => true;
  @override
  Future<void> open() async => throw StateError('no database here');
  @override
  Future<List<ReviewEvent>> readAll() async => const <ReviewEvent>[];
  @override
  Future<void> append(ReviewEvent event) async {}
  @override
  Future<void> replaceAll(List<ReviewEvent> events) async {}
  @override
  Future<bool> removeLast(String itemId) async => false;
  @override
  Future<int> count() async => 0;
  @override
  Future<void> close() async {}
}

void main() {
  // Plain `test`, never `testWidgets`: sqflite talks to a real isolate, and
  // testWidgets runs the body inside a FakeAsync zone where that isolate never
  // gets scheduled, so every await on the database hangs forever.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('the SQLite store', () {
    late SqliteReviewStore store;

    setUp(() async {
      store = SqliteReviewStore(databasePath: freshDbPath());
      await store.open();
      addTearDown(store.close);
    });

    test('round-trips an event without losing a field', () async {
      final ReviewEvent original = sample('x10743');
      await store.append(original);

      final ReviewEvent back = (await store.readAll()).single;
      expect(back.itemId, original.itemId);
      expect(back.at, original.at);
      expect(back.grade, original.grade);
      expect(back.intervalBefore, original.intervalBefore);
      expect(back.easeBefore, original.easeBefore);
      expect(back.dueBefore, original.dueBefore);
      expect(back.repsBefore, original.repsBefore);
      expect(back.lapsesBefore, original.lapsesBefore);
      expect(back.stepBefore, original.stepBefore);
    });

    test('keeps two reviews of one card in the same second', () async {
      // A learning step puts two reviews seconds apart. Keying the table on
      // (item, timestamp) would silently swallow the second.
      await store.append(sample('001', seconds: 1700000000));
      await store.append(sample('001', seconds: 1700000000));
      expect(await store.count(), 2);
    });

    test('preserves order', () async {
      for (int i = 0; i < 20; i++) {
        await store.append(sample('card-$i', seconds: 1700000000 + i));
      }
      expect((await store.readAll()).map((ReviewEvent e) => e.itemId).toList(),
          <String>[for (int i = 0; i < 20; i++) 'card-$i']);
    });

    test('removeLast takes the newest of that card and nothing else',
        () async {
      await store.append(sample('a', seconds: 1700000000));
      await store.append(sample('b', seconds: 1700000001));
      await store.append(sample('a', seconds: 1700000002));

      expect(await store.removeLast('a'), isTrue);
      final List<ReviewEvent> left = await store.readAll();
      expect(left.map((ReviewEvent e) => e.itemId), <String>['a', 'b']);
      expect(left.first.at.millisecondsSinceEpoch ~/ 1000, 1700000000);
    });

    test('removeLast on an unknown card reports that it did nothing',
        () async {
      expect(await store.removeLast('never-seen'), isFalse);
    });

    test('holds far more than the old blob ceiling', () async {
      // The 5,000 cap existed because the log was re-encoded into the profile
      // on every save. Nothing here needs a cap.
      await store.replaceAll(<ReviewEvent>[
        for (int i = 0; i < 20000; i++)
          sample('card-${i % 500}', seconds: 1700000000 + i),
      ]);
      expect(await store.count(), 20000);
    });

    test('using it before open() says so instead of failing obscurely',
        () async {
      final SqliteReviewStore unopened =
          SqliteReviewStore(databasePath: freshDbPath());
      expect(() => unopened.count(), throwsStateError);
    });
  });

  group('the migration', () {
    Future<AppController> bootWithBlobLog(int events,
        {ReviewStore? store}) async {
      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      await prefs.setString(
          kStateKey,
          jsonEncode(<String, dynamic>{
            'xp': 1234,
            'reviewLog': <List<Object>>[
              for (int i = 0; i < events; i++)
                asStored('card-$i', 1700000000 + i),
            ],
          }));
      final AppController c = AppController();
      addTearDown(c.dispose);
      c.reviewStore = store ?? SqliteReviewStore(databasePath: freshDbPath());
      await c.load();
      return c;
    }

    test('carries an existing blob log into the table',
        () async {
      final AppController c = await bootWithBlobLog(120);

      expect(c.reviewLog, hasLength(120));
      expect(c.reviewLogMigrationDeferred, isFalse);
      expect(await c.reviewStore.count(), 120);
    });

    test('the profile stops carrying the log once it has moved',
        () async {
      final AppController c = await bootWithBlobLog(50);
      await c.flushSave();

      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      final Map<String, dynamic> saved =
          jsonDecode((await prefs.getString(kStateKey))!)
              as Map<String, dynamic>;
      expect(saved.containsKey('reviewLog'), isFalse,
          reason: 'leaving it in would duplicate the whole history into the '
              'blob the move was meant to empty');
      expect(saved['xp'], 1234, reason: 'the rest of the profile is intact');
    });

    test('a write that does not read back leaves the blob alone',
        () async {
      // The failure this ordering exists to survive: the table accepted the
      // rows and does not have them. Dropping the profile copy here would be
      // how a learner loses a year of history.
      final AppController c = await bootWithBlobLog(80, store: LosesWrites(freshDbPath()));

      expect(c.reviewLogMigrationDeferred, isTrue);
      expect(c.reviewLog, hasLength(80),
          reason: 'the in-memory log still holds what the blob had');

      await c.flushSave();
      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      final Map<String, dynamic> saved =
          jsonDecode((await prefs.getString(kStateKey))!)
              as Map<String, dynamic>;
      expect((saved['reviewLog'] as List<dynamic>), hasLength(80),
          reason: 'the profile must keep carrying the history it still owns');
    });

    test('a store that will not open is survivable',
        () async {
      final AppController c = await bootWithBlobLog(40, store: RefusesToOpen());
      expect(c.reviewLogMigrationDeferred, isTrue);
      expect(c.reviewLog, hasLength(40));
    });

    test('a second start reads the table, not the blob',
        () async {
      final SqliteReviewStore shared =
          SqliteReviewStore(databasePath: freshDbPath());
      final AppController first = await bootWithBlobLog(30, store: shared);
      await first.gradeWord(vocabulary.first, ReviewGrade.good);
      await first.flushSave();
      expect(await shared.count(), 31);

      final AppController second = AppController();
      addTearDown(second.dispose);
      second.reviewStore = shared;
      await second.load();

      expect(second.reviewLog, hasLength(31));
      expect(second.reviewLogMigrationDeferred, isFalse);
    });
  });

  group('grading through the store', () {
    late SqliteReviewStore store;

    Future<AppController> boot() async {
      store = SqliteReviewStore(databasePath: freshDbPath());
      final AppController c = AppController();
      addTearDown(c.dispose);
      c.reviewStore = store;
      await c.load();
      return c;
    }

    test('an answer reaches the table without waiting for a save',
        () async {
      final AppController c = await boot();
      await c.gradeWord(vocabulary.first, ReviewGrade.good);
      expect(await store.count(), 1,
          reason: 'an event that never reaches disk is a review the learner '
              'did and the history denies');
    });

    test('an undo removes the row as well as the entry',
        () async {
      final AppController c = await boot();
      await c.gradeWord(vocabulary.first, ReviewGrade.good);
      await c.gradeWord(vocabulary.first, ReviewGrade.again);
      expect(await store.count(), 2);

      await c.undoLastReview(vocabulary.first.id);
      expect(c.reviewLog, hasLength(1));
      expect(await store.count(), 1,
          reason: 'a reverted answer left in the table would be counted by '
              'anything reading the history');
    });

    test('the log is no longer capped where it has its own table', () async {
      final AppController c = await boot();
      await c.restoreFrom(<String, dynamic>{
        'reviewLog': <List<Object>>[
          for (int i = 0; i < AppController.reviewLogLimit + 500; i++)
            asStored('card-$i', 1700000000 + i),
        ],
      });
      expect(c.reviewLog, hasLength(AppController.reviewLogLimit + 500),
          reason: 'the ceiling was a property of the blob, not of the log');
    });
  });
}
