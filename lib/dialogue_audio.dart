/// Splits written lines into spoken turns and hands each one a voice.
///
/// Speaker identity comes from authored roles, not a quotation's position.
/// Unattributed quotation marks can also enclose signs, titles or examples;
/// they must not invent a character or change an existing character's voice.
library;

import 'tts_service.dart';

/// Turns a role-play script into spoken turns, one voice per speaker.
///
/// Lines are taken to alternate between two speakers, which is what ordinary
/// authored role-play scripts do. Named scenes should use
/// [labelledDialogueTurns] when they have more than two speakers.
List<SpokenTurn> alternatingDialogueTurns(Iterable<String> lines) {
  final List<SpokenTurn> turns = <SpokenTurn>[];
  var speaker = 0;
  for (final String raw in lines) {
    final String text = raw.trim();
    if (text.isEmpty) continue;
    turns.add(SpokenTurn(text, voice: germanRoleForSpeaker(speaker % 2)));
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
  final RegExp label = RegExp(
    r'^\s*[-–—]?\s*([\p{L}][\p{L}\s.]{0,24}?)\s*:\s*(.*)$',
    unicode: true,
  );
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
    final GermanVoiceRole role = cast.putIfAbsent(
      name,
      () => germanRoleForSpeaker(cast.length),
    );
    previous = role;
    out.add(SpokenTurn(text, voice: role));
  }
  return out;
}

/// Reads text without cast metadata in the narrator's voice. Authored stories
/// use [storyLineSpokenTurns] with their explicit quoted-voice assignments.
List<SpokenTurn> storySpokenTurns(Iterable<String> lines) =>
    storyTurnsFromLines(
      lines.map((String text) => (german: text, voice: null)),
    );

final RegExp _directSpeech = RegExp(r'„([^“]+)“|“([^”]+)”|"([^"]+)"');

/// Compatibility adapter for lines with a whole-line speaker. Quoted prose
/// without speaker metadata remains narration instead of guessing A/B.
List<SpokenTurn> storyTurnsFromLines(
  Iterable<({String german, GermanVoiceRole? voice})> lines,
) {
  final List<SpokenTurn> out = <SpokenTurn>[];
  for (final ({String german, GermanVoiceRole? voice}) line in lines) {
    out.addAll(storyLineSpokenTurns(line.german, voice: line.voice));
  }
  return out;
}

/// Separates narration from each authored quotation. The same role may speak
/// twice in a row, or return after another chapter, without changing voice.
List<SpokenTurn> storyLineSpokenTurns(
  String line, {
  GermanVoiceRole? voice,
  List<GermanVoiceRole> quotedVoices = const <GermanVoiceRole>[],
}) {
  final List<SpokenTurn> out = <SpokenTurn>[];
  if (voice != null) {
    if (line.trim().isNotEmpty) out.add(SpokenTurn(line.trim(), voice: voice));
    return out;
  }
  var quoteIndex = 0;

  void add(String text, GermanVoiceRole voice) {
    final String clean = text.trim();
    // Preserve line boundaries: very long Android synthesis requests were
    // unstable and remove the useful pauses between narrated sentences.
    if (clean.isNotEmpty) out.add(SpokenTurn(clean, voice: voice));
  }

  int cursor = 0;
  for (final RegExpMatch match in _directSpeech.allMatches(line)) {
    add(line.substring(cursor, match.start), GermanVoiceRole.narrator);
    add(
      match.group(1) ?? match.group(2) ?? match.group(3) ?? '',
      quoteIndex < quotedVoices.length
          ? quotedVoices[quoteIndex]
          : GermanVoiceRole.narrator,
    );
    quoteIndex += 1;
    cursor = match.end;
  }
  add(line.substring(cursor), GermanVoiceRole.narrator);
  return out;
}
