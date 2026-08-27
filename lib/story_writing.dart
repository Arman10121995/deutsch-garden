import 'models.dart';
import 'stories.dart';

/// Seventy-four guided retelling tasks turn selected reader chapters into
/// productive writing practice. Together with the 46 authored prompts this
/// brings the writing track to 120 tasks without inventing disconnected model
/// answers: the chapter itself is the answer learners can compare against.
const int storyWritingTarget = 74;

const Map<CefrLevel, int> _targetsByLevel = <CefrLevel, int>{
  CefrLevel.a1: 12,
  CefrLevel.a2: 12,
  CefrLevel.b1: 13,
  CefrLevel.b2: 13,
  CefrLevel.c1: 12,
  CefrLevel.c2: 12,
};

final List<WritingLesson> storyWritingLessons = <WritingLesson>[
  for (final CefrLevel level in CefrLevel.values) ..._lessonsForLevel(level),
];

Iterable<WritingLesson> _lessonsForLevel(CefrLevel level) sync* {
  final int target = _targetsByLevel[level]!;
  final Iterable<({Story story, StoryChapter chapter})> candidates =
      storiesFor(level).expand(
        (Story story) => story.chapters.map(
          (StoryChapter chapter) => (story: story, chapter: chapter),
        ),
      );
  for (final ({Story story, StoryChapter chapter}) item in candidates.take(
    target,
  )) {
    final String example = item.chapter.lines
        .map((StoryLine line) => line.german)
        .join(' ');
    final List<String> keywords = _keywordsFrom(example);
    yield WritingLesson(
      id: 'ws-${item.chapter.id.substring(3)}',
      level: level,
      title: 'Nacherzählung: ${item.story.title} · ${item.chapter.title}',
      prompt:
          'Retell this chapter in German without copying it sentence by '
          'sentence. Preserve the people, the central event and the outcome.',
      guidance: <String>[
        'Read or listen to the chapter once, then close the transcript.',
        'Keep the events in a clear order and use your own connectors.',
        'Include the central problem or change, not every small detail.',
        'Compare your text with the model only after your first draft.',
      ],
      minWords: (item.chapter.wordCount * 0.7).floor().clamp(20, 120),
      keywords: keywords,
      example: example,
    );
  }
}

List<String> _keywordsFrom(String text) {
  const Set<String> stop = <String>{
    'aber',
    'alle',
    'auch',
    'dann',
    'dass',
    'deren',
    'dieser',
    'diese',
    'einem',
    'einen',
    'einer',
    'hatte',
    'haben',
    'immer',
    'nicht',
    'noch',
    'oder',
    'seine',
    'seiner',
    'sich',
    'über',
    'unter',
    'wurde',
    'waren',
    'wenn',
    'weil',
    'wieder',
    'zwischen',
  };
  final List<String> found = <String>[];
  for (final Match match in RegExp(r'[A-Za-zÄÖÜäöüß]{5,}').allMatches(text)) {
    final String word = match.group(0)!.toLowerCase();
    if (!stop.contains(word) && !found.contains(word)) found.add(word);
    if (found.length == 4) break;
  }
  return found;
}
