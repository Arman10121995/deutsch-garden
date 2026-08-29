/// Offline speech recognition, as an optional extra.
///
/// The pronunciation lab has scored *sound* since 3.17 — MFCC features against
/// the bundled voice, which reaches timing, rhythm and vowel shape. What it has
/// never had is *words*: it cannot tell a mispronounced sentence from a
/// different sentence, and on Linux there is no system recogniser at all.
///
/// A German model closes that. It is not bundled, for two reasons that are
/// both measurements rather than opinions:
///
/// * **Size.** The App Bundle is 184 MB against Google Play's 200 MB cap for a
///   base module. The model is another 100 MB. Bundling it would trade the
///   ability to publish for a feature most learners will never switch on —
///   the wrong side of the first rule in `docs/ASSET_POLICY.md`.
///
/// * **Licence.** NVIDIA's German FastConformer is CC-BY-4.0: attribution
///   required, which composes with this project's MIT grant the same way the
///   Tabler icons do. The 55 MB Kroko alternative is CC-BY-SA with
///   non-commercial free keys, and share-alike inside an MIT application is a
///   compliance burden with no upside.
///
/// So it downloads once, on request, and then works offline forever. That is
/// the smallest possible use of the network under the third rule of the policy:
/// never during a session, never for anything a learner needs, and never
/// without being asked for.
///
/// **What is not established:** how well it reads *learner* German. NVIDIA
/// report 5.1% word error rate on Common Voice, but that is native read speech.
/// A recogniser that marks a correct answer wrong because the learner has an
/// accent is worse than no recogniser, which is exactly why this was declined
/// in 3.17. The acoustic score therefore stays primary and the transcript is
/// shown as a second opinion, not a verdict.
library;

export 'asr_stub.dart' if (dart.library.io) 'asr_io.dart'
    show createSpeechRecogniser;

/// Where the model is in its life.
enum AsrModelState {
  /// Not on this device. The lab works without it.
  absent,

  /// Being fetched. The only moment the network is involved.
  downloading,

  /// Unpacking what was fetched.
  installing,

  /// Present and usable. Nothing touches the network again.
  ready,

  /// Something went wrong; [AsrModelStatus.message] says what.
  failed,

  /// This platform cannot run it at all.
  unsupported,
}

class AsrModelStatus {
  const AsrModelStatus({
    required this.state,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.message = '',
  });

  final AsrModelState state;
  final int receivedBytes;
  final int totalBytes;
  final String message;

  bool get isReady => state == AsrModelState.ready;
  bool get isBusy =>
      state == AsrModelState.downloading || state == AsrModelState.installing;

  /// 0..1, or null when the server did not say how big the download is.
  double? get progress {
    if (totalBytes <= 0) return null;
    return (receivedBytes / totalBytes).clamp(0.0, 1.0);
  }
}

/// What a recognised utterance came back as.
class AsrResult {
  const AsrResult({required this.text, required this.ok, this.error = ''});

  const AsrResult.failed(String reason)
      : text = '',
        ok = false,
        error = reason;

  final String text;
  final bool ok;
  final String error;
}

abstract class SpeechRecogniser {
  /// Whether this platform could run a model if one were installed.
  bool get isSupported;

  /// Roughly what the download costs, for saying so before starting it.
  int get approximateDownloadBytes;

  /// A human-readable note about where the model comes from and its licence.
  String get attribution;

  /// Current state. Cheap; safe to call on every build.
  Future<AsrModelStatus> status();

  /// Fetches and installs the model, reporting progress.
  Stream<AsrModelStatus> install();

  /// Deletes it, freeing the space.
  Future<void> remove();

  /// Transcribes 16 kHz mono PCM. Returns a failure rather than throwing:
  /// a recogniser that crashes the speaking lab is worse than one that
  /// declines to answer.
  Future<AsrResult> transcribe(List<double> samples, int sampleRate);

  /// Transcribes a recorded wav. Convenience over [transcribe] for the
  /// speaking lab, which already has a file rather than samples.
  Future<AsrResult> transcribeFile(String path);

  /// Releases native resources.
  Future<void> dispose();
}
