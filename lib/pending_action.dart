import 'package:flutter/widgets.dart';

/// Keeps an asynchronous answer/save and its navigation atomic from the UI's
/// perspective. A failed action releases the controls so it can be retried.
mixin PendingAction<T extends StatefulWidget> on State<T> {
  bool actionPending = false;

  Future<void> runAction(Future<void> Function() action) async {
    if (actionPending || !mounted) return;
    setState(() => actionPending = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => actionPending = false);
    }
  }
}
