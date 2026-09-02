import 'l10n/app_localizations.dart';
import 'dart:math';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'assessment.dart';
import 'civics_test_screens.dart';
import 'driving_test_screens.dart';
import 'models.dart';
import 'answer_shuffle.dart';
import 'test_prep.dart';
import 'tts_service.dart';

class TestHubScreen extends StatelessWidget {
  const TestHubScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
          children: <Widget>[
            Text(
              'Tests & exam prep',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Diagnose your current level, practise CEFR-style exam skills, and prepare with the official German civics question catalogue.',
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: const Text('🎯', style: TextStyle(fontSize: 38)),
                title: const Text(
                  'Adaptive placement assessment',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  controller.lastPlacementLevel.isEmpty
                      ? 'A1–C2 diagnostic across vocabulary, grammar, reading and listening.'
                      : 'Last result: ${controller.lastPlacementLevel} • ${controller.lastPlacementScore}% • ${controller.lastPlacementDate}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        PlacementIntroScreen(controller: controller),
                  ),
                ),
              ),
            ),
            if (controller.placementPredatesShuffle) ...<Widget>[
              const SizedBox(height: 10),
              _StalePlacementNotice(controller: controller),
            ],
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: const Text('🇩🇪', style: TextStyle(fontSize: 38)),
                title: const Text(
                  'Leben in Deutschland & citizenship',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text(
                  'All 300 general and 160 state questions, Bundesland practice, 60-minute mocks and mistake review — fully offline.',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => CivicsHubScreen(controller: controller),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: const Text('🚘', style: TextStyle(fontSize: 38)),
                title: const Text(
                  'German driving theory · Class B',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: const Text(
                  '72 original offline questions, topic practice, bilingual helper and a 30-question mock across danger awareness, signs, right of way, motorway driving, technology and fitness.',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => DrivingTheoryScreen(controller: controller),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Exam preparation',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...CefrLevel.values.map((level) {
              final profile = examProfileFor(level);
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    child: Text(
                      level.label,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  title: Text(
                    '${level.label} exam training',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    'Reading ${profile.readingMinutes}m • Listening ${profile.listeningMinutes}m • Writing ${profile.writingMinutes}m • Speaking ${profile.speakingMinutes}m',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ExamLevelPrepScreen(
                        controller: controller,
                        level: level,
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'DeutschGarden assessments and mini mocks are training instruments, not official Goethe exams and not CEFR certificates.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlacementIntroScreen extends StatelessWidget {
  const PlacementIntroScreen({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Placement assessment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          const Text(
            '🎯',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 12),
          Text(
            'Find your starting level',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          const Text(
            'The test begins at A1. Each CEFR band samples vocabulary, grammar, reading and listening. Strong performance advances you to the next band; the first unsupported band ends the test.',
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Assessment rules',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 8),
                  Text('• 6 items per level band'),
                  Text('• 4 domains: vocabulary, grammar, reading, listening'),
                  Text('• ≥67% advances to the next band'),
                  Text(
                    '• Results unlock an appropriate learning starting point',
                  ),
                  Text('• No external account or server is used'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Start assessment'),
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PlacementTestScreen(controller: controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlacementTestScreen extends StatefulWidget {
  const PlacementTestScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementSnapshot {
  const _PlacementSnapshot({
    required this.levelIndex,
    required this.questionIndex,
    required this.bandCorrect,
    required this.allCorrect,
    required this.allTotal,
    required this.answered,
    required this.selected,
    required this.result,
    required this.domainCorrect,
    required this.domainTotal,
    required this.bands,
  });

  final int levelIndex;
  final int questionIndex;
  final int bandCorrect;
  final int allCorrect;
  final int allTotal;
  final bool answered;
  final int? selected;
  final CefrLevel result;
  final Map<AssessmentDomain, int> domainCorrect;
  final Map<AssessmentDomain, int> domainTotal;
  final List<PlacementBandResult> bands;
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  final TtsService _tts = TtsService();
  int _levelIndex = 0;
  int _questionIndex = 0;
  int _bandCorrect = 0;
  int _allCorrect = 0;
  int _allTotal = 0;
  bool _answered = false;
  int? _selected;
  bool _done = false;
  CefrLevel _result = CefrLevel.a1;
  final Map<AssessmentDomain, int> _domainCorrect = <AssessmentDomain, int>{};
  final Map<AssessmentDomain, int> _domainTotal = <AssessmentDomain, int>{};
  final List<PlacementBandResult> _bands = <PlacementBandResult>[];
  final List<_PlacementSnapshot> _history = <_PlacementSnapshot>[];

  CefrLevel get _level => CefrLevel.values[_levelIndex];
  List<PlacementQuestion> get _questions => placementQuestionsFor(_level);

  /// Fixed once per sitting. The option order has to be stable while a
  /// question is on screen -- a rebuild that moved the options under a finger
  /// about to tap is its own wrong answer -- and different the next time the
  /// test is taken. Seeding from (question identity, this salt) gives both
  /// without keeping a shuffled copy in state.
  final int _shuffleSalt = Random().nextInt(0x7fffffff);

  /// Never the authored order. All sixty placement questions were written
  /// answer-first, so before this the top option was always right and the
  /// test placed anyone who tapped it at C2.
  PlacementQuestion get _question {
    final PlacementQuestion raw = _questions[_questionIndex];
    return raw.shuffled(seededFor(raw.id, _shuffleSalt));
  }

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Placement assessment');
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Placement assessment');
    _tts.stop();
    super.dispose();
  }

  void _answer(int index) {
    if (_answered) return;
    final q = _question;
    final correct = index == q.correctIndex;
    setState(() {
      _answered = true;
      _selected = index;
      _allTotal += 1;
      _domainTotal[q.domain] = (_domainTotal[q.domain] ?? 0) + 1;
      if (correct) {
        _bandCorrect += 1;
        _allCorrect += 1;
        _domainCorrect[q.domain] = (_domainCorrect[q.domain] ?? 0) + 1;
      }
    });
  }

  /// How many answers a band needs before its verdict is even considered.
  ///
  /// Every band carries ten items, but most learners are settled by six: a
  /// clean sweep or a clean miss is already outside the threshold's interval.
  /// The extra four exist for the learners six could not separate, which is
  /// precisely the population the old fixed six placed by coin flip.
  static const int _bandFloor = 6;

  Future<void> _next() async {
    _history.add(
      _PlacementSnapshot(
        levelIndex: _levelIndex,
        questionIndex: _questionIndex,
        bandCorrect: _bandCorrect,
        allCorrect: _allCorrect,
        allTotal: _allTotal,
        answered: _answered,
        selected: _selected,
        result: _result,
        domainCorrect: Map<AssessmentDomain, int>.from(_domainCorrect),
        domainTotal: Map<AssessmentDomain, int>.from(_domainTotal),
        bands: List<PlacementBandResult>.from(_bands),
      ),
    );
    final int answeredInBand = _questionIndex + 1;
    final PlacementBandResult running = PlacementBandResult(
      level: _level,
      correct: _bandCorrect,
      total: answeredInBand,
    );
    final bool settled =
        answeredInBand >= _bandFloor &&
        running.verdict() != BandVerdict.unclear;

    if (!settled && answeredInBand < _questions.length) {
      setState(() {
        _questionIndex += 1;
        _answered = false;
        _selected = null;
      });
      return;
    }

    final band = PlacementBandResult(
      level: _level,
      correct: _bandCorrect,
      total: answeredInBand,
    );
    _bands.add(band);
    // Where the interval still straddles the threshold after ten answers,
    // the point estimate decides -- but the result view says so rather than
    // presenting the band as measured.
    final passed =
        band.verdict() == BandVerdict.pass ||
        (band.verdict() == BandVerdict.unclear &&
            band.ratio >= placementThreshold);

    if (passed && _levelIndex < CefrLevel.values.length - 1) {
      setState(() {
        _result = _level;
        _levelIndex += 1;
        _questionIndex = 0;
        _bandCorrect = 0;
        _answered = false;
        _selected = null;
      });
      return;
    }

    CefrLevel result;
    if (passed) {
      result = _level;
    } else if (_levelIndex == 0) {
      result = CefrLevel.a1;
    } else {
      result = CefrLevel.values[_levelIndex - 1];
    }
    final score = _allTotal == 0
        ? 0
        : ((_allCorrect / _allTotal) * 100).round();
    await widget.controller.savePlacementResult(result, score: score);
    if (!mounted) return;
    setState(() {
      _result = result;
      _done = true;
    });
  }

  void _previous() {
    if (_history.isEmpty) return;
    final _PlacementSnapshot snapshot = _history.removeLast();
    setState(() {
      _levelIndex = snapshot.levelIndex;
      _questionIndex = snapshot.questionIndex;
      _bandCorrect = snapshot.bandCorrect;
      _allCorrect = snapshot.allCorrect;
      _allTotal = snapshot.allTotal;
      _answered = snapshot.answered;
      _selected = snapshot.selected;
      _result = snapshot.result;
      _domainCorrect
        ..clear()
        ..addAll(snapshot.domainCorrect);
      _domainTotal
        ..clear()
        ..addAll(snapshot.domainTotal);
      _bands
        ..clear()
        ..addAll(snapshot.bands);
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _resultView(context);
    final q = _question;
    final totalPotential = placementQuestions.length;
    final progress = min(1.0, (_allTotal + 1) / totalPotential);
    return Scaffold(
      appBar: AppBar(title: Text('Placement • ${_level.label}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          LinearProgressIndicator(value: progress, minHeight: 8),
          const SizedBox(height: 10),
          Text(
            '${q.domain.emoji} ${q.domain.label} • Item ${_questionIndex + 1}/${_questions.length}',
          ),
          if (q.contextText.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(q.contextText, style: const TextStyle(height: 1.5)),
              ),
            ),
          ],
          if (q.spokenText.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Play listening item'),
              onPressed: () => _tts.speakGerman(q.spokenText),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            q.prompt,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < q.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: _answered ? null : () => _answer(i),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(q.options[i]),
              ),
            ),
          if (_answered) ...<Widget>[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _selected == q.correctIndex ? 'Correct' : 'Not quite',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Text(q.explanation),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                if (_history.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: _previous,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Previous'),
                  ),
                if (_history.isNotEmpty) const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _next,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Text('Continue'),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (_history.isNotEmpty)
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

  /// States how firm the recommendation actually is.
  ///
  /// A band decided on ten answers is a sample, not a measurement, and a
  /// learner who is told "B1" with no qualification reasonably reads it as a
  /// verdict. Where the interval still straddles the pass mark after every
  /// item in the band, the honest thing is to say the two levels either side
  /// are both plausible and that they may move themselves.
  Widget _confidenceNote(BuildContext context) {
    if (_bands.isEmpty) return const SizedBox.shrink();
    final PlacementBandResult deciding = _bands.last;
    final bool firm = deciding.verdict() != BandVerdict.unclear;
    final String range = deciding.interval.toString();
    final String text = firm
        ? 'Decided on ${deciding.correct}/${deciding.total} at '
              '${deciding.level.label} ($range at 80% confidence).'
        : 'Borderline: ${deciding.correct}/${deciding.total} at '
              '${deciding.level.label} gives $range at 80% confidence, which '
              'still spans the pass mark. The level either side of this one is '
              'plausible too — change it in Profile if it feels wrong.';
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget _resultView(BuildContext context) {
    final overall = _allTotal == 0
        ? 0
        : ((_allCorrect / _allTotal) * 100).round();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Assessment result'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          const Text(
            '🎯',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 60),
          ),
          Text(
            _result.label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text('$overall% across attempted items', textAlign: TextAlign.center),
          const SizedBox(height: 18),
          const Text(
            'Recommended starting level',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _confidenceNote(context),
          const SizedBox(height: 8),
          // Placement raises where the guided path begins; it locks nothing.
          // Without saying so, "you are B1" reads as "A2 is closed to you".
          Text(
            AppText.of(context).placementLowerLevelsNote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          ...AssessmentDomain.values.map((domain) {
            final total = _domainTotal[domain] ?? 0;
            final correct = _domainCorrect[domain] ?? 0;
            final value = total == 0 ? 0.0 : correct / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: <Widget>[
                      Text(domain.emoji, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(domain.label)),
                      Text('$correct/$total • ${(value * 100).round()}%'),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Band history',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  ..._bands.map(
                    (band) => Text(
                      '${band.level.label}: ${band.correct}/${band.total} (${(band.ratio * 100).round()}%)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'This is a placement estimate for study planning, not an official CEFR certification result.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: <Widget>[
              if (_history.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: _previous,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Review last item'),
                ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Use this level'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExamLevelPrepScreen extends StatelessWidget {
  const ExamLevelPrepScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  Widget build(BuildContext context) {
    final profile = examProfileFor(level);
    final sets = examSetsFor(level);
    return Scaffold(
      appBar: AppBar(title: Text('${level.label} exam preparation')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            'Module reference',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _moduleCard(
            context,
            '📖 Reading',
            profile.readingMinutes,
            profile.readingFocus,
          ),
          _moduleCard(
            context,
            '🎧 Listening',
            profile.listeningMinutes,
            profile.listeningFocus,
          ),
          _moduleCard(
            context,
            '✍️ Writing',
            profile.writingMinutes,
            profile.writingFocus,
          ),
          _moduleCard(
            context,
            '🗣️ Speaking',
            profile.speakingMinutes,
            profile.speakingFocus,
          ),
          const SizedBox(height: 16),
          Text(
            'Mini mocks',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...sets.map((set) {
            final progress = controller.activities[set.id];
            return Card(
              child: ListTile(
                title: Text(
                  set.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  progress == null || progress.attempts == 0
                      ? 'Objective reading/listening + writing/speaking tasks'
                      : 'Best objective score: ${progress.bestScore}% • ${progress.attempts} attempt(s)',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ExamPracticeScreen(controller: controller, set: set),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          ExpansionTile(
            title: const Text(
              'Exam strategy',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            children: generalExamStrategies
                .map(
                  (tip) => ListTile(
                    leading: const Icon(Icons.check_circle_outline_rounded),
                    title: Text(tip),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Timing is a current preparation reference. DeutschGarden practice tasks are original and are not copied from official examination papers.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context,
    String title,
    int minutes,
    String focus,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 105,
              child: Text(
                '$title\n$minutes min',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(focus)),
          ],
        ),
      ),
    );
  }
}

class ExamPracticeScreen extends StatefulWidget {
  const ExamPracticeScreen({
    super.key,
    required this.controller,
    required this.set,
  });

  final AppController controller;
  final ExamPracticeSet set;

  @override
  State<ExamPracticeScreen> createState() => _ExamPracticeScreenState();
}

class _ExamPracticeScreenState extends State<ExamPracticeScreen> {
  final TtsService _tts = TtsService();
  int _index = 0;
  int _correct = 0;
  bool _answered = false;
  int? _selected;
  int _page = 0; // 0 objective, 1 writing, 2 speaking, 3 result
  final Map<int, int> _answers = <int, int>{};

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Exam practice · ${widget.set.title}');
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Exam practice · ${widget.set.title}');
    _tts.stop();
    super.dispose();
  }

  /// Fixed once per sitting. The option order has to be stable while a
  /// question is on screen -- a rebuild that moved the options under a finger
  /// about to tap is its own wrong answer -- and different the next time the
  /// test is taken. Seeding from (question identity, this salt) gives both
  /// without keeping a shuffled copy in state.
  final int _shuffleSalt = Random().nextInt(0x7fffffff);

  ExamObjectiveQuestion get _question {
    final ExamObjectiveQuestion raw = widget.set.objectiveQuestions[_index];
    return raw.shuffled(seededFor(raw.prompt, _shuffleSalt));
  }

  void _answer(int index) {
    if (_answered) return;
    setState(() {
      _selected = index;
      _answered = true;
      _answers[_index] = index;
      if (index == _question.correctIndex) _correct += 1;
    });
  }

  void _nextQuestion() {
    if (_index + 1 < widget.set.objectiveQuestions.length) {
      setState(() {
        _index += 1;
        _selected = _answers[_index];
        _answered = _selected != null;
      });
    } else {
      setState(() {
        _page = 1;
      });
    }
  }

  void _previousQuestion() {
    if (_index <= 0) return;
    setState(() {
      _index -= 1;
      _selected = _answers[_index];
      _answered = _selected != null;
    });
  }

  void _skipQuestion() {
    if (_answered) return;
    _nextQuestion();
  }

  int get _score => widget.set.objectiveQuestions.isEmpty
      ? 0
      : ((_correct / widget.set.objectiveQuestions.length) * 100).round();

  Future<void> _finish() async {
    await widget.controller.recordActivity(widget.set.id, score: _score);
    if (!mounted) return;
    setState(() => _page = 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.set.title)),
      body: switch (_page) {
        0 => _objective(context),
        1 => _productiveTask(
          context,
          emoji: '✍️',
          title: 'Writing task',
          prompt: widget.set.writingPrompt,
          checklist: widget.set.writingChecklist,
          button: 'Continue to speaking',
          onContinue: () async => setState(() => _page = 2),
          onPrevious: () => setState(() {
            _page = 0;
            _index = widget.set.objectiveQuestions.length - 1;
            _selected = _answers[_index];
            _answered = _selected != null;
          }),
        ),
        2 => _productiveTask(
          context,
          emoji: '🗣️',
          title: 'Speaking task',
          prompt: widget.set.speakingPrompt,
          checklist: widget.set.speakingChecklist,
          button: 'Finish mini mock',
          onContinue: _finish,
          onPrevious: () => setState(() => _page = 1),
        ),
        _ => _result(context),
      },
    );
  }

  Widget _objective(BuildContext context) {
    final q = _question;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        LinearProgressIndicator(
          value: (_index + 1) / widget.set.objectiveQuestions.length,
          minHeight: 8,
        ),
        const SizedBox(height: 12),
        Text(
          '${q.module.emoji} ${q.module.label} • ${_index + 1}/${widget.set.objectiveQuestions.length}',
        ),
        if (q.contextText.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(q.contextText, style: const TextStyle(height: 1.5)),
            ),
          ),
        ],
        if (q.spokenText.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: () => _tts.speakGerman(q.spokenText),
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text('Play audio'),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          q.prompt,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          children: <Widget>[
            if (_index > 0)
              TextButton.icon(
                onPressed: _previousQuestion,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Previous'),
              ),
            if (!_answered)
              TextButton.icon(
                onPressed: _skipQuestion,
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('Skip'),
              ),
          ],
        ),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              onPressed: _answered ? null : () => _answer(i),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(16),
              ),
              child: Text(q.options[i]),
            ),
          ),
        if (_answered) ...<Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${_selected == q.correctIndex ? 'Correct.' : 'Not quite.'} ${q.explanation}',
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(onPressed: _nextQuestion, child: const Text('Continue')),
        ],
      ],
    );
  }

  Widget _productiveTask(
    BuildContext context, {
    required String emoji,
    required String title,
    required String prompt,
    required List<String> checklist,
    required String button,
    required Future<void> Function() onContinue,
    required VoidCallback onPrevious,
  }) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(
          emoji,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 48),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(prompt, style: const TextStyle(height: 1.5)),
          ),
        ),
        const SizedBox(height: 14),
        const Text('Self-check', style: TextStyle(fontWeight: FontWeight.w900)),
        ...checklist.map(
          (item) => ListTile(
            leading: const Icon(Icons.check_box_outline_blank_rounded),
            title: Text(item),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: onPrevious,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Previous'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () async => onContinue(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Text(button),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _result(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _score >= 70 ? '🎉' : '🌱',
                  style: const TextStyle(fontSize: 56),
                ),
                Text(
                  '$_score%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Objective reading/listening score: $_correct/${widget.set.objectiveQuestions.length}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Writing and speaking are guided self-assessment tasks in the offline app; they are not automatically CEFR-certified.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _page = 2),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Review speaking task'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Told once, then never again.
///
/// Every placement question was authored answer-first, so before 4.2 the test
/// could be passed by tapping the top option. Anyone holding a result from
/// then is holding a number that does not mean what it says, and they are
/// entitled to know that.
///
/// What this deliberately is not: a recurring prompt. Retaking is permanently
/// available from the card directly above, which is where someone who wants
/// it will look. Repeating the offer would be nagging about a decision that
/// belongs to the learner -- and their recorded level was left alone rather
/// than reset, because silently discarding it would be its own kind of wrong.
class _StalePlacementNotice extends StatelessWidget {
  const _StalePlacementNotice({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.info_outline_rounded, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your placement result predates a fix',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Until recently every question here listed its correct answer '
              'first, so the test could be passed without reading it. Your '
              'saved level is still yours and nothing has been changed — but '
              'if it never felt right, this is why, and a retake will now '
              'give a real answer.',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: controller.dismissPlacementNotice,
                  child: const Text('Not now'),
                ),
                TextButton(
                  onPressed: () {
                    controller.dismissPlacementNotice();
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            PlacementIntroScreen(controller: controller),
                      ),
                    );
                  },
                  child: const Text('Retake it'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
