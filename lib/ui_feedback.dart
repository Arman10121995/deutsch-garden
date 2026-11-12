import 'package:flutter/foundation.dart';

enum UiFeedbackEvent {
  click(1, 30),
  success(3, 210),
  failure(3, 220),
  achievement(2, 300),
  complete(4, 540);

  const UiFeedbackEvent(this.priority, this.milliseconds);
  final int priority;
  final int milliseconds;
}

/// Both recording backends hold this gate, including microphone startup.
/// Feedback must not become part of a learner's recorded attempt.
class UiFeedbackCaptureGate {
  static final active = ValueNotifier<bool>(false);
  static final _owners = <Object>{};
  static final _stoppers = <Future<void> Function()>{};

  static void addStopper(Future<void> Function() stop) => _stoppers.add(stop);
  static void removeStopper(Future<void> Function() stop) =>
      _stoppers.remove(stop);

  static Future<void> begin(Object owner) async {
    _owners.add(owner);
    active.value = _owners.isNotEmpty;
    // Drain effects before opening a microphone. A broken cosmetic player
    // must not prevent recording; even the longest tone is only 540 ms.
    try {
      await Future.wait(
        _stoppers.toList().map((stop) => stop()),
      ).timeout(const Duration(milliseconds: 750));
    } catch (_) {
      /* recording still works without effect playback */
    }
  }

  static void end(Object owner) {
    _owners.remove(owner);
    active.value = _owners.isNotEmpty;
  }
}
