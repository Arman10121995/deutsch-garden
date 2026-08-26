import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'achievements.dart';
import 'backup.dart';
import 'app_state.dart';
import 'build_info.dart';
import 'conversation_screens.dart';
import 'course_screens.dart';
import 'games.dart';
import 'models.dart';
import 'platform_support.dart';
import 'skill_screens.dart';
import 'tts_service.dart';
import 'vocabulary.dart';

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

  // Five destinations, and the course takes one of them. It is the answer to
  // "what should I do next", which is the question the app was worst at, so
  // burying it a tap down would have defeated the point of building it.
  //
  // Stories moved into the practice hub to make room, alongside Gartenradio,
  // which was already there. They are both libraries to browse rather than
  // paths to follow, and every story is also a step inside a course unit, so
  // nothing became harder to reach than it was.
  static const List<_Destination> _destinations = <_Destination>[
    _Destination('Home', Icons.home_outlined, Icons.home),
    _Destination('Course', Icons.route_outlined, Icons.route),
    _Destination('Speak', Icons.record_voice_over_outlined, Icons.record_voice_over),
    _Destination('Practice', Icons.fitness_center_outlined, Icons.fitness_center),
    _Destination('Profile', Icons.person_outline, Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(controller: widget.controller),
      CourseScreen(controller: widget.controller),
      SpeakHubScreen(controller: widget.controller),
      PracticeHubScreen(controller: widget.controller),
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
                backgroundColor:
                    Theme.of(context).colorScheme.errorContainer,
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
                    child: const Text('Verstanden'),
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
                  destinations: _destinations
                      .map((destination) => NavigationRailDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.selectedIcon),
                            label: Text(destination.label),
                          ))
                      .toList(),
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
            destinations: _destinations
                .map((destination) => NavigationDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: destination.label,
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});
  final AppController controller;

  void _openLevel(BuildContext context, CefrLevel level) {
    if (!controller.isLevelUnlocked(level)) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => LevelDashboardScreen(controller: controller, level: level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final current = controller.highestUnlockedLevel;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'DeutschGarden',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text('A1 → C2 German mastery path'),
                      ],
                    ),
                  ),
                  _pill(context, '🔥 ${controller.streak}'),
                  const SizedBox(width: 7),
                  _pill(context, '⚡ ${controller.xp}'),
                ],
              ),
              const SizedBox(height: 22),
              _dailyGoalCard(context),
              const SizedBox(height: 14),
              _questsCard(context),
              const SizedBox(height: 14),
              _quickActions(context),
              const SizedBox(height: 18),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openLevel(context, current),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 28,
                          child: Text(
                            current.label,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Continue ${current.label}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(current.description),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: controller.levelProgress(current),
                                minHeight: 7,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'CEFR roadmap',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'Reach ${(AppController.levelUnlockThreshold * 100).round()}% overall mastery to unlock the next level.',
              ),
              const SizedBox(height: 14),
              ...CefrLevel.values.map((level) => _levelCard(context, level)),
            ],
          );
        },
      ),
    );
  }

  Widget _levelCard(BuildContext context, CefrLevel level) {
    final unlocked = controller.isLevelUnlocked(level);
    final progress = controller.levelProgress(level);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          onTap: unlocked ? () => _openLevel(context, level) : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  child: unlocked
                      ? Text(level.label,
                          style: const TextStyle(fontWeight: FontWeight.w900))
                      : const Icon(Icons.lock_outline_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            level.label,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(level.description)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 3),
                      Text(
                        unlocked
                            ? '${(progress * 100).round()}% complete'
                            : 'Locked',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (unlocked) const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      );

  Widget _questsCard(BuildContext context) {
    final List<DailyQuest> quests = controller.todaysQuests;
    if (quests.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Tagesaufgaben',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              'Three quests, reshuffled every day.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ...quests.map((quest) {
              final int progress = controller.questProgress(quest);
              final bool done = controller.isQuestComplete(quest);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: <Widget>[
                    Text(done ? '✅' : quest.emoji,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(quest.title,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: (progress / quest.target).clamp(0.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('$progress/${quest.target}',
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(width: 6),
                    Text('+${quest.reward}',
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final int due = controller.dueCount;
    final int mistakes = controller.mistakes.length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          _actionChip(
            context,
            '🔁 Review${due > 0 ? ' ($due)' : ''}',
            () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ReviewSessionScreen(controller: controller),
              ),
            ),
          ),
          _actionChip(
            context,
            '📚 Word list',
            () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Vocabulary library')),
                  body: WordListScreen(controller: controller),
                ),
              ),
            ),
          ),
          _actionChip(
            context,
            '🩹 Mistakes${mistakes > 0 ? ' ($mistakes)' : ''}',
            () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => MistakeBankScreen(controller: controller),
              ),
            ),
          ),
          _actionChip(
            context,
            '🗣️ Talk',
            () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Sprechen')),
                  body: SpeakHubScreen(controller: controller),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionChip(BuildContext context, String label, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ActionChip(label: Text(label), onPressed: onTap),
      );

  Widget _dailyGoalCard(BuildContext context) {
    final completed = controller.todayReviews >= controller.dailyGoal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 62,
              height: 62,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: controller.dailyGoalProgress,
                      strokeWidth: 7,
                    ),
                  ),
                  Text(
                    completed ? '✓' : '${controller.todayReviews}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    completed ? 'Daily goal complete!' : 'Daily goal',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text('${controller.todayReviews} / ${controller.dailyGoal} learning actions today'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final TextEditingController _search = TextEditingController();
  final TtsService _tts = TtsService();
  String _category = 'All';
  String _level = 'All';
  bool _favoritesOnly = false;

  @override
  void dispose() {
    _search.dispose();
    _tts.stop();
    super.dispose();
  }

  List<GermanWord> _filtered() {
    final q = _search.text.trim().toLowerCase();
    return vocabulary.where((word) {
      final textMatch = q.isEmpty ||
          word.german.toLowerCase().contains(q) ||
          word.english.toLowerCase().contains(q) ||
          word.plural.toLowerCase().contains(q);
      final categoryMatch = _category == 'All' || word.category == _category;
      final levelMatch = _level == 'All' || word.level == _level;
      final favoriteMatch = !_favoritesOnly ||
          (widget.controller.progress[word.id]?.favorite ?? false);
      return textMatch && categoryMatch && levelMatch && favoriteMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>{'All', ...vocabulary.map((word) => word.category)}
        .toList()
      ..sort((a, b) {
        if (a == 'All') return -1;
        if (b == 'All') return 1;
        return a.compareTo(b);
      });
    final words = _filtered();
    return SafeArea(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) => Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Vocabulary library',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text('${vocabulary.length} bundled words • A1 to C2'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search German, English or plural',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        DropdownButton<String>(
                          value: _level,
                          items: <String>[
                            'All',
                            ...CefrLevel.values.map((e) => e.label),
                          ]
                              .map(
                                (value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value == 'All' ? 'All levels' : value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _level = value ?? 'All'),
                        ),
                        const SizedBox(width: 14),
                        DropdownButton<String>(
                          value: _category,
                          items: categories
                              .map(
                                (value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _category = value ?? 'All'),
                        ),
                        const SizedBox(width: 12),
                        FilterChip(
                          label: const Text('Favorites'),
                          selected: _favoritesOnly,
                          onSelected: (value) =>
                              setState(() => _favoritesOnly = value),
                        ),
                      ],
                    ),
                  ),
                  Text('${words.length} words'),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                itemCount: words.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) => _wordTile(context, words[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wordTile(BuildContext context, GermanWord word) {
    final p = widget.controller.progress[word.id] ?? WordProgress();
    final color = word.genderColor(Theme.of(context).brightness);
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color,
          foregroundColor: Colors.white,
          child: Text(
            word.article.isEmpty
                ? '•'
                : word.article.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        title: Text(word.displayGerman,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${word.english} • ${word.level} • ${word.category}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              label: p.masteryLabel,
              child: ExcludeSemantics(
                child: Text(p.plantIcon,
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            IconButton(
              tooltip: 'Favorite',
              onPressed: () => widget.controller.toggleFavorite(word.id),
              icon: Icon(p.favorite ? Icons.star : Icons.star_border),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  word.plural == '—' || word.plural.isEmpty
                      ? 'Lexical item'
                      : 'Plural: ${word.plural}',
                ),
              ),
              IconButton(
                tooltip: 'Hear this word in German',
                onPressed: widget.controller.ttsEnabled
                    ? () => _tts.speakGerman(word.displayGerman)
                    : null,
                icon: const Icon(Icons.volume_up_rounded),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(word.exampleGerman,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(word.exampleEnglish),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(child: LinearProgressIndicator(value: p.mastery / 5)),
              const SizedBox(width: 12),
              Text('Mastery ${p.mastery}/5'),
            ],
          ),
        ],
      ),
    );
  }
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
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
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
                _statCard(context, '🌿', '${controller.learnedCount}', 'words learned'),
                _statCard(context, '🌳', '${controller.masteredCount}', 'words mastered'),
                _statCard(context, '🎯', '${(controller.accuracy * 100).round()}%', 'vocab accuracy'),
                _statCard(context, '🏅', controller.highestUnlockedLevel.label, 'highest unlocked'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'CEFR skill matrix',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ...CefrLevel.values.map((level) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(level.label,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900)),
                              const Spacer(),
                              Text('${(controller.levelProgress(level) * 100).round()}%'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...SkillType.values.map((skill) => Padding(
                                padding: const EdgeInsets.only(bottom: 7),
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(width: 28, child: Text(skill.emoji)),
                                    SizedBox(width: 86, child: Text(skill.label)),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: controller.skillProgress(level, skill),
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
                              )),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String emoji, String value, String label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 25)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              'Settings',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            Card(
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: const Text('German pronunciation'),
                    subtitle: const Text('Use the device text-to-speech engine for vocabulary and listening'),
                    value: controller.ttsEnabled,
                    onChanged: controller.setTtsEnabled,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Immersion mode'),
                    subtitle: const Text(
                        'Hide English by default in stories, role-plays and '
                        'speaking prompts. You can still reveal it per screen.'),
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
                          onChanged: (value) => controller.setDailyGoal(value.round()),
                        ),
                      ],
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
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
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
                    Text('Gender colors',
                        style: TextStyle(fontWeight: FontWeight.w900)),
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
                    Text('This build',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900)),
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
                        'Copy your whole profile as text, to carry it to another device'),
                    onTap: () => _showExport(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: const Text('Import progress'),
                    subtitle: const Text(
                        'Paste a profile exported from another device — replaces what is here'),
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
                subtitle: const Text('Deletes XP, streak, lesson scores, drafts and word mastery on this device'),
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
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      payload,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
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
              final ScaffoldMessengerState messenger =
                  ScaffoldMessenger.of(context);
              final NavigatorState navigator = Navigator.of(context);
              await Clipboard.setData(ClipboardData(text: payload));
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Profile copied to the clipboard')),
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
                    final ClipboardData? data =
                        await Clipboard.getData(Clipboard.kTextPlain);
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
                final BackupImportResult result =
                    ProgressBackup.parse(input.text);
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

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace your progress?'),
        content: Text(
          'The backup contains:\n\n${ProgressBackup.describe(state)}\n\n'
          'Restoring replaces everything currently on this device. This cannot '
          'be undone — export the current profile first if you want to keep it.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.restoreFrom(state);
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text('This removes all local learning history and saved writing drafts. This cannot be undone.'),
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
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      ),
    );
  }
}

/// Profile tab: a compact summary plus the routes that used to live in the
/// bottom bar (full statistics, achievements, the word list and settings).
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
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
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
                            Text('🔥 ${controller.streak}-day streak',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 17)),
                            const SizedBox(height: 3),
                            Text('⚡ ${controller.xp} XP • '
                                '🌿 ${controller.learnedCount} learned • '
                                '🌳 ${controller.masteredCount} mastered'),
                            const SizedBox(height: 3),
                            Text('🗣️ ${controller.conversationsDone} role-plays • '
                                '📖 ${controller.storyChaptersDone} chapters'),
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
                  title: const Text('Achievements',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle:
                      Text('$unlocked of ${achievements.length} unlocked'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _push(
                      context, AchievementsScreen(controller: controller)),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Text('📊', style: TextStyle(fontSize: 26)),
                  title: const Text('Detailed progress',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: const Text('CEFR skill matrix across all six levels'),
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
                  leading: const Text('📚', style: TextStyle(fontSize: 26)),
                  title: const Text('Vocabulary library',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle:
                      Text('${vocabulary.length} bundled words, searchable'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _push(
                    context,
                    Scaffold(
                      appBar: AppBar(title: const Text('Vocabulary library')),
                      body: WordListScreen(controller: controller),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Text('⚙️', style: TextStyle(fontSize: 26)),
                  title: const Text('Settings',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: const Text(
                      'Speech, immersion mode, daily goal, theme and reset'),
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
            final bool unlocked =
                widget.controller.isAchievementUnlocked(achievement);
            final double progress =
                widget.controller.achievementProgress(achievement);
            final int value =
                widget.controller.metricValue(achievement.metric);
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Opacity(
                      opacity: unlocked ? 1 : 0.35,
                      child: Text(achievement.emoji,
                          style: const TextStyle(fontSize: 30)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(achievement.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text(achievement.description,
                              style: Theme.of(context).textTheme.bodySmall),
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
                    if (unlocked)
                      const Icon(Icons.verified_rounded, size: 20),
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
