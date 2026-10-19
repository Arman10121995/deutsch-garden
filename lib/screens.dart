import 'package:flutter/material.dart';

import 'achievements.dart';
import 'app_state.dart';
import 'profile_text.dart';
import 'learning_path_text.dart';
import 'study_time.dart';
import 'backup.dart';
import 'backup_dialogs.dart';
import 'pending_action.dart';
import 'glosses.dart';
import 'identity_screen.dart';
import 'l10n/app_localizations.dart';
import 'onboarding_screen.dart';
import 'build_info.dart';
import 'explore_screen.dart';
import 'learning_path_screen.dart';
import 'models.dart';
import 'platform_support.dart';
import 'permissions_screen.dart';
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
              AppText.of(context).profileProgress,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            _statGrid(context, <Widget>[
              _statCard(
                context,
                '🔥',
                '${controller.streak}',
                AppText.of(context).profileStreakDays,
              ),
              _statCard(
                context,
                '⚡',
                '${controller.xp}',
                AppText.of(context).profileTotalXp,
              ),
              _statCard(
                context,
                '🌿',
                '${controller.learnedCount}',
                AppText.of(context).profileWordsLearned,
              ),
              _statCard(
                context,
                '🌳',
                '${controller.masteredCount}',
                AppText.of(context).profileWordsMastered,
              ),
              _retentionCard(context, controller),
              _statCard(
                context,
                '🏅',
                controller.highestUnlockedLevel.label,
                AppText.of(context).profileHighestLevel,
              ),
            ]),
            const SizedBox(height: 24),
            Text(
              AppText.of(context).profileStudyTime,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              AppText.of(context).profileStudyTimeNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _statCard(
                    context,
                    '⏱️',
                    '${controller.studyMinutesToday}',
                    AppText.of(context).profileMinutesToday,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    context,
                    '📅',
                    '${controller.studyMinutesThisWeek}',
                    AppText.of(context).profileMinutesWeek,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppText.of(context).profileLastWeek,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    for (final DateTime day in _lastSevenDays(controller))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 76,
                              child: Text(
                                MaterialLocalizations.of(
                                  context,
                                ).formatShortDate(day),
                              ),
                            ),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: (_minutesOn(controller, day) / 60).clamp(
                                  0.0,
                                  1.0,
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 52,
                              child: Text(
                                AppText.of(
                                  context,
                                ).profileMinutes(_minutesOn(controller, day)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (controller.studyIntervals.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppText.of(context).profileRecentSessions,
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      for (final StudyInterval interval
                          in controller.studyIntervals.reversed.take(20))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: const Icon(Icons.schedule_rounded),
                          title: Text(interval.activity),
                          subtitle: Text(
                            '${MaterialLocalizations.of(context).formatCompactDate(interval.startedAt)} • '
                            '${_clock(context, interval.startedAt)}–${_clock(context, interval.endedAt)}',
                          ),
                          trailing: Text(
                            AppText.of(context).profileMinutes(
                              roundedStudyMinutes(interval.duration),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              AppText.of(context).profileSkillMatrix,
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
                          (skill) => _skillRow(context, level, skill),
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
      return _statCard(
        context,
        '🎯',
        '—',
        AppText.of(context).profileRetention,
      );
    }
    return _statCard(
      context,
      '🎯',
      '${(retention * 100).round()}%',
      AppText.of(context).profileRetention,
    );
  }

  List<DateTime> _lastSevenDays(AppController controller) {
    final DateTime now = controller.currentTime;
    final DateTime today = DateTime(now.year, now.month, now.day);
    return <DateTime>[
      for (int offset = 6; offset >= 0; offset--)
        today.subtract(Duration(days: offset)),
    ];
  }

  int _minutesOn(AppController controller, DateTime day) =>
      roundedStudyMinutes(controller.studyDurationForDay(day));

  String _clock(BuildContext context, DateTime value) =>
      MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(value),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      );

  Widget _statGrid(BuildContext context, List<Widget> cards) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final columns = constraints.maxWidth >= 720
          ? 3
          : constraints.maxWidth >= 480 || scale <= 1.15
          ? 2
          : 1;
      final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final card in cards) SizedBox(width: width, child: card),
        ],
      );
    },
  );

  Widget _skillRow(BuildContext context, CefrLevel level, SkillType skill) {
    final value = controller.skillProgress(level, skill);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${skill.emoji} ${skillText(AppText.of(context), skill)}',
                ),
              ),
              const SizedBox(width: 8),
              Text('${(value * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(value: value),
        ],
      ),
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with PendingAction<SettingsScreen> {
  AppController get controller => widget.controller;

  /// Chooses the language card meanings are shown in.
  ///
  /// Separate from the interface language on purpose: a Turkish speaker living
  /// in Germany may well want the app in German and the glosses in Turkish,
  /// and neither choice should drag the other with it.
  Widget _preferenceCard({
    required IconData icon,
    required String title,
    String? body,
    required Widget control,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
            ],
          ),
          if (body != null) ...[const SizedBox(height: 8), Text(body)],
          const SizedBox(height: 8),
          control,
        ],
      ),
    ),
  );

  Widget _glossTile(BuildContext context) {
    final t = AppText.of(context);
    return _preferenceCard(
      icon: Icons.menu_book_rounded,
      title: t.settingsMeanings,
      body: controller.glossLanguage.isEmpty
          ? t.settingsMeaningsEnglish
          : t.settingsMeaningsFallback,
      control: DropdownButton<String>(
        isExpanded: true,
        value: controller.glossLanguage,
        onChanged: (value) => controller.setGlossLanguage(value ?? ''),
        items: [
          DropdownMenuItem(value: '', child: Text(t.settingsEnglishName)),
          for (final language in GlossLanguage.available)
            DropdownMenuItem(
              value: language.code,
              child: Text(language.nativeName),
            ),
        ],
      ),
    );
  }

  // Interface and meaning languages remain independent preferences.
  Widget _languageTile(BuildContext context) {
    final t = AppText.of(context);
    return _preferenceCard(
      icon: Icons.translate_rounded,
      title: t.settingsLanguage,
      control: DropdownButton<String>(
        isExpanded: true,
        value: controller.uiLocale?.languageCode ?? '',
        onChanged: (value) => controller.setUiLocale(
          value == null || value.isEmpty ? null : Locale(value),
        ),
        items: [
          DropdownMenuItem(value: '', child: Text(t.settingsLanguageSystem)),
          DropdownMenuItem(value: 'en', child: Text(t.settingsEnglishName)),
          DropdownMenuItem(value: 'de', child: Text(t.settingsGermanName)),
        ],
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
                    title: Text(AppText.of(context).settingsEndWithDrill),
                    subtitle: Text(
                      AppText.of(context).settingsEndWithDrillNote,
                    ),
                    value: controller.guidedIncludesDrills,
                    onChanged: controller.setGuidedIncludesDrills,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.science_rounded),
                    title: Text(AppText.of(context).settingsShowLabs),
                    subtitle: Text(AppText.of(context).settingsShowLabsNote),
                    value: controller.showExploreLabs,
                    onChanged: controller.setShowExploreLabs,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: Text(AppText.of(context).settingsPermissions),
                subtitle: Text(
                  controller.remindersEnabled
                      ? AppText.of(context).settingsRemindersOn
                      : AppText.of(context).settingsPermissionsNote,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        PermissionsAndDownloadsScreen(controller: controller),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: Text(AppText.of(context).settingsPronunciation),
                    subtitle: Text(
                      AppText.of(context).settingsPronunciationNote,
                    ),
                    value: controller.ttsEnabled,
                    onChanged: controller.setTtsEnabled,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(AppText.of(context).settingsImmersion),
                    subtitle: Text(AppText.of(context).settingsImmersionNote),
                    value: controller.immersionMode,
                    onChanged: controller.setImmersionMode,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(AppText.of(context).settingsDailyLearningGoal),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppText.of(
                            context,
                          ).settingsActionsDaily(controller.dailyGoal),
                        ),
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
                ],
              ),
            ),
            const SizedBox(height: 14),
            _preferenceCard(
              icon: Icons.palette_outlined,
              title: AppText.of(context).settingsAppearance,
              body: AppText.of(context).settingsAppearanceNote,
              control: DropdownButton<ThemeMode>(
                isExpanded: true,
                value: controller.themeMode,
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(AppText.of(context).settingsDark),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(AppText.of(context).settingsLight),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(AppText.of(context).settingsLanguageSystem),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) controller.setThemeMode(value);
                },
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppText.of(context).settingsGenderColors,
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
                      AppText.of(context).settingsThisBuild,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(AppText.of(context).settingsVersion(appVersion)),
                    const SizedBox(height: 6),
                    Text(
                      AppText.of(
                        context,
                      ).settingsPlatform(PlatformSupport.displayName),
                    ),
                    const SizedBox(height: 6),
                    Text('🔊 ${playbackSupportText(AppText.of(context))}'),
                    const SizedBox(height: 6),
                    Text(
                      '🎤 ${transcriptionSupportText(AppText.of(context), controller)}',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppText.of(context).settingsOfflineNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _showContentLicenses(context),
                        icon: const Icon(Icons.info_outline),
                        label: Text(AppText.of(context).settingsOpenLicenses),
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
                    title: Text(AppText.of(context).settingsExport),
                    subtitle: Text(AppText.of(context).settingsExportNote),
                    onTap: actionPending
                        ? null
                        : () => _runProfileAction(() => _showExport(context)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: Text(AppText.of(context).settingsImport),
                    subtitle: Text(AppText.of(context).settingsImportNote),
                    onTap: actionPending
                        ? null
                        : () => _runProfileAction(() => _showImport(context)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete_forever_outlined),
                title: Text(AppText.of(context).settingsResetAll),
                subtitle: Text(AppText.of(context).settingsResetNote),
                onTap: actionPending
                    ? null
                    : () => _runProfileAction(() => _confirmReset(context)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppText.of(
                context,
              ).settingsBuildSummary(vocabulary.length, appVersion),
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
        title: Text(AppText.of(context).settingsLicenses),
        content: SingleChildScrollView(
          child: SelectableText(AppText.of(context).settingsLicenseText),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppText.of(context).closeAction),
          ),
        ],
      ),
    );
  }

  Future<void> _runProfileAction(Future<void> Function() action) =>
      runAction(() async {
        try {
          await action();
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppText.of(context).settingsChangeFailed)),
            );
          }
        }
      });

  Future<void> _showExport(BuildContext context) async {
    final payload = ProgressBackup.export(controller);
    final copied = await showDialog<bool>(
      context: context,
      builder: (_) => BackupExportDialog(payload: payload),
    );
    if (copied == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.of(context).settingsCopyDone)),
      );
    }
  }

  Future<void> _showImport(BuildContext context) async {
    final state = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const BackupImportDialog(),
    );
    if (state == null || !context.mounted) return;
    final mode = await showDialog<_ImportMode>(
      context: context,
      builder: (context) {
        final t = AppText.of(context);
        return ProfileChoiceDialog<_ImportMode>(
          title: t.settingsMergeTitle,
          body: t.settingsMergeBody(backupSummaryText(t, state)),
          choices: [
            ProfileDialogChoice(t.cancelAction, null),
            ProfileDialogChoice(t.settingsReplace, _ImportMode.replace),
            ProfileDialogChoice(
              t.settingsMerge,
              _ImportMode.merge,
              primary: true,
            ),
          ],
        );
      },
    );
    if (mode == null || !context.mounted) return;
    final restored = mode == _ImportMode.merge
        ? ProgressBackup.merge(controller.toBackupJson(), state)
        : state;
    await controller.restoreFrom(restored);
    if (!context.mounted) return;
    final t = AppText.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mode == _ImportMode.merge
              ? t.settingsMergeDone
              : t.settingsReplaceDone,
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final t = AppText.of(context);
        return ProfileChoiceDialog<bool>(
          title: t.settingsResetTitle,
          body: t.settingsResetBody,
          choices: [
            ProfileDialogChoice(t.cancelAction, false),
            ProfileDialogChoice(t.settingsReset, true, primary: true),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      await controller.resetAllProgress();
    }
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
                AppText.of(context).tabProfile,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: ProfileAvatar(controller: controller, size: 48),
                  title: Text(
                    controller.learnerName.isEmpty
                        ? AppText.of(context).profileAddName
                        : controller.learnerName,
                  ),
                  subtitle: Text(
                    controller.learnerEmail.isEmpty
                        ? AppText.of(context).profileIdentityNote
                        : controller.learnerEmail,
                  ),
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
                              AppText.of(
                                context,
                              ).profileStreak(controller.streak),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              AppText.of(context).profileLearningSummary(
                                controller.learnedCount,
                                controller.masteredCount,
                                controller.xp,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              AppText.of(context).profilePracticeSummary(
                                controller.storyChaptersDone,
                                controller.conversationsDone,
                              ),
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
                  title: Text(
                    AppText.of(context).profileAchievements,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    AppText.of(
                      context,
                    ).profileAchievementsCount(unlocked, achievements.length),
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
                  title: Text(
                    AppText.of(context).profileDetailedProgress,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    AppText.of(context).profileDetailedProgressNote,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _push(
                    context,
                    Builder(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text(AppText.of(context).profileProgress),
                        ),
                        body: StatsScreen(controller: controller),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Text('⚙️', style: TextStyle(fontSize: 26)),
                  title: Text(
                    AppText.of(context).settingsTitle,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(AppText.of(context).profileSettingsNote),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _push(
                    context,
                    Builder(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text(AppText.of(context).settingsTitle),
                        ),
                        body: SettingsScreen(controller: controller),
                      ),
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
      appBar: AppBar(title: Text(AppText.of(context).profileAchievements)),
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
                            achievementTitle(AppText.of(context), achievement),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            achievementDescription(
                              AppText.of(context),
                              achievement,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: progress),
                          const SizedBox(height: 4),
                          Text(
                            '$value / ${achievement.target} '
                            '${statMetricText(AppText.of(context), achievement.metric)}',
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
