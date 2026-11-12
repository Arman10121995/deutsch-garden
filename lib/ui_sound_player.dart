import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'ui_feedback.dart';

abstract interface class UiSoundOutput {
  Future<void> play(UiFeedbackEvent event, bool Function() mayPlay);
  Future<void> stop();
  Future<void> dispose();
}

/// A lazy, best-effort cosmetic player. Never awaited during app startup or
/// profile writes; unsupported/muted audio must not block learning.
class UiSoundPlayer {
  UiSoundPlayer({UiSoundOutput? output, DateTime Function()? now})
    : _output = output ?? _AssetSoundOutput(),
      _now = now ?? DateTime.now {
    UiFeedbackCaptureGate.addStopper(stop);
  }
  final UiSoundOutput _output;
  final DateTime Function() _now;
  bool _enabled = true;
  bool _disposed = false;
  int _generation = 0;
  DateTime? _until;
  int _priority = 0;
  Future<void> _playChain = Future<void>.value();

  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    if (!value) unawaited(stop());
  }

  Future<void> play(UiFeedbackEvent event) async {
    if (_disposed || !_enabled || UiFeedbackCaptureGate.active.value) return;
    final now = _now();
    if (_until != null &&
        now.isBefore(_until!) &&
        (event.priority < _priority || event == UiFeedbackEvent.click)) {
      return;
    }
    _priority = event.priority;
    _until = now.add(Duration(milliseconds: event.milliseconds));
    final generation = ++_generation;
    bool mayPlay() =>
        !_disposed &&
        _enabled &&
        !UiFeedbackCaptureGate.active.value &&
        generation == _generation;
    // One native player must not receive interleaved setSource calls. Keep
    // preparation ordered, while discarding superseded cues rather than
    // playing a delayed queue of old clicks or old answer feedback.
    final pending = _playChain.then((_) async {
      if (mayPlay()) await _output.play(event, mayPlay);
    });
    _playChain = pending.catchError((Object _) {});
    try {
      await pending;
    } catch (_) {
      // Effects are optional, including on browsers before audio is unlocked.
    }
  }

  Future<void> stop() async {
    _generation++;
    _until = null;
    _priority = 0;
    try {
      await _output.stop();
    } catch (_) {
      /* optional audio */
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    UiFeedbackCaptureGate.removeStopper(stop);
    await stop();
    try {
      await _output.dispose();
    } catch (_) {
      /* optional audio */
    }
  }
}

class _AssetSoundOutput implements UiSoundOutput {
  AudioPlayer? _player;
  Future<void>? _ready;

  Future<void> _configure(AudioPlayer player) async {
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
      ),
    );
  }

  @override
  Future<void> play(UiFeedbackEvent event, bool Function() mayPlay) async {
    final player = _player ??= AudioPlayer();
    await (_ready ??= _configure(player));
    if (!mayPlay()) return;
    await player.stop();
    await player.setVolume(event == UiFeedbackEvent.click ? 0.45 : 0.65);
    await player.setSource(AssetSource('sounds/${event.name}.wav'));
    if (!mayPlay()) return;
    await player.resume();
    if (!mayPlay()) await player.stop();
  }

  @override
  Future<void> stop() async {
    await _player?.stop();
  }

  @override
  Future<void> dispose() async {
    await _player?.dispose();
  }
}
