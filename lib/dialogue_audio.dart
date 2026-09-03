/// Splits written lines into spoken turns and hands each one a voice.
///
/// Before 4.8 both routines below alternated between exactly two roles, which
/// was all the two bundled voices could carry. A role-play with three people
/// therefore had one of them silently doubled, and in a story the narrator
/// shared a voice with a character. There are five voices now, so the cast is
/// handed out in order instead.
library;

import 'tts_service.dart';

/// Turns a role-play script into spoken turns, one voice per speaker.
///
/// Lines are taken to alternate between speakers, which is what the authored
/// scripts do. The name is kept for compatibility, but it no longer means
/// "alternating between two": it cycles the whole character cast.
List<SpokenTurn> alternatingDialogueTurns(Iterable<String> lines) {
  final List<SpokenTurn> turns = <SpokenTurn>[];
  var speaker = 0;
  for (final String raw in lines) {
    final String text = raw.trim();
    if (text.isEmpty) continue;
    turns.add(SpokenTurn(text, voice: germanRoleForSpeaker(speaker)));
    speaker += 1;
  }
  return turns;
}

/// Turns a script with explicit speaker labels into spoken turns.
///
/// A line beginning `Anna:` or `- Ben:` is attributed to that person, and the
/// same name keeps the same voice throughout — which is the thing alternation
/// cannot do. A line with no label continues the previous speaker, so a
/// two-line speech is not split between two people.
List<SpokenTurn> labelledDialogueTurns(Iterable<String> lines) {
  final RegExp label = RegExp(r'^\s*[-–—]?\s*([\p{L}][\p{L}\s.]{0,24}?)\s*:\s*(.*)$',
      unicode: true);
  final Map<String, GermanVoiceRole> cast = <String, GermanVoiceRole>{};
  final List<SpokenTurn> out = <SpokenTurn>[];
  GermanVoiceRole? previous;

  for (final String raw in lines) {
    final String line = raw.trim();
    if (line.isEmpty) continue;
    final RegExpMatch? match = label.firstMatch(line);
    if (match == null) {
      // Unlabelled: the same person carrying on, or narration if nobody has
      // spoken yet.
      out.add(SpokenTurn(line, voice: previous ?? GermanVoiceRole.narrator));
      continue;
    }
    final String name = match.group(1)!.trim().toLowerCase();
    final String text = match.group(2)!.trim();
    if (text.isEmpty) continue;
    final GermanVoiceRole role =
        cast.putIfAbsent(name, () => germanRoleForSpeaker(cast.length));
    previous = role;
    out.add(SpokenTurn(text, voice: role));
  }
  return out;
}

/// Separates narration from German direct speech and gives each quoted
/// speaker a voice.
List<SpokenTurn> storySpokenTurns(Iterable<String> lines) {
  final List<SpokenTurn> out = <SpokenTurn>[];
  var speaker = 0;
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
      add(spoken, germanRoleForSpeaker(speaker));
      speaker += 1;
      cursor = match.end;
    }
    add(line.substring(cursor), GermanVoiceRole.narrator);
  }
  return out;
}
