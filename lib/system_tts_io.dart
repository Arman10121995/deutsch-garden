import 'dart:async';
import 'dart:io';

/// Command-line speech synthesis for platforms with no flutter_tts backend.
///
/// This exists for Linux. `flutter_tts` implements android, ios, macos,
/// windows and web, so on a Linux desktop the plugin channel is simply absent
/// and every call throws MissingPluginException. Rather than shipping a build
/// with a dead audio button, DeutschGarden drives the speech synthesiser that
/// desktop Linux already has:
///
/// * `spd-say` — the speech-dispatcher client, present on Ubuntu, Debian,
///   Fedora and openSUSE by default and used by Orca and Firefox;
/// * `espeak-ng` / `espeak` — the synthesiser speech-dispatcher itself usually
///   drives, used directly when the dispatcher is missing.
///
/// Both run entirely on the machine. Nothing is sent anywhere.
const List<String> _candidates = <String>['spd-say', 'espeak-ng', 'espeak'];

String? _binary;
bool _probed = false;
Process? _speaking;

Future<String?> _resolveBinary() async {
  if (_probed) return _binary;
  _probed = true;
  for (final String candidate in _candidates) {
    try {
      // Probing with --version avoids depending on `which`, which is not
      // guaranteed to be installed on a minimal system.
      final ProcessResult result =
          await Process.run(candidate, <String>['--version']);
      if (result.exitCode == 0) {
        _binary = candidate;
        return _binary;
      }
    } on ProcessException {
      // Not installed; try the next candidate.
    } catch (_) {
      // Any other failure means this candidate is unusable.
    }
  }
  return null;
}

Future<bool> systemTtsAvailable() async {
  if (!Platform.isLinux) return false;
  return await _resolveBinary() != null;
}

Future<bool> systemTtsSpeak(String text, {String locale = 'de'}) async {
  if (!Platform.isLinux) return false;
  final String? binary = await _resolveBinary();
  if (binary == null || text.trim().isEmpty) return false;

  await systemTtsStop();

  final List<String> arguments;
  switch (binary) {
    case 'spd-say':
      // -l language, -w waits for the utterance so the process handle stays
      // meaningful for stop(), -r slows delivery for learners.
      arguments = <String>['-l', locale, '-r', '-20', '-w', text];
      break;
    default:
      // espeak-ng: -v voice, -s words per minute.
      arguments = <String>['-v', locale, '-s', '130', text];
      break;
  }

  try {
    final Process process = await Process.start(binary, arguments);
    _speaking = process;
    unawaited(process.exitCode.then((int _) {
      if (identical(_speaking, process)) _speaking = null;
    }));
    return true;
  } on ProcessException {
    return false;
  }
}

Future<void> systemTtsStop() async {
  final Process? process = _speaking;
  _speaking = null;
  if (process == null) return;
  try {
    process.kill();
  } catch (_) {
    // Already exited.
  }
  if (_binary == 'spd-say') {
    try {
      // speech-dispatcher queues utterances in its own daemon, so killing the
      // client is not enough — the queue has to be cancelled too.
      await Process.run('spd-say', <String>['-C']);
    } catch (_) {
      // Best effort.
    }
  }
}

String get systemTtsBinaryName => _binary ?? '';
