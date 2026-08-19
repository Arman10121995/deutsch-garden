/// Lifetime statistics an achievement can be measured against.
///
/// The controller knows how to compute each of these; keeping the enum here
/// means the achievement catalogue has no dependency on app state, which in
/// turn keeps the catalogue trivially testable.
enum StatMetric {
  streak,
  xp,
  wordsLearned,
  wordsMastered,
  lessonsPassed,
  perfectLessons,
  storyChapters,
  conversationsCompleted,
  speakingTurns,
  levelsUnlocked,
  dailyGoalsHit,
  mistakesCleared,
  mnemonicsWritten,
}

extension StatMetricX on StatMetric {
  String get label {
    switch (this) {
      case StatMetric.streak:
        return 'day streak';
      case StatMetric.xp:
        return 'XP';
      case StatMetric.wordsLearned:
        return 'words learned';
      case StatMetric.wordsMastered:
        return 'words mastered';
      case StatMetric.lessonsPassed:
        return 'lessons passed';
      case StatMetric.perfectLessons:
        return 'perfect lessons';
      case StatMetric.storyChapters:
        return 'story chapters';
      case StatMetric.conversationsCompleted:
        return 'conversations completed';
      case StatMetric.speakingTurns:
        return 'spoken turns';
      case StatMetric.levelsUnlocked:
        return 'levels unlocked';
      case StatMetric.dailyGoalsHit:
        return 'daily goals hit';
      case StatMetric.mistakesCleared:
        return 'mistakes cleared';
      case StatMetric.mnemonicsWritten:
        return 'mnemonics written';
    }
  }
}

class Achievement {
  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final StatMetric metric;
  final int target;
}

const List<Achievement> achievements = <Achievement>[
  Achievement(id: 'ach-seed', emoji: '🌰', title: 'Erste Saat', description: 'Learn your first 10 words.', metric: StatMetric.wordsLearned, target: 10),
  Achievement(id: 'ach-sprout', emoji: '🌱', title: 'Keimling', description: 'Learn 100 words.', metric: StatMetric.wordsLearned, target: 100),
  Achievement(id: 'ach-grove', emoji: '🌳', title: 'Hain', description: 'Learn 400 words.', metric: StatMetric.wordsLearned, target: 400),
  Achievement(id: 'ach-forest', emoji: '🌲', title: 'Wald', description: 'Learn 800 words.', metric: StatMetric.wordsLearned, target: 800),
  Achievement(id: 'ach-master-50', emoji: '🏵️', title: 'Fest verwurzelt', description: 'Master 50 words.', metric: StatMetric.wordsMastered, target: 50),
  Achievement(id: 'ach-master-250', emoji: '👑', title: 'Wortschatzkönig', description: 'Master 250 words.', metric: StatMetric.wordsMastered, target: 250),
  Achievement(id: 'ach-streak-3', emoji: '🔥', title: 'Dranbleiben', description: 'Study three days in a row.', metric: StatMetric.streak, target: 3),
  Achievement(id: 'ach-streak-14', emoji: '🔥', title: 'Zwei Wochen', description: 'Keep a 14-day streak.', metric: StatMetric.streak, target: 14),
  Achievement(id: 'ach-streak-60', emoji: '☄️', title: 'Unaufhaltsam', description: 'Keep a 60-day streak.', metric: StatMetric.streak, target: 60),
  Achievement(id: 'ach-xp-1000', emoji: '⚡', title: 'Tausend', description: 'Earn 1,000 XP.', metric: StatMetric.xp, target: 1000),
  Achievement(id: 'ach-xp-10000', emoji: '🌟', title: 'Zehntausend', description: 'Earn 10,000 XP.', metric: StatMetric.xp, target: 10000),
  Achievement(id: 'ach-lesson-10', emoji: '🧩', title: 'Baustein', description: 'Pass 10 lessons.', metric: StatMetric.lessonsPassed, target: 10),
  Achievement(id: 'ach-lesson-60', emoji: '🏗️', title: 'Fundament', description: 'Pass 60 lessons.', metric: StatMetric.lessonsPassed, target: 60),
  Achievement(id: 'ach-perfect-5', emoji: '💯', title: 'Fehlerfrei', description: 'Score 100% in five lessons.', metric: StatMetric.perfectLessons, target: 5),
  Achievement(id: 'ach-perfect-25', emoji: '🎯', title: 'Präzision', description: 'Score 100% in 25 lessons.', metric: StatMetric.perfectLessons, target: 25),
  Achievement(id: 'ach-story-1', emoji: '📖', title: 'Erste Seite', description: 'Finish your first story chapter.', metric: StatMetric.storyChapters, target: 1),
  Achievement(id: 'ach-story-10', emoji: '📚', title: 'Vielleser', description: 'Finish 10 story chapters.', metric: StatMetric.storyChapters, target: 10),
  Achievement(id: 'ach-story-33', emoji: '🏛️', title: 'Bibliothek', description: 'Finish every bundled story chapter.', metric: StatMetric.storyChapters, target: 33),
  Achievement(id: 'ach-talk-1', emoji: '🗣️', title: 'Erstes Gespräch', description: 'Complete one AI role-play.', metric: StatMetric.conversationsCompleted, target: 1),
  Achievement(id: 'ach-talk-8', emoji: '🎙️', title: 'Redegewandt', description: 'Complete 8 AI role-plays.', metric: StatMetric.conversationsCompleted, target: 8),
  Achievement(id: 'ach-turns-100', emoji: '💬', title: 'Hundert Sätze', description: 'Speak or write 100 conversation turns.', metric: StatMetric.speakingTurns, target: 100),
  Achievement(id: 'ach-level-3', emoji: '🪜', title: 'Aufstieg', description: 'Unlock three CEFR levels.', metric: StatMetric.levelsUnlocked, target: 3),
  Achievement(id: 'ach-level-6', emoji: '🏔️', title: 'Gipfel', description: 'Unlock all six CEFR levels.', metric: StatMetric.levelsUnlocked, target: 6),
  Achievement(id: 'ach-goal-7', emoji: '✅', title: 'Sieben Tage Ziel', description: 'Hit the daily goal seven times.', metric: StatMetric.dailyGoalsHit, target: 7),
  Achievement(id: 'ach-goal-30', emoji: '📅', title: 'Ein Monat', description: 'Hit the daily goal 30 times.', metric: StatMetric.dailyGoalsHit, target: 30),
  Achievement(id: 'ach-fix-25', emoji: '🩹', title: 'Aufgeräumt', description: 'Clear 25 items from the mistake bank.', metric: StatMetric.mistakesCleared, target: 25),
  Achievement(id: 'ach-mem-10', emoji: '🧠', title: 'Eselsbrücken', description: 'Write 10 of your own mnemonics.', metric: StatMetric.mnemonicsWritten, target: 10),
];

