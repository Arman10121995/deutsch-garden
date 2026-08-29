import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'models.dart';
import 'radio.dart';
import 'tts_service.dart';
import 'dart:math';
import 'answer_shuffle.dart';

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
              final ActivityProgress progress = controller.progressForActivity(
                episode.id,
              );
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
  late bool _showEnglish = widget.episode.level.order <= CefrLevel.a2.order;

  double _speed = 1.0;
  bool _answering = false;
  bool _matching = false;
  int _questionIndex = 0;
  int _correct = 0;
  int? _selected;
  int _matchIndex = 0;
  int _matchCorrect = 0;
  int? _matchSelected;

  /// Transport state. Only populated on the bundled-voice path, which is the
  /// only backend that produces a file rather than telling the OS to talk.
  bool _scrubbable = false;
  bool _playing = false;
  bool _loading = false;
  Duration _position = Duration.zero;
  Duration _length = Duration.zero;
  final List<StreamSubscription<dynamic>> _subs =
      <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    _resolveBackend();
  }

  Future<void> _resolveBackend() async {
    await _tts.ensureReady();
    if (!mounted) return;
    setState(() => _scrubbable = _tts.canScrub);
    if (!_scrubbable) return;
    _subs.add(
      _tts.onPosition.listen((Duration p) {
        if (mounted) setState(() => _position = p);
      }),
    );
    _subs.add(
      _tts.onDuration.listen((Duration d) {
        if (mounted) setState(() => _length = d);
      }),
    );
    _subs.add(
      _tts.onComplete.listen((_) {
        if (mounted) setState(() => _playing = false);
      }),
    );
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> sub in _subs) {
      sub.cancel();
    }
    _tts.stop();
    super.dispose();
  }

  /// Synthesising a whole episode takes a second or two, so the button has to
  /// say something is happening or the first tap reads as a dead control.
  Future<void> _playAll() async {
    setState(() {
      _loading = true;
      _playing = true;
    });
    await _tts.speakGerman(widget.episode.transcript, rate: _speed);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _scrubbable = _tts.canScrub;
    });
  }

  Future<void> _toggle() async {
    if (!_playing) {
      if (_scrubbable && _position > Duration.zero) {
        await _tts.resume();
        if (mounted) setState(() => _playing = true);
        return;
      }
      await _playAll();
      return;
    }
    await _tts.pause();
    if (mounted) setState(() => _playing = false);
  }

  Future<void> _nudge(Duration by) async {
    final Duration target = _position + by;
    await _tts.seek(target < Duration.zero ? Duration.zero : target);
  }

  /// Changing speed means a different file, because the bundled voice bakes
  /// the rate into the audio it generates. Resume at the matching point rather
  /// than starting the episode again: the position scales by the ratio of the
  /// two rates.
  Future<void> _setSpeed(double rate) async {
    final double previous = _speed;
    setState(() => _speed = rate);
    if (!_playing) return;
    final Duration at = Duration(
      milliseconds: (_position.inMilliseconds * previous / rate).round(),
    );
    await _playAll();
    if (at > Duration.zero) await _tts.seek(at);
  }

  Future<void> _playLine(RadioLine line) =>
      _tts.speakGerman(line.german, rate: _speed);

  static String _clock(Duration d) {
    final int total = d.inSeconds;
    final String m = (total ~/ 60).toString();
    final String s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }


  /// Fixed once per sitting, so the option order is stable while a question is
  /// on screen and different next time. See lib/answer_shuffle.dart.
  final int _shuffleSalt = Random().nextInt(0x7fffffff);

  /// The current question, options already permuted. Both the grading path
  /// and the rendering path go through here, and because the shuffle is
  /// seeded from (prompt, salt) rather than a fresh Random, the two agree
  /// without either having to hold the shuffled copy.
  ChoiceQuestion get _shuffledQuestion {
    final ChoiceQuestion raw = widget.episode.questions[_questionIndex];
    return raw.shuffled(seededFor(raw.prompt, _shuffleSalt));
  }

  void _choose(int index) {
    if (_selected != null) return;
    final ChoiceQuestion question = _shuffledQuestion;
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
    if (widget.episode.matchingPairs.isNotEmpty) {
      setState(() {
        _matching = true;
        _matchIndex = 0;
        _matchCorrect = 0;
        _matchSelected = null;
      });
      return;
    }
    await _finishEpisode();
  }

  List<String> _matchOptions() {
    final List<String> raw = widget.episode.matchingPairs
        .map((RadioMatchPair pair) => pair.english)
        .toList(growable: false);
    final int shift = (_matchIndex * 2 + 1) % raw.length;
    return <String>[...raw.skip(shift), ...raw.take(shift)];
  }

  void _chooseMatch(int index) {
    if (_matchSelected != null) return;
    final List<String> options = _matchOptions();
    final RadioMatchPair pair = widget.episode.matchingPairs[_matchIndex];
    setState(() {
      _matchSelected = index;
      if (options[index] == pair.english) _matchCorrect++;
    });
  }

  Future<void> _nextMatch() async {
    if (_matchIndex + 1 < widget.episode.matchingPairs.length) {
      setState(() {
        _matchIndex++;
        _matchSelected = null;
      });
      return;
    }
    await _finishEpisode();
  }

  Future<void> _finishEpisode() async {
    final int questionCount = widget.episode.questions.length;
    final int blockCount = widget.episode.checkpointCount;
    final double matchingCredit = widget.episode.matchingPairs.isEmpty
        ? 0
        : _matchCorrect / widget.episode.matchingPairs.length;
    final int score = (((_correct + matchingCredit) / blockCount) * 100)
        .round();
    await widget.controller.recordActivity(widget.episode.id, score: score);
    if (!mounted) return;
    setState(() {
      _answering = false;
      _matching = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$score% — $_correct of $questionCount questions and '
          '$_matchCorrect of ${widget.episode.matchingPairs.length} matches',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final RadioEpisode episode = widget.episode;
    return Scaffold(
      appBar: AppBar(title: Text(episode.title)),
      body: SafeArea(
        child: _answering
            ? _matching
                  ? _buildMatching(context)
                  : _buildQuestions(context)
            : _buildPlayer(context),
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
                    _matching = false;
                    _matchIndex = 0;
                    _matchCorrect = 0;
                    _matchSelected = null;
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
                      onPressed: _loading ? null : _toggle,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                      label: Text(
                        _loading
                            ? 'Preparing'
                            : _playing
                            ? 'Pause'
                            : 'Play episode',
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        _tts.stop();
                        setState(() {
                          _playing = false;
                          _position = Duration.zero;
                        });
                      },
                      child: const Text('Stop'),
                    ),
                  ],
                ),
                // Scrubbing needs a file to scrub. The bundled voice makes
                // one; an OS engine is handed a string and speaks it, with no
                // position to report and nowhere to seek to. Showing a dead
                // progress bar there would repeat the mistake the speed chips
                // used to make, so the controls simply are not offered.
                if (_scrubbable) ...<Widget>[
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => _nudge(const Duration(seconds: -10)),
                        icon: const Icon(Icons.replay_10_rounded),
                        tooltip: 'Back ten seconds',
                      ),
                      Expanded(
                        child: Slider(
                          value: _length.inMilliseconds == 0
                              ? 0
                              : _position.inMilliseconds
                                    .clamp(0, _length.inMilliseconds)
                                    .toDouble(),
                          max: _length.inMilliseconds == 0
                              ? 1
                              : _length.inMilliseconds.toDouble(),
                          onChanged: _length.inMilliseconds == 0
                              ? null
                              : (double v) => _tts.seek(
                                  Duration(milliseconds: v.round()),
                                ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _nudge(const Duration(seconds: 10)),
                        icon: const Icon(Icons.forward_10_rounded),
                        tooltip: 'Forward ten seconds',
                      ),
                    ],
                  ),
                  Text(
                    '${_clock(_position)} / ${_clock(_length)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
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
                      onSelected: (_) => _setSpeed(r),
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
            Text(
              'Transcript',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _showEnglish = !_showEnglish),
              icon: Icon(
                _showEnglish
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
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
    final ChoiceQuestion question = _shuffledQuestion;
    final bool isListening =
        _questionIndex < widget.episode.listenPrompts.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        Text(
          'Question ${_questionIndex + 1} of '
          '${widget.episode.questions.length}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        Text(
          question.prompt,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (isListening) ...<Widget>[
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: () => _tts.speakGerman(
              widget.episode.listenPrompts[_questionIndex],
              rate: _speed,
            ),
            icon: const Icon(Icons.hearing_rounded),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Play the sentence'),
            ),
          ),
        ],
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
                    : widget.episode.matchingPairs.isEmpty
                    ? 'Finish'
                    : 'Start matching',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMatching(BuildContext context) {
    final RadioMatchPair pair = widget.episode.matchingPairs[_matchIndex];
    final List<String> options = _matchOptions();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        Text(
          'Matching ${_matchIndex + 1} of '
          '${widget.episode.matchingPairs.length}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'Match the German expression',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    pair.german,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  tooltip: 'Hear the German expression',
                  onPressed: () => _tts.speakGerman(pair.german, rate: _speed),
                  icon: const Icon(Icons.volume_up_rounded),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...List<Widget>.generate(options.length, (int index) {
          Color? background;
          if (_matchSelected != null) {
            if (options[index] == pair.english) {
              background = Colors.green.withValues(alpha: 0.25);
            } else if (index == _matchSelected) {
              background = Colors.red.withValues(alpha: 0.25);
            }
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(backgroundColor: background),
              onPressed: _matchSelected == null
                  ? () => _chooseMatch(index)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(options[index]),
              ),
            ),
          );
        }),
        if (_matchSelected != null) ...<Widget>[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('„${pair.german}“ means “${pair.english}”.'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _nextMatch,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                _matchIndex + 1 < widget.episode.matchingPairs.length
                    ? 'Next match'
                    : 'Finish episode',
              ),
            ),
          ),
        ],
      ],
    );
  }
}
