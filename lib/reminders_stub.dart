/// Web has no local notification the app can schedule for tomorrow evening.
///
/// The Notification API needs a service worker and a push subscription, which
/// means a server -- and this app does not have one and is not going to get
/// one. The setting is simply not offered on web.
library;

import 'reminders.dart';

Reminders createReminders() => const NoReminders();

class NoReminders implements Reminders {
  const NoReminders();

  @override
  bool get isSupported => false;

  @override
  Future<void> initialise() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> schedule(ReminderPlan plan) async {}

  @override
  Future<void> cancel() async {}
}
