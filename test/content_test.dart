import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/achievements.dart';
import 'package:deutsch_garden/sentence_bank.dart';
import 'package:deutsch_garden/stories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every level has at least one story with readable chapters', () {
    for (final CefrLevel level in CefrLevel.values) {
      final List<Story> list = storiesFor(level);
      expect(list, isNotEmpty, reason: '${level.label} has no story');
      for (final Story story in list) {
        expect(story.chapters, isNotEmpty);
        expect(story.minutes, greaterThan(0));
        for (final StoryChapter chapter in story.chapters) {
          expect(chapter.lines, isNotEmpty);
          expect(chapter.questions, isNotEmpty);
          expect(chapter.glossary, isNotEmpty);
          for (final StoryLine line in chapter.lines) {
            expect(line.german.trim(), isNotEmpty);
            expect(line.english.trim(), isNotEmpty);
          }
        }
      }
    }
  });

  test('story and chapter ids are unique', () {
    final Set<String> ids = <String>{};
    for (final Story story in stories) {
      expect(ids.add(story.id), isTrue, reason: 'duplicate story ${story.id}');
      for (final StoryChapter chapter in story.chapters) {
        expect(ids.add(chapter.id), isTrue,
            reason: 'duplicate chapter ${chapter.id}');
      }
    }
    expect(allStoryChapters.length, greaterThanOrEqualTo(24));
  });

  test('every comprehension question has a valid correct index', () {
    for (final StoryChapter chapter in allStoryChapters) {
      for (final ChoiceQuestion question in chapter.questions) {
        expect(question.options.length, greaterThanOrEqualTo(2));
        expect(question.correctIndex, greaterThanOrEqualTo(0));
        expect(question.correctIndex, lessThan(question.options.length));
        expect(question.explanation.trim(), isNotEmpty);
      }
    }
  });

  test('the sentence bank produces buildable sentences at every level', () {
    for (final CefrLevel level in CefrLevel.values) {
      final List<PracticeSentence> list = sentencesFor(level);
      expect(list.length, greaterThanOrEqualTo(8),
          reason: '${level.label} has too few practice sentences');
      for (final PracticeSentence sentence in list) {
        expect(sentence.tokens.length, greaterThanOrEqualTo(2),
            reason: '${sentence.id} cannot be shuffled into a word bank');
        expect(sentence.tokens.join(' '), sentence.german,
            reason: '${sentence.id} does not round-trip through its tokens');
      }
    }
  });

  test('daily quests are deterministic per day and distinct', () {
    final List<DailyQuest> monday = questsForDay('2026-03-02');
    final List<DailyQuest> mondayAgain = questsForDay('2026-03-02');
    final List<DailyQuest> tuesday = questsForDay('2026-03-03');
    expect(monday.map((q) => q.id).toList(),
        mondayAgain.map((q) => q.id).toList());
    expect(monday.length, 3);
    expect(monday.map((q) => q.id).toSet().length, 3,
        reason: 'the same quest must not be handed out twice in one day');
    expect(
      monday.map((q) => q.id).toList() == tuesday.map((q) => q.id).toList(),
      isFalse,
      reason: 'quests should rotate across days',
    );
  });

  test('achievement targets are positive and ids unique', () {
    final Set<String> ids = <String>{};
    for (final Achievement achievement in achievements) {
      expect(ids.add(achievement.id), isTrue);
      expect(achievement.target, greaterThan(0));
      expect(achievement.title.trim(), isNotEmpty);
    }
  });

  test('the "read everything" achievement matches the bundled chapter count',
      () {
    final Achievement all =
        achievements.firstWhere((a) => a.id == 'ach-story-33');
    expect(all.target, allStoryChapters.length,
        reason: 'the completionist target must track the real chapter count');
  });
}
