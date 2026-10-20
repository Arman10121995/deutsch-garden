import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'app_state.dart';
import 'build_info.dart';
import 'l10n/app_localizations.dart';
import 'neural_tts.dart';
import 'platform_support.dart';
import 'vocab_icon.dart';

/// Draws before storage/plugin work starts. A failed profile load must never
/// leave the Android launch background as the app's only visible screen.
class GardenStartup extends StatefulWidget {
  const GardenStartup({super.key, this.createController, this.loadIcons});

  final AppController Function()? createController;
  final Future<void> Function()? loadIcons;

  @override
  State<GardenStartup> createState() => _GardenStartupState();
}

class _GardenStartupState extends State<GardenStartup> {
  AppController? _controller;
  Timer? _slowTimer;
  bool _opening = false, _ready = false, _slow = false;
  String? _failureType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_open());
    });
  }

  Future<void> _optionalIcons() async {
    try {
      await (widget.loadIcons?.call() ?? loadVocabIconIndex(rootBundle))
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Illustrations are optional. A stalled asset channel must not hold the
      // profile hostage; structural vocabulary cues remain available.
    }
  }

  Future<void> _open() async {
    if (_opening) return;
    _opening = true;
    setState(() {
      _failureType = null;
      _slow = false;
    });
    _slowTimer = Timer(const Duration(seconds: 12), () {
      if (mounted) setState(() => _slow = true);
    });
    try {
      final controller = widget.createController?.call() ?? AppController();
      _controller = controller;
      await Future.wait([controller.load(), _optionalIcons()]);
      if (!mounted) return;
      setState(() => _ready = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        debugPrint('DeutschGarden startup ready ($appVersion)');
        if (mounted && PlatformSupport.current != AppPlatform.android) {
          unawaited(_warmVoices());
        }
      });
    } catch (error) {
      // Do not print profile contents or continue with a writable empty
      // profile. Retry is offered only after the previous load has finished.
      _controller?.dispose();
      _controller = null;
      if (mounted) setState(() => _failureType = error.runtimeType.toString());
      debugPrint('DeutschGarden startup failed (${error.runtimeType})');
    } finally {
      _slowTimer?.cancel();
      _opening = false;
    }
  }

  Future<void> _warmVoices() async {
    try {
      await NeuralTts.instance.initialise();
    } catch (_) {
      // TTS already has a platform fallback and is optional at launch.
    }
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return DeutschGardenApp(controller: _controller!);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppText.of(context).appTitle,
      supportedLocales: AppText.supportedLocales,
      localizationsDelegates: AppText.localizationsDelegates,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF7C5CFC)),
      home: Builder(
        builder: (context) {
          final t = AppText.of(context);
          final failed = _failureType != null;
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.spa_rounded, size: 56),
                        const SizedBox(height: 20),
                        Text(
                          t.appTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        if (!failed) const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          failed
                              ? t.startupFailed
                              : _slow
                              ? t.startupSlow
                              : t.startupOpening,
                          textAlign: TextAlign.center,
                        ),
                        if (failed || _slow) ...[
                          const SizedBox(height: 12),
                          Text(t.startupPreserve, textAlign: TextAlign.center),
                        ],
                        if (failed) ...[
                          const SizedBox(height: 12),
                          Text(
                            t.startupDiagnostic(_failureType!),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _open,
                            child: Text(t.tryAgain),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
