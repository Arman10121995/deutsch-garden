import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'l10n/app_localizations.dart';
import 'pending_action.dart';
import 'feedback_text.dart';
import 'conversation_text.dart';
import 'game_text.dart';
import 'conversation.dart';
import 'conversation_engine.dart';
import 'package:path_provider/path_provider.dart';
import 'acoustic.dart';
import 'acoustic_scorer.dart';
import 'voice_recorder.dart';
import 'models.dart';
import 'pronunciation.dart';
import 'platform_support.dart';
import 'sentence_bank.dart';
import 'speech_service.dart';
import 'tts_service.dart';

/// Entry point for everything spoken: guided role-plays, open questions and
/// the pronunciation lab.
class SpeakHubScreen extends StatefulWidget {
  const SpeakHubScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<SpeakHubScreen> createState() => _SpeakHubScreenState();
}

class _SpeakHubScreenState extends State<SpeakHubScreen> {
  CefrLevel? _level;

  CefrLevel get _selected => _level ?? widget.controller.highestUnlockedLevel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final CefrLevel level = _selected;
          final List<ConversationScenario> scenarios = conversationsFor(level);
          final List<FreeTalkPrompt> prompts = freeTalkFor(level);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            children: <Widget>[
              Text(
                AppText.of(context).conversationTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(AppText.of(context).conversationIntro),
              const SizedBox(height: 14),
              _LevelChips(
                selected: level,
                controller: widget.controller,
                onChanged: (value) => setState(() => _level = value),
              ),
              const SizedBox(height: 18),
              Card(
                child: ListTile(
                  leading: const Text('🎯', style: TextStyle(fontSize: 26)),
                  title: Text(
                    AppText.of(context).pronunciationLab,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(AppText.of(context).pronunciationIntro),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => PronunciationLabScreen(
                        controller: widget.controller,
                        level: level,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                AppText.of(context).rolePlays,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              if (scenarios.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(AppText.of(context).rolePlaysEmpty),
                  ),
                ),
              ...scenarios.map((scenario) => _scenarioCard(context, scenario)),
              const SizedBox(height: 22),
              Text(
                AppText.of(context).freeTalkQuestions,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(AppText.of(context).freeTalkIntro),
              const SizedBox(height: 8),
              ...prompts.map((prompt) => _promptCard(context, prompt)),
            ],
          );
        },
      ),
    );
  }

