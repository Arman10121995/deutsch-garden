import 'package:flutter/material.dart';

import 'app_state.dart';
import 'mini_story.dart';
import 'models.dart';
import 'hints.dart';
import 'practice_aids.dart';
import 'stories.dart';
import 'tts_service.dart';
import 'dart:math';
import 'answer_shuffle.dart';

class MiniStoryDrillScreen extends StatefulWidget {
  const MiniStoryDrillScreen({
    super.key,
    required this.controller,
    required this.drill,
  });

  final AppController controller;
  final MiniStoryDrill drill;

  @override
  State<MiniStoryDrillScreen> createState() => _MiniStoryDrillScreenState();
}

class _MiniStoryDrillScreenState extends State<MiniStoryDrillScreen> {
  final TtsService _tts = TtsService();
  bool _showTranscript = false;
  int _index = 0;
  int _correct = 0;
  int? _picked;
  bool _quizDone = false;
  final Set<int> _correctAnswers = <int>{};

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      'Mini-story · ${widget.drill.story.title}',
    );
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity(
      'Mini-story · ${widget.drill.story.title}',
    );
    _tts.stop();
    super.dispose();
  }

  Future<void> _listen() => _tts.speakTurns(widget.drill.spokenTurns);

  /// Fixed once per sitting, so the option order is stable while a question is
  /// on screen and different next time. See lib/answer_shuffle.dart.
  final int _shuffleSalt = Random().nextInt(0x7fffffff);

  ChoiceQuestion get _shuffledQuestion {
    final ChoiceQuestion raw = widget.drill.questions[_index];
    return raw.shuffled(seededFor(raw.prompt, _shuffleSalt));
  }

  Future<void> _pick(int index) async {
    if (_picked != null || _quizDone) return;
    final ChoiceQuestion question = _shuffledQuestion;
    final bool right = index == question.correctIndex;
    setState(() {
      _picked = index;
      if (right) {
        _correctAnswers.add(_index);
      } else {
        _correctAnswers.remove(_index);
      }
      _correct = _correctAnswers.length;
    });
    if (!right) {
      await widget.controller.addMistake(
        MistakeEntry(
          id: '${widget.drill.id}-q$_index',
          prompt: question.prompt,
          correctAnswer: question.options[question.correctIndex],
          givenAnswer: question.options[index],
          source: 'mini-story',
          level: widget.drill.story.level.label,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _previous() {
    final int target = _quizDone
        ? widget.drill.questions.length - 1
        : _index - 1;
    if (target < 0) return;
    setState(() {
      _quizDone = false;
      _correctAnswers.remove(target);
      _correct = _correctAnswers.length;
      _index = target;
      _picked = null;
    });
  }

  Future<void> _skip() async {
    final ChoiceQuestion question = _shuffledQuestion;
    await widget.controller.recordSkip(
      id: '${widget.drill.id}-q$_index',
      prompt: question.prompt,
      correctAnswer: question.options[question.correctIndex],
      source: 'mini-story',
      level: widget.drill.story.level.label,
    );
    if (!mounted) return;
    if (_index + 1 < widget.drill.questions.length) {
      setState(() {
        _index += 1;
        _picked = null;
      });
    } else {
      final int score = (_correct / widget.drill.questions.length * 100)
          .round();
      await widget.controller.recordActivity(widget.drill.id, score: score);
      if (mounted) setState(() => _quizDone = true);
    }
  }

  Future<void> _next() async {
    if (_picked == null) return;
    if (_index + 1 < widget.drill.questions.length) {
      setState(() {
        _index += 1;
        _picked = null;
      });
      return;
    }
    final int score = (_correct / widget.drill.questions.length * 100).round();
    await widget.controller.recordActivity(widget.drill.id, score: score);
    if (!mounted) return;
    setState(() => _quizDone = true);
  }

  @override
  Widget build(BuildContext context) {
    final MiniStoryDrill drill = widget.drill;
    return Scaffold(
      appBar: AppBar(title: Text('Mini-story · ${drill.story.title}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
        children: <Widget>[
          Text(
            'One text, four passes',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Listen without text, read once, complete the circling questions, '
            'then retell the story aloud in your own words.',
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: widget.controller.ttsEnabled ? _listen : null,
                    icon: const Icon(Icons.headphones_rounded),
                    label: const Text('1 · Listen to the complete story'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _showTranscript = !_showTranscript),
                    icon: Icon(
                      _showTranscript
                          ? Icons.visibility_off_outlined
                          : Icons.menu_book_outlined,
                    ),
                    label: Text(
                      _showTranscript
                          ? 'Hide transcript'
                          : '2 · Read the transcript',
                    ),
                  ),
                  if (_showTranscript) ...<Widget>[
                    const Divider(height: 24),
                    ...drill.transcript.map(
                      (StoryLine line) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              line.german,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              line.english,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (!_quizDone) _questionCard(context) else _resultCard(context),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '4 · Retell aloud',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  ...drill.retellPrompts.map(
                    (String prompt) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $prompt'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aim for ${drill.story.level.index < 2 ? 45 : 90} seconds. '
                    'Replay the text afterwards and notice what you omitted.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionCard(BuildContext context) {
    final ChoiceQuestion question = _shuffledQuestion;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '3 · Circling ${_index + 1}/${widget.drill.questions.length}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_index + 1) / widget.drill.questions.length,
            ),
            const SizedBox(height: 14),
            Text(
              question.prompt,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...question.options.asMap().entries.map((entry) {
              final bool selected = _picked == entry.key;
              final bool correct = entry.key == question.correctIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: OutlinedButton(
                  onPressed: _picked == null ? () => _pick(entry.key) : null,
                  style: selected || (_picked != null && correct)
                      ? OutlinedButton.styleFrom(
                          backgroundColor: correct
                              ? Colors.green.withValues(alpha: 0.12)
                              : Theme.of(context).colorScheme.errorContainer,
                        )
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Text(entry.value),
                  ),
                ),
              );
            }),
            PracticeAidPanel(
              questionKey: '${widget.drill.id}-q$_index',
              hints: _picked == null
                  ? hintsForChoice(
                      question,
                      personalization: personalizationForQuestion(
                        widget.controller.mistakes,
                        '${widget.drill.id}-q$_index',
                      ),
                    )
                  : const <Hint>[],
              onPrevious: _index > 0 ? _previous : null,
              onSkip: _picked == null ? _skip : null,
            ),
            if (_picked != null) ...<Widget>[
              Text(
                question.explanation,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _next,
                child: Text(
                  _index + 1 == widget.drill.questions.length
                      ? 'Finish questions'
                      : 'Next question',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _resultCard(BuildContext context) {
    final int score = (_correct / widget.drill.questions.length * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: <Widget>[
            const Text(
              'Circling complete',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              '$score%',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            Text('$_correct of ${widget.drill.questions.length} correct'),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _previous,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Review previous question'),
            ),
          ],
        ),
      ),
    );
  }
}
