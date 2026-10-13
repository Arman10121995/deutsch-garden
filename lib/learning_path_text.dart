/// Presentation of the pure course plan in the selected interface language.
/// Lesson titles and can-do outcomes remain curriculum content. Counts and
/// routing never depend on translated strings.
library;

import 'achievements.dart';
import 'course.dart';
import 'l10n/app_localizations.dart';
import 'learning_path.dart';
import 'models.dart';

String skillText(AppText t, SkillType skill) => switch (skill) {
  SkillType.vocabulary => t.skillVocabulary,
  SkillType.grammar => t.skillGrammar,
  SkillType.listening => t.skillListening,
  SkillType.reading => t.skillReading,
  SkillType.writing => t.skillWriting,
  SkillType.speaking => t.skillSpeaking,
};

String courseStepText(AppText t, CourseStepKind kind) => switch (kind) {
  CourseStepKind.vocabulary => t.skillVocabulary,
  CourseStepKind.grammar => t.skillGrammar,
  CourseStepKind.listening => t.skillListening,
  CourseStepKind.reading => t.skillReading,
  CourseStepKind.writing => t.skillWriting,
  CourseStepKind.speaking => t.skillSpeaking,
  CourseStepKind.story => t.skillStory,
  CourseStepKind.conversation => t.skillRolePlay,
  CourseStepKind.radio => 'Gartenradio',
  CourseStepKind.matching => t.skillMatching,
  CourseStepKind.sentenceBuilder => t.skillSentenceBuilder,
  CourseStepKind.dictation => t.skillDictation,
};

String courseStepTitle(AppText t, CourseUnit unit, CourseStep step) =>
    switch (step.kind) {
      CourseStepKind.vocabulary => t.vocabularyStepTitle(
        unit.wordTarget,
        unit.level.label,
      ),
      CourseStepKind.matching ||
      CourseStepKind.sentenceBuilder ||
      CourseStepKind.dictation => courseStepText(t, step.kind),
      _ => step.title,
    };

String levelDescription(AppText t, CefrLevel level) => switch (level) {
  CefrLevel.a1 => t.levelA1Description,
  CefrLevel.a2 => t.levelA2Description,
  CefrLevel.b1 => t.levelB1Description,
  CefrLevel.b2 => t.levelB2Description,
  CefrLevel.c1 => t.levelC1Description,
  CefrLevel.c2 => t.levelC2Description,
};

String questTitle(AppText t, DailyQuest quest) => switch (quest.metric) {
  DailyMetric.reviews => t.questActions(quest.target),
  DailyMetric.xp => t.questXp(quest.target),
  DailyMetric.lessons => t.questLessons(quest.target),
  DailyMetric.storyChapters => t.questChapters(quest.target),
  DailyMetric.conversationTurns => t.questTurns(quest.target),
  DailyMetric.perfectAnswers => t.questPerfect(quest.target),
};

String drillTitle(AppText t, PracticeDrill drill) => switch (drill) {
  PracticeDrill.matchPairs => t.drillMatchPairs,
  PracticeDrill.sentenceBuilder => t.skillSentenceBuilder,
  PracticeDrill.cloze => t.drillCloze,
  PracticeDrill.articles => t.drillArticles,
  PracticeDrill.verbs => t.drillVerbs,
  PracticeDrill.speedReview => t.drillSpeedReview,
  PracticeDrill.dictation => t.skillDictation,
};

String drillDescription(AppText t, PracticeDrill drill) => switch (drill) {
  PracticeDrill.matchPairs => t.drillMatchBody,
  PracticeDrill.sentenceBuilder => t.drillSentenceBody,
  PracticeDrill.cloze => t.drillClozeBody,
  PracticeDrill.articles => t.drillArticlesBody,
  PracticeDrill.verbs => t.drillVerbsBody,
  PracticeDrill.speedReview => t.drillSpeedBody,
  PracticeDrill.dictation => t.drillDictationBody,
};

extension LearningPathActionText on LearningPathAction {
  String localizedTitle(AppText t) => switch (kind) {
    LearningPathActionKind.wordReview => t.reviewWordsTitle(itemCount),
    LearningPathActionKind.lessonReview => t.refreshLesson(lesson!.title),
    LearningPathActionKind.courseStep => courseStepTitle(t, unit!, step!),
    LearningPathActionKind.checkpoint => t.checkpointTitle(unit!.title),
    LearningPathActionKind.mistakeRepair => t.repairMistakesTitle(itemCount),
    LearningPathActionKind.enrichment => t.extraTitle(
      courseStepTitle(t, unit!, step!),
    ),
    LearningPathActionKind.practiceDrill => drillTitle(t, drill!),
  };

  String localizedSubtitle(AppText t) {
    switch (kind) {
      case LearningPathActionKind.wordReview:
        return totalItems > itemCount
            ? t.reviewWordsBatch(itemCount, totalItems)
            : t.reviewWordsBody;
      case LearningPathActionKind.lessonReview:
        return t.refreshLessonBody(
          lesson!.level.label,
          skillText(t, lesson!.skill),
        );
      case LearningPathActionKind.courseStep:
        final String part = partsTotal <= 1
            ? ''
            : step!.kind == CourseStepKind.story
            ? t.chapterProgress(partsDone + 1, partsTotal)
            : t.partProgress(partsDone + 1, partsTotal);
        return t.courseStepDescription(
          unit!.level.label,
          unit!.number,
          part,
          courseStepText(t, step!.kind),
        );
      case LearningPathActionKind.checkpoint:
        return t.checkpointBrief(unit!.checkpoint.length, courseCheckpointPass);
      case LearningPathActionKind.mistakeRepair:
        return t.repairMistakesBody;
      case LearningPathActionKind.enrichment:
        return t.extraBody(courseStepText(t, step!.kind));
      case LearningPathActionKind.practiceDrill:
        return t.drillClosing(drillDescription(t, drill!));
    }
  }
}
