import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'l10n/app_localizations.dart';
import 'submission_confirmation.dart';
import 'civics_test.dart';
import 'civic_driving_text.dart';
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
      appBar: AppBar(title: Text(AppText.of(context).civicsTitle)),
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
          AppText.of(context).civicsBankPreparation,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(AppText.of(context).civicsIntro),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppText.of(context).civicsYourState,
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
                  AppText.of(context).civicsProgress(mastered, mistakes),
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
          title: AppText.of(context).civicsPractiseBank,
          subtitle: AppText.of(context).civicsPracticeSubtitle(state.name),
          onTap: () => _openPractice(catalog, selected),
        ),
        _ActionCard(
          icon: Icons.replay_circle_filled_rounded,
          title: AppText.of(context).civicsReviewMistakes,
          subtitle: mistakes == 0
              ? AppText.of(context).civicsNoStateMistakes
              : AppText.of(context).civicsWaitingMistakes(mistakes),
          onTap: () => _openPractice(catalog, selected, mistakesOnly: true),
        ),
        const SizedBox(height: 8),
        Text(
          AppText.of(context).civicsSimulations,
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
                AppText.of(context).civicsLastResult(
                  widget.controller.lastCivicsCorrect,
                  widget.controller.lastCivicsTotal,
                ),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                AppText.of(context).civicsHistory(
                  widget.controller.civicsTestsCompleted,
                  widget.controller.lastCivicsDate,
                  widget.controller.lastCivicsKind,
                  widget.controller.lastCivicsStateCode,
                ),
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
              AppText.of(
                context,
              ).civicsCatalogueNote(catalog.metadata.catalogStand),
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
        AppText.of(context).civicsMockTitle(kind.label),
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(AppText.of(context).civicsMockSummary(kind.passMark)),
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
  bool _showEnglish = false;

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
          widget.mistakesOnly
              ? AppText.of(context).civicsMistakeReview
              : AppText.of(context).civicsQuestionPractice,
        ),
        actions: <Widget>[
          if (widget.catalog.translations.isNotEmpty)
            IconButton(
              tooltip: _showEnglish
                  ? AppText.of(context).hideEnglishHelper
                  : AppText.of(context).showEnglishHelper,
              icon: Icon(
                _showEnglish
                    ? Icons.translate_rounded
                    : Icons.translate_outlined,
              ),
              onPressed: () => setState(() => _showEnglish = !_showEnglish),
            ),
        ],
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
          final CivicsTranslation? translation = widget.catalog.translationFor(
            question.id,
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final filter in _PracticeFilter.values)
                    ChoiceChip(
                      label: Text(switch (filter) {
                        _PracticeFilter.all => AppText.of(
                          context,
                        ).gameSourceAll,
                        _PracticeFilter.general => AppText.of(
                          context,
                        ).civicsGeneral,
                        _PracticeFilter.state => AppText.of(
                          context,
                        ).civicsState,
                      }),
                      selected: _filter == filter,
                      onSelected: (_) {
                        if (_filter == filter) return;
                        setState(() {
                          _filter = filter;
                          _index = 0;
                          _answered = false;
                          _selected = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      AppText.of(
                        context,
                      ).questionOfTotal(_index + 1, questions.length),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Chip(
                    label: Text(
                      question.scope == CivicsQuestionScope.general
                          ? AppText.of(
                              context,
                            ).civicsGeneralNumber(question.officialNumber)
                          : '${question.stateCode} ${question.officialNumber}',
                    ),
                  ),
                ],
              ),
              LinearProgressIndicator(value: (_index + 1) / questions.length),
              const SizedBox(height: 20),
              _BilingualText(
                german: question.question,
                english: translation?.question,
                showEnglish: _showEnglish,
                germanStyle: Theme.of(
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
                  translation: _showEnglish
                      ? _civicsOptionTranslation(
                          widget.catalog,
                          question,
                          option,
                        )
                      : null,
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
                          ? AppText.of(context).correctSentence
                          : AppText.of(
                              context,
                            ).civicsCorrectAnswer(question.correctAnswer),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: _index == 0 ? null : () => _move(-1),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: Text(AppText.of(context).previousAction),
                  ),
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
                      _index + 1 == questions.length
                          ? AppText.of(context).finishAction
                          : AppText.of(context).actionNext,
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
            AppText.of(context).civicsNoMistakes,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            AppText.of(context).civicsMistakesNote,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onAllQuestions,
            child: Text(AppText.of(context).civicsAllQuestions),
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
            AppText.of(context).civicsSimulationTitle(kind.label),
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
                  Text(
                    AppText.of(context).civicsFormat,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(AppText.of(context).civicsGeneralRule),
                  Text(AppText.of(context).civicsStateRule(state.name)),
                  Text(AppText.of(context).civicsAnswerRule),
                  Text(AppText.of(context).civicsTimerRule),
                  Text(AppText.of(context).civicsPassRule(kind.passMark)),
                  Text(AppText.of(context).civicsUnansweredRule),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(AppText.of(context).civicsNavigationNote),
          const SizedBox(height: 22),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(AppText.of(context).civicsStartMock),
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

class _CivicsMockScreenState extends State<CivicsMockScreen>
    with SubmissionConfirmation<CivicsMockScreen> {
  late final CivicsMock _mock;
  late int _remainingSeconds;
  final Map<String, int> _answers = <String, int>{};
  Timer? _timer;
  int _index = 0;
  bool _submitting = false;
  bool _showEnglish = false;

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
    final String clock =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.kind.shortLabel),
          actions: <Widget>[
            if (widget.catalog.translations.isNotEmpty)
              IconButton(
                tooltip: _showEnglish
                    ? AppText.of(context).hideEnglishHelper
                    : AppText.of(context).showEnglishHelper,
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
              label: AppText.of(context).mockTimeRemaining(minutes, seconds),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    clock,
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
            // The helper is intentionally available in both the LiD and
            // Einbürgerung mock: German remains the test language, while an
            // English gloss can unblock a learner during preparation.
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    AppText.of(context).questionOfTotal(_index + 1, 33),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(AppText.of(context).mockAnswered(_answers.length)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: (_index + 1) / 33),
            const SizedBox(height: 22),
            _BilingualText(
              german: question.question,
              english: widget.catalog.translationFor(question.id)?.question,
              showEnglish: _showEnglish,
              germanStyle: Theme.of(
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
                translation: _showEnglish
                    ? _civicsOptionTranslation(widget.catalog, question, option)
                    : null,
                selected: _answers[question.id] == option,
                correct: false,
                reveal: false,
                onTap: _submitting
                    ? null
                    : () => setState(() => _answers[question.id] = option),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _index == 0 || _submitting
                      ? null
                      : () => setState(() => _index -= 1),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(AppText.of(context).previousAction),
                ),
                if (_index + 1 < _mock.questions.length)
                  FilledButton.icon(
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _index += 1),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(AppText.of(context).actionNext),
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
                    label: Text(AppText.of(context).mockSubmit),
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
    if (_submitting || confirmationOpen) return;
    final int unanswered = _mock.questions.length - _answers.length;
    if (unanswered == 0) {
      await _submit();
      return;
    }
    final bool confirmed = await confirmSubmission(
      (BuildContext context, close) => AlertDialog(
        title: Text(AppText.of(context).mockConfirmSubmit),
        content: Text(AppText.of(context).civicsUnansweredConfirm(unanswered)),
        actions: <Widget>[
          TextButton(
            onPressed: () => close(false),
            child: Text(AppText.of(context).mockContinue),
          ),
          FilledButton(
            onPressed: () => close(true),
            child: Text(AppText.of(context).mockSubmit),
          ),
        ],
      ),
    );
    if (confirmed && mounted) await _submit();
  }

  Future<void> _submit({bool timedOut = false}) async {
    if (_submitting) return;
    _timer?.cancel();
    setState(() => _submitting = true);
    dismissSubmissionConfirmation();
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
      appBar: AppBar(title: Text(AppText.of(context).civicsMockResult)),
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
            '${civicsOutcomeText(AppText.of(context), kind, result)} • ${result.percent}%',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (timedOut)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                AppText.of(context).civicsTimeExpired,
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 18),
          Card(
            child: Column(
              children: <Widget>[
                _ThresholdRow(
                  label: AppText.of(context).civicsTitle,
                  mark: 15,
                  passed: result.passedLebenInDeutschland,
                ),
                const Divider(height: 1),
                _ThresholdRow(
                  label: AppText.of(context).civicsCitizenshipKnowledge,
                  mark: 17,
                  passed: result.passedCitizenship,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (review.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(AppText.of(context).civicsPerfectScore),
              ),
            )
          else ...<Widget>[
            Text(
              AppText.of(context).civicsMissedQuestions(review.length),
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
                        ? AppText.of(context).mockNoAnswer
                        : AppText.of(context).mockYourAnswer(
                            item.question.options[item.selectedIndex!],
                          ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppText.of(
                          context,
                        ).mockCorrectAnswer(item.question.correctAnswer),
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
            label: Text(AppText.of(context).civicsPractiseMistakes),
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
            child: Text(AppText.of(context).civicsBackToCentre),
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
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppText.of(context).civicsThreshold(mark)),
        Text(
          passed
              ? AppText.of(context).civicsReached
              : AppText.of(context).civicsNotReached,
        ),
      ],
    ),
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
        label: AppText.of(context).civicsImageLabel(index + 1),
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
                  AppText.of(context).civicsImageLabel(index + 1),
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

/// The mock permutes German options for every sitting. Translate the option
/// by its original index, not by the displayed index, so the two languages
/// remain paired after that permutation.
String? _civicsOptionTranslation(
  CivicsCatalog catalog,
  CivicsQuestion displayed,
  int displayedIndex,
) {
  final CivicsTranslation? translation = catalog.translationFor(displayed.id);
  final CivicsQuestion? source = catalog.questionById(displayed.id);
  if (translation == null || source == null) return null;
  final int sourceIndex = source.options.indexOf(
    displayed.options[displayedIndex],
  );
  if (sourceIndex < 0 || sourceIndex >= translation.options.length) return null;
  return translation.options[sourceIndex];
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.index,
    required this.text,
    this.translation,
    required this.selected,
    required this.correct,
    required this.reveal,
    required this.onTap,
  });

  final int index;
  final String text;
  final String? translation;
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(text),
            if (translation != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                translation!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: trailing == null ? null : Icon(trailing),
        onTap: onTap,
      ),
    );
  }
}

class _BilingualText extends StatelessWidget {
  const _BilingualText({
    required this.german,
    required this.english,
    required this.showEnglish,
    required this.germanStyle,
  });

  final String german;
  final String? english;
  final bool showEnglish;
  final TextStyle? germanStyle;

  @override
  Widget build(BuildContext context) {
    final String? helper = english?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(german, style: germanStyle),
        if (showEnglish && helper != null && helper.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            helper,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
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
          Text(AppText.of(context).civicsLoadFailed),
          const SizedBox(height: 8),
          Text(
            AppText.of(context).civicsLoadHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}
