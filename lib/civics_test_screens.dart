import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'civics_test.dart';
import 'models.dart';
import 'dart:math';
import 'answer_shuffle.dart';

class CivicsHubScreen extends StatefulWidget {
  const CivicsHubScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<CivicsHubScreen> createState() => _CivicsHubScreenState();
}

class _CivicsHubScreenState extends State<CivicsHubScreen> {
  late final Future<CivicsCatalog> _catalog = CivicsCatalog.load();
  String? _stateCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leben in Deutschland')),
      body: FutureBuilder<CivicsCatalog>(
        future: _catalog,
        builder: (BuildContext context, AsyncSnapshot<CivicsCatalog> snapshot) {
          if (snapshot.hasError) {
            return _LoadError(error: snapshot.error);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return AnimatedBuilder(
            animation: widget.controller,
            builder: (BuildContext context, Widget? child) =>
                _buildLoaded(context, snapshot.requireData),
          );
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, CivicsCatalog catalog) {
    final Set<String> validCodes = catalog.states
        .map((GermanState state) => state.code)
        .toSet();
    final String selected =
        _stateCode ??
        (validCodes.contains(widget.controller.civicsStateCode)
            ? widget.controller.civicsStateCode
            : 'BE');
    final GermanState state = catalog.stateByCode(selected)!;
    final Set<String> relevantIds = catalog
        .relevantQuestions(selected)
        .map((CivicsQuestion question) => question.id)
        .toSet();
    final int mastered = widget.controller.civicsCorrectQuestionIds
        .where(relevantIds.contains)
        .length;
    final int mistakes = widget.controller.civicsMistakeQuestionIds
        .where(relevantIds.contains)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        Text(
          'Official question-bank preparation',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Study all 300 general questions, the 10 questions for your Bundesland, and sit realistic 33-question mock tests entirely offline.',
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Your Bundesland',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selected,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: <DropdownMenuItem<String>>[
                    for (final GermanState item in catalog.states)
                      DropdownMenuItem<String>(
                        value: item.code,
                        child: Text(item.name),
                      ),
                  ],
                  onChanged: (String? value) {
                    if (value == null) return;
                    setState(() => _stateCode = value);
                    unawaited(widget.controller.setCivicsStateCode(value));
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  '$mastered of 310 relevant questions answered correctly • $mistakes in mistake review',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: mastered / 310),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.menu_book_rounded,
          title: 'Practise the question bank',
          subtitle:
              'Immediate feedback across 300 general and 10 ${state.name} questions.',
          onTap: () => _openPractice(catalog, selected),
        ),
        _ActionCard(
          icon: Icons.replay_circle_filled_rounded,
          title: 'Review mistakes',
          subtitle: mistakes == 0
              ? 'No unanswered mistakes for this Bundesland.'
              : '$mistakes questions are waiting for another attempt.',
          onTap: () => _openPractice(catalog, selected, mistakesOnly: true),
        ),
        const SizedBox(height: 8),
        Text(
          'Official-style simulations',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        _MockCard(
          kind: CivicsTestKind.lebenInDeutschland,
          color: Colors.green,
          onTap: () => _openMockIntro(
            catalog,
            selected,
            CivicsTestKind.lebenInDeutschland,
          ),
        ),
        _MockCard(
          kind: CivicsTestKind.citizenship,
          color: Colors.blue,
          onTap: () =>
              _openMockIntro(catalog, selected, CivicsTestKind.citizenship),
        ),
        if (widget.controller.civicsTestsCompleted > 0) ...<Widget>[
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history_rounded),
              title: Text(
                'Last result: ${widget.controller.lastCivicsCorrect}/${widget.controller.lastCivicsTotal}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${widget.controller.lastCivicsKind} • ${widget.controller.lastCivicsStateCode} • ${widget.controller.lastCivicsDate}\n${widget.controller.civicsTestsCompleted} mock test(s) completed',
              ),
              isThreeLine: true,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Catalogue: BAMF, Stand ${catalog.metadata.catalogStand}. The official format is 30 general questions plus 3 for your Bundesland in 60 minutes. A LiD result requires 15 correct answers; proof of citizenship knowledge requires 17. DeutschGarden is an independent training aid and does not issue an official certificate.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }

  void _openPractice(
    CivicsCatalog catalog,
    String stateCode, {
    bool mistakesOnly = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => CivicsPracticeScreen(
          controller: widget.controller,
          catalog: catalog,
          stateCode: stateCode,
          mistakesOnly: mistakesOnly,
        ),
      ),
    );
  }

  void _openMockIntro(
    CivicsCatalog catalog,
    String stateCode,
    CivicsTestKind kind,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => CivicsMockIntroScreen(
          controller: widget.controller,
          catalog: catalog,
          stateCode: stateCode,
          kind: kind,
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Icon(icon, size: 34),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    ),
  );
}

class _MockCard extends StatelessWidget {
  const _MockCard({
    required this.kind,
    required this.color,
    required this.onTap,
  });

