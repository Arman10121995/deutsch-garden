import 'package:flutter/material.dart';

import 'hints.dart';

/// Shared Previous / progressive hint / Skip controls for practice screens.
class PracticeAidPanel extends StatefulWidget {
  const PracticeAidPanel({
    super.key,
    required this.questionKey,
    this.hints = const <Hint>[],
    this.onPrevious,
    this.onSkip,
  });

  final String questionKey;
  final List<Hint> hints;
  final VoidCallback? onPrevious;
  final VoidCallback? onSkip;

  @override
  State<PracticeAidPanel> createState() => _PracticeAidPanelState();
}

class _PracticeAidPanelState extends State<PracticeAidPanel> {
  int _stage = 0;

  @override
  void didUpdateWidget(PracticeAidPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionKey != widget.questionKey) _stage = 0;
  }

  @override
  Widget build(BuildContext context) {
    final Hint? shown = _stage <= 0 || widget.hints.isEmpty
        ? null
        : widget.hints[(_stage - 1).clamp(0, widget.hints.length - 1)];
    if (widget.hints.isEmpty &&
        widget.onPrevious == null &&
        widget.onSkip == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runSpacing: 4,
          children: <Widget>[
            if (widget.onPrevious != null)
              TextButton.icon(
                onPressed: widget.onPrevious,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Previous'),
              ),
            if (widget.hints.isNotEmpty)
              TextButton.icon(
                onPressed: _stage >= widget.hints.length
                    ? null
                    : () => setState(() => _stage += 1),
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: Text(_stage == 0 ? 'Hint' : 'Another hint'),
              ),
            if (widget.onSkip != null)
              TextButton.icon(
                onPressed: widget.onSkip,
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('Skip'),
              ),
          ],
        ),
        if (shown != null) ...<Widget>[
          const SizedBox(height: 4),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(switch (shown.kind) {
                    HintKind.rule => 'The rule',
                    HintKind.structural => 'Where to look',
                    HintKind.card => 'About this word',
                  }, style: const TextStyle(fontWeight: FontWeight.w900)),
                  if (shown.personalized)
                    Text(
                      'Based on your earlier practice',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  const SizedBox(height: 5),
                  Text(shown.text),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
