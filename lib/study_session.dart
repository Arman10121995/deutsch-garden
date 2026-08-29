import 'dart:math';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'german_text.dart';
import 'models.dart';
import 'sentence_audio.dart';
import 'tts_service.dart';
import 'vocab_icon.dart';
import 'vocabulary_metadata.dart';
import 'compound_breakdown.dart';

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
  late final int _startXp;
  int _index = 0;
  bool? _correct;
  String? _feedback;
  int _correctInSession = 0;
  int _answeredInSession = 0;

  @override
  void initState() {
    super.initState();
    _startXp = widget.controller.xp;
    _questions = _buildQuestions();
  }

  @override
  void dispose() {
    _typing.dispose();
    _tts.stop();
    super.dispose();
  }

  List<SessionQuestion> _buildQuestions() {
    final levelWords = widget.controller.wordsForLevel(widget.level);
    List<GermanWord> base;
    switch (widget.kind) {
      case SessionKind.learn:
        base = widget.controller.newWordsForLevel(widget.level).take(10).toList();
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
        base = widget.controller.reviewWordsForLevel(widget.level).take(20).toList();
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
  }) {
    final modes = <QuizMode>[
      QuizMode.meaning,
      QuizMode.german,
      if (word.article.isNotEmpty) QuizMode.article,
      QuizMode.typing,
    ];
    final mode = forcedMode ?? modes[_random.nextInt(modes.length)];
    final options = <String>[];

    if (mode == QuizMode.meaning) {
      options.add(word.english);
      final distractors = widget.controller.wordsForLevel(widget.level)
          .where((w) => w.id != word.id && w.english != word.english)
          .map((w) => w.english)
          .toList()
        ..shuffle(_random);
      options.addAll(distractors.take(3));
      options.shuffle(_random);
    } else if (mode == QuizMode.german) {
      options.add(word.displayGerman);
      final distractors = widget.controller.wordsForLevel(widget.level)
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

  Future<void> _submit(bool correct, {String? spellingNote}) async {
    if (_feedback != null) return;
    final word = _question.word;
    await widget.controller.answer(word, correct: correct);
    if (!correct) {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'vocab-${word.id}',
          prompt: _promptFor(_question.mode),
          correctAnswer: word.displayGerman,
          givenAnswer: word.english,
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
      _feedback = correct
          ? (spellingNote ??
              'Richtig! +XP ${widget.controller.progressFor(word.id).plantIcon}')
          : 'Nicht ganz. Richtig: ${word.displayGerman} — ${word.english}';
    });
  }

  Future<void> _continueFromFlashcard() async {
    await widget.controller.markSeen(_question.word);
    if (!mounted) return;
    _advance();
  }

  void _advance() {
    if (_index + 1 >= _questions.length) {
      setState(() => _index = _questions.length);
      return;
    }
    setState(() {
      _index += 1;
      _correct = null;
      _feedback = null;
      _typing.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Nothing is due right now. Practice a mixed session or learn new words.',
              textAlign: TextAlign.center,
            ),
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
              child: Text('⚡ ${widget.controller.xp} XP'),
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
        return 'Learn new words';
      case SessionKind.review:
        return 'Smart review';
      case SessionKind.practice:
        return 'Practice';
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
          'NEW WORD',
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
                  Text('Plural: ${word.plural}'),
                const SizedBox(height: 14),
                IconButton.filledTonal(
                  tooltip: 'Hear German pronunciation',
                  onPressed: widget.controller.ttsEnabled
                      ? () => _tts.speakGerman(word.displayGerman)
                      : null,
                  icon: const Icon(Icons.volume_up_rounded),
                ),
                const Divider(height: 40),
                Text(
                  word.english,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 20),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
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
                        Text(
                          word.exampleEnglish,
                          textAlign: TextAlign.center,
                        ),
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
                    word.genderEndingComment,
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
                      'Mnemonic: ${p.mnemonic}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => _editMnemonic(word),
                    icon: const Icon(Icons.psychology_outlined, size: 18),
                    label: const Text('Add personal mnemonic'),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _continueFromFlashcard,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Got it — test me'),
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
        title: Text('Mnemonic for ${word.displayGerman}'),
        content: TextField(
          controller: input,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'A picture, a rhyme, a story — whatever sticks.',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text),
            child: const Text('Save'),
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
                    q.word.english,
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
        if (_feedback != null) ...<Widget>[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (_correct == true ? Colors.green : Colors.red)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _correct == true ? Colors.green : Colors.red,
              ),
            ),
            child: Text(
              _feedback!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _advance,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Continue'),
            ),
          ),
        ],
      ],
    );
  }

  String _promptFor(QuizMode mode) {
    switch (mode) {
      case QuizMode.meaning:
        return 'What does this mean?';
      case QuizMode.german:
        return 'Choose the German translation';
      case QuizMode.article:
        return 'Choose the correct article';
      case QuizMode.typing:
        return _question.word.article.isEmpty
            ? 'Type the German translation'
            : 'Type the German word with its article';
      case QuizMode.flashcard:
        return '';
    }
  }

  Widget _buildOption(String option) {
    final q = _question;
    bool isCorrectOption;
    if (q.mode == QuizMode.meaning) {
      isCorrectOption = option == q.word.english;
    } else if (q.mode == QuizMode.german) {
      isCorrectOption = option == q.word.displayGerman;
    } else {
      isCorrectOption = option == q.word.article;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: _feedback == null ? () => _submit(isCorrectOption) : null,
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
          enabled: _feedback == null,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'Your answer',
            hintText: _question.word.article.isEmpty
                ? 'Type the German word'
                : 'e.g. der Schlüssel',
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
              onPressed: _feedback == null
                  ? () {
                      final selection = _typing.selection;
                      final text = _typing.text;
                      final offset = selection.isValid ? selection.start : text.length;
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
          onPressed: _feedback == null ? _checkTyping : null,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Check answer'),
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
      spellingNote: match == GermanMatch.umlautVariant
          ? 'Richtig — achte aber auf die Umlaute: '
              '${_question.word.displayGerman}'
          : null,
    );
  }

  Widget _buildSummary(BuildContext context) {
    final earned = widget.controller.xp - _startXp;
    final accuracy = _answeredInSession == 0
        ? 100
        : ((_correctInSession / _answeredInSession) * 100).round();

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Session complete')),
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
                        'Stark gemacht!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Your German garden grew today.'),
                      const SizedBox(height: 26),
                      Row(
                        children: <Widget>[
                          Expanded(child: _summaryMetric('Accuracy', '$accuracy%')),
                          Expanded(child: _summaryMetric('XP earned', '+$earned')),
                          Expanded(child: _summaryMetric('Streak', '${widget.controller.streak}🔥')),
                        ],
                      ),
                      const SizedBox(height: 26),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          child: Text('Back to home'),
                        ),
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
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
