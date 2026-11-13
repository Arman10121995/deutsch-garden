import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'l10n/app_localizations.dart';
import 'tts_service.dart';
import 'ui_feedback.dart';

/// Question tools also record exposure after the question has been rendered.
/// Merely drawing a mock must not mark its unvisited questions as seen.
class TestQuestionTools extends StatefulWidget {
  const TestQuestionTools({
    super.key,
    required this.controller,
    required this.questionId,
    required this.spokenText,
    required this.onRandom,
    this.enabled = true,
    this.speech,
  });

  final AppController controller;
  final String questionId;
  final String spokenText;
  final VoidCallback? onRandom;
  final bool enabled;
  final TtsService? speech;

  @override
  State<TestQuestionTools> createState() => _TestQuestionToolsState();
}

class _TestQuestionToolsState extends State<TestQuestionTools>
    with AutomaticKeepAliveClientMixin<TestQuestionTools> {
  TtsService? _speech;
  bool _reading = false;
  int _generation = 0;
  late bool _fresh;

  @override
  void initState() {
    super.initState();
    _fresh = !widget.controller.seenTestQuestionIds.contains(widget.questionId);
    _recordExposure();
  }

  @override
  bool get wantKeepAlive => true;

  void _recordExposure({bool reveal = false}) {
    final id = widget.questionId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.questionId == id && widget.enabled) {
        unawaited(widget.controller.recordTestQuestionSeen(id));
        if (reveal) {
          unawaited(
            Scrollable.ensureVisible(
              context,
              duration: MediaQuery.of(context).disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
            ),
          );
        }
      }
    });
  }

  @override
  void didUpdateWidget(TestQuestionTools oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionId != widget.questionId ||
        oldWidget.enabled && !widget.enabled) {
      if (oldWidget.questionId != widget.questionId) {
        _fresh = !widget.controller.seenTestQuestionIds.contains(
          widget.questionId,
        );
      }
      _stop();
      _recordExposure(reveal: oldWidget.questionId != widget.questionId);
    }
  }

  void _stop() {
    _generation++;
    _reading = false;
    final speech = _speech;
    if (speech != null) unawaited(speech.stop());
  }

  Future<void> _read() async {
    if (!mounted || !widget.enabled) return;
    if (_reading) {
      setState(_stop);
      return;
    }
    final generation = ++_generation;
    final speech = _speech ??= widget.speech ?? TtsService();
    setState(() => _reading = true);
    try {
      await speech.speakTurns([SpokenTurn(widget.spokenText)]);
      if (mounted &&
          generation == _generation &&
          speech.backend == TtsBackend.none) {
        _unavailable();
      }
    } catch (_) {
      if (mounted && generation == _generation) _unavailable();
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _reading = false);
      }
    }
  }

  void _unavailable() => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppText.of(context).testSpeechUnavailable)),
  );

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      // One row. These were a badge and two labelled buttons on three rows,
      // which pushed the question itself halfway down a phone screen. The
      // buttons are icons now; their tooltips carry the names.
      child: Row(
        children: [
          Flexible(
            child: Chip(
              avatar: Icon(
                _fresh
                    ? Icons.auto_awesome_outlined
                    : Icons.visibility_outlined,
                size: 18,
              ),
              label: Text(
                _fresh
                    ? AppText.of(context).questionNewBadge
                    : AppText.of(context).questionSeenBadge,
                overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: _fresh
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : null,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const Spacer(),
          IconButton.filledTonal(
            tooltip: _reading
                ? AppText.of(context).testStopReading
                : AppText.of(context).testReadQuestion,
            onPressed: widget.enabled ? _read : null,
            icon: Icon(_reading ? Icons.stop_rounded : Icons.volume_up_rounded),
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            tooltip: AppText.of(context).testRandomQuestion,
            onPressed: widget.enabled && widget.onRandom != null
                ? () {
                    widget.controller.requestFeedback(UiFeedbackEvent.click);
                    widget.onRandom!();
                  }
                : null,
            icon: const Icon(Icons.shuffle_rounded),
          ),
        ],
      ),
    );
  }
}

/// Speak all choices in their displayed order, without identifying the answer.
String spokenTestQuestion(String question, Iterable<String> options) => [
  question,
  ...options.indexed.map(
    (item) => '${String.fromCharCode(65 + item.$1)}. ${item.$2}',
  ),
].join('\n');
