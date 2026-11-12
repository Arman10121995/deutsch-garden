import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'answer_option.dart';
import 'app_state.dart';
import 'german_text.dart';
import 'models.dart';
import 'hints.dart';
import 'platform_support.dart';
import 'practice_aids.dart';
import 'quiz_distractors.dart';
import 'sentence_audio.dart';
import 'tts_service.dart';
import 'vocab_icon.dart';
import 'vocabulary_metadata.dart';
import 'vocabulary_text.dart';
import 'compound_breakdown.dart';
import 'l10n/app_localizations.dart';

class StudySessionScreen extends StatefulWidget {
  const StudySessionScreen({
    super.key,
    required this.controller,
    required this.kind,
    required this.level,
  });

  final AppController controller;
  final SessionKind kind;
  final CefrLevel level;

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  final Random _random = Random();
  final TtsService _tts = TtsService();
  final TextEditingController _typing = TextEditingController();
  final FocusNode _keys = FocusNode(debugLabel: 'study-shortcuts');
  final FocusNode _typingFocus = FocusNode(debugLabel: 'study-typing');

  /// Word classes are derived from the gloss by a chain of regular
  /// expressions. One sitting asks for the same few hundred repeatedly while
  /// choosing wrong options, so they are worked out once.
  final Map<String, GermanWordClass> _classes = <String, GermanWordClass>{};

  late final List<SessionQuestion> _questions;
  late final Map<String, String> _meanings;
  late final int _startXp;
  int _index = 0;
  bool? _correct;
  bool _answered = false;
  bool _umlautVariant = false;

  /// The option the learner tapped, so it can be marked once answered. Null
  /// for a typed answer.
  String? _chosen;

