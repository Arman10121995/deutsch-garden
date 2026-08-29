import 'package:flutter/material.dart';

import 'app_state.dart';
import 'audio_course_screens.dart';
import 'conversation_screens.dart';
import 'games.dart';
import 'models.dart';
import 'radio.dart';
import 'radio_screens.dart';
import 'skill_screens.dart';
import 'stories.dart';
import 'story_screens.dart';
import 'vocabulary.dart';
import 'vocabulary_library_screen.dart';

/// Optional libraries, specialist labs and tests. These are deliberately one
/// destination: they are ways to explore or target a need, not competing
/// learning paths.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  CefrLevel? _level;

  CefrLevel get _selected => _level ?? widget.controller.highestUnlockedLevel;

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final CefrLevel level = _selected;
          final int mistakes = widget.controller.mistakes.length;
          final int difficult = widget.controller.difficultWords.length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            children: <Widget>[
              Text(
                'Explore',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Browse a library, target a weak point, or prepare for a test. '
                'Your required sequence stays in Learn.',
              ),
              const SizedBox(height: 14),
              _LevelPicker(
                selected: level,
                controller: widget.controller,
                onChanged: (value) => setState(() => _level = value),
              ),
              const SizedBox(height: 16),
              _Section(
                icon: Icons.healing_rounded,
                title: 'Target a weak point',
                subtitle: '$mistakes mistakes · $difficult difficult words',
                children: <Widget>[
                  _Item(
                    emoji: '🩹',
                    title: 'Mistake bank',
                    subtitle: mistakes == 0
                        ? 'No mistakes waiting'
                        : '$mistakes items waiting',
                    onTap: () =>
                        _push(MistakeBankScreen(controller: widget.controller)),
                  ),
                  _Item(
                    emoji: '🧩',
                    title: 'Difficult words',
                    subtitle: difficult == 0
                        ? 'No recurring leeches yet'
                        : '$difficult words need a new memory hook',
                    onTap: () => _push(
                      DifficultWordsScreen(controller: widget.controller),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Section(
                icon: Icons.local_library_rounded,
                title: '${level.label} libraries',
                subtitle: 'All skills, stories, audio and speaking',
                children: <Widget>[
                  _Item(
                    emoji: '📚',
                    title: 'Vocabulary library',
                    subtitle:
                        'Search all ${vocabulary.length} words, examples and '
                        'favorites',
                    onTap: () => _push(
                      VocabularyLibraryScreen(controller: widget.controller),
                    ),
                  ),
                  _Item(
                    emoji: '🧭',
                    title: 'All ${level.label} skills',
                    subtitle:
                        'Vocabulary, grammar, listening, reading, '
                        'writing and speaking catalogues',
                    onTap: () => _push(
                      LevelDashboardScreen(
                        controller: widget.controller,
                        level: level,
                      ),
                    ),
                  ),
                  _Item(
                    emoji: '🗣️',
                    title: 'Speaking studio',
                    subtitle: 'Role-plays, open questions and pronunciation',
                    onTap: () => _push(
                      Scaffold(
                        appBar: AppBar(title: const Text('Speaking studio')),
                        body: SpeakHubScreen(controller: widget.controller),
                      ),
                    ),
                  ),
                  _Item(
                    emoji: '📖',
                    title: 'Story library',
                    subtitle:
                        '${storiesFor(level).length} graded stories at '
                        '${level.label}',
                    onTap: () => _push(
                      Scaffold(
                        appBar: AppBar(title: const Text('Story library')),
                        body: StoryLibraryScreen(controller: widget.controller),
                      ),
                    ),
                  ),
                  _Item(
                    emoji: '📻',
                    title: 'Gartenradio',
                    subtitle:
                        '${radioFor(level).length} authored episodes at '
                        '${level.label}',
                    onTap: () => _push(
                      RadioLibraryScreen(
                        controller: widget.controller,
                        level: level,
                      ),
                    ),
                  ),
                  _Item(
                    emoji: '🎧',
                    title: 'Spaced audio course',
                    subtitle: 'Anticipation speaking and scheduled replay',
                    onTap: () => _push(
                      AudioCourseScreen(
                        controller: widget.controller,
                        level: level,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Hidden when the learner has decided Learn is the whole path.
              // Everything here is still reachable that way; what goes is the
              // second list of the same drills.
              if (widget.controller.showExploreLabs)
                _Section(
                  icon: Icons.science_rounded,
                  title: 'Practice labs',
                  subtitle:
                      'Choose a drill only when you want extra repetition',
                children: <Widget>[
                  _drill('🃏', 'Match pairs', 'German ↔ English', () {
                    _push(
                      MatchPairsScreen(
                        controller: widget.controller,
                        level: level,
                      ),
                    );
                  }),
                  _drill(
                    '🧱',
                    'Sentence builder',
                    'Rebuild complete sentences',
                    () {
                      _push(
                        SentenceBuilderScreen(
                          controller: widget.controller,
                          level: level,
                        ),
                      );
                    },
                  ),
                  _drill('✍️', 'Dictation', 'Hear, type and compare', () {
                    _push(
                      DictationScreen(
                        controller: widget.controller,
                        level: level,
                      ),
                    );
                  }),
                  _drill(
                    '⚡',
                    'Speed review',
                    'One-minute retrieval sprint',
                    () {
                      _push(
                        SpeedReviewScreen(
                          controller: widget.controller,
                          level: level,
                        ),
                      );
                    },
                  ),
                  _drill(
                    '🎯',
                    'Der / die / das',
                    'Article and gender patterns',
                    () {
                      _push(
                        ArticleTrainerScreen(
                          controller: widget.controller,
                          level: level,
                        ),
                      );
                    },
                  ),
                  _drill('⚙️', 'Verb lab', 'Conjugation across tenses', () {
                    _push(
                      VerbLabScreen(
                        controller: widget.controller,
                        level: level,
                      ),
                    );
                  }),
                  _drill('🧩', 'Cloze drill', 'Fill words in context', () {
                    _push(
                      ClozeDrillScreen(
                        controller: widget.controller,
                        level: level,
                      ),
                    );
                  }),
                  _drill('🎙️', 'Shadow lab', 'Listen, repeat and compare', () {
                    _push(
                      ShadowLabScreen(
                        controller: widget.controller,
                        level: level,
                      ),
                    );
                  }),
                  _drill(
                    '📐',
                    'Grammar challenges',
                    'Twelve focused structures',
                    () {
                      _push(
                        GrammarChallengeHubScreen(
                          controller: widget.controller,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Section(
                icon: Icons.school_rounded,
                title: 'Tests & official preparation',
                subtitle: 'Placement, CEFR mocks, LiD and citizenship',
                children: <Widget>[
                  _Item(
                    emoji: '🎓',
                    title: 'Open test centre',
                    subtitle:
                        'Placement assessment, CEFR exam practice, '
                        'Leben in Deutschland and Einbürgerungstest',
                    onTap: () =>
                        _push(TestHubHostScreen(controller: widget.controller)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _drill(
    String emoji,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => _Item(emoji: emoji, title: title, subtitle: subtitle, onTap: onTap);
}

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({
    required this.selected,
    required this.controller,
    required this.onChanged,
  });

  final CefrLevel selected;
  final AppController controller;
  final ValueChanged<CefrLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final CefrLevel level in CefrLevel.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(level.label),
                selected: selected == level,
                onSelected: controller.isLevelUnlocked(level)
                    ? (_) => onChanged(level)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        children: children,
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: onTap != null,
      leading: Text(emoji, style: const TextStyle(fontSize: 25)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
