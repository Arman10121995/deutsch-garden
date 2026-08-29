/// What a learner sees the very first time they open the app.
///
/// Without this they land on a route screen with no explanation of what the
/// app is, whether it needs an account, where their data goes, or what the
/// single button in front of them will do. The repository has an
/// `INSTRUCTIONS.md`, but that is a build guide for whoever compiles the app
/// and would be worse than nothing here.
///
/// Four screens, skippable, shown once. It is deliberately short: an intro
/// that outstays its welcome gets dismissed without being read, which is the
/// same outcome as not having one.
library;

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'test_screens.dart';
import 'l10n/app_localizations.dart';

class _Page {
  const _Page(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

/// Built per frame rather than held as a const list: the text has to change
/// when the interface language does, and a const list cannot.
List<_Page> _pagesFor(AppText text) => <_Page>[
      _Page(Icons.local_florist_outlined, text.onboardingWelcomeTitle,
          text.onboardingWelcomeBody),
      _Page(Icons.wifi_off_outlined, text.onboardingOfflineTitle,
          text.onboardingOfflineBody),
      _Page(Icons.route_outlined, text.onboardingLearnTitle,
          text.onboardingLearnBody),
      _Page(Icons.explore_outlined, text.onboardingExploreTitle,
          text.onboardingExploreBody),
      _Page(Icons.equalizer_rounded, text.onboardingLevelTitle,
          text.onboardingLevelBody),
    ];

/// How many pages the intro has. Fixed, so the dots and the "last page" test
/// do not need the strings.
const int _pageCount = 5;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pager = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  bool get _onLast => _index == _pageCount - 1;

  Future<void> _finish() => widget.controller.completeOnboarding();

  /// Takes the placement test now, rather than leaving a new learner to find
  /// it later.
  ///
  /// Without this the app opens at A1 for everyone, and someone who already
  /// reads German spends their first session on *der Mann*. The test decides
  /// where the guided path starts; the levels below it stay open, because
  /// being placed at B1 is not a claim that A2 holds nothing worth reviewing.
  Future<void> _placeMe() async {
    await Navigator.of(context).push<void>(MaterialPageRoute<void>(
      builder: (BuildContext context) =>
          PlacementIntroScreen(controller: widget.controller),
    ));
    if (!mounted) return;
    await _finish();
  }

  void _next() {
    if (_onLast) {
      _finish();
      return;
    }
    _pager.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<_Page> pages = _pagesFor(AppText.of(context));
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(AppText.of(context).actionSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pager,
                itemCount: pages.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int i) {
                  final _Page page = pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(page.icon, size: 56, color: scheme.primary),
                        const SizedBox(height: 24),
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < pages.length; i++)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _index
                            ? scheme.primary
                            : scheme.outlineVariant,
                      ),
                    ),
                  const Spacer(),
                  if (_onLast) ...<Widget>[
                    TextButton(
                      onPressed: _finish,
                      child: Text(AppText.of(context).onboardingStartAtA1),
                    ),
                    const SizedBox(width: 8),
                  ],
                  FilledButton(
                    onPressed: _onLast ? _placeMe : _next,
                    child: Text(_onLast
                        ? AppText.of(context).onboardingFindMyLevel
                        : AppText.of(context).actionNext),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