  /// Questions whose wrong answer queued a second try at the end of the
  /// sitting. Undoing such an answer has to take the second try back out.
  final Set<int> _retrySpawned = <int>{};
  int _correctInSession = 0;
  int _answeredInSession = 0;
  final Map<int, bool> _gradedAnswers = <int, bool>{};
  final Set<int> _reviewedIndices = <int>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      '${widget.level.label} · ${widget.kind.name} vocabulary',
    );
    _startXp = widget.controller.xp;
    // Capture meanings once for the sitting. Changing a setting while an
    // answer is on screen must not change its labels or correct answer.
    _meanings = {
      for (final word in widget.controller.wordsForLevel(widget.level))
        word.id: widget.controller.meaningOf(word),
    };
    _questions = _buildQuestions();
    _syncFocus();
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity(
      '${widget.level.label} · ${widget.kind.name} vocabulary',
    );
    _typing.dispose();
    _keys.dispose();
    _typingFocus.dispose();
    _tts.stop();
    super.dispose();
  }

  List<SessionQuestion> _buildQuestions() {
    final levelWords = widget.controller.wordsForLevel(widget.level);
    List<GermanWord> base;
    switch (widget.kind) {
      case SessionKind.learn:
        base = widget.controller
            .newWordsForLevel(widget.level)
            .take(10)
            .toList();
        if (base.isEmpty) {
          base = levelWords.take(10).toList();
        }
        final questions = <SessionQuestion>[];
        for (final word in base) {
          questions.add(SessionQuestion(word: word, mode: QuizMode.flashcard));
          questions.add(_makeTestQuestion(word, forcedMode: QuizMode.meaning));
        }
        return questions;
      case SessionKind.review:
        base = widget.controller
            .reviewWordsForLevel(widget.level)
            .take(20)
            .toList();
        break;
      case SessionKind.practice:
        base = levelWords
            .where((w) => widget.controller.progress[w.id]?.seen ?? false)
            .toList();
        if (base.isEmpty) base = levelWords.take(15).toList();
        base.shuffle(_random);
        base = base.take(20).toList();
        break;
    }
    return base.map(_makeTestQuestion).toList();
  }

  SessionQuestion _makeTestQuestion(
    GermanWord word, {
    QuizMode? forcedMode,
    bool retry = false,
  }) {
    final modes = <QuizMode>[
      QuizMode.meaning,
      QuizMode.german,
      if (word.article.isNotEmpty) QuizMode.article,
      QuizMode.typing,
    ];
    final mode = forcedMode ?? modes[_random.nextInt(modes.length)];
    final options = <String>[];

    // The wrong options are words this one could plausibly have been: the
    // same word class, and where the level has them, the same topic. See
    // lib/quiz_distractors.dart for why a random draw taught nothing.
    if (mode == QuizMode.meaning) {
      options.add(_meaning(word));
      options.addAll(
        pickDistractors(
          target: word,
          pool: widget.controller.wordsForLevel(widget.level),
          label: _meaning,
          random: _random,
          classCache: _classes,
        ).map(_meaning),
      );
      options.shuffle(_random);
    } else if (mode == QuizMode.german) {
      options.add(word.displayGerman);
      options.addAll(
        pickDistractors(
          target: word,
          pool: widget.controller.wordsForLevel(widget.level),
          label: (GermanWord w) => w.displayGerman,
          // A synonym would be a second right answer to "which German word
          // means this?".
          conflict: _meaning,
          random: _random,
          classCache: _classes,
        ).map((GermanWord w) => w.displayGerman),
      );
      options.shuffle(_random);
    } else if (mode == QuizMode.article) {
      options.addAll(const <String>['der', 'die', 'das']);
      options.shuffle(_random);
    }

    return SessionQuestion(
      word: word,
      mode: mode,
      options: options,
      retry: retry,
    );
  }

  /// Puts the keyboard where the current step needs it: in the text field for
  /// a typed answer, on the shortcut handler otherwise.
  ///
  /// `autofocus` alone cannot do this. It only applies when nothing in the
  /// scope is focused yet, and from the second question on something is.
  void _syncFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bool typing =
          _index < _questions.length &&
          _question.mode == QuizMode.typing &&
          !_answered;
      (typing ? _typingFocus : _keys).requestFocus();
    });
  }

  /// Number keys choose an option and Enter or Space moves on, so a sitting
  /// can be worked through without reaching for the mouse between every word.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _busy) return KeyEventResult.ignored;
    if (_index >= _questions.length) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    final SessionQuestion question = _question;

    // Enter and Space belong to whatever control the learner has tabbed to.
    // They only mean "continue" while nothing more specific holds the focus.
    final bool advance = isAdvanceKey(key) && node.hasPrimaryFocus;
    if (question.mode == QuizMode.flashcard) {
      if (!advance) return KeyEventResult.ignored;
      _continueFromFlashcard();
      return KeyEventResult.handled;
    }
    if (_answered) {
      if (!advance) return KeyEventResult.ignored;
      _nextAfterAnswer();
      return KeyEventResult.handled;
    }
    // A typed answer needs every key, digits included.
    if (question.mode == QuizMode.typing) return KeyEventResult.ignored;
    final int? digit = answerDigitFor(key);
    if (digit == null || digit > question.options.length) {
      return KeyEventResult.ignored;
    }
    _choose(question.options[digit - 1]);
    return KeyEventResult.handled;
  }

  bool _isCorrectOption(SessionQuestion question, String option) =>
      option == _correctAnswerFor(question);

  void _choose(String option) {
    if (_answered || _busy) return;
    _submit(_isCorrectOption(_question, option), givenAnswer: option);
  }

  SessionQuestion get _question => _questions[_index];

  AppText get _t => AppText.of(context);
  String _meaning(GermanWord word) => _meanings[word.id] ?? word.english;

  String get _feedbackText => _correct == true
      ? _umlautVariant
            ? _t.umlautSpelling(_question.word.displayGerman)
            : _t.answerCorrectXp(
                widget.controller.progressFor(_question.word.id).plantIcon,
              )
      : _t.answerWrongWithCorrect(
          _question.word.displayGerman,
          _meaning(_question.word),
        );

  Future<void> _withMutationLock(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _correctAnswerFor(SessionQuestion question) => switch (question.mode) {
    QuizMode.meaning => _meaning(question.word),
    QuizMode.article => question.word.article,
    _ => question.word.displayGerman,
  };

  Future<void> _submit(
    bool correct, {
    required String givenAnswer,
    bool umlautVariant = false,
  }) async {
    if (_answered) return;
    await _withMutationLock(() async {
      final SessionQuestion question = _question;
      final String prompt = _promptFor(question.mode);
      final word = question.word;
      await widget.controller.answer(word, correct: correct);
      _reviewedIndices.add(_index);
      if (!correct) {
        await widget.controller.addMistake(
          MistakeEntry(
            id: 'vocab-${word.id}',
            prompt: prompt,
            correctAnswer: _correctAnswerFor(question),
            givenAnswer: givenAnswer,
            source: 'vocabulary',
            level: word.level,
            timestamp: DateTime.now(),
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _correct = correct;
        _answeredInSession += 1;
        if (correct) _correctInSession += 1;
        _gradedAnswers[_index] = correct;
        _answered = true;
        _umlautVariant = umlautVariant;
        _chosen = question.mode == QuizMode.typing ? null : givenAnswer;
        // Being shown the answer is not the same as being able to produce
        // it. A missed word is asked once more after everything else, which
        // is the delayed retrieval the scheduler's own one-minute relearning
        // step assumes will happen. A second miss is not queued again: the
        // word is already due and the sitting has to end.
        if (!correct && !question.retry) {
          _questions.add(
            _makeTestQuestion(word, forcedMode: question.mode, retry: true),
          );
          _retrySpawned.add(_index);
        }
      });
      _syncFocus();
    });
  }

  Future<void> _continueFromFlashcard() async {
    await _withMutationLock(() async {
      await widget.controller.markSeen(_question.word);
      if (!mounted) return;
      _advance();
    });
  }

  void _advance() {
    if (_index + 1 >= _questions.length) {
      setState(() => _index = _questions.length);
      return;
    }
    setState(() {
      _index += 1;
      _correct = null;
      _answered = false;
      _umlautVariant = false;
      _chosen = null;
      _typing.clear();
    });
    _syncFocus();
  }

  Future<void> _previous() async {
    await _withMutationLock(() async {
      final int target = _index >= _questions.length
          ? _questions.length - 1
          : _index - 1;
      if (target < 0) return;
      if (_reviewedIndices.remove(target)) {
        await widget.controller.undoLastReview(_questions[target].word.id);
      }
      final bool? old = _gradedAnswers.remove(target);
      if (old != null) {
        _answeredInSession = max(0, _answeredInSession - 1);
        if (old) _correctInSession = max(0, _correctInSession - 1);
      }
      // Second tries are appended in the order their questions were missed,
      // and Previous only ever steps back one question at a time, so the one
      // belonging to the answer being undone is always the last in the list.
      if (_retrySpawned.remove(target)) _questions.removeLast();
      if (!mounted) return;
      setState(() {
        _index = target;
        _correct = null;
        _answered = false;
        _umlautVariant = false;
        _chosen = null;
        _typing.clear();
      });
      _syncFocus();
    });
  }

  Future<void> _skip() async {
    await _withMutationLock(() async {
      final SessionQuestion question = _question;
      await widget.controller.recordSkip(
        id: 'vocab-${question.word.id}',
        prompt: _promptFor(question.mode),
        correctAnswer: _correctAnswerFor(question),
        source: 'vocabulary',
        level: question.word.level,
        word: question.word,
      );
      _reviewedIndices.add(_index);
      if (mounted) _advance();
    });
  }

  void _nextAfterAnswer() {
    if (_busy || !_answered) return;
    _advance();
  }

  HintPersonalization get _wordPersonalization {
    final WordProgress progress = widget.controller.progressFor(
      _question.word.id,
    );
    final HintPersonalization history = personalizationForQuestion(
      widget.controller.mistakes,
      'vocab-${_question.word.id}',
    );
    return HintPersonalization(
      priorAttempts: history.priorAttempts,
      priorWrongAnswer: history.priorWrongAnswer,
      wasSkipped: history.wasSkipped,
      lapses: progress.lapses,
      mnemonic: progress.mnemonic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_t.reviewTitle)),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(_t.noReviewsBody, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (_index >= _questions.length) {
      return _buildSummary(context);
    }

    final progress = (_index + 1) / _questions.length;
    final bool flashcard = _question.mode == QuizMode.flashcard;
    return Focus(
      focusNode: _keys,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.level.label} • ${_titleForKind()}'),
          actions: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(_t.xpValue(widget.controller.xp)),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              LinearProgressIndicator(value: progress, minHeight: 7),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: flashcard
                      ? _buildFlashcard(context)
                      : _buildQuiz(context),
                ),
              ),
              if (flashcard || _answered) _buildActionBar(context, flashcard),
            ],
          ),
        ),
      ),
    );
  }

  /// The step's one way forward, kept clear of the scrolling content.
  ///
  /// A new-word card is taller than a phone screen, so "test me" used to sit
  /// below the fold and every card began with a scroll to find it. The same
  /// went for Continue once an answer's feedback had pushed it down.
  Widget _buildActionBar(BuildContext context, bool flashcard) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (flashcard) ...<Widget>[
            FilledButton.icon(
              onPressed: _busy ? null : _continueFromFlashcard,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(_t.testMe),
              ),
            ),
            if (_index > 0)
              TextButton.icon(
                onPressed: _busy ? null : _previous,
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(_t.previousAction),
              ),
          ] else
            FilledButton(
              onPressed: _busy ? null : _nextAfterAnswer,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(_t.continueAction),
              ),
            ),
        ],
      ),
    );
  }

  String _titleForKind() {
    switch (widget.kind) {
      case SessionKind.learn:
        return _t.learnNewWords;
      case SessionKind.review:
        return _t.smartReview;
      case SessionKind.practice:
        return _t.practiceTitle;
    }
  }

  Widget _buildFlashcard(BuildContext context) {
    final word = _question.word;
    final brightness = Theme.of(context).brightness;
    final color = word.genderColor(brightness);
    final p = widget.controller.progressFor(word.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          _t.newWord,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: <Widget>[
                VocabVisual(word: word, size: 112),
                const SizedBox(height: 16),
                WordClassChip(word: word),
                const SizedBox(height: 10),
                if (word.article.isNotEmpty) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      word.article.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  word.german,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                if (word.plural != '—' && word.plural.isNotEmpty)
                  Text(_t.wordPlural(word.plural)),
                const SizedBox(height: 14),
                IconButton.filledTonal(
                  tooltip: _t.hearWord,
                  onPressed: widget.controller.ttsEnabled
                      ? () => _tts.speakGerman(word.displayGerman)
                      : null,
                  icon: const Icon(Icons.volume_up_rounded),
                ),
                const Divider(height: 40),
                Text(
                  _meaning(word),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        SpeakableSentence(
                          text: word.exampleGerman,
                          enabled: widget.controller.ttsEnabled,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(word.exampleEnglish, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                if (hasCompoundBreakdown(word)) ...<Widget>[
                  const SizedBox(height: 12),
                  // This is the "NEW WORD" introduction, where the word and
                  // its example are already on screen -- there is nothing
                  // here to give away, and meeting a compound for the first
                  // time is exactly when its parts are worth seeing. The
                  // recall modes deliberately do not show this: there the
                  // parts would hand over the answer.
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CompoundBreakdown(word: word, compact: true),
                  ),
                ],
                if (word.nounGender != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    genderEndingText(AppText.of(context), word),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                if (p.mnemonic.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _editMnemonic(word),
                    icon: const Icon(Icons.psychology_outlined, size: 18),
                    label: Text(
                      _t.mnemonicLabel(p.mnemonic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => _editMnemonic(word),
                    icon: const Icon(Icons.psychology_outlined, size: 18),
                    label: Text(_t.addMnemonic),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editMnemonic(GermanWord word) async {
    final TextEditingController input = TextEditingController(
      text: widget.controller.progressFor(word.id).mnemonic,
    );
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t.mnemonicFor(word.displayGerman)),
        content: TextField(
          controller: input,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(hintText: _t.mnemonicHint),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text),
            child: Text(_t.saveAction),
          ),
        ],
      ),
    );
    input.dispose();
    if (result == null) return;
    await widget.controller.setMnemonic(word.id, result);
    if (mounted) setState(() {});
  }

  Widget _buildQuiz(BuildContext context) {
    final q = _question;
    final bool choice = q.mode != QuizMode.typing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (q.retry) ...<Widget>[
          Center(
            child: Chip(
              avatar: const Icon(Icons.replay_rounded, size: 18),
              label: Text(_t.studyRetryBadge),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          _promptFor(q.mode),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: <Widget>[
                if (q.mode == QuizMode.meaning) ...<Widget>[
                  Text(
                    q.word.displayGerman,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: q.word.genderColor(Theme.of(context).brightness),
                    ),
                  ),
                  const SizedBox(height: 10),
                  IconButton.filledTonal(
                    onPressed: widget.controller.ttsEnabled
                        ? () => _tts.speakGerman(q.word.displayGerman)
                        : null,
                    icon: const Icon(Icons.volume_up_rounded),
                  ),
                ] else if (q.mode == QuizMode.german ||
                    q.mode == QuizMode.article ||
                    q.mode == QuizMode.typing) ...<Widget>[
                  Text(
                    _meaning(q.word),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (q.mode == QuizMode.article) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      q.word.german,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (q.mode == QuizMode.typing)
          _buildTypingAnswer(context)
        else
          ...q.options.map((option) => _buildOption(option)),
        if (!_answered) ...<Widget>[
          if (choice && PlatformSupport.isDesktop)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _t.studyKeyboardHint(q.options.length),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          const SizedBox(height: 6),
          PracticeAidPanel(
            questionKey: '${q.word.id}-${q.mode.name}-$_index',
            hints: hintsForWord(
              q.word,
              answer: q.mode == QuizMode.meaning
                  ? _meaning(q.word)
                  : q.word.displayGerman,
              personalization: _wordPersonalization,
            ),
            onPrevious: _index > 0 ? _previous : null,
            onSkip: _skip,
          ),
        ],
        if (_answered) ...<Widget>[
          const SizedBox(height: 14),
          _buildFeedback(context),
        ],
      ],
    );
  }

  /// What the learner reads between answering and moving on.
  ///
  /// This is the moment the word is most likely to stick, right or wrong, so
  /// it shows the word doing its job in a sentence rather than only a verdict.
  /// The verdict carries an icon as well as a colour.
  Widget _buildFeedback(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool right = _correct == true;
    final Color tone = right
        ? answerCorrectColor(theme.brightness)
        : theme.colorScheme.error;
    final GermanWord word = _question.word;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                right ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: tone,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _feedbackText,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              // "What does this mean?" already has the word and its speaker
              // above the options. The other directions prompt in the
              // learner's language, so this is the first chance to hear it.
              if (_question.mode != QuizMode.meaning)
                IconButton(
                  tooltip: _t.hearWord,
                  onPressed: widget.controller.ttsEnabled
                      ? () => _tts.speakGerman(word.displayGerman)
                      : null,
                  icon: const Icon(Icons.volume_up_rounded),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SpeakableSentence(
            text: word.exampleGerman,
            enabled: widget.controller.ttsEnabled,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(word.exampleEnglish, style: theme.textTheme.bodySmall),
          if (_retrySpawned.contains(_index)) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Icon(
                  Icons.replay_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _t.studyRetryNote,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _promptFor(QuizMode mode) {
    switch (mode) {
      case QuizMode.meaning:
        return _t.meaningQuestion;
      case QuizMode.german:
        return _t.germanQuestion;
      case QuizMode.article:
        return _t.articleQuestion;
      case QuizMode.typing:
        return _question.word.article.isEmpty
            ? _t.typingQuestion
            : _t.typingArticleQuestion;
      case QuizMode.flashcard:
        return '';
    }
  }

  Widget _buildOption(String option) {
    final bool isCorrectOption = _isCorrectOption(_question, option);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnswerOptionButton(
        label: option,
        fontSize: 17,
        state: answerOptionState(
          answered: _answered,
          isCorrect: isCorrectOption,
          chosen: option == _chosen,
        ),
        onPressed: !_answered && !_busy ? () => _choose(option) : null,
      ),
    );
  }

  Widget _buildTypingAnswer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _typing,
          focusNode: _typingFocus,
          enabled: !_answered,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: _t.yourAnswer,
            hintText: _question.word.article.isEmpty
                ? _t.typeGermanWord
                : _t.articleAnswerExample,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onSubmitted: (_) => _checkTyping(),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: <String>['ä', 'ö', 'ü', 'ß'].map((char) {
            return ActionChip(
              label: Text(char),
              onPressed: !_answered
                  ? () {
                      final selection = _typing.selection;
                      final text = _typing.text;
                      final offset = selection.isValid
                          ? selection.start
                          : text.length;
                      _typing.value = TextEditingValue(
                        text: text.replaceRange(offset, offset, char),
                        selection: TextSelection.collapsed(offset: offset + 1),
                      );
                    }
                  : null,
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: !_answered && !_busy ? _checkTyping : null,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(_t.checkAnswer),
          ),
        ),
      ],
    );
  }

  void _checkTyping() {
    // An answer typed as `Maedchen` on a keyboard with no umlaut key is a
    // recall success, not a failure. Credit it, then show the real spelling.
    final GermanMatch match = classifyGermanAnswer(
      _typing.text,
      _question.word.displayGerman,
    );
    _submit(
      match != GermanMatch.wrong,
      givenAnswer: _typing.text.trim(),
      umlautVariant: match == GermanMatch.umlautVariant,
    );
  }

  Widget _buildSummary(BuildContext context) {
    final earned = widget.controller.xp - _startXp;
    final accuracy = _answeredInSession == 0
        ? 100
        : ((_correctInSession / _answeredInSession) * 100).round();
    // Every word missed at least once, in the order it was first missed. A
    // word that was then recalled on its second try still belongs here: it
    // is the one the learner should expect to see again soonest.
    final List<GermanWord> missed = <GermanWord>[];
    final Set<String> missedIds = <String>{};
    for (int i = 0; i < _questions.length; i++) {
      if (_gradedAnswers[i] == false && missedIds.add(_questions[i].word.id)) {
        missed.add(_questions[i].word);
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_t.sessionComplete),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: <Widget>[
                      const Text('🎉', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 12),
                      Text(
                        _t.wellDone,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(_t.gardenGrew),
                      const SizedBox(height: 26),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _summaryMetric(
                              _t.accuracyLabel,
                              '$accuracy%',
                            ),
                          ),
                          Expanded(
                            child: _summaryMetric(_t.xpEarned, '+$earned'),
                          ),
                          Expanded(
                            child: _summaryMetric(
                              _t.streakLabel,
                              '${widget.controller.streak}🔥',
                            ),
                          ),
                        ],
                      ),
                      if (missed.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 22),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            _t.studyRevisitTitle,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(height: 6),
                        for (final GermanWord word in missed)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    word.displayGerman,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: word.genderColor(
                                        Theme.of(context).brightness,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _meaning(word),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                      const SizedBox(height: 26),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          child: Text(_t.backHome),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _previous,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: Text(_t.reviewPreviousItem),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryMetric(String label, String value) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