  Widget _scenarioCard(BuildContext context, ConversationScenario scenario) {
    final ActivityProgress progress =
        widget.controller.activities[scenario.id] ?? ActivityProgress();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ConversationScreen(
                controller: widget.controller,
                scenario: scenario,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Text(scenario.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        scenario.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        scenario.goal,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: <Widget>[
                          Text(
                            AppText.of(
                              context,
                            ).conversationTurnCount(scenario.steps.length),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          if (progress.attempts > 0)
                            Text(
                              AppText.of(
                                context,
                              ).bestPercent(progress.bestScore),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (progress.completed)
                  const Icon(Icons.check_circle, size: 20)
                else
                  const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _promptCard(BuildContext context, FreeTalkPrompt prompt) {
    final ActivityProgress progress =
        widget.controller.activities[prompt.id] ?? ActivityProgress();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: const Text('💭', style: TextStyle(fontSize: 24)),
          title: Text(
            prompt.question,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            AppText.of(context).freeTalkPromptSummary(
                  prompt.targetSeconds,
                  prompt.targetWords,
                ) +
                (progress.attempts > 0
                    ? AppText.of(context).freeTalkBest(progress.bestScore)
                    : ''),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  FreeTalkScreen(controller: widget.controller, prompt: prompt),
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelChips extends StatelessWidget {
  const _LevelChips({
    required this.selected,
    required this.controller,
    required this.onChanged,
  });

  final CefrLevel selected;
  final AppController controller;
  final ValueChanged<CefrLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: CefrLevel.values.map((level) {
          final bool unlocked = controller.isLevelUnlocked(level);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(level.label),
              selected: level == selected,
              onSelected: unlocked ? (_) => onChanged(level) : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Role-play
// ---------------------------------------------------------------------------

enum _Speaker { tutor, learner, coach }

class _Message {
  const _Message(
    this.speaker,
    this.german, {
    this.english = '',
    this.tone,
    this.evaluation,
    this.modelAnswer = false,
  });

  final _Speaker speaker;
  final String german;
  final String english;

  /// Positive/negative tint for coach messages.
  final bool? tone;
  final TurnEvaluation? evaluation;
  final bool modelAnswer;
}

class _ConversationSnapshot {
  const _ConversationSnapshot({
    required this.step,
    required this.messageCount,
    required this.evaluationCount,
    required this.turnsTaken,
  });

  final int step;
  final int messageCount;
  final int evaluationCount;
  final int turnsTaken;
}

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.controller,
    required this.scenario,
  });

  final AppController controller;
  final ConversationScenario scenario;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with PendingAction<ConversationScreen> {
  final TtsService _tts = TtsService();
  final SpeechService _speech = SpeechService();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<_Message> _messages = <_Message>[];
  final List<TurnEvaluation> _evaluations = <TurnEvaluation>[];
  final List<_ConversationSnapshot> _snapshots = <_ConversationSnapshot>[];

  int _step = 0;
  int _attempts = 0;
  int _turnsTaken = 0;
  int _hintStage = 0;
  bool _listening = false;
  bool _finished = false;
  bool _showTranslation = false;
  String _partial = '';
  Timer? _autoSend;
  bool _suppressSpeechDone = false;

  DialogueStep get _current => widget.scenario.steps[_step];

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      'Role-play · ${widget.scenario.title}',
    );
    _showTranslation = !widget.controller.immersionMode;
    _rememberCurrentStep();
    _pushTutorLine();
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Role-play · ${widget.scenario.title}');
    _input.dispose();
    _scroll.dispose();
    _autoSend?.cancel();
    _tts.stop();
    _speech.cancel();
    super.dispose();
  }

  void _pushTutorLine() {
    _messages.add(
      _Message(
        _Speaker.tutor,
        _current.tutorGerman,
        english: _current.tutorEnglish,
      ),
    );
    _speakTutor();
    _scrollToEnd();
  }

  void _rememberCurrentStep() {
    _snapshots.add(
      _ConversationSnapshot(
        step: _step,
        messageCount: _messages.length,
        evaluationCount: _evaluations.length,
        turnsTaken: _turnsTaken,
      ),
    );
  }

  bool get _canGoPrevious => _finished || _attempts > 0 || _step > 0;

  Future<void> _previousTurn() async {
    if (actionPending) return;
    await runAction(_restorePreviousTurn);
  }

  Future<void> _restorePreviousTurn() async {
    if (!_canGoPrevious || _snapshots.isEmpty) return;
    final bool restoreCurrent = _finished || _attempts > 0;
    if (!restoreCurrent && _snapshots.length > 1) {
      _snapshots.removeLast();
    }
    final _ConversationSnapshot snapshot = _snapshots.last;
    await _speech.cancel();
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _step = snapshot.step;
      _messages.removeRange(snapshot.messageCount, _messages.length);
      _evaluations.removeRange(snapshot.evaluationCount, _evaluations.length);
      _turnsTaken = snapshot.turnsTaken;
      _attempts = 0;
      _hintStage = 0;
      _finished = false;
      _listening = false;
      _partial = '';
      _input.clear();
    });
    _pushTutorLine();
  }

  void _speakTutor() {
    if (widget.controller.ttsEnabled) {
      _tts.speakGerman(_current.tutorGerman, voice: GermanVoiceRole.speakerB);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _toggleMic() async {
    if (actionPending) return;
    if (_listening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _listening = false);
      return;
    }
    final bool started = await _speech.listen(
      onTranscript: (transcript, isFinal) {
        if (!mounted) return;
        setState(() {
          _partial = transcript;
          _input.text = transcript;
        });
      },
      onDone: _rolePlaySpeechDone,
    );
    if (!mounted) return;
    if (!started) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_speech.unavailableReason)));
      return;
    }
    setState(() {
      _listening = true;
      _partial = '';
    });
  }

  void _rolePlaySpeechDone() {
    if (!mounted) return;
    setState(() => _listening = false);
    if (_suppressSpeechDone || _finished || _input.text.trim().isEmpty) return;
    _autoSend?.cancel();
    _autoSend = Timer(const Duration(milliseconds: 300), () {
      if (mounted && !_finished && _input.text.trim().isNotEmpty) {
        _send();
      }
    });
  }

  Future<void> _send() async {
    await runAction(_submitReply);
  }

  Future<void> _submitReply() async {
    _autoSend?.cancel();
    final String reply = _input.text.trim();
    if (reply.isEmpty || _finished) return;
    if (_listening) {
      _suppressSpeechDone = true;
      try {
        await _speech.stop();
      } finally {
        _suppressSpeechDone = false;
      }
    }

    final TurnEvaluation evaluation = ConversationEngine.evaluate(
      _current,
      reply,
    );
    _attempts += 1;
    _turnsTaken += 1;

    if (!mounted) return;
    setState(() {
      _listening = false;
      _messages.add(_Message(_Speaker.learner, reply));
      _messages.add(
        _Message(
          _Speaker.coach,
          evaluation.headline,
          english: evaluation.detail,
          tone: evaluation.accepted,
          evaluation: evaluation,
        ),
      );
      _input.clear();
      _partial = '';
    });
    _scrollToEnd();

    final bool moveOn =
        evaluation.accepted ||
        _attempts >= ConversationEngine.maxAttemptsPerStep;
    if (!moveOn) return;

    _evaluations.add(evaluation);
    if (_current.coachTip.isNotEmpty) {
      _messages.add(_Message(_Speaker.coach, '💡 ${_current.coachTip}'));
    }
    if (!evaluation.accepted) {
      _messages.add(
        _Message(
          _Speaker.coach,
          _current.modelAnswer,
          english: _current.modelAnswerEnglish,
          modelAnswer: true,
        ),
      );
    }

    _attempts = 0;
    if (_step + 1 >= widget.scenario.steps.length) {
      await _finish();
      return;
    }
    if (!mounted) return;
    setState(() {
      _step += 1;
      _hintStage = 0;
    });
    _rememberCurrentStep();
    _pushTutorLine();
  }

  Future<void> _finish() async {
    final int score = ConversationEngine.sessionScore(_evaluations);
    await widget.controller.recordConversation(
      widget.scenario.id,
      score: score,
      turns: _turnsTaken,
    );
    if (!mounted) return;
    setState(() => _finished = true);
    _scrollToEnd();
  }

  void _useQuickReply(String text) {
    if (actionPending) return;
    setState(() => _input.text = text);
  }

  void _showHint() {
    if (actionPending) return;
    final DialogueStep step = _current;
    final int stage = _hintStage.clamp(0, 2);
    setState(() => _hintStage = (_hintStage + 1).clamp(0, 2));
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppText.of(context).conversationYourTask,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(step.task),
            const SizedBox(height: 10),
            Text(
              _attempts > 0
                  ? AppText.of(context).conversationRetryHint
                  : AppText.of(context).conversationFirstHint,
            ),
            if (stage >= 1) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                AppText.of(context).conversationUsefulLanguage,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              ...widget.scenario.usefulPhrases.map(
                (phrase) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $phrase'),
                ),
              ),
              if (step.coachTip.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(AppText.of(context).conversationRule(step.coachTip)),
              ],
            ],
            if (stage >= 2) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                AppText.of(context).modelAnswer,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                step.modelAnswer,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(step.modelAnswerEnglish),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: () => _tts.speakGerman(
                      step.modelAnswer,
                      voice: GermanVoiceRole.speakerA,
                    ),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: Text(AppText.of(context).audioStageListen),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _useQuickReply(step.modelAnswer);
                    },
                    child: Text(AppText.of(context).conversationUseModel),
                  ),
                ],
              ),
            ] else ...<Widget>[
              const SizedBox(height: 14),
              Text(
                stage == 0
                    ? AppText.of(context).conversationHintAgain
                    : AppText.of(context).conversationHintModel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress =
        (_step + (_finished ? 1 : 0)) / widget.scenario.steps.length;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.scenario.emoji} ${widget.scenario.title}'),
        actions: <Widget>[
          IconButton(
            tooltip: _showTranslation
                ? AppText.of(context).hideEnglish
                : AppText.of(context).showEnglish,
            onPressed: () =>
                setState(() => _showTranslation = !_showTranslation),
            icon: Icon(
              _showTranslation
                  ? Icons.translate_rounded
                  : Icons.translate_outlined,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              children: <Widget>[
                _roleCard(context),
                const SizedBox(height: 12),
                ..._messages.map(_bubble),
                if (_finished) _summaryCard(context),
              ],
            ),
          ),
          if (!_finished) _composer(context),
        ],
      ),
    );
  }

  Widget _roleCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.scenario.setting,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Text(
              AppText.of(
                context,
              ).conversationTutorRole(widget.scenario.tutorRole),
            ),
            Text(
              AppText.of(
                context,
              ).conversationLearnerRole(widget.scenario.learnerRole),
            ),
            const SizedBox(height: 8),
            Text(
              '🎯 ${widget.scenario.goal}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(_Message message) {
    final t = AppText.of(context);
    final evaluation = message.evaluation;
    final headline = evaluation != null
        ? turnHeadline(t, evaluation)
        : message.modelAnswer
        ? t.conversationModelMessage(message.german)
        : message.german;
    final detail = evaluation != null
        ? turnDetail(t, evaluation)
        : message.english;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    late final Color background;
    late final Alignment alignment;
    switch (message.speaker) {
      case _Speaker.tutor:
        background = scheme.surfaceContainerHighest;
        alignment = Alignment.centerLeft;
        break;
      case _Speaker.learner:
        background = scheme.primaryContainer;
        alignment = Alignment.centerRight;
        break;
      case _Speaker.coach:
        background = message.tone == null
            ? scheme.surfaceContainerHigh
            : (message.tone!
                  ? scheme.tertiaryContainer
                  : scheme.errorContainer);
        alignment = Alignment.center;
        break;
    }
    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              headline,
              style: TextStyle(
                fontWeight: message.speaker == _Speaker.coach
                    ? FontWeight.w700
                    : FontWeight.w600,
              ),
            ),
            if (detail.isNotEmpty &&
                (_showTranslation ||
                    message.speaker == _Speaker.coach)) ...<Widget>[
              const SizedBox(height: 4),
              Text(detail, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (message.speaker == _Speaker.tutor)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: AppText.of(context).conversationHearLine,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _tts.speakGerman(
                    message.german,
                    voice: GermanVoiceRole.speakerB,
                  ),
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    final int score = ConversationEngine.sessionScore(_evaluations);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Text(
              AppText.of(context).conversationComplete,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              '$score%',
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(AppText.of(context).conversationTurnsDone(_turnsTaken)),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _previousTurn,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(AppText.of(context).conversationReviewLast),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppText.of(context).conversationBack),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _composer(BuildContext context) {
    final List<String> quick = _current.quickReplies;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_listening)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  _partial.isEmpty
                      ? AppText.of(context).listeningStatus
                      : _partial,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (quick.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: quick
                      .map(
                        (reply) => Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 6),
                          child: ActionChip(
                            label: Text(reply),
                            onPressed: () => _useQuickReply(reply),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            Row(
              children: <Widget>[
                IconButton(
                  tooltip: AppText.of(context).conversationPrevious,
                  onPressed: _canGoPrevious && !actionPending
                      ? _previousTurn
                      : null,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                IconButton(
                  tooltip: AppText.of(context).conversationHint,
                  onPressed: actionPending ? null : _showHint,
                  icon: const Icon(Icons.lightbulb_outline_rounded),
                ),
                IconButton.filledTonal(
                  tooltip: _listening
                      ? AppText.of(context).audioStop
                      : AppText.of(context).speakAction,
                  onPressed: actionPending ? null : _toggleMic,
                  icon: Icon(
                    _listening ? Icons.stop_rounded : Icons.mic_rounded,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _input,
                    enabled: !actionPending,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: AppText.of(context).conversationAnswerHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  tooltip: actionPending
                      ? AppText.of(context).savingAction
                      : AppText.of(context).conversationSend,
                  onPressed: actionPending ? null : _send,
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Open-question speaking
// ---------------------------------------------------------------------------

class FreeTalkScreen extends StatefulWidget {
  const FreeTalkScreen({
    super.key,
    required this.controller,
    required this.prompt,
  });

  final AppController controller;
  final FreeTalkPrompt prompt;

  @override
  State<FreeTalkScreen> createState() => _FreeTalkScreenState();
}

class _FreeTalkScreenState extends State<FreeTalkScreen> {
  final TtsService _tts = TtsService();
  final SpeechService _speech = SpeechService();
  final TextEditingController _answer = TextEditingController();

  bool _listening = false;
  bool _evaluating = false;
  bool _showModel = false;
  FreeTalkEvaluation? _evaluation;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      'Free speaking · ${widget.prompt.level.label}',
    );
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity(
      'Free speaking · ${widget.prompt.level.label}',
    );
    _answer.dispose();
    _tts.stop();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    if (_evaluating) return;
    if (_listening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _listening = false);
      return;
    }
    final String existing = _answer.text.trim();
    final bool started = await _speech.listen(
      listenFor: const Duration(minutes: 3),
      pauseFor: const Duration(seconds: 6),
      onTranscript: (transcript, isFinal) {
        if (!mounted) return;
        setState(() {
          _answer.text = existing.isEmpty
              ? transcript
              : '$existing $transcript';
          _evaluation = null;
        });
      },
      onDone: () {
        if (!mounted) return;
        setState(() => _listening = false);
        if (!_evaluating && _answer.text.trim().isNotEmpty) {
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

  Future<void> _evaluate() async {
    if (_evaluating || _answer.text.trim().isEmpty) return;
    setState(() => _evaluating = true);
    try {
      if (_listening) await _speech.stop();
      final FreeTalkEvaluation result = ConversationEngine.evaluateFreeTalk(
        widget.prompt,
        _answer.text,
      );
      await widget.controller.recordActivity(
        widget.prompt.id,
        score: result.score,
        passingScore: 60,
      );
      if (mounted) setState(() => _evaluation = result);
    } finally {
      if (mounted) {
        setState(() {
          _listening = false;
          _evaluating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FreeTalkPrompt prompt = widget.prompt;
    final FreeTalkEvaluation? result = _evaluation;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.of(context).freeTalkTitle(prompt.level.label)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          prompt.question,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: AppText.of(context).conversationHearLine,
                        onPressed: () => _tts.speakGerman(
                          prompt.question,
                          voice: GermanVoiceRole.speakerB,
                        ),
                        icon: const Icon(Icons.volume_up_rounded),
                      ),
                    ],
                  ),
                  if (!widget.controller.immersionMode) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      prompt.questionEnglish,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    AppText.of(context).freeTalkPoints,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  ...prompt.expectedPoints.map((point) => Text('• $point')),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: prompt.usefulConnectors
                        .map(
                          (connector) => Chip(
                            label: Text(connector),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppText.of(
                      context,
                    ).freeTalkTarget(prompt.targetSeconds, prompt.targetWords),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _answer,
            enabled: !_evaluating,
            minLines: 5,
            maxLines: 14,
            onChanged: (_) => setState(() => _evaluation = null),
            decoration: InputDecoration(
              hintText: AppText.of(context).freeTalkAnswerHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                AppText.of(
                  context,
                ).wordCountLabel(PronunciationScorer.wordCount(_answer.text)),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _evaluating ? null : _toggleMic,
                icon: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded),
                label: Text(
                  _listening
                      ? AppText.of(context).audioStop
                      : AppText.of(context).speakAction,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _answer.text.trim().isEmpty || _evaluating
                    ? null
                    : _evaluate,
                child: Text(
                  _evaluating
                      ? AppText.of(context).checkingStatus
                      : AppText.of(context).checkAnswer,
                ),
              ),
            ],
          ),
          if (result != null) ...<Widget>[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${result.score}%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      AppText.of(context).freeTalkResult(
                        prompt.usefulConnectors.length,
                        result.connectorsUsed.length,
                        result.wordCount,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...feedbackTexts(
                      AppText.of(context),
                      result.feedback,
                      result.tips,
                    ).map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $tip'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      AppText.of(context).modelAnswer,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    trailing: Icon(
                      _showModel
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                    ),
                    onTap: () => setState(() => _showModel = !_showModel),
                  ),
                  if (_showModel)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(prompt.modelAnswer),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () => _tts.speakGerman(
                              prompt.modelAnswer,
                              voice: GermanVoiceRole.speakerA,
                            ),
                            icon: const Icon(Icons.volume_up_rounded),
                            label: Text(AppText.of(context).listenModelAnswer),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pronunciation lab
// ---------------------------------------------------------------------------

class PronunciationLabScreen extends StatefulWidget {
  const PronunciationLabScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  State<PronunciationLabScreen> createState() => _PronunciationLabScreenState();
}

class _PronunciationLabScreenState extends State<PronunciationLabScreen> {
  final TtsService _tts = TtsService();
  final SpeechService _speech = SpeechService();

  final VoiceRecorder _recorder = VoiceRecorder();
  static const AcousticPronunciationScorer _acoustic =
      AcousticPronunciationScorer();

  late List<PracticeSentence> _sentences;
  int _index = 0;
  bool _listening = false;
  String _heard = '';
  PronunciationResult? _result;

  /// Set when the recording could be compared with the bundled voice.
  ///
  /// This is the only pronunciation signal on Linux, where `speech_to_text`
  /// has no implementation and there has never been a transcript to score.
  AcousticScore? _acousticScore;
  bool _scoring = false;

  /// True when [_heard] came from the downloaded offline model rather than
  /// from the system recogniser. The two are labelled differently because
  /// their failure modes differ: this one has never been measured on accented
  /// learner speech, and saying so is cheaper than a learner concluding they
  /// mispronounced a word they said correctly.
  bool _transcriptFromModel = false;
  bool _finishingAcoustic = false;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity(
      '${widget.level.label} · pronunciation lab',
    );
    _sentences = sentencesFor(widget.level);
    if (_sentences.length > 12) _sentences = _sentences.sublist(0, 12);
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity(
      '${widget.level.label} · pronunciation lab',
    );
    _tts.stop();
    _speech.cancel();
    _recorder.dispose();
    super.dispose();
  }

  PracticeSentence get _sentence => _sentences[_index];

  /// Record, then score the audio itself.
  ///
  /// Used where there is no recogniser to produce a transcript. Running this
  /// at the same time as `speech_to_text` would put two capture sessions on
  /// one microphone, which platforms disagree about, so the two paths stay
  /// separate rather than being combined and hoped for.
  Future<void> _recordAcoustic() async {
    if (_listening) {
      await _finishAcoustic();
      return;
    }

    if (_recorder.availability == RecorderAvailability.unknown) {
      await _recorder.initialise();
      if (!mounted) return;
      setState(() {});
    }
    final Directory dir = await getApplicationSupportDirectory();
    final bool started = await _recorder.start(
      '${dir.path}/pronunciation',
      trailingSilence: const Duration(milliseconds: 1400),
      noSpeechTimeout: const Duration(seconds: 8),
      maximumDuration: const Duration(seconds: 20),
      onSpeechEnd: (_) => unawaited(_finishAcoustic()),
    );
    if (!mounted) return;
    if (!started) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_recorder.unavailableReason)));
      return;
    }
    setState(() {
      _heard = '';
      _result = null;
      _acousticScore = null;
      _transcriptFromModel = false;
      _listening = true;
    });
  }

  Future<void> _finishAcoustic() async {
    if (_finishingAcoustic || !_listening) return;
    _finishingAcoustic = true;
    setState(() {
      _listening = false;
      _scoring = true;
    });
    final String? clip = await _recorder.stop();
    AcousticScore? score;
    String transcript = '';
    if (clip != null) {
      try {
        score = await _acoustic.score(
          targetGerman: _sentence.german,
          recordingPath: clip,
        );
        // Only if the learner fetched the model. Everything below keeps
        // working without it, which is still the common case.
        transcript = await widget.controller.transcribeRecording(clip);
      } finally {
        // A spoken attempt is input to one score, not learner content to
        // retain. Cleanup is encapsulated so this screen remains web-safe.
        await _recorder.deleteRecording(clip);
      }
    }
    if (!mounted) {
      _finishingAcoustic = false;
      return;
    }
    setState(() {
      _scoring = false;
      _acousticScore = score;
      _transcriptFromModel = transcript.isNotEmpty;
      if (transcript.isNotEmpty) {
        _heard = transcript;
        // Automatic word agreement is feedback, never a learner grade.
        _result = PronunciationScorer.compare(_sentence.german, _heard);
      }
    });
    _finishingAcoustic = false;
    if ((score == null || score.isEmpty) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppText.of(context).pronunciationRecordingEmpty),
        ),
      );
    }
  }

  Future<void> _record() async {
    if (_listening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _listening = false);
      return;
    }
    setState(() {
      _heard = '';
      _result = null;
    });
    final bool started = await _speech.listen(
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 3),
      onTranscript: (transcript, isFinal) {
        if (!mounted) return;
        setState(() {
          _heard = transcript;
        });
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          _listening = false;
          if (_heard.trim().isNotEmpty) _score();
        });
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

  void _score() {
    final PronunciationResult result = PronunciationScorer.compare(
      _sentence.german,
      _heard,
    );
    _result = result;
  }

  void _previous() {
    if (_index == 0 || _listening || _scoring) return;
    unawaited(_tts.stop());
    setState(() {
      _index -= 1;
      _heard = '';
      _result = null;
      _acousticScore = null;
      _transcriptFromModel = false;
    });
  }

  void _next() {
    if (_index + 1 >= _sentences.length) {
      // Neither synthetic acoustic similarity nor recognised word agreement
      // establishes pronunciation quality. Keep study time, but do not write
      // a pass/fail, retention event, XP grade or review schedule from either.
      Navigator.pop(context);
      return;
    }
    setState(() {
      _index += 1;
      _heard = '';
      _result = null;
      _acousticScore = null;
      _transcriptFromModel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sentences.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppText.of(context).pronunciationLab)),
        body: Center(child: Text(AppText.of(context).gameSentencesEmpty)),
      );
    }
    final PronunciationResult? result = _result;
    final AcousticScore? acoustic = _acousticScore;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.of(context).pronunciationTitle(widget.level.label)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / _sentences.length,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: <Widget>[
          Text(AppText.of(context).pronunciationUngraded),
          const SizedBox(height: 12),
          Text(
            AppText.of(context).sentenceOfTotal(_index + 1, _sentences.length),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Text(
                    _sentence.german,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (!widget.controller.immersionMode) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(_sentence.english, textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 8,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: () => _tts.speakGerman(_sentence.german),
                        icon: const Icon(Icons.volume_up_rounded),
                        label: Text(AppText.of(context).pronunciationModel),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        // Where there is no recogniser, the microphone still
                        // works: record and score the sound instead of the
                        // words. That is the whole of speaking practice on
                        // Linux, which until now was typed-only.
                        //
                        // The downloaded model wins over the system one when
                        // it is there. `speech_to_text` reaches whatever the
                        // platform provides, which on Android may go to a
                        // server; this app's promise is that it does not.
                        onPressed: _scoring
                            ? null
                            : (widget.controller.asrUsable ||
                                      !PlatformSupport.hasSpeechRecognition
                                  ? _recordAcoustic
                                  : _record),
                        icon: _scoring
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _listening
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                              ),
                        label: Text(
                          _scoring
                              ? AppText.of(context).scoringStatus
                              : _listening
                              ? AppText.of(context).audioStop
                              : AppText.of(context).pronunciationRepeat,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_listening) ...<Widget>[
            const SizedBox(height: 14),
            const LinearProgressIndicator(),
            const SizedBox(height: 6),
            Text(
              _heard.isEmpty ? AppText.of(context).listeningStatus : _heard,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              AppText.of(context).pronunciationStops,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
          if (acoustic != null && !acoustic.isEmpty) ...<Widget>[
            const SizedBox(height: 18),
            AcousticPracticeFeedback(acoustic: acoustic),
          ],
          if (result != null) ...<Widget>[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppText.of(
                        context,
                      ).pronunciationWordAgreement(result.score),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(recognisedWordsVerdict(AppText.of(context), result)),
                    if (_transcriptFromModel) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        AppText.of(context).pronunciationTranscriptNote,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: result.words.map((word) {
                        final ColorScheme scheme = Theme.of(
                          context,
                        ).colorScheme;
                        final Color background = word.isMatch
                            ? scheme.tertiaryContainer
                            : word.isClose
                            ? scheme.secondaryContainer
                            : scheme.errorContainer;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(word.expected),
                        );
                      }).toList(),
                    ),
                    if (result.problemWords.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        AppText.of(context).pronunciationPractiseWords(
                          result.problemWords.map((w) => w.expected).join(', '),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (result.transcript.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 10),
                      Text(
                        AppText.of(
                          context,
                        ).pronunciationHeard(result.transcript),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text(
                      AppText.of(context).pronunciationWordNote,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          if (_sentence.focus.isNotEmpty)
            Text(
              AppText.of(context).pronunciationFocus(_sentence.focus),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: _index > 0 && !_listening && !_scoring
                    ? _previous
                    : null,
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(AppText.of(context).previousAction),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _listening || _scoring ? null : _next,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _index + 1 >= _sentences.length
                          ? AppText.of(context).finishAction
                          : result == null && acoustic == null
                          ? AppText.of(context).skipSentence
                          : AppText.of(context).audioNextSentence,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Timing feedback only. The synthetic distance is deliberately not presented
/// as a percentage: the Windows physical pilot invalidated that grade mapping.
class AcousticPracticeFeedback extends StatelessWidget {
  const AcousticPracticeFeedback({super.key, required this.acoustic});

  final AcousticScore acoustic;

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.graphic_eq_rounded),
            const SizedBox(height: 6),
            Text(t.pronunciationCompared),
            const SizedBox(height: 8),
            Text(
              acoustic.tempoRatio > 1.25
                  ? t.pronunciationSlower
                  : acoustic.tempoRatio < 0.8
                  ? t.pronunciationFaster
                  : t.pronunciationPacing,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              t.pronunciationAcousticNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
