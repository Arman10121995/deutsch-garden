/// Stable fallback pitches, including the narrator, for engines with one
/// usable German voice. The role owns the pitch, not the selected device voice.
const List<double> germanRolePitches = <double>[0.96, 1.20, 0.84, 1.34, 1.06];

double germanPitchForRole(int roleIndex) =>
    germanRolePitches[roleIndex % germanRolePitches.length];

/// Returns every available voice once, starting at the role's stable slot.
/// This lets a rejected or missing voice fall through without collapsing the
/// whole programme into the first voice.
List<int> germanVoiceAttemptOrder(int roleIndex, int voiceCount) {
  if (voiceCount <= 0) return <int>[];
  final int first = roleIndex % voiceCount;
  return <int>[
    for (var offset = 0; offset < voiceCount; offset++)
      (first + offset) % voiceCount,
  ];
}

/// An engine may advertise a voice it cannot load. Try the remaining slots
/// for this role without abandoning the whole dialogue or swallowing a
/// later speech/playback error. Shared by direct speech and WAV rendering.
Future<bool> selectGermanVoice({
  required int roleIndex,
  required List<Map<String, String>> voices,
  required Future<Object?> Function(Map<String, String>) setVoice,
}) async {
  for (final int index in germanVoiceAttemptOrder(roleIndex, voices.length)) {
    try {
      if (await setVoice(voices[index]) == 1) return true;
    } catch (_) {
      // The next advertised voice may still be usable offline.
    }
  }
  return false;
}

/// Locks each role to the first usable device voice for this speech session.
/// A voice that later fails falls back to the default German voice and stays
/// there; it must not silently cast a different actor midway through a scene.
class GermanVoiceCast {
  GermanVoiceCast(List<Map<String, String>> voices)
    : _voices = voices.map((voice) => Map<String, String>.of(voice)).toList();

  final List<Map<String, String>> _voices;
  final Map<int, Map<String, String>?> _resolved =
      <int, Map<String, String>?>{};

  Future<bool> select({
    required int roleIndex,
    required Future<Object?> Function(Map<String, String>) setVoice,
    required Future<Object?> Function() resetToGerman,
  }) async {
    if (_resolved.containsKey(roleIndex)) {
      final Map<String, String>? voice = _resolved[roleIndex];
      if (voice != null) {
        try {
          if (await setVoice(voice) == 1) return true;
        } catch (_) {
          // Keep this role on the predictable fallback from now on.
        }
      }
    } else {
      for (final int index in germanVoiceAttemptOrder(
        roleIndex,
        _voices.length,
      )) {
        try {
          if (await setVoice(_voices[index]) == 1) {
            _resolved[roleIndex] = _voices[index];
            return true;
          }
        } catch (_) {
          // An advertised voice may not actually be installed.
        }
      }
    }
    _resolved[roleIndex] = null;
    // Never inherit whichever character spoke immediately before this one.
    await resetToGerman();
    return false;
  }
}
