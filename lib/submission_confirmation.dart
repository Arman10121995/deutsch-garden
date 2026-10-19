import 'package:flutter/material.dart';

/// Owns the submit dialog so a deadline can remove that dialog before replacing
/// the test route. Repeated taps cannot open two dialogs or pop the test page.
mixin SubmissionConfirmation<T extends StatefulWidget> on State<T> {
  DialogRoute<bool>? _confirmation;

  bool get confirmationOpen => _confirmation != null;

  Future<bool> confirmSubmission(
    Widget Function(BuildContext context, ValueChanged<bool> close) builder,
  ) async {
    if (confirmationOpen || !mounted) return false;
    bool resolved = false;
    late final DialogRoute<bool> route;
    void close(bool value) {
      if (resolved || !route.isCurrent) return;
      resolved = true;
      route.navigator!.pop(value);
    }

    route = DialogRoute<bool>(
      context: context,
      builder: (context) => builder(context, close),
    );
    _confirmation = route;
    try {
      return await Navigator.of(context).push(route) ?? false;
    } finally {
      if (identical(_confirmation, route)) _confirmation = null;
    }
  }

  void dismissSubmissionConfirmation() {
    final route = _confirmation;
    _confirmation = null;
    if (route != null && route.isActive) {
      route.navigator!.removeRoute(route, false);
    }
  }
}
