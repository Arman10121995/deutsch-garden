import 'models.dart';

/// One narrated Gartenradio episode.
///
/// The format is deliberately narrow. Synthesised German is a convincing
/// narrator and an unconvincing actor, so every episode is a genre that is
/// genuinely read from a script in life: a news bulletin, a weather report, a
/// station announcement, a voicemail, a recipe, an audio guide, a short
/// lecture or a diary entry.
class RadioEpisode {
  const RadioEpisode({
    required this.id,
    required this.level,
    required this.genre,
    required this.title,
    required this.lines,
    required this.questions,
    this.listenPrompts = const <String>[],
    this.matchingPairs = const <RadioMatchPair>[],
  });

  final String id;
  final CefrLevel level;
  final RadioGenre genre;
  final String title;

  /// The script, one turn per line.
  final List<RadioLine> lines;

  /// The first [listenPrompts.length] entries are audio-identification
  /// questions. The remaining entries are ordinary comprehension questions.
  final List<ChoiceQuestion> questions;

  /// German sentences spoken without first showing their text. Each prompt
  /// corresponds by index to the first questions in [questions].
  final List<String> listenPrompts;

  /// One five-pair matching block closes the episode.
  final List<RadioMatchPair> matchingPairs;

  /// The German script as one block, for the transcript view and for speaking
  /// the whole episode in a single utterance.
  String get transcript => lines.map((RadioLine l) => l.german).join(' ');

  /// Roughly how long the episode runs, at the pace the app speaks German.
  /// Words per second of the bundled voice, measured rather than guessed.
  ///
  /// This was 1.7, which over-stated every duration in the library by more
  /// than half: a 64-word C1 transcript predicted 38 seconds and actually
  /// rendered 24.4 seconds of audio. Measured on a desktop CPU at the default
  /// rate, dense C1 prose runs about 2.6 words per second and simple A1 prose
  /// about 3.3. The slower figure is used, because over-stating how long an
  /// episode takes is the kinder error.
  static const double _wordsPerSecond = 2.6;

  int get approximateSeconds {
    final int words = transcript.split(RegExp(r'\s+')).length;
    return (words / _wordsPerSecond).round();
  }

  int get checkpointCount => questions.length + (matchingPairs.isEmpty ? 0 : 1);
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

  /// At A1 and A2 the app shows this alongside the German. From B1 it stays
  /// hidden unless requested, providing a gradual monolingual transition.
  final String english;

  final RadioVoice voice;
}

class RadioMatchPair {
  const RadioMatchPair({required this.german, required this.english});

  final String german;
  final String english;
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
