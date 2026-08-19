import 'package:flutter/material.dart';

import 'app_state.dart';
import 'models.dart';
import 'skill_screens.dart';
import 'tts_service.dart';
import 'test_screens.dart';
import 'vocabulary.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(controller: widget.controller),
      WordListScreen(controller: widget.controller),
      TestHubScreen(controller: widget.controller),
      StatsScreen(controller: widget.controller),
      SettingsScreen(controller: widget.controller),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Words',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Tests',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
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
                separatorBuilder: (_, __) => const SizedBox(height: 6),
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
            Text(p.plantIcon, style: const TextStyle(fontSize: 20)),
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
              child: ListTile(
                leading: const Icon(Icons.delete_forever_outlined),
                title: const Text('Reset all learning progress'),
                subtitle: const Text('Deletes XP, streak, lesson scores, drafts and word mastery on this device'),
                onTap: () => _confirmReset(context),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'DeutschGarden 2.0 • ${vocabulary.length} bundled A1–C2 words • vocabulary + grammar + listening + reading + writing • offline-first',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
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
