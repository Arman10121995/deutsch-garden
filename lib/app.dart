import 'package:flutter/material.dart';
import 'dart:async';

import 'l10n/app_localizations.dart';

import 'app_state.dart';
import 'screens.dart';
import 'ui_feedback.dart';
import 'ui_sound_player.dart';

class DeutschGardenApp extends StatefulWidget {
  const DeutschGardenApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<DeutschGardenApp> createState() => _DeutschGardenAppState();
}

class _DeutschGardenAppState extends State<DeutschGardenApp> {
  late final AppLifecycleListener _lifecycle;
  final UiSoundPlayer _sounds = UiSoundPlayer();
  late final NavigatorObserver _routeFeedback = _FeedbackRouteObserver(
    () => controller.requestFeedback(UiFeedbackEvent.click),
  );
  bool _foreground = true;
  bool _hasDrawnFrame = false;

  void _syncFeedback() => _sounds.enabled = controller.uiSoundsEnabled;
  void _feedback(UiFeedbackEvent event) {
    if (_foreground && _hasDrawnFrame) unawaited(_sounds.play(event));
  }

  void _background() {
    _foreground = false;
    unawaited(_sounds.stop());
    controller.prepareForBackground();
  }

  void _resume() {
    _foreground = true;
    controller.resumeStudyTracking();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _hasDrawnFrame = true;
    });
    controller.uiFeedback = _feedback;
    controller.addListener(_syncFeedback);
    _syncFeedback();
    // Profile writes are debounced, so at any moment there may be half a
    // second of unsaved answers. Losing them because the learner switched
    // apps would be a worse bug than the writes the debounce removes, so
    // every transition out of the foreground flushes first.
    //
    // detach is included but cannot be relied on: Android may kill a process
    // without delivering it. hide and inactive fire earlier and are what
    // actually saves the session.
    _lifecycle = AppLifecycleListener(
      onHide: _background,
      onInactive: _background,
      onPause: _background,
      onDetach: _background,
      onResume: _resume,
    );
  }

  @override
  void dispose() {
    controller.removeListener(_syncFeedback);
    if (controller.uiFeedback == _feedback) controller.uiFeedback = null;
    unawaited(_sounds.dispose());
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DeutschGardenApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == controller) return;
    oldWidget.controller.removeListener(_syncFeedback);
    if (oldWidget.controller.uiFeedback == _feedback) {
      oldWidget.controller.uiFeedback = null;
    }
    controller.uiFeedback = _feedback;
    controller.addListener(_syncFeedback);
    _syncFeedback();
  }

  AppController get controller => widget.controller;

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C5CFC),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? const Color(0xFF101116)
          : const Color(0xFFF6F6FA),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (BuildContext context) =>
              AppText.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          navigatorObservers: [_routeFeedback],
          locale: controller.uiLocale,
          supportedLocales: AppText.supportedLocales,
          localizationsDelegates: AppText.localizationsDelegates,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          themeMode: controller.themeMode,
          home: MainShell(controller: controller),
        );
      },
    );
  }
}

/// Route transitions cover lesson cards, dialogs and back navigation without
/// noisy pointer listeners that would mistake scrolling for a click.
class _FeedbackRouteObserver extends NavigatorObserver {
  _FeedbackRouteObserver(this.onTap);
  final VoidCallback onTap;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // The initial home route must stay silent and open no audio plugin.
    if (previousRoute != null) onTap();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) onTap();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null && newRoute != null) onTap();
  }
}
