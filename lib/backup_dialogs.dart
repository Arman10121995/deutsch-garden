import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'backup.dart';
import 'l10n/app_localizations.dart';
import 'pending_action.dart';
import 'profile_text.dart';

class BackupExportDialog extends StatefulWidget {
  const BackupExportDialog({super.key, required this.payload});
  final String payload;
  @override
  State<BackupExportDialog> createState() => _BackupExportDialogState();
}

class _BackupExportDialogState extends State<BackupExportDialog>
    with PendingAction<BackupExportDialog> {
  bool _closed = false;

  void _close(bool copied) {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.pop(context, copied);
  }

  Future<void> _copy() async {
    if (_closed) return;
    await runAction(() async {
      try {
        await Clipboard.setData(ClipboardData(text: widget.payload));
        _close(true);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppText.of(context).settingsClipboardFailed),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    return PopScope(
      canPop: !actionPending,
      child: AlertDialog(
        scrollable: true,
        title: Text(t.settingsExport),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.settingsExportBody),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      widget.payload,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: actionPending ? null : () => _close(false),
            child: Text(t.closeAction),
          ),
          FilledButton.icon(
            onPressed: actionPending ? null : _copy,
            icon: const Icon(Icons.copy_all_outlined),
            label: Text(actionPending ? t.savingAction : t.copyAction),
          ),
        ],
      ),
    );
  }
}

class BackupImportDialog extends StatefulWidget {
  const BackupImportDialog({super.key});
  @override
  State<BackupImportDialog> createState() => _BackupImportDialogState();
}

class _BackupImportDialogState extends State<BackupImportDialog>
    with PendingAction<BackupImportDialog> {
  final _input = TextEditingController();
  BackupImportResult? _error;
  bool _closed = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _paste() => runAction(() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (mounted && !_closed && data?.text != null) {
        _input.text = data!.text!;
        setState(() => _error = null);
      }
    } catch (_) {
      if (mounted && !_closed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.of(context).settingsClipboardFailed)),
        );
      }
    }
  });

  void _close([Map<String, dynamic>? state]) {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.pop(context, state);
  }

  void _check() {
    if (_closed || actionPending) return;
    final result = ProgressBackup.parse(_input.text);
    if (!result.isSuccess) {
      setState(() => _error = result);
    } else {
      _close(result.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(t.settingsImport),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.settingsPasteBackup),
            const SizedBox(height: 12),
            TextField(
              controller: _input,
              enabled: !actionPending,
              minLines: 5,
              maxLines: 10,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                hintText: t.settingsBackupHint,
                errorText: _error == null ? null : backupErrorText(t, _error!),
                errorMaxLines: 5,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: actionPending ? null : _paste,
              icon: const Icon(Icons.paste_outlined),
              label: Text(t.settingsPaste),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => _close(), child: Text(t.cancelAction)),
        FilledButton(
          onPressed: actionPending ? null : _check,
          child: Text(t.checkAnswer),
        ),
      ],
    );
  }
}

class ProfileDialogChoice<T> {
  const ProfileDialogChoice(this.label, this.value, {this.primary = false});
  final String label;
  final T? value;
  final bool primary;
}

class ProfileChoiceDialog<T> extends StatefulWidget {
  const ProfileChoiceDialog({
    super.key,
    required this.title,
    required this.body,
    required this.choices,
  });
  final String title, body;
  final List<ProfileDialogChoice<T>> choices;
  @override
  State<ProfileChoiceDialog<T>> createState() => _ProfileChoiceDialogState<T>();
}

class _ProfileChoiceDialogState<T> extends State<ProfileChoiceDialog<T>> {
  bool _closed = false;
  void _choose(T? value) {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text(widget.title),
    content: Text(widget.body),
    actions: [
      for (final choice in widget.choices)
        choice.primary
            ? FilledButton(
                onPressed: () => _choose(choice.value),
                child: Text(choice.label),
              )
            : TextButton(
                onPressed: () => _choose(choice.value),
                child: Text(choice.label),
              ),
    ],
  );
}
