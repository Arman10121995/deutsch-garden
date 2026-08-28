/// SQLite-backed review log, for every target that is not the web.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'models.dart';
import 'review_store.dart';
import 'review_store_stub.dart';
import 'srs.dart';

/// The store the app uses.
///
/// Under `flutter test` this deliberately returns the in-profile store rather
/// than SQLite. sqflite talks to a real isolate, and `testWidgets` runs its
/// body inside a FakeAsync zone where that isolate is never scheduled -- so
/// any await on the database hangs the test forever rather than failing it.
/// Every widget test in the suite calls `load()`, so defaulting to SQLite
/// would deadlock all of them.
///
/// This is not a way of avoiding the database in tests: `review_store_test`
/// constructs [SqliteReviewStore] directly, against a real file, and exercises
/// the migration and every query. What it avoids is dragging a database into
/// two hundred tests that are about something else.
ReviewStore createReviewStore() {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return const InProfileReviewStore();
  }
  return SqliteReviewStore();
}

class SqliteReviewStore implements ReviewStore {
  SqliteReviewStore({this.databasePath});

  /// Overridden by tests, which run against an in-memory database.
  final String? databasePath;

  Database? _db;
  static bool _ffiReady = false;

  @override
  bool get isPersistent => true;

  /// Android and iOS ship SQLite; the desktops do not, and need the FFI
  /// implementation registered before the first open.
  static void _prepareDesktop() {
    if (_ffiReady) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _ffiReady = true;
  }

  @override
  Future<void> open() async {
    if (_db != null) return;
    _prepareDesktop();
    final String path = databasePath ??
        p.join((await getApplicationSupportDirectory()).path, 'reviews.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // seq, not a composite key: two reviews of the same card in the same
        // second are ordinary during a learning step, and a primary key on
        // (item, timestamp) would silently drop the second one.
        await db.execute('''
          CREATE TABLE review_events (
            seq             INTEGER PRIMARY KEY AUTOINCREMENT,
            item_id         TEXT    NOT NULL,
            at_seconds      INTEGER NOT NULL,
            grade           INTEGER NOT NULL,
            interval_before INTEGER NOT NULL,
            ease_before     REAL    NOT NULL,
            due_before      INTEGER NOT NULL,
            reps_before     INTEGER NOT NULL,
            lapses_before   INTEGER NOT NULL,
            step_before     INTEGER NOT NULL
          )
        ''');
        // The undo reads the newest row for one card, and a scheduler fit
        // reads a card's history in order. Both are this index.
        await db.execute(
            'CREATE INDEX idx_events_item ON review_events(item_id, seq)');
      },
    );
  }

  Database get _open {
    final Database? db = _db;
    if (db == null) {
      throw StateError('ReviewStore.open() was not awaited');
    }
    return db;
  }

  static Map<String, Object?> _row(ReviewEvent e) => <String, Object?>{
        'item_id': e.itemId,
        'at_seconds': e.at.millisecondsSinceEpoch ~/ 1000,
        'grade': e.grade.index,
        'interval_before': e.intervalBefore,
        'ease_before': e.easeBefore,
        'due_before': e.dueBefore.millisecondsSinceEpoch ~/ 1000,
        'reps_before': e.repsBefore,
        'lapses_before': e.lapsesBefore,
        'step_before': e.stepBefore,
      };

  static ReviewEvent? _event(Map<String, Object?> row) {
    final int gradeIndex = (row['grade'] as int?) ?? -1;
    if (gradeIndex < 0 || gradeIndex >= ReviewGrade.values.length) return null;
    return ReviewEvent(
      itemId: (row['item_id'] as String?) ?? '',
      at: DateTime.fromMillisecondsSinceEpoch(
          ((row['at_seconds'] as int?) ?? 0) * 1000),
      grade: ReviewGrade.values[gradeIndex],
      intervalBefore: (row['interval_before'] as int?) ?? 0,
      easeBefore: ((row['ease_before'] as num?) ?? 2.5).toDouble(),
      dueBefore: DateTime.fromMillisecondsSinceEpoch(
          ((row['due_before'] as int?) ?? 0) * 1000),
      repsBefore: (row['reps_before'] as int?) ?? 0,
      lapsesBefore: (row['lapses_before'] as int?) ?? 0,
      stepBefore: (row['step_before'] as int?) ?? 0,
    );
  }

  @override
  Future<List<ReviewEvent>> readAll() async {
    final List<Map<String, Object?>> rows =
        await _open.query('review_events', orderBy: 'seq ASC');
    final List<ReviewEvent> out = <ReviewEvent>[];
    for (final Map<String, Object?> row in rows) {
      final ReviewEvent? event = _event(row);
      // One unreadable row costs that row, exactly as in the blob format.
      if (event != null && event.itemId.isNotEmpty) out.add(event);
    }
    return out;
  }

  @override
  Future<void> append(ReviewEvent event) async {
    await _open.insert('review_events', _row(event));
  }

  @override
  Future<void> replaceAll(List<ReviewEvent> events) async {
    await _open.transaction((Transaction txn) async {
      await txn.delete('review_events');
      final Batch batch = txn.batch();
      for (final ReviewEvent e in events) {
        batch.insert('review_events', _row(e));
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<bool> removeLast(String itemId) async {
    final List<Map<String, Object?>> rows = await _open.query(
      'review_events',
      columns: <String>['seq'],
      where: 'item_id = ?',
      whereArgs: <Object>[itemId],
      orderBy: 'seq DESC',
      limit: 1,
    );
    if (rows.isEmpty) return false;
    final int removed = await _open.delete('review_events',
        where: 'seq = ?', whereArgs: <Object>[rows.first['seq'] as int]);
    return removed > 0;
  }

  @override
  Future<int> count() async {
    final List<Map<String, Object?>> rows =
        await _open.rawQuery('SELECT COUNT(*) AS n FROM review_events');
    return (rows.first['n'] as int?) ?? 0;
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
