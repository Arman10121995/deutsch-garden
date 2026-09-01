import 'dart:math';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'curriculum.dart';
import 'curriculum_meta.dart';
import 'grammar_tables.dart';
import 'lesson_registry.dart';
import 'models.dart';
import 'sentence_audio.dart';
import 'vocab_icon.dart';
import 'study_session.dart';
import 'tts_service.dart';
import 'vocabulary_metadata.dart';
import 'answer_shuffle.dart';
import 'hints.dart';

class LevelDashboardScreen extends StatelessWidget {
  const LevelDashboardScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  void _open(BuildContext context, SkillType skill) {
    Widget page;
    switch (skill) {
      case SkillType.vocabulary:
        page = VocabularyLevelScreen(controller: controller, level: level);
        break;
      case SkillType.grammar:
        page = GrammarListScreen(controller: controller, level: level);
        break;
      case SkillType.listening:
        page = ListeningListScreen(controller: controller, level: level);
        break;
      case SkillType.reading:
        page = ReadingListScreen(controller: controller, level: level);
        break;
      case SkillType.writing:
        page = WritingListScreen(controller: controller, level: level);
        break;
      case SkillType.speaking:
        page = SpeakingListScreen(controller: controller, level: level);
        break;
    }
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${level.label} German')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              level.description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: controller.levelProgress(level),
              minHeight: 9,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 6),
            Text(
              '${(controller.levelProgress(level) * 100).round()}% overall mastery',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            ...SkillType.values.map((skill) {
              final progress = controller.skillProgress(level, skill);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _open(context, skill),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: <Widget>[
                          Text(
                            skill.emoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  skill.label,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 7),
                                LinearProgressIndicator(value: progress),
                                const SizedBox(height: 4),
                                Text('${(progress * 100).round()}%'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (level.next != null) ...<Widget>[
              const SizedBox(height: 6),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    controller.isLevelUnlocked(level.next!)
                        ? '${level.next!.label} is unlocked.'
                        : 'Reach ${(AppController.levelUnlockThreshold * 100).round()}% overall mastery in ${level.label} to unlock ${level.next!.label}.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VocabularyLevelScreen extends StatefulWidget {
  const VocabularyLevelScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  State<VocabularyLevelScreen> createState() => _VocabularyLevelScreenState();
}

class _VocabularyLevelScreenState extends State<VocabularyLevelScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _articleFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _session(BuildContext context, SessionKind kind) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => StudySessionScreen(
          controller: widget.controller,
          kind: kind,
          level: widget.level,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.level.label} Vocabulary')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final words = widget.controller.wordsForLevel(widget.level);
          final seen = words
              .where(
                (word) => widget.controller.progress[word.id]?.seen ?? false,
              )
              .length;
          final mastered = words
              .where(
                (word) =>
                    widget.controller.progress[word.id]?.mastered ?? false,
              )
              .length;
          final due = widget.controller
              .reviewWordsForLevel(widget.level)
              .length;

          final query = _searchController.text.trim().toLowerCase();
          final filteredWords = words.where((word) {
            final matchesArticle =
                _articleFilter == 'all' ||
                word.article.toLowerCase() == _articleFilter;
            final matchesQuery =
                query.isEmpty ||
                word.german.toLowerCase().contains(query) ||
                word.english.toLowerCase().contains(query);
            return matchesArticle && matchesQuery;
          }).toList();

          // The header is a handful of widgets and is cheap to build eagerly.
          // The card list is not: a level holds up to 212 words and this
          // rebuilds on every keystroke in the search field, so it goes
          // through a builder and only materialises what is on screen.
          final List<Widget> header = <Widget>[
            _summaryCard(
              context,
              '${words.length} bundled training cards',
              '$seen learned • $mastered mastered • $due due\n'
                  'Internal cumulative breadth target by ${widget.level.label}: ~${coverageFor(widget.level).lexicalBreadthTarget} lexical units (planning target, not an official CEFR word count).',
              widget.controller.skillProgress(
                widget.level,
                SkillType.vocabulary,
              ),
            ),
            const SizedBox(height: 16),
            _action(
              context,
              '🌱',
              'Learn new words',
              'Introduce up to 10 new ${widget.level.label} words with pronunciation and examples.',
              () => _session(context, SessionKind.learn),
            ),
            const SizedBox(height: 10),
            _action(
              context,
              '🧠',
              'Smart review',
              due == 0
                  ? 'No ${widget.level.label} words are due right now.'
                  : '$due ${widget.level.label} words are due now.',
              () => _session(context, SessionKind.review),
            ),
            const SizedBox(height: 10),
            _action(
              context,
              '⚡',
              'Mixed practice',
              'Meaning, German recognition, articles and typed recall.',
              () => _session(context, SessionKind.practice),
            ),
            const SizedBox(height: 24),
            Text(
              'Vocabulary Bank (${filteredWords.length}/${words.length})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search vocabulary...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <String>['all', 'der', 'die', 'das'].map((art) {
                  final label = art == 'all' ? 'All Articles' : art;
                  final isSelected = _articleFilter == art;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _articleFilter = art),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ];

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: header.length + filteredWords.length,
            itemBuilder: (context, index) {
              if (index < header.length) return header[index];
              final GermanWord word = filteredWords[index - header.length];
              final p = widget.controller.progressFor(word.id);
              return Card(
                child: ListTile(
                  leading: VocabVisual(word: word, size: 40),
                  title: Text(
                    word.displayGerman,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${word.english} · ${word.grammarLabel}'),
                  trailing: IconButton(
                    tooltip: p.favorite
                        ? 'Remove ${word.german} from favourites'
                        : 'Add ${word.german} to favourites',
                    icon: Icon(
                      p.favorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: p.favorite ? Colors.amber : null,
                    ),
                    onPressed: () => widget.controller.toggleFavorite(word.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    String title,
    String subtitle,
    double progress,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress, minHeight: 8),
          ],
        ),
      ),
    );
  }

  Widget _action(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Text(emoji, style: const TextStyle(fontSize: 30)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class GrammarListScreen extends StatelessWidget {
  const GrammarListScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  Widget build(BuildContext context) {
    final lessons = grammarFor(level).toList();
    return _LessonListScaffold(
      title: '${level.label} Grammar',
      subtitle:
          'Learn the rule, inspect examples, then pass the quiz with 70%.',
      actions: <Widget>[
        IconButton(
          tooltip: 'Conjugation and grammar tables',
          icon: const Icon(Icons.table_chart_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => GrammarTablesScreen(
                initialLevel: level,
                ttsEnabled: controller.ttsEnabled,
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Grammar Handbook',
          icon: const Icon(Icons.menu_book_rounded),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => GrammarHandbookScreen(controller: controller),
            ),
          ),
        ),
      ],
      children: lessons.map((lesson) {
        final p = controller.activities[lesson.id] ?? ActivityProgress();
        return _lessonTile(
          context,
          lesson.title,
          p,
          () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  GrammarLessonScreen(controller: controller, lesson: lesson),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class GrammarLessonScreen extends StatefulWidget {
  const GrammarLessonScreen({
    super.key,
    required this.controller,
    required this.lesson,
  });

  final AppController controller;
  final GrammarLesson lesson;

  @override
  State<GrammarLessonScreen> createState() => _GrammarLessonScreenState();
}

class _GrammarLessonScreenState extends State<GrammarLessonScreen> {
  /// Fixed once per sitting, so the option order is stable while a question is
  /// on screen and different next time. See lib/answer_shuffle.dart.
  final int _shuffleSalt = Random().nextInt(0x7fffffff);

  int _index = -1;
  int _correct = 0;
  int? _selected;
  final Set<int> _correctAnswers = <int>{};

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Grammar · ${widget.lesson.title}');
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Grammar · ${widget.lesson.title}');
    super.dispose();
  }

  void _previous() {
    final int target = _index >= widget.lesson.questions.length
        ? widget.lesson.questions.length - 1
        : _index - 1;
    if (target < 0) {
      setState(() {
        _index = -1;
        _selected = null;
      });
      return;
    }
    setState(() {
      _correctAnswers.remove(target);
      _correct = _correctAnswers.length;
      _index = target;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    if (_index < 0) {
      return Scaffold(
        appBar: AppBar(title: Text(lesson.title)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            _lessonHeader(context, lesson.level, '🧩 Grammar'),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  lesson.explanation,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Examples',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...lesson.examples.map(
              (example) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: SpeakableSentence(
                    text: example,
                    enabled: widget.controller.ttsEnabled,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            if (tablesForLesson(lesson).isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Reference table',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => GrammarTablesScreen(
                          initialLevel: lesson.level,
                          ttsEnabled: widget.controller.ttsEnabled,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.table_chart_outlined),
                    label: const Text('All tables'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final GrammarReferenceTable table in tablesForLesson(lesson))
                GrammarTableCard(
                  table: table,
                  ttsEnabled: widget.controller.ttsEnabled,
                ),
            ],
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => setState(() => _index = 0),
              icon: const Icon(Icons.quiz_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Start quiz'),
              ),
            ),
          ],
        ),
      );
    }
    if (_index >= lesson.questions.length) {
      final score = ((_correct / lesson.questions.length) * 100).round();
      return _CompletionScreen(
        title: 'Grammar complete',
        score: score,
        passed: score >= 70,
        onSave: () async {
          final NavigatorState navigator = Navigator.of(context);
          await widget.controller.recordActivity(lesson.id, score: score);
          if (mounted) navigator.pop();
        },
        onPrevious: _previous,
      );
    }
    // Permuted before it is shown or graded. See lib/answer_shuffle.dart.
    final q = lesson.questions[_index].shuffled(
      seededFor(lesson.questions[_index].prompt, _shuffleSalt),
    );
    return _ChoiceQuizScaffold(
      title: '${lesson.level.label} Grammar',
      progress: (_index + 1) / lesson.questions.length,
      question: q,
      selected: _selected,
      onSelect: (choice) {
        if (_selected != null) return;
        setState(() {
          _selected = choice;
          if (choice == q.correctIndex) {
            _correctAnswers.add(_index);
            _correct = _correctAnswers.length;
          }
        });
        if (choice != q.correctIndex) {
          recordChoiceMistake(
            widget.controller,
            lessonId: lesson.id,
            level: lesson.level,
            source: 'grammar',
            question: q,
            questionIndex: _index,
            choice: choice,
          );
        }
      },
      // The lesson's own explanation is the hint: it is the rule being
      // taught, and a rule describes a pattern while an option is one
      // instance of it. lib/hints.dart drops it and falls back if it would
      // give the answer away.
      ruleText: lesson.explanation,
      personalization: personalizationForQuestion(
        widget.controller.mistakes,
        '${lesson.id}-q$_index',
      ),
      onPrevious: _previous,
      onSkip: _selected != null
          ? null
          : () {
              widget.controller.recordSkip(
                id: '${lesson.id}-q$_index',
                prompt: q.prompt,
                correctAnswer: q.options[q.correctIndex],
                source: 'grammar',
                level: lesson.level.label,
              );
              setState(() {
                _index += 1;
                _selected = null;
              });
            },
      onContinue: _selected == null
          ? null
          : () => setState(() {
              _index += 1;
              _selected = null;
            }),
    );
  }
}

class ListeningListScreen extends StatelessWidget {
  const ListeningListScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  Widget build(BuildContext context) {
    final lessons = listeningFor(level).toList();
    return _LessonListScaffold(
      title: '${level.label} Listening',
      subtitle:
          'Listen to native-device German TTS, then answer comprehension questions.',
      children: lessons.map((lesson) {
        final p = controller.activities[lesson.id] ?? ActivityProgress();
        return _lessonTile(
          context,
          lesson.title,
          p,
          () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  ListeningLessonScreen(controller: controller, lesson: lesson),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ListeningLessonScreen extends StatefulWidget {
  const ListeningLessonScreen({
    super.key,
    required this.controller,
    required this.lesson,
  });

  final AppController controller;
  final ListeningLesson lesson;

  @override
  State<ListeningLessonScreen> createState() => _ListeningLessonScreenState();
}

class _ListeningLessonScreenState extends State<ListeningLessonScreen> {
  /// Fixed once per sitting, so the option order is stable while a question is
  /// on screen and different next time. See lib/answer_shuffle.dart.
  final int _shuffleSalt = Random().nextInt(0x7fffffff);

  final TtsService _tts = TtsService();
  int _index = -1;
  int _correct = 0;
  int? _selected;
  bool _showTranscript = false;
  final Set<int> _correctAnswers = <int>{};

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Listening · ${widget.lesson.title}');
  }

  void _previous() {
    final int target = _index >= widget.lesson.questions.length
        ? widget.lesson.questions.length - 1
        : _index - 1;
    if (target < 0) {
      setState(() {
        _index = -1;
        _selected = null;
      });
      return;
    }
    setState(() {
      _correctAnswers.remove(target);
      _correct = _correctAnswers.length;
      _index = target;
      _selected = null;
    });
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Listening · ${widget.lesson.title}');
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    if (_index < 0) {
      return Scaffold(
        appBar: AppBar(title: Text(lesson.title)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            _lessonHeader(context, lesson.level, '🎧 Listening'),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.headphones_rounded, size: 64),
                    const SizedBox(height: 12),
                    const Text(
                      'Listen at least twice before revealing the transcript.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: widget.controller.ttsEnabled
                          ? () => _tts.speakGerman(lesson.transcript)
                          : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play German audio'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () =>
                  setState(() => _showTranscript = !_showTranscript),
              child: Text(
                _showTranscript ? 'Hide transcript' : 'Reveal transcript',
              ),
            ),
            if (_showTranscript) ...<Widget>[
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        lesson.transcript,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Divider(height: 26),
                      Text(lesson.translation),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _index = 0),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Start comprehension'),
              ),
            ),
          ],
        ),
      );
    }
    if (_index >= lesson.questions.length) {
      final score = ((_correct / lesson.questions.length) * 100).round();
      return _CompletionScreen(
        title: 'Listening complete',
        score: score,
        passed: score >= 70,
        onSave: () async {
          final NavigatorState navigator = Navigator.of(context);
          await widget.controller.recordActivity(lesson.id, score: score);
          if (mounted) navigator.pop();
        },
        onPrevious: _previous,
      );
    }
    // Permuted before it is shown or graded. See lib/answer_shuffle.dart.
    final q = lesson.questions[_index].shuffled(
      seededFor(lesson.questions[_index].prompt, _shuffleSalt),
    );
    return _ChoiceQuizScaffold(
      title: '${lesson.level.label} Listening',
      progress: (_index + 1) / lesson.questions.length,
      question: q,
      selected: _selected,
      topAction: widget.controller.ttsEnabled
          ? FilledButton.tonalIcon(
              onPressed: () => _tts.speakGerman(lesson.transcript),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Replay audio'),
            )
          : null,
      onSelect: (choice) {
        if (_selected != null) return;
        setState(() {
          _selected = choice;
          if (choice == q.correctIndex) {
            _correctAnswers.add(_index);
            _correct = _correctAnswers.length;
          }
        });
        if (choice != q.correctIndex) {
          recordChoiceMistake(
            widget.controller,
            lessonId: lesson.id,
            level: lesson.level,
            source: 'listening',
            question: q,
            questionIndex: _index,
            choice: choice,
          );
        }
      },
      // No rule text: a comprehension question is not testing a rule, so
      // there is nothing to remind the learner of. lib/hints.dart falls back
      // to a structural hint -- where to look -- which the UI labels as the
      // weaker kind of help rather than dressing it up as a rule.
      ruleText: '',
      personalization: personalizationForQuestion(
        widget.controller.mistakes,
        '${lesson.id}-q$_index',
      ),
      onPrevious: _previous,
      onSkip: _selected != null
          ? null
          : () {
              widget.controller.recordSkip(
                id: '${lesson.id}-q$_index',
                prompt: q.prompt,
                correctAnswer: q.options[q.correctIndex],
                source: 'listening',
                level: lesson.level.label,
              );
              setState(() {
                _index += 1;
                _selected = null;
              });
            },
      onContinue: _selected == null
          ? null
          : () => setState(() {
              _index += 1;
              _selected = null;
            }),
    );
  }
}

class ReadingListScreen extends StatelessWidget {
  const ReadingListScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  Widget build(BuildContext context) {
    final lessons = readingFor(level).toList();
    return _LessonListScaffold(
      title: '${level.label} Reading',
      subtitle:
          'Read increasingly complex German texts and answer comprehension questions.',
      children: lessons.map((lesson) {
        final p = controller.activities[lesson.id] ?? ActivityProgress();
        return _lessonTile(
          context,
          lesson.title,
          p,
          () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  ReadingLessonScreen(controller: controller, lesson: lesson),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ReadingLessonScreen extends StatefulWidget {
  const ReadingLessonScreen({
    super.key,
    required this.controller,
    required this.lesson,
  });

  final AppController controller;
  final ReadingLesson lesson;

  @override
  State<ReadingLessonScreen> createState() => _ReadingLessonScreenState();
}

class _ReadingLessonScreenState extends State<ReadingLessonScreen> {
  /// Fixed once per sitting, so the option order is stable while a question is
  /// on screen and different next time. See lib/answer_shuffle.dart.
  final int _shuffleSalt = Random().nextInt(0x7fffffff);

  int _index = -1;
  int _correct = 0;
  int? _selected;
  final Set<int> _correctAnswers = <int>{};

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Reading · ${widget.lesson.title}');
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Reading · ${widget.lesson.title}');
    super.dispose();
  }

  void _previous() {
    final int target = _index >= widget.lesson.questions.length
        ? widget.lesson.questions.length - 1
        : _index - 1;
    if (target < 0) {
      setState(() {
        _index = -1;
        _selected = null;
      });
      return;
    }
    setState(() {
      _correctAnswers.remove(target);
      _correct = _correctAnswers.length;
      _index = target;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    if (_index < 0) {
      return Scaffold(
        appBar: AppBar(title: Text(lesson.title)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            _lessonHeader(context, lesson.level, '📖 Reading'),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SelectableText(
                  lesson.passage,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.55),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => _index = 0),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Answer questions'),
              ),
            ),
          ],
        ),
      );
    }
    if (_index >= lesson.questions.length) {
      final score = ((_correct / lesson.questions.length) * 100).round();
      return _CompletionScreen(
        title: 'Reading complete',
        score: score,
        passed: score >= 70,
        onSave: () async {
          final NavigatorState navigator = Navigator.of(context);
          await widget.controller.recordActivity(lesson.id, score: score);
          if (mounted) navigator.pop();
        },
        onPrevious: _previous,
      );
    }
    // Permuted before it is shown or graded. See lib/answer_shuffle.dart.
    final q = lesson.questions[_index].shuffled(
      seededFor(lesson.questions[_index].prompt, _shuffleSalt),
    );
    return _ChoiceQuizScaffold(
      title: '${lesson.level.label} Reading',
      progress: (_index + 1) / lesson.questions.length,
      question: q,
      selected: _selected,
      topAction: OutlinedButton.icon(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SelectableText(lesson.passage),
            ),
          ),
        ),
        icon: const Icon(Icons.article_outlined),
        label: const Text('View text'),
      ),
      onSelect: (choice) {
        if (_selected != null) return;
        setState(() {
          _selected = choice;
          if (choice == q.correctIndex) {
            _correctAnswers.add(_index);
            _correct = _correctAnswers.length;
          }
        });
        if (choice != q.correctIndex) {
          recordChoiceMistake(
            widget.controller,
            lessonId: lesson.id,
            level: lesson.level,
            source: 'reading',
            question: q,
            questionIndex: _index,
            choice: choice,
          );
        }
      },
      // No rule text: a comprehension question is not testing a rule, so
      // there is nothing to remind the learner of. lib/hints.dart falls back
      // to a structural hint -- where to look -- which the UI labels as the
      // weaker kind of help rather than dressing it up as a rule.
      ruleText: '',
      personalization: personalizationForQuestion(
        widget.controller.mistakes,
        '${lesson.id}-q$_index',
      ),
      onPrevious: _previous,
      onSkip: _selected != null
          ? null
          : () {
              widget.controller.recordSkip(
                id: '${lesson.id}-q$_index',
                prompt: q.prompt,
                correctAnswer: q.options[q.correctIndex],
                source: 'reading',
                level: lesson.level.label,
              );
              setState(() {
                _index += 1;
                _selected = null;
              });
            },
      onContinue: _selected == null
          ? null
          : () => setState(() {
              _index += 1;
              _selected = null;
            }),
    );
  }
}

class WritingListScreen extends StatelessWidget {
  const WritingListScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  Widget build(BuildContext context) {
    final lessons = writingFor(level).toList();
    return _LessonListScaffold(
      title: '${level.label} Writing',
      subtitle:
          'Draft responses offline, use a CEFR-scaled rubric, and save your best result.',
      children: lessons.map((lesson) {
        final p = controller.activities[lesson.id] ?? ActivityProgress();
        return _lessonTile(
          context,
          lesson.title,
          p,
          () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  WritingLessonScreen(controller: controller, lesson: lesson),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class WritingLessonScreen extends StatefulWidget {
  const WritingLessonScreen({
    super.key,
    required this.controller,
    required this.lesson,
  });

  final AppController controller;
  final WritingLesson lesson;

  @override
  State<WritingLessonScreen> createState() => _WritingLessonScreenState();
}

class _WritingLessonScreenState extends State<WritingLessonScreen> {
  late final TextEditingController _text;
  int? _score;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Writing · ${widget.lesson.title}');
    _text = TextEditingController(
      text: widget.controller.activities[widget.lesson.id]?.draft ?? '',
    );
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Writing · ${widget.lesson.title}');
    _text.dispose();
    super.dispose();
  }

  int get _wordCount => _text.text
      .trim()
      .split(RegExp(r'\s+'))
      .where((value) => value.isNotEmpty)
      .length;

  int _evaluate() {
    final lesson = widget.lesson;
    final lower = _text.text.toLowerCase();
    final lengthRatio = min<double>(1.0, _wordCount / lesson.minWords);
    final keywordHits = lesson.keywords
        .where((keyword) => lower.contains(keyword.toLowerCase()))
        .length;
    final keywordRatio = lesson.keywords.isEmpty
        ? 1.0
        : keywordHits / lesson.keywords.length;
    final sentenceCount = RegExp(
      r'[.!?](?:\s|$)',
    ).allMatches(_text.text).length;
    final expectedSentences = max(3, lesson.level.order + 3);
    final sentenceRatio = min<double>(1.0, sentenceCount / expectedSentences);
    final paragraphBonus = _text.text.trim().contains('\n') || _wordCount < 100
        ? 1.0
        : 0.75;
    return ((lengthRatio * 45) +
            (keywordRatio * 30) +
            (sentenceRatio * 15) +
            (paragraphBonus * 10))
        .round()
        .clamp(0, 100)
        .toInt();
  }

  Future<void> _saveAndEvaluate() async {
    await widget.controller.saveWritingDraft(widget.lesson.id, _text.text);
    final score = _evaluate();
    await widget.controller.recordActivity(widget.lesson.id, score: score);
    if (!mounted) return;
    setState(() => _score = score);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _lessonHeader(context, lesson.level, '✍️ Writing'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    lesson.prompt,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...lesson.guidance.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text('• $item'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Target: at least ${lesson.minWords} words'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _text,
            minLines: 12,
            maxLines: null,
            onChanged: (_) => setState(() => _score = null),
            decoration: InputDecoration(
              hintText: 'Write in German…',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text('$_wordCount / ${lesson.minWords} words'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _text.text.trim().isEmpty ? null : _saveAndEvaluate,
            icon: const Icon(Icons.fact_check_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Save & run offline rubric'),
            ),
          ),
          if (_score != null) ...<Widget>[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: <Widget>[
                    Text(
                      '$_score / 100',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _score! >= 70
                          ? 'Passed. This offline score checks length, target structures and basic response development.'
                          : 'Not passed yet. Expand the answer and use more of the requested structures.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ExpansionTile(
                      title: const Text('Show model answer'),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: SelectableText(lesson.example),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

/// Builds the screen that teaches one lesson, whichever track it belongs to.
///
/// The review queue holds lessons from all five tracks in one list, so it needs
/// a single way to open any of them. The cast is safe because
/// [LessonRef.skill] and [LessonRef.lesson] are populated together in
/// `lesson_registry.dart`.
Widget lessonScreenFor(AppController controller, LessonRef ref) {
  switch (ref.skill) {
    case SkillType.grammar:
      return GrammarLessonScreen(
        controller: controller,
        lesson: ref.lesson as GrammarLesson,
      );
    case SkillType.listening:
      return ListeningLessonScreen(
        controller: controller,
        lesson: ref.lesson as ListeningLesson,
      );
    case SkillType.reading:
      return ReadingLessonScreen(
        controller: controller,
        lesson: ref.lesson as ReadingLesson,
      );
    case SkillType.writing:
      return WritingLessonScreen(
        controller: controller,
        lesson: ref.lesson as WritingLesson,
      );
    case SkillType.speaking:
      return SpeakingLessonScreen(
        controller: controller,
        lesson: ref.lesson as SpeakingLesson,
      );
    case SkillType.vocabulary:
      // Vocabulary is scheduled per card by the review queue, not per lesson.
      return VocabularyLevelScreen(controller: controller, level: ref.level);
  }
}

class SpeakingListScreen extends StatelessWidget {
  const SpeakingListScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  Widget build(BuildContext context) {
    final lessons = speakingFor(level).toList();
    return _LessonListScaffold(
      title: '${level.label} Speaking',
      subtitle:
          'Guided speaking rehearsal with CEFR-scaled prompts, model language and transparent self-assessment.',
      children: lessons.map((lesson) {
        final p = controller.activities[lesson.id] ?? ActivityProgress();
        return _lessonTile(
          context,
          lesson.title,
          p,
          () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  SpeakingLessonScreen(controller: controller, lesson: lesson),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SpeakingLessonScreen extends StatefulWidget {
  const SpeakingLessonScreen({
    super.key,
    required this.controller,
    required this.lesson,
  });

  final AppController controller;
  final SpeakingLesson lesson;

  @override
  State<SpeakingLessonScreen> createState() => _SpeakingLessonScreenState();
}

class _SpeakingLessonScreenState extends State<SpeakingLessonScreen> {
  final TtsService _tts = TtsService();
  int? _lastScore;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Speaking · ${widget.lesson.title}');
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Speaking · ${widget.lesson.title}');
    _tts.stop();
    super.dispose();
  }

  Future<void> _score(int value) async {
    await widget.controller.recordActivity(widget.lesson.id, score: value);
    if (!mounted) return;
    setState(() => _lastScore = value);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _lessonHeader(context, lesson.level, '🗣️ Speaking'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    lesson.prompt,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Target: about ${lesson.targetSeconds} seconds'),
                  const SizedBox(height: 12),
                  ...lesson.guidance.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text('• $item'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text(
              'Model language',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            children: lesson.modelPhrases
                .map(
                  (phrase) => ListTile(
                    title: Text(phrase),
                    trailing: IconButton(
                      tooltip: 'Hear phrase',
                      icon: const Icon(Icons.volume_up_rounded),
                      onPressed: widget.controller.ttsEnabled
                          ? () => _tts.speakGerman(phrase)
                          : null,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          const Text(
            'After speaking aloud, assess this attempt:',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _score(45),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Text('Needs work — incomplete or hesitant'),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => _score(75),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Text('Task completed — understandable and structured'),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => _score(95),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 13),
              child: Text('Controlled & confident — precise and fluent'),
            ),
          ),
          if (_lastScore != null) ...<Widget>[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Saved self-assessment: $_lastScore%. Speaking is guided self-evaluation in this offline release; no microphone recording or automatic pronunciation certification is performed.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LessonListScaffold extends StatelessWidget {
  const _LessonListScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(subtitle),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

Widget _lessonTile(
  BuildContext context,
  String title,
  ActivityProgress progress,
  VoidCallback onTap,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: progress.completed
              ? const Icon(Icons.check_rounded)
              : Text('${progress.bestScore}%'),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(
          progress.attempts == 0
              ? 'Not attempted'
              : 'Best ${progress.bestScore}% • ${progress.attempts} attempt${progress.attempts == 1 ? '' : 's'}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    ),
  );
}

Widget _lessonHeader(BuildContext context, CefrLevel level, String text) {
  return Row(
    children: <Widget>[
      Chip(label: Text(level.label)),
      const SizedBox(width: 8),
      Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
      ),
    ],
  );
}

class _ChoiceQuizScaffold extends StatefulWidget {
  const _ChoiceQuizScaffold({
    required this.title,
    required this.progress,
    required this.question,
    required this.selected,
    required this.onSelect,
    required this.onContinue,
    this.topAction,
    this.ruleText = '',
    this.onSkip,
    this.onPrevious,
    this.personalization = const HintPersonalization(),
  });

  final String title;
  final double progress;
  final ChoiceQuestion question;
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback? onContinue;
  final Widget? topAction;

  /// What the lesson teaches, used as the hint. Empty falls back to a
  /// structural hint. See lib/hints.dart for why the explanation is not used.
  final String ruleText;

  /// Called when the learner declines to answer. Null hides the button.
  final VoidCallback? onSkip;

  /// Reopens the immediately preceding question. Null hides the button.
  final VoidCallback? onPrevious;

  /// Local learner history used to order and tailor progressive hints.
  final HintPersonalization personalization;

  @override
  State<_ChoiceQuizScaffold> createState() => _ChoiceQuizScaffoldState();
}

class _ChoiceQuizScaffoldState extends State<_ChoiceQuizScaffold> {
  int _hintStage = 0;

  @override
  void didUpdateWidget(_ChoiceQuizScaffold old) {
    super.didUpdateWidget(old);
    // A new question starts without the previous one's hint on screen.
    if (old.question.prompt != widget.question.prompt) _hintStage = 0;
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.title;
    final double progress = widget.progress;
    final ChoiceQuestion question = widget.question;
    final int? selected = widget.selected;
    final ValueChanged<int> onSelect = widget.onSelect;
    final VoidCallback? onContinue = widget.onContinue;
    final Widget? topAction = widget.topAction;
    final List<Hint> hints = hintsForChoice(
      question,
      ruleText: widget.ruleText,
      personalization: widget.personalization,
    );
    final Hint? hint = _hintStage <= 0 || hints.isEmpty
        ? null
        : hints[(_hintStage - 1).clamp(0, hints.length - 1)];
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            LinearProgressIndicator(value: progress, minHeight: 7),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  if (topAction != null) ...<Widget>[
                    Center(child: topAction),
                    const SizedBox(height: 16),
                  ],
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Text(
                        question.prompt,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List<Widget>.generate(question.options.length, (index) {
                    Color? background;
                    if (selected != null) {
                      if (index == question.correctIndex) {
                        background = Colors.green.withValues(alpha: 0.15);
                      } else if (index == selected) {
                        background = Colors.red.withValues(alpha: 0.15);
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: OutlinedButton(
                          onPressed: selected == null
                              ? () => onSelect(index)
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(question.options[index]),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (selected == null &&
                      (hints.isNotEmpty ||
                          widget.onSkip != null ||
                          widget.onPrevious != null)) ...<Widget>[
                    const SizedBox(height: 4),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 4,
                      spacing: 8,
                      children: <Widget>[
                        if (widget.onPrevious != null)
                          TextButton.icon(
                            onPressed: widget.onPrevious,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Previous'),
                          ),
                        if (hints.isNotEmpty)
                          TextButton.icon(
                            onPressed: _hintStage >= hints.length
                                ? null
                                : () => setState(() => _hintStage += 1),
                            icon: const Icon(Icons.lightbulb_outline_rounded),
                            label: Text(
                              _hintStage == 0 ? 'Hint' : 'Another hint',
                            ),
                          ),
                        if (widget.onSkip != null)
                          TextButton.icon(
                            onPressed: widget.onSkip,
                            icon: const Icon(Icons.skip_next_rounded),
                            label: const Text('Skip'),
                          ),
                      ],
                    ),
                  ],
                  if (selected == null && hint != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              switch (hint.kind) {
                                HintKind.rule => 'The rule',
                                HintKind.structural => 'Where to look',
                                HintKind.card => 'About this word',
                              },
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if (hint.personalized) ...<Widget>[
                              const SizedBox(height: 3),
                              Text(
                                'Based on your earlier practice',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(hint.text),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (selected != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(question.explanation),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: onContinue,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Continue'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionScreen extends StatelessWidget {
  const _CompletionScreen({
    required this.title,
    required this.score,
    required this.passed,
    required this.onSave,
    this.onPrevious,
  });

  final String title;
  final int score;
  final bool passed;
  final Future<void> Function() onSave;
  final VoidCallback? onPrevious;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    passed ? '🎉' : '🌱',
                    style: const TextStyle(fontSize: 56),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$score%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    passed
                        ? 'Passed — your best score will count toward level progression.'
                        : 'You need 70% to complete this lesson. Save this attempt and try again.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: onSave,
                    child: const Text('Save result'),
                  ),
                  if (onPrevious != null) ...<Widget>[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: onPrevious,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Review previous question'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Files a wrong multiple-choice answer in the mistake bank so it can be
/// drilled later. Shared by the grammar, listening and reading quizzes.
void recordChoiceMistake(
  AppController controller, {
  required String lessonId,
  required CefrLevel level,
  required String source,
  required ChoiceQuestion question,
  required int questionIndex,
  required int choice,
}) {
  controller.addMistake(
    MistakeEntry(
      id: '$lessonId-q$questionIndex',
      prompt: question.prompt,
      correctAnswer: question.options[question.correctIndex],
      givenAnswer: question.options[choice],
      source: source,
      level: level.label,
      timestamp: DateTime.now(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Searchable Grammar Handbook
// ---------------------------------------------------------------------------

class GrammarHandbookScreen extends StatefulWidget {
  const GrammarHandbookScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<GrammarHandbookScreen> createState() => _GrammarHandbookScreenState();
}

class _GrammarHandbookScreenState extends State<GrammarHandbookScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLevel = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<GrammarLesson> allLessons = CefrLevel.values
        .expand((level) => grammarFor(level))
        .toList();

    final String query = _searchController.text.trim().toLowerCase();
    final List<GrammarLesson> filtered = allLessons.where((lesson) {
      final matchesLevel =
          _selectedLevel == 'ALL' || lesson.level.label == _selectedLevel;
      final matchesQuery =
          query.isEmpty ||
          lesson.title.toLowerCase().contains(query) ||
          lesson.explanation.toLowerCase().contains(query) ||
          lesson.examples.any((e) => e.toLowerCase().contains(query));
      return matchesLevel && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Handbook')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText:
                    'Search grammar topics (e.g. passive, weil, modal)...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                isDense: true,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <String>['ALL', ...CefrLevel.values.map((l) => l.label)]
                  .map((lvl) {
                    final isSelected = _selectedLevel == lvl;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(lvl),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedLevel = lvl),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No matching grammar lessons found.'),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final lesson = filtered[index];
                      final p =
                          widget.controller.activities[lesson.id] ??
                          ActivityProgress();
                      return Card(
                        child: ListTile(
                          title: Row(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  lesson.level.label,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  lesson.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              lesson.explanation,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: Icon(
                            p.completed
                                ? Icons.check_circle_rounded
                                : Icons.chevron_right_rounded,
                            color: p.completed ? Colors.green : null,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => GrammarLessonScreen(
                                controller: widget.controller,
                                lesson: lesson,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
