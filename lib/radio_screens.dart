import 'package:flutter/material.dart';

import 'app_state.dart';
import 'media_text.dart';
import 'l10n/app_localizations.dart';
import 'models.dart';
import 'hints.dart';
import 'practice_aids.dart';
import 'radio.dart';
import 'long_form_audio_player.dart';
import 'tts_service.dart';
import 'dart:math';
import 'answer_shuffle.dart';
import 'pending_action.dart';

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
      appBar: AppBar(
        title: Text(AppText.of(context).radioLibraryTitle(level.label)),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, _) {
          if (episodes.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  AppText.of(context).radioEmpty,
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
                    AppText.of(context).radioInstructions,
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
                    AppText.of(context).radioSummary(
                          radioGenreText(AppText.of(context), episode.genre),
                          minutes,
                        ) +
                        (progress.completed
                            ? AppText.of(context).radioBest(progress.bestScore)
                            : ''),
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

class _RadioEpisodeScreenState extends State<RadioEpisodeScreen>
    with PendingAction<RadioEpisodeScreen> {
  final TtsService _lineTts = TtsService();

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
  final Set<int> _correctQuestions = <int>{};
  final Set<int> _correctMatches = <int>{};

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      'Gartenradio · ${widget.episode.title}',
    );
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Gartenradio · ${widget.episode.title}');
    _lineTts.dispose();
    super.dispose();
  }

  Future<void> _playLine(RadioLine line) =>
      _lineTts.speakGerman(line.german, rate: _speed, voice: line.voice.role);

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
    if (_selected != null || actionPending) return;
    final ChoiceQuestion question = _shuffledQuestion;
    setState(() {
      _selected = index;
      if (index == question.correctIndex) {
        _correctQuestions.add(_questionIndex);
      } else {
        _correctQuestions.remove(_questionIndex);
      }
      _correct = _correctQuestions.length;
    });
  }

  void _previousQuestion() {
    if (actionPending) return;
    if (_questionIndex <= 0) {
      setState(() {
        _answering = false;
        _selected = null;
      });
      return;
    }
    final int target = _questionIndex - 1;
    setState(() {
      _correctQuestions.remove(target);
      _correct = _correctQuestions.length;
      _questionIndex = target;
      _selected = null;
    });
  }

  Future<void> _skipQuestion() async {
    if (_selected != null) return;
    await runAction(_recordQuestionSkip);
  }

  Future<void> _recordQuestionSkip() async {
    final ChoiceQuestion question = _shuffledQuestion;
    await widget.controller.recordSkip(
      id: '${widget.episode.id}-q$_questionIndex',
      prompt: question.prompt,
      correctAnswer: question.options[question.correctIndex],
      source: 'radio',
      level: widget.episode.level.label,
    );
    if (mounted) await _advanceQuestion();
  }

  Future<void> _nextQuestion() async {
    if (_selected == null || !_answering) return;
    await runAction(_advanceQuestion);
  }

  Future<void> _advanceQuestion() async {
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
        _correctMatches.clear();
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
    if (_matchSelected != null || actionPending) return;
    final List<String> options = _matchOptions();
    final RadioMatchPair pair = widget.episode.matchingPairs[_matchIndex];
    setState(() {
      _matchSelected = index;
      if (options[index] == pair.english) {
        _correctMatches.add(_matchIndex);
      } else {
        _correctMatches.remove(_matchIndex);
      }
      _matchCorrect = _correctMatches.length;
    });
  }

  void _previousMatch() {
    if (actionPending) return;
    if (_matchIndex <= 0) {
      final int target = widget.episode.questions.length - 1;
      setState(() {
        _matching = false;
        _correctQuestions.remove(target);
        _correct = _correctQuestions.length;
        _questionIndex = target;
        _selected = null;
      });
      return;
    }
    final int target = _matchIndex - 1;
    setState(() {
      _correctMatches.remove(target);
      _matchCorrect = _correctMatches.length;
      _matchIndex = target;
      _matchSelected = null;
    });
  }

  Future<void> _skipMatch() async {
    if (_matchSelected != null) return;
    await runAction(_recordMatchSkip);
  }

  Future<void> _recordMatchSkip() async {
    final RadioMatchPair pair = widget.episode.matchingPairs[_matchIndex];
    await widget.controller.recordSkip(
      id: '${widget.episode.id}-match-$_matchIndex',
      prompt: 'Match: ${pair.german}',
      correctAnswer: pair.english,
      source: 'radio',
      level: widget.episode.level.label,
    );
    if (mounted) await _advanceMatch();
  }

  Future<void> _nextMatch() async {
    if (_matchSelected == null || !_matching) return;
    await runAction(_advanceMatch);
  }

  Future<void> _advanceMatch() async {
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
          AppText.of(context).radioResult(
            _correct,
            _matchCorrect,
            questionCount,
            score,
            widget.episode.matchingPairs.length,
          ),
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
                    _correctQuestions.clear();
                    _selected = null;
                    _matching = false;
                    _matchIndex = 0;
                    _matchCorrect = 0;
                    _correctMatches.clear();
                    _matchSelected = null;
                  }),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(AppText.of(context).radioAnswerQuestions),
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
                  '${episode.genre.emoji}  ${radioGenreText(AppText.of(context), episode.genre)}'
                  ' • ${episode.level.label}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 10),
                LongFormAudioPlayer(
                  programmeId: episode.id,
                  turns: episode.lines
                      .map(
                        (RadioLine line) =>
                            SpokenTurn(line.german, voice: line.voice.role),
                      )
                      .toList(growable: false),
                  playLabel: AppText.of(context).playEpisode,
                  enabled: widget.controller.ttsEnabled,
                  onSpeedChanged: (double rate) => _speed = rate,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: <Widget>[
            Text(
              AppText.of(context).transcriptTitle,
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
              label: Text(
                _showEnglish
                    ? AppText.of(context).hideEnglish
                    : AppText.of(context).showEnglish,
              ),
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
                tooltip: AppText.of(context).hearLineAgain,
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
          AppText.of(context).questionOfTotal(
            _questionIndex + 1,
            widget.episode.questions.length,
          ),
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
            onPressed: () => _lineTts.speakGerman(
              widget.episode.listenPrompts[_questionIndex],
              rate: _speed,
            ),
            icon: const Icon(Icons.hearing_rounded),
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(AppText.of(context).playSentence),
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
              onPressed: _selected == null && !actionPending
                  ? () => _choose(i)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(question.options[i]),
              ),
            ),
          );
        }),
        PracticeAidPanel(
          questionKey: '${widget.episode.id}-q$_questionIndex',
          hints: _selected == null
              ? hintsForChoice(
                  question,
                  personalization: personalizationForQuestion(
                    widget.controller.mistakes,
                    '${widget.episode.id}-q$_questionIndex',
                  ),
                )
              : const <Hint>[],
          onPrevious: actionPending ? null : _previousQuestion,
          onSkip: _selected == null && !actionPending ? _skipQuestion : null,
        ),
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
            onPressed: actionPending ? null : _nextQuestion,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                _questionIndex + 1 < widget.episode.questions.length
                    ? AppText.of(context).nextQuestion
                    : widget.episode.matchingPairs.isEmpty
                    ? AppText.of(context).finishAction
                    : AppText.of(context).startMatching,
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
          AppText.of(context).matchingOfTotal(
            _matchIndex + 1,
            widget.episode.matchingPairs.length,
          ),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        Text(
          AppText.of(context).matchExpression,
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
                  tooltip: AppText.of(context).hearExpression,
                  onPressed: () =>
                      _lineTts.speakGerman(pair.german, rate: _speed),
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
              onPressed: _matchSelected == null && !actionPending
                  ? () => _chooseMatch(index)
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(options[index]),
              ),
            ),
          );
        }),
        PracticeAidPanel(
          questionKey: '${widget.episode.id}-match-$_matchIndex',
          hints: _matchSelected == null
              ? <Hint>[
                  Hint(
                    text: AppText.of(context).radioMatchHint,
                    kind: HintKind.structural,
                    personalized: personalizationForQuestion(
                      widget.controller.mistakes,
                      '${widget.episode.id}-match-$_matchIndex',
                    ).hasHistory,
                  ),
                ]
              : const <Hint>[],
          onPrevious: actionPending ? null : _previousMatch,
          onSkip: _matchSelected == null && !actionPending ? _skipMatch : null,
        ),
        if (_matchSelected != null) ...<Widget>[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppText.of(
                  context,
                ).expressionMeaning(pair.german, pair.english),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: actionPending ? null : _nextMatch,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                _matchIndex + 1 < widget.episode.matchingPairs.length
                    ? AppText.of(context).nextMatch
                    : AppText.of(context).finishEpisode,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
