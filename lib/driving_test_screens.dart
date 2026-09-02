import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'answer_shuffle.dart';
import 'driving_test.dart';
import 'models.dart';

/// Offline Class B theory preparation. The question bank is original and
/// educational; it does not replace an official driving-school catalogue.
class DrivingTheoryScreen extends StatelessWidget {
  const DrivingTheoryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('German driving theory')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: <Widget>[
          Text(
            'Class B practice',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Build safe decision-making with original offline questions across danger awareness, speed, right of way, signs, motorway driving, technology, vulnerable road users, fitness and the environment.',
          ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Mock format to practise',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('• 30 questions from the Class B subject areas'),
                  const Text('• 110 official maximum points'),
                  const Text('• Up to 10 error points in the official rule'),
                  const Text('• Two wrong 5-point questions mean a fail'),
                  const SizedBox(height: 10),
                  Text(
                    'DeutschGarden questions are original practice material, not the official TÜV/DEKRA catalogue or a certificate.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(child: Icon(Icons.menu_book_rounded)),
              title: const Text(
                'Practise by topic',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(
                '${DrivingTheoryCatalog.questions.length} original questions • immediate explanations • German with optional English helper',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => DrivingPracticeScreen(controller: controller),
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(child: Icon(Icons.timer_outlined)),
              title: const Text(
                'Start a 30-question mock',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                'Configurable practice countdown • no answers revealed until submission',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => DrivingMockScreen(controller: controller),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('How the score works'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: <Widget>[
              const Text(
                'The mock reports correct answers and error points. Its 30 questions are a representative training set, so the error-point total is a practice signal rather than an official result. Always use current official materials and a qualified driving school for exam preparation.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DrivingPracticeScreen extends StatefulWidget {
  const DrivingPracticeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<DrivingPracticeScreen> createState() => _DrivingPracticeScreenState();
}

class _DrivingPracticeScreenState extends State<DrivingPracticeScreen> {
  DrivingQuestionCategory? _category;
  int _index = 0;
  int? _selected;
  bool _answered = false;
  bool _showEnglish = false;

  List<DrivingQuestion> get _questions =>
      DrivingTheoryCatalog.questionsFor(_category);

  DrivingQuestion get _baseQuestion => _questions[_index];

  DrivingQuestion get _question =>
      _baseQuestion.shuffled(seededFor(_baseQuestion.id, 1));

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Driving theory · topic practice');
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Driving theory · topic practice');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<DrivingQuestion> questions = _questions;
    final DrivingQuestion question = _question;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topic practice'),
        actions: <Widget>[
          IconButton(
            tooltip: _showEnglish
                ? 'Hide English helper'
                : 'Show English helper',
            icon: Icon(
              _showEnglish ? Icons.translate_rounded : Icons.translate_outlined,
            ),
            onPressed: () => setState(() => _showEnglish = !_showEnglish),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: <Widget>[
          DropdownButtonFormField<DrivingQuestionCategory?>(
            initialValue: _category,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Topic',
              border: OutlineInputBorder(),
            ),
            items: <DropdownMenuItem<DrivingQuestionCategory?>>[
              const DropdownMenuItem<DrivingQuestionCategory?>(
                value: null,
                child: Text('All topics'),
              ),
              for (final DrivingQuestionCategory category
                  in DrivingQuestionCategory.values)
                DropdownMenuItem<DrivingQuestionCategory?>(
                  value: category,
                  child: Text(category.label),
                ),
            ],
            onChanged: (DrivingQuestionCategory? value) {
              setState(() {
                _category = value;
                _index = 0;
                _selected = null;
                _answered = false;
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
              Chip(label: Text('${question.points} points')),
            ],
          ),
          LinearProgressIndicator(value: (_index + 1) / questions.length),
          const SizedBox(height: 20),
          _BilingualDrivingText(
            german: question.questionGerman,
            english: question.questionEnglish,
            showEnglish: _showEnglish,
            germanStyle: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          for (int option = 0; option < question.options.length; option++)
            _DrivingAnswerTile(
              index: option,
              option: question.options[option],
              showEnglish: _showEnglish,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _selected == question.correctIndex
                          ? 'Correct.'
                          : 'Correct: ${question.correctOption.german}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    _BilingualDrivingText(
                      german: question.explanationGerman,
                      english: question.explanationEnglish,
                      showEnglish: _showEnglish,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: _index == 0 ? null : _previous,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Previous'),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _answered ? null : _skip,
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('Skip'),
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                onPressed: _answered || _index + 1 < questions.length
                    ? _next
                    : null,
                icon: Icon(
                  _index + 1 == questions.length
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                ),
                label: Text(_index + 1 == questions.length ? 'Finish' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _answer(DrivingQuestion question, int option) {
    if (_answered) return;
    final bool correct = option == question.correctIndex;
    setState(() {
      _selected = option;
      _answered = true;
    });
    if (correct) {
      unawaited(widget.controller.clearMistake('driving:${question.id}'));
    } else {
      unawaited(
        widget.controller.addMistake(
          MistakeEntry(
            id: 'driving:${question.id}',
            prompt: question.questionGerman,
            correctAnswer: question.correctOption.german,
            givenAnswer: question.options[option].german,
            source: 'driving',
            level: 'Class B',
            timestamp: DateTime.now(),
          ),
        ),
      );
    }
  }

  void _skip() {
    final DrivingQuestion question = _question;
    unawaited(
      widget.controller.recordSkip(
        id: 'driving:${question.id}',
        prompt: question.questionGerman,
        correctAnswer: question.correctOption.german,
        source: 'driving',
        level: 'Class B',
      ),
    );
    _next();
  }

  void _previous() {
    if (_index == 0) return;
    setState(() {
      _index -= 1;
      _selected = null;
      _answered = false;
    });
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _index += 1;
      _selected = null;
      _answered = false;
    });
  }
}

class DrivingMockScreen extends StatefulWidget {
  const DrivingMockScreen({
    super.key,
    required this.controller,
    this.duration = const Duration(minutes: 45),
  });

  final AppController controller;
  final Duration duration;

  @override
  State<DrivingMockScreen> createState() => _DrivingMockScreenState();
}

class _DrivingMockScreenState extends State<DrivingMockScreen> {
  late final DrivingMock _mock;
  late int _remainingSeconds;
  final Map<String, int> _answers = <String, int>{};
  Timer? _timer;
  int _index = 0;
  bool _submitting = false;
  bool _showEnglish = false;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Driving theory · mock');
    _mock = DrivingTheoryCatalog.buildMock(
      seed: DateTime.now().millisecondsSinceEpoch,
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
    _timer?.cancel();
    widget.controller.endStudyActivity('Driving theory · mock');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DrivingQuestion question = _mock.questions[_index];
    final int minutes = _remainingSeconds ~/ 60;
    final int seconds = _remainingSeconds % 60;
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Class B mock'),
          actions: <Widget>[
            IconButton(
              tooltip: _showEnglish
                  ? 'Hide English helper'
                  : 'Show English helper',
              icon: Icon(
                _showEnglish
                    ? Icons.translate_rounded
                    : Icons.translate_outlined,
              ),
              onPressed: _submitting
                  ? null
                  : () => setState(() => _showEnglish = !_showEnglish),
            ),
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
                    'Question ${_index + 1} of ${_mock.questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text('${_answers.length} answered'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_index + 1) / _mock.questions.length,
            ),
            const SizedBox(height: 22),
            _BilingualDrivingText(
              german: question.questionGerman,
              english: question.questionEnglish,
              showEnglish: _showEnglish,
              germanStyle: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            for (int option = 0; option < question.options.length; option++)
              _DrivingAnswerTile(
                index: option,
                option: question.options[option],
                showEnglish: _showEnglish,
                selected: _answers[question.id] == option,
                correct: false,
                reveal: false,
                onTap: _submitting
                    ? null
                    : () => setState(() => _answers[question.id] = option),
              ),
            const SizedBox(height: 18),
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
          '$unanswered question${unanswered == 1 ? '' : 's'} are unanswered and will count as error points.',
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
    final DrivingTestResult result = _mock.score(_answers);
    final List<DrivingReviewItem> review = <DrivingReviewItem>[];
    for (final DrivingQuestion question in _mock.questions) {
      final int? selected = _answers[question.id];
      if (selected != question.correctIndex) {
        review.add(
          DrivingReviewItem(question: question, selectedIndex: selected),
        );
        await widget.controller.addMistake(
          MistakeEntry(
            id: 'driving:${question.id}',
            prompt: question.questionGerman,
            correctAnswer: question.correctOption.german,
            givenAnswer: selected == null
                ? 'Keine Antwort'
                : question.options[selected].german,
            source: 'driving',
            level: 'Class B',
            timestamp: DateTime.now(),
          ),
        );
      } else {
        await widget.controller.clearMistake('driving:${question.id}');
      }
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DrivingResultScreen(
          result: result,
          review: review,
          timedOut: timedOut,
        ),
      ),
    );
  }
}

class DrivingReviewItem {
  const DrivingReviewItem({
    required this.question,
    required this.selectedIndex,
  });

  final DrivingQuestion question;
  final int? selectedIndex;
}

class DrivingResultScreen extends StatelessWidget {
  const DrivingResultScreen({
    super.key,
    required this.result,
    required this.review,
    required this.timedOut,
  });

  final DrivingTestResult result;
  final List<DrivingReviewItem> review;
  final bool timedOut;

  @override
  Widget build(BuildContext context) {
    final bool passed = result.passed;
    return Scaffold(
      appBar: AppBar(title: const Text('Driving mock result')),
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
            passed ? 'Practice threshold reached' : 'Keep practising',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (timedOut)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Time expired; unanswered questions were counted as errors.',
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 18),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.error_outline_rounded),
                  title: const Text('Error points'),
                  trailing: Text(
                    '${result.errorPoints}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.warning_amber_rounded),
                  title: const Text('Wrong 5-point questions'),
                  subtitle: const Text(
                    'Two of these would fail the official rule',
                  ),
                  trailing: Text(
                    '${result.fivePointErrors}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (review.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('Perfect practice mock — nothing to review.'),
              ),
            )
          else ...<Widget>[
            Text(
              'Review (${review.length})',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final DrivingReviewItem item in review)
              Card(
                child: ExpansionTile(
                  title: Text(item.question.questionGerman),
                  subtitle: Text(
                    item.selectedIndex == null
                        ? 'No answer'
                        : 'Your answer: ${item.question.options[item.selectedIndex!].german}',
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Correct: ${item.question.correctOption.german}\n${item.question.explanationGerman}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to driving theory'),
          ),
        ],
      ),
    );
  }
}

class _BilingualDrivingText extends StatelessWidget {
  const _BilingualDrivingText({
    required this.german,
    required this.english,
    required this.showEnglish,
    this.germanStyle,
  });

  final String german;
  final String english;
  final bool showEnglish;
  final TextStyle? germanStyle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(german, style: germanStyle),
      if (showEnglish) ...<Widget>[
        const SizedBox(height: 6),
        Text(
          english,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ],
  );
}

class _DrivingAnswerTile extends StatelessWidget {
  const _DrivingAnswerTile({
    required this.index,
    required this.option,
    required this.showEnglish,
    required this.selected,
    required this.correct,
    required this.reveal,
    required this.onTap,
  });

  final int index;
  final DrivingOption option;
  final bool showEnglish;
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
        title: Text(option.german),
        subtitle: showEnglish ? Text(option.english) : null,
        trailing: trailing == null ? null : Icon(trailing),
        onTap: onTap,
      ),
    );
  }
}
