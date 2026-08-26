/// The audio course: what to hear today, and how to drill it.
///
/// Two ideas borrowed from courses that predate the app by decades, and both
/// are scheduling rather than content. The sentence bank already holds 9,211
/// German sentences with translations; none of this authors a word.
///
/// **What to hear today** is Glossika's shape: each day introduces a small,
/// fixed batch of new sentences and replays the batches from a handful of
/// earlier days on a widening gap. Ten new sentences on day 12 arrive
/// alongside the batches from days 11, 10, 8 and 4.
///
/// **How to drill it** is Pimsleur's: the English appears, then a silence long
/// enough to say the German out loud, then the German is spoken. Producing the
/// sentence in the gap and being corrected a beat later is the whole exercise;
/// hearing it and agreeing that it sounds right is not.
///
/// ## Why this stores one integer and not ten thousand records
///
/// The obvious implementation gives every sentence an SM-2 record and asks the
/// scheduler what is due. That would work, and it would put several thousand
/// entries into the profile, flood the "lessons due" count on the practice hub
/// with things that are not lessons, and make today's session depend on the
/// exact minute of every past answer.
///
/// A fixed day schedule needs one number per level: how many days have been
/// completed. The spacing is then a pure function of the day index, which
/// means the same day always produces the same playlist, two devices restoring
/// one backup agree, and the whole thing is testable without a clock.
///
/// The trade is real and worth stating: this does not adapt to the individual
/// sentence. A sentence you find hard comes back on the same schedule as one
/// you found easy. Per-card adaptation already exists for vocabulary, where
/// the unit of difficulty is a word; here the unit is a sentence heard in
/// sequence, and Glossika's own answer to that is repetition volume rather
/// than per-item scheduling.
library;

import 'models.dart';
import 'sentence_bank.dart';

/// New sentences introduced per day.
///
/// Ten, because a day's playlist is ten new plus up to four earlier batches,
/// and fifty sentences at roughly eight seconds each is about seven minutes of
/// audio. That is a session someone does on a commute. Twenty new would double
/// it and is how audio courses become the thing you stop doing.
const int audioCourseNewPerDay = 10;

/// How many days back the review batches come from.
///
/// 1, 2, 4, 8, 16, 32 — each gap twice the last. A sentence met on day 1 is
/// heard again on days 2, 3, 5, 9, 17 and 33, and then not again. Six
/// exposures over a month, front-loaded, which is the shape of every spacing
/// curve that works.
const List<int> audioCourseGaps = <int>[1, 2, 4, 8, 16, 32];

/// One sentence as it appears in a playlist.
class PlaylistItem {
  const PlaylistItem({
    required this.sentence,
    required this.isNew,
    required this.fromDay,
  });

  final PracticeSentence sentence;

  /// True when this is the day the sentence is introduced.
  final bool isNew;

  /// The day whose batch this sentence belongs to. Equal to the current day
  /// when [isNew].
  final int fromDay;
}

/// A day of the audio course.
class Playlist {
  const Playlist({
    required this.level,
    required this.day,
    required this.items,
    required this.totalDays,
  });

  final CefrLevel level;

  /// 1-based.
  final int day;

  final List<PlaylistItem> items;

  /// How many days the level's sentences stretch to. The course ends when the
  /// bank runs out of new material, which at 9,211 sentences is a long way
  /// off.
  final int totalDays;

  int get newCount => items.where((PlaylistItem i) => i.isNew).length;
  int get reviewCount => items.length - newCount;

  bool get isEmpty => items.isEmpty;

  /// Roughly how long the audio runs, at eight seconds per sentence including
  /// the anticipation gap.
  Duration get estimatedLength => Duration(seconds: items.length * 8);
}

/// The batch introduced on [day], as indices into the level's sentence list.
///
/// Exposed rather than inlined because the day arithmetic is the part worth
/// testing directly.
List<int> batchIndices(int day, int available) {
  final int start = (day - 1) * audioCourseNewPerDay;
  if (start >= available) return const <int>[];
  final int end = start + audioCourseNewPerDay;
  return <int>[
    for (int i = start; i < end && i < available; i++) i,
  ];
}

/// How many days of new material the level holds.
int totalDaysFor(CefrLevel level) {
  final int count = sentencesFor(level).length;
  return (count + audioCourseNewPerDay - 1) ~/ audioCourseNewPerDay;
}

/// Build the playlist for a given day.
///
/// New material first, then the review batches from oldest to newest. Order
/// matters: meeting the new sentences while attention is freshest, then
/// finishing on material that is already partly known, is a better shape than
/// the reverse, and a fixed order means a session interrupted halfway is
/// resumed rather than reshuffled.
Playlist playlistFor(CefrLevel level, int day) {
  final List<PracticeSentence> pool = sentencesFor(level);
  final int totalDays = totalDaysFor(level);
  if (day < 1 || pool.isEmpty) {
    return Playlist(level: level, day: day, items: const <PlaylistItem>[],
        totalDays: totalDays);
  }

  final List<PlaylistItem> items = <PlaylistItem>[];
  final Set<String> seen = <String>{};

  for (final int index in batchIndices(day, pool.length)) {
    final PracticeSentence sentence = pool[index];
    if (!seen.add(sentence.id)) continue;
    items.add(PlaylistItem(sentence: sentence, isNew: true, fromDay: day));
  }

  // Oldest batch first, so the widest gap is heard before the freshest.
  for (final int gap in audioCourseGaps.reversed) {
    final int source = day - gap;
    if (source < 1) continue;
    for (final int index in batchIndices(source, pool.length)) {
      final PracticeSentence sentence = pool[index];
      if (!seen.add(sentence.id)) continue;
      items.add(
        PlaylistItem(sentence: sentence, isNew: false, fromDay: source),
      );
    }
  }

  return Playlist(
    level: level,
    day: day,
    items: List<PlaylistItem>.unmodifiable(items),
    totalDays: totalDays,
  );
}

/// The stages one item moves through in an anticipation drill.
///
/// Named rather than left as a bare index because the gap is the point of the
/// exercise and a stage list makes it impossible to quietly drop.
enum DrillStage {
  /// The English is shown. Nothing is spoken.
  prompt,

  /// Silence. The learner says the German out loud.
  gap,

  /// The German is spoken and shown.
  answer,

  /// The German is spoken once more, to imitate rather than to produce.
  echo,
}

/// How long each stage lasts.
///
/// The gap scales with sentence length — a fixed five seconds is far too long
/// for "Ich bin müde" and far too short for a B2 sentence with a verb bracket.
/// Roughly six hundred milliseconds a word, floored at two and a half seconds
/// so a three-word sentence still leaves thinking time.
Duration gapFor(PracticeSentence sentence) {
  final int words = sentence.tokens.length;
  final int ms = words * 600;
  return Duration(milliseconds: ms < 2500 ? 2500 : (ms > 9000 ? 9000 : ms));
}
