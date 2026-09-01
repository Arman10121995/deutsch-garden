/// The course, on screen.
///
/// Three screens: the map of all seventy-two units, one unit, and the
/// checkpoint that gates it. Every step opens a screen that already exists —
/// the course does not reimplement a grammar lesson, it points at one — so
/// this file is mostly routing and state display.
library;

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'conversation.dart';
import 'conversation_screens.dart';
import 'course.dart';
import 'games.dart';
import 'lesson_registry.dart';
import 'matching.dart';
import 'models.dart';
import 'radio.dart';
import 'radio_screens.dart';
import 'skill_screens.dart';
import 'stories.dart';
import 'story_screens.dart';
import 'study_session.dart';
import 'dart:math';
import 'answer_shuffle.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        final List<CourseUnitStatus> status = courseStatus(
          activities: controller.activities,
          wordsSeenByLevel: controller.wordsSeenByLevel,
          placementLevel: controller.highestUnlockedLevel,
        );
        final CourseUnitStatus? next = nextUnit(
          status,
          preferredLevel: controller.highestUnlockedLevel,
        );
        final int done = status
            .where((CourseUnitStatus s) => s.complete)
            .length;

        // No Scaffold: this is a tab body, and the shell already provides
        // one. Every other tab follows the same shape.
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: <Widget>[
              _ContinueCard(
                controller: controller,
                next: next,
                done: done,
                total: status.length,
              ),
              const SizedBox(height: 20),
              for (final CefrLevel level in CefrLevel.values)
                _LevelSection(
                  controller: controller,
                  level: level,
                  status: status
                      .where((CourseUnitStatus s) => s.unit.level == level)
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.controller,
    required this.next,
    required this.done,
    required this.total,
  });

  final AppController controller;
  final CourseUnitStatus? next;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CourseUnitStatus? target = next;
    if (target == null) return const SizedBox.shrink();

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'The course · $done of $total units passed',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                backgroundColor: theme.colorScheme.onPrimaryContainer
                    .withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${target.unit.level.label} · Unit ${target.unit.number} — '
              '${target.unit.title}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              target.unit.canDo,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => openCourseUnit(context, controller, target.unit),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({
    required this.controller,
    required this.level,
    required this.status,
  });

  final AppController controller;
  final CefrLevel level;
  final List<CourseUnitStatus> status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int passed = status.where((CourseUnitStatus s) => s.complete).length;
    final bool anyOpen = status.any((CourseUnitStatus s) => s.unlocked);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        initiallyExpanded: anyOpen && passed < status.length,
        title: Text(
          '${level.label} · ${level.description}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text('$passed of ${status.length} units passed'),
        leading: CircleAvatar(
          backgroundColor: passed == status.length
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          child: Text(
            level.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: passed == status.length
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        children: <Widget>[
          for (final CourseUnitStatus s in status)
            _UnitTile(controller: controller, status: s),
        ],
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.controller, required this.status});

  final AppController controller;
  final CourseUnitStatus status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CourseUnit unit = status.unit;
    final bool locked = !status.unlocked;

    return ListTile(
      enabled: !locked,
      leading: _UnitBadge(status: status),
      title: Text(
        'Unit ${unit.number} — ${unit.title}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: locked ? theme.disabledColor : null,
        ),
      ),
      subtitle: Text(
        locked
            ? 'Pass the checkpoint before this to open it'
            : '${status.stepsDone}/${status.stepsTotal} done'
                  '${status.complete ? ' · passed ${status.checkpointBest}%' : ''}',
      ),
      trailing: unit.isReview
          ? const Icon(Icons.replay, size: 20)
          : const Icon(Icons.chevron_right),
      onTap: locked ? null : () => openCourseUnit(context, controller, unit),
    );
  }
}

class _UnitBadge extends StatelessWidget {
  const _UnitBadge({required this.status});

  final CourseUnitStatus status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (!status.unlocked) {
      return Icon(Icons.lock_outline, color: theme.disabledColor);
    }
    if (status.complete) {
      return Icon(Icons.check_circle, color: theme.colorScheme.primary);
    }
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(value: status.progress, strokeWidth: 3),
    );
  }
}

void openCourseUnit(
  BuildContext context,
  AppController controller,
  CourseUnit u,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => CourseUnitScreen(controller: controller, unit: u),
    ),
  );
}

// ---------------------------------------------------------------------------

class CourseUnitScreen extends StatelessWidget {
  const CourseUnitScreen({
    super.key,
    required this.controller,
    required this.unit,
  });

  final AppController controller;
  final CourseUnit unit;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        final ThemeData theme = Theme.of(context);
        final CourseUnitStatus status = courseStatus(
          activities: controller.activities,
          wordsSeenByLevel: controller.wordsSeenByLevel,
          placementLevel: controller.highestUnlockedLevel,
        ).firstWhere((CourseUnitStatus s) => s.unit.id == unit.id);
        final CourseStep? next = nextCoreStep(status, controller.activities);

