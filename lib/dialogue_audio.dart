import 'tts_service.dart';

List<SpokenTurn> alternatingDialogueTurns(Iterable<String> lines) {
  final List<SpokenTurn> turns = <SpokenTurn>[];
  var next = GermanVoiceRole.speakerA;
  for (final String raw in lines) {
    final String text = raw.trim();
    if (text.isEmpty) continue;
    turns.add(SpokenTurn(text, voice: next));
    next = next == GermanVoiceRole.speakerA
        ? GermanVoiceRole.speakerB
        : GermanVoiceRole.speakerA;
  }
  return turns;
}

/// Separates narration from German direct speech and alternates quoted roles.
List<SpokenTurn> storySpokenTurns(Iterable<String> lines) {
  final List<SpokenTurn> out = <SpokenTurn>[];
  var quotedVoice = GermanVoiceRole.speakerB;
  final RegExp quote = RegExp(r'„([^“]+)“|“([^”]+)”|"([^"]+)"');

  void add(String text, GermanVoiceRole voice) {
    final String clean = text.trim();
    if (clean.isEmpty) return;
    // Keep authored story lines bounded. Merging a whole narration chapter
    // into one TTS request made the Android native backend unstable and also
    // removed the learner-friendly pause between sentences.
    out.add(SpokenTurn(clean, voice: voice));
  }

  for (final String line in lines) {
    int cursor = 0;
    for (final RegExpMatch match in quote.allMatches(line)) {
      add(line.substring(cursor, match.start), GermanVoiceRole.narrator);
      final String spoken =
          match.group(1) ?? match.group(2) ?? match.group(3) ?? '';
      add(spoken, quotedVoice);
      quotedVoice = quotedVoice == GermanVoiceRole.speakerA
          ? GermanVoiceRole.speakerB
          : GermanVoiceRole.speakerA;
      cursor = match.end;
    }
    add(line.substring(cursor), GermanVoiceRole.narrator);
  }
  return out;
}
