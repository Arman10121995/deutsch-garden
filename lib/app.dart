import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

import 'app_state.dart';
import 'screens.dart';

class DeutschGardenApp extends StatefulWidget {
  const DeutschGardenApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<DeutschGardenApp> createState() => _DeutschGardenAppState();
}

class _DeutschGardenAppState extends State<DeutschGardenApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Profile writes are debounced, so at any moment there may be half a
    // second of unsaved answers. Losing them because the learner switched
    // apps would be a worse bug than the writes the debounce removes, so
    // every transition out of the foreground flushes first.
    //
    // detach is included but cannot be relied on: Android may kill a process
    // without delivering it. hide and inactive fire earlier and are what
    // actually saves the session.
    _lifecycle = AppLifecycleListener(
      onHide: widget.controller.prepareForBackground,
      onInactive: widget.controller.prepareForBackground,
      onPause: widget.controller.prepareForBackground,
      onDetach: widget.controller.prepareForBackground,
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
          onGenerateTitle: (BuildContext context) => AppText.of(context).appTitle,
          debugShowCheckedModeBanner: false,
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
