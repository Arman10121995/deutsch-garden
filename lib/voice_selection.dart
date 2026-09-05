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
