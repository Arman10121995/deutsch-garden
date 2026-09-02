/// The audio course, on screen.
///
/// A day card that says what today holds, and the drill itself: English,
/// silence, German, German again, next. The scheduling lives in
/// `lib/audio_course.dart`; this is the player.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'audio_course.dart';
import 'long_form_audio_player.dart';
import 'models.dart';
import 'tts_service.dart';

class AudioCourseScreen extends StatelessWidget {
  const AudioCourseScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        final ThemeData theme = Theme.of(context);
        final int day = controller.audioCourseDay(level);
        final int done = controller.audioCourseDaysDone(level);
        final Playlist today = playlistFor(level, day);
        final List<SpokenTurn> listeningTurns = <SpokenTurn>[
          for (final PlaylistItem item in today.items)
            SpokenTurn(item.sentence.german),
        ];

        return Scaffold(
          appBar: AppBar(title: Text('Audio course · ${level.label}')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: <Widget>[
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Day $day of ${today.totalDays}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        today.isEmpty
                            ? 'The sentence bank for ${level.label} is '
                                  'finished. Nothing left to introduce.'
                            : '${today.newCount} new, '
                                  '${today.reviewCount} coming back · about '
                                  '${today.estimatedLength.inMinutes} minutes',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (!today.isEmpty) ...<Widget>[
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => AnticipationDrillScreen(
                                controller: controller,
                                playlist: today,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start today'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (listeningTurns.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Listen through today’s playlist',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Use the full player for play, pause, stop, back, forward, scrubbing and speed control. Start today opens the speaking-and-anticipation drill.',
                        ),
                        const SizedBox(height: 12),
                        LongFormAudioPlayer(
                          programmeId: 'audio-course-${level.name}-$day',
                          turns: listeningTurns,
                          playLabel: 'Play playlist',
                          enabled: controller.ttsEnabled,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'How it works',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You read the English, then there is a silence. Say the '
                'German out loud in that silence — out loud, not in your '
                'head; producing it is the exercise. Then you hear it and can '
                'compare.\n\n'
                'Each day introduces ten sentences and brings back the '
                'batches from one, two, four, eight, sixteen and thirty-two '
                'days ago. A sentence you meet today comes back six times '
                'over the next month and then stops.',
              ),
              if (done > 0) ...<Widget>[
                const SizedBox(height: 20),
                Text(
                  'Days done',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$done · roughly ${done * audioCourseNewPerDay} '
                  'sentences met at ${level.label}',
                ),
                const SizedBox(height: 12),
                // Re-listening to an earlier day is a reasonable thing to
                // want, and the counter is guarded against it, so there is no
                // reason to forbid it.
                OutlinedButton.icon(
                  onPressed: () => _replay(context, done),
                  icon: const Icon(Icons.history),
                  label: const Text('Replay an earlier day'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _replay(BuildContext context, int done) async {
    final int? pick = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            for (int d = done; d >= 1; d--)
              ListTile(
                title: Text('Day $d'),
                onTap: () => Navigator.pop(sheet, d),
              ),
          ],
        ),
      ),
    );
    if (pick == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnticipationDrillScreen(
          controller: controller,
          playlist: playlistFor(level, pick),
        ),
      ),
    );
  }
}

class AnticipationDrillScreen extends StatefulWidget {
  const AnticipationDrillScreen({
    super.key,
    required this.controller,
    required this.playlist,
  });

  final AppController controller;
  final Playlist playlist;

  @override
  State<AnticipationDrillScreen> createState() =>
      _AnticipationDrillScreenState();
}

class _AnticipationDrillScreenState extends State<AnticipationDrillScreen> {
  final TtsService _tts = TtsService();

  int _index = 0;
  DrillStage _stage = DrillStage.prompt;
  bool _running = false;
  bool _finished = false;
  Timer? _timer;

  PlaylistItem get _item => widget.playlist.items[_index];

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      'Audio course · ${widget.playlist.level.label} day '
      '${widget.playlist.day}',
    );
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity(
      'Audio course · ${widget.playlist.level.label} day '
      '${widget.playlist.day}',
    );
    _timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  /// Advance to [stage] after [wait], unless the screen has gone away or the
  /// learner has paused.
  void _schedule(Duration wait, DrillStage stage) {
    _timer?.cancel();
    _timer = Timer(wait, () {
      if (!mounted || !_running) return;
      _enter(stage);
    });
  }

  void _enter(DrillStage stage) {
    setState(() => _stage = stage);
    switch (stage) {
      case DrillStage.prompt:
        // A beat to read the English before the gap starts.
        _schedule(const Duration(milliseconds: 1400), DrillStage.gap);
      case DrillStage.gap:
        _schedule(gapFor(_item.sentence), DrillStage.answer);
      case DrillStage.answer:
        unawaited(_tts.speakGerman(_item.sentence.german));
        _schedule(
          gapFor(_item.sentence) + const Duration(milliseconds: 800),
          DrillStage.echo,
        );
      case DrillStage.echo:
        // Slower the second time: the first hearing is the correction, the
        // second is a model to imitate, and imitation wants the vowels held.
        unawaited(_tts.speakGerman(_item.sentence.german, rate: 0.85));
        // The echo is the last stage, so what follows is the next sentence
        // rather than another stage of this one.
        _timer?.cancel();
        _timer = Timer(
          gapFor(_item.sentence) + const Duration(milliseconds: 1400),
          () {
            if (!mounted || !_running) return;
            _next();
          },
        );
    }
  }

  Future<void> _next() async {
    if (_index + 1 >= widget.playlist.items.length) {
      _timer?.cancel();
      await _tts.stop();
      await widget.controller.completeAudioCourseDay(
        widget.playlist.level,
        widget.playlist.day,
      );
      if (!mounted) return;
      setState(() {
        _running = false;
        _finished = true;
      });
      return;
    }
    setState(() => _index += 1);
    _enter(DrillStage.prompt);
  }

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _enter(_stage);
    } else {
      _timer?.cancel();
      _tts.stop();
    }
  }

  void _skip() {
    _timer?.cancel();
    _tts.stop();
    _next();
  }

  void _previous() {
    if (_index <= 0) return;
    _timer?.cancel();
    _tts.stop();
    setState(() {
      _index -= 1;
      _stage = DrillStage.prompt;
      _running = false;
    });
  }

  void _reviewLast() {
    _timer?.cancel();
    _tts.stop();
    setState(() {
      _index = widget.playlist.items.length - 1;
      _stage = DrillStage.prompt;
      _running = false;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (_finished) return _done(theme);

    final PlaylistItem item = _item;
    final bool reveal =
        _stage == DrillStage.answer || _stage == DrillStage.echo;

    return Scaffold(
      appBar: AppBar(
        title: Text('Day ${widget.playlist.day}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / widget.playlist.items.length,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${_index + 1} of ${widget.playlist.items.length}',
                    style: theme.textTheme.labelMedium,
                  ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      item.isNew ? 'new' : 'from day ${item.fromDay}',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.sentence.english,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              _StageIndicator(stage: _stage),
              const SizedBox(height: 28),
              AnimatedOpacity(
                opacity: reveal ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: <Widget>[
                    Text(
                      item.sentence.german,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (item.sentence.focus.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        item.sentence.focus,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton.filledTonal(
                    onPressed: _index > 0 ? _previous : null,
                    icon: const Icon(Icons.skip_previous_rounded),
                    tooltip: 'Previous sentence',
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: () =>
                        _tts.speakGerman(item.sentence.german, rate: 0.85),
                    icon: const Icon(Icons.volume_up),
                    tooltip: 'Hear it again',
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: _toggle,
                    icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                    label: Text(_running ? 'Pause' : 'Play'),
                  ),
                  const SizedBox(width: 16),
                  IconButton.filledTonal(
                    onPressed: _skip,
                    icon: const Icon(Icons.skip_next),
                    tooltip: 'Next sentence',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _done(ThemeData theme) => Scaffold(
    appBar: AppBar(title: Text('Day ${widget.playlist.day}')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('\u{1F3A7}', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 12),
            Text(
              'Day ${widget.playlist.day} done',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.playlist.newCount} new sentences, '
              '${widget.playlist.reviewCount} brought back.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _reviewLast,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Review last'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Where in the prompt / silence / answer cycle the drill is.
///
/// Shown because the silence is otherwise indistinguishable from the app
/// having stopped working, and a learner who thinks it has broken will not use
/// the gap for what it is for.
class _StageIndicator extends StatelessWidget {
  const _StageIndicator({required this.stage});

  final DrillStage stage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (String label, IconData icon) = switch (stage) {
      DrillStage.prompt => ('Read it', Icons.visibility_outlined),
      DrillStage.gap => ('Say it in German, out loud', Icons.mic_none),
      DrillStage.answer => ('Listen', Icons.hearing),
      DrillStage.echo => ('Once more, with them', Icons.repeat),
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
