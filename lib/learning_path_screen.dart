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

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _openAction(BuildContext context, LearningPathAction action) {
    switch (action.kind) {
      case LearningPathActionKind.wordReview:
        _push(context, ReviewSessionScreen(controller: controller, limit: 20));
        return;
      case LearningPathActionKind.lessonReview:
        final LessonRef? lesson = action.lesson;
        if (lesson != null) _push(context, lessonScreenFor(controller, lesson));
        return;
      case LearningPathActionKind.courseStep:
      case LearningPathActionKind.enrichment:
        final CourseUnit? unit = action.unit;
        final CourseStep? step = action.step;
        if (unit != null && step != null) {
          openCourseStep(context, controller, unit, step);
        }
        return;
      case LearningPathActionKind.checkpoint:
        final CourseUnit? unit = action.unit;
        if (unit != null) {
          _push(context, CheckpointScreen(controller: controller, unit: unit));
        }
        return;
      case LearningPathActionKind.mistakeRepair:
        _push(context, MistakeBankScreen(controller: controller));
        return;
    }
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
          final List<CourseUnitStatus> status = courseStatus(
            activities: controller.activities,
            wordsSeenByLevel: controller.wordsSeenByLevel,
            placementLevel: controller.highestUnlockedLevel,
          );
          final LearningPathPlan plan = buildLearningPath(
            status: status,
            activities: controller.activities,
            dueWords: controller.dueCount,
            dueLessons: lessonsForIds(controller.dueActivityIds),
            mistakeCount: controller.mistakes.length,
            preferredLevel: controller.highestUnlockedLevel,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            children: <Widget>[
              _Header(controller: controller),
              const SizedBox(height: 20),
              if (plan.next case final LearningPathAction next)
                _NextCard(action: next, onTap: () => _openAction(context, next))
              else
                const _CourseCompleteCard(),
              if (plan.actions.length > 1) ...<Widget>[
                const SizedBox(height: 22),
                Text(
                  'Your next session',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  'This queue updates automatically when you finish or review '
                  'something. Optional enrichment never blocks progress.',
                ),
                const SizedBox(height: 10),
                for (int i = 1; i < plan.actions.length; i++)
                  _PlanTile(
                    number: i + 1,
                    action: plan.actions[i],
                    onTap: () => _openAction(context, plan.actions[i]),
                  ),
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
  const _NextCard({required this.action, required this.onTap});

  final LearningPathAction action;
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
              'NEXT UP · ~${action.estimatedMinutes} MIN',
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
              label: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.number,
    required this.action,
    required this.onTap,
  });

  final int number;
  final LearningPathAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            child: action.isOptional
                ? const Icon(Icons.add_rounded)
                : Text('$number'),
          ),
          title: Text(
            action.title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${action.subtitle} · ~${action.estimatedMinutes} min',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
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
  }
}
