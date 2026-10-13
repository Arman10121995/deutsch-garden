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
import 'l10n/app_localizations.dart';

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

  static int _megabytes(int bytes) => (bytes / (1024 * 1024)).round();

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
        SnackBar(
          content: Text(
            '${AppText.of(context).asrInstallFailed}\n${status.message}',
          ),
        ),
      );
    }
  }

  Future<void> _confirmRemove() async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppText.of(context).asrRemoveTitle),
        content: Text(
          AppText.of(
            context,
          ).asrRemoveBody(_megabytes(widget.controller.asrDownloadBytes)),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppText.of(context).keepAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppText.of(context).removeAction),
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
                    AppText.of(context).asrTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              AppText.of(context).asrBody,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            // Everything the learner is agreeing to, before the button.
            _fact(
              theme,
              Icons.download_rounded,
              AppText.of(
                context,
              ).asrDownloadFact(_megabytes(controller.asrDownloadBytes)),
            ),
            _fact(
              theme,
              Icons.public_off_rounded,
              AppText.of(context).asrLocalFact,
            ),
            _fact(theme, Icons.balance_rounded, controller.asrAttribution),
            _fact(
              theme,
              Icons.info_outline_rounded,
              AppText.of(context).asrAccuracyCaveat,
            ),
            const SizedBox(height: 6),
            if (status.isBusy) ...<Widget>[
              LinearProgressIndicator(value: status.progress),
              const SizedBox(height: 6),
              Text(
                status.state == AsrModelState.installing
                    ? AppText.of(context).asrUnpacking
                    : status.progress == null
                    ? AppText.of(context).asrDownloading
                    : AppText.of(
                        context,
                      ).asrDownloadProgress((status.progress! * 100).round()),
                style: theme.textTheme.bodySmall,
              ),
            ] else if (status.isReady) ...<Widget>[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppText.of(context).asrShowTranscript),
                subtitle: Text(AppText.of(context).asrTranscriptHelp),
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
                  label: Text(AppText.of(context).asrRemoveModel),
                ),
              ),
            ] else
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _working ? null : _install,
                  icon: const Icon(Icons.download_rounded),
                  label: Text(AppText.of(context).asrDownloadModel),
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      ],
    ),
  );
}
