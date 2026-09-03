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
///
/// Quoted segments alternate between two characters, which is what an
/// exchange in prose almost always is. Cycling the whole cast here instead --
/// briefly the case in 4.8.0 -- made a two-person conversation sound like
/// four people, because it handed a new voice to every quotation rather than
/// to every speaker. A scene with more than two people should say who is
/// talking, via [storyTurnsFromLines].
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
      add(spoken, germanRoleForSpeaker(speaker % 2));
      speaker += 1;
      cursor = match.end;
    }
    add(line.substring(cursor), GermanVoiceRole.narrator);
  }
  return out;
}

/// Spoken turns for a chapter whose lines may name their own speaker.
///
/// A line carrying an explicit role uses it. A line without one falls back to
/// [storySpokenTurns]' reading of the punctuation, so every story written
/// before this existed behaves exactly as it did.
List<SpokenTurn> storyTurnsFromLines(
  Iterable<({String german, GermanVoiceRole? voice})> lines,
) {
  final List<SpokenTurn> out = <SpokenTurn>[];
  for (final ({String german, GermanVoiceRole? voice}) line in lines) {
    final GermanVoiceRole? explicit = line.voice;
    if (explicit == null) {
      out.addAll(storySpokenTurns(<String>[line.german]));
      continue;
    }
    final String text = line.german.trim();
    if (text.isEmpty) continue;
    out.add(SpokenTurn(text, voice: explicit));
  }
  return out;
}
