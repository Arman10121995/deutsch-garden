import 'dart:async';

import 'package:flutter/material.dart';

import 'tts_service.dart';

/// A real transport surface shared by stories and Gartenradio.
///
/// With the bundled voices, all turns are rendered into one WAV and every
/// control is functional. If a device cannot load that backend, playback
/// degrades to sequential OS speech and only the controls that engine can
/// honour remain visible.
class LongFormAudioPlayer extends StatefulWidget {
  const LongFormAudioPlayer({
    super.key,
    required this.programmeId,
    required this.turns,
    required this.playLabel,
    this.enabled = true,
    this.onSpeedChanged,
  });

  /// Stable identity for the story chapter or radio episode being played.
  ///
  /// Parents rebuild their derived [turns] lists for harmless UI changes such
  /// as transcript visibility or reading font size. Playback must only reset
  /// when the actual programme changes.
  final String programmeId;
  final List<SpokenTurn> turns;
  final String playLabel;
  final bool enabled;
  final ValueChanged<double>? onSpeedChanged;

  @override
  State<LongFormAudioPlayer> createState() => _LongFormAudioPlayerState();
}

class _LongFormAudioPlayerState extends State<LongFormAudioPlayer> {
  final TtsService _tts = TtsService();
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  bool _ready = false;
  bool _scrubbable = false;
  bool _loading = false;
  bool _playing = false;
  bool _completed = false;
  double _speed = 1.0;
  double? _renderedRate;
  Duration? _pendingSeek;
  Duration _position = Duration.zero;
  Duration _length = Duration.zero;

  @override
  void initState() {
    super.initState();
    _resolveBackend();
  }

  Future<void> _resolveBackend() async {
    await _tts.ensureReady();
    if (!mounted) return;
    _subscriptions.add(
      _tts.onPosition.listen((Duration position) {
        if (mounted) setState(() => _position = position);
      }),
    );
    _subscriptions.add(
      _tts.onDuration.listen((Duration length) {
        if (mounted) setState(() => _length = length);
      }),
    );
    _subscriptions.add(
      _tts.onComplete.listen((_) {
        if (!mounted) return;
        setState(() {
          _playing = false;
          _completed = true;
          if (_length > Duration.zero) _position = _length;
        });
      }),
    );
    setState(() {
      _ready = true;
      _scrubbable = _tts.canScrub;
    });
  }

  @override
  void didUpdateWidget(covariant LongFormAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.programmeId != widget.programmeId) {
      unawaited(_reset());
    }
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_tts.dispose());
    super.dispose();
  }

  Future<void> _reset() async {
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _playing = false;
      _loading = false;
      _completed = false;
      _renderedRate = null;
      _pendingSeek = null;
      _position = Duration.zero;
      _length = Duration.zero;
    });
  }

  Future<void> _start() async {
    if (!widget.enabled || widget.turns.isEmpty || _loading) return;
    if (_tts.canScrub &&
        _renderedRate == _speed &&
        _position > Duration.zero &&
        !_completed) {
      await _tts.resume();
      if (mounted) setState(() => _playing = true);
      return;
    }

    if (!_tts.canScrub) {
      setState(() {
        _playing = true;
        _loading = false;
      });
      await _tts.speakTurns(widget.turns, rate: _speed);
      if (mounted) setState(() => _playing = false);
      return;
    }

    setState(() {
      _loading = true;
      _playing = false;
      _completed = false;
    });
    final bool seekable = await _tts.playTurns(widget.turns, rate: _speed);
    if (!mounted) return;
    if (!seekable) {
      setState(() {
        _loading = false;
        _scrubbable = false;
      });
      await _start();
      return;
    }
    final Duration? seekAfter = _pendingSeek;
    _pendingSeek = null;
    _renderedRate = _speed;
    setState(() {
      _loading = false;
      _playing = true;
      _scrubbable = true;
      _position = Duration.zero;
    });
    if (seekAfter != null && seekAfter > Duration.zero) {
      await _tts.seek(seekAfter);
    }
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _tts.pause();
      if (mounted) setState(() => _playing = false);
    } else {
      await _start();
    }
  }

  Future<void> _stop() async {
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _playing = false;
      _completed = false;
      _position = Duration.zero;
    });
  }

  Future<void> _nudge(Duration delta) async {
    Duration target = _position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (_length > Duration.zero && target > _length) target = _length;
    await _tts.seek(target);
  }

  Future<void> _setSpeed(double rate) async {
    if (_speed == rate) return;
    final double previous = _renderedRate ?? _speed;
    final bool wasPlaying = _playing;
    final Duration resumeAt = Duration(
      milliseconds: (_position.inMilliseconds * previous / rate).round(),
    );
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _speed = rate;
      _playing = false;
      _completed = false;
      _renderedRate = null;
      _pendingSeek = resumeAt;
      _position = Duration.zero;
      _length = Duration.zero;
    });
    widget.onSpeedChanged?.call(rate);
    if (wasPlaying) await _start();
  }

  static String _clock(Duration duration) {
    final int seconds = duration.inSeconds;
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return const Text('Audio is disabled in Settings.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            FilledButton.icon(
              key: const ValueKey<String>('long-form-play-pause'),
              onPressed: !_ready || _loading ? null : _toggle,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    ),
              label: Text(
                _loading
                    ? 'Preparing audio'
                    : _playing
                    ? 'Pause'
                    : widget.playLabel,
              ),
            ),
            OutlinedButton.icon(
              key: const ValueKey<String>('long-form-stop'),
              onPressed: _ready ? _stop : null,
              icon: const Icon(Icons.stop_rounded),
              label: const Text('Stop'),
            ),
          ],
        ),
        if (_scrubbable) ...<Widget>[
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () => _nudge(const Duration(seconds: -10)),
                icon: const Icon(Icons.replay_10_rounded),
                tooltip: 'Back ten seconds',
              ),
              Expanded(
                child: Slider(
                  key: const ValueKey<String>('long-form-position'),
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
                      : (double value) =>
                            _tts.seek(Duration(milliseconds: value.round())),
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
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: <double>[0.6, 0.75, 1.0, 1.25].map((double rate) {
            return ChoiceChip(
              label: Text(rate == 1.0 ? 'Normal' : '${rate}x'),
              selected: _speed == rate,
              onSelected: _loading ? null : (_) => _setSpeed(rate),
            );
          }).toList(),
        ),
        if (_ready && !_scrubbable) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            'This device is using system speech, so seeking is unavailable.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
