import 'models.dart';
import 'stories.dart';

/// A compact four-mode exercise derived from one graded reader:
/// listen, read, answer fifteen circling/sequence questions, then retell.
class MiniStoryDrill {
  const MiniStoryDrill({
    required this.id,
    required this.story,
    required this.transcript,
    required this.questions,
    required this.retellPrompts,
  });

  final String id;
  final Story story;
  final List<StoryLine> transcript;
  final List<ChoiceQuestion> questions;
  final List<String> retellPrompts;
}

final List<MiniStoryDrill> miniStoryDrills = stories
    .map<MiniStoryDrill>(_drillForStory)
    .toList(growable: false);

MiniStoryDrill miniStoryFor(Story story) => miniStoryDrills.firstWhere(
  (MiniStoryDrill drill) => drill.story.id == story.id,
);

MiniStoryDrill _drillForStory(Story story) {
  final List<StoryLine> allLines = story.chapters
      .expand<StoryLine>((StoryChapter chapter) => chapter.lines)
      .toList(growable: false);
  final List<StoryLine> transcript = allLines.take(10).toList(growable: false);
  final List<ChoiceQuestion> questions = story.chapters
      .expand<ChoiceQuestion>((StoryChapter chapter) => chapter.questions)
      .take(15)
      .toList(growable: true);

  int cursor = 0;
  while (questions.length < 15) {
    final int firstIndex = cursor % (transcript.length - 1);
    final int secondIndex = firstIndex + 1;
    final StoryLine first = transcript[firstIndex];
    final StoryLine second = transcript[secondIndex];
    questions.add(
      ChoiceQuestion(
        prompt: 'Was geschieht in der Geschichte zuerst?',
        options: <String>[first.german, second.german],
        correctIndex: 0,
        explanation: 'Im Text steht „${first.german}“ vor „${second.german}“.',
      ),
    );
    cursor += 1;
  }

  return MiniStoryDrill(
    id: 'ms-${story.id.substring(3)}',
    story: story,
    transcript: transcript,
    questions: questions,
    retellPrompts: <String>[
      'Wer handelt, und wo beginnt die Geschichte?',
      'Welches Problem oder welche Veränderung tritt auf?',
      'Was wird entschieden oder ausprobiert?',
      'Wie endet die Geschichte, und was lässt sich daraus lernen?',
    ],
  );
}
