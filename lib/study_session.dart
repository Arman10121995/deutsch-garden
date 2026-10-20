import 'dart:math';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'german_text.dart';
import 'models.dart';
import 'hints.dart';
import 'practice_aids.dart';
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

  late final List<SessionQuestion> _questions;
  late final Map<String, String> _meanings;
  late final int _startXp;
  int _index = 0;
  bool? _correct;
  bool _answered = false;
  bool _umlautVariant = false;
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
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity(
      '${widget.level.label} · ${widget.kind.name} vocabulary',
    );
    _typing.dispose();
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

  SessionQuestion _makeTestQuestion(GermanWord word, {QuizMode? forcedMode}) {
    final modes = <QuizMode>[
      QuizMode.meaning,
      QuizMode.german,
      if (word.article.isNotEmpty) QuizMode.article,
      QuizMode.typing,
    ];
    final mode = forcedMode ?? modes[_random.nextInt(modes.length)];
    final options = <String>[];

    if (mode == QuizMode.meaning) {
      options.add(_meaning(word));
      final distractors =
          widget.controller
              .wordsForLevel(widget.level)
              .where((w) => w.id != word.id && _meaning(w) != _meaning(word))
              .map(_meaning)
              .toSet()
              .toList()
            ..shuffle(_random);
      options.addAll(distractors.take(3));
      options.shuffle(_random);
    } else if (mode == QuizMode.german) {
      options.add(word.displayGerman);
      final distractors =
          widget.controller
              .wordsForLevel(widget.level)
              .where((w) => w.id != word.id)
              .map((w) => w.displayGerman)
              .toList()
            ..shuffle(_random);
      options.addAll(distractors.take(3));
      options.shuffle(_random);
    } else if (mode == QuizMode.article) {
      options.addAll(const <String>['der', 'die', 'das']);
      options.shuffle(_random);
    }

    return SessionQuestion(word: word, mode: mode, options: options);
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
      });
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
      _typing.clear();
    });
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
      if (!mounted) return;
      setState(() {
        _index = target;
        _correct = null;
        _answered = false;
        _umlautVariant = false;
        _typing.clear();
      });
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
    return Scaffold(
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
                child: _question.mode == QuizMode.flashcard
                    ? _buildFlashcard(context)
                    : _buildQuiz(context),
              ),
            ),
          ],
        ),
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
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _busy ? null : _continueFromFlashcard,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(_t.testMe),
          ),
        ),
        if (_index > 0)
          TextButton.icon(
            onPressed: _busy ? null : _previous,
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(_t.previousAction),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (_correct == true ? Colors.green : Colors.red).withValues(
                alpha: 0.14,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _correct == true ? Colors.green : Colors.red,
              ),
            ),
            child: Text(
              _feedbackText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _busy ? null : _nextAfterAnswer,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(_t.continueAction),
            ),
          ),
        ],
      ],
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
    final q = _question;
    bool isCorrectOption;
    if (q.mode == QuizMode.meaning) {
      isCorrectOption = option == _meaning(q.word);
    } else if (q.mode == QuizMode.german) {
      isCorrectOption = option == q.word.displayGerman;
    } else {
      isCorrectOption = option == q.word.article;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: !_answered && !_busy
            ? () => _submit(isCorrectOption, givenAnswer: option)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(option, style: const TextStyle(fontSize: 17)),
        ),
      ),
    );
  }

  Widget _buildTypingAnswer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _typing,
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
