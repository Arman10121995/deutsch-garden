import 'dart:math';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'curriculum.dart';
import 'curriculum_meta.dart';
import 'models.dart';
import 'study_session.dart';
import 'tts_service.dart';

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
                          Text(skill.emoji, style: const TextStyle(fontSize: 36)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  skill.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
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

class VocabularyLevelScreen extends StatelessWidget {
  const VocabularyLevelScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  void _session(BuildContext context, SessionKind kind) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => StudySessionScreen(
          controller: controller,
          kind: kind,
          level: level,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${level.label} Vocabulary')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final words = controller.wordsForLevel(level);
          final seen = words
              .where((word) => controller.progress[word.id]?.seen ?? false)
              .length;
          final mastered = words
              .where((word) => controller.progress[word.id]?.mastered ?? false)
              .length;
          final due = controller.reviewWordsForLevel(level).length;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              _summaryCard(
                context,
                '${words.length} bundled training cards',
                '$seen learned • $mastered mastered • $due due\n'
                'Internal cumulative breadth target by ${level.label}: ~${coverageFor(level).lexicalBreadthTarget} lexical units (planning target, not an official CEFR word count).',
                controller.skillProgress(level, SkillType.vocabulary),
              ),
              const SizedBox(height: 16),
              _action(
                context,
                '🌱',
                'Learn new words',
                'Introduce up to 10 new ${level.label} words with pronunciation and examples.',
                () => _session(context, SessionKind.learn),
              ),
              const SizedBox(height: 10),
              _action(
                context,
                '🧠',
                'Smart review',
                due == 0
                    ? 'No ${level.label} words are due right now.'
                    : '$due ${level.label} words are due now.',
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
            ],
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
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900)),
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
      subtitle: 'Learn the rule, inspect examples, then pass the quiz with 70%.',
      children: lessons.map((lesson) {
        final p = controller.activities[lesson.id] ?? ActivityProgress();
        return _lessonTile(
          context,
          lesson.title,
          p,
          () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => GrammarLessonScreen(
                controller: controller,
                lesson: lesson,
              ),
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
  int _index = -1;
  int _correct = 0;
  int? _selected;

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
                child: Text(lesson.explanation,
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
            ),
            const SizedBox(height: 14),
            Text('Examples',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            ...lesson.examples.map(
              (example) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(example,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
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
          await widget.controller.recordActivity(lesson.id, score: score);
          if (mounted) Navigator.pop(context);
        },
      );
    }
    final q = lesson.questions[_index];
    return _ChoiceQuizScaffold(
      title: '${lesson.level.label} Grammar',
      progress: (_index + 1) / lesson.questions.length,
      question: q,
      selected: _selected,
      onSelect: (choice) {
        if (_selected != null) return;
        setState(() {
          _selected = choice;
          if (choice == q.correctIndex) _correct += 1;
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
      subtitle: 'Listen to native-device German TTS, then answer comprehension questions.',
      children: lessons.map((lesson) {
        final p = controller.activities[lesson.id] ?? ActivityProgress();
        return _lessonTile(
          context,
          lesson.title,
          p,
          () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ListeningLessonScreen(
                controller: controller,
                lesson: lesson,
              ),
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
  final TtsService _tts = TtsService();
  int _index = -1;
  int _correct = 0;
  int? _selected;
  bool _showTranscript = false;

  @override
  void dispose() {
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
              onPressed: () => setState(() => _showTranscript = !_showTranscript),
              child: Text(_showTranscript ? 'Hide transcript' : 'Reveal transcript'),
            ),
            if (_showTranscript) ...<Widget>[
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(lesson.transcript,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
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
          await widget.controller.recordActivity(lesson.id, score: score);
          if (mounted) Navigator.pop(context);
        },
      );
    }
    final q = lesson.questions[_index];
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
          if (choice == q.correctIndex) _correct += 1;
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
      subtitle: 'Read increasingly complex German texts and answer comprehension questions.',
      children: lessons.map((lesson) {
        final p = controller.activities[lesson.id] ?? ActivityProgress();
        return _lessonTile(
          context,
          lesson.title,
          p,
          () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ReadingLessonScreen(
                controller: controller,
                lesson: lesson,
              ),
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
  int _index = -1;
  int _correct = 0;
  int? _selected;

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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.55,
                      ),
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
          await widget.controller.recordActivity(lesson.id, score: score);
          if (mounted) Navigator.pop(context);
        },
      );
    }
    final q = lesson.questions[_index];
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
          if (choice == q.correctIndex) _correct += 1;
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
      subtitle: 'Draft responses offline, use a CEFR-scaled rubric, and save your best result.',
      children: lessons.map((lesson) {
        final p = controller.activities[lesson.id] ?? ActivityProgress();
        return _lessonTile(
          context,
          lesson.title,
          p,
          () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => WritingLessonScreen(
                controller: controller,
                lesson: lesson,
              ),
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
    _text = TextEditingController(
      text: widget.controller.activities[widget.lesson.id]?.draft ?? '',
    );
  }

  @override
  void dispose() {
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
    final sentenceCount = RegExp(r'[.!?](?:\s|$)').allMatches(_text.text).length;
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
                  Text(lesson.prompt,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900)),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
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
              builder: (_) => SpeakingLessonScreen(
                controller: controller,
                lesson: lesson,
              ),
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
  void dispose() {
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
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text('Target: about ${lesson.targetSeconds} seconds'),
                  const SizedBox(height: 12),
                  ...lesson.guidance.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text('• $item'),
                      )),
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
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
      Text(text,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w900)),
    ],
  );
}

class _ChoiceQuizScaffold extends StatelessWidget {
  const _ChoiceQuizScaffold({
    required this.title,
    required this.progress,
    required this.question,
    required this.selected,
    required this.onSelect,
    required this.onContinue,
    this.topAction,
  });

  final String title;
  final double progress;
  final ChoiceQuestion question;
  final int? selected;
  final ValueChanged<int> onSelect;
  final VoidCallback? onContinue;
  final Widget? topAction;

  @override
  Widget build(BuildContext context) {
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
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
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
                          onPressed: selected == null ? () => onSelect(index) : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(question.options[index]),
                          ),
                        ),
                      ),
                    );
                  }),
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
  });

  final String title;
  final int score;
  final bool passed;
  final Future<void> Function() onSave;

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
                  Text(passed ? '🎉' : '🌱', style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text('$score%',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.w900)),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
