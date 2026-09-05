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

/// Separates narration from German direct speech and gives each quoted
/// speaker a voice.
///
/// Quoted segments alternate between two characters, which is what an
/// exchange in prose almost always is. A scene with more than two people
/// should say who is talking, via [storyTurnsFromLines].
List<SpokenTurn> storySpokenTurns(Iterable<String> lines) =>
    storyTurnsFromLines(
      lines.map((String text) => (german: text, voice: null)),
    );

final RegExp _directSpeech = RegExp(r'„([^“]+)“|“([^”]+)”|"([^"]+)"');

/// Spoken turns for a chapter whose lines may name their own speaker.
///
/// A line carrying an explicit role uses it. A line without one falls back to
/// [storySpokenTurns]' reading of the punctuation, so every story written
/// before this existed behaves exactly as it did.
List<SpokenTurn> storyTurnsFromLines(
  Iterable<({String german, GermanVoiceRole? voice})> lines,
) {
  final List<SpokenTurn> out = <SpokenTurn>[];
  var nextSpeaker = 0;
  for (final ({String german, GermanVoiceRole? voice}) line in lines) {
    final GermanVoiceRole? explicit = line.voice;
    if (explicit == null) {
      out.addAll(_storySpokenTurns(line.german, nextSpeaker));
      nextSpeaker += _directSpeech.allMatches(line.german).length;
      continue;
    }
    final String text = line.german.trim();
    if (text.isEmpty) continue;
    out.add(SpokenTurn(text, voice: explicit));
    if (explicit.index > GermanVoiceRole.narrator.index) {
      nextSpeaker = explicit.index - GermanVoiceRole.speakerA.index + 1;
    }
  }
  return out;
}

List<SpokenTurn> _storySpokenTurns(String line, int startingSpeaker) {
  final List<SpokenTurn> out = <SpokenTurn>[];
  var speaker = startingSpeaker;

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
      germanRoleForSpeaker(speaker % 2),
    );
    speaker += 1;
    cursor = match.end;
  }
  add(line.substring(cursor), GermanVoiceRole.narrator);
  return out;
}
