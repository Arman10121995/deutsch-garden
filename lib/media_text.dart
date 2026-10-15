import 'l10n/app_localizations.dart';
import 'radio_models.dart';

String radioGenreText(AppText t, RadioGenre genre) => switch (genre) {
  RadioGenre.news => t.radioGenreNews,
  RadioGenre.weather => t.radioGenreWeather,
  RadioGenre.announcement => t.radioGenreAnnouncement,
  RadioGenre.voicemail => t.radioGenreVoicemail,
  RadioGenre.recipe => t.radioGenreRecipe,
  RadioGenre.audioGuide => t.radioGenreAudioGuide,
  RadioGenre.lecture => t.radioGenreLecture,
  RadioGenre.diary => t.radioGenreDiary,
};
