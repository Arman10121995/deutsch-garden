/// The web fallback: no database, so the log stays in the profile blob.
///
/// SQLite has no web implementation. There are experimental builds backed by
/// IndexedDB, and putting a learner's only copy of their review history under
/// one is not a trade worth making for a capability the web build can live
/// without.
///
/// So on web the log continues to be carried in the profile JSON and continues
/// to be capped. [isPersistent] is false, and the controller reads that to
/// decide whether the log still has to be serialised into the profile.
library;

import 'models.dart';
import 'review_store.dart';

ReviewStore createReviewStore() => const InProfileReviewStore();

class InProfileReviewStore implements ReviewStore {
  const InProfileReviewStore();

  @override
  bool get isPersistent => false;

  @override
  Future<void> open() async {}

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
