import 'package:flutter/foundation.dart';

/// The platforms DeutschGarden ships on.
enum AppPlatform { android, ios, macos, windows, linux, web, unknown }

/// Which optional capabilities exist on the current platform.
///
/// Everything the app *teaches* — every word, lesson, story, role-play and
/// exam item — is compiled into the binary and works identically everywhere.
/// The only things that vary are the two speech capabilities, because those
/// are provided by the operating system rather than by this app.
class PlatformSupport {
  const PlatformSupport._();

  static AppPlatform get current {
    if (kIsWeb) return AppPlatform.web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AppPlatform.android;
      case TargetPlatform.iOS:
        return AppPlatform.ios;
      case TargetPlatform.macOS:
        return AppPlatform.macos;
      case TargetPlatform.windows:
        return AppPlatform.windows;
      case TargetPlatform.linux:
        return AppPlatform.linux;
      case TargetPlatform.fuchsia:
        return AppPlatform.unknown;
    }
  }

  static String get displayName {
    switch (current) {
      case AppPlatform.android:
        return 'Android';
      case AppPlatform.ios:
        return 'iOS';
      case AppPlatform.macos:
        return 'macOS';
      case AppPlatform.windows:
        return 'Windows';
      case AppPlatform.linux:
        return 'Linux';
      case AppPlatform.web:
        return 'Web';
      case AppPlatform.unknown:
        return 'this device';
    }
  }

  /// True on the three desktop targets, where there is a mouse, a keyboard and
  /// a resizable window to design for.
  static bool get isDesktop {
    switch (current) {
      case AppPlatform.macos:
      case AppPlatform.windows:
      case AppPlatform.linux:
        return true;
      case AppPlatform.android:
      case AppPlatform.ios:
      case AppPlatform.web:
      case AppPlatform.unknown:
        return false;
    }
  }

  static bool get isMobile =>
      current == AppPlatform.android || current == AppPlatform.ios;

  /// `flutter_tts` declares android, ios, macos, windows and web. It has no
  /// Linux implementation at all, so on Linux the plugin channel does not
  /// exist and every call throws MissingPluginException.
  static bool get hasPluginTts {
    switch (current) {
      case AppPlatform.android:
      case AppPlatform.ios:
      case AppPlatform.macos:
      case AppPlatform.windows:
      case AppPlatform.web:
        return true;
      case AppPlatform.linux:
      case AppPlatform.unknown:
        return false;
    }
  }

  /// On Linux we fall back to the speech-synthesis binaries that ship with
  /// essentially every desktop distribution: `spd-say` (speech-dispatcher) or
  /// `espeak-ng`. Both run entirely locally.
  static bool get usesCommandLineTts => current == AppPlatform.linux;

  /// `speech_to_text` declares android, ios, macos, windows and web. There is
  /// no Linux implementation, and no offline Linux recogniser this app could
  /// bundle without shipping an acoustic model of its own.
  static bool get hasSpeechRecognition {
    switch (current) {
      case AppPlatform.android:
      case AppPlatform.ios:
      case AppPlatform.macos:
      case AppPlatform.windows:
      case AppPlatform.web:
        return true;
      case AppPlatform.linux:
      case AppPlatform.unknown:
        return false;
    }
  }

  /// Shown in Settings so the learner can see exactly what this build can do
  /// rather than discovering a dead button.
  static String get speechRecognitionNote {
    if (hasSpeechRecognition) {
      return 'Microphone practice is available. The system recogniser handles '
          'transcription; install a German offline language pack to keep it on '
          'the device.';
    }
    return 'Microphone practice is not available on $displayName: no speech '
        'recogniser is offered for this platform. Every speaking exercise '
        'accepts typed answers and scores them identically.';
  }

  static String get ttsNote {
    if (usesCommandLineTts) {
      return 'German speech uses the system speech synthesiser '
          '(speech-dispatcher or espeak-ng). If you hear nothing, install one: '
          'sudo apt install speech-dispatcher espeak-ng';
    }
    if (hasPluginTts) {
      return 'German speech uses the $displayName text-to-speech engine.';
    }
    return 'No speech synthesiser is available on $displayName. Text is still '
        'fully usable; only audio playback is affected.';
  }
}
