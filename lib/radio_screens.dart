import 'package:flutter/material.dart';

import 'app_state.dart';
import 'models.dart';
import 'radio.dart';
import 'tts_service.dart';

/// The Gartenradio library: episodes for one level, newest first.
class RadioLibraryScreen extends StatelessWidget {
  const RadioLibraryScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  Widget build(BuildContext context) {
    final List<RadioEpisode> episodes = radioFor(level);
    return Scaffold(
      appBar: AppBar(title: Text('Gartenradio • ${level.label}')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, _) {
          if (episodes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No episodes at this level yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: episodes.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Short narrated episodes. Listen first, read the '
                    'transcript afterwards.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
              final RadioEpisode episode = episodes[index - 1];
              final ActivityProgress progress =
                  controller.progressForActivity(episode.id);
              final int minutes = (episode.approximateSeconds / 60).ceil();
              return Card(
                child: ListTile(
                  leading: Text(
                    episode.genre.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                  title: Text(
                    episode.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${episode.genre.label} • about $minutes min'
                    '${progress.completed ? ' • done ${progress.bestScore}%' : ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => RadioEpisodeScreen(
                        controller: controller,
                        episode: episode,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// One episode: listen, then answer.
class RadioEpisodeScreen extends StatefulWidget {
  const RadioEpisodeScreen({
    super.key,
    required this.controller,
    required this.episode,
  });

  final AppController controller;
  final RadioEpisode episode;

  @override
  State<RadioEpisodeScreen> createState() => _RadioEpisodeScreenState();
}

class _RadioEpisodeScreenState extends State<RadioEpisodeScreen> {
  final TtsService _tts = TtsService();

  /// A1 and A2 show the English beside every line; from B1 the learner meets
  /// German first and reveals the translation only if they want it.
  late bool _showEnglish =
      widget.episode.level.order <= CefrLevel.a2.order;

  double _speed = 1.0;
  bool _answering = false;
  int _questionIndex = 0;
  int _correct = 0;
  int? _selected;

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _playAll() =>
      _tts.speakGerman(widget.episode.transcript, rate: _speed);

  Future<void> _playLine(RadioLine line) =>
      _tts.speakGerman(line.german, rate: _speed);

  void _choose(int index) {
    if (_selected != null) return;
    final ChoiceQuestion question =
        widget.episode.questions[_questionIndex];
    setState(() {
      _selected = index;
      if (index == question.correctIndex) _correct++;
    });
  }

  Future<void> _nextQuestion() async {
    if (_questionIndex + 1 < widget.episode.questions.length) {
      setState(() {
        _questionIndex++;
        _selected = null;
      });
      return;
    }
    final int score =
        ((_correct / widget.episode.questions.length) * 100).round();
    await widget.controller.recordActivity(widget.episode.id, score: score);
    if (!mounted) return;
    setState(() => _answering = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$score% — $_correct of '
          '${widget.episode.questions.length} correct')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RadioEpisode episode = widget.episode;
    return Scaffold(
      appBar: AppBar(title: Text(episode.title)),
      body: SafeArea(
        child: _answering ? _buildQuestions(context) : _buildPlayer(context),
      ),
      // Pinned rather than placed after the transcript: a B2 episode runs to
      // seven paragraphs, and burying the next action under all of it means
      // scrolling past everything you just read to continue.
      bottomNavigationBar: _answering
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: FilledButton(
                  onPressed: () => setState(() {
                    _answering = true;
                    _questionIndex = 0;
                    _correct = 0;
                    _selected = null;
                  }),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Answer the questions'),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPlayer(BuildContext context) {
    final RadioEpisode episode = widget.episode;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${episode.genre.emoji}  ${episode.genre.label}'
                  ' • ${episode.level.label}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: _playAll,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play episode'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: _tts.stop,
                      child: const Text('Stop'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Slower delivery is the single most useful control a learner
                // has on synthesised speech, so it is on the main surface
                // rather than behind a menu.
                Wrap(
                  spacing: 8,
                  children: <double>[0.6, 0.75, 1.0, 1.25].map((double r) {
                    return ChoiceChip(
                      label: Text(r == 1.0 ? 'Normal' : '${r}x'),
                      selected: _speed == r,
                      onSelected: (_) => setState(() => _speed = r),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Transcript',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => setState(() => _showEnglish = !_showEnglish),
              icon: Icon(_showEnglish
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded),
              label: Text(_showEnglish ? 'Hide English' : 'Show English'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...episode.lines.map((RadioLine line) {
          return Card(
            child: ListTile(
              dense: true,
              title: Text(line.german),
              subtitle: _showEnglish ? Text(line.english) : null,
              trailing: IconButton(
                tooltip: 'Hear this line again',
                icon: const Icon(Icons.volume_up_rounded),
                onPressed: () => _playLine(line),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuestions(BuildContext context) {
    final ChoiceQuestion question = widget.episode.questions[_questionIndex];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        Text(
          'Question ${_questionIndex + 1} of '
          '${widget.episode.questions.length}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        Text(question.prompt,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        ...List<Widget>.generate(question.options.length, (int i) {
          Color? background;
          if (_selected != null) {
            if (i == question.correctIndex) {
              background = Colors.green.withValues(alpha: 0.25);
            } else if (i == _selected) {
              background = Colors.red.withValues(alpha: 0.25);
            }
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(backgroundColor: background),
              onPressed: _selected == null ? () => _choose(i) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(question.options[i]),
              ),
            ),
          );
        }),
        if (_selected != null) ...<Widget>[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(question.explanation),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _nextQuestion,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                _questionIndex + 1 < widget.episode.questions.length
                    ? 'Next question'
                    : 'Finish',
              ),
            ),
          ),
        ],
      ],
    );
  }
}
