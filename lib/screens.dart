import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'achievements.dart';
import 'backup.dart';
import 'app_state.dart';
import 'glosses.dart';
import 'identity_screen.dart';
import 'l10n/app_localizations.dart';
import 'onboarding_screen.dart';
import 'build_info.dart';
import 'explore_screen.dart';
import 'learning_path_screen.dart';
import 'models.dart';
import 'platform_support.dart';
import 'vocabulary.dart';

enum _ImportMode { merge, replace }

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// Below this width the bottom bar wins; above it a side rail does, which is
  /// what a desktop window actually wants. The breakpoint is deliberately on
  /// window width rather than on platform: a Windows build in a narrow window
  /// should behave like a phone, and a tablet in landscape should not.
  static const double _railBreakpoint = 900;

  // Three destinations with three distinct jobs. Learn decides what comes
  // next; Explore holds every optional library, lab and test; Profile holds
  // progress and settings. Home/Course/Speak/Practice used to compete as five
  // different starting points even though most of their content was already
  // attached to the same course.
  // Labels are resolved at build time rather than held in this list,
  // because a const list cannot change when the locale does.
  static const List<_Destination> _destinations = <_Destination>[
    _Destination(Icons.route_outlined, Icons.route),
    _Destination(Icons.explore_outlined, Icons.explore),
    _Destination(Icons.person_outline, Icons.person),
  ];

  List<String> _destinationLabels(BuildContext context) {
    final AppText text = AppText.of(context);
    return <String>[text.tabLearn, text.tabExplore, text.tabProfile];
  }

  @override
  Widget build(BuildContext context) {
    // Shown before anything else on a first run. It is part of the shell
    // rather than a pushed route so there is no back gesture out of it into
    // an app the learner has had nothing explained about.
    if (!widget.controller.onboardingDone) {
      return OnboardingScreen(controller: widget.controller);
    }

    final pages = <Widget>[
      LearningPathScreen(controller: widget.controller),
      ExploreScreen(controller: widget.controller),
      ProfileScreen(controller: widget.controller),
    ];
    final Widget body = IndexedStack(index: _index, children: pages);

    // A profile that failed to load must never look like a fresh install.
    // This is the one message in the app that overrides whatever the learner
    // was doing, because acting on it later is worse than acting on it now.
    final Widget shell = widget.controller.recoveryNotice.isEmpty
        ? body
        : Column(
            children: <Widget>[
              MaterialBanner(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                leading: Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                content: Text(
                  widget.controller.recoveryNotice,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: widget.controller.dismissRecoveryNotice,
                    child: Text(AppText.of(context).actionUnderstood),
                  ),
                ],
              ),
              Expanded(child: body),
            ],
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _railBreakpoint) {
          return Scaffold(
            body: Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (value) =>
                      setState(() => _index = value),
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('🌱', style: TextStyle(fontSize: 26)),
                  ),
                  destinations: <NavigationRailDestination>[
                    for (int i = 0; i < _destinations.length; i++)
                      NavigationRailDestination(
                        icon: Icon(_destinations[i].icon),
                        selectedIcon: Icon(_destinations[i].selectedIcon),
                        label: Text(_destinationLabels(context)[i]),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                // A very wide desktop window would otherwise stretch every
                // card to an unreadable line length.
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: shell,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          body: shell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: <NavigationDestination>[
              for (int i = 0; i < _destinations.length; i++)
                NavigationDestination(
                  icon: Icon(_destinations[i].icon),
                  selectedIcon: Icon(_destinations[i].selectedIcon),
                  label: _destinationLabels(context)[i],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Destination {
  const _Destination(this.icon, this.selectedIcon);

  final IconData icon;
  final IconData selectedIcon;
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              'Progress',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.55,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: <Widget>[
                _statCard(context, '🔥', '${controller.streak}', 'day streak'),
                _statCard(context, '⚡', '${controller.xp}', 'total XP'),
                _statCard(
                  context,
                  '🌿',
                  '${controller.learnedCount}',
                  'words learned',
                ),
                _statCard(
                  context,
                  '🌳',
                  '${controller.masteredCount}',
                  'words mastered',
                ),
                _retentionCard(context, controller),
                _statCard(
                  context,
                  '🏅',
                  controller.highestUnlockedLevel.label,
                  'highest unlocked',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'CEFR skill matrix',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ...CefrLevel.values.map(
              (level) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              level.label,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(controller.levelProgress(level) * 100).round()}%',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...SkillType.values.map(
                          (skill) => Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 28, child: Text(skill.emoji)),
                                SizedBox(width: 86, child: Text(skill.label)),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: controller.skillProgress(
                                      level,
                                      skill,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '${(controller.skillProgress(level, skill) * 100).round()}%',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Recall on scheduled reviews over the last month.
  ///
  /// The card used to show all-time accuracy, which mixes a card's first
  /// exposure with a year-long interval and can only ever creep upward. This
  /// figure covers a window and counts only graduated cards, so it can fall --
  /// which is what makes it worth looking at. Until there are enough reviews
  /// to divide, it says so rather than printing a percentage derived from
  /// three answers.
  Widget _retentionCard(BuildContext context, AppController controller) {
    final double? retention = controller.trueRetention();
    if (retention == null) {
      return _statCard(context, '🎯', '—', 'retention, 30 days');
    }
    return _statCard(
      context,
      '🎯',
      '${(retention * 100).round()}%',
      'retention, 30 days',
    );
  }

  Widget _statCard(
    BuildContext context,
    String emoji,
    String value,
    String label,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 25)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});
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
      helpText: 'Daily study reminder',
    );
    if (value == null) return;
    await controller.setReminderTime(value.hour, value.minute);
  }

  /// Chooses the language card meanings are shown in.
  ///
  /// Separate from the interface language on purpose: a Turkish speaker living
  /// in Germany may well want the app in German and the glosses in Turkish,
  /// and neither choice should drag the other with it.
  Widget _glossTile(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.menu_book_rounded),
        title: const Text('Card meanings'),
        subtitle: Text(controller.glossLanguage.isEmpty
            ? 'English, from the card itself'
            : 'Falls back to English where a word is not covered'),
        trailing: DropdownButton<String>(
          value: controller.glossLanguage,
          onChanged: (String? value) =>
              controller.setGlossLanguage(value ?? ''),
          items: <DropdownMenuItem<String>>[
            const DropdownMenuItem<String>(value: '', child: Text('English')),
            for (final GlossLanguage language in GlossLanguage.available)
              DropdownMenuItem<String>(
                value: language.code,
                child: Text(language.nativeName),
              ),
          ],
        ),
      ),
    );
  }

  /// Chooses the language of the app's own text.
  ///
  /// Explicitly not the language being taught: the cards, stories and grammar
  /// stay German whatever this is set to. A learner switching the interface to
  /// German has not asked for their English glosses to disappear.
  Widget _languageTile(BuildContext context) {
    final AppText text = AppText.of(context);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.translate_rounded),
        title: Text(text.settingsLanguage),
        trailing: DropdownButton<String>(
          value: controller.uiLocale?.languageCode ?? '',
          onChanged: (String? value) => controller.setUiLocale(
              value == null || value.isEmpty ? null : Locale(value)),
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(
              value: '',
              child: Text(text.settingsLanguageSystem),
            ),
            const DropdownMenuItem<String>(
              value: 'en',
              child: Text('English'),
            ),
            const DropdownMenuItem<String>(
              value: 'de',
              child: Text('Deutsch'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              AppText.of(context).settingsTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            _languageTile(context),
            const SizedBox(height: 12),
            _glossTile(context),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    secondary: const Icon(Icons.fitness_center_rounded),
                    title: const Text('End each session with a drill'),
                    subtitle: const Text(
                      'Learn closes with one practice lab, chosen for you and '
                      'rotated daily.',
                    ),
                    value: controller.guidedIncludesDrills,
                    onChanged: controller.setGuidedIncludesDrills,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.science_rounded),
                    title: const Text('List the labs in Explore too'),
                    subtitle: const Text(
                      'Turn this off once Learn is the only path you want to '
                      'follow. Nothing is removed; the drills still come to '
                      'you.',
                    ),
                    value: controller.showExploreLabs,
                    onChanged: controller.setShowExploreLabs,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: const Text('German pronunciation'),
                    subtitle: const Text(
                      'Use the device text-to-speech engine for vocabulary and listening',
                    ),
                    value: controller.ttsEnabled,
                    onChanged: controller.setTtsEnabled,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Immersion mode'),
                    subtitle: const Text(
                      'Hide English by default in stories, role-plays and '
                      'speaking prompts. You can still reveal it per screen.',
                    ),
                    value: controller.immersionMode,
                    onChanged: controller.setImmersionMode,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Daily learning goal'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${controller.dailyGoal} actions per day'),
                        Slider(
                          value: controller.dailyGoal.toDouble(),
                          min: 5,
                          max: 100,
                          divisions: 19,
                          label: '${controller.dailyGoal}',
                          onChanged: (value) =>
                              controller.setDailyGoal(value.round()),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  if (controller.remindersSupported) ...<Widget>[
                    SwitchListTile(
                      title: const Text('Daily study reminder'),
                      subtitle: const Text(
                        'One private on-device notification. Off by default; '
                        'no account, server or tracking.',
                      ),
                      value: controller.remindersEnabled,
                      onChanged: (bool value) =>
                          _toggleReminder(context, value),
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
                        'This platform cannot schedule a reliable local '
                        'notification. DeutschGarden will not pretend it can.',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                title: const Text('Appearance'),
                subtitle: const Text('Choose how DeutschGarden looks'),
                trailing: DropdownButton<ThemeMode>(
                  value: controller.themeMode,
                  items: const <DropdownMenuItem<ThemeMode>>[
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setThemeMode(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Gender colors',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _GenderLegend(label: 'DER', color: Color(0xFF1565C0)),
                        _GenderLegend(label: 'DIE', color: Color(0xFFC62828)),
                        _GenderLegend(label: 'DAS', color: Color(0xFF2E7D32)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'This build',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('DeutschGarden $appVersion'),
                    const SizedBox(height: 6),
                    Text('Platform: ${PlatformSupport.displayName}'),
                    const SizedBox(height: 6),
                    Text('🔊 ${PlatformSupport.ttsNote}'),
                    const SizedBox(height: 6),
                    Text('🎤 ${PlatformSupport.speechRecognitionNote}'),
                    const SizedBox(height: 10),
                    Text(
                      'All lessons, words, stories, role-plays and exams are '
                      'compiled into the app. Nothing is downloaded and the app '
                      'never contacts a server.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _showContentLicenses(context),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Open content sources & licenses'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.ios_share_outlined),
                    title: const Text('Export progress'),
                    subtitle: const Text(
                      'Copy your whole profile as text, to carry it to another device',
                    ),
                    onTap: () => _showExport(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: const Text('Import progress'),
                    subtitle: const Text(
                      'Paste a profile exported from another device — replaces what is here',
                    ),
                    onTap: () => _showImport(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete_forever_outlined),
                title: const Text('Reset all learning progress'),
                subtitle: const Text(
                  'Deletes XP, streak, lesson scores, drafts and word mastery on this device',
                ),
                onTap: () => _confirmReset(context),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'DeutschGarden $appVersion • ${vocabulary.length} bundled A1–C2 words • '
              'vocabulary, grammar, listening, reading, writing, speaking, '
              'AI role-plays, stories and exam prep • offline-first',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showContentLicenses(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Content sources & licenses'),
        content: const SingleChildScrollView(
          child: SelectableText(
            'DeutschGarden software and original course material are released '
            'under the MIT License.\n\n'
            'Generated lexical metadata and English glosses are adapted from '
            'wordhoard v0.1.0 and German Wiktionary data distributed through '
            'Lector. Those adaptations are provided under CC BY-SA 4.0.\n\n'
            'Sourced German–English example pairs come from Tatoeba and are '
            'provided under CC BY 2.0 France. Individual sentence contributor '
            'attributions are included in the source distribution.\n\n'
            'Sources: github.com/natema/wordhoard, lector.dev, '
            'de.wiktionary.org and tatoeba.org.',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showExport(BuildContext context) async {
    final String payload = ProgressBackup.export(controller);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export progress'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'This text is your entire profile. Copy it, move it to the '
                'other device by any means you like, and paste it into '
                'Import progress there.',
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      payload,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () async {
              final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                context,
              );
              final NavigatorState navigator = Navigator.of(context);
              await Clipboard.setData(ClipboardData(text: payload));
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Profile copied to the clipboard'),
                ),
              );
            },
            icon: const Icon(Icons.copy_all_outlined),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImport(BuildContext context) async {
    final TextEditingController input = TextEditingController();
    String? error;
    final Map<String, dynamic>? state = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Import progress'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Paste a profile exported from another device.'),
                const SizedBox(height: 12),
                TextField(
                  controller: input,
                  minLines: 5,
                  maxLines: 10,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  decoration: InputDecoration(
                    hintText: '{ "format": "deutschgarden.backup", … }',
                    errorText: error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () async {
                    final ClipboardData? data = await Clipboard.getData(
                      Clipboard.kTextPlain,
                    );
                    if (data?.text != null) input.text = data!.text!;
                  },
                  icon: const Icon(Icons.paste_outlined),
                  label: const Text('Paste from clipboard'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final BackupImportResult result = ProgressBackup.parse(
                  input.text,
                );
                if (!result.isSuccess) {
                  setLocalState(() => error = result.error);
                  return;
                }
                Navigator.pop(context, result.state);
              },
              child: const Text('Check'),
            ),
          ],
        ),
      ),
    );
    input.dispose();
    if (state == null) return;
    if (!context.mounted) return;

    final _ImportMode? mode = await showDialog<_ImportMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Merge imported progress?'),
        content: Text(
          'The backup contains:\n\n${ProgressBackup.describe(state)}\n\n'
          'Merge keeps learning from both devices. It combines words, lessons, '
          'mistakes and review history item by item, while keeping this '
          'device’s theme, audio and reminder settings. If the same item was '
          'reviewed on both devices, the newer review supplies its schedule.\n\n'
          'Replace is available for deliberate full recovery, but removes '
          'progress that exists only on this device.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _ImportMode.replace),
            child: const Text('Replace'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, _ImportMode.merge),
            icon: const Icon(Icons.merge_rounded),
            label: const Text('Merge safely'),
          ),
        ],
      ),
    );
    if (mode == null) return;
    final Map<String, dynamic> restored = mode == _ImportMode.merge
        ? ProgressBackup.merge(controller.toBackupJson(), state)
        : state;
    await controller.restoreFrom(restored);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mode == _ImportMode.merge
              ? 'Progress from both devices was merged.'
              : 'The imported profile replaced local progress.',
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text(
          'This removes all local learning history and saved writing drafts. This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.resetAllProgress();
  }
}

class _GenderLegend extends StatelessWidget {
  const _GenderLegend({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// Profile tab: personal progress, achievements and local settings only.
/// Learning content, including vocabulary search, belongs to Explore.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});

  final AppController controller;

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final int unlocked = controller.unlockedAchievements.length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            children: <Widget>[
              Text(
                'Profil',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: ProfileAvatar(controller: controller, size: 48),
                  title: Text(controller.learnerName.isEmpty
                      ? 'Add your name'
                      : controller.learnerName),
                  subtitle: Text(controller.learnerEmail.isEmpty
                      ? 'Name, picture and an optional email — kept on this '
                          'device'
                      : controller.learnerEmail),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          IdentityScreen(controller: controller),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 30,
                        child: Text(
                          controller.highestUnlockedLevel.label,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '🔥 ${controller.streak}-day streak',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '⚡ ${controller.xp} XP • '
                              '🌿 ${controller.learnedCount} learned • '
                              '🌳 ${controller.masteredCount} mastered',
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '🗣️ ${controller.conversationsDone} role-plays • '
                              '📖 ${controller.storyChaptersDone} chapters',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: ListTile(
                  leading: const Text('🏅', style: TextStyle(fontSize: 26)),
                  title: const Text(
                    'Achievements',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    '$unlocked of ${achievements.length} unlocked',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _push(
                    context,
                    AchievementsScreen(controller: controller),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Text('📊', style: TextStyle(fontSize: 26)),
                  title: const Text(
                    'Detailed progress',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text(
                    'CEFR skill matrix across all six levels',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _push(
                    context,
                    Scaffold(
                      appBar: AppBar(title: const Text('Progress')),
                      body: StatsScreen(controller: controller),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Text('⚙️', style: TextStyle(fontSize: 26)),
                  title: const Text(
                    'Settings',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: const Text(
                    'Speech, immersion mode, daily goal, theme and reset',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _push(
                    context,
                    Scaffold(
                      appBar: AppBar(title: const Text('Settings')),
                      body: SettingsScreen(controller: controller),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    // Opening this screen is what "sees" a new achievement, so the celebration
    // badge does not follow the learner around forever.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.controller.acknowledgeAchievements(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
          itemCount: achievements.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final Achievement achievement = achievements[index];
            final bool unlocked = widget.controller.isAchievementUnlocked(
              achievement,
            );
            final double progress = widget.controller.achievementProgress(
              achievement,
            );
            final int value = widget.controller.metricValue(achievement.metric);
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Opacity(
                      opacity: unlocked ? 1 : 0.35,
                      child: Text(
                        achievement.emoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            achievement.title,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            achievement.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: progress),
                          const SizedBox(height: 4),
                          Text(
                            '$value / ${achievement.target} '
                            '${achievement.metric.label}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    if (unlocked) const Icon(Icons.verified_rounded, size: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
