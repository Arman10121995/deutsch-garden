import 'models.dart';
import 'radio_episodes.dart';
import 'radio_models.dart';

// radio.dart is the entry point: callers should not need to know the script
// library is a separate file.
export 'radio_episodes.dart';
export 'radio_models.dart';

/// Episodes for one level, in the order they should be met.
List<RadioEpisode> radioFor(CefrLevel level) =>
    radioEpisodes.where((RadioEpisode e) => e.level == level).toList();

int get radioEpisodeCount => radioEpisodes.length;
