import 'package:flutter/material.dart';

import 'app_state.dart';
import 'asr_settings.dart';
import 'l10n/app_localizations.dart';

/// One honest place for every capability that can cross the app sandbox.
///
/// DeutschGarden never asks for a permission speculatively. Notification
/// access follows the reminder switch, microphone access follows a learner's
/// tap on a speaking tool, and network access is limited to the explicit
/// optional desktop speech-model download.
class PermissionsAndDownloadsScreen extends StatelessWidget {
  const PermissionsAndDownloadsScreen({super.key, required this.controller});

  final AppController controller;

  Future<void> _toggleReminder(BuildContext context, bool value) async {
    final bool changed = await controller.setRemindersEnabled(value);
    if (!context.mounted || changed) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppText.of(context).notificationPermissionDenied)),
    );
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final TimeOfDay? value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: controller.reminderHour,
        minute: controller.reminderMinute,
      ),
      helpText: AppText.of(context).studyReminder,
    );
    if (value == null) return;
    await controller.setReminderTime(value.hour, value.minute);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppText.of(context).permissionsDownloads)),
    body: AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? _) => ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppText.of(context).permissionsOnUse,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(AppText.of(context).permissionsExplanation),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.mic_none_rounded),
                  title: Text(AppText.of(context).microphoneTitle),
                  subtitle: Text(AppText.of(context).microphoneExplanation),
                ),
                const Divider(height: 1),
                if (controller.remindersSupported) ...<Widget>[
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_none_rounded),
                    title: Text(AppText.of(context).goalReminders),
                    subtitle: Text(
                      AppText.of(context).goalRemindersExplanation,
                    ),
                    value: controller.remindersEnabled,
                    onChanged: (bool value) => _toggleReminder(context, value),
                  ),
                  ListTile(
                    enabled: controller.remindersEnabled,
                    leading: const Icon(Icons.schedule_rounded),
                    title: Text(AppText.of(context).reminderTime),
                    subtitle: Text(
                      MaterialLocalizations.of(context).formatTimeOfDay(
                        TimeOfDay(
                          hour: controller.reminderHour,
                          minute: controller.reminderMinute,
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: controller.remindersEnabled
                        ? () => _pickReminderTime(context)
                        : null,
                  ),
                ] else
                  ListTile(
                    leading: const Icon(Icons.notifications_off_outlined),
                    title: Text(
                      AppText.of(context).scheduledRemindersUnavailable,
                    ),
                    subtitle: Text(AppText.of(context).reminderUnsupported),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _GoalCard(controller: controller),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_download_outlined),
              title: Text(AppText.of(context).internetAccessTitle),
              subtitle: Text(AppText.of(context).internetAccessExplanation),
            ),
          ),
          const SizedBox(height: 12),
          AsrModelCard(controller: controller),
        ],
      ),
    ),
  );
}

class _GoalCard extends StatefulWidget {
  const _GoalCard({required this.controller});

  final AppController controller;

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  late int _dailyGoal;
  late int _weeklyGoal;

  AppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _dailyGoal = controller.dailyMinuteGoal;
    _weeklyGoal = controller.weeklyMinuteGoal;
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.today_rounded),
          title: Text(AppText.of(context).dailyTimeTarget),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppText.of(
                  context,
                ).timeProgressToday(controller.studyMinutesToday, _dailyGoal),
              ),
              Slider(
                value: _dailyGoal.toDouble(),
                min: 5,
                max: 180,
                divisions: 35,
                label: AppText.of(context).minutesShort(_dailyGoal),
                onChanged: (double value) =>
                    setState(() => _dailyGoal = value.round()),
                onChangeEnd: (double value) =>
                    controller.setDailyMinuteGoal(value.round()),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.date_range_rounded),
          title: Text(AppText.of(context).weeklyTimeTarget),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppText.of(context).timeProgressThisWeek(
                  controller.studyMinutesThisWeek,
                  _weeklyGoal,
                ),
              ),
              Slider(
                value: _weeklyGoal.toDouble(),
                min: 30,
                max: 1200,
                divisions: 39,
                label: AppText.of(context).minutesShort(_weeklyGoal),
                onChanged: (double value) =>
                    setState(() => _weeklyGoal = value.round()),
                onChangeEnd: (double value) =>
                    controller.setWeeklyMinuteGoal(value.round()),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