        return Scaffold(
          appBar: AppBar(
            title: Text('${unit.level.label} · Unit ${unit.number}'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: <Widget>[
              Text(
                unit.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: theme.colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'By the end of this unit',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        unit.canDo,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _UnitContinueCard(
                controller: controller,
                unit: unit,
                next: next,
                checkpointReady: next == null && !status.checkpointPassed,
              ),
              const SizedBox(height: 20),
              Text(
                'Core path · ${status.stepsDone}/${status.stepsTotal}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'These activities prepare the checkpoint and are shown in '
                'the order to do them.',
              ),
              const SizedBox(height: 8),
              for (final CourseStep step in unit.coreSteps)
                _StepTile(
                  controller: controller,
                  unit: unit,
                  step: step,
                  status: status,
                ),
              if (unit.enrichmentSteps.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.add_circle_outline_rounded),
                    title: const Text(
                      'Extra practice',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      '${unit.enrichmentSteps.length} stories, broadcasts, '
                      'writing or speaking activities · optional',
                    ),
                    children: <Widget>[
                      for (final CourseStep step in unit.enrichmentSteps)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _StepTile(
                            controller: controller,
                            unit: unit,
                            step: step,
                            status: status,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _CheckpointCard(
                controller: controller,
                unit: unit,
                status: status,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UnitContinueCard extends StatelessWidget {
  const _UnitContinueCard({
    required this.controller,
    required this.unit,
    required this.next,
    required this.checkpointReady,
  });

  final AppController controller;
  final CourseUnit unit;
  final CourseStep? next;
  final bool checkpointReady;

  @override
  Widget build(BuildContext context) {
    final CourseStep? step = next;
    final bool passed = step == null && !checkpointReady;
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          passed
              ? Icons.check_circle_rounded
              : checkpointReady
              ? Icons.flag_rounded
              : Icons.play_arrow_rounded,
          color: colors.onPrimaryContainer,
        ),
        title: Text(
          passed
              ? 'Unit passed'
              : checkpointReady
              ? 'Core complete — take the checkpoint'
              : step!.title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: colors.onPrimaryContainer,
          ),
        ),
        subtitle: Text(
          passed
              ? 'Extra practice remains available whenever you want it.'
              : checkpointReady
              ? '$courseCheckpointPass% opens the next unit.'
              : 'Next required activity',
          style: TextStyle(color: colors.onPrimaryContainer),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colors.onPrimaryContainer,
        ),
        onTap: checkpointReady
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      CheckpointScreen(controller: controller, unit: unit),
                ),
              )
            : step == null
            ? null
            : () => openCourseStep(context, controller, unit, step),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.controller,
    required this.unit,
    required this.step,
    required this.status,
  });

  final AppController controller;
  final CourseUnit unit;
  final CourseStep step;
  final CourseUnitStatus status;

  static const Map<CourseStepKind, IconData> _icons =
      <CourseStepKind, IconData>{
        CourseStepKind.grammar: Icons.rule,
        CourseStepKind.listening: Icons.headphones,
        CourseStepKind.reading: Icons.menu_book,
        CourseStepKind.writing: Icons.edit_note,
        CourseStepKind.speaking: Icons.record_voice_over,
        CourseStepKind.story: Icons.auto_stories,
        CourseStepKind.conversation: Icons.forum,
        CourseStepKind.radio: Icons.podcasts,
        CourseStepKind.vocabulary: Icons.style,
        CourseStepKind.matching: Icons.grid_view_rounded,
        CourseStepKind.sentenceBuilder: Icons.view_week_outlined,
        CourseStepKind.dictation: Icons.hearing_rounded,
      };

  static const Map<CourseStepKind, String> _labels = <CourseStepKind, String>{
    CourseStepKind.grammar: 'Grammar',
    CourseStepKind.listening: 'Listening',
    CourseStepKind.reading: 'Reading',
    CourseStepKind.writing: 'Writing',
    CourseStepKind.speaking: 'Speaking',
    CourseStepKind.story: 'Story',
    CourseStepKind.conversation: 'Role-play',
    CourseStepKind.radio: 'Gartenradio',
    CourseStepKind.vocabulary: 'Vocabulary',
    CourseStepKind.matching: 'Matching',
    CourseStepKind.sentenceBuilder: 'Sentence builder',
    CourseStepKind.dictation: 'Dictation',
  };

  bool get _done => courseStepDone(status, step, controller.activities);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int matchingSeen = step.kind == CourseStepKind.matching
        ? controller.matchingWordsForLevel(unit.level).length
        : matchingPairsPerRound;
    final bool matchingLocked =
        step.kind == CourseStepKind.matching &&
        matchingSeen < matchingPairsPerRound;
    final String subtitle = step.isVocabulary
        ? '${status.wordsMet} of ${unit.wordTarget} ${unit.level.label} '
              'words met'
        : matchingLocked
        ? 'Locked · learn ${matchingPairsPerRound - matchingSeen} more distinct '
              '${unit.level.label} words first'
        : _labels[step.kind]!;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        _done ? Icons.check_circle : _icons[step.kind],
        color: _done ? theme.colorScheme.primary : null,
      ),
      title: Text(step.title),
      subtitle: Text(subtitle),
      trailing: Icon(
        matchingLocked ? Icons.lock_outline_rounded : Icons.chevron_right,
      ),
      onTap: matchingLocked
          ? null
          : () => openCourseStep(context, controller, unit, step),
    );
  }
}

/// Route a step to the screen that already knows how to run it.
///
/// A step that cannot be resolved is a bug in the spine rather than something
/// the learner did, so it says so plainly instead of doing nothing.
Future<void> openCourseStep(
  BuildContext context,
  AppController controller,
  CourseUnit unit,
  CourseStep step,
) async {
  Widget? screen;

  if (step.isVocabulary) {
    // A guided path starts the work directly. Opening the level catalogue here
    // forced a second decision between Learn, Review and Mixed practice.
    screen = StudySessionScreen(
      controller: controller,
      kind: SessionKind.learn,
      level: unit.level,
    );
  } else if (step.kind == CourseStepKind.matching) {
    screen = MatchPairsScreen(
      controller: controller,
      level: unit.level,
      activityId: step.completionIds.single,
    );
  } else if (step.kind == CourseStepKind.sentenceBuilder) {
    screen = SentenceBuilderScreen(
      controller: controller,
      level: unit.level,
      activityId: step.completionIds.single,
    );
  } else if (step.kind == CourseStepKind.dictation) {
    screen = DictationScreen(
      controller: controller,
      level: unit.level,
      activityId: step.completionIds.single,
    );
  } else if (step.kind == CourseStepKind.story) {
    for (final Story story in storiesFor(unit.level)) {
      if (story.id == step.route) {
        screen = StoryDetailScreen(controller: controller, story: story);
      }
    }
  } else if (step.kind == CourseStepKind.conversation) {
    for (final ConversationScenario s in conversationsFor(unit.level)) {
      if (s.id == step.route) {
        screen = ConversationScreen(controller: controller, scenario: s);
      }
    }
  } else if (step.kind == CourseStepKind.radio) {
    for (final RadioEpisode e in radioFor(unit.level)) {
      if (e.id == step.route) {
        screen = RadioEpisodeScreen(controller: controller, episode: e);
      }
    }
  } else {
    for (final LessonRef ref in allLessons) {
      if (ref.id != step.route) continue;
      final Object lesson = ref.lesson;
      if (lesson is GrammarLesson) {
        screen = GrammarLessonScreen(controller: controller, lesson: lesson);
      } else if (lesson is ListeningLesson) {
        screen = ListeningLessonScreen(controller: controller, lesson: lesson);
      } else if (lesson is ReadingLesson) {
        screen = ReadingLessonScreen(controller: controller, lesson: lesson);
      } else if (lesson is WritingLesson) {
        screen = WritingLessonScreen(controller: controller, lesson: lesson);
      } else if (lesson is SpeakingLesson) {
        screen = SpeakingLessonScreen(controller: controller, lesson: lesson);
      }
    }
  }

  final Widget? target = screen;
  if (target == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('“${step.title}” could not be opened.')),
    );
    return;
  }
  await Navigator.of(
    context,
  ).push<void>(MaterialPageRoute<void>(builder: (_) => target));
}

