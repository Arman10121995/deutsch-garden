/// One choice in a multiple-choice question, and how it looks once answered.
///
/// Before this the vocabulary session simply disabled all four options after
/// an answer, so a learner could not see which one they had picked or which
/// was right without reading a sentence underneath. The lesson quizzes tinted
/// the two options but used colour alone, which is no signal at all to a
/// learner who cannot tell red from green.
///
/// The right option always gets a tick and the wrong pick always gets a cross,
/// in addition to the tint. Shape carries the meaning; colour reinforces it.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n/app_localizations.dart';

/// What an option is showing.
enum AnswerOptionState {
  /// Not answered yet: an ordinary tappable button.
  idle,

  /// The right answer, shown once the question is answered.
  correct,

  /// The learner's pick, when it was wrong.
  wrong,

  /// Any other option after answering.
  dimmed,
}

/// The green used to mark a right answer.
///
/// Material's colour scheme has `error` but no counterpart for success, so
/// the two tones are fixed here and chosen for contrast on each surface.
Color answerCorrectColor(Brightness brightness) => brightness == Brightness.dark
    ? const Color(0xFF81C784)
    : const Color(0xFF2E7D32);

/// Resolves the state of one option from the question's outcome.
///
/// [chosen] is false for every option when the question was answered some
/// other way (a typed answer, say), which still marks the right one.
AnswerOptionState answerOptionState({
  required bool answered,
  required bool isCorrect,
  required bool chosen,
}) {
  if (!answered) return AnswerOptionState.idle;
  if (isCorrect) return AnswerOptionState.correct;
  return chosen ? AnswerOptionState.wrong : AnswerOptionState.dimmed;
}

class AnswerOptionButton extends StatelessWidget {
  const AnswerOptionButton({
    super.key,
    required this.label,
    required this.state,
    required this.onPressed,
    this.fontSize,
    this.verticalPadding = 15,
  });

  final String label;
  final AnswerOptionState state;

  /// Null once the question is answered. The state, not this, decides the
  /// colours: a disabled button that is the right answer must not look
  /// greyed out.
  final VoidCallback? onPressed;
  final double? fontSize;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color? tone = switch (state) {
      AnswerOptionState.correct => answerCorrectColor(theme.brightness),
      AnswerOptionState.wrong => theme.colorScheme.error,
      AnswerOptionState.idle || AnswerOptionState.dimmed => null,
    };
    final AppText text = AppText.of(context);
    final String? mark = switch (state) {
      AnswerOptionState.correct => text.answerMarkCorrect,
      AnswerOptionState.wrong => text.answerMarkChosen,
      AnswerOptionState.idle || AnswerOptionState.dimmed => null,
    };

    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onPressed,
            style: tone == null
                ? null
                : OutlinedButton.styleFrom(
                    disabledForegroundColor: theme.colorScheme.onSurface,
                    disabledBackgroundColor: tone.withValues(alpha: 0.14),
                    side: BorderSide(color: tone, width: 1.5),
                  ),
            // The horizontal padding is constant so the label does not shift
            // when the mark appears beside it.
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: verticalPadding,
                horizontal: 26,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: fontSize == null ? null : TextStyle(fontSize: fontSize),
              ),
            ),
          ),
        ),
        if (tone != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: IgnorePointer(
              child: Icon(
                state == AnswerOptionState.correct
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: tone,
                semanticLabel: mark,
              ),
            ),
          ),
      ],
    );
  }
}

/// The option a number key selects, or null when the key is not a digit.
///
/// Shared by every choice screen so 1–4 mean the same thing everywhere, on
/// the number row and the numeric keypad alike.
int? answerDigitFor(LogicalKeyboardKey key) {
  const List<List<LogicalKeyboardKey>> rows = <List<LogicalKeyboardKey>>[
    <LogicalKeyboardKey>[
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
    ],
    <LogicalKeyboardKey>[
      LogicalKeyboardKey.numpad1,
      LogicalKeyboardKey.numpad2,
      LogicalKeyboardKey.numpad3,
      LogicalKeyboardKey.numpad4,
      LogicalKeyboardKey.numpad5,
      LogicalKeyboardKey.numpad6,
    ],
  ];
  for (final List<LogicalKeyboardKey> row in rows) {
    final int index = row.indexOf(key);
    if (index >= 0) return index + 1;
  }
  return null;
}

/// True for the keys that mean "go on": Enter, keypad Enter and Space.
bool isAdvanceKey(LogicalKeyboardKey key) =>
    key == LogicalKeyboardKey.enter ||
    key == LogicalKeyboardKey.numpadEnter ||
    key == LogicalKeyboardKey.space;

/// Number keys and Enter for a screen of answer options.
///
/// It draws nothing. It holds the keyboard focus so that 1-6 choose an option
/// and Enter or Space continues, the same on every practice screen. Place it
/// beside the options and give it a [questionKey] that changes with the
/// question, so it takes the focus back when the next one appears.
///
/// A text field or a button the learner has tabbed to keeps its own keys:
/// this only hears a key while it is itself the focused node.
class AnswerKeys extends StatefulWidget {
  const AnswerKeys({
    super.key,
    required this.questionKey,
    required this.optionCount,
    required this.onSelect,
    this.onAdvance,
  });

  final Object questionKey;
  final int optionCount;

  /// Null once the question is answered.
  final ValueChanged<int>? onSelect;

  /// Null while there is nothing to continue from.
  final VoidCallback? onAdvance;

  @override
  State<AnswerKeys> createState() => _AnswerKeysState();
}

class _AnswerKeysState extends State<AnswerKeys> {
  final FocusNode _node = FocusNode(debugLabel: 'answer-keys');

  @override
  void didUpdateWidget(AnswerKeys old) {
    super.didUpdateWidget(old);
    if (old.questionKey != widget.questionKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _node.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  KeyEventResult _handle(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    final ValueChanged<int>? onSelect = widget.onSelect;
    if (onSelect != null) {
      final int? digit = answerDigitFor(key);
      if (digit == null || digit > widget.optionCount) {
        return KeyEventResult.ignored;
      }
      onSelect(digit - 1);
      return KeyEventResult.handled;
    }
    final VoidCallback? onAdvance = widget.onAdvance;
    if (onAdvance != null && isAdvanceKey(key)) {
      onAdvance();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: _node,
    autofocus: true,
    onKeyEvent: _handle,
    child: const SizedBox.shrink(),
  );
}
