/// The one place the app ever offers to use the network.
///
/// It is a card rather than a switch because a switch implies something free
/// and instant, and this is a hundred-megabyte download the learner is paying
/// for. The size, the licence and the accuracy caveat are all on the card
/// before the button is, so nobody starts it without knowing all three.
library;

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'asr.dart';

class AsrModelCard extends StatefulWidget {
  const AsrModelCard({super.key, required this.controller});

  final AppController controller;

  @override
  State<AsrModelCard> createState() => _AsrModelCardState();
}

class _AsrModelCardState extends State<AsrModelCard> {
  bool _working = false;

  @override
  void initState() {
    super.initState();
    // The card is built before the directory has been walked, so it opens
    // saying "absent" and corrects itself. That is the right way round: the
    // wrong way would be a spinner over a setting that is nearly always off.
    widget.controller.refreshAsrStatus();
  }

  static String _megabytes(int bytes) =>
      '${(bytes / (1024 * 1024)).round()} MB';

  Future<void> _install() async {
    setState(() => _working = true);
    try {
      await widget.controller.installAsrModel().drain<void>();
    } finally {
      if (mounted) setState(() => _working = false);
    }
    if (!mounted) return;
    final AsrModelStatus status = widget.controller.asrStatus;
    if (status.state == AsrModelState.failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status.message)),
      );
    }
  }

  Future<void> _confirmRemove() async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Remove the speech model?'),
        content: Text(
          'This frees about '
          '${_megabytes(widget.controller.asrDownloadBytes)}. '
          'The speaking lab keeps scoring your pronunciation either way; only '
          'the written transcript goes. Getting it back means downloading it '
          'again.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    setState(() => _working = true);
    try {
      await widget.controller.removeAsrModel();
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        // The card listens for itself rather than relying on its host to
        // rebuild it. The status arrives one frame late, from walking the
        // model directory, and a card that missed that notification would sit
        // there offering a download of something already installed.
        animation: widget.controller,
        builder: _build,
      );

  Widget _build(BuildContext context, Widget? _) {
    final AppController controller = widget.controller;
    final ThemeData theme = Theme.of(context);
    final AsrModelStatus status = controller.asrStatus;

    if (status.state == AsrModelState.unsupported) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.record_voice_over_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Written feedback on what you said',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'The speaking lab already scores how you sound. A German speech '
              'model adds the words: it writes down what it heard, so you can '
              'see whether a low score was your pronunciation or a different '
              'sentence.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            // Everything the learner is agreeing to, before the button.
            _fact(
              theme,
              Icons.download_rounded,
              'A one-time download of about '
              '${_megabytes(controller.asrDownloadBytes)}. '
              'This is the only thing in the whole app that uses the internet, '
              'and nothing else ever will.',
            ),
            _fact(
              theme,
              Icons.public_off_rounded,
              'After that it runs on this device. No recording leaves it, '
              'and there is no account and no server to send one to.',
            ),
            _fact(
              theme,
              Icons.balance_rounded,
              controller.asrAttribution,
            ),
            const SizedBox(height: 6),
            if (status.isBusy) ...<Widget>[
              LinearProgressIndicator(value: status.progress),
              const SizedBox(height: 6),
              Text(
                status.state == AsrModelState.installing
                    ? 'Unpacking'
                    : status.progress == null
                        ? 'Downloading'
                        : 'Downloading '
                            '${(status.progress! * 100).round()}%',
                style: theme.textTheme.bodySmall,
              ),
            ] else if (status.isReady) ...<Widget>[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show the transcript'),
                subtitle: const Text(
                  'Turn this off to keep the model but stop showing what it '
                  'heard.',
                ),
                value: controller.asrFeedbackEnabled,
                onChanged: _working
                    ? null
                    : (bool value) => controller.setAsrFeedbackEnabled(value),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _working ? null : _confirmRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Remove the model'),
                ),
              ),
            ] else
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _working ? null : _install,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download the speech model'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fact(ThemeData theme, IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 16, color: theme.colorScheme.outline),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          ],
        ),
      );
}