class _CheckpointCard extends StatelessWidget {
  const _CheckpointCard({
    required this.controller,
    required this.unit,
    required this.status,
  });

  final AppController controller;
  final CourseUnit unit;
  final CourseUnitStatus status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool passed = status.checkpointPassed;
    final String best = status.checkpointBest > 0
        ? ' Best so far: ${status.checkpointBest}%.'
        : '';
    final String blurb = passed
        ? 'Passed with ${status.checkpointBest}%. You can sit it again '
              'whenever you like.'
        : '${unit.checkpoint.length} questions drawn from this unit. '
              '$courseCheckpointPass% opens the next unit.$best';

    return Card(
      color: passed
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(passed ? Icons.verified : Icons.flag_outlined),
                const SizedBox(width: 8),
                Text(
                  'Checkpoint',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(blurb),
            if (!passed && !status.ready) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'You can sit it now, but the core steps above are what it tests.',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      CheckpointScreen(controller: controller, unit: unit),
                ),
              ),
              child: Text(passed ? 'Sit it again' : 'Start the checkpoint'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class CheckpointScreen extends StatefulWidget {
  const CheckpointScreen({
    super.key,
    required this.controller,
    required this.unit,
  });

  final AppController controller;
  final CourseUnit unit;

  @override
  State<CheckpointScreen> createState() => _CheckpointScreenState();
}

class _CheckpointScreenState extends State<CheckpointScreen> {
  int _index = 0;
  int _correct = 0;
  int? _picked;
  bool _done = false;
  final Map<int, int> _picks = <int, int>{};

  List<ChoiceQuestion> get _questions => widget.unit.checkpoint;

  /// Fixed once per sitting, so the option order is stable while a question is
  /// on screen and different next time. See lib/answer_shuffle.dart.
  final int _shuffleSalt = Random().nextInt(0x7fffffff);

  ChoiceQuestion get _question {
    final ChoiceQuestion raw = _questions[_index];
    return raw.shuffled(seededFor(raw.prompt, _shuffleSalt));
  }

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      '${widget.unit.level.label} · unit ${widget.unit.number} checkpoint',
    );
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity(
      '${widget.unit.level.label} · unit ${widget.unit.number} checkpoint',
    );
    super.dispose();
  }

