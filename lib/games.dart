import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'cloze_bank.dart';
import 'german_text.dart';
import 'matching.dart';
import 'hints.dart';
import 'practice_aids.dart';
import 'gender_guide.dart';
import 'grammar_challenge.dart';
import 'grammar_tables.dart';
import 'models.dart';
import 'l10n/app_localizations.dart';
import 'review_text.dart';
import 'game_text.dart';
import 'pending_action.dart';
import 'platform_support.dart';
import 'pronunciation.dart';
import 'sentence_audio.dart';
import 'sentence_bank.dart';
import 'speech_service.dart';
import 'srs.dart';
import 'test_screens.dart';
import 'tts_service.dart';
import 'vocab_icon.dart';
import 'vocabulary_metadata.dart';

class TestHubHostScreen extends StatelessWidget {
  const TestHubHostScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppText.of(context).testHubTitle)),
      body: TestHubScreen(controller: controller),
    );
  }
}

// ---------------------------------------------------------------------------
// SM-2 review queue
// ---------------------------------------------------------------------------

class ReviewSessionScreen extends StatefulWidget {
  const ReviewSessionScreen({
    super.key,
    required this.controller,
    this.limit = 40,
  });

  final AppController controller;
  final int limit;

  @override
  State<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
  final TtsService _tts = TtsService();
  final FocusNode _keyboardFocus = FocusNode(debugLabel: 'review-shortcuts');
  late List<GermanWord> _queue;
  int _index = 0;
  bool _revealed = false;
  int _graded = 0;
  bool _grading = false;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Smart review');
    _queue = widget.controller.reviewWords.take(widget.limit).toList();
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Smart review');
    _keyboardFocus.dispose();
    _tts.stop();
    super.dispose();
  }

  /// Desktop keyboard control, the way every serious SRS client works:
  /// space or enter reveals, then 1-4 grade. Reviewing a long queue with the
  /// mouse is the fastest way to make someone stop reviewing.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (_index >= _queue.length) return KeyEventResult.ignored;
    if (_grading) return KeyEventResult.handled;

    final LogicalKeyboardKey key = event.logicalKey;
    if (!_revealed) {
      if (key == LogicalKeyboardKey.space ||
          key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.numpadEnter) {
        setState(() => _revealed = true);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // Not const: LogicalKeyboardKey overrides ==, so it cannot key a const map.
    final Map<LogicalKeyboardKey, ReviewGrade> bindings =
        <LogicalKeyboardKey, ReviewGrade>{
          LogicalKeyboardKey.digit1: ReviewGrade.again,
          LogicalKeyboardKey.numpad1: ReviewGrade.again,
          LogicalKeyboardKey.digit2: ReviewGrade.hard,
          LogicalKeyboardKey.numpad2: ReviewGrade.hard,
          LogicalKeyboardKey.digit3: ReviewGrade.good,
          LogicalKeyboardKey.numpad3: ReviewGrade.good,
          LogicalKeyboardKey.digit4: ReviewGrade.easy,
          LogicalKeyboardKey.numpad4: ReviewGrade.easy,
        };
    final ReviewGrade? grade = bindings[key];
    if (grade != null) {
      _grade(grade);
      return KeyEventResult.handled;
    }
    // Space on a revealed card repeats "Good", matching Anki.
    if (key == LogicalKeyboardKey.space) {
      _grade(ReviewGrade.good);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _grade(ReviewGrade grade) async {
    if (_grading || !_revealed || _index >= _queue.length) return;
    final GermanWord word = _queue[_index];
    setState(() => _grading = true);
    try {
      await widget.controller.gradeWord(word, grade);
      if (!mounted) return;
      setState(() {
        _graded += 1;
        _revealed = false;
        _index += 1;
      });
    } finally {
      if (mounted) setState(() => _grading = false);
    }
  }

  Future<void> _editMnemonic(GermanWord word) async {
    final TextEditingController input = TextEditingController(
      text: widget.controller.progressFor(word.id).mnemonic,
    );
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.of(context).mnemonicFor(word.displayGerman)),
        content: TextField(
          controller: input,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppText.of(context).mnemonicHint,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppText.of(context).cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text),
            child: Text(AppText.of(context).saveAction),
          ),
        ],
      ),
    );
    input.dispose();
    if (result == null) return;
    await widget.controller.setMnemonic(word.id, result);
  }

  @override
  Widget build(BuildContext context) {
    if (_queue.isEmpty || _index >= _queue.length) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.of(context).reviewTitle)),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('🌳', style: TextStyle(fontSize: 54)),
                const SizedBox(height: 12),
                Text(
                  _graded == 0
                      ? AppText.of(context).reviewNothingDue
                      : AppText.of(context).reviewCleared(_graded),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppText.of(context).doneAction),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final GermanWord word = _queue[_index];
    final WordProgress progress = widget.controller.progressFor(word.id);
    return Focus(
      focusNode: _keyboardFocus,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppText.of(context).reviewProgress(_index + 1, _queue.length),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(value: _index / _queue.length),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 20,
                      ),
                      child: Column(
                        children: <Widget>[
                          if (_revealed) ...<Widget>[
                            VocabVisual(word: word, size: 104),
                            const SizedBox(height: 16),
                            WordClassChip(word: word),
                            const SizedBox(height: 10),
                          ],
                          Text(
                            word.displayGerman,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: word.genderColor(
                                Theme.of(context).brightness,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          IconButton(
                            tooltip: AppText.of(context).hearWord,
                            onPressed: widget.controller.ttsEnabled
                                ? () => _tts.speakGerman(word.displayGerman)
                                : null,
                            icon: const Icon(Icons.volume_up_rounded),
                          ),
                          if (_revealed) ...<Widget>[
                            const Divider(height: 30),
                            Text(
                              widget.controller.meaningOf(word),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SpeakableSentence(
                              text: word.exampleGerman,
                              enabled: widget.controller.ttsEnabled,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              word.exampleEnglish,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (progress.mnemonic.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 14),
                              Text(
                                '🧠 ${progress.mnemonic}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppText.of(context).reviewSchedule(
                      progress.ease,
                      progress.intervalDays,
                      progress.lapses,
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: !_revealed
                    ? SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => setState(() => _revealed = true),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              PlatformSupport.isDesktop
                                  ? AppText.of(context).reviewRevealDesktop
                                  : AppText.of(context).showAnswer,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns =
                                  constraints.maxWidth < 480 ||
                                      (MediaQuery.textScalerOf(
                                                context,
                                              ).scale(12) >
                                              18 &&
                                          constraints.maxWidth < 650)
                                  ? 2
                                  : 4;
                              final width =
                                  (constraints.maxWidth - 8 * (columns - 1)) /
                                  columns;
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: ReviewGrade.values
                                    .map(
                                      (grade) => SizedBox(
                                        width: width,
                                        child: OutlinedButton(
                                          onPressed: _grading
                                              ? null
                                              : () => _grade(grade),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(grade.emoji),
                                                const SizedBox(height: 2),
                                                Text(
                                                  reviewGradeText(
                                                    AppText.of(context),
                                                    grade,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  reviewIntervalText(
                                                    AppText.of(context),
                                                    ease: progress.ease,
                                                    intervalDays:
                                                        progress.intervalDays,
                                                    reps: progress.reps,
                                                    lapses: progress.lapses,
                                                    learningStep:
                                                        progress.learningStep,
                                                    grade: grade,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => _editMnemonic(word),
                            icon: const Icon(Icons.psychology_outlined),
                            label: Text(
                              progress.mnemonic.isEmpty
                                  ? AppText.of(context).addMnemonic
                                  : AppText.of(context).reviewEditMnemonic,
                            ),
                          ),
                          if (PlatformSupport.isDesktop) ...<Widget>[
                            const SizedBox(height: 6),
                            Text(
                              AppText.of(context).reviewKeyboard,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Match pairs
// ---------------------------------------------------------------------------

class MatchPairsScreen extends StatefulWidget {
  const MatchPairsScreen({
    super.key,
    required this.controller,
    required this.level,
    this.activityId,
  });

  final AppController controller;
  final CefrLevel level;
  final String? activityId;

  @override
  State<MatchPairsScreen> createState() => _MatchPairsScreenState();
}

class _MatchPairsScreenState extends State<MatchPairsScreen>
    with PendingAction<MatchPairsScreen> {
  final Random _random = Random();
  final TtsService _tts = TtsService();

  late List<GermanWord> _round;
  late List<GermanWord> _left;
  late List<GermanWord> _right;
  late List<List<GermanWord>> _rounds;
  final Set<String> _solved = <String>{};
  String? _pickedLeftId;
  String? _pickedRightId;
  bool _wrongFlash = false;
  int _roundIndex = 0;
  int _mistakes = 0;
  int _elapsed = 0;
  Timer? _timer;
  late final Map<String, String> _meanings;
  late final int _eligibleCount;

  String _meaning(GermanWord word) => _meanings[word.id]!;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      '${widget.level.label} · word matching',
    );
    final words = widget.controller.wordsForLevel(widget.level);
    _meanings = {
      for (final word in words) word.id: widget.controller.meaningOf(word),
    };
    final eligible = eligibleMatchingWords(
      words: words,
      progress: widget.controller.progress,
      meaning: _meaning,
    );
    _eligibleCount = eligible.length;
    _rounds = dealMatchingRounds(eligible, _random);
    _deal();
    if (_rounds.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += 1);
      });
    }
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('${widget.level.label} · word matching');
    _timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  void _deal() {
    _round = _rounds.isEmpty ? <GermanWord>[] : _rounds[_roundIndex];
    _left = List<GermanWord>.of(_round)..shuffle(_random);
    _right = List<GermanWord>.of(_round)..shuffle(_random);
    _solved.clear();
    _pickedLeftId = null;
    _pickedRightId = null;
  }

  GermanWord? _wordForId(String id) {
    for (final GermanWord word in _round) {
      if (word.id == id) return word;
    }
    return null;
  }

  Future<void> _check() async {
    if (_pickedLeftId == null || _pickedRightId == null) return;
    await runAction(_resolvePair);
  }

  Future<void> _resolvePair() async {
    final String? left = _pickedLeftId;
    final String? right = _pickedRightId;
    if (left == null || right == null) return;
    final GermanWord? word = _wordForId(left);
    final GermanWord? chosenMeaning = _wordForId(right);
    if (word != null && left == right) {
      if (widget.controller.ttsEnabled) _tts.speakGerman(word.displayGerman);
      await widget.controller.gradeWord(word, ReviewGrade.good);
      if (!mounted) return;
      setState(() {
        _solved.add(left);
        _pickedLeftId = null;
        _pickedRightId = null;
      });
      if (_solved.length >= matchingPairsPerRound) await _nextRound();
      return;
    }
    _mistakes += 1;
    if (word != null) {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'match-${word.id}',
          prompt: word.displayGerman,
          correctAnswer: _meaning(word),
          givenAnswer: chosenMeaning == null ? '' : _meaning(chosenMeaning),
          source: 'vocabulary',
          level: word.level,
          timestamp: DateTime.now(),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _wrongFlash = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {
      _wrongFlash = false;
      _pickedLeftId = null;
      _pickedRightId = null;
    });
  }

  Future<void> _nextRound() async {
    if (_roundIndex + 1 >= _rounds.length) {
      _timer?.cancel();
      final int total = matchingPairsPerRound * _rounds.length;
      final int score = (((total - _mistakes).clamp(0, total) / total) * 100)
          .round();
      await widget.controller.recordActivity(
        widget.activityId ?? 'game-match-${widget.level.label.toLowerCase()}',
        score: score,
        passingScore: 70,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppText.of(context).gameRoundComplete),
          content: Text(
            AppText.of(context).gameMatchResult(_mistakes, score, _elapsed),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    if (!mounted) return;
    setState(() {
      _roundIndex += 1;
      _deal();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_rounds.isEmpty) {
      final int seen = _eligibleCount;
      return Scaffold(
        appBar: AppBar(title: Text(AppText.of(context).gameMatchPairs)),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.lock_clock_outlined, size: 48),
                const SizedBox(height: 14),
                Text(
                  AppText.of(context).gameLearnFirst,
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  AppText.of(context).gameMatchingLocked(
                    widget.level.label,
                    matchingPairsPerRound,
                    seen,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.of(context).gameMatchingTitle(widget.level.label)),
        actions: <Widget>[
          Center(child: Text(AppText.of(context).gameElapsedSeconds(_elapsed))),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_roundIndex + 1) / _rounds.length,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _column(_left, isLeft: true)),
            const SizedBox(width: 10),
            Expanded(child: _column(_right, isLeft: false)),
          ],
        ),
      ),
    );
  }

  Widget _column(List<GermanWord> items, {required bool isLeft}) {
    return Column(
      children: items.map((word) {
        final bool solved = _solved.contains(word.id);
        final bool picked = isLeft
            ? _pickedLeftId == word.id
            : _pickedRightId == word.id;
        final ColorScheme scheme = Theme.of(context).colorScheme;
        Color? background;
        if (solved) {
          background = scheme.tertiaryContainer;
        } else if (picked) {
          background = _wrongFlash
              ? scheme.errorContainer
              : scheme.primaryContainer;
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: background,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
              ),
              onPressed: solved || actionPending
                  ? null
                  : () {
                      if (actionPending || _solved.contains(word.id)) return;
                      setState(() {
                        if (isLeft) {
                          _pickedLeftId = word.id;
                        } else {
                          _pickedRightId = word.id;
                        }
                      });
                      _check();
                    },
              child: Text(
                isLeft ? word.displayGerman : _meaning(word),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Sentence builder
// ---------------------------------------------------------------------------

class SentenceBuilderScreen extends StatefulWidget {
  const SentenceBuilderScreen({
    super.key,
    required this.controller,
    required this.level,
    this.activityId,
  });

  final AppController controller;
  final CefrLevel level;
  final String? activityId;

  @override
  State<SentenceBuilderScreen> createState() => _SentenceBuilderScreenState();
}

class _SentenceBuilderScreenState extends State<SentenceBuilderScreen> {
  static const int questionsPerRound = 8;

  final Random _random = Random();
  final TtsService _tts = TtsService();

  late List<PracticeSentence> _items;
  final List<String> _built = <String>[];
  late List<String> _bank;
  int _index = 0;
  int _correct = 0;
  bool? _verdict;
  final Map<int, bool> _results = <int, bool>{};

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      '${widget.level.label} · sentence builder',
    );
    _items = sentencesFor(widget.level)..shuffle(_random);
    if (_items.length > questionsPerRound) {
      _items = _items.sublist(0, questionsPerRound);
    }
    _resetBank();
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity(
      '${widget.level.label} · sentence builder',
    );
    _tts.stop();
    super.dispose();
  }

  void _resetBank() {
    if (_items.isEmpty) {
      _bank = <String>[];
      return;
    }
    _built.clear();
    _bank = List<String>.from(_items[_index].tokens)..shuffle(_random);
    _verdict = null;
  }

  Future<void> _check() async {
    final PracticeSentence sentence = _items[_index];
    // Compared through the German normaliser so a stray space or a trailing
    // full stop in the authored sentence cannot fail a correctly built answer.
    final bool right = isGermanAnswerAccepted(
      _built.join(' '),
      sentence.german,
    );
    setState(() => _verdict = right);
    _results[_index] = right;
    _correct = _results.values.where((bool value) => value).length;
    if (right) {
      if (widget.controller.ttsEnabled) _tts.speakGerman(sentence.german);
    } else {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'build-${sentence.id}',
          prompt: sentence.english,
          correctAnswer: sentence.german,
          givenAnswer: _built.join(' '),
          source: 'grammar',
          level: widget.level.label,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _previous() {
    if (_index <= 0) return;
    final int target = _index - 1;
    setState(() {
      _results.remove(target);
      _correct = _results.values.where((bool value) => value).length;
      _index = target;
      _resetBank();
    });
  }

  Future<void> _skip() async {
    final PracticeSentence sentence = _items[_index];
    await widget.controller.recordSkip(
      id: 'build-${sentence.id}',
      prompt: sentence.english,
      correctAnswer: sentence.german,
      source: 'sentence-builder',
      level: widget.level.label,
    );
    if (mounted) await _next();
  }

  Future<void> _next() async {
    if (_index + 1 >= _items.length) {
      final int score = ((_correct / _items.length) * 100).round();
      await widget.controller.recordActivity(
        widget.activityId ?? 'game-build-${widget.level.label.toLowerCase()}',
        score: score,
        passingScore: 70,
      );
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    setState(() {
      _index += 1;
      _resetBank();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.of(context).gameSentenceBuilder)),
        body: Center(child: Text(AppText.of(context).gameSentencesEmpty)),
      );
    }
    final PracticeSentence sentence = _items[_index];
    final bool? verdict = _verdict;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppText.of(context).gameSentenceBuilderTitle(widget.level.label),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_index + 1) / _items.length),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        children: <Widget>[
          Text(
            AppText.of(context).gameBuildSentence,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            sentence.english,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(minHeight: 90),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _built
                  .asMap()
                  .entries
                  .map(
                    (entry) => ActionChip(
                      label: Text(entry.value),
                      onPressed: verdict != null
                          ? null
                          : () => setState(() {
                              _bank.add(_built.removeAt(entry.key));
                            }),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _bank
                .asMap()
                .entries
                .map(
                  (entry) => ActionChip(
                    label: Text(entry.value),
                    onPressed: verdict != null
                        ? null
                        : () => setState(() {
                            _built.add(_bank.removeAt(entry.key));
                          }),
                  ),
                )
                .toList(),
          ),
          PracticeAidPanel(
            questionKey: 'build-${sentence.id}',
            hints: verdict == null
                ? <Hint>[
                    if (sentence.focus.isNotEmpty &&
                        !leaksAnswer(sentence.focus, sentence.german))
                      Hint(text: sentence.focus, kind: HintKind.rule),
                    Hint(
                      text: AppText.of(context).gameSentenceHint,
                      kind: HintKind.structural,
                    ),
                  ]
                : const <Hint>[],
            onPrevious: _index > 0 ? _previous : null,
            onSkip: verdict == null ? _skip : null,
          ),
          const SizedBox(height: 24),
          if (verdict == null)
            FilledButton(
              onPressed: _built.isEmpty ? null : _check,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(AppText.of(context).checkAnswer),
              ),
            )
          else ...<Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      verdict
                          ? AppText.of(context).gameCorrect
                          : AppText.of(context).gameNotQuite,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sentence.german,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (sentence.focus.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        sentence.focus,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _next,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _index + 1 >= _items.length
                      ? AppText.of(context).finishAction
                      : AppText.of(context).actionNext,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dictation
// ---------------------------------------------------------------------------

class DictationScreen extends StatefulWidget {
  const DictationScreen({
    super.key,
    required this.controller,
    required this.level,
    this.activityId,
  });

  final AppController controller;
  final CefrLevel level;
  final String? activityId;

  @override
  State<DictationScreen> createState() => _DictationScreenState();
}

class _DictationScreenState extends State<DictationScreen> {
  static const int itemsPerRound = 6;

  final Random _random = Random();
  final TtsService _tts = TtsService();
  final TextEditingController _input = TextEditingController();

  late List<PracticeSentence> _items;
  int _index = 0;
  int _scoreTotal = 0;
  PronunciationResult? _result;
  final Map<int, int> _scores = <int, int>{};

  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('${widget.level.label} · dictation');
    _items = sentencesFor(widget.level)..shuffle(_random);
    if (_items.length > itemsPerRound) {
      _items = _items.sublist(0, itemsPerRound);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('${widget.level.label} · dictation');
    _input.dispose();
    _tts.stop();
    super.dispose();
  }

  void _play() {
    if (_items.isEmpty) return;
    if (!widget.controller.ttsEnabled) return;
    _tts.speakGerman(_items[_index].german, rate: _speed);
  }

  Future<void> _check() async {
    final PracticeSentence sentence = _items[_index];
    // The same alignment used for speech: it reports which words were dropped
    // or misspelled instead of a bare right/wrong.
    final PronunciationResult result = PronunciationScorer.compare(
      sentence.german,
      _input.text,
    );
    _scores[_index] = result.score;
    _scoreTotal = _scores.values.fold<int>(0, (int a, int b) => a + b);
    if (result.score < 80) {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'dict-${sentence.id}',
          prompt: 'Dictation: ${sentence.english}',
          correctAnswer: sentence.german,
          givenAnswer: _input.text,
          source: 'dictation',
          level: widget.level.label,
          timestamp: DateTime.now(),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _result = result);
  }

  void _previous() {
    if (_index <= 0) return;
    final int target = _index - 1;
    setState(() {
      _scores.remove(target);
      _scoreTotal = _scores.values.fold<int>(0, (int a, int b) => a + b);
      _index = target;
      _result = null;
      _input.clear();
    });
    _play();
  }

  Future<void> _skip() async {
    final PracticeSentence sentence = _items[_index];
    await widget.controller.recordSkip(
      id: 'dict-${sentence.id}',
      prompt: 'Dictation: ${sentence.english}',
      correctAnswer: sentence.german,
      source: 'dictation',
      level: widget.level.label,
    );
    if (mounted) await _next();
  }

  Future<void> _next() async {
    if (_index + 1 >= _items.length) {
      final int average = (_scoreTotal / _items.length).round();
      await widget.controller.recordActivity(
        widget.activityId ??
            'game-dictation-${widget.level.label.toLowerCase()}',
        score: average,
        passingScore: 70,
      );
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    setState(() {
      _index += 1;
      _result = null;
      _input.clear();
    });
    _play();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.of(context).gameDictation)),
        body: Center(child: Text(AppText.of(context).gameSentencesEmpty)),
      );
    }
    final PracticeSentence sentence = _items[_index];
    final PronunciationResult? result = _result;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.of(context).gameDictationTitle(widget.level.label)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_index + 1) / _items.length),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
        children: <Widget>[
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ChoiceChip(
                label: Text(AppText.of(context).gameSlow),
                selected: _speed == 0.75,
                onSelected: (_) => setState(() => _speed = 0.75),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(AppText.of(context).gameNormal),
                selected: _speed == 1.0,
                onSelected: (_) => setState(() => _speed = 1.0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(AppText.of(context).gameFast),
                selected: _speed == 1.25,
                onSelected: (_) => setState(() => _speed = 1.25),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: FilledButton.icon(
              onPressed: _play,
              icon: const Icon(Icons.replay_rounded),
              label: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text(AppText.of(context).playSentence),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _input,
            minLines: 2,
            maxLines: 4,
            enabled: result == null,
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppText.of(context).gameTypeHeard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          PracticeAidPanel(
            questionKey: 'dict-${sentence.id}',
            hints: result == null
                ? <Hint>[
                    Hint(
                      text: AppText.of(
                        context,
                      ).gameDictationHint(sentence.tokens.length),
                      kind: HintKind.structural,
                      personalized: personalizationForQuestion(
                        widget.controller.mistakes,
                        'dict-${sentence.id}',
                      ).hasHistory,
                    ),
                  ]
                : const <Hint>[],
            onPrevious: _index > 0 ? _previous : null,
            onSkip: result == null ? _skip : null,
          ),
          const SizedBox(height: 16),
          if (result == null)
            FilledButton(
              onPressed: _input.text.trim().isEmpty ? null : _check,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(AppText.of(context).checkAnswer),
              ),
            )
          else ...<Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${result.score}% ${result.stars}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: result.words.map((word) {
                        final ColorScheme scheme = Theme.of(
                          context,
                        ).colorScheme;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: word.isMatch
                                ? scheme.tertiaryContainer
                                : scheme.errorContainer,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(word.expected),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      sentence.german,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sentence.english,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _next,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _index + 1 >= _items.length
                      ? AppText.of(context).finishAction
                      : AppText.of(context).actionNext,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Speed review
// ---------------------------------------------------------------------------

class SpeedReviewScreen extends StatefulWidget {
  const SpeedReviewScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  State<SpeedReviewScreen> createState() => _SpeedReviewScreenState();
}

class _SpeedReviewScreenState extends State<SpeedReviewScreen> {
  static const int roundSeconds = 60;

  final Random _random = Random();
  Timer? _timer;
  int _remaining = roundSeconds;
  int _hits = 0;
  int _misses = 0;
  bool _running = true;

  late List<GermanWord> _pool;
  late GermanWord _current;
  late List<String> _options;
  int? _picked;
  late final Map<String, String> _meanings;
  late final bool _playable;

  String _meaning(GermanWord word) => _meanings[word.id]!;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      '${widget.level.label} · speed review',
    );
    _pool = widget.controller.wordsForLevel(widget.level).toList();
    _meanings = {
      for (final word in _pool) word.id: widget.controller.meaningOf(word),
    };
    _playable =
        _meanings.values
            .map((value) => value.trim().toLowerCase())
            .toSet()
            .length >=
        4;
    if (!_playable) return;
    _nextQuestion();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining -= 1);
      if (_remaining <= 0) _finish();
    });
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('${widget.level.label} · speed review');
    _timer?.cancel();
    super.dispose();
  }

  void _nextQuestion() {
    _pool.shuffle(_random);
    _current = _pool.first;
    final seenMeanings = {_meaning(_current).trim().toLowerCase()};
    final List<String> distractors = _pool
        .where((word) => seenMeanings.add(_meaning(word).trim().toLowerCase()))
        .map(_meaning)
        .toSet()
        .take(3)
        .toList();
    _options = <String>[_meaning(_current), ...distractors]..shuffle(_random);
    _picked = null;
  }

  Future<void> _pick(int index) async {
    if (!_running || _picked != null) return;
    final bool right = _options[index] == _meaning(_current);
    setState(() => _picked = index);
    if (right) {
      _hits += 1;
      await widget.controller.gradeWord(_current, ReviewGrade.good);
    } else {
      _misses += 1;
      await widget.controller.gradeWord(_current, ReviewGrade.again);
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'speed-${_current.id}',
          prompt: _current.displayGerman,
          correctAnswer: _meaning(_current),
          givenAnswer: _options[index],
          source: 'vocabulary',
          level: _current.level,
          timestamp: DateTime.now(),
        ),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted || !_running) return;
    setState(_nextQuestion);
  }

  Future<void> _finish() async {
    if (!_running) return;
    _running = false;
    _timer?.cancel();
    final int total = _hits + _misses;
    final int score = total == 0 ? 0 : ((_hits / total) * 100).round();
    await widget.controller.recordActivity(
      'game-speed-${widget.level.label.toLowerCase()}',
      score: score,
      passingScore: 70,
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_playable) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.of(context).gameSpeedReview)),
        body: Center(child: Text(AppText.of(context).gameSpeedEmpty)),
      );
    }
    if (!_running) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.of(context).gameSpeedReview)),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('⚡', style: TextStyle(fontSize: 54)),
                const SizedBox(height: 10),
                Text(
                  AppText.of(context).gameSpeedHits(_hits),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(AppText.of(context).gameSpeedMisses(_misses)),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppText.of(context).doneAction),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.of(context).gameRemainingSeconds(_remaining)),
        actions: <Widget>[
          Center(child: Text('✅ $_hits   ❌ $_misses')),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: _remaining / roundSeconds),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
        children: <Widget>[
          Text(
            _current.displayGerman,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: _current.genderColor(Theme.of(context).brightness),
            ),
          ),
          const SizedBox(height: 30),
          ..._options.asMap().entries.map((entry) {
            final bool isCorrect = entry.value == _meaning(_current);
            Color? background;
            if (_picked != null) {
              if (isCorrect) {
                background = Theme.of(context).colorScheme.tertiaryContainer;
              } else if (_picked == entry.key) {
                background = Theme.of(context).colorScheme.errorContainer;
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(backgroundColor: background),
                onPressed: _picked == null && _running
                    ? () => _pick(entry.key)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mistake bank and difficult words
// ---------------------------------------------------------------------------

class MistakeBankScreen extends StatefulWidget {
  const MistakeBankScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<MistakeBankScreen> createState() => _MistakeBankScreenState();
}

class _MistakeBankScreenState extends State<MistakeBankScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSource = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const sources = <String>[
      'all',
      'vocabulary',
      'grammar',
      'listening',
      'reading',
      'dictation',
      'story',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.of(context).gameMistakeBank),
        actions: <Widget>[
          IconButton(
            tooltip: AppText.of(context).gameClearAll,
            onPressed: () async {
              final bool? confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppText.of(context).gameClearMistakes),
                  content: Text(AppText.of(context).gameClearMistakesBody),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(AppText.of(context).cancelAction),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(AppText.of(context).gameClear),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await widget.controller.clearAllMistakes();
              }
            },
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final List<MistakeEntry> allEntries = widget.controller.mistakes;
          if (allEntries.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  AppText.of(context).gameMistakesEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final query = _searchController.text.trim().toLowerCase();
          final filtered = allEntries.where((entry) {
            final matchesSource =
                _selectedSource == 'all' ||
                entry.source.toLowerCase() == _selectedSource;
            final matchesQuery =
                query.isEmpty ||
                entry.prompt.toLowerCase().contains(query) ||
                entry.correctAnswer.toLowerCase().contains(query) ||
                entry.givenAnswer.toLowerCase().contains(query);
            return matchesSource && matchesQuery;
          }).toList();

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: AppText.of(context).gameSearchMistakes,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            tooltip: AppText.of(context).clearSearch,
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: sources.map((src) {
                    final label = mistakeSourceText(AppText.of(context), src);
                    final isSelected = _selectedSource == src;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedSource = src);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            AppText.of(context).gameMistakesFilteredEmpty,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final MistakeEntry entry = filtered[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                entry.prompt,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(height: 4),
                                  Text('✅ ${entry.correctAnswer}'),
                                  if (entry.givenAnswer.isNotEmpty)
                                    Text('❌ ${entry.givenAnswer}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${mistakeSourceText(AppText.of(context), entry.source)} • ${entry.level}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                tooltip: AppText.of(context).gameMistakeFixed,
                                onPressed: () =>
                                    widget.controller.clearMistake(entry.id),
                                icon: const Icon(Icons.check_circle_outline),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DifficultWordsScreen extends StatelessWidget {
  const DifficultWordsScreen({super.key, required this.controller});

  final AppController controller;

  Future<void> _editMnemonic(BuildContext context, GermanWord word) async {
    final TextEditingController input = TextEditingController(
      text: controller.progressFor(word.id).mnemonic,
    );
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.of(context).mnemonicFor(word.displayGerman)),
        content: TextField(
          controller: input,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppText.of(context).mnemonicHint,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppText.of(context).cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text),
            child: Text(AppText.of(context).saveAction),
          ),
        ],
      ),
    );
    input.dispose();
    if (result == null) return;
    await controller.setMnemonic(word.id, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppText.of(context).gameDifficultWords)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final List<GermanWord> words = controller.difficultWords;
          if (words.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  AppText.of(context).gameDifficultEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            itemCount: words.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final GermanWord word = words[index];
              final WordProgress progress = controller.progressFor(word.id);
              return Card(
                child: ListTile(
                  leading: VocabVisual(word: word, size: 44),
                  title: Text(
                    word.displayGerman,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${controller.meaningOf(word)} · ${word.grammarLabel}',
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppText.of(context).gameWordLapses(
                          progress.lapses,
                          progress.ease.toStringAsFixed(2),
                        ),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      if (progress.mnemonic.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          '🧠 ${progress.mnemonic}',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: AppText.of(context).gameMnemonic,
                    onPressed: () => _editMnemonic(context, word),
                    icon: const Icon(Icons.psychology_outlined),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Der/Die/Das Article Trainer
// ---------------------------------------------------------------------------

class ArticleTrainerScreen extends StatefulWidget {
  const ArticleTrainerScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  State<ArticleTrainerScreen> createState() => _ArticleTrainerScreenState();
}

class _ArticleTrainerScreenState extends State<ArticleTrainerScreen>
    with PendingAction<ArticleTrainerScreen> {
  final Random _random = Random();
  late List<GermanWord> _words;
  int _index = 0;
  bool? _correct;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      '${widget.level.label} · article trainer',
    );
    _words =
        widget.controller
            .wordsForLevel(widget.level)
            .where((w) => w.article.isNotEmpty)
            .toList()
          ..shuffle(_random);
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity(
      '${widget.level.label} · article trainer',
    );
    super.dispose();
  }

  Future<void> _choose(String article) async {
    if (_correct != null) return;
    await runAction(() => _recordChoice(article));
  }

  Future<void> _recordChoice(String article) async {
    final current = _words[_index];
    final bool correct = current.article.toLowerCase() == article.toLowerCase();
    await widget.controller.answer(current, correct: correct);
    if (!correct) {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'art-${current.id}',
          prompt: 'Article for "${current.german}"',
          correctAnswer: '${current.article} ${current.german}',
          givenAnswer: '$article ${current.german}',
          source: 'vocabulary',
          level: current.level,
          timestamp: DateTime.now(),
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _correct = correct;
      if (correct) _score += 10;
    });
  }

  void _next() {
    if (actionPending) return;
    if (_index + 1 >= _words.length) {
      _words.shuffle(_random);
      _index = 0;
    } else {
      _index += 1;
    }
    setState(() {
      _correct = null;
    });
  }

  void _previous() {
    if (_index <= 0 || actionPending) return;
    setState(() {
      _index -= 1;
      _correct = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.of(context).gameArticleTrainer)),
        body: Center(child: Text(AppText.of(context).gameNounsEmpty)),
      );
    }

    final GermanWord word = _words[_index];
    final String tip = _correct == null ? '' : word.genderEndingComment;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.of(context).gameArticleTitle(widget.level.label)),
        actions: <Widget>[
          IconButton(
            tooltip: AppText.of(context).gameArticleGuide,
            icon: const Icon(Icons.abc_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const GenderGuideScreen(),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(AppText.of(context).gameScore(_score)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: <Widget>[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 36,
                    horizontal: 20,
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        AppText.of(context).articleQuestion,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      VocabVisual(word: word, size: 104, revealGrammar: false),
                      const SizedBox(height: 14),
                      Text(
                        word.german,
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.controller.meaningOf(word),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (tip.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tip,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PracticeAidPanel(
                questionKey: 'article-${word.id}-$_index',
                hints: hintsForWord(
                  word,
                  answer: word.article,
                  personalization: HintPersonalization(
                    lapses: widget.controller.progressFor(word.id).lapses,
                    mnemonic: widget.controller.progressFor(word.id).mnemonic,
                  ),
                ),
                onPrevious: _index > 0 && !actionPending ? _previous : null,
                onSkip: _correct == null && !actionPending ? _next : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: _correct != null || actionPending
                          ? null
                          : () => _choose('der'),
                      child: const Text(
                        'DER',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: _correct != null || actionPending
                          ? null
                          : () => _choose('die'),
                      child: const Text(
                        'DIE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: _correct != null || actionPending
                          ? null
                          : () => _choose('das'),
                      child: const Text(
                        'DAS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_correct != null) ...<Widget>[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _correct == true
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _correct == true
                        ? AppText.of(
                            context,
                          ).gameArticleCorrect(word.displayGerman)
                        : AppText.of(context).gameArticleWrong(
                            word.displayGerman,
                            widget.controller.meaningOf(word),
                          ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                SpeakableSentence(
                  text: word.exampleGerman,
                  enabled: widget.controller.ttsEnabled,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(AppText.of(context).gameNextNoun),
                ),
              ] else
                const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Verb Conjugation & Tense Lab
// ---------------------------------------------------------------------------

class VerbConjugationItem {
  const VerbConjugationItem({
    required this.verb,
    required this.pronoun,
    required this.tense,
    required this.correctAnswer,
    required this.options,
    required this.explanation,
  });

  final String verb;
  final String pronoun;
  final String tense;
  final String correctAnswer;
  final List<String> options;
  final String explanation;
}

class VerbLabScreen extends StatefulWidget {
  const VerbLabScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  State<VerbLabScreen> createState() => _VerbLabScreenState();
}

class _VerbLabScreenState extends State<VerbLabScreen> {
  final Random _random = Random();
  late List<VerbConjugationItem> _items;
  int _index = 0;
  String? _selected;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('${widget.level.label} · verb lab');
    _items = _generateItems();
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('${widget.level.label} · verb lab');
    super.dispose();
  }

  List<VerbConjugationItem> _generateItems() {
    return <VerbConjugationItem>[
      const VerbConjugationItem(
        verb: 'sein',
        pronoun: 'wir',
        tense: 'Präsens',
        correctAnswer: 'sind',
        options: <String>['sind', 'seid', 'bin', 'ist'],
        explanation: 'sein in Präsens for wir: wir sind.',
      ),
      const VerbConjugationItem(
        verb: 'haben',
        pronoun: 'du',
        tense: 'Präsens',
        correctAnswer: 'hast',
        options: <String>['hast', 'habe', 'hat', 'haben'],
        explanation:
            'haben for du drops -en and adds -st with vowel change: du hast.',
      ),
      const VerbConjugationItem(
        verb: 'werden',
        pronoun: 'er/sie/es',
        tense: 'Präsens',
        correctAnswer: 'wird',
        options: <String>['wird', 'werdet', 'wirst', 'werden'],
        explanation: 'werden has vowel change e->i for er/sie/es: wird.',
      ),
      const VerbConjugationItem(
        verb: 'gehen',
        pronoun: 'ich',
        tense: 'Perfekt',
        correctAnswer: 'bin gegangen',
        options: <String>['bin gegangen', 'habe gegangen', 'ging', 'gehe'],
        explanation: 'gehen indicates motion, taking sein + ge-gang-en.',
      ),
      const VerbConjugationItem(
        verb: 'sprechen',
        pronoun: 'du',
        tense: 'Präsens',
        correctAnswer: 'sprichst',
        options: <String>['sprichst', 'sprechtest', 'sprich', 'sprecht'],
        explanation: 'sprechen is a strong verb with e->i change: du sprichst.',
      ),
      const VerbConjugationItem(
        verb: 'wollen',
        pronoun: 'ich',
        tense: 'Präsens',
        correctAnswer: 'will',
        options: <String>['will', 'wolle', 'wollt', 'willst'],
        explanation:
            'Modal verbs have identical 1st/3rd person singular forms: ich will.',
      ),
      const VerbConjugationItem(
        verb: 'können',
        pronoun: 'sie (plural)',
        tense: 'Präteritum',
        correctAnswer: 'konnten',
        options: <String>['konnten', 'könnten', 'kann', 'konntet'],
        explanation: 'können in Präteritum drops umlaut: sie konnten.',
      ),
      const VerbConjugationItem(
        verb: 'fahren',
        pronoun: 'er',
        tense: 'Präsens',
        correctAnswer: 'fährt',
        options: <String>['fährt', 'fahrt', 'fuhren', 'gefahren'],
        explanation:
            'fahren changes a->ä in 2nd/3rd person singular: er fährt.',
      ),
    ]..shuffle(_random);
  }

  void _choose(String option) async {
    if (_selected != null) return;
    final item = _items[_index];
    final bool correct = option == item.correctAnswer;
    setState(() {
      _selected = option;
    });
    if (correct) {
      await widget.controller.recordActivity('verb-lab', score: 100);
    } else {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'verb-${item.verb}-$_index',
          prompt: '${item.pronoun} (${item.verb} • ${item.tense})',
          correctAnswer: item.correctAnswer,
          givenAnswer: option,
          source: 'grammar',
          level: widget.level.label,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _next() {
    if (_index + 1 >= _items.length) {
      _items.shuffle(_random);
      _index = 0;
    } else {
      _index += 1;
    }
    setState(() {
      _selected = null;
    });
  }

  void _previous() {
    if (_index <= 0) return;
    setState(() {
      _index -= 1;
      _selected = null;
    });
  }

  List<Hint> _hintsFor(VerbConjugationItem item) {
    final int correctIndex = item.options.indexOf(item.correctAnswer);
    final String mistakeId = 'verb-${item.verb}-${item.pronoun}-${item.tense}';
    return hintsForChoice(
      ChoiceQuestion(
        prompt: '${item.pronoun} ___ (${item.verb} · ${item.tense})',
        options: item.options,
        correctIndex: correctIndex,
        explanation: '',
      ),
      ruleText: AppText.of(context).gameVerbHint,
      personalization: personalizationForQuestion(
        widget.controller.mistakes,
        mistakeId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.of(context).gameVerbTitle(widget.level.label)),
        actions: <Widget>[
          IconButton(
            tooltip: AppText.of(context).gameOpenTables,
            icon: const Icon(Icons.table_chart_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => GrammarTablesScreen(
                  initialLevel: widget.level,
                  ttsEnabled: widget.controller.ttsEnabled,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: <Widget>[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      Text(
                        AppText.of(
                          context,
                        ).gameConjugateVerb(item.verb.toUpperCase()),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppText.of(context).gameConjugationPrompt(item.pronoun),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppText.of(context).gameTense(item.tense),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PracticeAidPanel(
                questionKey:
                    'verb-${item.verb}-${item.pronoun}-${item.tense}-$_index',
                hints: _hintsFor(item),
                onPrevious: _index > 0 ? _previous : null,
                onSkip: _selected == null ? _next : null,
              ),
              const SizedBox(height: 24),
              ...item.options.map((opt) {
                final isSelected = _selected == opt;
                Color? bg;
                if (_selected != null) {
                  if (opt == item.correctAnswer) {
                    bg = Colors.green.withValues(alpha: 0.3);
                  } else if (isSelected) {
                    bg = Colors.red.withValues(alpha: 0.3);
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: bg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _selected != null ? null : () => _choose(opt),
                    child: Text(
                      opt,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
              if (_selected != null) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.explanation,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(AppText.of(context).gameNextVerb),
                ),
              ] else
                const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cloze Fill-in-the-Blank Drill
// ---------------------------------------------------------------------------

class ClozeDrillScreen extends StatefulWidget {
  const ClozeDrillScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  State<ClozeDrillScreen> createState() => _ClozeDrillScreenState();
}

class _ClozeDrillScreenState extends State<ClozeDrillScreen> {
  final Random _random = Random();
  late List<ClozeItem> _items;
  int _index = 0;
  String? _targetWord;
  String? _clozeSentence;
  List<String> _options = <String>[];
  String? _selected;
  bool? _correct;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('${widget.level.label} · cloze drill');
    // The bank gaps the word each sentence teaches, and draws its wrong answers
    // from the same word class and level. The previous version blanked
    // whichever token happened to be longest and offered three random tokens
    // from any sentence, so a noun gap could be answered by eliminating "und"
    // and "ist" -- and it rebuilt that pool on every single question, which is
    // roughly ninety thousand token operations per item now the deck is large.
    _items = clozeFor(widget.level).toList()..shuffle(_random);
    _loadCurrent();
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('${widget.level.label} · cloze drill');
    super.dispose();
  }

  void _loadCurrent() {
    if (_items.isEmpty) return;
    final ClozeItem item = _items[_index];
    _targetWord = item.answer;
    _clozeSentence = item.gapped;
    _options = item.optionsFor(_index);
  }

  void _choose(String option) async {
    if (_selected != null) return;
    final bool correct = option == _targetWord;
    setState(() {
      _selected = option;
      _correct = correct;
    });
    if (correct) {
      await widget.controller.recordActivity(
        'cloze-${widget.level.label}',
        score: 100,
      );
    } else {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'cloze-${_items[_index].id}',
          prompt: _clozeSentence ?? '',
          correctAnswer: _targetWord ?? '',
          givenAnswer: option,
          source: 'dictation',
          level: widget.level.label,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _next() {
    if (_index + 1 >= _items.length) {
      _items.shuffle(_random);
      _index = 0;
    } else {
      _index += 1;
    }
    setState(() {
      _selected = null;
      _correct = null;
    });
    _loadCurrent();
  }

  void _previous() {
    if (_index <= 0) return;
    setState(() {
      _index -= 1;
      _selected = null;
      _correct = null;
      _loadCurrent();
    });
  }

  List<Hint> _clozeHints(ClozeItem item) {
    final int correctIndex = _options.indexOf(item.answer);
    return hintsForChoice(
      ChoiceQuestion(
        prompt: item.gapped,
        options: _options,
        correctIndex: correctIndex,
        explanation: '',
      ),
      ruleText: AppText.of(context).gameClozeHint,
      personalization: personalizationForQuestion(
        widget.controller.mistakes,
        'cloze-${item.id}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.of(context).gameCloze)),
        body: Center(child: Text(AppText.of(context).gameClozeEmpty)),
      );
    }

    final ClozeItem sentence = _items[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.of(context).gameClozeTitle(widget.level.label)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: <Widget>[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      Text(
                        AppText.of(context).gameFillGap,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _clozeSentence ?? '',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        sentence.english,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PracticeAidPanel(
                questionKey: 'cloze-${sentence.id}-$_index',
                hints: _clozeHints(sentence),
                onPrevious: _index > 0 ? _previous : null,
                onSkip: _selected == null ? _next : null,
              ),
              const SizedBox(height: 24),
              ..._options.map((opt) {
                final isSelected = _selected == opt;
                Color? bg;
                if (_selected != null) {
                  if (opt == _targetWord) {
                    bg = Colors.green.withValues(alpha: 0.3);
                  } else if (isSelected) {
                    bg = Colors.red.withValues(alpha: 0.3);
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: bg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _selected != null ? null : () => _choose(opt),
                    child: Text(
                      opt,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
              if (_selected != null) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _correct == true
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _correct == true
                        ? AppText.of(
                            context,
                          ).gameFullSentenceCorrect(sentence.full)
                        : AppText.of(context).gameFullSentenceWrong(
                            _targetWord ?? '',
                            sentence.full,
                          ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(AppText.of(context).audioNextSentence),
                ),
              ] else
                const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TTS Shadowing & Speed Control Lab
// ---------------------------------------------------------------------------

class ShadowLabScreen extends StatefulWidget {
  const ShadowLabScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  State<ShadowLabScreen> createState() => _ShadowLabScreenState();
}

class _ShadowLabScreenState extends State<ShadowLabScreen> {
  final TtsService _tts = TtsService();
  final SpeechService _speech = SpeechService();
  final Random _random = Random();
  final TextEditingController _input = TextEditingController();
  late List<PracticeSentence> _sentences;
  int _index = 0;
  double _speed = 1.0;
  PronunciationResult? _result;
  bool _listening = false;
  bool _evaluating = false;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      '${widget.level.label} · shadowing lab',
    );
    _sentences = sentencesFor(widget.level).toList()..shuffle(_random);
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('${widget.level.label} · shadowing lab');
    _input.dispose();
    _tts.stop();
    _speech.cancel();
    super.dispose();
  }

  void _speak() {
    if (_sentences.isEmpty) return;
    _tts.speakGerman(_sentences[_index].german, rate: _speed);
  }

  Future<void> _evaluate() async {
    if (_sentences.isEmpty || _evaluating) return;
    _evaluating = true;
    if (_listening) await _speech.stop();
    final expected = _sentences[_index].german;
    final heard = _input.text.trim();
    if (heard.isEmpty) {
      _evaluating = false;
      return;
    }
    final res = PronunciationScorer.compare(expected, heard);
    await widget.controller.recordActivity(
      'shadow-${widget.level.label}',
      score: res.score,
    );
    if (!mounted) return;
    setState(() {
      _listening = false;
      _evaluating = false;
      _result = res;
    });
  }

  Future<void> _toggleMic() async {
    if (_listening) {
      await _speech.stop();
      return;
    }
    setState(() {
      _input.clear();
      _result = null;
    });
    final bool started = await _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onTranscript: (String words, bool isFinal) {
        if (!mounted) return;
        setState(() => _input.text = words);
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _listening = false);
        if (_input.text.trim().isNotEmpty && !_evaluating) {
          unawaited(_evaluate());
        }
      },
    );
    if (!mounted) return;
    if (!started) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_speech.unavailableReason)));
      return;
    }
    setState(() => _listening = true);
  }

  void _next() {
    if (_index + 1 >= _sentences.length) {
      _sentences.shuffle(_random);
      _index = 0;
    } else {
      _index += 1;
    }
    setState(() {
      _input.clear();
      _result = null;
      _listening = false;
    });
  }

  void _previous() {
    if (_index <= 0) return;
    setState(() {
      _index -= 1;
      _input.clear();
      _result = null;
      _listening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sentences.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.of(context).gameShadowing)),
        body: Center(child: Text(AppText.of(context).gameShadowingEmpty)),
      );
    }

    final sentence = _sentences[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.of(context).gameShadowingTitle(widget.level.label)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Text(
                        sentence.german,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(sentence.english, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          ChoiceChip(
                            label: Text(AppText.of(context).gameSlow),
                            selected: _speed == 0.75,
                            onSelected: (_) => setState(() => _speed = 0.75),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text(AppText.of(context).gameNormal),
                            selected: _speed == 1.0,
                            onSelected: (_) => setState(() => _speed = 1.0),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text(AppText.of(context).gameFast),
                            selected: _speed == 1.25,
                            onSelected: (_) => setState(() => _speed = 1.25),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _speak,
                        icon: const Icon(Icons.volume_up_rounded),
                        label: Text(AppText.of(context).gameListenModel),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PracticeAidPanel(
                questionKey: 'shadow-${sentence.id}-$_index',
                hints: <Hint>[
                  Hint(
                    text: AppText.of(context).gameShadowingRhythmHint,
                    kind: HintKind.structural,
                  ),
                  Hint(
                    text: AppText.of(context).gameShadowingChunksHint,
                    kind: HintKind.rule,
                  ),
                ],
                onPrevious: _index > 0 ? _previous : null,
                onSkip: _next,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _input,
                decoration: InputDecoration(
                  labelText: AppText.of(context).gameRepeatSentence,
                  hintText: AppText.of(context).gameTypeHeard,
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _evaluating ? null : _toggleMic,
                      icon: Icon(
                        _listening ? Icons.stop_rounded : Icons.mic_rounded,
                      ),
                      label: Text(
                        _listening
                            ? AppText.of(context).gameFinishNow
                            : AppText.of(context).speakAction,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _input.text.trim().isEmpty || _evaluating
                          ? null
                          : _evaluate,
                      icon: const Icon(Icons.analytics_outlined),
                      label: Text(
                        _evaluating
                            ? AppText.of(context).scoringStatus
                            : AppText.of(context).gameScoreAttempt,
                      ),
                    ),
                  ),
                ],
              ),
              if (_listening) ...<Widget>[
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
                const SizedBox(height: 4),
                Text(
                  AppText.of(context).gameListeningStatus,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (_result != null) ...<Widget>[
                const SizedBox(height: 20),
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppText.of(
                            context,
                          ).gameAttemptResult(_result!.score, _result!.stars),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recognisedWordsVerdict(AppText.of(context), _result!),
                        ),
                        const Divider(),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _result!.words.map((w) {
                            final color = w.isMatch
                                ? Colors.green
                                : w.isClose
                                ? Colors.orange
                                : Colors.red;
                            return Chip(
                              label: Text(w.expected),
                              backgroundColor: color.withValues(alpha: 0.2),
                              side: BorderSide(color: color),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _next,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(AppText.of(context).audioNextSentence),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grammar Challenge Collections
// ---------------------------------------------------------------------------

/// Picker for the twelve corpus-derived collections in
/// `lib/grammar_challenge.dart`. Each is one confusion -- nominative vs.
/// accusative articles, haben vs. sein, im vs. ins -- rather than one
/// shuffled pile of every rule at once, so a learner can drill exactly the
/// mistake they keep making.
class GrammarChallengeHubScreen extends StatelessWidget {
  const GrammarChallengeHubScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppText.of(context).gameGrammarChallenges)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: GrammarFeature.values.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final GrammarFeature feature = GrammarFeature.values[index];
            final int count = challengesFor(feature).length;
            return Card(
              child: ListTile(
                title: Text(
                  grammarFeatureLabel(AppText.of(context), feature),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  AppText.of(context).gameGrammarFeatureSummary(
                    count,
                    grammarFeatureDescription(AppText.of(context), feature),
                  ),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: count == 0
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => GrammarChallengeDrillScreen(
                            controller: controller,
                            feature: feature,
                          ),
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GrammarChallengeDrillScreen extends StatefulWidget {
  const GrammarChallengeDrillScreen({
    super.key,
    required this.controller,
    required this.feature,
  });

  final AppController controller;
  final GrammarFeature feature;

  @override
  State<GrammarChallengeDrillScreen> createState() =>
      _GrammarChallengeDrillScreenState();
}

class _GrammarChallengeDrillScreenState
    extends State<GrammarChallengeDrillScreen> {
  final Random _random = Random();
  late List<GrammarChallengeItem> _items;
  int _index = 0;
  String? _targetAnswer;
  String? _gapped;
  List<String> _options = <String>[];
  String? _selected;
  bool? _correct;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      'Grammar challenge · ${widget.feature.label}',
    );
    _items = challengesFor(widget.feature).toList()..shuffle(_random);
    _loadCurrent();
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity(
      'Grammar challenge · ${widget.feature.label}',
    );
    super.dispose();
  }

  void _loadCurrent() {
    if (_items.isEmpty) return;
    final GrammarChallengeItem item = _items[_index];
    _targetAnswer = item.answer;
    _gapped = item.gapped;
    _options = item.optionsFor(_index);
  }

  void _choose(String option) async {
    if (_selected != null) return;
    final bool correct = option == _targetAnswer;
    setState(() {
      _selected = option;
      _correct = correct;
    });
    if (correct) {
      await widget.controller.recordActivity(
        'grammar-challenge-${widget.feature.name}',
        score: 100,
      );
    } else {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'gc-${_items[_index].id}',
          prompt: _gapped ?? '',
          correctAnswer: _targetAnswer ?? '',
          givenAnswer: option,
          source: 'grammar',
          level: _items[_index].level.label,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _next() {
    if (_index + 1 >= _items.length) {
      _items.shuffle(_random);
      _index = 0;
    } else {
      _index += 1;
    }
    setState(() {
      _selected = null;
      _correct = null;
    });
    _loadCurrent();
  }

  void _previous() {
    if (_index <= 0) return;
    setState(() {
      _index -= 1;
      _selected = null;
      _correct = null;
      _loadCurrent();
    });
  }

  List<Hint> _challengeHints(GrammarChallengeItem item) {
    final int correctIndex = _options.indexOf(item.answer);
    return hintsForChoice(
      ChoiceQuestion(
        prompt: item.gapped,
        options: _options,
        correctIndex: correctIndex,
        explanation: '',
      ),
      ruleText: grammarFeatureDescription(AppText.of(context), widget.feature),
      personalization: personalizationForQuestion(
        widget.controller.mistakes,
        'gc-${item.id}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(grammarFeatureLabel(AppText.of(context), widget.feature)),
        ),
        body: Center(child: Text(AppText.of(context).gameGrammarFeatureEmpty)),
      );
    }

    final GrammarChallengeItem item = _items[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text(grammarFeatureLabel(AppText.of(context), widget.feature)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: <Widget>[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      Text(
                        grammarFeatureDescription(
                          AppText.of(context),
                          widget.feature,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _gapped ?? '',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.english,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              PracticeAidPanel(
                questionKey: 'grammar-${item.id}-$_index',
                hints: _challengeHints(item),
                onPrevious: _index > 0 ? _previous : null,
                onSkip: _selected == null ? _next : null,
              ),
              const SizedBox(height: 24),
              ..._options.map((opt) {
                final isSelected = _selected == opt;
                Color? bg;
                if (_selected != null) {
                  if (opt == _targetAnswer) {
                    bg = Colors.green.withValues(alpha: 0.3);
                  } else if (isSelected) {
                    bg = Colors.red.withValues(alpha: 0.3);
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: bg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _selected != null ? null : () => _choose(opt),
                    child: Text(
                      opt,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
              if (_selected != null) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _correct == true
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _correct == true
                        ? AppText.of(context).gameFullSentenceCorrect(item.full)
                        : AppText.of(context).gameFullSentenceWrong(
                            _targetAnswer ?? '',
                            item.full,
                          ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(AppText.of(context).actionNext),
                ),
              ] else
                const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