  final CivicsTestKind kind;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.16),
        child: Icon(Icons.timer_outlined, color: color),
      ),
      title: Text(
        '${kind.label} mock',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        '33 questions • 60 minutes • pass mark ${kind.passMark}/33',
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    ),
  );
}

enum _PracticeFilter { all, general, state }

class CivicsPracticeScreen extends StatefulWidget {
  const CivicsPracticeScreen({
    super.key,
    required this.controller,
    required this.catalog,
    required this.stateCode,
    this.mistakesOnly = false,
  });

  final AppController controller;
  final CivicsCatalog catalog;
  final String stateCode;
  final bool mistakesOnly;

  @override
  State<CivicsPracticeScreen> createState() => _CivicsPracticeScreenState();
}

class _CivicsPracticeScreenState extends State<CivicsPracticeScreen> {
  /// Fixed once per sitting. See lib/answer_shuffle.dart.
  final int _shuffleSalt = Random().nextInt(0x7fffffff);

  _PracticeFilter _filter = _PracticeFilter.all;
  late final Set<String> _mistakeSnapshotIds =
      widget.controller.civicsMistakeQuestionIds;
  int _index = 0;
  int? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      widget.mistakesOnly
          ? 'Citizenship test · mistake review'
          : 'Citizenship test · question practice',
    );
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity(
      widget.mistakesOnly
          ? 'Citizenship test · mistake review'
          : 'Citizenship test · question practice',
    );
    super.dispose();
  }

  List<CivicsQuestion> get _questions {
    Iterable<CivicsQuestion> questions = switch (_filter) {
      _PracticeFilter.all => widget.catalog.relevantQuestions(widget.stateCode),
      _PracticeFilter.general => widget.catalog.generalQuestions,
      _PracticeFilter.state => widget.catalog.stateQuestions(widget.stateCode),
    };
    if (widget.mistakesOnly) {
      questions = questions.where(
        (CivicsQuestion item) => _mistakeSnapshotIds.contains(item.id),
      );
    }
    return questions.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mistakesOnly ? 'Mistake review' : 'Question practice',
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (BuildContext context, Widget? child) {
          final List<CivicsQuestion> questions = _questions;
          if (questions.isEmpty) {
            return _EmptyMistakes(
              onAllQuestions: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => CivicsPracticeScreen(
                    controller: widget.controller,
                    catalog: widget.catalog,
                    stateCode: widget.stateCode,
                  ),
                ),
              ),
            );
          }
          if (_index >= questions.length) _index = questions.length - 1;
          // Permuted for the same reason as everywhere else, and seeded so it
          // stays put while the learner is looking at it.
          final CivicsQuestion question = questions[_index].shuffled(
            seededFor(questions[_index].id, _shuffleSalt),
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            children: <Widget>[
              SegmentedButton<_PracticeFilter>(
                segments: const <ButtonSegment<_PracticeFilter>>[
                  ButtonSegment<_PracticeFilter>(
                    value: _PracticeFilter.all,
                    label: Text('All'),
                  ),
                  ButtonSegment<_PracticeFilter>(
                    value: _PracticeFilter.general,
                    label: Text('General'),
                  ),
                  ButtonSegment<_PracticeFilter>(
                    value: _PracticeFilter.state,
                    label: Text('State'),
                  ),
                ],
                selected: <_PracticeFilter>{_filter},
                onSelectionChanged: (Set<_PracticeFilter> selected) {
                  setState(() {
                    _filter = selected.first;
                    _index = 0;
                    _answered = false;
                    _selected = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Question ${_index + 1} of ${questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Chip(
                    label: Text(
                      question.scope == CivicsQuestionScope.general
                          ? 'General ${question.officialNumber}'
                          : '${question.stateCode} ${question.officialNumber}',
                    ),
                  ),
                ],
              ),
              LinearProgressIndicator(value: (_index + 1) / questions.length),
              const SizedBox(height: 20),
              Text(
                question.question,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              if (question.images.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                CivicsImageGrid(images: question.images),
              ],
              const SizedBox(height: 16),
              for (int option = 0; option < question.options.length; option++)
                _AnswerTile(
                  index: option,
                  text: question.options[option],
                  selected: _selected == option,
                  correct: option == question.correctIndex,
                  reveal: _answered,
                  onTap: () => _answer(question, option),
                ),
              if (_answered) ...<Widget>[
                const SizedBox(height: 8),
                Card(
                  color: _selected == question.correctIndex
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.orange.withValues(alpha: 0.12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _selected == question.correctIndex
                          ? 'Correct.'
                          : 'Correct answer: ${question.correctAnswer}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: _index == 0 ? null : () => _move(-1),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Previous'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _answered || _index + 1 < questions.length
                        ? () => _move(1)
                        : null,
                    icon: Icon(
                      _index + 1 == questions.length
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(
                      _index + 1 == questions.length ? 'Finish' : 'Next',
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _answer(CivicsQuestion question, int option) {
    if (_answered) return;
    final bool correct = option == question.correctIndex;
    setState(() {
      _selected = option;
      _answered = true;
    });
    unawaited(
      widget.controller.recordCivicsPractice(
        questionId: question.id,
        prompt: question.question,
        correctAnswer: question.correctAnswer,
        givenAnswer: question.options[option],
        correct: correct,
      ),
    );
  }

  void _move(int amount) {
    final List<CivicsQuestion> questions = _questions;
    if (amount > 0 && _index + 1 >= questions.length) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _index = (_index + amount).clamp(0, questions.length - 1);
      _selected = null;
      _answered = false;
    });
  }
}

class _EmptyMistakes extends StatelessWidget {
  const _EmptyMistakes({required this.onAllQuestions});

  final VoidCallback onAllQuestions;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.task_alt_rounded, size: 64, color: Colors.green),
          const SizedBox(height: 12),
          Text(
            'No mistakes waiting',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Wrong answers from practice and mock tests will appear here.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onAllQuestions,
            child: const Text('All questions'),
          ),
        ],
      ),
    ),
  );
}

class CivicsMockIntroScreen extends StatelessWidget {
  const CivicsMockIntroScreen({
    super.key,
    required this.controller,
    required this.catalog,
    required this.stateCode,
    required this.kind,
  });

  final AppController controller;
  final CivicsCatalog catalog;
  final String stateCode;
  final CivicsTestKind kind;

  @override
  Widget build(BuildContext context) {
    final GermanState state = catalog.stateByCode(stateCode)!;
    return Scaffold(
      appBar: AppBar(title: Text(kind.label)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          const Icon(Icons.fact_check_rounded, size: 70),
          const SizedBox(height: 12),
          Text(
            '${kind.label} simulation',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Official format',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  const Text('• 30 randomly selected general questions'),
                  Text('• 3 questions for ${state.name}'),
                  const Text('• One correct answer out of four'),
                  const Text('• 60-minute countdown'),
                  Text('• ${kind.passMark} of 33 required for this outcome'),
                  const Text('• Unanswered questions count as incorrect'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'You can move backward and forward before submitting. Answers are not revealed during the simulation. The final review shows every missed question.',
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Start 60-minute mock'),
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => CivicsMockScreen(
                  controller: controller,
                  catalog: catalog,
                  stateCode: stateCode,
                  kind: kind,
                  seed: DateTime.now().millisecondsSinceEpoch,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CivicsMockScreen extends StatefulWidget {
  const CivicsMockScreen({
    super.key,
    required this.controller,
    required this.catalog,
    required this.stateCode,
    required this.kind,
    required this.seed,
    this.duration = const Duration(minutes: 60),
  });

  final AppController controller;
  final CivicsCatalog catalog;
  final String stateCode;
  final CivicsTestKind kind;
  final int seed;
  final Duration duration;

  @override
  State<CivicsMockScreen> createState() => _CivicsMockScreenState();
}

class _CivicsMockScreenState extends State<CivicsMockScreen> {
  late final CivicsMock _mock;
  late int _remainingSeconds;
  final Map<String, int> _answers = <String, int>{};
  Timer? _timer;
  int _index = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      'Citizenship test · ${widget.kind.shortLabel}',
    );
    _mock = widget.catalog.buildMock(
      stateCode: widget.stateCode,
      seed: widget.seed,
    );
    _remainingSeconds = widget.duration.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted || _submitting) return;
      if (_remainingSeconds <= 1) {
        setState(() => _remainingSeconds = 0);
        unawaited(_submit(timedOut: true));
      } else {
        setState(() => _remainingSeconds -= 1);
      }
    });
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity(
      'Citizenship test · ${widget.kind.shortLabel}',
    );
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CivicsQuestion question = _mock.questions[_index];
    final int minutes = _remainingSeconds ~/ 60;
    final int seconds = _remainingSeconds % 60;
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.kind.shortLabel),
          actions: <Widget>[
            Semantics(
              label: '$minutes minutes $seconds seconds remaining',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _remainingSeconds < 300 ? Colors.red : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Question ${_index + 1} of 33',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text('${_answers.length} answered'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: (_index + 1) / 33),
            const SizedBox(height: 22),
            Text(
              question.question,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (question.images.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              CivicsImageGrid(images: question.images),
            ],
            const SizedBox(height: 16),
            for (int option = 0; option < question.options.length; option++)
              _AnswerTile(
                index: option,
                text: question.options[option],
                selected: _answers[question.id] == option,
                correct: false,
                reveal: false,
                onTap: _submitting
                    ? null
                    : () => setState(() => _answers[question.id] = option),
              ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _index == 0 || _submitting
                      ? null
                      : () => setState(() => _index -= 1),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Previous'),
                ),
                const Spacer(),
                if (_index + 1 < _mock.questions.length)
                  FilledButton.icon(
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _index += 1),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Next'),
                  )
                else
                  FilledButton.icon(
                    onPressed: _submitting ? null : _confirmSubmit,
                    icon: _submitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: const Text('Submit'),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                for (int index = 0; index < _mock.questions.length; index++)
                  SizedBox.square(
                    dimension: 38,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor:
                            _answers.containsKey(_mock.questions[index].id)
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                      ),
                      onPressed: _submitting
                          ? null
                          : () => setState(() => _index = index),
                      child: Text('${index + 1}'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSubmit() async {
    final int unanswered = _mock.questions.length - _answers.length;
    if (unanswered == 0) {
      await _submit();
      return;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Submit mock?'),
        content: Text(
          '$unanswered question${unanswered == 1 ? '' : 's'} are unanswered and will count as incorrect.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue test'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await _submit();
  }

  Future<void> _submit({bool timedOut = false}) async {
    if (_submitting) return;
    _timer?.cancel();
    setState(() => _submitting = true);
    final CivicsTestResult result = _mock.score(_answers);
    final Set<String> correctIds = <String>{};
    final List<MistakeEntry> mistakes = <MistakeEntry>[];
    final List<CivicsReviewItem> review = <CivicsReviewItem>[];
    for (final CivicsQuestion question in _mock.questions) {
      final int? selected = _answers[question.id];
      if (selected == question.correctIndex) {
        correctIds.add(question.id);
      } else {
        final String given = selected == null
            ? 'Keine Antwort'
            : question.options[selected];
        mistakes.add(
          MistakeEntry(
            id: 'civics:${question.id}',
            prompt: question.question,
            correctAnswer: question.correctAnswer,
            givenAnswer: given,
            source: 'civics',
            level: widget.kind.shortLabel,
            timestamp: DateTime.now(),
          ),
        );
        review.add(
          CivicsReviewItem(question: question, selectedIndex: selected),
        );
      }
    }
    await widget.controller.recordCivicsExam(
      kind: widget.kind.label,
      stateCode: widget.stateCode,
      correct: result.correct,
      total: result.total,
      correctQuestionIds: correctIds,
      mistakes: mistakes,
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => CivicsResultScreen(
          controller: widget.controller,
          catalog: widget.catalog,
          stateCode: widget.stateCode,
          kind: widget.kind,
          result: result,
          review: review,
          timedOut: timedOut,
        ),
      ),
    );
  }
}

class CivicsReviewItem {
  const CivicsReviewItem({required this.question, required this.selectedIndex});

  final CivicsQuestion question;
  final int? selectedIndex;
}

class CivicsResultScreen extends StatelessWidget {
  const CivicsResultScreen({
    super.key,
    required this.controller,
    required this.catalog,
    required this.stateCode,
    required this.kind,
    required this.result,
    required this.review,
    required this.timedOut,
  });

  final AppController controller;
  final CivicsCatalog catalog;
  final String stateCode;
  final CivicsTestKind kind;
  final CivicsTestResult result;
  final List<CivicsReviewItem> review;
  final bool timedOut;

  @override
  Widget build(BuildContext context) {
    final bool passed = result.passed(kind);
    return Scaffold(
      appBar: AppBar(title: const Text('Mock result')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
        children: <Widget>[
          Icon(
            passed ? Icons.verified_rounded : Icons.school_rounded,
            size: 76,
            color: passed ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 10),
          Text(
            '${result.correct} / ${result.total}',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            '$passedText • ${result.percent}%',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (timedOut)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Time expired; unanswered questions were marked incorrect.',
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 18),
          Card(
            child: Column(
              children: <Widget>[
                _ThresholdRow(
                  label: 'Leben in Deutschland',
                  mark: 15,
                  passed: result.passedLebenInDeutschland,
                ),
                const Divider(height: 1),
                _ThresholdRow(
                  label: 'Citizenship knowledge',
                  mark: 17,
                  passed: result.passedCitizenship,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (review.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Perfect score — there are no missed questions to review.',
                ),
              ),
            )
          else ...<Widget>[
            Text(
              'Missed questions (${review.length})',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final CivicsReviewItem item in review)
              Card(
                child: ExpansionTile(
                  title: Text(item.question.question),
                  subtitle: Text(
                    item.selectedIndex == null
                        ? 'No answer'
                        : 'Your answer: ${item.question.options[item.selectedIndex!]}',
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Correct: ${item.question.correctAnswer}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Practise mistakes'),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => CivicsPracticeScreen(
                  controller: controller,
                  catalog: catalog,
                  stateCode: stateCode,
                  mistakesOnly: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to test centre'),
          ),
        ],
      ),
    );
  }

  String get passedText => result.passed(kind)
      ? '${kind.label} pass mark reached'
      : '${kind.label} pass mark not yet reached';
}

class _ThresholdRow extends StatelessWidget {
  const _ThresholdRow({
    required this.label,
    required this.mark,
    required this.passed,
  });

  final String label;
  final int mark;
  final bool passed;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(
      passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
      color: passed ? Colors.green : Colors.orange,
    ),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    subtitle: Text('Threshold: $mark / 33'),
    trailing: Text(passed ? 'Reached' : 'Not reached'),
  );
}

class CivicsImageGrid extends StatelessWidget {
  const CivicsImageGrid({super.key, required this.images});

  final List<CivicsImage> images;

  @override
  Widget build(BuildContext context) {
    final int columns = images.length == 1 ? 1 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: images.length == 1 ? 1.7 : 0.9,
      ),
      itemBuilder: (BuildContext context, int index) => Semantics(
        label: 'Bild ${index + 1}',
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    images[index].asset,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) => const Center(
                          child: Icon(Icons.broken_image_outlined, size: 42),
                        ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Bild ${index + 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.index,
    required this.text,
    required this.selected,
    required this.correct,
    required this.reveal,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool selected;
  final bool correct;
  final bool reveal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color? color;
    IconData? trailing;
    if (reveal && correct) {
      color = Colors.green.withValues(alpha: 0.16);
      trailing = Icons.check_circle_rounded;
    } else if (reveal && selected) {
      color = Colors.red.withValues(alpha: 0.12);
      trailing = Icons.cancel_rounded;
    } else if (selected) {
      color = Theme.of(context).colorScheme.primaryContainer;
    }
    return Card(
      color: color,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(String.fromCharCode('A'.codeUnitAt(0) + index)),
        ),
        title: Text(text),
        trailing: trailing == null ? null : Icon(trailing),
        onTap: onTap,
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline_rounded, size: 54),
          const SizedBox(height: 12),
          const Text('The bundled civics catalogue could not be loaded.'),
          const SizedBox(height: 8),
          Text('$error', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}
