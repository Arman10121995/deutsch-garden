/// Where the review log lives.
///
/// The log outgrew the profile blob almost immediately. Measured, a full
/// 5,000-entry log is 175 KB against a 761-byte profile: the history *is* the
/// profile, and both were being re-encoded and rewritten together on every
/// save. The 5,000 ceiling existed only because of that, not because a
/// scheduler wants to forget anything.
///
/// On every native target the log now lives in its own SQLite table, appended
/// a row at a time. On web it stays in the blob, because SQLite has no web
/// implementation and shipping an experimental one under a learner's only copy
/// of their history is not a trade worth making. The web cap therefore stays;
/// [ReviewStore.isPersistent] says which case you are in.
///
/// The profile core deliberately does **not** move. It is 761 bytes with a
/// quarantine-and-snapshot recovery path built over several releases, and
/// moving that buys nothing measurable now that writes are debounced -- while
/// a bug in the move costs a learner every review they have ever done.
library;

import 'models.dart';

export 'review_store_stub.dart'
    if (dart.library.io) 'review_store_io.dart' show createReviewStore;

abstract class ReviewStore {
  /// Whether this store keeps the log outside the profile blob.
  ///
  /// False on web, where the log is still carried in the profile and still
  /// capped. Callers use it to decide whether to serialise the log into the
  /// profile JSON as well.
  bool get isPersistent;

  /// Opens the store. Safe to call more than once.
  Future<void> open();

  /// Every event, oldest first.
  Future<List<ReviewEvent>> readAll();

  /// Appends one event.
  Future<void> append(ReviewEvent event);

  /// Replaces the whole log. Used by the migration and by a profile restore.
  Future<void> replaceAll(List<ReviewEvent> events);

  /// Removes the most recent event for [itemId], for an undo.
  ///
  /// Returns whether one was removed, so the caller does not have to read the
  /// whole log back to find out.
  Future<bool> removeLast(String itemId);

  /// How many events are stored.
  Future<int> count();

  Future<void> close();
}
