/// Editing the learner's name, email and picture.
///
/// Identity is local and optional. Name and email travel with a progress
/// export; the separately stored picture stays on this device.
library;

import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'l10n/app_localizations.dart';
import 'identity.dart';
import 'pending_action.dart';
import 'profile_text.dart';

class IdentityScreen extends StatefulWidget {
  const IdentityScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen>
    with PendingAction<IdentityScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.controller.learnerName,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.controller.learnerEmail,
  );
  bool _emailInvalid = false;
  bool _saved = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() => runAction(() async {
    try {
      final XTypeGroup images = XTypeGroup(
        label: AppText.of(context).profileImageFiles,
        extensions: <String>['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'],
      );
      final XFile? file = await openFile(
        acceptedTypeGroups: <XTypeGroup>[images],
      );
      if (file == null) return;
      final Uint8List raw = await file.readAsBytes();
      // Decoding and resizing happen here rather than at display time: a
      // twelve-megapixel photograph should not be what gets stored.
      final AvatarResult result = prepareAvatar(raw);
      if (!mounted) return;
      if (!result.ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(avatarErrorText(AppText.of(context), result))),
        );
        return;
      }
      await widget.controller.setAvatar(result.bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.of(context).profilePictureFailed)),
      );
    }
  });

  Future<void> _removeAvatar() => runAction(() async {
    try {
      await widget.controller.setAvatar(null);
    } catch (_) {
      _saveFailed();
    }
  });

  void _saveFailed() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppText.of(context).profileSaveFailed)),
    );
  }

  Future<void> _save() async {
    if (_saved) return;
    await runAction(() async {
      final String email = _email.text.trim();
      if (!looksLikeEmail(email)) {
        setState(() => _emailInvalid = true);
        return;
      }
      setState(() => _emailInvalid = false);
      try {
        await widget.controller.setIdentity(name: _name.text, email: email);
        await widget.controller.flushSave();
        if (!mounted) return;
        _saved = true;
        Navigator.of(context).pop();
      } catch (_) {
        _saveFailed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = widget.controller;
    return PopScope(
      canPop: !actionPending,
      child: Scaffold(
        appBar: AppBar(title: Text(AppText.of(context).profileEditTitle)),
        body: AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, _) => ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[
                    ProfileAvatar(controller: controller, size: 104),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: <Widget>[
                        FilledButton.tonalIcon(
                          onPressed: actionPending ? null : _pickAvatar,
                          icon: const Icon(Icons.image_outlined),
                          label: Text(AppText.of(context).profileChoosePicture),
                        ),
                        if (controller.avatar != null)
                          TextButton(
                            onPressed: actionPending ? null : _removeAvatar,
                            child: Text(
                              AppText.of(context).profileRemovePicture,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                enabled: !actionPending,
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: AppText.of(context).profileName,
                  helperText: AppText.of(context).profileNameHelp,
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: !actionPending,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: AppText.of(context).profileEmail,
                  errorText: _emailInvalid
                      ? AppText.of(context).profileEmailInvalid
                      : null,
                  errorMaxLines: 3,
                  helperText: AppText.of(context).profileEmailHelp,
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.lock_outline_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppText.of(context).profilePrivacy,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: actionPending ? null : _save,
                child: Text(
                  actionPending
                      ? AppText.of(context).savingAction
                      : AppText.of(context).saveAction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The learner's picture, or their initials, or a fallback.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.controller, this.size = 56});

  final AppController controller;
  final double size;

  String get _initials {
    final List<String> parts = controller.learnerName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Uint8List? bytes = controller.avatar;
    if (bytes != null) {
      return ClipOval(
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
    }
    final String initials = _initials;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primaryContainer,
      ),
      child: initials.isEmpty
          ? Icon(
              Icons.person_outline_rounded,
              size: size * 0.5,
              color: scheme.onPrimaryContainer,
            )
          : Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.36,
                fontWeight: FontWeight.w800,
                color: scheme.onPrimaryContainer,
              ),
            ),
    );
  }
}
