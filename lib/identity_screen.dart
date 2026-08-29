/// Editing the learner's name, email and picture.
///
/// The screen says plainly that none of it leaves the device, because an app
/// asking for an email address has usually earned some suspicion. This one has
/// no server to send it to.
library;

import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'identity.dart';

class IdentityScreen extends StatefulWidget {
  const IdentityScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  late final TextEditingController _name =
      TextEditingController(text: widget.controller.learnerName);
  late final TextEditingController _email =
      TextEditingController(text: widget.controller.learnerEmail);
  String? _emailError;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    setState(() => _busy = true);
    try {
      const XTypeGroup images = XTypeGroup(
        label: 'Images',
        extensions: <String>['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'],
      );
      final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[images]);
      if (file == null) return;
      final Uint8List raw = await file.readAsBytes();
      // Decoding and resizing happen here rather than at display time: a
      // twelve-megapixel photograph should not be what gets stored.
      final AvatarResult result = prepareAvatar(raw);
      if (!mounted) return;
      if (!result.ok) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result.error!)));
        return;
      }
      await widget.controller.setAvatar(result.bytes);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('That picture could not be opened: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final String email = _email.text.trim();
    if (!looksLikeEmail(email)) {
      setState(() => _emailError = 'That does not look like an email address.');
      return;
    }
    setState(() => _emailError = null);
    await widget.controller.setIdentity(name: _name.text, email: email);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = widget.controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Your profile')),
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
                        onPressed: _busy ? null : _pickAvatar,
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Choose a picture'),
                      ),
                      if (controller.avatar != null)
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => controller.setAvatar(null),
                          child: const Text('Remove'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                helperText: 'Shown on your profile. Leave it blank if you like.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email (optional)',
                errorText: _emailError,
                helperText: 'Stored on this device and never sent anywhere.',
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
                        'This is not an account. There is no server to send it '
                        'to, nothing here is used to identify you, and the '
                        'email field is read by nothing in the app. It all '
                        'lives beside your streak count and leaves with your '
                        'export.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _busy ? null : _save, child: const Text('Save')),
          ],
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
        child: Image.memory(bytes,
            width: size, height: size, fit: BoxFit.cover, gaplessPlayback: true),
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
          ? Icon(Icons.person_outline_rounded,
              size: size * 0.5, color: scheme.onPrimaryContainer)
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
