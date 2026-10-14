import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app_state.dart';
import 'l10n/app_localizations.dart';
import 'learning_path_text.dart';
import 'feedback_text.dart';
import 'curriculum.dart';
import 'curriculum_meta.dart';
import 'dialogue_audio.dart';
import 'grammar_tables.dart';
import 'lesson_registry.dart';
import 'long_form_audio_player.dart';
import 'models.dart';
import 'platform_support.dart';
import 'sentence_audio.dart';
import 'speaking_evaluation.dart';
import 'writing_evaluation.dart';
import 'speech_service.dart';
import 'vocab_icon.dart';
import 'study_session.dart';
import 'tts_service.dart';
import 'voice_recorder.dart';
import 'vocabulary_metadata.dart';
import 'vocabulary_search.dart';
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
      appBar: AppBar(title: Text(AppText.of(context).germanLevel(level.label))),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              levelDescription(AppText.of(context), level),
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
              AppText.of(
                context,
              ).overallMastery((controller.levelProgress(level) * 100).round()),
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
                                  skillText(AppText.of(context), skill),
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
                        ? AppText.of(
                            context,
                          ).nextLevelUnlocked(level.next!.label)
                        : AppText.of(context).unlockLevelRule(
                            level.label,
                            level.next!.label,
                            (AppController.levelUnlockThreshold * 100).round(),
                          ),
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
      appBar: AppBar(
        title: Text(
          AppText.of(context).levelSkillTitle(
            widget.level.label,
            AppText.of(context).skillVocabulary,
          ),
        ),
      ),
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
            final matchesQuery = vocabularyMatchesQuery(
              word,
              query,
              meaning: widget.controller.meaningOf(word),
            );
            return matchesArticle && matchesQuery;
          }).toList();

          // The header is a handful of widgets and is cheap to build eagerly.
          // The card list is not: a level holds up to 212 words and this
          // rebuilds on every keystroke in the search field, so it goes
          // through a builder and only materialises what is on screen.
          final List<Widget> header = <Widget>[
            _summaryCard(
              context,
              AppText.of(context).trainingCardCount(words.length),
              AppText.of(context).vocabLevelProgress(
                due,
                widget.level.label,
                mastered,
                seen,
                coverageFor(widget.level).lexicalBreadthTarget,
              ),
              widget.controller.skillProgress(
                widget.level,
                SkillType.vocabulary,
              ),
            ),
            const SizedBox(height: 16),
            _action(
              context,
              '🌱',
              AppText.of(context).learnNewWords,
              AppText.of(context).learnWordsBody(widget.level.label),
              () => _session(context, SessionKind.learn),
            ),
            const SizedBox(height: 10),
            _action(
              context,
              '🧠',
              AppText.of(context).smartReview,
              AppText.of(context).levelWordsDue(due, widget.level.label),
              () => _session(context, SessionKind.review),
            ),
            const SizedBox(height: 10),
            _action(
              context,
              '⚡',
              AppText.of(context).mixedPractice,
              AppText.of(context).mixedPracticeBody,
              () => _session(context, SessionKind.practice),
            ),
            const SizedBox(height: 24),
            Text(
              AppText.of(
                context,
              ).vocabularyBankCount(filteredWords.length, words.length),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: AppText.of(context).searchVocabulary,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: AppText.of(context).clearSearch,
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
                  final label = art == 'all'
                      ? AppText.of(context).allArticles
                      : art;
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
                  subtitle: Text(
                    '${widget.controller.meaningOf(word)} · ${word.grammarLabel}',
                  ),
                  trailing: IconButton(
                    tooltip: p.favorite
                        ? AppText.of(context).removeWordFavorite(word.german)
                        : AppText.of(context).addWordFavorite(word.german),
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
      title: AppText.of(
        context,
      ).levelSkillTitle(level.label, AppText.of(context).skillGrammar),
      subtitle: AppText.of(context).grammarListBody,
      actions: <Widget>[
        IconButton(
          tooltip: AppText.of(context).grammarTablesTitle,
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
          tooltip: AppText.of(context).grammarHandbook,
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
            _lessonHeader(
              context,
              lesson.level,
              '🧩 ${AppText.of(context).skillGrammar}',
            ),
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
              AppText.of(context).examplesTitle,
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
                      AppText.of(context).referenceTable,
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
                    label: Text(AppText.of(context).allTables),
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
              label: Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(AppText.of(context).startQuiz),
              ),
            ),
          ],
        ),
      );
    }
    if (_index >= lesson.questions.length) {
      final score = ((_correct / lesson.questions.length) * 100).round();
      return _CompletionScreen(
        title: AppText.of(
          context,
        ).skillComplete(AppText.of(context).skillGrammar),
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
      title: AppText.of(
        context,
      ).levelSkillTitle(lesson.level.label, AppText.of(context).skillGrammar),
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
      title: AppText.of(
        context,
      ).levelSkillTitle(level.label, AppText.of(context).skillListening),
      subtitle: AppText.of(context).listeningListBody,
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
    super.dispose();
  }

  Widget _audioPlayer() => LongFormAudioPlayer(
    programmeId: 'listening-${widget.lesson.id}',
    turns: labelledDialogueTurns(widget.lesson.transcript.split('\n')),
    playLabel: AppText.of(context).playGermanAudio,
    enabled: widget.controller.ttsEnabled,
  );

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    if (_index < 0) {
      return Scaffold(
        appBar: AppBar(title: Text(lesson.title)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            _lessonHeader(
              context,
              lesson.level,
              '🎧 ${AppText.of(context).skillListening}',
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.headphones_rounded, size: 64),
                    const SizedBox(height: 12),
                    Text(
                      AppText.of(context).listenTwice,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    _audioPlayer(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () =>
                  setState(() => _showTranscript = !_showTranscript),
              child: Text(
                _showTranscript
                    ? AppText.of(context).hideTranscript
                    : AppText.of(context).revealTranscript,
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
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(AppText.of(context).startComprehension),
              ),
            ),
          ],
        ),
      );
    }
    if (_index >= lesson.questions.length) {
      final score = ((_correct / lesson.questions.length) * 100).round();
      return _CompletionScreen(
        title: AppText.of(
          context,
        ).skillComplete(AppText.of(context).skillListening),
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
      title: AppText.of(
        context,
      ).levelSkillTitle(lesson.level.label, AppText.of(context).skillListening),
      progress: (_index + 1) / lesson.questions.length,
      question: q,
      selected: _selected,
      topAction: _audioPlayer(),
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
      title: AppText.of(
        context,
      ).levelSkillTitle(level.label, AppText.of(context).skillReading),
      subtitle: AppText.of(context).readingListBody,
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
            _lessonHeader(
              context,
              lesson.level,
              '📖 ${AppText.of(context).skillReading}',
            ),
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
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(AppText.of(context).answerQuestions),
              ),
            ),
          ],
        ),
      );
    }
    if (_index >= lesson.questions.length) {
      final score = ((_correct / lesson.questions.length) * 100).round();
      return _CompletionScreen(
        title: AppText.of(
          context,
        ).skillComplete(AppText.of(context).skillReading),
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
      title: AppText.of(
        context,
      ).levelSkillTitle(lesson.level.label, AppText.of(context).skillReading),
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
        label: Text(AppText.of(context).viewText),
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
      title: AppText.of(
        context,
      ).levelSkillTitle(level.label, AppText.of(context).skillWriting),
      subtitle: AppText.of(context).writingListBody,
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
  late String _draftText;
  WritingAttemptEvaluation? _evaluation;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Writing · ${widget.lesson.title}');
    _text = TextEditingController(
      text: widget.controller.activities[widget.lesson.id]?.draft ?? '',
    );
    _draftText = _text.text;
    _text.addListener(_saveDraft);
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Writing · ${widget.lesson.title}');
    _text.dispose();
    super.dispose();
  }

  void _saveDraft() {
    if (_text.text == _draftText) return;
    _draftText = _text.text;
    // AppController coalesces writes and flushes on backgrounding. Saving a
    // draft never grades the task or advances the learning path.
    unawaited(widget.controller.saveWritingDraft(widget.lesson.id, _draftText));
    setState(() => _evaluation = null);
  }

  int get _wordCount => WritingEvaluator.wordCount(_text.text);

  Future<void> _saveAndEvaluate() async {
    if (_saving || _wordCount == 0) return;
    final String draft = _text.text;
    final WritingAttemptEvaluation eval = WritingEvaluator.evaluate(
      widget.lesson,
      draft,
    );
    setState(() => _saving = true);
    try {
      await widget.controller.saveWritingDraft(widget.lesson.id, draft);
      await widget.controller.recordActivity(
        widget.lesson.id,
        score: eval.score,
      );
      if (mounted) setState(() => _evaluation = eval);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _lessonHeader(
            context,
            lesson.level,
            '✍️ ${AppText.of(context).skillWriting}',
          ),
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
                  Text(AppText.of(context).targetWordCount(lesson.minWords)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _text,
            minLines: 12,
            maxLines: null,
            enabled: !_saving,
            decoration: InputDecoration(
              hintText: AppText.of(context).writeGermanHint,
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              AppText.of(
                context,
              ).writingDraftCounter(_wordCount, lesson.minWords),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving || _wordCount == 0 ? null : _saveAndEvaluate,
            icon: const Icon(Icons.fact_check_outlined),
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                _saving
                    ? AppText.of(context).savingAction
                    : AppText.of(context).evaluateWriting,
              ),
            ),
          ),
          if (_evaluation case final result?) ...<Widget>[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12,
                      runSpacing: 8,
                      children: <Widget>[
                        Text(
                          '${result.score}%',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: result.passed
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Wrap(
                            spacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Icon(
                                result.passed
                                    ? Icons.check_circle_rounded
                                    : Icons.edit_note_rounded,
                                size: 18,
                                color: result.passed
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800,
                              ),
                              Text(
                                result.passed
                                    ? AppText.of(context).passedLabel
                                    : AppText.of(context).revisionNeeded,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: result.passed
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.passed
                          ? AppText.of(context).writingEvaluationBody
                          : AppText.of(context).writingRevisionBody,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Divider(height: 24),
                    Text(
                      AppText.of(context).diagnosticBreakdown,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _rubricRow(
                      context,
                      AppText.of(context).taskLengthLabel,
                      AppText.of(
                        context,
                      ).wordCountProgress(result.wordCount, result.targetWords),
                      result.taskScore,
                    ),
                    const SizedBox(height: 6),
                    _rubricRow(
                      context,
                      AppText.of(context).keyVocabularyLabel,
                      AppText.of(context).usedCountProgress(
                        result.matchedKeywords.length,
                        result.matchedKeywords.length +
                            result.missingKeywords.length,
                      ),
                      result.vocabScore,
                    ),
                    const SizedBox(height: 6),
                    _rubricRow(
                      context,
                      AppText.of(context).cohesionLabel,
                      AppText.of(
                        context,
                      ).connectorCount(result.connectorsUsed.length),
                      result.cohesionScore,
                    ),
                    const SizedBox(height: 6),
                    _rubricRow(
                      context,
                      AppText.of(context).mechanicsLabel,
                      result.capitalizationErrors.isEmpty &&
                              result.sentenceCapitalizationErrors == 0
                          ? AppText.of(context).cleanOrthography
                          : AppText.of(context).writingAlertCount(
                              result.capitalizationErrors.length +
                                  result.sentenceCapitalizationErrors,
                            ),
                      result.mechanicsScore,
                    ),
                    if (lesson.keywords.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 14),
                      Text(
                        AppText.of(context).targetStructures,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          ...result.matchedKeywords.map(
                            (kw) => Chip(
                              visualDensity: VisualDensity.compact,
                              backgroundColor: Colors.green.withValues(
                                alpha: 0.12,
                              ),
                              avatar: const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.green,
                              ),
                              label: Text(kw),
                            ),
                          ),
                          ...result.missingKeywords.map(
                            (kw) => Chip(
                              visualDensity: VisualDensity.compact,
                              backgroundColor: Colors.orange.withValues(
                                alpha: 0.12,
                              ),
                              avatar: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.orange,
                              ),
                              label: Text(
                                AppText.of(context).missingStructure(kw),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (result.connectorsUsed.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 10),
                      Text(
                        AppText.of(
                          context,
                        ).connectorsDetected(result.connectorsUsed.join(', ')),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                    const Divider(height: 24),
                    Text(
                      AppText.of(context).coachingTips,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...feedbackTexts(
                      AppText.of(context),
                      result.feedback,
                      result.tips,
                    ).map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $tip'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExpansionTile(
                      title: Text(AppText.of(context).showModelAnswer),
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

  Widget _rubricRow(
    BuildContext context,
    String label,
    String value,
    int score,
  ) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$score%',
          textAlign: TextAlign.end,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: score >= 70 ? Colors.green.shade700 : Colors.orange.shade700,
          ),
        ),
      ],
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

enum _SpeakingStatus {
  none,
  finishing,
  listening,
  pause,
  evaluating,
  localListening,
  transcribing,
  failed,
  empty,
  saved,
}

String _speakingStatusText(AppText t, _SpeakingStatus status) =>
    switch (status) {
      _SpeakingStatus.none => '',
      _SpeakingStatus.finishing => t.finishingTranscript,
      _SpeakingStatus.listening => t.listeningStatus,
      _SpeakingStatus.pause => t.listeningPauseStatus,
      _SpeakingStatus.evaluating => t.evaluatingTranscript,
      _SpeakingStatus.localListening => t.listeningLocalStatus,
      _SpeakingStatus.transcribing => t.transcribingLocalStatus,
      _SpeakingStatus.failed => t.transcriptionFailedBody,
      _SpeakingStatus.empty => t.noRecognizedWords,
      _SpeakingStatus.saved => t.attemptSaved,
    };

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
      title: AppText.of(
        context,
      ).levelSkillTitle(level.label, AppText.of(context).skillSpeaking),
      subtitle: AppText.of(context).speakingListBody,
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
  final SpeechService _speech = SpeechService();
  final VoiceRecorder _recorder = VoiceRecorder();
  late final TextEditingController _transcript;
  late String _draftTranscript;

  SpeakingAttemptEvaluation? _evaluation;
  bool _listening = false;
  bool _processing = false;
  bool _finishing = false;
  bool _evaluating = false;
  bool _starting = false;
  DateTime? _startedAt;
  Duration? _attemptDuration;
  _SpeakingStatus _status = _SpeakingStatus.none;

  bool get _useRecordedRecognizer => widget.controller.asrUsable;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Speaking · ${widget.lesson.title}');
    _transcript = TextEditingController(
      text: widget.controller.activities[widget.lesson.id]?.draft ?? '',
    );
    _draftTranscript = _transcript.text;
    _transcript.addListener(_saveTranscriptDraft);
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Speaking · ${widget.lesson.title}');
    _transcript.dispose();
    _tts.stop();
    _speech.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Duration get _maximumAttempt =>
      Duration(seconds: min(widget.lesson.targetSeconds + 45, 10 * 60));

  void _saveTranscriptDraft() {
    if (_transcript.text == _draftTranscript) return;
    _draftTranscript = _transcript.text;
    unawaited(
      widget.controller.saveWritingDraft(widget.lesson.id, _draftTranscript),
    );
    setState(() => _evaluation = null);
  }

  Future<void> _toggleSpeech() async {
    if (_processing || _starting) return;
    if (_listening) {
      if (_useRecordedRecognizer) {
        await _finishRecordedAttempt();
      } else {
        await _speech.stop();
      }
      return;
    }

    setState(() => _starting = true);
    try {
      if (_useRecordedRecognizer) {
        await _startRecordedAttempt();
        return;
      }
      if (!PlatformSupport.hasSpeechRecognition) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppText.of(
                context,
              ).speakingModelSuggestion(PlatformSupport.speechRecognitionNote),
            ),
          ),
        );
        return;
      }
      await _startSystemAttempt();
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _startSystemAttempt() async {
    bool receivedTranscript = false;
    final bool started = await _speech.listen(
      listenFor: _maximumAttempt,
      pauseFor: const Duration(seconds: 5),
      onTranscript: (String words, bool isFinal) {
        if (!mounted) return;
        receivedTranscript = true;
        setState(() {
          _transcript.text = words;
          _status = isFinal
              ? _SpeakingStatus.finishing
              : _SpeakingStatus.listening;
        });
      },
      onDone: () => unawaited(_finishSystemAttempt()),
    );
    if (!mounted) return;
    if (!started) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_speech.unavailableReason)));
      return;
    }
    setState(() {
      // Permission failure must leave a typed draft intact. Only discard it
      // once a new recording actually starts, without dropping early results.
      if (!receivedTranscript) _transcript.clear();
      _evaluation = null;
      _startedAt = DateTime.now();
      _attemptDuration = null;
      _listening = true;
      _status = _SpeakingStatus.pause;
    });
  }

  Future<void> _finishSystemAttempt() async {
    if (_finishing || !_listening) return;
    _finishing = true;
    if (mounted) {
      setState(() {
        _listening = false;
        _processing = true;
        _status = _SpeakingStatus.evaluating;
      });
    }
    try {
      await _evaluateTranscript();
    } finally {
      _finishing = false;
    }
  }

  Future<void> _startRecordedAttempt() async {
    final directory = await getApplicationSupportDirectory();
    final bool started = await _recorder.start(
      '${directory.path}/speaking',
      trailingSilence: const Duration(seconds: 2),
      noSpeechTimeout: const Duration(seconds: 12),
      maximumDuration: _maximumAttempt,
      onSpeechEnd: (_) => unawaited(_finishRecordedAttempt()),
    );
    if (!mounted) return;
    if (!started) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_recorder.unavailableReason)));
      return;
    }
    setState(() {
      _transcript.clear();
      _evaluation = null;
      _startedAt = DateTime.now();
      _attemptDuration = null;
      _listening = true;
      _status = _SpeakingStatus.localListening;
    });
  }

  Future<void> _finishRecordedAttempt() async {
    if (_finishing || !_listening) return;
    _finishing = true;
    if (mounted) {
      setState(() {
        _listening = false;
        _processing = true;
        _status = _SpeakingStatus.transcribing;
      });
    }
    try {
      final String? clip = await _recorder.stop();
      String words = '';
      if (clip != null) {
        try {
          words = await widget.controller.transcribeRecording(clip);
        } finally {
          await _recorder.deleteRecording(clip);
        }
      }
      if (mounted && words.isNotEmpty) {
        setState(() => _transcript.text = words);
      }
      await _evaluateTranscript();
    } catch (error) {
      debugPrint('speaking transcription failed: $error');
      if (mounted) {
        setState(() {
          _status = _SpeakingStatus.failed;
        });
      }
    } finally {
      _finishing = false;
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _evaluateTranscript() async {
    if (!mounted || _evaluating) return;
    final String words = _transcript.text.trim();
    final DateTime? started = _startedAt;
    final Duration elapsed = started == null
        ? Duration.zero
        : DateTime.now().difference(started);
    if (words.isEmpty) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _status = _SpeakingStatus.empty;
      });
      return;
    }
    final SpeakingAttemptEvaluation result = SpeakingEvaluator.evaluate(
      widget.lesson,
      words,
    );
    setState(() {
      _evaluating = true;
      _processing = true;
    });
    try {
      await widget.controller.recordActivity(
        widget.lesson.id,
        score: result.score,
      );
      if (mounted) {
        setState(() {
          _evaluation = result;
          _attemptDuration = elapsed;
          _status = _SpeakingStatus.saved;
        });
      }
    } finally {
      _evaluating = false;
      if (mounted) setState(() => _processing = false);
    }
  }

  void _tryAgain() {
    setState(() {
      _transcript.clear();
      _evaluation = null;
      _status = _SpeakingStatus.none;
      _startedAt = null;
      _attemptDuration = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _lessonHeader(
            context,
            lesson.level,
            '🗣️ ${AppText.of(context).skillSpeaking}',
          ),
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
                  Text(AppText.of(context).targetSeconds(lesson.targetSeconds)),
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
            title: Text(
              AppText.of(context).modelLanguage,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            children: lesson.modelPhrases
                .map(
                  (phrase) => ListTile(
                    title: Text(phrase),
                    trailing: IconButton(
                      tooltip: AppText.of(context).hearPhrase,
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    AppText.of(context).automaticSpeakingCheck,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _useRecordedRecognizer
                        ? AppText.of(context).localRecognizerBody
                        : AppText.of(context).systemRecognizerBody,
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _processing || _starting ? null : _toggleSpeech,
                    icon: _processing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _listening ? Icons.stop_rounded : Icons.mic_rounded,
                          ),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _processing
                            ? AppText.of(context).transcribingAction
                            : _listening
                            ? AppText.of(context).finishNow
                            : AppText.of(context).startSpeaking,
                      ),
                    ),
                  ),
                  if (_listening) ...<Widget>[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(),
                  ],
                  if (_status != _SpeakingStatus.none) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      _speakingStatusText(AppText.of(context), _status),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextField(
                    controller: _transcript,
                    minLines: 3,
                    maxLines: 8,
                    enabled: !_listening && !_processing && !_starting,
                    decoration: InputDecoration(
                      labelText: AppText.of(context).transcriptOrTyped,
                      hintText: AppText.of(context).germanAnswerHint,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {
                      _startedAt = null;
                      _attemptDuration = null;
                      _status = _SpeakingStatus.none;
                    }),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed:
                        _listening ||
                            _starting ||
                            _processing ||
                            _transcript.text.trim().isEmpty
                        ? null
                        : _evaluateTranscript,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: Text(AppText.of(context).checkTranscript),
                  ),
                ],
              ),
            ),
          ),
          if (_evaluation case final result?) ...<Widget>[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${result.score}%',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      AppText.of(context).speakingProgress(
                        result.phrasesCovered,
                        result.targetWords,
                        result.totalPhrases,
                        result.wordCount,
                      ),
                    ),
                    if (_attemptDuration case final elapsed?) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        AppText.of(context).attemptTime(
                          '${elapsed.inMinutes}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                        ),
                      ),
                    ],
                    if (result.connectors.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        AppText.of(
                          context,
                        ).connectorList(result.connectors.join(', ')),
                      ),
                    ],
                    const SizedBox(height: 10),
                    ...feedbackTexts(
                      AppText.of(context),
                      result.feedback,
                      result.tips,
                    ).map(
                      (String tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $tip'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppText.of(context).transcriptFeedbackNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _tryAgain,
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(AppText.of(context).tryAgain),
                    ),
                  ],
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
              ? AppText.of(context).notAttempted
              : AppText.of(
                  context,
                ).lessonBestAttempts(progress.attempts, progress.bestScore),
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
      Expanded(
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
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
                            label: Text(AppText.of(context).previousAction),
                          ),
                        if (hints.isNotEmpty)
                          TextButton.icon(
                            onPressed: _hintStage >= hints.length
                                ? null
                                : () => setState(() => _hintStage += 1),
                            icon: const Icon(Icons.lightbulb_outline_rounded),
                            label: Text(
                              _hintStage == 0
                                  ? AppText.of(context).hintAction
                                  : AppText.of(context).anotherHint,
                            ),
                          ),
                        if (widget.onSkip != null)
                          TextButton.icon(
                            onPressed: widget.onSkip,
                            icon: const Icon(Icons.skip_next_rounded),
                            label: Text(AppText.of(context).actionSkip),
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
                                HintKind.rule => AppText.of(context).hintRule,
                                HintKind.structural => AppText.of(
                                  context,
                                ).hintStructural,
                                HintKind.card => AppText.of(context).hintCard,
                              },
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if (hint.personalized) ...<Widget>[
                              const SizedBox(height: 3),
                              Text(
                                AppText.of(context).hintPersonalized,
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
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(AppText.of(context).continueAction),
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

class _CompletionScreen extends StatefulWidget {
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
  State<_CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<_CompletionScreen> {
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSave();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.title;
    final int score = widget.score;
    final bool passed = widget.passed;
    final VoidCallback? onPrevious = widget.onPrevious;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(title)),
      body: SingleChildScrollView(
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
                        ? AppText.of(context).lessonPassedBody
                        : AppText.of(context).lessonFailedBody,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(
                      _saving
                          ? AppText.of(context).savingAction
                          : AppText.of(context).saveResult,
                    ),
                  ),
                  if (onPrevious != null) ...<Widget>[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _saving ? null : onPrevious,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: Text(AppText.of(context).reviewPreviousQuestion),
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
      appBar: AppBar(title: Text(AppText.of(context).grammarHandbook)),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: AppText.of(context).grammarSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: AppText.of(context).clearSearch,
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
                        label: Text(
                          lvl == 'ALL' ? AppText.of(context).allLevels : lvl,
                        ),
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
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(AppText.of(context).noGrammarResults),
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
