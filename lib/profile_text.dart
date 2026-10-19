import 'achievements.dart';
import 'app_state.dart';
import 'backup.dart';
import 'identity.dart';
import 'l10n/app_localizations.dart';
import 'platform_support.dart';

String playbackSupportText(AppText t) => switch (PlatformSupport.current) {
  AppPlatform.android => t.settingsPlaybackAndroid,
  AppPlatform.web => t.settingsPlaybackWeb,
  AppPlatform.windows ||
  AppPlatform.macos ||
  AppPlatform.ios ||
  AppPlatform.linux => t.settingsPlaybackBundled,
  AppPlatform.unknown => t.settingsPlaybackOther,
};

String transcriptionSupportText(AppText t, AppController controller) =>
    controller.asrUsable
    ? t.settingsTranscriptionLocal
    : PlatformSupport.hasSpeechRecognition
    ? t.settingsTranscriptionSystem
    : t.settingsTranscriptionOther;

String backupErrorText(AppText t, BackupImportResult result) =>
    switch (result.reason) {
      BackupFailure.empty => t.settingsBackupEmpty,
      BackupFailure.invalidJson => t.settingsBackupJson,
      BackupFailure.notBackup => t.settingsBackupWrong,
      BackupFailure.newerFormat => t.settingsBackupNewer(
        ProgressBackup.formatVersion,
        result.backupVersion,
      ),
      BackupFailure.missingState => t.settingsBackupState,
      null => result.error,
    };

String backupSummaryText(AppText t, Map<String, dynamic> state) {
  int number(String key) => state[key] is num ? (state[key] as num).toInt() : 0;
  int items(String key) => state[key] is Map ? (state[key] as Map).length : 0;
  return t.settingsBackupSummary(
    items('activities'),
    number('streak'),
    items('progress'),
    number('xp'),
  );
}

String avatarErrorText(AppText t, AvatarResult result) =>
    switch (result.reason) {
      AvatarFailure.empty => t.profilePictureEmpty,
      AvatarFailure.tooLarge => t.profilePictureLarge,
      AvatarFailure.unreadable => t.profilePictureUnreadable,
      null => t.profilePictureFailed,
    };

String statMetricText(AppText t, StatMetric metric) => switch (metric) {
  StatMetric.streak => t.profileMetricStreak,
  StatMetric.xp => t.profileMetricXp,
  StatMetric.wordsLearned => t.profileMetricWordsLearned,
  StatMetric.wordsMastered => t.profileMetricWordsMastered,
  StatMetric.lessonsPassed => t.profileMetricLessonsPassed,
  StatMetric.perfectLessons => t.profileMetricPerfectLessons,
  StatMetric.storyChapters => t.profileMetricStoryChapters,
  StatMetric.conversationsCompleted => t.profileMetricConversationsCompleted,
  StatMetric.speakingTurns => t.profileMetricSpeakingTurns,
  StatMetric.levelsUnlocked => t.profileMetricLevelsUnlocked,
  StatMetric.dailyGoalsHit => t.profileMetricDailyGoalsHit,
  StatMetric.mistakesCleared => t.profileMetricMistakesCleared,
  StatMetric.mnemonicsWritten => t.profileMetricMnemonicsWritten,
};

String achievementTitle(AppText t, Achievement achievement) =>
    switch (achievement.id) {
      'ach-seed' => t.profileAchievement0,
      'ach-sprout' => t.profileAchievement1,
      'ach-grove' => t.profileAchievement2,
      'ach-forest' => t.profileAchievement3,
      'ach-master-50' => t.profileAchievement4,
      'ach-master-250' => t.profileAchievement5,
      'ach-streak-3' => t.profileAchievement6,
      'ach-streak-14' => t.profileAchievement7,
      'ach-streak-60' => t.profileAchievement8,
      'ach-xp-1000' => t.profileAchievement9,
      'ach-xp-10000' => t.profileAchievement10,
      'ach-lesson-10' => t.profileAchievement11,
      'ach-lesson-60' => t.profileAchievement12,
      'ach-perfect-5' => t.profileAchievement13,
      'ach-perfect-25' => t.profileAchievement14,
      'ach-story-1' => t.profileAchievement15,
      'ach-story-10' => t.profileAchievement16,
      'ach-story-33' => t.profileAchievement17,
      'ach-talk-1' => t.profileAchievement18,
      'ach-talk-8' => t.profileAchievement19,
      'ach-turns-100' => t.profileAchievement20,
      'ach-level-3' => t.profileAchievement21,
      'ach-level-6' => t.profileAchievement22,
      'ach-goal-7' => t.profileAchievement23,
      'ach-goal-30' => t.profileAchievement24,
      'ach-fix-25' => t.profileAchievement25,
      'ach-mem-10' => t.profileAchievement26,
      _ => achievement.title,
    };

String achievementDescription(AppText t, Achievement achievement) {
  if (achievement.id == 'ach-story-33') return t.profileAllChapters;
  return switch (achievement.metric) {
    StatMetric.streak => t.profileGoalStreak(achievement.target),
    StatMetric.xp => t.profileGoalXp(achievement.target),
    StatMetric.wordsLearned => t.profileGoalWordsLearned(achievement.target),
    StatMetric.wordsMastered => t.profileGoalWordsMastered(achievement.target),
    StatMetric.lessonsPassed => t.profileGoalLessonsPassed(achievement.target),
    StatMetric.perfectLessons => t.profileGoalPerfectLessons(
      achievement.target,
    ),
    StatMetric.storyChapters => t.profileGoalStoryChapters(achievement.target),
    StatMetric.conversationsCompleted => t.profileGoalConversationsCompleted(
      achievement.target,
    ),
    StatMetric.speakingTurns => t.profileGoalSpeakingTurns(achievement.target),
    StatMetric.levelsUnlocked => t.profileGoalLevelsUnlocked(
      achievement.target,
    ),
    StatMetric.dailyGoalsHit => t.profileGoalDailyGoalsHit(achievement.target),
    StatMetric.mistakesCleared => t.profileGoalMistakesCleared(
      achievement.target,
    ),
    StatMetric.mnemonicsWritten => t.profileGoalMnemonicsWritten(
      achievement.target,
    ),
  };
}