/// Counters that reset at midnight and drive the rotating daily quests.
enum DailyMetric { reviews, xp, lessons, storyChapters, conversationTurns, perfectAnswers }

class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.emoji,
    required this.title,
    required this.metric,
    required this.target,
    required this.reward,
  });

  final String id;
  final String emoji;
  final String title;
  final DailyMetric metric;
  final int target;

  /// Bonus XP granted once, when the quest is first completed.
  final int reward;
}

const List<DailyQuest> questPool = <DailyQuest>[
  DailyQuest(id: 'q-reviews-20', emoji: '🌱', title: 'Complete 20 learning actions', metric: DailyMetric.reviews, target: 20, reward: 30),
  DailyQuest(id: 'q-reviews-40', emoji: '🌿', title: 'Complete 40 learning actions', metric: DailyMetric.reviews, target: 40, reward: 60),
  DailyQuest(id: 'q-xp-150', emoji: '⚡', title: 'Earn 150 XP today', metric: DailyMetric.xp, target: 150, reward: 30),
  DailyQuest(id: 'q-xp-300', emoji: '🌟', title: 'Earn 300 XP today', metric: DailyMetric.xp, target: 300, reward: 60),
  DailyQuest(id: 'q-lesson-2', emoji: '🧩', title: 'Finish 2 lessons', metric: DailyMetric.lessons, target: 2, reward: 40),
  DailyQuest(id: 'q-lesson-4', emoji: '🏗️', title: 'Finish 4 lessons', metric: DailyMetric.lessons, target: 4, reward: 70),
  DailyQuest(id: 'q-story-1', emoji: '📖', title: 'Read one story chapter', metric: DailyMetric.storyChapters, target: 1, reward: 35),
  DailyQuest(id: 'q-talk-6', emoji: '🗣️', title: 'Speak 6 conversation turns', metric: DailyMetric.conversationTurns, target: 6, reward: 45),
  DailyQuest(id: 'q-talk-12', emoji: '🎙️', title: 'Speak 12 conversation turns', metric: DailyMetric.conversationTurns, target: 12, reward: 80),
  DailyQuest(id: 'q-perfect-10', emoji: '🎯', title: 'Get 10 answers right first time', metric: DailyMetric.perfectAnswers, target: 10, reward: 40),
];

/// Picks three quests for a given day. Deterministic, so the set does not
/// reshuffle every time the app is reopened, and offline, so no server is
/// needed to hand out a daily challenge.
List<DailyQuest> questsForDay(String dayKey) {
  if (questPool.isEmpty) return const <DailyQuest>[];
  int hash = 7;
  for (final int unit in dayKey.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  final List<DailyQuest> pool = List<DailyQuest>.from(questPool);
  final List<DailyQuest> chosen = <DailyQuest>[];
  for (int i = 0; i < 3 && pool.isNotEmpty; i++) {
    hash = (hash * 1103515245 + 12345) & 0x7fffffff;
    chosen.add(pool.removeAt(hash % pool.length));
  }
  return chosen;
}
