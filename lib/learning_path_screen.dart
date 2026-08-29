import 'package:flutter/material.dart';

import 'app_state.dart';
import 'course.dart';
import 'course_screens.dart';
import 'games.dart';
import 'learning_path.dart';
import 'lesson_registry.dart';
import 'models.dart';
import 'skill_screens.dart';

/// The app's default destination: one answer to "what should I do next?".
class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key, required this.controller});

  final AppController controller;

  Future<void> _push(BuildContext context, Widget screen) => Navigator.of(
    context,
  ).push<void>(MaterialPageRoute<void>(builder: (_) => screen));

  LearningPathPlan _plan() {
    final List<CourseUnitStatus> status = courseStatus(
      activities: controller.activities,
      wordsSeenByLevel: controller.wordsSeenByLevel,
      placementLevel: controller.highestUnlockedLevel,
    );
    return buildLearningPath(
      status: status,
      activities: controller.activities,
      dueWords: controller.dueCount,
      dueLessons: lessonsForIds(controller.dueActivityIds),
      mistakeCount: controller.mistakes.length,
      preferredLevel: controller.highestUnlockedLevel,
      includePracticeDrill: controller.guidedIncludesDrills,
    );
  }

  Future<void> _openAction(
    BuildContext context,
    LearningPathAction action,
  ) async {
    switch (action.kind) {
      case LearningPathActionKind.wordReview:
        await _push(
          context,
          ReviewSessionScreen(controller: controller, limit: 20),
        );
        return;
      case LearningPathActionKind.lessonReview:
        final LessonRef? lesson = action.lesson;
        if (lesson != null) {
          await _push(context, lessonScreenFor(controller, lesson));
        }
        return;
      case LearningPathActionKind.courseStep:
      case LearningPathActionKind.enrichment:
        final CourseUnit? unit = action.unit;
        final CourseStep? step = action.step;
        if (unit != null && step != null) {
          await openCourseStep(context, controller, unit, step);
        }
        return;
      case LearningPathActionKind.checkpoint:
        final CourseUnit? unit = action.unit;
        if (unit != null) {
          await _push(
            context,
            CheckpointScreen(controller: controller, unit: unit),
          );
        }
        return;
      case LearningPathActionKind.mistakeRepair:
        await _push(context, MistakeBankScreen(controller: controller));
        return;
      case LearningPathActionKind.practiceDrill:
        final PracticeDrill? drill = action.drill;
        if (drill != null) {
          await _push(context, _drillScreen(controller, drill));
        }
        return;
    }
  }

  /// Run the calculated path as one session. Each activity remains a normal
  /// route with its own pedagogy; after a completed route changes the plan,
  /// Learn offers the newly calculated next step without sending the learner
  /// back through a catalogue.
  Future<void> _startGuidedSession(
    BuildContext context,
    LearningPathAction first,
  ) async {
    LearningPathAction action = first;
    while (context.mounted) {
      final String completedId = action.id;
      await _openAction(context, action);
      if (!context.mounted) return;

      final LearningPathAction? next = _plan().next;
      // The same action means the learner backed out, did not pass, or reached
      // the deliberate per-session cap (20 reviews / 10 new words). In every
      // case, silently reopening it would feel like a loop rather than help.
      if (next == null || next.id == completedId) return;

      final bool continueSession = await _offerNext(context, next);
      if (!continueSession || !context.mounted) return;
      action = next;
    }
  }

  Future<bool> _offerNext(BuildContext context, LearningPathAction next) async {
    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Next in your guided session',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Icon(_iconFor(next.kind))),
                title: Text(
                  next.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${next.subtitle} · ~${next.estimatedMinutes} min',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Continue session'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Finish for now'),
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  void _openCourseMap(BuildContext context) {
    _push(
      context,
      Scaffold(
        appBar: AppBar(title: const Text('Course map')),
        body: CourseScreen(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final LearningPathPlan plan = _plan();
          final List<LearningPathAction> required = plan.requiredActions;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            children: <Widget>[
              _Header(controller: controller),
              const SizedBox(height: 20),
              if (plan.next case final LearningPathAction next)
                _NextCard(
                  action: next,
                  sessionSteps: required.length,
                  sessionMinutes: plan.estimatedMinutes,
                  onTap: () => _startGuidedSession(context, next),
                )
              else
                plan.courseComplete
                    ? const _CourseCompleteCard()
                    : const _CaughtUpCard(),
              if (required.length > 1) ...<Widget>[
                const SizedBox(height: 14),
                _SessionPlanCard(actions: required),
              ],
              const SizedBox(height: 22),
              if (plan.currentUnit case final CourseUnitStatus current)
                _CurrentUnitCard(
                  status: current,
                  unitsPassed: plan.unitsPassed,
                  unitsTotal: plan.unitsTotal,
                  onOpenUnit: () =>
                      openCourseUnit(context, controller, current.unit),
                  onOpenMap: () => _openCourseMap(context),
                ),
              if (plan.enrichment
                  case final LearningPathAction extra) ...<Widget>[
                const SizedBox(height: 14),
                _OptionalExtraCard(
                  action: extra,
                  onTap: () => _openAction(context, extra),
                ),
              ],
              const SizedBox(height: 14),
              _DailyProgressCard(controller: controller),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Learn German',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${controller.highestUnlockedLevel.label} · one guided path '
                'from review to new learning',
              ),
            ],
          ),
        ),
        _MetricPill(text: '🔥 ${controller.streak}'),
        const SizedBox(width: 7),
        _MetricPill(text: '⚡ ${controller.xp}'),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({
    required this.action,
    required this.sessionSteps,
    required this.sessionMinutes,
    required this.onTap,
  });

  final LearningPathAction action;
  final int sessionSteps;
  final int sessionMinutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'NEXT UP · $sessionSteps STEP${sessionSteps == 1 ? '' : 'S'} · '
              '~$sessionMinutes MIN',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              action.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              action.subtitle,
              style: TextStyle(color: colors.onPrimaryContainer),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onTap,
              icon: Icon(_iconFor(action.kind)),
              label: Text(
                sessionSteps == 1
                    ? 'Start next activity'
                    : 'Start guided session',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionPlanCard extends StatelessWidget {
  const _SessionPlanCard({required this.actions});

  final List<LearningPathAction> actions;

  @override
  Widget build(BuildContext context) {
    final int minutes = actions.fold<int>(
      0,
      (int total, LearningPathAction action) => total + action.estimatedMinutes,
    );
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.playlist_add_check_circle_rounded),
        title: const Text(
          'Today’s guided session',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${actions.length} ordered steps · about $minutes minutes',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: <Widget>[
          for (int index = 0; index < actions.length; index++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(radius: 16, child: Text('${index + 1}')),
              title: Text(
                actions[index].title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${actions[index].subtitle} · '
                '~${actions[index].estimatedMinutes} min',
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionalExtraCard extends StatelessWidget {
  const _OptionalExtraCard({required this.action, required this.onTap});

  final LearningPathAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.add_circle_outline_rounded),
        title: const Text(
          'Optional extra',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${action.title} · ~${action.estimatedMinutes} min\n'
          'Attached to this unit, but never required for progression.',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _CurrentUnitCard extends StatelessWidget {
  const _CurrentUnitCard({
    required this.status,
    required this.unitsPassed,
    required this.unitsTotal,
    required this.onOpenUnit,
    required this.onOpenMap,
  });

  final CourseUnitStatus status;
  final int unitsPassed;
  final int unitsTotal;
  final VoidCallback onOpenUnit;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.route_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${status.unit.level.label} · Unit ${status.unit.number} '
                    '— ${status.unit.title}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(status.unit.canDo),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: status.progress, minHeight: 7),
            const SizedBox(height: 5),
            Text(
              '${status.stepsDone}/${status.stepsTotal} core activities · '
              '$unitsPassed/$unitsTotal units passed',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton(
                  onPressed: onOpenUnit,
                  child: const Text('Unit details'),
                ),
                TextButton(
                  onPressed: onOpenMap,
                  child: const Text('Full course map'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyProgressCard extends StatelessWidget {
  const _DailyProgressCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final quests = controller.todaysQuests;
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.today_rounded),
        title: const Text(
          'Today’s progress',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${controller.todayReviews}/${controller.dailyGoal} learning actions',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: <Widget>[
          LinearProgressIndicator(
            value: controller.dailyGoalProgress,
            minHeight: 7,
          ),
          const SizedBox(height: 14),
          for (final quest in quests)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  Text(controller.isQuestComplete(quest) ? '✅' : quest.emoji),
                  const SizedBox(width: 8),
                  Expanded(child: Text(quest.title)),
                  Text(
                    '${controller.questProgress(quest)}/${quest.target}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CaughtUpCard extends StatelessWidget {
  const _CaughtUpCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(22),
        child: Column(
          children: <Widget>[
            Text('🌿', style: TextStyle(fontSize: 46)),
            SizedBox(height: 8),
            Text(
              'You are caught up',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              'There is no required activity right now. Optional practice '
              'stays below, and scheduled reviews will return automatically.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCompleteCard extends StatelessWidget {
  const _CourseCompleteCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(22),
        child: Column(
          children: <Widget>[
            Text('🌳', style: TextStyle(fontSize: 46)),
            SizedBox(height: 8),
            Text(
              'The guided course is complete',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              'Spaced reviews and optional enrichment will continue to appear '
              'here as they become useful.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(LearningPathActionKind kind) {
  switch (kind) {
    case LearningPathActionKind.wordReview:
      return Icons.style_rounded;
    case LearningPathActionKind.lessonReview:
      return Icons.refresh_rounded;
    case LearningPathActionKind.courseStep:
      return Icons.play_arrow_rounded;
    case LearningPathActionKind.checkpoint:
      return Icons.flag_rounded;
    case LearningPathActionKind.mistakeRepair:
      return Icons.healing_rounded;
    case LearningPathActionKind.enrichment:
      return Icons.add_circle_outline_rounded;
    case LearningPathActionKind.practiceDrill:
      return Icons.fitness_center_rounded;
  }
}

/// The screen behind each drill the path can hand out.
///
/// Every one of these already existed and was reachable only by going to
/// Explore and choosing it. Nothing here is a new exercise; what is new is
/// that the learner no longer has to know to go looking.
Widget _drillScreen(AppController controller, PracticeDrill drill) {
  final CefrLevel level = controller.highestUnlockedLevel;
  switch (drill) {
    case PracticeDrill.matchPairs:
      return MatchPairsScreen(controller: controller, level: level);
    case PracticeDrill.sentenceBuilder:
      return SentenceBuilderScreen(controller: controller, level: level);
    case PracticeDrill.cloze:
      return ClozeDrillScreen(controller: controller, level: level);
    case PracticeDrill.articles:
      return ArticleTrainerScreen(controller: controller, level: level);
    case PracticeDrill.verbs:
      return VerbLabScreen(controller: controller, level: level);
    case PracticeDrill.speedReview:
      return SpeedReviewScreen(controller: controller, level: level);
    case PracticeDrill.dictation:
      return DictationScreen(controller: controller, level: level);
  }
}
