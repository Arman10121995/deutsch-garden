import 'models.dart';
import 'radio_episodes.dart';

// radio.dart is the entry point: callers should not need to know the script
// library is a separate file.
export 'radio_episodes.dart';

/// One narrated Gartenradio episode.
///
/// The format is deliberately narrow. Synthesised German is a convincing
/// narrator and an unconvincing actor, so every episode is a genre that is
/// genuinely read from a script in life — a news bulletin, a weather report, a
/// station announcement, a voicemail, a recipe, an audio guide, a short
/// lecture. Nothing here pretends to be spontaneous conversation, because a
/// synthetic voice performing an argument in a café is worse than no audio.
///
/// The transcript is a first-class part of the episode, not a hidden answer
/// key: on Linux, and anywhere the platform voice disappoints, the episode
/// degrades into a reading lesson rather than breaking.
class RadioEpisode {
  const RadioEpisode({
    required this.id,
    required this.level,
    required this.genre,
    required this.title,
    required this.lines,
    required this.questions,
  });

  final String id;
  final CefrLevel level;
  final RadioGenre genre;
  final String title;

  /// The script, one turn per line.
  final List<RadioLine> lines;

  /// Comprehension checks, asked after listening.
  final List<ChoiceQuestion> questions;

  /// The German script as one block, for the transcript view and for speaking
  /// the whole episode in a single utterance.
  String get transcript => lines.map((RadioLine l) => l.german).join(' ');

  /// Roughly how long the episode runs, at the pace the app speaks German.
  /// Useful for showing a duration before a learner commits to listening.
  int get approximateSeconds {
    final int words = transcript.split(RegExp(r'\s+')).length;
    return (words / 1.7).round();
  }
}

/// Who is speaking. Two speakers are enough to make turn-taking audible, and
/// more than two is beyond what distinct system voices can reliably provide.
enum RadioVoice { host, guest }

class RadioLine {
  const RadioLine({
    required this.german,
    required this.english,
    this.voice = RadioVoice.host,
  });

  final String german;

  /// Kept for every line. At A1 and A2 the app shows it alongside; from B1 it
  /// stays hidden unless asked for, which is the same scaffolding ramp the
  /// stories already use.
  final String english;

  final RadioVoice voice;
}

enum RadioGenre {
  news,
  weather,
  announcement,
  voicemail,
  recipe,
  audioGuide,
  lecture,
  diary,
}

extension RadioGenreX on RadioGenre {
  String get label {
    switch (this) {
      case RadioGenre.news:
        return 'Nachrichten';
      case RadioGenre.weather:
        return 'Wetter';
      case RadioGenre.announcement:
        return 'Durchsage';
      case RadioGenre.voicemail:
        return 'Nachricht';
      case RadioGenre.recipe:
        return 'Rezept';
      case RadioGenre.audioGuide:
        return 'Audioguide';
      case RadioGenre.lecture:
        return 'Vortrag';
      case RadioGenre.diary:
        return 'Tagebuch';
    }
  }

  String get emoji {
    switch (this) {
      case RadioGenre.news:
        return '📰';
      case RadioGenre.weather:
        return '🌦️';
      case RadioGenre.announcement:
        return '📢';
      case RadioGenre.voicemail:
        return '📞';
      case RadioGenre.recipe:
        return '🍳';
      case RadioGenre.audioGuide:
        return '🏛️';
      case RadioGenre.lecture:
        return '🎓';
      case RadioGenre.diary:
        return '📔';
    }
  }
}

/// Episodes for one level, in the order they should be met.
List<RadioEpisode> radioFor(CefrLevel level) =>
    radioEpisodes.where((RadioEpisode e) => e.level == level).toList();

int get radioEpisodeCount => radioEpisodes.length;
