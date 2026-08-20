import 'curriculum.dart';
import 'models.dart';

/// One reviewable lesson, flattened across the five skill tracks.
///
/// Progress is stored against an opaque activity id. To show a learner *what*
/// is due — rather than a list of ids like `gr-b1-07` — something has to map
/// that id back to a title, a level and a skill. That is all this does.
class LessonRef {
  const LessonRef({
    required this.id,
    required this.title,
    required this.level,
    required this.skill,
    required this.lesson,
  });

  final String id;
  final String title;
  final CefrLevel level;
  final SkillType skill;

  /// The concrete lesson — a [GrammarLesson], [ListeningLesson],
  /// [ReadingLesson], [WritingLesson] or [SpeakingLesson]. Held as [Object] so
  /// this file stays free of any dependency on the widget layer; the UI
  /// switches on [skill] and casts.
  final Object lesson;
}

List<LessonRef>? _cache;

/// Every lesson in the app, built once and reused.
///
/// The five accessors are lazy `Iterable`s over const tables, so flattening
/// them costs one pass the first time anything asks and nothing afterwards.
List<LessonRef> get allLessons {
  final List<LessonRef>? cached = _cache;
  if (cached != null) return cached;

  final List<LessonRef> lessons = <LessonRef>[];
  for (final CefrLevel level in CefrLevel.values) {
    for (final GrammarLesson lesson in grammarFor(level)) {
      lessons.add(LessonRef(
        id: lesson.id,
        title: lesson.title,
        level: level,
        skill: SkillType.grammar,
        lesson: lesson,
      ));
    }
    for (final ListeningLesson lesson in listeningFor(level)) {
      lessons.add(LessonRef(
        id: lesson.id,
        title: lesson.title,
        level: level,
        skill: SkillType.listening,
        lesson: lesson,
      ));
    }
    for (final ReadingLesson lesson in readingFor(level)) {
      lessons.add(LessonRef(
        id: lesson.id,
        title: lesson.title,
        level: level,
        skill: SkillType.reading,
        lesson: lesson,
      ));
    }
    for (final WritingLesson lesson in writingFor(level)) {
      lessons.add(LessonRef(
        id: lesson.id,
        title: lesson.title,
        level: level,
        skill: SkillType.writing,
        lesson: lesson,
      ));
    }
    for (final SpeakingLesson lesson in speakingFor(level)) {
      lessons.add(LessonRef(
        id: lesson.id,
        title: lesson.title,
        level: level,
        skill: SkillType.speaking,
        lesson: lesson,
      ));
    }
  }
  _cache = lessons;
  return lessons;
}

Map<String, LessonRef>? _byIdCache;

Map<String, LessonRef> get _byId =>
    _byIdCache ??= <String, LessonRef>{
      for (final LessonRef lesson in allLessons) lesson.id: lesson,
    };

/// The lesson with this activity id, or null when the id belongs to something
/// that is not a lesson — a story chapter or a role-play, which carry their own
/// progress under the same map.
LessonRef? lessonForId(String id) => _byId[id];

/// Resolves a list of activity ids to lessons, dropping ids that are not
/// lessons. Order is preserved, because the caller has already sorted by due
/// date and that order is the review order.
List<LessonRef> lessonsForIds(Iterable<String> ids) {
  final List<LessonRef> resolved = <LessonRef>[];
  for (final String id in ids) {
    final LessonRef? lesson = _byId[id];
    if (lesson != null) resolved.add(lesson);
  }
  return resolved;
}