  Future<void> _pick(int index) async {
    if (_picked != null) return;
    setState(() {
      _picked = index;
      _picks[_index] = index;
    });
    if (index == _question.correctIndex) {
      _correct += 1;
      return;
    }
    // A checkpoint miss goes into the mistake book like any other, so the
    // thing that blocked progression is also the thing offered for review.
    await widget.controller.addMistake(
      MistakeEntry(
        id: '${widget.unit.checkpointId}-q$_index',
        prompt: _question.prompt,
        correctAnswer: _question.options[_question.correctIndex],
        givenAnswer: _question.options[index],
        source: 'checkpoint',
        level: widget.unit.level.label,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _next() async {
    if (_index + 1 < _questions.length) {
      setState(() {
        _index += 1;
        _picked = _picks[_index];
      });
      return;
    }
    final int score = ((_correct / _questions.length) * 100).round();
    await widget.controller.recordActivity(
      widget.unit.checkpointId,
      score: score,
      passingScore: courseCheckpointPass,
    );
    if (!mounted) return;
    setState(() => _done = true);
  }

  void _previous() {
    if (_index <= 0) return;
    setState(() {
      _index -= 1;
      _picked = _picks[_index];
    });
  }

  void _reviewLastQuestion() {
    setState(() {
      _done = false;
      _index = _questions.length - 1;
      _picked = _picks[_index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (_done) return _result(theme);

    final ChoiceQuestion question = _question;
    final int? picked = _picked;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkpoint · Unit ${widget.unit.number}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / _questions.length,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: <Widget>[
          Text(
            'Question ${_index + 1} of ${_questions.length}',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 10),
          Text(
            question.prompt,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < question.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionButton(
                label: question.options[i],
                state: picked == null
                    ? _OptionState.idle
                    : i == question.correctIndex
                    ? _OptionState.correct
                    : i == picked
                    ? _OptionState.wrong
                    : _OptionState.idle,
                onTap: picked == null ? () => _pick(i) : null,
              ),
            ),
          if (picked != null) ...<Widget>[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(question.explanation),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                if (_index > 0)
                  OutlinedButton.icon(
                    onPressed: _previous,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Previous'),
                  ),
                if (_index > 0) const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _next,
                    child: Text(
                      _index + 1 < _questions.length ? 'Next' : 'Finish',
                    ),
                  ),
                ),
              ],
            ),
          ] else if (_index > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _previous,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Previous'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _result(ThemeData theme) {
    final int score = ((_correct / _questions.length) * 100).round();
    final bool passed = score >= courseCheckpointPass;
    return Scaffold(
      appBar: AppBar(title: Text('Checkpoint · Unit ${widget.unit.number}')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(passed ? '🎉' : '🌱', style: const TextStyle(fontSize: 54)),
              const SizedBox(height: 12),
              Text(
                '$score%',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text('$_correct of ${_questions.length} correct'),
              const SizedBox(height: 18),
              Text(
                passed
                    ? widget.unit.canDo
                    : 'You need $courseCheckpointPass% to open the next unit. '
                          'The questions you missed are in the mistake book.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: _reviewLastQuestion,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Review questions'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to the unit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _OptionState { idle, correct, wrong }

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Color? background;
    switch (state) {
      case _OptionState.correct:
        background = theme.colorScheme.primaryContainer;
      case _OptionState.wrong:
        background = theme.colorScheme.errorContainer;
      case _OptionState.idle:
        background = null;
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        child: Text(label, textAlign: TextAlign.left),
      ),
    );
  }
}
