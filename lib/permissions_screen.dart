import 'package:flutter/material.dart';

import 'app_state.dart';
import 'asr_settings.dart';

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
      const SnackBar(
        content: Text(
          'Notification permission was not granted. No reminder was enabled.',
        ),
      ),
    );
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final TimeOfDay? value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: controller.reminderHour,
        minute: controller.reminderMinute,
      ),
      helpText: 'Study reminder',
    );
    if (value == null) return;
    await controller.setReminderTime(value.hour, value.minute);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Permissions & downloads')),
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
                    'Asked only when you use it',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The app does not request location, calls, contacts, '
                    'calendar, camera or broad file access because no learning '
                    'feature needs them. Speaker playback needs no permission.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: <Widget>[
                const ListTile(
                  leading: Icon(Icons.mic_none_rounded),
                  title: Text('Microphone'),
                  subtitle: Text(
                    'The operating system asks only after you start a speaking '
                    'or pronunciation exercise. Clips are processed locally '
                    'and deleted after scoring.',
                  ),
                ),
                const Divider(height: 1),
                if (controller.remindersSupported) ...<Widget>[
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_none_rounded),
                    title: const Text('Daily & weekly goal reminders'),
                    subtitle: const Text(
                      'One private on-device notification per day; Sunday '
                      'includes weekly progress. Off by default.',
                    ),
                    value: controller.remindersEnabled,
                    onChanged: (bool value) => _toggleReminder(context, value),
                  ),
                  ListTile(
                    enabled: controller.remindersEnabled,
                    leading: const Icon(Icons.schedule_rounded),
                    title: const Text('Reminder time'),
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
                  const ListTile(
                    leading: Icon(Icons.notifications_off_outlined),
                    title: Text('Scheduled reminders unavailable'),
                    subtitle: Text(
                      'This platform cannot reliably schedule a local '
                      'notification.',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _GoalCard(controller: controller),
          const SizedBox(height: 12),
          Card(
            child: const ListTile(
              leading: Icon(Icons.cloud_download_outlined),
              title: Text('Internet access'),
              subtitle: Text(
                'Lessons, images and both German voices are bundled. The only '
                'optional network action is the clearly labelled one-time '
                'desktop speech-model download below. After installation it '
                'also works offline.',
              ),
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
          title: const Text('Daily time target'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${controller.studyMinutesToday}/$_dailyGoal '
                'minutes today',
              ),
              Slider(
                value: _dailyGoal.toDouble(),
                min: 5,
                max: 180,
                divisions: 35,
                label: '$_dailyGoal min',
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
          title: const Text('Weekly time target'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${controller.studyMinutesThisWeek}/'
                '$_weeklyGoal minutes this week',
              ),
              Slider(
                value: _weeklyGoal.toDouble(),
                min: 30,
                max: 1200,
                divisions: 39,
                label: '$_weeklyGoal min',
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
